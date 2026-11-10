"""Which still-unnamed routines have run, and in which game state first? usage: python tools/unnamed_exec.py VERSION exec.json... [--first first.json ...]"""
import json, sys, glob
v = sys.argv[1]; f = json.load(open(f'c/auto/{v}/funcs.json')); ex = set(); first = {}
args = sys.argv[2:]
for p in args:
    if p.endswith('.json') and 'first' not in p:
        for pp in glob.glob(p): ex |= set(json.load(open(pp)))
    else:
        for pp in glob.glob(p):
            for k, val in json.load(open(pp)).items():
                if k not in first or val[0] < first[k][0]: first[k] = val
un = [(k, x) for k, x in f.items() if k.startswith('Sub_')]
hit = [k for k, x in un if x['ranges'][0][0] in ex]
print(len(un), 'unnamed;', len(hit), 'executed;', len(un) - len(hit), 'never executed')
for k, x in un:
    o = x['ranges'][0][0]
    if o in ex and str(o) in first: print(k, 'first frame/GameState/PaletteSet/Stage/bank:', first[str(o)])
