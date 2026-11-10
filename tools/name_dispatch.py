"""Name state-machine dispatch routines: a routine that loads an index variable, doubles it, fetches a word from a
table into Tmp00/01 and ends in `jmp ($0000)`. The name is Dispatch_<variable>, qualified by bank for switchable banks.
usage: python tools/name_dispatch.py [--version us|jp]    (reads src/<ver>/bank_*.asm, updates config/<ver>/names.json)"""
import json, os, re, sys
v = sys.argv[sys.argv.index('--version') + 1] if '--version' in sys.argv else 'us'
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
nf = os.path.join(root, 'config', v, 'names.json'); names = json.load(open(nf))
added = 0
for b in range(8):
    lines = open(os.path.join(root, 'src', v, f'bank_{b}.asm')).read().split('\n')
    for i, l in enumerate(lines):
        if 'jmp ($0000)' not in l: continue
        j = i
        while j > 0 and not re.match(r'^(Sub|Loc|[A-Z]\w*)_?\w*:$', lines[j]): j -= 1
        m = re.match(r'^(\w+):$', lines[j])
        if not m or not m.group(1).startswith(('Sub_', 'Loc_')): continue
        body = lines[j + 1:i]
        var = next((re.search(r'lda (?:a:)?(\$?\w+)', x).group(1) for x in body if re.search(r'^\s+lda (?:a:)?(\$?\w+)\s', x)), None)
        addr = re.search(r'_(?:B\d_)?([0-9A-F]{4})$', m.group(1)).group(1)
        key = addr if b == 7 else f'{b}:{addr}'
        if key in names or var is None: continue
        names[key] = (f'Bank{b}' if b != 7 else '') + 'Dispatch_' + var.replace('$', '')
        added += 1
json.dump(names, open(nf, 'w'), indent=1); print(f'[{v}] named {added} dispatch routines')
