"""Name the routines that a table of code addresses points to: <Base>_<index>. Base comes from the dictionary below (known
tables) or is Bank<N>Tbl<addr>. Existing names are kept. usage: python tools/name_tables.py --version us"""
import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import g13dis as g
KNOWN = {'5:8061': 'Bank5Scene', '5:8AF3': 'Bank5SubScene', '5:A1AE': 'SoundCmdA', '5:A23E': 'SoundCmdB',
         '4:80C5': 'Bank4State', '4:85B7': 'Bank4StateB', '4:8E36': 'Bank4StateC',
         '1:8041': 'Bank1Title', '1:8DCF': 'Bank1State', '1:AB9D': 'Bank1ObjAnim'}
code, labels, conf = g.classify_full(g.load_roots())
nf = os.path.join(g.CONF, 'names.json'); names = json.load(open(nf)); added = 0
for p, t in sorted(g.TABLES.items()):
    key = f'{g.bank_of(p)}:{g.addr_of(p):04X}'
    base = KNOWN.get(key, f'Bank{g.bank_of(p)}Tbl{g.addr_of(p):04X}')
    for i, tp in enumerate(t['tg']):
        k = f'{g.addr_of(tp):04X}' if g.bank_of(tp) == 7 else f'{g.bank_of(tp)}:{g.addr_of(tp):04X}'
        if k not in names and g.code[tp] == 'S' if hasattr(g, 'code') else k not in names:
            names[k] = f'{base}_{i:02X}'; added += 1
json.dump(names, open(nf, 'w'), indent=1); print(f'[{g.VER}] named {added} table targets')
