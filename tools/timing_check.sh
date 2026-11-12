#!/bin/bash
# Compare the native port's pictures with NESRecomp's interpreter on random routes: tools/timing_check.sh VERSION "SEEDS" "FRAMES"
# needs the reference exe (dist/golgo13-<ver>.exe of the NESRecomp project) in REF, and the port built by tools/build_port.py
v=$1; seeds=${2:-"1 2 3"}; frames=${3:-"3000 4500"}; root="$(cd "$(dirname "$0")/.." && pwd)"; w="$root/build/timing"; mkdir -p "$w"
REF=${REF:-"/e/Claude - NES Decomp Disassembly/dist/golgo13-$v.exe"}; export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy
for s in $seeds; do
  python "$root/tools/mkroute.py" $s 9000 "$w/rt_$s.route" $((1500+(s%5)*150)) > /dev/null
  for f in $frames; do
    "$REF" "$root/orig/golgo13_$v.nes" --hidden --interp-only --frames $f --window-input "$w/rt_$s.route" --exit-after $f --uncapped --present-out "$w/rref_${s}_$f.png" > /dev/null 2>&1
    "$root/build/port/golgo13_port_$v.exe" "$root/orig/golgo13_$v.nes" --frames $f --input "$w/rt_$s.route" --out "$w" --shot-every $f > /dev/null 2>&1
    mv "$w/frame_$(printf %06d $f).ppm" "$w/rp_${s}_$f.ppm"
    echo -n "$v seed=$s frame=$f: "; python "$root/tools/cmp_frames.py" "$w/rp_${s}_$f.ppm" "$w/rref_${s}_$f.png" | head -1
  done
done
