"""Add routine entries (computed-jump targets the lifted code reached) to config/<ver>/entries.json.
usage: python tools/learn_entry.py --version us 6:86EA [7:C123 ...]   (bank:address; the native port prints these when it stops)"""
import json, os, sys
ver = sys.argv[sys.argv.index('--version') + 1]; new = [x for x in sys.argv[1:] if ':' in x]
f = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'config', ver, 'entries.json')
cur = set(json.load(open(f))['entries']) if os.path.exists(f) else set(); cur |= set(x.upper() for x in new)
json.dump({'entries': sorted(cur)}, open(f, 'w')); print(f'{ver}: {len(cur)} entries')
