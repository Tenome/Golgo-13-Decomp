#!/bin/bash
# usage: tools/portloop.sh VERSION ROUTE FRAMES [extra port args]
# Build the native port, run a route; when the lifted code reaches an address without a routine (computed jump targets), add it to
# config/<ver>/entries.json, regenerate and run again.
v=$1; route=$2; frames=$3; shift 3
cd "$(dirname "$0")/.."
for i in $(seq 1 60); do
  python tools/g13dis.py --version $v > /dev/null && python tools/build_port.py --version $v > /dev/null 2>&1 || { echo "build failed"; exit 1; }
  out=$(build/port/golgo13_port_$v.exe orig/golgo13_$v.nes --frames $frames --input $route "$@" 2>&1)
  echo "$out" | tail -2
  m=$(echo "$out" | grep -o 'no routine for \$[0-9A-F]* in bank [0-9]')
  [ -z "$m" ] && exit 0
  addr=$(echo "$m" | sed 's/.*\$\([0-9A-F]*\) in bank \([0-9]\)/\1/'); bank=$(echo "$m" | sed 's/.*in bank \([0-9]\)/\1/')
  [ $((16#$addr)) -ge $((16#C000)) ] && bank=7
  [ $((16#$addr)) -lt $((16#2000)) ] && { echo "RAM code at $addr: run tools/ramcode_from_capture.py with a NESRecomp --capture-log of this route"; exit 3; }
  python tools/learn_entry.py --version $v "$bank:$addr"
done
