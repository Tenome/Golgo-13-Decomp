"""Add routine / RAM names to config/us and config/jp: names for the fixed bank are copied to jp only when the first 12 bytes of the
routine are identical in both ROMs (the jp banks differ, the fixed bank is nearly the same).
usage: python tools/addnames.py names.json   with {"routines": {"C170": "Name", "5:804F": "Name"}, "ram": {"0238": "Name"}}"""
import json, os, sys
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
add = json.load(open(sys.argv[1]))
us = open(os.path.join(root, 'orig', 'golgo13_us.nes'), 'rb').read()[16:]; jp = open(os.path.join(root, 'orig', 'golgo13_jp.nes'), 'rb').read()[16:]
off = lambda k: int(k.split(':')[0]) * 0x4000 + (int(k.split(':')[1], 16) & 0x3FFF) if ':' in k else 7 * 0x4000 + (int(k, 16) & 0x3FFF)
for v in ('us', 'jp'):
    nf = os.path.join(root, 'config', v, 'names.json'); n = json.load(open(nf)); kept = dropped = 0
    for k, nm in add.get('routines', {}).items():
        if v == 'jp' and us[off(k):off(k) + 12] != jp[off(k):off(k) + 12]: dropped += 1; continue
        n[k] = nm; kept += 1
    json.dump(n, open(nf, 'w'), indent=1)
    rf = os.path.join(root, 'config', v, 'ram.json'); r = json.load(open(rf)); r.update(add.get('ram', {})); json.dump(r, open(rf, 'w'), indent=1)
    print(f'[{v}] {kept} routine names, {dropped} not identical in this version; {len(add.get("ram", {}))} RAM names')
