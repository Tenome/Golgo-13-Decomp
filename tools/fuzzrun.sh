#!/bin/bash
# usage: tools/fuzzrun.sh VERSION FRAMES SEED... : state-fuzzed whole-program runs that learn new code (see tools/frametest.py --fuzz-state)
v=$1; frames=$2; shift 2
cd "$(dirname "$0")/.."
for s in "$@"; do
  bash tools/frameloop.sh $v $frames --seed $s --assist --fuzz-state 300 --out-exec build/fz_${v}_$s.json --out-first build/fz_first_${v}_$s.json 2>&1 | tail -1 | cut -c1-200
done
