#!/bin/bash
# Check a native build against NESRecomp's interpreter (same exe, --interp-only) on a random input route:
# the per-frame hashes (CPU trace, memory, picture, registers, hardware state) must be identical.
#   tools/native_check.sh VERSION SEED FRAMES      run from the repo root after recomp/build_native.ps1
# Writes build/native_check/<ver>_<seed>.* and the final picture of the native run.
v=$1; s=$2; f=$3; root="$(cd "$(dirname "$0")/.." && pwd)"; w="$root/build/native_check"; mkdir -p "$w"
E="$root/build/native/$v/cmake/Release/nes_game.exe"; export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy
python "$root/tools/mkroute.py" $s $f "$w/${v}_$s.route" $((1500+(s%5)*150))
"$E" "$root/orig/golgo13_$v.nes" --hidden --frames $f --window-input "$w/${v}_$s.route" --exit-after $f --uncapped --present-out "$w/${v}_$s.png" --hash-out "$w/${v}_$s.native.txt" > "$w/${v}_$s.native.log" 2>&1
"$E" "$root/orig/golgo13_$v.nes" --hidden --interp-only --frames $f --window-input "$w/${v}_$s.route" --exit-after $f --uncapped --hash-out "$w/${v}_$s.interp.txt" > "$w/${v}_$s.interp.log" 2>&1
if cmp -s "$w/${v}_$s.native.txt" "$w/${v}_$s.interp.txt"; then echo "$v seed=$s frames=$f IDENTICAL"; else echo "$v seed=$s frames=$f DIFFERENT"; exit 1; fi
