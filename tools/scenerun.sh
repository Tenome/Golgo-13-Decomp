#!/bin/bash
# usage: tools/scenerun.sh VERSION FRAMES FIRST LAST : one run per scene target (hex), so a scene that hangs the simulator only ends its own run
v=$1; frames=$2; lo=$((16#$3)); hi=$((16#$4))
cd "$(dirname "$0")/.."
for t in $(seq $lo $hi); do
  h=$(printf '%02X' $t)
  bash tools/frameloop.sh $v $frames --seed $t --assist --fuzz-state 100 --sweep --sweep-range $h $h --out-exec build/fz_${v}_t$h.json --out-first build/fz_first_${v}_t$h.json 2>&1 | tail -1 | cut -c1-160 | sed "s/^/[$h] /"
done
