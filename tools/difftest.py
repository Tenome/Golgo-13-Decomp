#!/usr/bin/env python3
"""Differential test: every lifted C routine (c/golgo13.c) against the original 6502 code (orig ROM, tools/sim6502.py).
Random CPU RAM, registers and PRG bank are fed to both; RAM (except the stack page), the declared result registers, the
log of writes to $2000-$FFFF (PPU/APU/mapper) and the PRG bank chosen through the MMC1 model must match.
usage: python tools/difftest.py [--version us|jp] [--runs N] [--clang PATH] [--only NAME]"""
import argparse, ctypes, os, random, shutil, subprocess, sys
ap = argparse.ArgumentParser(); ap.add_argument('--version', default='us'); ap.add_argument('--runs', type=int, default=2000)
ap.add_argument('--clang'); ap.add_argument('--only')
a = ap.parse_args()
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.argv = [sys.argv[0], '--version', a.version]; sys.path.insert(0, HERE)
import g13dis, sim6502

def find_cc():
    for c in (a.clang, os.environ.get('CLANG'), 'clang', 'gcc', 'cc'):
        if c:
            p = shutil.which(c) or (c if os.path.exists(c) else None)
            if p: return p
    sys.exit('no C compiler found (pass --clang PATH or set CLANG)')
dll = os.path.join(ROOT, 'build', 'golgo13_c' + ('.dll' if os.name == 'nt' else '.so'))
os.makedirs(os.path.dirname(dll), exist_ok=True)
subprocess.check_call([find_cc(), '-shared', '-O1', '-fPIC', '-Wall', '-Wno-unused-function', '-o', dll, os.path.join(ROOT, 'c', 'golgo13.c'), os.path.join(ROOT, 'c', 'core.c')])
lib = ctypes.CDLL(dll)
class Regs(ctypes.Structure): _fields_ = [('a', ctypes.c_uint8), ('x', ctypes.c_uint8), ('y', ctypes.c_uint8), ('c', ctypes.c_uint8)]
ram_c = (ctypes.c_uint8 * 0x800).in_dll(lib, 'g_ram')
log_addr = (ctypes.c_uint16 * 8192).in_dll(lib, 'g_iolog_addr'); log_val = (ctypes.c_uint8 * 8192).in_dll(lib, 'g_iolog_val')
log_n = ctypes.c_int.in_dll(lib, 'g_iolog_n'); bank_c = ctypes.c_uint8.in_dll(lib, 'g_bank')
prg = bytes(g13dis.PRG); prg_buf = ctypes.create_string_buffer(prg, len(prg))
ctypes.c_void_p.in_dll(lib, 'g_prg').value = ctypes.addressof(prg_buf)
iolog_reset = lib.iolog_reset

def pk(addr, fn): return {addr + i: fn(i) for i in range(4)}
# name, asm address, takes_regs, result regs to compare ('V' = void), input generator (may bias RAM through ram={...})
TESTS = [
    ('AslA6',         0xC1EF, True, 'ac',  lambda r: {}),
    ('AslA5',         0xC1F0, True, 'ac',  lambda r: {}),
    ('AslA4',         0xC1F1, True, 'ac',  lambda r: {}),
    ('AslA3',         0xC1F2, True, 'ac',  lambda r: {}),
    ('LsrA6',         0xC1F6, True, 'ac',  lambda r: {}),
    ('LsrA5',         0xC1F7, True, 'ac',  lambda r: {}),
    ('LsrA4',         0xC1F8, True, 'ac',  lambda r: {}),
    ('LsrA3',         0xC1F9, True, 'ac',  lambda r: {}),
    ('SetPpuCtrl',    0xC1FD, True, 'axy', lambda r: {}),
    ('SetPpuMask',    0xC203, True, 'axy', lambda r: {}),
    ('DoOamDma',      0xC1E4, True, 'axy', lambda r: {}),
    ('ApplyScroll',   0xC196, False, '',   lambda r: {}),
    ('BinToDecimal',  0xC1A9, True, 'axyc', lambda r: dict(ram={0x03: r.randint(0, 255), 0x04: r.choice([0, 0, 0, 1, 2, 0x10, 0xFF])})),
    ('QueueSound',   0xC22C, True, 'axy', lambda r: {}),
    ('TickClock',     0xC23C, False, '',   lambda r: dict(ram={0x11: r.choice([0, 1, 0x3A, 0x3B, 0x3C, 0xFF, r.randint(0, 255)])})),
    ('GetRandomByte', 0xC2A3, True, 'axc', lambda r: dict(ram={0x0108: r.choice([0, 0x1E, 0x1F, 0x20, 0xFF, r.randint(0, 255)])})),
    ('MmcWriteControl', 0xC554, True, 'ac', lambda r: {}),
    ('MmcWriteChr0',  0xC56A, True, 'ac',  lambda r: {}),
    ('MmcWriteChr1',  0xC580, True, 'ac',  lambda r: {}),
    ('MmcWriteChr1A', 0xC582, True, 'ac',  lambda r: {}),
    ('MmcWritePrg',   0xC596, True, 'ac',  lambda r: dict(ram={0xFB: r.randint(0, 255)})),
    ('SetPaletteAddr', 0xC270, True, 'axy', lambda r: {}),
    ('ResetPpuAddr',   0xC285, True, 'ay', lambda r: {}),
    ('UploadPalette',  0xC25E, True, 'axyc', lambda r: dict(x=r.choice([0, 0, 5, 0x1F, 0x20, 0xFF]))),
    ('FillPaletteBlack', 0xC24E, True, 'axyc', lambda r: dict(x=r.choice([0, 0, 5, 0x1F, 0x20, 0xFF]))),
    ('ResetPpuScroll', 0xC209, True, 'axy', lambda r: {}),
    ('SetPpuAddrFromBuf', 0xC21C, True, 'axy', lambda r: {}),
    ('AnimatePalette', 0xDDE1, True, 'axyc', lambda r: dict(ram={0x10: r.randint(0, 255)})),
    ('HideEnemySprites', 0xDC77, True, 'axyc', lambda r: {}),
    ('CopyPlayerSprites', 0xD3D3, True, 'axyc', lambda r: dict(ram={0x37: r.choice([0, 0, 1, 2, 3, 4, r.randint(0, 255)])})),
    ('InitHudSprites', 0xC983, True, 'axy', lambda r: dict(x=r.choice([0, 0, 0x10, 0x20, 0x30, r.randint(0, 255)]), y=r.choice([0, 0x10, r.randint(0, 255)]))),
    ('DrawHudNumber',  0xC994, True, 'axyc', lambda r: dict(x=r.choice([0, 0x10]), ram={0x03: r.randint(0, 255), 0x04: r.choice([0, 0, 0, 0, 1, 2, 3, 0x10, 0xFF])})),
    ('UpdatePlayerFacing', 0xEAB6, True, 'ac', lambda r: dict(ram={0x10B: r.choice([0, 0x40, 0x80, 0xC0, 0x41, 0xFF]), 0x36: r.randint(0, 255)})),
    ('SetPlayerPose', 0xEAAA, True, 'a', lambda r: {}),
    ('AdjustAmmo',     0xEEB7, True, 'ac', lambda r: dict(ram={0x3A: r.choice([0, 1, 0x80, 0xFF, r.randint(0, 255)]), 0x3B: r.choice([0, 0, 1, 2, 0x80, 0xFF])})),
    ('UseAmmo',        0xEACF, True, 'ac', lambda r: dict(x=r.randint(0, 12), ram={0x3A: r.choice([0, 1, 0x80, 0xFF, r.randint(0, 255)]), 0x3B: r.choice([0, 0, 1, 2, 0x80, 0xFF])})),
    ('ClearObjectStatusBits', 0xFBE0, True, 'axyc', lambda r: dict(ram={0x0301: r.choice([0, 1, 2, 5, 16, 17, 40, r.randint(0, 255)])})),
    ('UpdateLifeBlink', 0xFBFE, True, 'a', lambda r: dict(ram={0x114: r.choice([0, 0, 1, 7]), 0x116: r.randint(0, 255), 0x10: r.randint(0, 255), 0x38: r.randint(0, 255)})),
]

def run(name, addr, takes_regs, cmp_regs, gen, runs, seed):
    rnd = random.Random(seed); fn = getattr(lib, name)
    returns = takes_regs and 'V' not in cmp_regs
    fn.restype = Regs if returns else None
    if takes_regs: fn.argtypes = [Regs]
    for i in range(runs):
        ram = bytearray(rnd.randrange(256) for _ in range(0x800))
        regs = dict(a=rnd.randrange(256), x=rnd.randrange(256), y=rnd.randrange(256), c=rnd.randrange(2)); regs.update(gen(rnd))
        for k, v in regs.pop('ram', {}).items(): ram[k] = v
        ram = bytes(ram); bank = rnd.randrange(7)
        cpu = sim6502.CPU(prg); cpu.ram[:] = ram; cpu.bank = bank
        ra = cpu.call(addr, regs['a'], regs['x'], regs['y'], regs['c'])
        for k in range(0x800): ram_c[k] = ram[k]
        bank_c.value = bank; iolog_reset()
        rc = fn(Regs(regs['a'], regs['x'], regs['y'], regs['c'])) if takes_regs else fn()
        rc = (rc.a, rc.x, rc.y, rc.c) if returns else None
        bad = [k for k in range(0x800) if not 0x100 <= k < 0x200 and cpu.ram[k] != ram_c[k]]
        badreg = [r for r, idx in (('a', 0), ('x', 1), ('y', 2), ('c', 3)) if r in cmp_regs and rc is not None and ra[idx] != rc[idx]]
        clog = [(log_addr[k], log_val[k]) for k in range(min(log_n.value, 8192))]
        badio = clog != cpu.io_writes; badbank = cpu.bank != bank_c.value
        if bad or badreg or badio or badbank:
            print(f'  FAIL {name} run {i}: input {regs}  ram diffs at {[hex(k) for k in bad[:6]]}  reg diffs {badreg}  io {"DIFF" if badio else "ok"} bank {"DIFF" if badbank else "ok"}  asm={ra} c={rc}')
            if badio: print('   asm io', cpu.io_writes[:8], '\n   c   io', clog[:8])
            return False
    return True

ok = True
for n, addr, tr, cr, gen in TESTS:
    if a.only and n != a.only: continue
    r = run(n, addr, tr, cr, gen, a.runs, hash(n) & 0xFFFF)
    print(f'{"ok  " if r else "FAIL"} {n:24s} ${addr:04X}  ({a.runs} random states)')
    ok &= r
print('ALL MATCH' if ok else 'MISMATCHES FOUND'); sys.exit(0 if ok else 1)
