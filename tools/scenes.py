"""Force scene changes in the native port and tile the pictures: python tools/scenes.py VERSION FIRST LAST [--frames N] [--prefix NAME]
Each target is a TransitionTarget value (street area < $50, $78-$8F bank 4 scenes, >= $90 bank 5 scenes) poked in after the game has started."""
import subprocess, os, sys
ver = sys.argv[1]; lo, hi = int(sys.argv[2], 16), int(sys.argv[3], 16)
frames = int(sys.argv[sys.argv.index('--frames') + 1]) if '--frames' in sys.argv else 3000
prefix = sys.argv[sys.argv.index('--prefix') + 1] if '--prefix' in sys.argv else 'sc'
root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
exe = os.path.join(root, 'build', 'port', f'golgo13_port_{ver}.exe'); rom = os.path.join(root, 'orig', f'golgo13_{ver}.nes')
base = [l for l in open(os.path.join(root, 'build', 'act', 'h0.route')).read().splitlines() if l.strip() and int(l.split()[0]) <= 2400]
os.makedirs(os.path.join(root, 'build', 'scn'), exist_ok=True); files = []
for x in range(lo, hi + 1):
    r = base + [f'2500 POKE 0028 01', f'2500 POKE 0029 {x:02X}', f'2500 POKE 002A 00', f'2500 POKE 0014 0C']
    rt = os.path.join(root, 'build', 'scn', 'r.route'); open(rt, 'w').write('\n'.join(r) + '\n')
    d = os.path.join(root, 'build', 'scn', f'{prefix}{x:02X}'); os.makedirs(d, exist_ok=True)
    subprocess.run([exe, rom, '--frames', str(frames), '--input', rt, '--out', d, '--shot-every', str(frames)], capture_output=True)
    files.append(os.path.join(d, f'frame_{frames:06d}.ppm'))
for i in range(0, len(files), 8):
    subprocess.run([sys.executable, os.path.join(root, 'tools', 'ppm2png.py'), '--sheet', os.path.join(root, 'build', 'scn', f'{prefix}_{lo + i:02X}.png')] + files[i:i + 8])
print('sheets in build/scn')
