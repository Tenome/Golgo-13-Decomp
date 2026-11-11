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
json.dump(nj, open(nf, 'w'), indent=1); print(added, 'names transferred to jp')
