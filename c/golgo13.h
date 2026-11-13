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
Regs QueueSound(Regs r);      /* $C22C */
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
Regs UpdatePlayerFacing(Regs r);   /* $EAB6 */
Regs SetPlayerPose(Regs r);   /* $EAAA */
Regs AdjustAmmo(Regs r);       /* $EEB7 */
Regs UseAmmo(Regs r);          /* $EACF */
Regs ClearObjectStatusBits(Regs r); /* $FBE0 */
Regs UpdateLifeBlink(Regs r);  /* $FBFE */

/* ---- game logic (c/golgo13_game.c) ---- */
Regs HideObjectSpriteRange(Regs r);  /* $D308 */
Regs HideSpritesUntilE0(Regs r);     /* $D318 */
void MoveBulletsRight8(void);        /* $F698 */
void MoveBulletsSide6(void);         /* $F634 */
void MoveBulletsSide4(void);         /* $F664 */
void ComputeAreaGroup(void);         /* $CCD3 */
void SetPlayerScreenSide(void);      /* $F606 */
void StepSequenceForward(void);      /* $FEA7 */
void StepSequenceBackward(void);     /* $FEC1 */
void FinishTransition(void);         /* $DDD0 */
void EndGameOverSequence(void);      /* $DF02 */
void InitEndScreenSprites(void);     /* $E079 */
void HealPlayerDuringTransition(void); /* $E042 */
void ResetPlayerForRetry(void);      /* $E85E */
void UpdateLowLifeAlarm(void);       /* $E916 */
void RemoveObject(void);             /* $C43D */
void PixelToNametableAddr(void);     /* $C4C8 */
Regs AddTileOffsetToPtr20(Regs r);   /* $C761 */
Regs AddNibbleOffsetToPtr(Regs r);   /* $CF84 */
Regs AddPackedOffsetToPtr20(Regs r); /* $CFA3 */
void DrawLifeHud(void);              /* $C941 */
void DrawAmmoHud(void);              /* $C962 */
void DrawHud(void);                  /* $C929 */
void SetupFloorProbeSideView(void);  /* $F2DA */
void PlayerActionState3(void);       /* $D5BD */
void PlayerActionState4(void);       /* $D5E2 */
void SelectPlayerSpriteFrame(void);  /* $EF7B */
void SetBulletHitbox1(void);         /* $FC62 */
void SetBulletHitbox2(void);         /* $FCBD */
void SelectEndScreenPhase(void);     /* $E018 */
void StartPlayerFallIfNoFloor(void); /* $EA02 */
void AdvancePlayerPoseTimer(void);   /* $EA2D */
void HandleFireButton(Regs r);       /* $EA61 */
void MovePlayerOnScreenSide(void);   /* $D0AB */
void UpdatePlayerWalkInput(void);    /* $EF2D */
void UpdatePlayerShootPose(void);    /* $EAD9 */
void SpawnBulletSprite(void);        /* $EEC9 */
void SelectPlayerWalkFrame(void);    /* $EB2F */
void UpdatePlayerJumpArc(void);      /* $E971 */
void MovePlayerVertical(void);       /* $F39E */

