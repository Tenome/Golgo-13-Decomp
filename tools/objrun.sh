#!/bin/bash
# usage: tools/objrun.sh VERSION FRAMES SEED... : runs with random objects poked into the object table, alone and combined with the scene sweep
v=$1; frames=$2; shift 2
cd "$(dirname "$0")/.."
for s in "$@"; do
  bash tools/frameloop.sh $v $frames --seed $s --assist --fuzz-objects 60 --out-exec build/fz_${v}_ob$s.json --out-first build/fz_first_${v}_ob$s.json 2>&1 | tail -1 | cut -c1-200
  bash tools/frameloop.sh $v $frames --seed $s --assist --fuzz-state 450 --sweep --fuzz-objects 50 --out-exec build/fz_${v}_obs$s.json --out-first build/fz_first_${v}_obs$s.json 2>&1 | tail -1 | cut -c1-200
done
