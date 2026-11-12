#!/bin/bash
# usage: tools/creditrun.sh VERSION : whole-program runs that credit the routines they execute (config/<ver>/lockstep.json): random play, scene sweeps, object fuzzing, one run per scene target
v=$1; cd "$(dirname "$0")/.."
run() { bash tools/frameloop.sh $v "$@" 2>&1 | tail -1 | cut -c1-150; }
for s in 3 5; do run 20000 --seed $s --assist --credit; done
run 36000 --seed 41 --assist --fuzz-state 450 --sweep --credit
for s in 52 53; do run 20000 --seed $s --assist --fuzz-objects 60 --credit; done
for t in $(seq $((16#90)) $((16#A8))); do h=$(printf '%02X' $t); run 7000 --seed $t --assist --fuzz-state 100 --sweep --sweep-range $h $h --credit; done
for t in $(seq $((16#78)) $((16#8F))); do h=$(printf '%02X' $t); run 7000 --seed $t --assist --fuzz-state 100 --sweep --sweep-range $h $h --fuzz-objects 50 --credit; done
for t in $(seq $((16#50)) $((16#77))); do h=$(printf '%02X' $t); run 4000 --seed $t --assist --fuzz-state 100 --sweep --sweep-range $h $h --credit; done
