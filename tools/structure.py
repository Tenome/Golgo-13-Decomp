"""Turn the goto soup of a lifted routine into if / if-else / do-while blocks where the control flow allows it.

Input: a list of Items (plain statement, conditional goto `cb`, unconditional goto) in address order; labels are attached to the
item that follows them. Rewrites (repeatedly, smallest spans first):
  * backward `cb` / `goto` whose label sits at an earlier item and nothing else enters the region  -> do { } while (cond) / for (;;)
  * forward `cb` over a block that nothing else enters                                              -> if (!cond) { }
  * the same with the block ending in a goto over an else-block                                    -> if / else
Anything that does not fit stays a goto. The result is semantically identical (tools/autotest.py checks every routine)."""


class Item:
    def __init__(self, kind, text='', cond=None, neg=None, target=None, labels=None, comment='', body=None, els=None):
        self.kind, self.text, self.cond, self.neg, self.target = kind, text, cond, neg, target
        self.labels = list(labels or []); self.comment = comment; self.body = body; self.els = els


def targets(it):
    t = set()
    if it.target: t.add(it.target)
    for lst in (it.body, it.els):
        for x in lst or []: t |= targets(x)
    return t


def inner_labels(items):
    s = set()
    for it in items:
        s |= set(it.labels)
        for lst in (it.body, it.els):
            if lst: s |= inner_labels(lst)
    return s


def outside_refs(items, lo, hi):
    """labels referenced by items outside [lo, hi]"""
    t = set()
    for k, it in enumerate(items):
        if not lo <= k <= hi: t |= targets(it)
    return t


def find_label(items, name):
    for k, it in enumerate(items):
        if name in it.labels: return k
    return None


def try_loop(items):
    best = None
    for j, it in enumerate(items):
        if it.kind in ('cb', 'goto') and it.target:
            i = find_label(items, it.target)
            if i is not None and i <= j:
                if best is None or j - i < best[1] - best[0]: best = (i, j)
    for i, j in sorted([best] if best else [], key=lambda x: x[1] - x[0]):
        it = items[j]; entry = it.target
        inside = inner_labels(items[i:j]) | set(items[i].labels)
        inside_entry_only = inside - {entry}
        ext = outside_refs(items, i, j)
        if ext & inside_entry_only: return None
        body = items[i:j]
        loop = Item('loop', text=it.text, cond=it.cond if it.kind == 'cb' else None, labels=items[i].labels, comment=it.comment)
        # keep the entry label inside the loop body if the body still jumps to it
        loop.body = body
        loop.labels = [l for l in items[i].labels if l != entry]
        if body: body[0].labels = [l for l in body[0].labels if l == entry]
        loop.body = body
        loop.entry = entry
        loop.exit_text = it.text
        return items[:i] + [loop] + items[j + 1:]
    return None


def try_if(items):
    for i, it in enumerate(items):
        if it.kind != 'cb': continue
        k = find_label(items, it.target)
        if k is None or k <= i: continue
        block = items[i + 1:k]
        lbl_block = inner_labels(block)
        ext = set()
        for x, y in enumerate(items):
            if not (i + 1 <= x <= k - 1): ext |= targets(y)
        ext_wo_cb = ext
        if (ext_wo_cb - {it.target}) & lbl_block or (it.target in lbl_block): continue          # something else enters the block
        # if / else: the block ends with a goto over the else part
        if block and block[-1].kind == 'goto' and not block[-1].labels and block[-1].target != it.target:
            m = find_label(items, block[-1].target)
            if m is not None and m > k:
                els = items[k:m]
                refs_else = set()
                for x, y in enumerate(items):
                    if x != i: refs_else |= targets(y) if not (k <= x < m) else set()
                lbl_else = inner_labels(els)
                outside_else = set()
                for x, y in enumerate(items):
                    if not (k <= x < m): outside_else |= targets(y)
                # the else part may only be entered through the cb (its own first label)
                entry_ok = (outside_else & lbl_else) <= {it.target}
                only_cb = sum(1 for x, y in enumerate(items) if it.target in targets(y)) == 1
                if entry_ok and only_cb:
                    then = block[:-1]
                    els[0].labels = [l for l in els[0].labels if l != it.target]
                    if not then:                                    # nothing to do when the branch is not taken: if (cond) { else-part }
                        node = Item('if', text=it.text, cond=it.cond, labels=items[i].labels, comment=it.comment, body=els, els=None)
                    else:
                        node = Item('if', text=it.text, cond=it.neg, labels=items[i].labels, comment=it.comment, body=then, els=els)
                    return items[:i] + [node] + items[m:]
        node = Item('if', text=it.text, cond=it.neg, labels=items[i].labels, comment=it.comment, body=block, els=None)
        if not block:
            return items[:i] + [Item('plain', text=it.text, labels=items[i].labels, comment=it.comment)] + items[k:]
        return items[:i] + [node] + items[k:]
    return None


def structure_list(items):
    changed = True
    while changed:
        changed = False
        for fn in (try_loop, try_if):
            r = fn(items)
            if r is not None: items = r; changed = True; break
    for it in items:
        if it.kind in ('loop', 'if'):
            it.body = structure_list(it.body)
            if it.els is not None: it.els = structure_list(it.els)
    return items


def _fmt(indent, text, comment):
    t = indent + text
    return f'{t:<88} /* {comment} */' if comment else t


def render(items, indent, referenced):
    out = []
    ind = '  ' * indent
    for it in items:
        for l in it.labels:
            if l in referenced: out.append(f'{l}: BUDGET();')
        if it.kind == 'plain':
            if it.text.strip(): out.append(_fmt(ind, it.text, it.comment))
        elif it.kind == 'cb': out.append(_fmt(ind, f'{it.text}if ({it.cond}) goto {it.target};', it.comment))
        elif it.kind == 'goto': out.append(_fmt(ind, f'{it.text}goto {it.target};', it.comment))
        elif it.kind == 'if':
            out.append(_fmt(ind, f'{it.text}if ({it.cond}) {{', it.comment))
            out += render(it.body, indent + 1, referenced)
            if it.els is not None:
                out.append(f'{ind}}} else {{'); out += render(it.els, indent + 1, referenced)
            out.append(f'{ind}}}')
        elif it.kind == 'loop':
            out.append(f'{ind}do {{ BUDGET();' if it.cond is not None else f'{ind}for (;;) {{ BUDGET();')
            out += render(it.body, indent + 1, referenced)
            out.append(_fmt(ind, f'}} while ({it.cond});' if it.cond is not None else '}', it.comment))
    return out


def run(items):
    items = structure_list(items)
    referenced = set()
    for it in items: referenced |= targets(it)
    return render(items, 1, referenced)
