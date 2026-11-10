#!/usr/bin/env python3
"""Whole-program differential test: run the mechanically lifted C (c/auto/<ver>) and the original 6502 code (tools/sim6502.py)
frame by frame from power-on and compare CPU RAM, the PPU/APU/mapper write log and the PRG bank after every NMI.

Reset runs first (RAM clear, hardware setup, PPU warm-up loops); after that all game logic runs inside the NMI handler, so a frame
is one call of the handler. Reads of $2002 and the joypad ports use the deterministic pattern shared by c/core.c and the simulator,
so both sides see the same inputs. usage: python tools/frametest.py [--version us|jp] [--frames N] [--clang PATH]"""
import argparse, ctypes, os, subprocess, sys
ap = argparse.ArgumentParser(); ap.add_argument('--version', default='us'); ap.add_argument('--frames', type=int, default=300)
ap.add_argument('--clang'); ap.add_argument('--keep', action='store_true')
a = ap.parse_args()
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.argv = [sys.argv[0], '--version', a.version]; sys.path.insert(0, HERE)
import g13dis, sim6502
sys.argv = [sys.argv[0], '--version', a.version, '--frames', str(a.frames)]

CDIR = os.path.join(ROOT, 'c'); ADIR = os.path.join(CDIR, 'auto', a.version)
DLL = os.path.join(ROOT, 'build', f'golgo13_frame_{a.version}' + ('.dll' if os.name == 'nt' else '.so'))
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
    old = set(map(tuple, json.load(open(RC))['insns'])) if os.path.exists(RC) else set()
    new = old | cpu.ram_log
    if new != old: json.dump({'insns': sorted(new)}, open(RC, 'w')); return len(new) - len(old)
    return 0
if not compare('after reset'): sys.exit(1)
import random
rnd = random.Random(7); pad_c = ctypes.c_uint8.in_dll(lib, 'g_pad'); pad = 0
nmi_c = fn('Nmi')
for frame in range(a.frames):
    if frame % 4 == 0:      # change the buttons every few frames; Start taps now and then
        pad = (rnd.choice([0, 0, 0x80, 0x10, 0x01, 0x02, 0x04, 0x08, 0x40, 0x90]) | (0x08 if rnd.random() < 0.15 else 0)) & 0xFF
    cpu.pad = pad; pad_c.value = pad
    cpu.io_writes.clear(); lib.iolog_reset_log() if hasattr(lib, 'iolog_reset_log') else None
    # interrupt entry in the simulator: push PC and P, jump to the NMI vector, run until the RTI returns to the idle loop
    cpu.push(IDLE >> 8); cpu.push(IDLE & 0xFF); cpu.push(cpu.getp(0x20)); cpu.i = 1; cpu.pc = NMI; steps = 0
    while cpu.pc != IDLE and steps < 2_000_000: cpu.step(); steps += 1
    if cpu.pc != IDLE: print(f'frame {frame}: the simulator did not return from NMI'); sys.exit(1)
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
    cpu.io_writes[:] = cpu.io_writes
print(f'[{a.version}] {a.frames} frames from power-on: RAM, I/O writes and PRG bank identical after every NMI')
