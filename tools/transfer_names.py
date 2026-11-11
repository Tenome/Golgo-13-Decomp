"""Copy US routine names to the JP names file for routines that exist in the JP ROM at another address (same bank, unique 16-byte match).
usage: python tools/transfer_names.py"""
import json, os
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
us = open(os.path.join(root, 'orig', 'golgo13_us.nes'), 'rb').read()[16:]; jp = open(os.path.join(root, 'orig', 'golgo13_jp.nes'), 'rb').read()[16:]
nu = json.load(open(os.path.join(root, 'config', 'us', 'names.json'))); nf = os.path.join(root, 'config', 'jp', 'names.json'); nj = json.load(open(nf))
have = set(nj.values()); added = 0
for k, nm in nu.items():
    if ':' not in k or k in nj or nm in have: continue
    b = int(k.split(':')[0]); a = int(k.split(':')[1], 16) & 0x3FFF
    sig = us[b * 0x4000 + a:b * 0x4000 + a + 16]; bank = jp[b * 0x4000:(b + 1) * 0x4000]
    pos = [i for i in range(len(bank) - 16) if bank[i:i + 16] == sig]
    if len(pos) == 1: nj[f'{b}:{0x8000 + pos[0]:04X}'] = nm; have.add(nm); added += 1
# second pass: compare instruction shapes (opcodes and immediates, not absolute operands) against the routines of the JP lift
import sys; sys.argv = [sys.argv[0], '--version', 'jp']; sys.path.insert(0, os.path.dirname(__file__))
import g13dis
jf = json.load(open(os.path.join(root, 'c', 'auto', 'jp', 'funcs.json')))
def shape(rom, off, n=14):
    out = []
    for _ in range(n):
        op = rom[off]
        if op not in g13dis.TAB: return None
        nm, mode = g13dis.TAB[op]; ln = g13dis.LENM[mode]
        out.append((op, rom[off + 1] if mode == 'imm' else None)); off += ln
        if nm in ('rts', 'rti', 'jmp'): break
    return tuple(out)
byshape = {}
for k, v in jf.items():
    if v['bank'] < 7 and v['ok']:
        sh = shape(jp, v['bank'] * 0x4000 + (v['addr'] & 0x3FFF))
        if sh and len(sh) >= 4: byshape.setdefault((v['bank'], sh), []).append(v['addr'])
shape_added = 0
for k, nm in nu.items():
    if ':' not in k or nm in have: continue
    b = int(k.split(':')[0]); a = int(k.split(':')[1], 16) & 0x3FFF
    sh = shape(us, b * 0x4000 + a)
    c = byshape.get((b, sh)) if sh and len(sh) >= 4 else None
    if c and len(c) == 1 and f'{b}:{c[0]:04X}' not in nj: nj[f'{b}:{c[0]:04X}'] = nm; have.add(nm); shape_added += 1
json.dump(nj, open(nf, 'w'), indent=1); print(added, 'names transferred to jp by bytes,', shape_added, 'by instruction shape')
