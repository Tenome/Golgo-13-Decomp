"""Side-by-side crop (port left, reference right) scaled 3x: python tools/crop_cmp.py port.ppm ref.png y0 y1 out.png"""
import sys, zlib, struct
src = open(__file__.replace('crop_cmp.py', 'cmp_frames.py')).read().split("pw, ph, P = read_ppm")[0]; ns = {}; exec(src, ns)
pw, ph, P = ns['read_ppm'](sys.argv[1]); rw, rh, R = ns['read_png'](sys.argv[2]); y0, y1 = int(sys.argv[3]), int(sys.argv[4])
s = rw // pw; R = [[R[y * s][x * s] for x in range(pw)] for y in range(ph)]
rows = []
for y in range(y0, y1):
    line = b''.join(bytes(P[y][x]) * 3 for x in range(256)) + b'\xff\xff\xff' * 24 + b''.join(bytes(R[y][x]) * 3 for x in range(256))
    for _ in range(3): rows.append(b'\x00' + line)
ch = lambda t, b: struct.pack('>I', len(b)) + t + b + struct.pack('>I', zlib.crc32(t + b) & 0xFFFFFFFF)
open(sys.argv[5], 'wb').write(b'\x89PNG\r\n\x1a\n' + ch(b'IHDR', struct.pack('>IIBBBBB', (256 * 2 + 8) * 3, len(rows), 8, 2, 0, 0, 0)) + ch(b'IDAT', zlib.compress(b''.join(rows))) + ch(b'IEND', b''))
