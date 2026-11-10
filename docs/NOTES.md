# Notes

## Hardware and banking
- MMC1, PRG mode 3: 16 KB switchable window at `$8000`, last bank fixed at `$C000`. The game keeps shadow copies of the four MMC1 registers in zero page and writes them with routines in the fixed bank:

| Shadow | RAM | Writer | Register |
|---|---|---|---|
| `MmcControlShadow` | `$F8` | `MmcWriteControl` `$C554` | control (`$8000-$9FFF`) |
| `MmcChr0Shadow` | `$F9` | `MmcWriteChr0` `$C56A` | CHR bank 0 (`$A000`) |
| `MmcChr1Shadow` | `$FA` | `MmcWriteChr1` `$C580` | CHR bank 1 (`$C000`) |
| `MmcPrgShadow` | `$FB` | `MmcWritePrg` `$C596` | PRG bank (`$E000`) |

- Every switchable bank starts with the same reset stub (`sei / lda #$80 / sta $BFFD / jmp $C000`) at `$8000`. The fixed-bank NMI handler calls `MmcWritePrg` and then jumps to **`$8010`** of the bank in `MmcPrgShadow`: `$8010` is each bank's per-frame NMI routine.
- Scene logic is a state machine: `SceneState` (`$0500`) indexes a pointer table through `jmp ($0000)`; `SceneTimer` (`$0526`) counts frames until the next state.

## Fixed-bank helpers (bank 7)
`ApplyScroll`, `SetPpuCtrl`/`SetPpuMask` (shadows `$FF`/`$FE`), `DoOamDma`, `UploadPalette` (buffer `$0140`), `EnqueueByte` (queue at `$06E0`), `GetRandomByte` (index `$0108` into a 32-byte table), `ReadJoypads` (`JoyHeld1` `$010B`, `JoyNew1` `$010D`), `BinToDecimal`, `TickClock` (`$10-$12`), `DrawObjects` (objects at `$0310`, 16 bytes each, count `$0301`).

## Versions
The Japanese ROM is the original release. Bank 7 differs by 201 bytes, banks 3-5 carry most of the text and scene differences, CHR differs by about 10 KB. `tools/g13dis.py --version jp` inherits the US coverage wherever the instruction bytes are identical, and `config/jp/names.json` only keeps names whose code is identical in both.

## Growing coverage
1. Build NESRecomp's cycle host **without** a seed file (`recomp/build_native.ps1` writes seeds; for exploring use the project in `tools/nesrecomp/runner/cyc/project` with a `game.toml` that has no `cycle_seed_file`).
2. `tools/run_routes.sh us path/to/nes_game.exe 1000 60000 11` runs 11 biased random input routes and merges the executed opcodes into `config/us/coverage.json`.
3. `python tools/g13dis.py --version us && python tools/build.py --version us`.

Blind routes plateau at about 9.8K opcodes (first scenes of the acts). Directed routes (or hand-written input scripts that play through each act) are needed for the rest. Do not mutate game RAM to force scenes: executing garbage would record bogus code.

## Open work
- Directed play for deeper coverage (banks 0, 1, 4, 6 especially), then re-run the classifier.
- Names: RAM variables (object fields, enemy state, inventory), scene routines, per-bank state tables.
- Structured data: text (kana/Latin), map/scroll data, palettes, pointer tables.
