#!/bin/bash
# Regenerate and verify everything for one version: sources, byte-identical build, report, lifted C, per-routine test, whole-program test.
#   tools/verify_all.sh us|jp [CC65_DIR] [FRAMES]
v=$1; cc=${2:-}; frames=${3:-3000}
cd "$(dirname "$0")/.."
ccarg=(); [ -n "$cc" ] && ccarg=(--cc65 "$cc")
python tools/g13dis.py --version $v | tail -1 || exit 1
python tools/build.py --version $v "${ccarg[@]}" || exit 1
python tools/report.py --version $v "${ccarg[@]}" | tail -1 || exit 1
python tools/lift.py --version $v | head -1
python tools/autotest.py --version $v --runs 100 2>&1 | tail -1 | cut -c1-200
tools/frameloop.sh $v $frames --assist 2>&1 | tail -1 | cut -c1-200
