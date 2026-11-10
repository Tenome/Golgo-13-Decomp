# Golgo 13: matching disassembly (NES)

A work-in-progress **matching decompilation** of *Golgo 13* for the Famicom/NES, in both releases:

| Version | Game | Notes |
|---|---|---|
| `us` | Golgo 13: Top Secret Episode (USA, Vic Tokai) | localized release |
| `jp` | Golgo 13: Daiisshou - Kamigami no Tasogare (Japan) | original release; 19 % of the bytes differ (text, banks 3-5, CHR) |

The source is ca65 assembly that rebuilds each 256 KB ROM **byte for byte**; the long-term goal is readable, named source and a native Windows port without an emulation core.
This repository contains no game files. You need your own ROMs.

| | |
|---|---|
| Board | MMC1 (mapper 1), 8 x 16 KB PRG (banks 0-6 switchable at `$8000`, bank 7 fixed at `$C000`), 128 KB CHR-ROM, NES 2.0 header |
| Code found so far | about 34 KB in 718 routines (per version), all bytes of every executed instruction plus code reached statically from it |
| Data | everything else (`.incbin` of files extracted from your ROM into `assets/`, git-ignored) |
| Byte identity | `python tools/build.py` prints `MATCH` for both versions |
| Native build | `recomp/build_native.ps1` statically recompiles the classified code to C with [NESRecomp](https://github.com/mstan/nesrecomp) (about 99.8 % of cycles native in a 600-frame boot test) |

The ByteMatch report counts **byte-exact assembly source**: decoded instructions and `.incbin` data both count as matching, so the numbers start at 100 %.
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
Everything not found is data. Bank 0 and large parts of banks 1-6 are still data, because blind play never reached those scenes.
