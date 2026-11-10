# Golgo 13: matching disassembly (NES)

A work-in-progress **matching decompilation** of *Golgo 13* for the Famicom/NES, in both releases:

| Version | Game | Notes |
|---|---|---|
| `us` | Golgo 13: Top Secret Episode (USA, Vic Tokai) | localized release |
| `jp` | Golgo 13: Daiisshou - Kamigami no Tasogare (Japan) | original release; 19 % of the bytes differ (text, banks 3-5, CHR) |

The source is ca65 assembly that rebuilds each 256 KB ROM **byte for byte**; the goals are readable, named source, C that is checked against the original code, and native Windows builds without an emulation core. All three exist in first form (see below).
This repository contains no game files. You need your own ROMs.

| | |
|---|---|
| Board | MMC1 (mapper 1), 8 x 16 KB PRG (banks 0-6 switchable at `$8000`, bank 7 fixed at `$C000`), 128 KB CHR-ROM, NES 2.0 header |
| Code found so far | about 34 KB in about 770 routines per version: every executed instruction plus code reached statically from it. A scan for code-looking gaps finds almost nothing more, so the other 94 KB of PRG is probably data (maps, scripts, text, graphics) |
| Data | everything else (`.incbin` of files extracted from your ROM into `assets/`, git-ignored) |
| Byte identity | `python tools/build.py` prints `MATCH` for both versions |
| C lifting | mechanical C for every classified routine (`c/auto/`: 652 of 711 routines verified against the 6502 code on random states, none failing; the whole lifted program runs 12,000 frames from power-on identical to the original) plus readable hand-lifted C (`c/golgo13.c`, 37 routines) |
| Native port from the lifted C | `c/port/` + `tools/build_port.py`: PPU/APU/MMC1 host around the lifted game logic, headless or SDL2 window (runs both versions; see docs/NOTES.md) |
| Native build (static recompilation) | `recomp/build_native.ps1` statically recompiles the classified code to C with [NESRecomp](https://github.com/mstan/nesrecomp) (about 99.8 % of cycles native in a 600-frame boot test) |

Two kinds of ByteMatch report are published (`progress/<ver>/report.json`, `progress/<ver>_c/report.json`). The first counts **byte-exact assembly source**: decoded instructions and `.incbin` data both count as matching, so the numbers start at 100 %.
The `_c` reports (`tools/report.py --c`) count a routine as matched when its lifted C is verified against the 6502 code on random states (about 90 % of the code bytes today); routines that are lifted but cannot be tested on random input count 50 %.
What continues from here is understanding: more code found, routines and RAM named, data turned into structured forms. See `docs/NOTES.md`.

## Building

```
# 1. put your ROMs in orig/ (see orig/README.md), install cc65 (ca65 + ld65) and Python 3.10+
python tools/g13dis.py --version us     # extract assets/us/ from your ROM and (re)generate src/us/
python tools/build.py  --version us     # ca65 + ld65, compares with orig/golgo13_us.nes; prints MATCH
python tools/report.py --version us     # verify, then write progress/us/report.json
# the same with --version jp
```
cc65 is found through `--cc65 DIR`, `$CC65_DIR` or `PATH`.

## Layout

| Path | Contents |
|---|---|
| `src/<ver>/` | generated ca65 sources: header, `bank_N.asm` (instructions, labels, pointer tables), `hardware.inc` (PPU/APU/MMC1 registers and RAM names) |
| `config/<ver>/` | `coverage.json` (opcodes executed in play, PRG offsets), `names.json` (routine names), `ram.json` (RAM names), `hints.json` (extra code entry points / forced data) |
| `config/golgo13.cfg` | ld65 memory layout shared by both versions |
| `assets/<ver>/` | data extracted from your ROM (git-ignored) |
| `tools/` | `g13dis.py` bank-aware tracing disassembler/emitter, `build.py`, `report.py`, `gapscan.py`, coverage tools (`mkroute.py`, `miss2cov.py`, `run_routes.sh`), `make_seeds.py` for the recompiler |
| `progress/<ver>/report.json` | objdiff-format report that ByteMatch reads (published by `.github/workflows/report.yml` as `<ver>_report`) |
| `recomp/` | native Windows build script |
| `docs/NOTES.md` | findings: memory map, MMC1 handling, game structure, workflow |

Edit the JSON files in `config/`, not the generated `src/`: running `tools/g13dis.py` rewrites `src/<ver>/`.

## How code is found

The retail code is table driven and banked, so a plain linear or reset-vector trace finds little. `tools/g13dis.py` combines, in order of trust:

1. opcodes the game actually executed (`config/<ver>/coverage.json`, recorded with NESRecomp's interpreter host and romatlas),
2. static descent from those, the vectors and `hints.json`,
3. pointer tables found from paired indexed loads (`lda Tbl,x` / `lda Tbl+1,x` then `jmp (zp)`),
4. a conservative gap scan, marked `[heuristic code]` in the source.

A hold-out check classified from part of the coverage and compared with code reached later: 0 misaligned predictions, 64 % of newly executed instructions already found.
Everything not found is data. Later acts have not been played, so some code there may still be missing; `tools/frametest.py`, `tools/frameloop.sh` and `tools/portloop.sh` add missing routines automatically when the lifted C or the native port reaches them.

## Playing the native port

```
python tools/build_port.py --version us --sdl <SDL2 development folder>      # also needs clang or gcc (--clang PATH)
build/port/golgo13_play_us.exe orig/golgo13_us.nes                           # arrows, Z = A, X = B, Enter = Start, Right Shift = Select
```
`build/port/golgo13_port_us.exe ROM --frames N --input route.txt --out DIR --shot-every N --wav out.wav` runs headless and dumps pictures / audio.
The port runs the lifted game logic on a small PPU/APU/MMC1 host written for this project; it is not an emulator of the original CPU. See `docs/NOTES.md`.

## Verification in one command
`tools/verify_all.sh us [cc65 dir] [frames]` regenerates the sources, checks that the ROM rebuilds byte for byte, rewrites the report, lifts the C and runs the per-routine and the whole-program differential tests.
