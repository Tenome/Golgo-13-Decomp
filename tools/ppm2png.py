"""python tools/ppm2png.py in.ppm... : convert port screenshots to PNG (no dependencies); several inputs are tiled into one sheet when --sheet OUT.png is given"""
import sys, zlib, struct
def read(p):
    d = open(p, 'rb').read(); parts = d.split(b'\n', 3); w, h = map(int, parts[1].split()); return w, h, parts[3]
def png(path, w, h, rgb):
    raw = b''.join(b'\x00' + rgb[y * w * 3:(y + 1) * w * 3] for y in range(h))
    ch = lambda t, b: struct.pack('>I', len(b)) + t + b + struct.pack('>I', zlib.crc32(t + b) & 0xFFFFFFFF)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + ch(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)) + ch(b'IDAT', zlib.compress(raw)) + ch(b'IEND', b''))
a = sys.argv[1:]
if a and a[0] == '--sheet':
    out = a[1]; ims = [read(p) for p in a[2:]]; cols = min(len(ims), 4); rows = (len(ims) + cols - 1) // cols; W = 256 * cols; H = 240 * rows
    buf = bytearray(W * H * 3)
    for k, (w, h, d) in enumerate(ims):
        ox, oy = (k % cols) * 256, (k // cols) * 240
        for y in range(h): buf[((oy + y) * W + ox) * 3:((oy + y) * W + ox + w) * 3] = d[y * w * 3:(y + 1) * w * 3]
    png(out, W, H, bytes(buf))
else:
    for p in a: w, h, d = read(p); png(p[:-4] + '.png', w, h, d)
