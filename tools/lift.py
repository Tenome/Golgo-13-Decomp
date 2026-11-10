#!/usr/bin/env python3
"""Mechanical 6502 -> C lifter.

Every routine entry found by tools/g13dis.py (JSR targets, vectors, named routines, pointer-table targets) becomes a C function
`void <Label>(void)` that works on the global CPU state `R` (registers and flags) and on g_ram / io_write / rd / wr from
c/auto/runtime.h. Each instruction becomes one or two C statements, branches become gotos, JSR becomes a call, JMP to another
routine becomes a tail call. The result is faithful, not pretty: it is the verified starting point for the readable C in
c/golgo13.c (tools/autotest.py compares every function with the 6502 original on random states).

usage: python tools/lift.py [--version us|jp]     writes c/auto/<ver>/bank_N.c, dispatch.c, funcs.json"""
import json, os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..'))
sys.path.insert(0, HERE)
import g13dis as g
VER = g.VER
OUT = os.path.join(ROOT, 'c', 'auto', VER); os.makedirs(OUT, exist_ok=True)

roots = g.load_roots()
code, labels, conf = g.classify_full(roots)
names = g.load_names()
CONF = set(conf)      # starts where two decodings of the same bytes overlap (e.g. a BIT used to skip an instruction): both are real code
vec = [g.PRG[0x1FFFA + i * 2] | g.PRG[0x1FFFB + i * 2] << 8 for i in range(3)]

# ---- entries -------------------------------------------------------------------------------------------------------
entries = set()
for p in labels:
    if code[p] == 'S' and g.KIND.get(p) == 'sub': entries.add(p)
for key in names:
    try: p = g.parse_loc(key) if ':' in key else g.p_of(7, int(key, 16))
    except ValueError: continue
    if code[p] == 'S': entries.add(p)
for v in vec:
    if v >= 0xC000: entries.add(g.p_of(7, v))
for t in g.TABLES.values():
    for x in t['tg']: entries.add(x)
for p in list(g.HEUR): entries.add(p)

def fname(p): return g.lname(p, names)

# ---- instruction semantics ------------------------------------------------------------------------------------------
def ea_expr(m, ob):
    v = ob[0] if len(ob) == 1 else ob[0] | ob[1] << 8
    return {'zp': f'0x{v:02X}', 'abs': f'0x{v:04X}',
            'zpx': f'(uint8_t)(0x{v:02X} + R.x)', 'zpy': f'(uint8_t)(0x{v:02X} + R.y)',
            'abx': f'(uint16_t)(0x{v:04X} + R.x)', 'aby': f'(uint16_t)(0x{v:04X} + R.y)',
            'izx': f'rd16zp((uint8_t)(0x{v:02X} + R.x))', 'izy': f'(uint16_t)(rd16zp(0x{v:02X}) + R.y)'}[m]
def val_expr(m, ob):
    return f'0x{ob[0]:02X}' if m == 'imm' else f'rd({ea_expr(m, ob)})'

def target_code(cur, t):
    """CPU target address -> (kind, payload): ('local'|'entry'|'dyn', p or addr)"""
    tp = g.resolve(cur, t)
    if tp is None or (code[tp] is None and tp not in CONF): return ('dyn', t)
    return ('entry' if tp in entries else 'local', tp)

def is_dispatch_call(p, d):
    op, n, m, l, ob = d
    if n == 'jsr' and m == 'abs':
        tp = g.resolve(p, ob[0] | ob[1] << 8)
        return tp is not None and tp in g.INLINE_DISP
    return False
def inline_skip(p, d):
    op, n, m, l, ob = d
    if n == 'jsr' and m == 'abs':
        tp = g.resolve(p, ob[0] | ob[1] << 8)
        return g.INLINE_N.get(tp, 0) if tp is not None else 0
    return 0
def pushed_return(p):
    """JMP preceded by `lda #hi / pha / lda #lo / pha` (a call through a pointer with a fake return address): the return point or None"""
    b = g.PRG; lo = p - 6
    if lo >= (p >> 14 << 14) and b[lo] == 0xA9 and b[lo + 2] == 0x48 and b[lo + 3] == 0xA9 and b[lo + 5] == 0x48:
        ra = (b[lo + 1] << 8 | b[lo + 4]) + 1
        rp = g.resolve(p, ra)
        if rp is not None and code[rp] == 'S': return rp
    return None
def lift_function(entry):
    """returns (c_source_lines, unsupported_reason or None)"""
    body = {}; work = [entry]; reason = None
    while work:
        p = work.pop()
        if p in body: continue
        if code[p] is None and p not in CONF: reason = reason or f'flow reaches data at ${g.addr_of(p):04X}'; continue
        d = g.decode(p)
        if d is None: reason = reason or f'cannot decode ${g.addr_of(p):04X}'; continue
        body[p] = d; op, n, m, l, ob = d
        succ = []
        if m == 'rel':
            t = (g.addr_of(p) + 2 + (ob[0] - 256 if ob[0] > 127 else ob[0])) & 0xFFFF; k = target_code(p, t)
            if k[0] == 'local': succ.append(k[1])
            succ.append(p + l)
        elif n == 'jmp' and pushed_return(p) is not None:
            succ.append(pushed_return(p))
            if m == 'abs':
                k = target_code(p, ob[0] | ob[1] << 8)
                if k[0] == 'local': succ.append(k[1])
        elif n == 'jmp' and m == 'abs':
            k = target_code(p, ob[0] | ob[1] << 8)
            if k[0] == 'local': succ.append(k[1])
        elif n in ('rts', 'rti', 'jmp', 'brk') or is_dispatch_call(p, d): pass
        else: succ.append(p + l + inline_skip(p, d))
        for s in succ:
            if s in entries and s != entry: continue          # flow into another routine = tail call, not followed
            work.append(s)
    if not body: return [], reason or 'empty body', 0
    order = sorted(body)
    need_label = set([entry])
    out = []

    def label(p): return f'L{g.addr_of(p):04X}'
    def jump_to(cur, t, cond=None):
        k = target_code(cur, t)
        if k[0] == 'local': need_label.add(k[1]); stmt = f'goto {label(k[1])};'
        elif k[0] == 'entry': stmt = f'{{ {fname(k[1])}(); return; }}'
        else: stmt = f'{{ call_addr(0x{t:04X}); return; }}'
        return f'if ({cond}) {stmt}' if cond else stmt
    def call(cur, t):
        k = target_code(cur, t)
        ret = g.addr_of(cur) + 2                      # JSR pushes the address of its last byte
        inner = f'{fname(k[1])}();' if k[0] in ('local', 'entry') else f'call_addr(0x{t:04X});'
        return f'push16(0x{ret:04X}); {inner} ret_check(0x{ret:04X});'

    stmts = {}
    for p in order:
        op, n, m, l, ob = body[p]; s = ''
        if m == 'rel':
            t = (g.addr_of(p) + 2 + (ob[0] - 256 if ob[0] > 127 else ob[0])) & 0xFFFF
            cond = {'bpl': '!R.n', 'bmi': 'R.n', 'bvc': '!R.v', 'bvs': 'R.v', 'bcc': '!R.c', 'bcs': 'R.c', 'bne': '!R.z', 'beq': 'R.z'}[n]
            s = jump_to(p, t, cond)
        elif n == 'jsr' and is_dispatch_call(p, body[p]):      # the callee jumps to a handler whose RTS returns to our caller
            k0 = target_code(p, ob[0] | ob[1] << 8); s = f'push16(0x{g.addr_of(p) + 2:04X}); {fname(k0[1])}(); return;'
        elif n == 'jsr': s = call(p, ob[0] | ob[1] << 8)
        elif n == 'jmp' and pushed_return(p) is not None:       # call through a pointer; the callee's RTS resumes after the JMP's fake return
            rp = pushed_return(p); need_label.add(rp)
            if m == 'abs': k0 = target_code(p, ob[0] | ob[1] << 8); inner = (f'{fname(k0[1])}();' if k0[0] in ('local', 'entry') else f'call_addr(0x{ob[0] | ob[1] << 8:04X});')
            else: inner = f'call_addr(rd16bug(0x{ob[0] | ob[1] << 8:04X}));'
            s = f'{inner} R.sp += 2; goto {label(rp)};'
        elif n == 'jmp':
            if m == 'abs': s = jump_to(p, ob[0] | ob[1] << 8)
            else:
                v = ob[0] | ob[1] << 8; s = f'call_addr(rd16bug(0x{v:04X})); return;'
        elif n in ('rts', 'rti'): s = 'return;'
        elif n == 'brk': s = 'cpu_brk(); return;'
        elif m == 'imp':
            s = {'nop': '', 'pha': 'push(R.a);', 'php': 'push(getp() | 0x30);', 'pla': 'R.a = pull(); NZ(R.a);', 'plp': 'setp(pull());',
                 'clc': 'R.c = 0;', 'sec': 'R.c = 1;', 'cli': 'R.i = 0;', 'sei': 'R.i = 1;', 'cld': 'R.d = 0;', 'sed': 'R.d = 1;', 'clv': 'R.v = 0;',
                 'tax': 'R.x = R.a; NZ(R.x);', 'tay': 'R.y = R.a; NZ(R.y);', 'txa': 'R.a = R.x; NZ(R.a);', 'tya': 'R.a = R.y; NZ(R.a);',
                 'tsx': 'R.x = R.sp; NZ(R.x);', 'txs': 'R.sp = R.x;', 'inx': 'R.x++; NZ(R.x);', 'iny': 'R.y++; NZ(R.y);',
                 'dex': 'R.x--; NZ(R.x);', 'dey': 'R.y--; NZ(R.y);'}[n]
        elif m == 'acc': s = f'R.a = {n}8(R.a);'
        else:
            if n in ('lda', 'ldx', 'ldy'):
                reg = 'R.' + n[2]; s = f'{reg} = {val_expr(m, ob)}; NZ({reg});'
            elif n in ('sta', 'stx', 'sty'): s = f'wr({ea_expr(m, ob)}, R.{n[2]});'
            elif n == 'adc': s = f'adc({val_expr(m, ob)});'
            elif n == 'sbc': s = f'sbc({val_expr(m, ob)});'
            elif n in ('and', 'ora', 'eor'):
                s = f'R.a {"&|^"[("and", "ora", "eor").index(n)]}= {val_expr(m, ob)}; NZ(R.a);'
            elif n in ('cmp', 'cpx', 'cpy'): s = f'cmp8(R.{ {"cmp": "a", "cpx": "x", "cpy": "y"}[n] }, {val_expr(m, ob)});'
            elif n == 'bit': s = f'bit8({val_expr(m, ob)});'
            elif n in ('inc', 'dec'):
                s = f'{{ uint16_t e_ = {ea_expr(m, ob)}; uint8_t v_ = (uint8_t)(rd(e_) {"+" if n == "inc" else "-"} 1); wr(e_, v_); NZ(v_); }}'
            elif n in ('asl', 'lsr', 'rol', 'ror'):
                s = f'{{ uint16_t e_ = {ea_expr(m, ob)}; wr(e_, {n}8(rd(e_))); }}'
            else: reason = reason or f'opcode {n} {m}'
        stmts[p] = s
    for k, p in enumerate(order):
        op, n, m, l, ob = body[p]
        nxt = order[k + 1] if k + 1 < len(order) else None
        ends = n in ('rts', 'rti', 'jmp', 'brk') or is_dispatch_call(p, body[p])
        extra = ''
        if not ends:
            ft = p + l + inline_skip(p, body[p])
            if ft in body:
                if nxt != ft: need_label.add(ft); extra = f' goto {label(ft)};'
            elif ft in entries and ft != entry: extra = f' {{ {fname(ft)}(); return; }}'
            else: reason = reason or f'falls off at ${g.addr_of(p):04X}'
        stmts[p] = stmts[p] + extra
    lines = [f'void {fname(entry)}(void) {{  /* ${g.addr_of(entry):04X} bank {g.bank_of(entry)} */']
    if order[0] != entry: lines.append(f'  goto {label(entry)};')
    for p in order:
        op, n, m, l, ob = body[p]
        lab = f'{label(p)}:' if p in need_label else ''
        backward = any(False for _ in ())
        lines.append(f' {lab:<7}{("BUDGET(); " if lab else "")}TR(0x{g.addr_of(p):04X}); {stmts[p]:<64} /* ${g.addr_of(p):04X} {n} */')
    lines.append('}')
    return lines, reason, len(order)

# ---- generate -------------------------------------------------------------------------------------------------------
funcs = {}; per_bank = {b: [] for b in range(8)}
for e in sorted(entries):
    lines, reason, n = lift_function(e)
    if reason:
        lines = [f'void {fname(e)}(void) {{ cpu_unsupported("{fname(e)}: {reason}"); }}']
    funcs[fname(e)] = dict(addr=g.addr_of(e), bank=g.bank_of(e), instrs=n, ok=reason is None, reason=reason)
    per_bank[g.bank_of(e)].append(lines)
for b in range(8):
    with open(os.path.join(OUT, f'bank_{b}.c'), 'w', newline='\n') as f:
        f.write(f'/* GENERATED by tools/lift.py --version {VER}: mechanical C for the routines of PRG bank {b}. Do not edit. */\n#include "../runtime.h"\n#include "decls.h"\n\n')
        for lines in per_bank[b]: f.write('\n'.join(lines) + '\n\n')
with open(os.path.join(OUT, 'decls.h'), 'w', newline='\n') as f:
    f.write('/* GENERATED by tools/lift.py */\n#pragma once\n')
    for e in sorted(entries): f.write(f'void {fname(e)}(void);\n')
with open(os.path.join(OUT, 'dispatch.c'), 'w', newline='\n') as f:
    f.write('/* GENERATED by tools/lift.py: call_addr() maps a CPU address to the lifted routine (for JSR/JMP through RAM pointers or banks) */\n#include "../runtime.h"\n#include "decls.h"\n\n')
    f.write('static int fixed_bank(uint16_t a) {\n    switch (a) {\n')
    for e in sorted(entries):
        if g.bank_of(e) == 7: f.write(f'    case 0x{g.addr_of(e):04X}: {fname(e)}(); return 1;\n')
    f.write('    }\n    return 0;\n}\n')
    for b in range(7):
        f.write(f'static int bank{b}(uint16_t a) {{\n    switch (a) {{\n')
        for e in sorted(entries):
            if g.bank_of(e) == b: f.write(f'    case 0x{g.addr_of(e):04X}: {fname(e)}(); return 1;\n')
        f.write('    }\n    return 0;\n}\n')
    f.write('void call_addr(uint16_t a) {\n    if (a >= 0xC000) { if (fixed_bank(a)) return; }\n    else if (a >= 0x8000) {\n        switch (g_bank) {\n')
    for b in range(7): f.write(f'        case {b}: if (bank{b}(a)) return; break;\n')
    f.write('        }\n    }\n    cpu_unknown_target(a);\n}\n')
json.dump(funcs, open(os.path.join(OUT, 'funcs.json'), 'w'), indent=1)
ok = sum(1 for v in funcs.values() if v['ok'])
print(f'[{VER}] {len(funcs)} routines, {ok} lifted, {len(funcs) - ok} unsupported')
for k, v in funcs.items():
    if not v['ok']: print('  ', k, v['reason'])
