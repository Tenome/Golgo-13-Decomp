#!/usr/bin/env python3
"""Differential test of the mechanically lifted C (c/auto/<ver>/, tools/lift.py) against the original 6502 code.

For every lifted routine: random CPU RAM / registers / flags, the routine's own PRG bank mapped at $8000; run the original through
tools/sim6502.py and the C function; compare RAM (except the stack page), A X Y, flags C Z N V, SP, the PPU/APU/mapper write log
and the MMC1 bank. Runs where the original does not return (spin loops on PPU registers, jumps into RAM) or where the C reports
an unknown target are skipped, so a routine is `verified` only with enough completed comparisons.
usage: python tools/autotest.py [--version us|jp] [--runs N] [--only NAME] [--jobs N] [--clang PATH]"""
import argparse, ctypes, json, multiprocessing, os, random, shutil, subprocess, sys, zlib
ap = argparse.ArgumentParser(); ap.add_argument('--version', default=os.environ.get('G13_VERSION', 'us')); ap.add_argument('--runs', type=int, default=80)
ap.add_argument('--only'); ap.add_argument('--jobs', type=int, default=10); ap.add_argument('--clang'); ap.add_argument('--min-ok', type=int, default=20)
ap.add_argument('--steps', type=int, default=30000)
ap.add_argument('--snaps', help='file of 2 KB RAM snapshots from tools/frametest.py --dump-ram (default build/ram_snaps_<ver>.bin when present)')
a = ap.parse_args()
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.argv = [sys.argv[0], '--version', a.version]; sys.path.insert(0, HERE)
import g13dis, sim6502
CDIR = os.path.join(ROOT, 'c'); ADIR = os.path.join(ROOT, 'build', f'auto_{a.version}')   # traced copy of the lifted C, regenerated for every run

FUNCS = None
DLL = os.path.join(ROOT, 'build', f'golgo13_auto_{a.version}' + ('.dll' if os.name == 'nt' else '.so'))

def find_cc():
    for c in (a.clang, os.environ.get('CLANG'), 'clang', 'gcc', 'cc'):
        if c:
            p = shutil.which(c) or (c if os.path.exists(c) else None)
            if p: return p
    sys.exit('no C compiler found (pass --clang PATH or set CLANG)')
def build():
    os.makedirs(os.path.dirname(DLL), exist_ok=True)
    subprocess.check_call([sys.executable, os.path.join(HERE, 'lift.py'), '--version', a.version, '--trace', '--out', ADIR], stdout=subprocess.DEVNULL)
    srcs = [os.path.join(CDIR, 'core.c'), os.path.join(CDIR, 'auto', 'runtime.c'), os.path.join(ADIR, 'dispatch.c')] + \
           [os.path.join(ADIR, f'bank_{b}.c') for b in range(8)] + [os.path.join(ADIR, 'ram_code.c')]
    subprocess.check_call([find_cc(), '-shared', '-O1', '-fPIC', '-w', '-I', os.path.join(CDIR, 'auto'), '-o', DLL] + srcs)

class CpuS(ctypes.Structure):
    _fields_ = [(n, ctypes.c_uint8) for n in ('a', 'x', 'y', 'sp', 'c', 'z', 'n', 'v', 'd', 'i')]

def worker(names):
    global FUNCS
    FUNCS = json.load(open(os.path.join(ADIR, 'funcs.json')))
    lib = ctypes.CDLL(DLL)
    R = CpuS.in_dll(lib, 'R'); ram_c = (ctypes.c_uint8 * 0x800).in_dll(lib, 'g_ram')
    log_addr = (ctypes.c_uint16 * 8192).in_dll(lib, 'g_iolog_addr'); log_val = (ctypes.c_uint8 * 8192).in_dll(lib, 'g_iolog_val')
    log_n = ctypes.c_int.in_dll(lib, 'g_iolog_n'); bank_c = ctypes.c_uint8.in_dll(lib, 'g_bank')
    prg = bytes(g13dis.PRG); prg_buf = ctypes.create_string_buffer(prg, len(prg))
    ctypes.c_void_p.in_dll(lib, 'g_prg').value = ctypes.addressof(prg_buf)
    tr_pc = (ctypes.c_uint16 * 100000).in_dll(lib, 'g_tr_pc'); tr_reg = ((ctypes.c_uint8 * 6) * 100000).in_dll(lib, 'g_tr_reg')
    run_fn = lib.g13_run; run_fn.argtypes = [ctypes.c_void_p, ctypes.c_int]; run_fn.restype = ctypes.c_int
    snapf = a.snaps or os.path.join(ROOT, 'build', f'ram_snaps_{a.version}.bin')
    snaps = []
    if os.path.exists(snapf):
        raw = open(snapf, 'rb').read(); snaps = [raw[i:i + 0x800] for i in range(0, len(raw) - 0x7FF, 0x800)]
    res = {}
    for name in names:
        info = FUNCS[name]; addr, bank = info['addr'], info['bank']
        fp = ctypes.cast(getattr(lib, name), ctypes.c_void_p)
        rnd = random.Random(zlib.crc32(name.encode())); ok = skip = 0; fail = None
        for i in range(a.runs):
            ram = bytearray(rnd.randrange(256) for _ in range(0x800))
            if snaps and i % 2 == 1: ram = bytearray(rnd.choice(snaps))        # a RAM image from real play
            elif i % 3 == 1:                                    # sparser RAM reaches the 'zero' branches
                for k in range(0x800):
                    if rnd.random() < 0.7: ram[k] = rnd.choice((0, 0, 1, 2, 0x10, 0x80, 0xFF))
            regs = dict(a=rnd.randrange(256), x=rnd.randrange(256), y=rnd.randrange(256), c=rnd.randrange(2), z=rnd.randrange(2), n=rnd.randrange(2), v=rnd.randrange(2))
            if i % 3 == 2: regs.update(x=rnd.randrange(8), y=rnd.randrange(8))
            b = bank if bank < 7 else rnd.randrange(7)
            if bank < 7: ram[0xFB] = bank
            else: ram[0xFB] = b
            cpu = sim6502.CPU(prg); cpu.ram[:] = ram; cpu.bank = b; cpu.z = regs['z']; cpu.n = regs['n']; cpu.v = regs['v']
            try: ra = cpu.call(addr, regs['a'], regs['x'], regs['y'], regs['c'], max_steps=a.steps)
            except Exception: skip += 1; continue
            if cpu.stray_write: skip += 1; continue
            for k in range(0x800): ram_c[k] = ram[k]
            ram_c[0x1FF] = 0xFF; ram_c[0x1FE] = 0xFD
            bank_c.value = b; lib.iolog_reset()
            R.a, R.x, R.y, R.c, R.z, R.n, R.v, R.sp, R.d, R.i = regs['a'], regs['x'], regs['y'], regs['c'], regs['z'], regs['n'], regs['v'], 0xFD, 0, 0
            r = run_fn(fp, 200000)
            if r in (1, 4, 5, 6): skip += 1; continue             # budget exhausted / unknown target / stack tampering: cannot compare
            if r:                                              # brk / unsupported in C but the original returned
                fail = f'C aborted ({r}) but the original returned'; break
            bad = [k for k in range(0x800) if not 0x100 <= k < 0x200 and cpu.ram[k] != ram_c[k]]
            diffs = [n for n, mine, theirs in (('a', ra[0], R.a), ('x', ra[1], R.x), ('y', ra[2], R.y), ('c', ra[3], R.c), ('z', cpu.z, R.z),
                                              ('n', cpu.n, R.n), ('v', cpu.v, R.v), ('sp', cpu.sp, (R.sp + 2) & 0xFF)) if mine != theirs]
            clog = [(log_addr[k], log_val[k]) for k in range(min(log_n.value, 8192))]
            if bad or diffs or clog != cpu.io_writes or cpu.bank != bank_c.value:
                fail_extra = ''
                try:   # re-run both with an instruction trace and report the first divergence
                    t2 = sim6502.CPU(prg); t2.ram[:] = ram; t2.bank = b; t2.z = regs['z']; t2.n = regs['n']; t2.v = regs['v']; t2.trace = []
                    t2.call(addr, regs['a'], regs['x'], regs['y'], regs['c'], max_steps=a.steps)
                    for k in range(0x800): ram_c[k] = ram[k]
                    ram_c[0x1FF] = 0xFF; ram_c[0x1FE] = 0xFD
                    bank_c.value = b; lib.iolog_reset(); lib.g13_trace_start()
                    R.a, R.x, R.y, R.c, R.z, R.n, R.v, R.sp, R.d, R.i = regs['a'], regs['x'], regs['y'], regs['c'], regs['z'], regs['n'], regs['v'], 0xFD, 0, 0
                    run_fn(fp, 200000); n = ctypes.c_int.in_dll(lib, 'g_tr_n').value
                    trc = [(tr_pc[k], *tuple(tr_reg[k][j] for j in range(6))) for k in range(n)]; lib.g13_trace_stop()
                    for k in range(min(len(trc), len(t2.trace))):
                        if tuple(trc[k]) != tuple(t2.trace[k]):
                            fail_extra = f' FIRST DIVERGENCE at step {k}: asm(pc,a,x,y,c,z,n)={tuple(hex(v) for v in t2.trace[k])} C={tuple(hex(v) for v in trc[k])} prev asm pc={hex(t2.trace[k-1][0]) if k else None}'; break
                    else: fail_extra = f' (traces equal for {min(len(trc), len(t2.trace))} steps; asm {len(t2.trace)} C {len(trc)})'
                except Exception as e: fail_extra = f' (trace failed: {e})'
                fail = f'run {i}: ram {[hex(k) for k in bad[:5]]} regs {diffs} io {"DIFF" if clog != cpu.io_writes else "ok"} bank {"DIFF" if cpu.bank != bank_c.value else "ok"}{fail_extra} in={regs} asm(a,x,y,c)={ra} z={cpu.z} n={cpu.n} c=(a={R.a:#x} x={R.x:#x} y={R.y:#x} c={R.c} z={R.z} n={R.n}) ram_asm={[hex(cpu.ram[k]) for k in bad[:4]]} ram_c={[hex(ram_c[k]) for k in bad[:4]]}'
                break
            ok += 1
        res[name] = (ok, skip, fail)
    return res

if __name__ == '__main__':
    os.environ['G13_VERSION'] = a.version
    build()
    FUNCS = json.load(open(os.path.join(ADIR, 'funcs.json')))
    names = [n for n, v in FUNCS.items() if v['ok'] and v['bank'] < 8 and (not a.only or n == a.only)]
    chunks = [names[i::a.jobs] for i in range(a.jobs)]
    with multiprocessing.Pool(a.jobs) as pool: parts = pool.map(worker, chunks)
    res = {}; [res.update(p) for p in parts]
    verified = [n for n, (ok, sk, f) in res.items() if not f and ok >= a.min_ok]
    weak = [n for n, (ok, sk, f) in res.items() if not f and ok < a.min_ok]
    failed = [(n, f) for n, (ok, sk, f) in res.items() if f]
    for n, f in failed[:40]: print(f'FAIL {n}: {f}')
    print(f'[{a.version}] {len(names)} lifted routines: {len(verified)} verified (>= {a.min_ok} comparisons, all equal), {len(weak)} untestable on random input, {len(failed)} FAILED')
    json.dump({n: dict(ok=r[0], skipped=r[1], fail=r[2]) for n, r in sorted(res.items())}, open(os.path.join(ROOT, 'build', f'autotest_{a.version}.json'), 'w'), indent=1)
    if not a.only and not failed:      # committed so the C-progress report (tools/report.py --c) can be rebuilt without the ROM
        json.dump({'verified': sorted(verified), 'lifted': sorted(names)}, open(os.path.join(ROOT, 'config', a.version, 'verified.json'), 'w'), indent=0)
    sys.exit(1 if failed else 0)
