#!/usr/bin/env python3
"""Whole-program differential test: run the mechanically lifted C (c/auto/<ver>) and the original 6502 code (tools/sim6502.py)
frame by frame from power-on and compare CPU RAM, the PPU/APU/mapper write log and the PRG bank after every NMI.

Reset runs first (RAM clear, hardware setup, PPU warm-up loops); after that all game logic runs inside the NMI handler, so a frame
is one call of the handler. Reads of $2002 and the joypad ports use the deterministic pattern shared by c/core.c and the simulator,
so both sides see the same inputs. usage: python tools/frametest.py [--version us|jp] [--frames N] [--clang PATH]"""
import argparse, ctypes, os, subprocess, sys
ap = argparse.ArgumentParser(); ap.add_argument('--version', default='us'); ap.add_argument('--frames', type=int, default=300)
ap.add_argument('--clang'); ap.add_argument('--keep', action='store_true')
ap.add_argument('--seed', type=int, default=7); ap.add_argument('--assist', action='store_true', help='hold life and ammo up in both models (QA assist) so random play survives longer')
ap.add_argument('--out-exec', help='write the ROM code the simulator executed (PRG offsets) to this JSON file instead of only learning on failures')
ap.add_argument('--dll', help='use a separate DLL path (parallel runs)')
ap.add_argument('--dump-ram', help='append a snapshot of CPU RAM to this file every --dump-every frames (realistic starting states for tools/autotest.py --snaps)')
ap.add_argument('--dump-every', type=int, default=40)
ap.add_argument('--dump-from', type=int, default=0, help='with --dump-ram: only frames >= this')
ap.add_argument('--fuzz-state', type=int, default=0, help='every N frames (after frame 1500) overwrite scene variables (PaletteSetIndex, StageIndex, GameState, SceneState, transition request) on both sides to reach code the random route never gets to')
ap.add_argument('--fuzz-objects', type=int, default=0, help='every N frames in street gameplay replace the object table with 1-3 random objects (random types and states) to reach enemy code the route never spawns')
ap.add_argument('--credit', action='store_true', help='when every frame matched: record the routines that ran (and the MMC1 reset stubs, run from power-on) in config/<ver>/lockstep.json, which tools/report.py --c counts as verified')
ap.add_argument('--sweep-range', nargs=2, help='with --sweep: only targets LO..HI (hex)')
ap.add_argument('--sweep', action='store_true', help='with --fuzz-state: walk through every scene-change target ($50-$A8) in order, from any state')
ap.add_argument('--out-first', help='write {prg offset: [frame, GameState, PaletteSetIndex, StageIndex, bank]} for every ROM instruction the first time it ran')
a = ap.parse_args()
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.argv = [sys.argv[0], '--version', a.version]; sys.path.insert(0, HERE)
import g13dis, sim6502
sys.argv = [sys.argv[0], '--version', a.version, '--frames', str(a.frames)]

CDIR = os.path.join(ROOT, 'c'); ADIR = os.path.join(CDIR, 'auto', a.version)
DLL = a.dll or os.path.join(ROOT, 'build', f'golgo13_frame_{a.version}' + ('.dll' if os.name == 'nt' else '.so'))
import shutil
cc = next((p for p in (a.clang, os.environ.get('CLANG'), shutil.which('clang'), shutil.which('gcc'), shutil.which('cc')) if p), None)
if not cc: sys.exit('no C compiler (pass --clang PATH)')
os.makedirs(os.path.dirname(DLL), exist_ok=True)
srcs = [os.path.join(CDIR, 'core.c'), os.path.join(CDIR, 'auto', 'runtime.c'), os.path.join(ADIR, 'dispatch.c')] + [os.path.join(ADIR, f'bank_{b}.c') for b in range(8)] + [os.path.join(ADIR, 'ram_code.c')]
subprocess.check_call([cc, '-shared', '-O1', '-fPIC', '-w', '-I', os.path.join(CDIR, 'auto'), '-o', DLL] + srcs)
lib = ctypes.CDLL(DLL)
class CpuS(ctypes.Structure): _fields_ = [(n, ctypes.c_uint8) for n in ('a', 'x', 'y', 'sp', 'c', 'z', 'n', 'v', 'd', 'i')]
R = CpuS.in_dll(lib, 'R'); ram_c = (ctypes.c_uint8 * 0x800).in_dll(lib, 'g_ram')
log_addr = (ctypes.c_uint16 * 8192).in_dll(lib, 'g_iolog_addr'); log_val = (ctypes.c_uint8 * 8192).in_dll(lib, 'g_iolog_val')
log_n = ctypes.c_int.in_dll(lib, 'g_iolog_n'); bank_c = ctypes.c_uint8.in_dll(lib, 'g_bank')
prg = bytes(g13dis.PRG); prg_buf = ctypes.create_string_buffer(prg, len(prg)); ctypes.c_void_p.in_dll(lib, 'g_prg').value = ctypes.addressof(prg_buf)
run_fn = lib.g13_run; run_fn.argtypes = [ctypes.c_void_p, ctypes.c_int]; run_fn.restype = ctypes.c_int
fn = lambda name: ctypes.cast(getattr(lib, name), ctypes.c_void_p)
vec = lambda i: prg[0x1FFFA + 2 * i] | prg[0x1FFFB + 2 * i] << 8
NMI, RESET = vec(0), vec(1)
IDLE = 0xC078                                       # the main loop after the reset code (see config/*/names.json MainIdleLoop)


# ---- MMC1 reset stubs ('sei / lda #$80 / sta $BFFD / jmp Reset' at $8000 of each switchable bank): run each from power-on on both sides
import json
stub_ok = []
if a.credit:
    FJ = json.load(open(os.path.join(ADIR, 'funcs.json')))
    for b in range(7):
        nm_ = f'Loc_B{b}_8000'
        if nm_ not in FJ: continue
        c2 = sim6502.CPU(prg); c2.bank = b; c2.pc = 0x8000; c2.sp = 0xFD; st_ = 0
        while c2.pc != IDLE and st_ < 3_000_000: c2.step(); st_ += 1
        c2.ram[0x2F] = 1
        for k in range(0x800): ram_c[k] = 0
        R.a = R.x = R.y = R.c = R.z = R.n = R.v = R.d = R.i = 0; R.sp = 0xFD; bank_c.value = b; lib.iolog_reset()
        rc2 = run_fn(fn(nm_), 400000)
        same = rc2 == 1 and c2.pc == IDLE and all(c2.ram[k] == ram_c[k] for k in range(0x800) if not 0x100 <= k < 0x200) and [(log_addr[k], log_val[k]) for k in range(min(log_n.value, 8192))] == c2.io_writes and c2.bank == bank_c.value
        print(f'reset stub of bank {b}: {"identical to the original" if same else "DIFFERENT"}')
        if same: stub_ok.append(nm_)
        else: sys.exit(1)
# ---- power-on: RAM random-ish like hardware is not needed; both start from zero RAM
cpu = sim6502.CPU(prg); cpu.bank = 0; cpu.ram_log = set(); cpu.exec_log = set()
lib.iolog_reset(); bank_c.value = 0
for k in range(0x800): ram_c[k] = 0
R.a = R.x = R.y = R.c = R.z = R.n = R.v = R.d = R.i = 0; R.sp = 0xFD
# simulator: run Reset until it reaches the idle loop
cpu.pc = RESET; cpu.sp = 0xFD; steps = 0
while cpu.pc != IDLE and steps < 3_000_000: cpu.step(); steps += 1
assert cpu.pc == IDLE, 'simulator never reached the idle loop'
cpu.ram[0x2F] = 1
# C: Reset ends in the idle loop; the loop budget stops it there
rc = run_fn(fn('Reset'), 400000)
assert rc == 1, f'C Reset ended with {rc}'
def compare(tag):
    bad = [k for k in range(0x800) if not 0x100 <= k < 0x200 and cpu.ram[k] != ram_c[k]]
    clog = [(log_addr[k], log_val[k]) for k in range(min(log_n.value, 8192))]
    if bad or clog != cpu.io_writes or cpu.bank != bank_c.value:
        print(f'DIVERGENCE {tag}: ram {[(hex(k), cpu.ram[k], ram_c[k]) for k in bad[:8]]}  io {"DIFF" if clog != cpu.io_writes else "ok"}  bank asm={cpu.bank} c={bank_c.value}')
        if clog != cpu.io_writes:
            for k in range(max(len(clog), len(cpu.io_writes))):
                x = clog[k] if k < len(clog) else None; y = cpu.io_writes[k] if k < len(cpu.io_writes) else None
                if x != y: print(f'   first io difference at write #{k}: asm {y} C {x}'); break
        return False
    return True
import json
RC = os.path.join(ROOT, 'config', a.version, 'ramcode.json')
COV = os.path.join(ROOT, 'config', a.version, 'coverage.json')
def learn_cov():
    old = set(json.load(open(COV))); new = old | cpu.exec_log
    if new != old: json.dump(sorted(new), open(COV, 'w')); return len(new) - len(old)
    return 0
def learn():
    d = json.load(open(RC)) if os.path.exists(RC) else {'insns': []}
    old = set(map(tuple, d['insns'])); oldruns = set(tuple(map(tuple, r)) for r in d.get('runs', []))
    new = old | cpu.ram_log; newruns = oldruns | cpu.ram_runs
    if new != old or newruns != oldruns:
        json.dump({'insns': sorted(new), 'runs': [list(map(list, r)) for r in sorted(newruns)]}, open(RC, 'w'))
        return len(new) - len(old) + len(newruns) - len(oldruns)
    return 0
if not compare('after reset'): sys.exit(1)
seen = set()
import random
SCENE_ADDR = next((int(k, 16) for k, v in json.load(open(os.path.join(ROOT, 'config', a.version, 'ram.json'))).items() if v == 'SceneState'), 0x10); SWEEP = list(range(0x78, 0xA9)) + list(range(0x50, 0x78))
if a.sweep_range: SWEEP = list(range(int(a.sweep_range[0], 16), int(a.sweep_range[1], 16) + 1))
sweep_i = 0; first = {}; known = set(); next_fz = 1500; fz = random.Random(a.seed * 7919 + 1)
rnd = random.Random(a.seed); style = rnd.choice([(0.2, 0.5), (0.4, 0.3), (0.6, 0.2)]);  pad_c = ctypes.c_uint8.in_dll(lib, 'g_pad'); pad = 0
nmi_c = fn('Nmi')
for frame in range(a.frames):
    if frame % 4 == 0:      # change the buttons every few frames; Start taps now and then
        pad = 0
        for bit, p_ in ((0x80, style[1]), (0x40, 0.1), (0x10, 0.15), (0x20, 0.1), (0x01, style[0]), (0x02, 0.2), (0x04, 0.02)):
            if rnd.random() < p_: pad |= bit
        if rnd.random() < 0.12: pad |= 0x08
    if a.fuzz_state and frame >= next_fz and (a.sweep or (cpu.ram[0xFB] == 0 and cpu.ram[0x14] >= 7)):
        next_fz = frame + a.fuzz_state
        if a.sweep: tgt = SWEEP[sweep_i % len(SWEEP)]; sweep_i += 1
        else: tgt = fz.choice([fz.randrange(0x78, 0x90)] * 3 + [fz.randrange(0x50, 0x78), fz.randrange(0x90, 0xA8), fz.randrange(0, 0x50)])
        pk = [(0x28, 1), (0x29, tgt), (0x2A, 0), (0x14, 0x0C), (0x0100, fz.randrange(0, 8))]       # ask for a scene change the way the street code does
        if a.sweep: pk.append((0xFB, 0))
        for ad, vl in pk: cpu.ram[ad] = vl; ram_c[ad] = vl
    if a.fuzz_objects and frame >= 1500 and frame % a.fuzz_objects == 0 and ((cpu.ram[0xFB] == 0 and cpu.ram[0x14] >= 7) or cpu.ram[0xFB] == 4):
        k = fz.randrange(1, 4); bytes_ = {0x0301: k}; maze = cpu.ram[0xFB] == 4
        for i in range(1, k + 1):
            b = 0x300 + 16 * i; ty = fz.randrange(0, 0x2D if maze else 0x30)
            vals = [ty | fz.choice((0x80, 0x80, 0)), fz.randrange(0x60, 0xB0), fz.randrange(0x30, 0xC0), 0, fz.choice((0, 0x40, 0x80, 0xC0)), fz.randrange(0, 8), 0, 0 if maze else fz.randrange(0, 10), 0,
                    cpu.ram[0x18], cpu.ram[0x19] + fz.randrange(0x40, 0x90) & 0xFF, fz.randrange(0x60, 0xB0), 0, 0, 0, 0]
            for j, v_ in enumerate(vals): bytes_[b + j] = v_
        for ad, vl in bytes_.items(): cpu.ram[ad] = vl; ram_c[ad] = vl
    cpu.pad = pad; pad_c.value = pad
    if a.assist:                                         # same data-only help on both sides: life >= 200, ammo >= 32
        for addr_, mn_ in ((0x38, 0xC8), (0x3A, 0x20)):
            if cpu.ram[addr_] < mn_: cpu.ram[addr_] = mn_
            if ram_c[addr_] < mn_: ram_c[addr_] = mn_
    cpu.io_writes.clear(); lib.iolog_reset_log() if hasattr(lib, 'iolog_reset_log') else None
    # interrupt entry in the simulator: push PC and P, jump to the NMI vector, run until the RTI returns to the idle loop
    cpu.push(IDLE >> 8); cpu.push(IDLE & 0xFF); cpu.push(cpu.getp(0x20)); cpu.i = 1; cpu.pc = NMI; steps = 0
    while cpu.pc != IDLE and steps < 2_000_000: cpu.step(); steps += 1
    if cpu.pc != IDLE:
        print(f'frame {frame}: the simulator did not return from NMI' + (' (forced state; run stops here)' if a.fuzz_state else ''))
        if a.fuzz_state:
            if a.out_first: json.dump(first, open(a.out_first, 'w'))
            if a.out_exec: json.dump(sorted(cpu.exec_log), open(a.out_exec, 'w'))
            sys.exit(5)
        sys.exit(1)
    # C: same, keeping the I/O log per frame (g_iolog_n reset, MMC1 shift state kept by core.c)
    log_n.value = 0
    rc = run_fn(nmi_c, 5_000_000)
    if rc == 4 and ctypes.c_uint16.in_dll(lib, 'g_unknown_addr').value >= 0x2000:
        nc = learn_cov(); ua = ctypes.c_uint16.in_dll(lib, 'g_unknown_addr').value
        EN = os.path.join(ROOT, 'config', a.version, 'entries.json')
        ent = set(json.load(open(EN))['entries']) if os.path.exists(EN) else set(); key = f'{7 if ua >= 0xC000 else bank_c.value}:{ua:04X}'
        if key not in ent: ent.add(key); json.dump({'entries': sorted(ent)}, open(EN, 'w')); nc += 1
        print(f'frame {frame}: no lifted code for ${ua:04X} (bank {bank_c.value}); the simulator executed it, learned {nc} new opcodes -> config/{a.version}/coverage.json; run tools/g13dis.py and tools/lift.py, then retry'); sys.exit(3 if nc else 1)
    if rc == 4 and ctypes.c_uint16.in_dll(lib, 'g_unknown_addr').value < 0x2000:
        n_ = learn(); print(f'frame {frame}: RAM code at ${ctypes.c_uint16.in_dll(lib, "g_unknown_addr").value:04X} not lifted yet; learned {n_} new RAM instructions -> config/{a.version}/ramcode.json; run tools/lift.py and retry'); sys.exit(3)
    if rc == 6: print(f'frame {frame}: an RTS left the stack at {ctypes.c_uint16.in_dll(lib, "g_ret_got").value & 255:#x} instead of {ctypes.c_uint16.in_dll(lib, "g_ret_exp").value & 255:#x} in {ctypes.c_char_p.in_dll(lib, "g_rts_fn").value.decode()}'); sys.exit(1)
    if rc: print(f'frame {frame}: C aborted with code {rc}' + (f' (unknown call target ${ctypes.c_uint16.in_dll(lib, "g_unknown_addr").value:04X} in bank {bank_c.value})' if rc == 4 else '') + (f' (JSR at ${ctypes.c_uint16.in_dll(lib, "g_ret_exp").value - 2:04X} returned to ${ctypes.c_uint16.in_dll(lib, "g_ret_got").value + 1:04X}, bank {bank_c.value})' if rc == 5 else '')); sys.exit(1)
    if not compare(f'frame {frame}'): sys.exit(1)
    seen.add((cpu.ram[0x14], cpu.ram[0x0100], cpu.ram[0xFB]))
    if len(cpu.exec_log) != len(known):
        for o in cpu.exec_log - known: first[o] = [frame, cpu.ram[0x14], cpu.ram[0x17], cpu.ram[0x0100], cpu.ram[0xFB], cpu.ram[SCENE_ADDR]]
        known = set(cpu.exec_log)
    if a.dump_ram and frame % a.dump_every == 0 and frame >= a.dump_from:
        with open(a.dump_ram, 'ab') as df: df.write(bytes(cpu.ram))
    cpu.io_writes[:] = cpu.io_writes
if a.credit:
    ran = {k for k, v in FJ.items() if v['ok'] and v['bank'] < 8 and (v['ranges'][0][0] in cpu.exec_log or any(lo_ <= 7 * 0x4000 + (IDLE & 0x3FFF) < hi_ for lo_, hi_ in v['ranges']))}      # the main idle loop is where every frame returns to
    LS = os.path.join(ROOT, 'config', a.version, 'lockstep.json')
    old_ = set(json.load(open(LS))) if os.path.exists(LS) else set()
    new_ = old_ | {f"{FJ[k]['bank']}:{FJ[k]['addr']:04X}" for k in ran | set(stub_ok)}; json.dump(sorted(new_), open(LS, 'w'), indent=1)      # keyed by bank:address so renaming a routine keeps its credit
    print(f'lockstep credit: {len(ran)} routines ran in this run, {len(new_)} in total')
if a.out_first: json.dump(first, open(a.out_first, 'w'))
if a.out_exec: json.dump(sorted(cpu.exec_log), open(a.out_exec, 'w'))
print('states seen (GameState, StageIndex, PRG bank):', sorted(seen)[:40], '...' if len(seen) > 40 else '')
print(f'[{a.version}] {a.frames} frames from power-on: RAM, I/O writes and PRG bank identical after every NMI')
