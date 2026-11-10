#!/usr/bin/env python3
"""Build the native port (lifted C + PPU host) with clang/gcc: python tools/build_port.py [--version us|jp] [--clang PATH]
Output: build/port/golgo13_port_<ver>(.exe). Run: golgo13_port_<ver> orig/golgo13_<ver>.nes --frames 600 --out dir --shot-every 60"""
import argparse, os, shutil, subprocess, sys
ap = argparse.ArgumentParser(); ap.add_argument('--version', default='us'); ap.add_argument('--clang'); ap.add_argument('--opt', default='-O2'); ap.add_argument('--sdl', help='SDL2 development folder (include/, lib/x64/): also builds the windowed golgo13_play')
a = ap.parse_args(); v = a.version
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
cc = next((p for p in (a.clang, os.environ.get('CLANG'), shutil.which('clang'), shutil.which('gcc')) if p), None) or sys.exit('no C compiler (pass --clang PATH)')
gen = os.path.join(ROOT, 'build', f'port_{v}')
subprocess.check_call([sys.executable, os.path.join(HERE, 'lift.py'), '--version', v, '--cycles', '--out', gen], stdout=subprocess.DEVNULL)
out = os.path.join(ROOT, 'build', 'port'); os.makedirs(out, exist_ok=True)
exe = os.path.join(out, f'golgo13_port_{v}' + ('.exe' if os.name == 'nt' else ''))
srcs = [os.path.join(ROOT, 'c', 'port', 'port.c'), os.path.join(ROOT, 'c', 'port', 'main.c'), os.path.join(ROOT, 'c', 'port', 'apu.c'), os.path.join(ROOT, 'c', 'auto', 'runtime.c'),
        os.path.join(gen, 'dispatch.c'), os.path.join(gen, 'ram_code.c')] + [os.path.join(gen, f'bank_{b}.c') for b in range(8)]
subprocess.check_call([cc, a.opt, '-w', '-DPORT_CYCLES', '-I', os.path.join(ROOT, 'c', 'auto'), '-o', exe] + srcs)
print(exe)
if a.sdl:
    play = os.path.join(out, f'golgo13_play_{v}' + ('.exe' if os.name == 'nt' else ''))
    lib = os.path.join(a.sdl, 'lib', 'x64', 'SDL2.lib') if os.name == 'nt' else '-lSDL2'
    psrcs = [os.path.join(ROOT, 'c', 'port', 'port.c'), os.path.join(ROOT, 'c', 'port', 'sdl_main.c'), os.path.join(ROOT, 'c', 'port', 'apu.c'), os.path.join(ROOT, 'c', 'auto', 'runtime.c'), os.path.join(gen, 'dispatch.c'), os.path.join(gen, 'ram_code.c')] + [os.path.join(gen, f'bank_{b}.c') for b in range(8)]
    subprocess.check_call([cc, a.opt, '-w', '-DPORT_CYCLES', '-I', os.path.join(ROOT, 'c', 'auto'), '-I', os.path.join(a.sdl, 'include'), '-I', os.path.join(a.sdl, 'include', 'SDL2'), '-o', play] + psrcs + [lib])
    if os.name == 'nt': shutil.copy(os.path.join(a.sdl, 'lib', 'x64', 'SDL2.dll'), out)
    print(play)
