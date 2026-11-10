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

## Bank roles (from screenshots of save states grouped by `MmcPrgShadow`)
| Bank | Seen running | Notes |
|---|---|---|
| 0 | street gameplay | data bank: `MmcPrgShadow = 0` makes the NMI run the fixed-bank main code (`Loc_C0E3`) instead of `$8010` |
| 1 | game-over screen ('The man with the custom M-16') | also object/enemy routines for the street scene |
| 2 | sniper-scope scenes | palette tables read by `LoadPaletteSet` |
| 3 | dialogue and briefing scenes | portrait text boxes |
| 4, 6 | not identified | classified code comes mostly from static descent |
| 5 | Vic Tokai logo, intro, title, act cards, 'To be continued' | also holds the sound driver `SoundDriver` at `$A000` (run every frame through `RunSoundDriver`; commands queued with `QueueSound` in `SoundQueue` at `$06E0`) |
| 7 | always | reset, NMI, helpers, street-scene gameplay loop |

## Fixed-bank helpers (bank 7)
`ApplyScroll`, `SetPpuCtrl`/`SetPpuMask` (shadows `$FF`/`$FE`), `DoOamDma`, `UploadPalette` (buffer `$0140`), `QueueSound` (queue at `$06E0`), `GetRandomByte` (index `$0108` into a 32-byte table), `ReadJoypads` (`JoyHeld1` `$010B`, `JoyNew1` `$010D`), `BinToDecimal`, `TickClock` (`$10-$12`), `DrawObjects` (objects at `$0310`, 16 bytes each, count `$0301`).

## Versions
The Japanese ROM is the original release. Bank 7 differs by 201 bytes, banks 3-5 carry most of the text and scene differences, CHR differs by about 10 KB. `tools/g13dis.py --version jp` inherits the US coverage wherever the instruction bytes are identical, and `config/jp/names.json` only keeps names whose code is identical in both.

## Growing coverage
1. Build NESRecomp's cycle host **without** a seed file (`recomp/build_native.ps1` writes seeds; for exploring use the project in `tools/nesrecomp/runner/cyc/project` with a `game.toml` that has no `cycle_seed_file`).
2. `tools/run_routes.sh us path/to/nes_game.exe 1000 60000 11` runs 11 biased random input routes and merges the executed opcodes into `config/us/coverage.json`.
3. `python tools/g13dis.py --version us && python tools/build.py --version us`.

Blind routes plateau at about 9.8K opcodes (first scenes of the acts). Directed routes (or hand-written input scripts that play through each act) are needed for the rest. Do not mutate game RAM to force scenes: executing garbage would record bogus code.

## Coverage search result (2026-11-09)
`tools/goexplore.py` branches from save states on the seeded headless native build and treats any ROM instruction the recompiler had not compiled (`--miss-log`) as new code. Starting from 89 states taken along eight 20,000-frame random routes, with a QA assist that keeps life (`PlayerLifeLo` `$38`) and ammo (`AmmoLo` `$3A`) up (data-only holds, the game's code is untouched), 1,289 branch runs of 300-1,200 frames found **no new opcodes**, in states spanning banks 1-6. The classified code is therefore probably most of what these scenes execute; the unclassified bytes (all of bank 0 and large parts of banks 1-6) look like scene scripts, text and graphics data. Later acts and endings are still unvisited.

## Open work
- Reach the later acts (a scripted play-through, or a memory-searched act selector) and re-run the classifier.
- Names: RAM variables (object fields, enemy state, inventory), scene routines, per-bank state tables.
- Structured data: text (kana/Latin), map/scroll data, palettes, pointer tables.

## Native build check
`recomp/build_native.ps1` produces `build/native/<ver>/golgo13-<ver>.exe` (SDL window). `tools/native_check.sh <ver> <seed> <frames>` runs it and NESRecomp's own interpreter on the same random input route and compares the per-frame hashes (CPU trace, memory, picture, registers, hardware state).
Result on 2026-11-09: 8 US and 8 JP routes of 20,000 frames plus a 9,000-frame route: all identical to the interpreter. US runs 0 interpreted ROM cycles; JP interprets about 10 ROM cycles (a few unclassified instructions) and both versions interpret the RAM routine the game copies into RAM (about 0.0 %). The routes show the intro, story text (English and Japanese), act 1 gameplay and the title/game-over screens.

## C lifting
Two layers, both checked against the original 6502 code on random states:

1. **Mechanical lift** (`tools/lift.py`, output `c/auto/<ver>/`): every routine found by the classifier becomes a C function that works on the global CPU model `R` (`c/auto/runtime.c`): one or two statements per instruction, branches as gotos, JSR as a call that also pushes/pops the return address so stack-reading code sees what the hardware would. Special cases the classifier now knows about: `ProcessPpuUpdateList` takes an inline data pointer after its JSR, `Sub_B5_A464` dispatches through an inline table of code addresses, `lda #hi / pha / lda #lo / pha / jmp (ptr)` is a call through a pointer, and overlapping decodes (a `BIT` used to skip two bytes) are lifted as real code.
   `tools/autotest.py` runs every lifted routine and the original on random RAM, registers and flags (the routine's own bank mapped at `$8000`) and compares RAM, A X Y, flags, SP, the log of PPU/APU/mapper writes and the MMC1 bank; on a mismatch it prints the first diverging instruction. Result (100 random states per routine): US 639 of 696 routines verified, 0 failed, 57 not testable on random input (loops that never end, stack tampering); JP 615 of 683 verified, 0 failed, 68 not testable. Every classified routine is lifted.
2. **Readable C** (`c/golgo13.c`, tests in `tools/difftest.py`): hand-written versions of single routines with names and structure (37 so far). They use the same state (`g_ram`, `io_write`, `g_bank`) as the mechanical layer, so a readable function can replace its mechanical twin once `tools/difftest.py` passes.

Run: `python tools/lift.py --version us && python tools/autotest.py --version us` and `python tools/difftest.py --version us` (needs clang or gcc: `--clang PATH`).

### Whole-program check (`tools/frametest.py`, `tools/frameloop.sh`)
Runs the lifted C and the 6502 simulator from power-on, frame by frame: Reset first, then one call of the NMI handler per frame, with the same controller input (a random pad that changes every few frames, shifted out through `$4016`) and the same `$2002` pattern on both sides. After every frame it compares CPU RAM (except the stack page), the log of PPU/APU/mapper writes and the PRG bank.
Result: **US 12,000 frames and JP 4,000 frames from power-on identical on every compared value.**
Hole finder: whenever the C reaches an address with no lifted routine, the simulator has executed it, so `frameloop.sh` merges that code into `config/<ver>/coverage.json` (ROM code), `config/<ver>/entries.json` (routine entries reached through computed jumps) or `config/<ver>/ramcode.json` (instructions executed from RAM: the game builds small stubs at `$0005`, `$0513`, `$051E`, `$0520`, `$0568`, `$05B8`), regenerates the sources and the C and runs again. RAM stubs are lifted per observed variant and selected at call time by comparing the RAM bytes.
Stack idioms the lifted code reproduces: inline arguments after a JSR, `pha / pha / rts` jumps, `pla / pla` returns past the caller, tables of code addresses after a JSR, and a JMP whose fake return address was pushed first.

## Gameplay notes (street scenes, fixed bank)
- `GameState` (`$14`) is the main state: 0 init (`InitLevel`), 1 auto-walk (`StateAutoWalk`), 2 scene change, 3-5 variants that hand over to bank 6, 6 end screen, 7 and up the street gameplay handled by `UpdatePlayerAction`.
- Player: `PlayerActionState` (`$30`) with `PlayerActionTimer` (`$31`) is a small state machine (`UpdatePlayerAction`, states `PlayerActionIdle`, `PlayerActionState1-7`); `PlayerPose` (`$36`) is an index into the pose tables (low nibble pose, bit 4 = facing left, set by `UpdatePlayerFacing`); `PlayerSpriteFrame` (`$37`) picks the 19-sprite OAM block `CopyPlayerSprites` copies to `PlayerSpriteY0` (`$0238`); life is `PlayerLifeLo/Hi` (`$38/$39`, 200 at start), ammo `AmmoLo/Hi` (`$3A/$3B`), `HurtTimer` (`$0114`) makes the life digits blink. `StageIndex` (`$0100`) counts the stages.
- Controller bits (JoyHeld1 `$010B`, JoyNew1 `$010D`): A=$01 B=$02 Select=$04 Start=$08 Up=$10 Down=$20 Left=$40 Right=$80; `hardware.inc` defines `JOY_*`.
- Objects (enemies, items) live at `$0310`, 16 bytes each (count `ObjectCount` `$0301`); `DrawObject` / `RemoveObject` / `TickObjectStates` work on that table.

## Native port from the lifted C (`c/port/`, `tools/build_port.py`)
The mechanically lifted game logic (`tools/lift.py --cycles`, nominal 6502 cycle counts per instruction) runs as plain C on top of a small host:
- `c/port/port.c`: machine state and I/O hooks (`io_read` / `io_write`), MMC1 (PRG/CHR banks, mirroring), a lazily caught-up PPU (scanline renderer with loopy scroll registers, so mid-frame scroll writes and sprite-0 hits work), OAM DMA, joypad shift register, NMI delivery at loop heads (`port_poll`, the same places the lifted code checks its loop budget).
- `c/port/apu.c`: two pulse channels, triangle and noise (no DMC), one frame of samples per picture.
- `c/port/main.c` headless driver (`--frames N --input route --out DIR --shot-every N --wav FILE`), `c/port/sdl_main.c` windowed player (`golgo13_play`, keys: arrows, Z = A, X = B, Enter = Start, Right Shift = Select, Esc = quit; gamepad too).
Build: `python tools/build_port.py --version us [--sdl <SDL2 folder>]`, then `build/port/golgo13_port_us.exe orig/golgo13_us.nes --frames 3000 --input route.txt --out frames --shot-every 500` or `golgo13_play_us.exe orig/golgo13_us.nes`.
Checked so far: a 20,000-frame random-input route runs end to end on both versions and the pictures show the intro, briefing dialogue, street gameplay with HUD, the sniper scope, game over and title; the audio path produces non-silent output. The port is **not** a cycle-exact emulator: colours use a standard palette, DMC is missing, timing inside the NMI handler is approximate, and code reached through computed jumps is added to `config/<ver>/entries.json` / `ramcode.json` by `tools/portloop.sh` as it is found (`tools/learn_entry.py`, `tools/ramcode_from_capture.py`).
