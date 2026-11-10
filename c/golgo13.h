/* Golgo 13: routines lifted from 6502 assembly to C.
 * Each function mirrors one routine of src/<ver>/bank_N.asm and is differential-tested against the original code:
 * tools/difftest.py runs both on random CPU state and compares RAM, the result registers, the log of PPU/APU/mapper
 * register writes and the PRG bank selected by the MMC1 model. Function names equal the labels in config/<ver>/names.json. */
#pragma once
#include <stdint.h>

typedef struct { uint8_t a, x, y, c; } Regs;   /* register (and carry) inputs/outputs of a lifted routine */

extern uint8_t g_ram[0x800];                   /* CPU RAM ($0000-$07FF) */
extern const uint8_t *g_prg;                   /* 128 KB PRG-ROM (supplied by the host from the user's ROM) */
extern uint8_t g_bank;                         /* PRG bank mapped at $8000 (banks 0-6; bank 7 is fixed at $C000) */
#define ROMB(addr) ((addr) >= 0xC000 ? g_prg[7 * 0x4000 + ((addr) & 0x3FFF)] : g_prg[g_bank * 0x4000 + ((addr) & 0x3FFF)])

/* every write the original makes to $2000-$FFFF goes through io_write (PPU, APU, joypad strobe, MMC1) */
void io_write(uint16_t addr, uint8_t value);
#define IOLOG_MAX 8192
extern uint16_t g_iolog_addr[IOLOG_MAX];
extern uint8_t g_iolog_val[IOLOG_MAX];
extern int g_iolog_n;
uint8_t io_read(uint16_t addr);               /* PPU/APU/joypad register reads (0 in the tests) */
void iolog_reset(void);                        /* clears the log and the MMC1 shift register */

/* ---- fixed bank ($C000-$FFFF) ---- */
Regs AslA6(Regs r);  Regs AslA5(Regs r);  Regs AslA4(Regs r);  Regs AslA3(Regs r);     /* $C1EF-$C1F2 (entries into one run of ASL A) */
Regs LsrA6(Regs r);  Regs LsrA5(Regs r);  Regs LsrA4(Regs r);  Regs LsrA3(Regs r);     /* $C1F6-$C1F9 */
Regs SetPpuCtrl(Regs r);       /* $C1FD  A -> PpuCtrlShadow + $2000 */
Regs SetPpuMask(Regs r);       /* $C203  A -> PpuMaskShadow + $2001 */
Regs DoOamDma(Regs r);         /* $C1E4 */
void ApplyScroll(void);        /* $C196 */
Regs BinToDecimal(Regs r);     /* $C1A9  16-bit Tmp03/$04 -> digits Tmp02 (hundreds), Tmp01, Tmp00 */
Regs EnqueueByte(Regs r);      /* $C22C */
void TickClock(void);          /* $C23C */
Regs GetRandomByte(Regs r);    /* $C2A3 */
Regs MmcWriteControl(Regs r);  /* $C554 */
Regs MmcWriteChr0(Regs r);     /* $C56A */
Regs MmcWriteChr1(Regs r);     /* $C580 */
Regs MmcWriteChr1A(Regs r);    /* $C582 */
Regs MmcWritePrg(Regs r);      /* $C596 */
Regs SetPaletteAddr(Regs r);   /* $C270 */
Regs ResetPpuAddr(Regs r);     /* $C285  (Y = PPU high byte) */
Regs UploadPalette(Regs r);    /* $C25E  32 bytes of PaletteBuffer ($0140) -> $3F00 */
Regs FillPaletteBlack(Regs r); /* $C24E */
Regs ResetPpuScroll(Regs r);   /* $C209 */
Regs SetPpuAddrFromBuf(Regs r);/* $C21C */
Regs AnimatePalette(Regs r);   /* $DDE1 */
Regs HideEnemySprites(Regs r); /* $DC77 */
Regs CopyPlayerSprites(Regs r);/* $D3D3 */
Regs InitHudSprites(Regs r);   /* $C983 */
Regs DrawHudNumber(Regs r);    /* $C994 */
Regs UpdateFireMode(Regs r);   /* $EAB6 */
Regs SetFireModeLow(Regs r);   /* $EAAA */
Regs AdjustAmmo(Regs r);       /* $EEB7 */
Regs UseAmmo(Regs r);          /* $EACF */
Regs ClearObjectStatusBits(Regs r); /* $FBE0 */
Regs UpdateLifeBlink(Regs r);  /* $FBFE */
