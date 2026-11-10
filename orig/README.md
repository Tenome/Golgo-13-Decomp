# Original ROMs (not in this repository)

Place your own dumps here. The tools read them to extract data (`assets/`) and to verify the rebuilt ROM.

| Version | File | Size | Notes |
|---|---|---|---|
| us | `golgo13_us.nes` | 262,160 bytes | Golgo 13: Top Secret Episode (USA), iNES/NES 2.0 header, MMC1, 128 KB PRG + 128 KB CHR |
| jp | `golgo13_jp.nes` | 262,160 bytes | Golgo 13: Daiisshou - Kamigami no Tasogare (Japan), same layout |

SHA-1 of the ROM that `python tools/build.py` must reproduce:

| Version | SHA-1 |
|---|---|
| us | `9d3d822d51cc4582cf742fe70ccc181b23890447` |
| jp | `40f3232a261d5706ce83900b56d372ede41a1c0b` |
