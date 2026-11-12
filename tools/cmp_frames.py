"""Compare a port picture (PPM) with a reference picture (PNG) of the same frame, ignoring the palette: python tools/cmp_frames.py port.ppm ref.png [diff.png]
The palettes of the two renderers differ, so the colours are matched through the most frequent pairing (port colour -> reference colour);
every pixel that breaks that mapping is a real difference (a shifted line, a missing sprite, a wrong tile)."""
import sys, zlib, struct, collections

def read_png(path):
    d = open(path, 'rb').read(); pos = 8; idat = b''; w = h = bd = ct = 0
    while pos < len(d):
        n, = struct.unpack('>I', d[pos:pos + 4]); t = d[pos + 4:pos + 8]; body = d[pos + 8:pos + 8 + n]; pos += 12 + n
        if t == b'IHDR': w, h, bd, ct = struct.unpack('>IIBB', body[:10])
        elif t == b'IDAT': idat += body
    raw = zlib.decompress(idat); bpp = {2: 3, 6: 4}[ct]; stride = w * bpp; rows = []; prev = bytearray(stride); p = 0
    for _ in range(h):
        f = raw[p]; line = bytearray(raw[p + 1:p + 1 + stride]); p += 1 + stride
        for i in range(stride):
            a = line[i - bpp] if i >= bpp else 0; b = prev[i]; c = prev[i - bpp] if i >= bpp else 0
            if f == 1: line[i] = (line[i] + a) & 255
            elif f == 2: line[i] = (line[i] + b) & 255
            elif f == 3: line[i] = (line[i] + (a + b) // 2) & 255
            elif f == 4:
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c); pr = a if pa <= pb and pa <= pc else b if pb <= pc else c
                line[i] = (line[i] + pr) & 255
        rows.append(bytes(line)); prev = line
    return w, h, [[tuple(r[x * bpp:x * bpp + 3]) for x in range(w)] for r in rows]

def read_ppm(path):
    d = open(path, 'rb').read(); parts = d.split(b'\n', 3); w, h = map(int, parts[1].split()); b = parts[3]
    return w, h, [[tuple(b[(y * w + x) * 3:(y * w + x) * 3 + 3]) for x in range(w)] for y in range(h)]

pw, ph, P = read_ppm(sys.argv[1]); rw, rh, Rf = read_png(sys.argv[2])
if (rw, rh) != (pw, ph):                                  # the reference may be scaled: take every n-th pixel
    sx, sy = rw // pw, rh // ph; Rf = [[Rf[y * sy][x * sx] for x in range(pw)] for y in range(ph)]
pairs = collections.Counter((P[y][x], Rf[y][x]) for y in range(ph) for x in range(pw))
best = {}
for (pc, rc), n in pairs.most_common():
    if pc not in best: best[pc] = rc
bad = [(x, y) for y in range(ph) for x in range(pw) if best[P[y][x]] != Rf[y][x]]
rows = collections.Counter(y for x, y in bad)
print(f'{len(bad)} of {pw * ph} pixels differ ({100.0 * len(bad) / (pw * ph):.3f} %); colours in port {len(best)}, in reference {len(set(Rf[y][x] for y in range(ph) for x in range(pw)))}')
if rows: print('rows with differences:', sorted(rows.items())[:30])
