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
static void enter_bank3_scene(uint8_t x) {       /* $D5C5: set up the dialogue scene of bank 3 and switch to it */
    RAM(0x5C) = 0x8C; RAM(0x5D) = 0x02; RAM(0x0402) = 0x02;
    RAM(0x0410) = 0; RAM(0x0403) = 0;
    MmcPrgShadow = 3; MmcWritePrg((Regs){0x03, x, 0, 0});
    PlayerActionState++;
}
void PlayerActionState3(void) {
    RAM(0x0400) = ROMB(0xF77B + PlayerPose);
    enter_bank3_scene(PlayerPose);
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

/* ---- bullets and end screen ---- */
/* A bullet hit record (5 bytes at $011E / $0123 ...): flag, Y, X, size, sprite number. The flag is 0 when the bullet is off screen
 * (Y >= $E8 or X >= $E0) so that nothing can be hit by it. Y and X are copied even when only the second test fails, like the original. */
static void bullet_hit_record(unsigned sprite_y_addr, unsigned record, uint8_t sprite_index, uint8_t flag_when_live) {
    uint8_t y = RAM(sprite_y_addr), flag = 0;
    if (y < 0xE8) {
        RAM(record + 1) = y; uint8_t x = RAM(sprite_y_addr + 3); RAM(record + 2) = x;
        if (x < 0xE0) { RAM(record + 3) = 0x14; RAM(record + 4) = sprite_index; flag = flag_when_live; }
    }
    RAM(record) = flag;
}
void SetBulletHitbox1(void) {                    /* $FC62: the bullets in sprites $4C and $50 */
    bullet_hit_record(0x024C, 0x011E, 0x4C, 0x40);
    bullet_hit_record(0x0250, 0x0123, 0x50, 0x20);
}
void SetBulletHitbox2(void) {                    /* $FCBD: the bullets in sprites $54 and $58 */
    bullet_hit_record(0x0254, 0x011E, 0x54, 0x40);
    bullet_hit_record(0x0258, 0x0123, 0x58, 0x20);
}
/* $E018: the end screen has six phases chosen from the transition counter (thresholds $20, $23, $26, $29, $2C); the phase picks a CHR bank */
void SelectEndScreenPhase(void) {
    uint8_t t = TransitionTarget;
    unsigned phase = t < 0x20 ? 0 : t < 0x23 ? 1 : t < 0x26 ? 2 : t < 0x29 ? 3 : t < 0x2C ? 4 : 5;
    RAM(0x0157) = ROMB(0xE03C + phase);
}

/* ---- player movement and shooting (street scenes) ---- */
#define JoyHeld1 RAM(0x010B)
#define JoyNew1 RAM(0x010D)
#define JOY_A 0x01
#define JOY_B 0x02
#define JOY_UP 0x10
#define JOY_DOWN 0x20
#define JOY_LEFT 0x40
#define JOY_RIGHT 0x80
#define MmcChr1Shadow RAM(0xFA)
#define FloorProbeTile RAM(0x3F)
#define ShootPoseActive RAM(0x33)                /* 1 while the shooting pose is held */
#define ShootPoseTimer RAM(0x34)
#define WeaponEquipped RAM(0x3C)
enum { POSE_STAND = 0, POSE_WALK = 1, POSE_UP = 2, POSE_DOWN = 3, POSE_SHOOT = 4, POSE_AIM_LOW = 6 };   /* low nibble of PlayerPose; bit 4 = facing left */
static void set_pose(uint8_t pose) { SetPlayerPose((Regs){0, pose, 0, 0}); }

/* $EA02: on the ground and not already falling or jumping: B jumps, otherwise the player falls when the floor tile under the feet is
 * below the walkable range for the current CHR set. Both start action state 1 with the timer that drives the arc. */
void StartPlayerFallIfNoFloor(void) {
    if ((PlayerPose & 0x0F) >= POSE_DOWN) return;
    uint8_t timer;
    if (JoyNew1 & JOY_B) timer = 0;                                           /* jump */
    else { if (FloorProbeTile >= ROMB(0xE961 + MmcChr1Shadow)) return; timer = 0x20; }   /* walked off an edge: start falling */
    PlayerActionTimer = timer; PlayerActionState = 1;
    set_pose(POSE_DOWN);
}

/* $EA2D: the shooting pose ends after a number of frames that depends on the pose (aiming poses 4 and 6: 32 frames, others: 224) */
void AdvancePlayerPoseTimer(void) {
    ShootPoseTimer++;
    uint8_t pose = PlayerPose & 0x0F, next;
    if (pose == POSE_SHOOT)         { if (ShootPoseTimer < 0x20) return; next = POSE_DOWN; }
    else if (pose == POSE_AIM_LOW)  { if (ShootPoseTimer < 0x20) return; next = POSE_STAND; }
    else                            { if (ShootPoseTimer < 0xE0) return; next = POSE_STAND; }
    set_pose(next); ShootPoseActive = 0;
}

/* $EA61: A fires. With a weapon and ammo the pose depends on the current one; without, a standing player crouches (action state 1,
 * 24 pixels lower). The register X on entry is used unchanged for poses above 3, like in the original. */
void HandleFireButton(Regs r) {
    if (!(JoyNew1 & JOY_A)) return;
    uint8_t pose = PlayerPose & 0x0F, x;
    if (WeaponEquipped && (AmmoLo | AmmoHi)) {
        if (pose == POSE_DOWN) x = POSE_SHOOT; else if (pose > POSE_DOWN) x = r.x; else x = POSE_AIM_LOW;
    } else {
        if (pose == POSE_DOWN) x = POSE_SHOOT;
        else if (pose > POSE_DOWN) return;
        else { PlayerActionState = 1; PlayerActionTimer = 0x20; RAM(0x0238) = (uint8_t)(RAM(0x0238) - 0x18); x = POSE_SHOOT; }
    }
    set_pose(x); ShootPoseActive = 1; ShootPoseTimer = 0;
}

/* $D0AB: left / right movement of the player sprite while the screen does not scroll (PlayerScreenSide 1 = left half, 2 = right half) */
void MovePlayerOnScreenSide(void) {
    uint8_t x = PlayerSpriteX0, held = JoyHeld1 & (JOY_LEFT | JOY_RIGHT);
    if (PlayerScreenSide == 0 || held == 0) return;
    if (PlayerScreenSide == 1) {
        if (held == JOY_LEFT) { if (x >= 0x11) PlayerSpriteX0--; }
        else if (x < 0x78) PlayerSpriteX0++;
    } else {
        if (held == JOY_LEFT && x >= 0x79) PlayerSpriteX0--;
        else if (x < 0xE0) PlayerSpriteX0++;      /* (also when walking left below $79, like the original) */
    }
}

/* $EF2D: walking pose and vertical movement of the side view: stand, then walk when the stick points the way the player faces, otherwise
 * climb / descend poses from up / down, and finally move one pixel up or down */
void UpdatePlayerWalkInput(void) {
    if ((PlayerPose & 0x0F) == 0) UpdatePlayerFacing((Regs){0, 0, 0, 0});
    set_pose(POSE_STAND);
    int walking = (PlayerPose & 0x10) ? (JoyHeld1 & JOY_LEFT) : (JoyHeld1 & JOY_RIGHT);
    if (walking) set_pose(POSE_WALK);
    else {
        uint8_t vertical = JoyHeld1 & (JOY_UP | JOY_DOWN);
        if (vertical == JOY_UP) set_pose(POSE_UP); else if (vertical == JOY_DOWN) set_pose(POSE_DOWN);
    }
    uint8_t vertical = JoyHeld1 & (JOY_UP | JOY_DOWN);
    if (vertical == 0) return;
    if (vertical == JOY_UP) RAM(0x0238)--; else RAM(0x0238)++;
}

/* ---- more player code ---- */
#define PlayerSpriteY RAM(0x0238)

/* $EAD9: the standing / walking pose follows the left-right stick, the crouch pose follows down; every pose change may spend ammo
 * (UseAmmo only does so for X >= 6, so here it is a no-op that is kept for the register effects) */
void UpdatePlayerShootPose(void) {
    uint8_t pose = PlayerPose & 0x0F, sideways = JoyHeld1 & (JOY_LEFT | JOY_RIGHT);
    int facing_part = 1;
    if (pose == POSE_STAND) {
        if (sideways) { set_pose(POSE_WALK); UseAmmo((Regs){PlayerPose, POSE_WALK, 0, 0}); } else facing_part = 0;
    } else if (pose == POSE_WALK) {
        if (sideways) facing_part = 0; else { set_pose(POSE_STAND); UseAmmo((Regs){PlayerPose, POSE_STAND, 0, 0}); }
    }
    if (facing_part && (PlayerPose & 0x0F) < POSE_SHOOT) UpdatePlayerFacing((Regs){0, 0, 0, 0});
    pose = PlayerPose & 0x0F; uint8_t held = JoyHeld1;                       /* the vertical part: up / down poses */
    if (pose == POSE_UP) { if (held & JOY_DOWN) return; set_pose(POSE_STAND); UseAmmo((Regs){PlayerPose, POSE_STAND, 0, 0}); }
    else if (pose > POSE_UP) return;
    else { if (!(held & JOY_DOWN)) return; set_pose(POSE_UP); UseAmmo((Regs){PlayerPose, POSE_UP, 0, 0}); }
}

/* $EEC9: fire one bullet into a free sprite among $58-$67 (Y below $E8 = in use), 24 pixels ahead of the player, and use one round */
void SpawnBulletSprite(void) {
    if (AmmoLo == 0 && AmmoHi == 0) return;
    unsigned x = 0x58;
    while (OAM_Y(x) < 0xE8) { x += 4; if (x >= 0x68) return; }
    OAM_Y(x) = (uint8_t)(PlayerSpriteY + 3); OAM(x + 1) = 0xBE;
    uint8_t attr, dx;
    if (!(PlayerPose & 0x10)) { attr = 0x00; dx = 0x18; } else { attr = 0x40; dx = 0xF0; }
    OAM_X(x) = (uint8_t)(dx + PlayerSpriteX0); OAM_FLAGS(x) = attr;
    AdjustAmmo((Regs){0xFF, 0, 0, 0});
    QueueSound((Regs){0x0E, (uint8_t)x, 0, 0});
}

/* $EB2F: choose the sprite frame (PlayerSpriteFrame = facing bit | frame number) from the pose; the shooting poses also time the muzzle flash */
void SelectPlayerWalkFrame(void) {
    uint8_t pose = PlayerPose & 0x0F, frame;
    if (pose == POSE_STAND) frame = 7;
    else if (pose == POSE_WALK) { uint8_t t = (FrameCounter & 0x30) >> 4; frame = t == 2 ? 0 : t == 3 ? 2 : t; }
    else if (pose == POSE_UP) frame = 4;
    else if (pose == POSE_DOWN) frame = PlayerActionTimer < 8 ? 4 : 5;
    else if (pose == POSE_SHOOT) frame = 6;
    else if (pose == POSE_AIM_LOW) {
        uint8_t t = ShootPoseTimer;
        if (t == 8) { SpawnBulletSprite(); frame = 8; }
        else if (t < 8) frame = 7;
        else if (t < 0x10) frame = 8;
        else if (t < 0x18) frame = 9;
        else if (t < 0x20) frame = 8;
        else frame = 7;
    } else {
        ShootPoseTimer++; uint8_t t = ShootPoseTimer;
        if (t < 0x20) frame = 0;
        else if (t >= 0xE0) { set_pose(POSE_STAND); frame = 7; }
        else { uint8_t u = t & 0x1F; frame = u < 0x0A ? 0x0A : u < 0x16 ? 0x0B : 0x0C; }
    }
    Tmp02 = frame;                                       /* (the original leaves the frame number in Tmp02) */
    PlayerSpriteFrame = (uint8_t)((PlayerPose & 0x10) | frame);
}

/* $E971: the jump / fall arc: Y moves by a table value per frame (6 after $30 frames); in the first $18 frames releasing B ends the rise;
 * after that the player lands when the floor tile is solid and Down is not held in the upper half. */
void UpdatePlayerJumpArc(void) {
    uint8_t t = PlayerActionTimer, dy = ROMB(0xE9D2 + t);
    if (t >= 0x30) dy = 6;
    PlayerSpriteY = (uint8_t)(PlayerSpriteY + dy); PlayerActionTimer++;
    if (PlayerActionTimer < 0x18) { if (!(JoyHeld1 & JOY_B)) PlayerActionTimer = 0x18; }
    else if (FloorProbeTile >= ROMB(0xE961 + MmcChr1Shadow) && !(PlayerSpriteY < 0x90 && (JoyHeld1 & JOY_DOWN))) {
        PlayerActionState = 0; ShootPoseActive = 0; PlayerPose &= 0x10;
        PlayerSpriteY = (uint8_t)((PlayerSpriteY & 0xF0) | 0x02);
    }
    if ((PlayerPose & 0x0F) < POSE_SHOOT) UpdatePlayerFacing((Regs){0, 0, 0, 0});
}

/* $F39E: top-down view (bank 6 style scenes): Up / Down move the player in Y (Down twice as fast), Left / Right in X while the screen has
 * not reached the last page; then the four sprites of the crosshair body are placed around the player, flickering every other frame */
void MovePlayerVertical(void) {
    uint8_t held = JoyHeld1;
    if ((held & JOY_UP) && PlayerSpriteY >= 0x12) PlayerSpriteY--;
    if ((held & JOY_DOWN) && PlayerSpriteY < 0xC8) PlayerSpriteY += 2;
    if (RAM(0x18) < 0x0F) {
        if (held & JOY_LEFT) { if (PlayerSpriteX0 >= 0x18) PlayerSpriteX0 -= 2; }
        else if ((held & JOY_RIGHT) && PlayerSpriteX0 < 0xE0) PlayerSpriteX0++;
    }
    for (unsigned k = 0; k < 4; k++) {
        OAM(0x3C + 4 * k) = (uint8_t)(ROMB(0xF428 + 2 * k) + PlayerSpriteY);
        OAM(0x3C + 4 * k + 3) = (uint8_t)(ROMB(0xF428 + 2 * k + 1) + PlayerSpriteX0);
    }
    if (!(FrameCounter & 0x02)) {
        uint8_t old = RAM(0x0247), carry = old >= 0x0E; uint8_t v = (uint8_t)(old - 0x0E); RAM(0x0247) = v;
        RAM(0x024B) = (uint8_t)(v - 0x08 - (carry ? 0 : 1));
    }
}

/* $D3A4: standing still: after A is pressed (or while the timer runs) a 4-frame idle animation advances by time */
void PlayerActionIdle(void) {
    if (PlayerActionTimer == 0 && !(JoyHeld1 & JOY_A)) return;
    PlayerActionTimer++;
    uint8_t t = PlayerActionTimer;
    PlayerSpriteFrame = t < 0x0E ? 0 : t < 0x1C ? 1 : t < 0x2A ? 2 : 3;
}
/* $D6A4: player action state 6 (a cutscene pose): at the frames listed in a table of 6 pairs, 8 sprites of the scene are replaced
 * from another table; after 232 frames the next state starts */
void PlayerActionState6(void) {
    PlayerActionTimer++;
    if (PlayerActionTimer >= 0xE8) { PlayerActionState++; return; }
    for (unsigned x = 0; x < 0x0C; x += 2) {
        if (ROMB(0xD6D4 + x) != PlayerActionTimer) continue;
        unsigned y = ROMB(0xD6D5 + x);
        for (unsigned k = 0; k < 8; k++) OAM(0xC1 + 4 * k) = ROMB(0xD6E0 + y + k);
        return;
    }
}
/* $D710: player action state 7: three of the scene codes play two sound effects before the dialogue scene starts */
void PlayerActionState7(void) {
    uint8_t scene = ROMB(0xF77C + PlayerPose); RAM(0x0400) = scene;
    unsigned first = 0, second = 0; int sound = 1;
    if (scene == 0x0A) { first = 0x00; second = 0x08; }
    else if (scene == 0x28) { first = 0x1E; second = 0x14; }
    else if (scene == 0x2A) { first = 0x22; second = 0x15; }
    else sound = 0;
    if (sound) { QueueSound((Regs){(uint8_t)first, PlayerPose, (uint8_t)second, 0}); QueueSound((Regs){(uint8_t)second, PlayerPose, (uint8_t)second, 0}); }
    enter_bank3_scene(PlayerPose);
}

/* $FA47: after a bullet hit on an object (flag $40 in its status byte) the hit sound plays, the object's hit points drop by one and a
 * 64-frame lockout starts; every object's hit flags are cleared each frame */
void CheckBulletHitObjects(void) {
    if (RAM(0x0115)) { RAM(0x0115)--; return; }
    Tmp00 = 0x10; Tmp01 = 0x03;
    uint8_t left = (uint8_t)ObjectCount;
    if (left == 0) return;
    do {
        unsigned obj = 0x0300 + Tmp00;
        if (RAM(obj + 4) & 0x40) {
            RAM(0x0115) = 0x40; QueueSound((Regs){0x0D, left, 0, 0});
            if (RAM(obj + 6)) RAM(obj + 6)--;
        }
        RAM(obj + 4) &= 0x3F;
        Tmp00 = (uint8_t)(Tmp00 + 0x10); left--;
    } while (left);
}

/* ---- collisions ---- */
/* Object table entry fields used below (16 bytes at $0310 + 16 * n): +0 type and flags (bit 7 alive, bit 6 can be shot), +1 Y, +2 X,
 * +4 hit flags (bit 7 touches the player, bits 6 / 5 / 4 hit by the bullet in hit record 1 / 2 / 3), +6 hit points, +11 world Y,
 * +15 size (high nibble = height / 4, low nibble = width / 4). */
#define OBJ(n) (0x0300 + (n))
#define OBJ_TYPE 0
#define OBJ_Y 1
#define OBJ_X 2
#define OBJ_HITS 4
#define OBJ_HP 6
#define OBJ_SIZE 15
#define HurtTimer RAM(0x0114)

/* $F804: three bullet hit records (flag, Y, X, size) are compared with every shootable object: when the two boxes overlap the record's flag
 * is OR-ed into the object's hit byte. The box test is the original's carry arithmetic: starting below the other box's bottom edge only
 * counts when the other box's top is above the bottom of this one, and the other way round. */
static int boxes_overlap(uint8_t ry, uint8_t ry2, uint8_t oy1, uint8_t oy2) { return ry >= oy2 ? ry2 < oy1 : ry2 >= oy1; }
void BuildBulletHitboxes(void) {
    static const struct { unsigned flag, y, x, size, y2, x2; } rec[3] = {
        {0x0119, 0x011A, 0x011B, 0x011C, 0x08, 0x09}, {0x011E, 0x011F, 0x0120, 0x0121, 0x0A, 0x0B}, {0x0123, 0x0124, 0x0125, 0x0126, 0x0C, 0x0D}};
    for (int k = 0; k < 3; k++) if (RAM(rec[k].flag)) {
        RAM(rec[k].y2) = (uint8_t)(((RAM(rec[k].size) & 0xF0) >> 2) + RAM(rec[k].y));
        RAM(rec[k].x2) = (uint8_t)(((RAM(rec[k].size) & 0x0F) << 2) + RAM(rec[k].x));
    }
    if (ObjectCount == 0) return;
    Tmp00 = 0x10; Tmp01 = 0x03;
    uint8_t left = (uint8_t)ObjectCount;
    do {
        unsigned o = OBJ(Tmp00);
        if ((RAM(o + OBJ_TYPE) & 0xC0) == 0xC0 && RAM(o + OBJ_SIZE) != 0) {
            Tmp02 = RAM(o + OBJ_Y); Tmp03 = RAM(o + OBJ_X);
            unsigned y2 = ((RAM(o + OBJ_SIZE) & 0xF0) >> 2) + Tmp02; RAM(0x04) = (uint8_t)y2;
            if (y2 <= 0xFF) {
                unsigned x2 = ((RAM(o + OBJ_SIZE) & 0x0F) << 2) + Tmp03; RAM(0x05) = (uint8_t)x2;
                if (x2 <= 0xFF) {
                    for (int k = 0; k < 3; k++) {
                        if (!RAM(rec[k].flag)) continue;
                        if (k == 0 && RAM(rec[k].y) >= 0xE0) continue;
                        if (boxes_overlap(RAM(rec[k].y), RAM(rec[k].y2), Tmp02, RAM(0x04)) && boxes_overlap(RAM(rec[k].x), RAM(rec[k].x2), Tmp03, RAM(0x05)))
                            RAM(o + OBJ_HITS) |= RAM(rec[k].flag);
                    }
                }
            }
        }
        Tmp00 = (uint8_t)(Tmp00 + 0x10); left--;
    } while (left);
}

/* $F984: the first object that touches the player hurts him: sound $43, a 16-frame invulnerability, life minus the object type's damage
 * (table at $FA1D). Object type $27 while the player is in a low pose is a bonus instead: full life. Objects of types 0 stop the scan. */
void CheckPlayerHitByObjects(void) {
    if (HurtTimer) return;
    Tmp00 = 0x10; Tmp01 = 0x03;
    uint8_t left = (uint8_t)ObjectCount;
    if (left == 0) return;
    for (;;) {
        unsigned o = OBJ(Tmp00);
        if (RAM(o + OBJ_HITS) & 0x80) {
            uint8_t type = RAM(o + OBJ_TYPE) & 0x3F;
            if (type == 0) return;
            if (type == 0x27 && (PlayerPose & 0x0F) < 3) {
                PlayerPose = 7; ShootPoseTimer = 0; PlayerLifeLo = 200; RAM(o + 11) = 0xF0; RAM(0x0138) = 1; return;
            }
            QueueSound((Regs){0x43, left, 0, 0}); HurtTimer = 0x10;
            uint8_t dmg = ROMB(0xFA1D + type);
            PlayerLifeLo = PlayerLifeLo >= dmg ? (uint8_t)(PlayerLifeLo - dmg) : 0;
            if (type == 0x09 || type == 0x16 || type == 0x18 || type == 0x22 || type == 0x25) RAM(o + OBJ_HP) = 0;   /* these die on contact */
            return;
        }
        RAM(o + OBJ_HITS) &= 0x7F;
        Tmp00 = (uint8_t)(Tmp00 + 0x10);
        if (--left == 0) return;
    }
}

/* $FA8E: per frame, for every object: the hit-flash countdown in the high nibble of +6 runs down; when an object was just hit by a bullet
 * (status bits $40 / $20) its hit points' low nibble drops, the bullet's sprite is hidden and the flash starts. (In the original the sprite
 * index ends up in X, which is also the loop counter: the scan continues with that value. This is kept.) */
void TickObjectStates(void) {
    Tmp00 = 0x10; Tmp01 = 0x03;
    uint8_t left = (uint8_t)ObjectCount;
    if (left == 0) return;
    for (;;) {
        unsigned o = OBJ(Tmp00);
        if (RAM(o + OBJ_HP) & 0xF0) RAM(o + OBJ_HP) = (uint8_t)(RAM(o + OBJ_HP) - 0x10);
        else if ((RAM(o + OBJ_HITS) & 0x60) && (RAM(o + OBJ_HP) & 0x0F) != 0 && (RAM(o + OBJ_HP) & 0x0F) != 0x0F) {
            RAM(o + OBJ_HP) = (uint8_t)(((RAM(o + OBJ_HP) - 1) & 0xFF) | 0xF0);
            if ((RAM(o + OBJ_HITS) & 0x60) == 0x40) left = RAM(0x0122);
            else { left = RAM(0x0127); if (left >= 0x40) { left = 0x5C; RAM(0x0204 + left) = SPRITE_HIDDEN; } }
            OAM(left) = SPRITE_HIDDEN;
        }
        RAM(o + OBJ_HITS) &= 0x1F;
        Tmp00 = (uint8_t)(Tmp00 + 0x10);
        if (--left == 0) return;
    }
}

/* The three player hit-box routines (one per view / pose set) fill hit record 0 with the player's box (flag $80) unless the player is in
 * his hurt blink, then run the collision pass. */
static void clear_hit_flags(void) { ClearObjectStatusBits((Regs){0, 0, 0, 0}); }
static void player_hit_record(uint8_t y, uint8_t x_offset, uint8_t size) {
    RAM(0x011A) = y; RAM(0x011B) = (uint8_t)(PlayerSpriteX0 + x_offset); RAM(0x011C) = size; RAM(0x0119) = 0x80;
}
static void bullet_record_from_sprite(unsigned sprite, unsigned record, uint8_t size, uint8_t flag) {   /* a bullet sprite (Y at $0200 + sprite) as hit record */
    uint8_t y = RAM(0x0200 + sprite), live = y < 0xE8;
    if (live) { RAM(record + 1) = y; RAM(record + 2) = RAM(0x0200 + sprite + 3); RAM(record + 3) = size; RAM(record + 4) = (uint8_t)sprite; }
    RAM(record) = live ? flag : 0;
}
void UpdatePlayerHitboxA(void) {                 /* $FB00 */
    if (HurtTimer) { if (!(FrameCounter & 1)) HurtTimer--; RAM(0x0119) = 0; }
    else {
        uint8_t pose = PlayerPose & 0x0F, carry = pose >= 2;
        uint8_t dy = pose == 2 ? 0x12 : 0x08, size = pose == 2 ? 0x61 : 0x81;
        player_hit_record((uint8_t)(PlayerSpriteY + dy + carry), 6, size);
    }
    if (RAM(0x0115)) RAM(0x0115)--;
    else {
        uint8_t flag = 0;
        if ((PlayerPose & 0x0F) == POSE_SHOOT && ShootPoseTimer == 2) {          /* the muzzle flash of a fresh shot hurts what is in front */
            RAM(0x011F) = (uint8_t)(PlayerSpriteY + 0x11);
            RAM(0x0120) = (uint8_t)(((PlayerPose & 0x10) ? 0xEE : 0x0E) + PlayerSpriteX0);
            RAM(0x0121) = 0x35; flag = 0x40;
        }
        RAM(0x011E) = flag;
    }
    clear_hit_flags(); BuildBulletHitboxes(); CheckPlayerHitByObjects(); CheckBulletHitObjects();
    bullet_record_from_sprite(0x58, 0x011E, 0x12, 0x40);
    bullet_record_from_sprite(0x5C, 0x0123, 0x12, 0x20);
    clear_hit_flags(); BuildBulletHitboxes(); TickObjectStates(); UpdateLifeBlink((Regs){0, 0, 0, 0});
}
void UpdatePlayerHitboxB(void) {                 /* $FC1A */
    if (HurtTimer) { if (!(FrameCounter & 1)) HurtTimer--; RAM(0x0119) = 0; }
    else player_hit_record(PlayerSpriteY, 0, 0x44);
    if (!(FrameCounter & 1)) SetBulletHitbox1(); else SetBulletHitbox2();
    clear_hit_flags(); BuildBulletHitboxes(); CheckPlayerHitByObjects(); TickObjectStates(); UpdateLifeBlink((Regs){0, 0, 0, 0});
}
void UpdatePlayerHitboxC(void) {                 /* $FD18 */
    if (HurtTimer) { if (!(FrameCounter & 1)) HurtTimer--; RAM(0x0119) = 0; }
    else player_hit_record(PlayerSpriteY, 0, (PlayerPose & 0x0F) == 1 ? 0x44 : 0x63);
    SetBulletHitbox2();
    clear_hit_flags(); BuildBulletHitboxes(); CheckPlayerHitByObjects(); TickObjectStates(); UpdateLifeBlink((Regs){0, 0, 0, 0});
}

/* $E8D3: the palette fades out in steps: at fade level $40 / $50 / $60 every colour at or above $30 / $20 / $10 (the lighter ones) drops by one
 * brightness step; from level $70 the whole palette is black ($0F) */
#define PaletteFadeLevel RAM(0x013D)
#define PaletteBuffer(i) RAM(0x0140 + (i))
void FadePaletteStep(void) {
    uint8_t level = PaletteFadeLevel, threshold;
    if (level == 0x40) threshold = 0x30; else if (level == 0x50) threshold = 0x20; else if (level == 0x60) threshold = 0x10;
    else {
        if (level >= 0x70) for (unsigned i = 0; i < 0x20; i++) PaletteBuffer(i) = 0x0F;
        return;
    }
    RAM(0x04) = threshold;
    for (unsigned i = 0; i < 0x20; i++) if (PaletteBuffer(i) >= threshold) PaletteBuffer(i) = (uint8_t)(PaletteBuffer(i) - 0x10);
}

/* $D28E: is the player close enough to the object at table offset X (within 15 pixels in Y, 21 in X)? If so the dialogue / pickup scene of
 * bank 3 is prepared: the object's sprites (from $0200 + its OAM start up to the end of its box) and the ones after it are hidden. Result in A. */
Regs CheckPlayerNearObject(Regs r) {
    unsigned o = 0x0310 + r.x;
    Tmp00 = RAM(o + 1); Tmp01 = RAM(o + 2);
    uint8_t dy = (uint8_t)(PlayerSpriteY - Tmp00);
    if (dy < 0xF0 && dy >= 0x10) { r.a = 0; return r; }
    uint8_t dx = (uint8_t)(PlayerSpriteX0 - Tmp01);
    if (dx < 0xEA && dx >= 0x16) { r.a = 0; return r; }
    RAM(0x0410) = 0; RAM(0x0403) = 0; RAM(0x5D) = 2; Tmp03 = 2; RAM(0x05) = 2; RAM(0x0402) = 2;
    Tmp02 = GameState == 3 ? 0x58 : 0x4C;
    uint8_t first = RAM(o + 3);                                   /* +3 / +4: first OAM byte of the object and its number of sprites */
    RAM(0x04) = (uint8_t)(first + (RAM(o + 4) << 2)); RAM(0x5C) = RAM(0x04);
    if ((uint8_t)(first - Tmp02) >= 0x30) RAM(0x5C) = Tmp02;
    HideObjectSpriteRange(r); HideSpritesUntilE0(r);
    RAM(0x0110) = 0; r.a = 1; return r;
}

/* $C4EB: copy the palette set number PaletteSetIndex from bank 2 into the palette buffer: a table at $BA6C holds two bytes per set, each a
 * 12-bit offset into a pool of 16-color palettes (background pool at $BB42, sprite pool at $BDA2); bank 2 is switched in around the copy */
void LoadPaletteSet(void) {
    uint8_t saved = MmcPrgShadow;
    MmcPrgShadow = 2; MmcWritePrg((Regs){2, 0, 0, 0});
    unsigned x = (unsigned)PaletteSetIndex * 2 & 0xFF;
    uint8_t bg = ROMB(0xBA6C + x), spr = ROMB(0xBA6D + x);
    unsigned lo = ((bg << 4) & 0xFF) + 0x42; Tmp00 = (uint8_t)lo; Tmp01 = (uint8_t)(0xBB + (lo > 0xFF) + (bg >> 4));
    lo = ((spr << 4) & 0xFF) + 0xA2; Tmp02 = (uint8_t)lo; Tmp03 = (uint8_t)(0xBD + (lo > 0xFF) + (spr >> 4));
    uint16_t bg_ptr = (uint16_t)(Tmp00 | Tmp01 << 8), spr_ptr = (uint16_t)(Tmp02 | Tmp03 << 8);
    for (unsigned i = 0; i < 0x10; i++) PaletteBuffer(i) = ROMB(bg_ptr + i);
    for (unsigned i = 0; i < 0x10; i++) PaletteBuffer(0x10 + i) = ROMB(spr_ptr + i);
    MmcPrgShadow = saved; MmcWritePrg((Regs){saved, 0x20, 0x10, 0});
}

/* =====================================================================================================================================
 * Bank 6 (street scene spawns). These routines live in a switchable bank, so the tests run them with bank 6 mapped.
 * The spawn code builds a new object in the table through the pointer $0A/$0B; Tmp00/Tmp01 point at the object being updated.
 * ===================================================================================================================================== */
#define NEW_OBJ(y) PTR(RAM(0x0A), RAM(0x0B), (y))
#define CUR_OBJ(y) PTR(Tmp00, Tmp01, (y))

/* $B6:808E: pointer to this area's spawn list (a table of pointers at $B500, one per palette set / area) */
void LoadStageSpawnListPtr(void) {
    unsigned x = (PaletteSetIndex << 1) & 0xFF;
    Tmp00 = ROMB(0xB500 + x); Tmp01 = ROMB(0xB501 + x);
}
/* column of the map the screen's left edge (current page) or the next page is on: Tmp02 = page * 16 + ScrollX / 16 */
static void column_index(uint8_t page) { Tmp02 = (uint8_t)(((page << 4) & 0xFF) | (ScrollX >> 4)); }
void CalcScrollColumnIndex(void) { column_index(RAM(0x18)); }
void CalcNextScrollColumnIndex(void) { column_index((uint8_t)(RAM(0x18) + 1)); }

/* is an object of the type in $06 in the table (types at +7 of each entry from the second one on)? X = 1 if so, else 0 */
Regs FindObjectByType(Regs r) {
    uint8_t left = (uint8_t)ObjectCount; r.x = left;
    if (left == 0) return r;
    RAM(0x04) = 0x17; RAM(0x05) = 0x03;
    do {
        if (RAM(0x0300 + RAM(0x04)) == RAM(0x06)) { r.x = 1; return r; }
        RAM(0x04) = (uint8_t)(RAM(0x04) + 0x10); left--;
    } while (left);
    r.x = 0; return r;
}

void SetRandomSpawnPhase(void) {                 /* the new object's animation step (+14) is random 0-3 */
    Regs g = GetRandomByte((Regs){0, 0, 0, 0});
    NEW_OBJ(0x0E) = g.a & 3;
}
/* the new object's world X (+9 page, +10 position): at the left edge of the screen, or one screen width... when $08 != 0 at the right edge (ScrollX + 255) */
void SetSpawnXFromScroll(void) {
    if (RAM(0x08) == 0) { NEW_OBJ(9) = RAM(0x18); NEW_OBJ(10) = ScrollX; }
    else { unsigned s = 0xFF + ScrollX; NEW_OBJ(10) = (uint8_t)s; NEW_OBJ(9) = (uint8_t)(RAM(0x18) + (s > 0xFF)); }
}
void SetSpawnFacingBits(void) {                  /* bit 6 of +9 carries the side the object came from ($08 << 6) */
    NEW_OBJ(9) = (uint8_t)(NEW_OBJ(9) | ((RAM(0x08) << 6) & 0xFF));
}
Regs GetObjectBehaviorIndex(Regs r) {            /* Y = twice the high nibble of +9 (index into a table of pointers) */
    r.y = (uint8_t)((CUR_OBJ(9) & 0xF0) >> 3); return r;
}
Regs AdvanceObjectAnimStep(Regs r) {             /* the animation step counter (+14) goes up; $04 = the animation's length (first byte of the table Tmp02) */
    RAM(0x04) = PTR(Tmp02, Tmp03, 0);
    unsigned n = CUR_OBJ(0x0E) + 1; CUR_OBJ(0x0E) = (uint8_t)n;
    r.a = (uint8_t)n; r.c = n > 0xFF; r.y = 0x0E; return r;
}
void CalcObjectTileColumn(void) {                /* $04 = tile column of the object's world X: low nibble of +9 and high nibble of +10 */
    RAM(0x04) = (uint8_t)(((CUR_OBJ(9) << 4) & 0xFF) | (CUR_OBJ(10) >> 4));
}
Regs StoreSpawnStats(Regs r) {                   /* copy two bytes of the spawn list entry at offset Y+2 / Y+3 into the new object (+11 and +7) */
    uint8_t second = CUR_OBJ(r.y + 3), first = CUR_OBJ(r.y + 2) & 0xFE;
    NEW_OBJ(0x0B) = first; NEW_OBJ(7) = second;
    r.y = 7; r.a = second; return r;
}

/* =====================================================================================================================================
 * Bank 4 (first-person building scenes): object helpers. The object being worked on is at Tmp00/Tmp01 (a 16-byte entry of the table at $0310).
 * ===================================================================================================================================== */
Regs IncObjectField(Regs r) {                    /* $B4:8FBD: object byte Y goes up by one; A = the new value */
    unsigned n = CUR_OBJ(r.y) + 1; CUR_OBJ(r.y) = (uint8_t)n; r.a = (uint8_t)n; r.c = n > 0xFF; return r;
}
Regs DecObjectField(Regs r) {                    /* $B4:8FC5: byte Y goes down by one; carry set when there was no borrow */
    unsigned v = CUR_OBJ(r.y); CUR_OBJ(r.y) = (uint8_t)(v - 1); r.a = (uint8_t)(v - 1); r.c = v >= 1; return r;
}
Regs AdvanceObjectState(Regs r) { r.y = 8; return IncObjectField(r); }   /* $B4:8FBB: the state byte (+8) goes to the next state */
Regs AddToObjectField(Regs r) {                  /* $B4:AC2D: byte Y += A */
    unsigned n = CUR_OBJ(r.y) + r.a; CUR_OBJ(r.y) = (uint8_t)n; r.a = (uint8_t)n; r.c = n > 0xFF; return r;
}
Regs AddToObjectY(Regs r) { r.y = 1; return AddToObjectField(r); }       /* $B4:AC2B: screen Y (+1) += A */
Regs MoveObjectXY(Regs r) {                      /* $B4:AC25: X (+2) += A, then Y (+1) += X register */
    r.y = 2; r = AddToObjectField(r); r.a = r.x; return AddToObjectY(r);
}
Regs SetObjectFlagsE0(Regs r) { r.y = 0x0A; r.a = CUR_OBJ(0x0A) | 0xE0; CUR_OBJ(0x0A) = r.a; return r; }   /* $B4:B3F2 */
Regs SetObjectFlagsC0(Regs r) { r.a = CUR_OBJ(r.y) | 0xC0; CUR_OBJ(r.y) = r.a; return r; }               /* $B4:B3FB: byte Y gets bits 7 and 6 */
void AllocObjectSlot(void) {                     /* $B4:8FAB: the next free object entry; Tmp00/Tmp01 point at it */
    ObjectCount++; Tmp00 = (uint8_t)(ObjectCount << 4); Tmp01 = 3;
}
void ClearObjectTable(void) {                    /* $B4:86D1: no objects: the table from the second entry on is zeroed */
    ObjectCount = 0; for (unsigned x = 0x10; x < 0x100; x++) RAM(0x0300 + x) = 0;
}
Regs HideAllSprites(Regs r) {                    /* $B4:8473: Y = $F0 in all 64 sprites; X ends at 0 */
    r.x = 0;
    do { OAM(r.x) = SPRITE_HIDDEN; r.x = (uint8_t)(r.x + 4); } while (r.x != 0);
    r.a = SPRITE_HIDDEN; return r;
}
/* damage and pickups (life 0-200 in PlayerLifeLo/Hi, ammo up to $190) */
void DamagePlayer(Regs r) {                      /* $B4:B43D: life -= A, with a borrow into the high byte */
    uint8_t lo = PlayerLifeLo; PlayerLifeLo = (uint8_t)(lo - r.a); RAM(0x6A) = r.a;
    if (lo < r.a) PlayerLifeHi--;
}
void AddLifeAndAmmo(Regs r) {                    /* $B4:B44B: life += A (at most 200), ammo += X (at most $190) */
    uint8_t life = r.a; unsigned s = life + PlayerLifeLo;
    PlayerLifeLo = (s > 0xFF || (uint8_t)s >= 0xC8) ? 0xC8 : (uint8_t)s;
    unsigned lo = r.x + AmmoLo; uint8_t hi = (uint8_t)(AmmoHi + (lo > 0xFF)); lo &= 0xFF;
    if (hi >= 1 && (hi != 1 || lo >= 0x90)) { hi = 1; lo = 0x90; }
    AmmoHi = hi; AmmoLo = (uint8_t)lo;
}
Regs ExtractBitPair(Regs r) {                    /* $B4:9943: the 2-bit field number Y (0 = lowest) of A; callers load Y just before, so the zero flag stands for Y == 0 */
    uint8_t a = r.a;
    for (int i = 0; i < r.y; i++) a >>= 2;       /* (the original handles Y of 0-3 and shifts three times at most) */
    r.a = a & 3; return r;
}
Regs RandomByteMixed(Regs r) {                   /* $B4:90C5: the scene's own counter ($85, never 0) added to the random byte */
    do { RAM(0x85)++; } while (RAM(0x85) == 0);
    Regs g = GetRandomByte(r); unsigned s = g.a + RAM(0x85) + g.c;
    r.a = (uint8_t)s; r.x = g.x; r.c = s > 0xFF; return r;
}

