#!/usr/bin/env python3
"""Go-explore style coverage search on the seeded headless native build.

Branches from save states: each iteration loads a state from the pool, plays a random biased input route for a few hundred
frames and reads --miss-log, which lists ROM instructions the recompiler had NOT compiled (i.e. code that is not classified yet).
A run that executes new code keeps its end state in the pool, so later runs continue from deeper in the game.
New opcodes are written to build/goexplore/<ver>/new_coverage.json; use --merge to fold them into config/<ver>/coverage.json.
usage: python tools/goexplore.py --version us --minutes 30 [--workers 11] [--merge]
needs: recomp/build_native.ps1 -Headless -Version <ver>  (build/native/<ver>/cmake_headless/Release/nes_game.exe)"""
import argparse, json, os, random, subprocess, sys, threading, time, shutil
from concurrent.futures import ThreadPoolExecutor
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
ap = argparse.ArgumentParser(); ap.add_argument('--version', default='us'); ap.add_argument('--minutes', type=float, default=30)
ap.add_argument('--workers', type=int, default=8); ap.add_argument('--seed', type=int, default=1); ap.add_argument('--merge', action='store_true')
ap.add_argument('--seeds', help='folder of extra start states named <anything>_<frame>.state (frame = the frame each was saved after)')
ap.add_argument('--start-frame', type=int, default=2599, help='frame of the initial state (title screen is reached around 1900)')
a = ap.parse_args(); v = a.version
EXE = os.path.join(ROOT, 'build', 'native', v, 'cmake_headless', 'Release', 'nes_game.exe'); ROM = os.path.join(ROOT, 'orig', f'golgo13_{v}.nes')
W = os.path.join(ROOT, 'build', 'goexplore', v); os.makedirs(W, exist_ok=True)
covf = os.path.join(ROOT, 'config', v, 'coverage.json')
known = set(json.load(open(covf))); seen_sigs = set(); new_total = set(); lock = threading.Lock(); pool = []; stats = {'runs': 0, 'gains': 0}
NAMES = ['RIGHT', 'LEFT', 'UP', 'DOWN', 'A', 'B', 'START', 'SELECT']
def route(rnd, f0, n):
    pr = [rnd.choice([0.2, 0.5, 0.8]), rnd.choice([0.05, 0.2, 0.4]), rnd.choice([0.1, 0.3, 0.5]), rnd.choice([0.05, 0.25, 0.5]),
          rnd.choice([0.2, 0.5, 0.8]), rnd.choice([0.1, 0.4, 0.7]), rnd.choice([0.0, 0.02, 0.1]), rnd.choice([0.0, 0.01, 0.05])]
    hold = rnd.choice([(3, 6, 10), (10, 20, 45), (20, 45, 90)]); f = f0
    # QA assist (data only, the guest's code is untouched): keep life >= 200 and ammo >= 32 so random play survives longer
    out = [f'{f0} HOLD_MIN 0038 C8', f'{f0} HOLD_MIN 003A 20']
    while f < f0 + n:
        b = [nm for nm, p in zip(NAMES, pr) if rnd.random() < p]
        out.append(f"{f} {'+'.join(b) if b else '-'}"); f += rnd.choice(hold)
    return '\n'.join(out) + '\n'
def parse_miss(path):
    s = set()
    if not os.path.exists(path): return s
    for line in open(path):
        if line.startswith('#') or not line.strip(): continue
        p = line.split()[0].split(':')
        if p[0] == '4k': s.add(int(p[1], 16) * 0x1000 + (int(p[2], 16) & 0xFFF))
    return s
def signature(path):
    ram = bytearray(0x800)
    try:
        for line in open(path):
            if line.startswith('ram '):
                a0 = int(line[4:8], 16); b = bytes(int(x, 16) for x in line[10:].split())
                if a0 + len(b) <= 0x800: ram[a0:a0 + len(b)] = b
    except OSError: return None
    return (ram[0xFB], ram[0x14], ram[0x0500], ram[0x17])
def one(job):
    rnd = random.Random(a.seed * 1000003 + job)
    with lock:
        if not pool: return
        # favour recent (deeper) states
        st = rnd.choice(pool[-8:]) if rnd.random() < 0.6 else rnd.choice(pool)
    n = rnd.choice([300, 600, 1200]); end = st['frame'] + n
    rt = os.path.join(W, f'r{job}.route'); ms = os.path.join(W, f'm{job}.txt'); ns = os.path.join(W, f's{job}.state'); mo = os.path.join(W, f'mem{job}.txt')
    open(rt, 'w').write(route(rnd, st['frame'] + 1, n))
    for p in (ms, ns):
        if os.path.exists(p): os.remove(p)
    try:
        subprocess.run([EXE, ROM, '--load-state', st['path'], '--frames', str(end + 1), '--input', rt, '--miss-log', ms,
                        '--save-state', f'{end}:{ns}', '--mem-frame', str(end), '--mem-out', mo], capture_output=True, timeout=600)
    except subprocess.TimeoutExpired: return
    gain = parse_miss(ms); sig = signature(mo)
    with lock:
        stats['runs'] += 1
        fresh = gain - known
        newsig = sig is not None and sig not in seen_sigs
        if newsig: seen_sigs.add(sig)
        if (fresh or newsig) and os.path.exists(ns):
            known.update(fresh); new_total.update(fresh); stats['gains'] += 1
            keep = os.path.join(W, f'pool_{len(pool):04d}.state'); shutil.move(ns, keep)
            pool.append({'path': keep, 'frame': end}); 
            json.dump(sorted(new_total), open(os.path.join(W, 'new_coverage.json'), 'w'))
            print(f'[{time.strftime("%H:%M:%S")}] sig={sig} +{len(fresh)} opcodes (total new {len(new_total)}) pool={len(pool)} frame={end} runs={stats["runs"]}', flush=True)
def main():
    init = os.path.join(W, 'init.state')
    if not os.path.exists(init):
        rt = os.path.join(W, 'init.route')
        open(rt, 'w').write('\n'.join(f"{f} {'START' if (f // 40) % 2 == 0 else '-'}" for f in range(1500, a.start_frame + 1, 20)) + '\n')
        r = subprocess.run([EXE, ROM, '--frames', str(a.start_frame + 1), '--input', rt, '--save-state', f'{a.start_frame}:{init}'], capture_output=True, text=True)
        if not os.path.exists(init): sys.exit('could not create the initial state:\n' + r.stdout[-400:] + r.stderr[-400:])
    pool.append({'path': init, 'frame': a.start_frame})
    if a.seeds:
        for fn in sorted(os.listdir(a.seeds)):
            if fn.endswith('.state'): pool.append({'path': os.path.join(a.seeds, fn), 'frame': int(fn[:-6].rsplit('_', 1)[1])})
    print(len(pool), 'start states', flush=True)
    end = time.time() + a.minutes * 60; job = 0
    with ThreadPoolExecutor(a.workers) as ex:
        futs = []
        while time.time() < end:
            futs = [f for f in futs if not f.done()]
            while len(futs) < a.workers * 2: futs.append(ex.submit(one, job)); job += 1
            time.sleep(0.5)
        for f in futs: f.cancel()
    print(f'done: {stats["runs"]} runs, {stats["gains"]} gains, {len(new_total)} new opcodes')
    if a.merge and new_total:
        cur = set(json.load(open(covf))); cur |= new_total; json.dump(sorted(cur), open(covf, 'w')); print('merged into', covf, len(cur))
main()
