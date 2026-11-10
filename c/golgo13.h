/* Hand-lifted routines (c/golgo13.c): readable C versions of single routines, differential-tested by tools/difftest.py. */
#pragma once
#include "core.h"

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
