"""Print routines from the generated source compactly: python tools/showasm.py [--version us] BANK LABEL [LABEL...]  (LABEL without ':')
Stops at the next label that starts a different routine (Sub_*/named) or after the run of code that ends the routine."""
import re, sys
args = sys.argv[1:]; ver = 'us'
if args[0] == '--version': ver = args[1]; args = args[2:]
bank = args[0]; L = open(f'src/{ver}/bank_{bank}.asm').read().split('\n')
for name in args[1:]:
    i = next(k for k, l in enumerate(L) if l.startswith(name + ':'))
    out = [name + ':']
    for l in L[i + 1:i + 200]:
        t = re.sub(r'\s+;\s*(\$[0-9A-F]{4}).*', r'  ;\1', l.rstrip())
        if re.match(r'^(Sub_|[A-Z][A-Za-z0-9]*:)', l) and not l.startswith('Loc_'): break
        out.append(t)
    print('\n'.join(out)); print()
