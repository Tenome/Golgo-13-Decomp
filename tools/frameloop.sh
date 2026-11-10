#!/bin/bash
# usage: tools/frameloop.sh VERSION FRAMES [CC65_DIR]  -- run frametest; whenever the simulator reaches code that is not lifted yet,
# merge it into config/<ver>/coverage.json or ramcode.json, regenerate sources + lifted C and try again.
v=$1; frames=$2; cc=${3:-}
cd "$(dirname "$0")/.."
for i in $(seq 1 25); do
  python tools/frametest.py --version $v --frames $frames > build/frametest_$v.log 2>&1; rc=$?
  tail -1 build/frametest_$v.log | cut -c1-300
  [ $rc -ne 3 ] && exit $rc
  python tools/g13dis.py --version $v > /dev/null && python tools/lift.py --version $v | head -1
done
exit 4
