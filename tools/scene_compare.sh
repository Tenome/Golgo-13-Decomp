#!/bin/bash
# Force every scene target in the port and in NESRecomp's interpreter and compare the pictures:
#   tools/scene_compare.sh VERSION FIRST LAST [FRAMES]    (targets in hex, e.g. 78 8F)
v=$1; lo=$((16#$2)); hi=$((16#$3)); f=${4:-3300}; root="$(cd "$(dirname "$0")/.." && pwd)"; w="$root/build/timing/sc"; mkdir -p "$w"
REF=${REF:-"/e/Claude - NES Decomp Disassembly/dist/golgo13-$v.exe"}; export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy
for t in $(seq $lo $hi); do
  h=$(printf '%02X' $t)
  python - "$root" "$w" $h <<'PY'
import sys
root, w, h = sys.argv[1], sys.argv[2], sys.argv[3]
base = [l for l in open(root + '/build/act/h0.route').read().splitlines() if l.strip() and int(l.split()[0]) <= 2400]
open(f'{w}/{h}.route', 'w').write('\n'.join(base + ['2500 POKE 0028 01', f'2500 POKE 0029 {h}', '2500 POKE 002A 00', '2500 POKE 0014 0C']) + '\n')
PY
  "$REF" "$root/orig/golgo13_$v.nes" --hidden --interp-only --frames $f --window-input "$w/$h.route" --exit-after $f --uncapped --present-out "$w/ref_$h.png" > /dev/null 2>&1
  "$root/build/port/golgo13_port_$v.exe" "$root/orig/golgo13_$v.nes" --frames $f --input "$w/$h.route" --out "$w" --shot-every $f > /dev/null 2>&1
  mv "$w/frame_$(printf %06d $f).ppm" "$w/p_$h.ppm" 2>/dev/null
  echo -n "$v target $h: "; python "$root/tools/cmp_frames.py" "$w/p_$h.ppm" "$w/ref_$h.png" 2>&1 | head -1 | cut -c1-70
done
