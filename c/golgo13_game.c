/* Readable C for game-logic routines of the fixed bank (second file of hand-written routines, after c/golgo13.c).
 * Each function has the same effect as the original 6502 routine on RAM, on the PPU/APU/mapper writes and on the registers it returns;
 * tools/difftest.py checks that on thousands of random states. Names are the labels of config/<ver>/names.json. */
#include "golgo13.h"

#define RAM(a) g_ram[(a) & 0x7FF]
#define ZP(a) g_ram[(a) & 0xFF]                         /* zero page indexing wraps inside page 0 */
#define PTR(lo, hi, y) RAM((((unsigned)(hi) << 8) | (lo)) + (y))   /* ($lo),y with a pointer held in two RAM bytes */

/* sprite buffer (sent to the PPU by DoOamDma): 4 bytes per sprite, Y / tile / attributes / X */
#define OAM(i) RAM(0x0200 + (i))
#define OAM_Y(i) OAM(i)
#define OAM_FLAGS(i) OAM((i) + 2)
#define OAM_X(i) OAM((i) + 3)
#define SPRITE_HIDDEN 0xF0

/* named RAM (config/<ver>/ram.json) */
#define Tmp00 RAM(0x00)
#define Tmp01 RAM(0x01)
#define Tmp02 RAM(0x02)
#define Tmp03 RAM(0x03)
#define FrameCounter RAM(0x10)
#define PaletteSetIndex RAM(0x17)
#define ScrollX RAM(0x19)
#define ScrollY RAM(0x1A)
#define GameState RAM(0x14)
#define AreaGroup RAM(0x16)
#define PlayerScreenSide RAM(0x32)
#define TransitionTarget RAM(0x29)
#define PaletteDirty RAM(0x35)
#define PlayerLifeLo RAM(0x38)
#define PlayerLifeHi RAM(0x39)
#define AmmoLo RAM(0x3A)
#define AmmoHi RAM(0x3B)
#define MmcPrgShadow RAM(0xFB)
#define ObjectCount RAM(0x0301)
#define PlayerSpriteX0 RAM(0x023B)

static inline uint8_t rol8(uint8_t a, uint8_t *c) { uint8_t out = a >> 7; a = (uint8_t)((a << 1) | *c); *c = out; return a; }

/* $D308: write "sprite hidden" (Y = $F0) through the pointer Tmp02/Tmp03 until its low byte reaches the object's limit ($0313 + X) */
Regs HideObjectSpriteRange(Regs r) {
    uint8_t limit = RAM(0x0313 + r.x);
    do { PTR(Tmp02, Tmp03, 0) = SPRITE_HIDDEN; Tmp02++; } while (Tmp02 < limit);
    r.a = Tmp02; r.y = 0; r.c = 1; return r;
}

/* $D318: the same through the pointer $04/$05 up to low byte $E0 */
Regs HideSpritesUntilE0(Regs r) {
    do { PTR(RAM(0x04), RAM(0x05), 0) = SPRITE_HIDDEN; RAM(0x04)++; } while (RAM(0x04) < 0xE0);
    r.a = RAM(0x04); r.y = 0; r.c = 1; return r;
}

/* The three bullet movers walk a range of sprites. A bullet is alive while its Y is below $E8; it moves sideways every frame
 * (direction from the horizontal-flip bit of its attributes) and is hidden once it leaves the screen. */
void MoveBulletsRight8(void) {                   /* $F698: sprites $4C-$5B, always +8 */
    for (unsigned i = 0x4C; i < 0x5C; i += 4) {
        if (OAM_Y(i) >= 0xE8) continue;
        OAM_X(i) = (uint8_t)(OAM_X(i) + 8);
        if (OAM_X(i) >= 0xF6) OAM_Y(i) = SPRITE_HIDDEN;
    }
}
void MoveBulletsSide6(void) {                    /* $F634: sprites $58-$67, +6 or -6 */
    for (unsigned i = 0x58; i < 0x68; i += 4) {
        if (OAM_Y(i) >= 0xE8) continue;
        OAM_X(i) = (uint8_t)(OAM_X(i) + ((OAM_FLAGS(i) & 0x40) ? 0xFA : 0x06));
        if (OAM_X(i) >= 0xF6) OAM_Y(i) = SPRITE_HIDDEN;
    }
}
void MoveBulletsSide4(void) {                    /* $F664: sprites $54-$5B, +4 or -4, hidden outside 8..$EF */
    for (unsigned i = 0x54; i < 0x5C; i += 4) {
        if (OAM_Y(i) >= 0xE8) continue;
        OAM_X(i) = (uint8_t)(OAM_X(i) + ((OAM_FLAGS(i) & 0x40) ? 0xFC : 0x04));
        if (OAM_X(i) < 0x08 || OAM_X(i) >= 0xF0) OAM_Y(i) = SPRITE_HIDDEN;
    }
}

/* $CCD3: AreaGroup = 0 for areas $00-$11, 1 for $12-$2F, 2 for $30-$3F, 3 from $40 on */
void ComputeAreaGroup(void) {
    uint8_t area = PaletteSetIndex;
    AreaGroup = area < 0x12 ? 0 : area < 0x30 ? 1 : area < 0x40 ? 2 : 3;
}

/* $F606: 0 = the player stands at screen X $78 (the scroll centre), 1 = left of it, 2 = right of it */
void SetPlayerScreenSide(void) {
    PlayerScreenSide = PlayerSpriteX0 == 0x78 ? 0 : PlayerSpriteX0 < 0x78 ? 1 : 2;
}

/* $FEA7 / $FEC1: $0107 holds a step number; the table at $FE8C lists step numbers, move to the next / previous one ($FF = end of list) */
#define SEQUENCE_TABLE 0xFE8C
void StepSequenceForward(void) {
    unsigned x = 0; while (ROMB(SEQUENCE_TABLE + x) != RAM(0x0107)) x += 2;
    uint8_t next = ROMB(SEQUENCE_TABLE + 2 + x);
    if (next != 0xFF) RAM(0x0107) = next;
}
void StepSequenceBackward(void) {
    unsigned x = 0; while (ROMB(SEQUENCE_TABLE + x) != RAM(0x0107)) x += 2;
    if (x != 0) RAM(0x0107) = ROMB(SEQUENCE_TABLE - 2 + x);
}

/* $DDD0: a scene change request is finished: load the target area and start the level state */
void FinishTransition(void) {
    PaletteSetIndex = TransitionTarget; PaletteDirty = 0; GameState = 0x10; MmcPrgShadow = 2;
}
/* $DF02 */
void EndGameOverSequence(void) {
    GameState = 0; RAM(0x1B) = 0; PaletteDirty = 0; RAM(0x0139) = 0; TransitionTarget = 0x1F;
}
/* $E079: tile $FD in the 15 sprites after the first one (blank tiles) */
void InitEndScreenSprites(void) {
    for (unsigned i = 0; i < 0x3C; i += 4) OAM(5 + i) = 0xFD;
}
/* $E042: after the first $30 frames of a transition the player gains 10 life on every 8th frame (at most 200) */
void HealPlayerDuringTransition(void) {
    if (TransitionTarget < 0x30 || (FrameCounter & 7)) return;
    PlayerLifeLo = (uint8_t)(PlayerLifeLo + 10);
    if (PlayerLifeLo >= 200) PlayerLifeLo = 200;
}
/* $E85E: restart after a death: full life, ammo halved (but at least 10 unless the target is the game over scene) */
void ResetPlayerForRetry(void) {
    PlayerLifeLo = 200; PlayerLifeHi = 0;
    uint8_t carry = AmmoHi & 1; AmmoHi = 0;
    AmmoLo = (uint8_t)((AmmoLo >> 1) | (carry << 7));
    if (AmmoLo < 10 && TransitionTarget != 0x77) AmmoLo = 10;
}
/* $E916: two life thresholds with hysteresis: below 50 life the low-life tune starts (sound $42), back at 50 it stops (sound $44) */
void UpdateLowLifeAlarm(void) {
    uint8_t x, sound;
    if (RAM(0x0117) == 0) { if (PlayerLifeLo >= 0x32) return; x = 1; sound = 0x42; }
    else                  { if (PlayerLifeLo <  0x32) return; x = 0; sound = 0x44; }
    RAM(0x0117) = x;
    Regs q = {sound, x, 0, 0}; QueueSound(q);
}

/* $C43D: delete the object at Tmp00/Tmp01 from the object table by sliding every later entry down by 16 bytes and clearing the last one */
void RemoveObject(void) {
    uint8_t entry = Tmp00;
    Tmp02 = entry; RAM(0x04) = (uint8_t)(entry + 0x10); Tmp03 = 3; RAM(0x05) = 3;
    uint8_t bytes_after = (uint8_t)((ObjectCount << 4) - entry);   /* bytes from the next entry to the end of the table */
    unsigned y;
    if (bytes_after == 0) { RAM(0x04) = Tmp02; y = 0x0F; }          /* removing the last one: just clear it */
    else {
        unsigned n = bytes_after; y = 0;
        do { PTR(Tmp02, Tmp03, y) = PTR(RAM(0x04), RAM(0x05), y); y++; } while (--n & 0xFF);
        y = (y - 1) & 0xFF;
    }
    for (unsigned n = 0x10; n; n--, y = (y - 1) & 0xFF) PTR(RAM(0x04), RAM(0x05), y) = 0;
    ObjectCount--; Tmp00 = (uint8_t)(Tmp00 - 0x10);
}

/* $C4C8: pixel position (Tmp03 = X, Tmp02 = Y) -> nametable address Tmp01:Tmp00 with the scroll applied (carries as on the 6502) */
void PixelToNametableAddr(void) {
    uint8_t c, a;
    Tmp00 = (uint8_t)((uint8_t)(Tmp03 + ScrollX) >> 3);
    uint8_t y = (uint8_t)(Tmp02 + ScrollY);
    unsigned s = (unsigned)(((y & 0x38) << 2) & 0xFF) + Tmp00; Tmp00 = (uint8_t)s; c = s > 0xFF;
    a = y & 0xC0; a = rol8(a, &c); a = rol8(a, &c); a = rol8(a, &c);
    Tmp01 = (uint8_t)(a + 0x20 + c);
}

/* Three pointer-advance helpers: a byte holds a packed (row, column) offset that is added to a 16-bit pointer in zero page (+X).
 * The source byte is read twice, like the original does: with odd X the pointer overlaps the source and the first addition changes it. */
enum { OFFSET_RRRCCCCC, OFFSET_HHHHLLLL, OFFSET_HHHLLLLL };
static uint8_t offset_high(unsigned mode, uint8_t v) { return mode == OFFSET_RRRCCCCC ? (uint8_t)(v >> 5) : mode == OFFSET_HHHHLLLL ? (uint8_t)(v >> 4) : (uint8_t)((v & 0xE0) >> 5); }
static uint8_t offset_low(unsigned mode, uint8_t v)  { return mode == OFFSET_RRRCCCCC ? (uint8_t)(v << 3) : mode == OFFSET_HHHHLLLL ? (uint8_t)((v & 0x0F) << 4) : (uint8_t)((v & 0x1F) << 3); }
static Regs add_to_pointer(Regs r, unsigned mode, unsigned source, unsigned lo_zp, unsigned hi_zp) {
    ZP(hi_zp + r.x) = (uint8_t)(ZP(hi_zp + r.x) + offset_high(mode, RAM(source)));
    unsigned s = (unsigned)ZP(lo_zp + r.x) + offset_low(mode, RAM(source)); ZP(lo_zp + r.x) = (uint8_t)s;
    if (s > 0xFF) ZP(hi_zp + r.x)++;
    r.a = ZP(lo_zp + r.x); r.c = s > 0xFF; return r;
}
Regs AddTileOffsetToPtr20(Regs r)   { return add_to_pointer(r, OFFSET_RRRCCCCC, r.y, 0x20, 0x21); }        /* $C761: byte = RRRCCCCC -> pointer $20/$21 += (RRR << 8) | (CCCCC << 3) */
Regs AddNibbleOffsetToPtr(Regs r)   { return add_to_pointer(r, OFFSET_HHHHLLLL, r.y, 0x02, 0x03); }        /* $CF84: byte = HHHHLLLL -> pointer Tmp02/Tmp03 += (HHHH << 8) | (LLLL << 4) */
Regs AddPackedOffsetToPtr20(Regs r) { return add_to_pointer(r, OFFSET_HHHLLLLL, 0x06 + r.y, 0x20, 0x21); } /* $CFA3: byte at $06+Y = HHHLLLLL -> pointer $20/$21 += (HHH << 8) | (LLLLL << 3) */

/* ---- HUD ---- */
#define PlayerPose RAM(0x36)
#define PlayerSpriteFrame RAM(0x37)
#define PlayerActionState RAM(0x30)
#define PlayerActionTimer RAM(0x31)
#define FloorProbeValid RAM(0x3E)
#define FloorProbeAddrLo RAM(0x40)
#define FloorProbeAddrHi RAM(0x41)
#define PlayerSpriteY0 RAM(0x0238)

/* The life and ammo counters are drawn on alternate frames (life on even, ammo on odd), except in game state 7. In the scene states
 * $10-$2F the sprites sit lower on the screen (index $10 / $30 instead of $00 / $20). */
static int hud_is_lowered(void) { return GameState >= 0x10 && GameState < 0x30; }
void DrawLifeHud(void) {                         /* $C941 */
    InitHudSprites((Regs){GameState, hud_is_lowered() ? 0x10 : 0x00, 0x00, 0});
    Tmp03 = PlayerLifeLo; RAM(0x04) = PlayerLifeHi;
    DrawHudNumber((Regs){0, 0x00, 0, 0});
}
void DrawAmmoHud(void) {                         /* $C962 */
    InitHudSprites((Regs){GameState, hud_is_lowered() ? 0x30 : 0x20, 0x10, 0});
    Tmp03 = AmmoLo; RAM(0x04) = AmmoHi;
    DrawHudNumber((Regs){0, 0x10, 0, 0});
}
void DrawHud(void) {                             /* $C929 */
    if (GameState == 0x07) return;
    if (FrameCounter & 1) DrawAmmoHud(); else DrawLifeHud();
}

/* $F2DA: remember the nametable cell under the player's feet (7 pixels right of the sprite origin, 47 below it) for ReadFloorProbeTile */
void SetupFloorProbeSideView(void) {
    FloorProbeValid = 1;
    Tmp02 = (uint8_t)(PlayerSpriteY0 + 0x2F); Tmp03 = (uint8_t)(PlayerSpriteX0 + 0x07);
    PixelToNametableAddr();
    FloorProbeAddrLo = Tmp00; FloorProbeAddrHi = Tmp01;
}

/* ---- player ---- */
/* $D5BD / $D5C5: player action state 3 hands over to the scene code of bank 3 (dialogue / briefing) */
void PlayerActionState3(void) {
    RAM(0x0400) = ROMB(0xF77B + PlayerPose);
    RAM(0x5C) = 0x8C; RAM(0x5D) = 0x02; RAM(0x0402) = 0x02;
    RAM(0x0410) = 0; RAM(0x0403) = 0;
    MmcPrgShadow = 3; MmcWritePrg((Regs){0x03, PlayerPose, 0, 0});
    PlayerActionState++;
}
/* $D5E2: player action state 4 chooses the next state from a flag table: 8 when neither flag bit is set, 6 when both are, else 5 with a sound */
void PlayerActionState4(void) {
    uint8_t flags = ROMB(0xF77A + PlayerPose) & 0x0C;
    if (flags == 0) PlayerActionState = 8;
    else if (flags == 0x0C) PlayerActionState = 6;
    else { QueueSound((Regs){0x0F, PlayerPose, 0, 0}); PlayerActionState = 5; }
    PlayerActionTimer = 0;
}
/* $EF7B: sprite frame = 12 when facing left, + the pose's frame offset, + a walk cycle step from the frame counter (0, 1, 2, 1) */
void SelectPlayerSpriteFrame(void) {
    uint8_t frame = (PlayerPose & 0x10) ? 0x0C : 0;
    frame = (uint8_t)(frame + ROMB(0xEFA5 + (PlayerPose & 3)));
    uint8_t step = (FrameCounter & 0x30) >> 4;
    PlayerSpriteFrame = (uint8_t)(frame + (step == 3 ? 1 : step));
}

