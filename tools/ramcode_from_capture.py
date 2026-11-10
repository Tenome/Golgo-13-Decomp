"""Merge NESRecomp --capture-log files (lines `insn ADDR BYTES COUNT`: RAM instructions that ran) into config/<ver>/ramcode.json.
usage: python tools/ramcode_from_capture.py --version us cap1.txt [cap2.txt ...]"""
import json, os, sys
ver = sys.argv[sys.argv.index('--version') + 1]; files = [x for x in sys.argv[1:] if x not in ('--version', ver)]
rc = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'config', ver, 'ramcode.json')
old = set(map(tuple, json.load(open(rc))['insns'])) if os.path.exists(rc) else set(); new = set(old)
for f in files:
    for line in open(f):
        p = line.split()
        if p and p[0] == 'insn' and len(p) >= 3: new.add((int(p[1], 16), p[2].lower()))
json.dump({'insns': sorted(new)}, open(rc, 'w')); print(f'{ver}: {len(old)} -> {len(new)} RAM instructions')
