"""Compare two WAV files (the port's and a reference emulator's) of the same input: python tools/cmp_audio.py port.wav ref.wav [window_seconds]
Both are resampled to 16 kHz mono; per window it prints the RMS of each, the correlation of their magnitude spectra and the strongest frequencies,
so level, timing (a shifted note shows up as low correlation) and pitch errors are visible without listening."""
import sys, struct
import numpy as np

def load(path):
    d = open(path, 'rb').read(); i = d.index(b'data'); n, = struct.unpack('<I', d[i + 4:i + 8]); f = d.index(b'fmt ')
    ch, sr = struct.unpack('<HI', d[f + 10:f + 16]); bits, = struct.unpack('<H', d[f + 22:f + 24]); raw = d[i + 8:i + 8 + n]
    x = np.frombuffer(raw, dtype='<i2' if bits == 16 else '<i4').astype(np.float64)
    if ch == 2: x = x[::2]
    return sr, x / (32768.0 if bits == 16 else 2147483648.0)

def resample(x, sr, to=16000):
    t = np.arange(0, len(x) / sr, 1.0 / to); return np.interp(t, np.arange(len(x)) / sr, x)

sr1, a = load(sys.argv[1]); sr2, b = load(sys.argv[2]); win = float(sys.argv[3]) if len(sys.argv) > 3 else 1.0
a = resample(a, sr1); b = resample(b, sr2); n = min(len(a), len(b)); a, b = a[:n], b[:n]; w = int(16000 * win)
print(f'{n / 16000:.1f} s compared; overall RMS port {np.sqrt(np.mean(a * a)):.4f} ref {np.sqrt(np.mean(b * b)):.4f} (ratio {np.sqrt(np.mean(a * a)) / max(1e-9, np.sqrt(np.mean(b * b))):.2f})')
cors = []
for s in range(0, n - w + 1, w):
    x, y = a[s:s + w], b[s:s + w]; ra, rb = np.sqrt(np.mean(x * x)), np.sqrt(np.mean(y * y))
    if ra < 1e-4 and rb < 1e-4: continue
    X = np.abs(np.fft.rfft(x * np.hanning(w))); Y = np.abs(np.fft.rfft(y * np.hanning(w)))
    X /= max(1e-12, X.sum()); Y /= max(1e-12, Y.sum()); c = float(np.dot(X, Y) / max(1e-12, np.linalg.norm(X) * np.linalg.norm(Y))); cors.append(c)
    fa = np.argsort(X)[-3:][::-1] * 16000.0 / w; fb = np.argsort(Y)[-3:][::-1] * 16000.0 / w
    print(f'{s / 16000:6.1f}s  rms port {ra:.3f} ref {rb:.3f}  spectrum corr {c:.2f}  peaks port {np.round(fa).astype(int).tolist()} ref {np.round(fb).astype(int).tolist()}')
if cors: print(f'mean spectrum correlation {np.mean(cors):.3f} over {len(cors)} windows')
