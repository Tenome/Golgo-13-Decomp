"""List the routines of one bank in compact form for naming: python tools/listsubs.py --version us BANK [--unnamed]"""
import re, sys, json, os
args = sys.argv[1:]; ver = args[args.index('--version') + 1]; bank = args[args.index('--version') + 2]
L = open(f'src/{ver}/bank_{bank}.asm').read().split('\n')
names = json.load(open(f'config/{ver}/names.json')); unnamed = '--unnamed' in args
i = 0
while i < len(L):
    m = re.match(r'^(Sub_B\d_([0-9A-F]{4})|Bank\w+|[A-Z]\w+):$', L[i])
    if m and not L[i].startswith(('Data_', 'Loc_')):
        j = i + 1; body = []
        while j < len(L) and not re.match(r'^(Sub_|[A-Z][A-Za-z0-9]*:)', L[j]):
            t = re.sub(r'\s+;.*', '', L[j]).strip()
            if t and not t.startswith('.incbin'): body.append(t)
            j += 1
        if not unnamed or m.group(1).startswith('Sub_'): print(m.group(1), '::', ' | '.join(body)[:260])
        i = j
    else: i += 1
