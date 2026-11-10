#include "golgo13.h"

uint8_t g_ram[0x800];
const uint8_t *g_prg;
uint8_t g_bank;
uint16_t g_iolog_addr[IOLOG_MAX];
uint8_t g_iolog_val[IOLOG_MAX];
int g_iolog_n;
static uint8_t mmc_shift, mmc_count;

void iolog_reset(void) { g_iolog_n = 0; mmc_shift = 0; mmc_count = 0; }
void io_write(uint16_t addr, uint8_t v) {
    if (g_iolog_n < IOLOG_MAX) { g_iolog_addr[g_iolog_n] = addr; g_iolog_val[g_iolog_n] = v; g_iolog_n++; }
    if (addr >= 0x8000) {                       /* MMC1 serial port */
        if (v & 0x80) { mmc_shift = 0; mmc_count = 0; return; }
        mmc_shift |= (uint8_t)((v & 1) << mmc_count); mmc_count++;
        if (mmc_count == 5) { if (addr >= 0xE000) g_bank = mmc_shift & 7; mmc_shift = 0; mmc_count = 0; }
    }
}

uint8_t io_read(uint16_t addr) { (void)addr; return 0; }   /* tests: every register reads 0; the host replaces this */

/* ---- tiny 6502 helpers so the lifted code keeps the exact arithmetic of the original ---- */
static inline uint8_t sbc8(uint8_t a, uint8_t m, uint8_t *c) { unsigned r = a + (uint8_t)~m + *c; *c = r > 0xFF; return (uint8_t)r; }
static inline uint8_t adc8(uint8_t a, uint8_t m, uint8_t *c) { unsigned r = a + m + *c; *c = r > 0xFF; return (uint8_t)r; }
#define RAM(a) g_ram[(a) & 0x7FF]
#define NEG(v) (((v) & 0x80) != 0)

/* named RAM ($xx = zero page) - see config/<ver>/ram.json */
#define PpuMaskShadow RAM(0xFE)
#define PpuCtrlShadow RAM(0xFF)
#define MmcControlShadow RAM(0xF8)
#define MmcChr0Shadow RAM(0xF9)
#define MmcChr1Shadow RAM(0xFA)
#define MmcPrgShadow RAM(0xFB)

#define SHIFTL(n) Regs r2 = r; r2.c = (uint8_t)((r.a >> (8 - (n))) & 1); r2.a = (uint8_t)(r.a << (n)); return r2
Regs AslA6(Regs r) { SHIFTL(6); }
Regs AslA5(Regs r) { SHIFTL(5); }
Regs AslA4(Regs r) { SHIFTL(4); }
Regs AslA3(Regs r) { SHIFTL(3); }
#define SHIFTR(n) Regs r2 = r; r2.c = (uint8_t)((r.a >> ((n) - 1)) & 1); r2.a = (uint8_t)(r.a >> (n)); return r2
Regs LsrA6(Regs r) { SHIFTR(6); }
Regs LsrA5(Regs r) { SHIFTR(5); }
Regs LsrA4(Regs r) { SHIFTR(4); }
Regs LsrA3(Regs r) { SHIFTR(3); }

Regs SetPpuCtrl(Regs r) { PpuCtrlShadow = r.a; io_write(0x2000, r.a); return r; }
Regs SetPpuMask(Regs r) { PpuMaskShadow = r.a; io_write(0x2001, r.a); return r; }
Regs DoOamDma(Regs r) { io_write(0x2003, 0); io_write(0x4014, 2); r.a = 2; return r; }
void ApplyScroll(void) { io_write(0x2005, RAM(0xFD)); io_write(0x2005, RAM(0xFC)); io_write(0x2000, PpuCtrlShadow); }

Regs BinToDecimal(Regs r) {
    uint8_t c, a;
    RAM(0x00) = RAM(0x01) = RAM(0x02) = 0;
    do { c = 1; a = sbc8(RAM(0x03), 0x64, &c); RAM(0x03) = a; a = sbc8(RAM(0x04), 0x00, &c); RAM(0x04) = a; RAM(0x02)++; } while (c);
    RAM(0x02)--; c = 0; a = adc8(0x64, RAM(0x03), &c); RAM(0x03) = a; RAM(0x04) = 0;
    do { c = 1; a = sbc8(RAM(0x03), 0x0A, &c); RAM(0x03) = a; RAM(0x01)++; } while (c);
    RAM(0x01)--; c = 0; a = adc8(0x0A, RAM(0x03), &c); RAM(0x00) = a;
    r.a = a; r.c = c; return r;
}

Regs EnqueueByte(Regs r) {
    RAM(0x0118) = r.x; RAM(0x06E0)++;
    uint8_t x = RAM(0x06E0); RAM(0x06E0 + x) = r.a;
    return r;                                   /* X reloaded from $0118 = the caller's X */
}

void TickClock(void) {
    RAM(0x10)++; RAM(0x11)++;
    if (0x3B < RAM(0x11)) { RAM(0x11) = 0; RAM(0x12)++; }
}

Regs GetRandomByte(Regs r) {
    RAM(0x0108)++;
    uint8_t c = 1;
    if (!(0x1F >= RAM(0x0108))) { RAM(0x0108) = 0; c = 0; }
    r.x = RAM(0x0108); r.a = ROMB(0xC2B9 + r.x); r.c = c; return r;
}

static Regs mmc_write(Regs r, uint16_t addr) {         /* five writes of A, shifting right between them */
    uint8_t a = r.a;
    for (int i = 0; i < 5; i++) { io_write(addr, a); if (i < 4) { r.c = a & 1; a >>= 1; } }
    r.a = a; return r;
}
Regs MmcWriteControl(Regs r) { r.a = MmcControlShadow; return mmc_write(r, 0x9FFF); }
Regs MmcWriteChr0(Regs r)    { r.a = MmcChr0Shadow;    return mmc_write(r, 0xBFFF); }
Regs MmcWriteChr1A(Regs r)   { return mmc_write(r, 0xDFFF); }
Regs MmcWriteChr1(Regs r)    { r.a = MmcChr1Shadow;    return mmc_write(r, 0xDFFF); }
Regs MmcWritePrg(Regs r)     { r.a = MmcPrgShadow;     return mmc_write(r, 0xFFFF); }

/* more named RAM */
#define FrameCounter RAM(0x10)
#define PaletteBuffer(i) RAM(0x0140 + (i))
#define OamBuffer(i) RAM(0x0200 + (i))
#define JoyHeld1 RAM(0x010B)
#define FireMode RAM(0x36)
#define AmmoLo RAM(0x3A)
#define AmmoHi RAM(0x3B)
#define ObjectCount RAM(0x0301)
#define PlayerLifeLo RAM(0x38)
#define PlayerSpriteFrame RAM(0x37)

Regs SetPaletteAddr(Regs r) {
    SetPpuCtrl((Regs){ (uint8_t)(PpuCtrlShadow & 0xFB), r.x, r.y, r.c });
    r.a = io_read(0x2002); r.y = 0x3F; io_write(0x2006, r.y); r.x = 0; io_write(0x2006, 0); return r;
}
Regs ResetPpuAddr(Regs r) { io_write(0x2006, r.y); io_write(0x2006, 0); io_write(0x2006, 0); io_write(0x2006, 0); r.a = 0; return r; }
Regs UploadPalette(Regs r) {
    r = SetPaletteAddr(r);
    do { r.a = PaletteBuffer(r.x); io_write(0x2007, r.a); r.x++; } while (NEG((uint8_t)(r.x - 0x20)));
    r.c = r.x >= 0x20;
    return ResetPpuAddr(r);
}
Regs FillPaletteBlack(Regs r) {
    r = SetPaletteAddr(r); r.a = 0x0F;
    do { io_write(0x2007, r.a); r.x++; } while (NEG((uint8_t)(r.x - 0x20)));
    r.c = r.x >= 0x20;
    return ResetPpuAddr(r);
}
Regs ResetPpuScroll(Regs r) {
    io_read(0x2002); io_write(0x2005, 0); io_write(0x2005, 0);
    r.a = PpuCtrlShadow & 0xFC; return SetPpuCtrl(r);
}
Regs SetPpuAddrFromBuf(Regs r) {
    io_read(0x2002); io_write(0x2006, RAM(0x0109)); r.a = RAM(0x010A); io_write(0x2006, r.a); return r;
}
Regs AnimatePalette(Regs r) {
    uint8_t x = (FrameCounter & 0x02) ? 4 : 0, y = 0, a = 0;
    do {
        for (int k = 0; k < 4; k++) { a = ROMB(0xDE0D + k + x); PaletteBuffer(y) = a; y++; }
    } while (y < 0x10);
    r.a = a; r.x = x; r.y = y; r.c = 1; return r;
}
Regs HideEnemySprites(Regs r) {
    uint8_t x = 0x5C;
    do { OamBuffer(x) = 0xF0; x += 4; } while (x < 0xE0);
    r.a = 0xF0; r.x = x; r.c = 1; return r;
}
Regs CopyPlayerSprites(Regs r) {
    uint8_t x = PlayerSpriteFrame, a = 0, y = 0;
    if (x) { do { a = (uint8_t)(a + 0x4C); x--; } while (x); x = a; }
    do { a = ROMB(0xD3EF + x); RAM(0x0238 + y) = a; x++; y++; } while (y < 0x4C);
    r.a = a; r.x = x; r.y = y; r.c = 1; return r;
}
Regs InitHudSprites(Regs r) {
    RAM(0x05) = 0x10; uint8_t a = r.a;
    do { a = ROMB(0xC9B9 + r.x); RAM(0x02E0 + r.y) = a; r.x++; r.y++; RAM(0x05)--; } while (RAM(0x05) != 0);
    r.a = a; return r;
}
Regs DrawHudNumber(Regs r) {
    uint8_t c, a, x = r.x;
    r = BinToDecimal(r);
    if (RAM(0x02) != 0) { c = NEG(RAM(0x02)); a = (uint8_t)(RAM(0x02) << 1); a = adc8(a, 0xE4, &c); RAM(0x02E9 + x) = a; }
    if (RAM(0x02) != 0 || RAM(0x01) != 0) { c = NEG(RAM(0x01)); a = (uint8_t)(RAM(0x01) << 1); a = adc8(a, 0xE4, &c); RAM(0x02E5 + x) = a; }
    c = NEG(RAM(0x00)); a = (uint8_t)(RAM(0x00) << 1); a = adc8(a, 0xE4, &c); RAM(0x02E1 + x) = a;
    r.a = a; r.c = c; r.x = x; return r;
}
Regs UpdateFireMode(Regs r) {
    uint8_t a = JoyHeld1 & 0xC0;
    if (a == 0) { r.a = 0; return r; }
    r.c = 1;
    a = (a == 0x40) ? (uint8_t)(FireMode | 0x10) : (uint8_t)(FireMode & 0x0F);
    FireMode = a; r.a = a; return r;
}
Regs SetFireModeLow(Regs r) { FireMode &= 0x10; r.a = (uint8_t)(r.x | FireMode); FireMode = r.a; return r; }
Regs AdjustAmmo(Regs r) {
    uint8_t c = 0, a = adc8(r.a, AmmoLo, &c); AmmoLo = a;
    if (!c) { AmmoHi--; if (NEG(AmmoHi)) { a = 0; AmmoLo = 0; AmmoHi = 0; } }
    r.a = a; r.c = c; return r;
}
Regs UseAmmo(Regs r) {
    r.c = r.x >= 6;
    if (r.x >= 6) { r.a = 0xFF; r = AdjustAmmo(r); }
    return r;
}
Regs ClearObjectStatusBits(Regs r) {
    uint8_t x = ObjectCount; r.x = x;
    if (x == 0) return r;
    RAM(0x00) = 0x10; RAM(0x01) = 0x03; uint8_t y = 4, c = 0, a = 0;
    do { RAM(0x0310 + y) &= 0x1F; a = y; c = 0; a = adc8(a, 0x10, &c); y = a; x--; } while (x != 0);
    r.a = a; r.x = 0; r.y = y; r.c = c; return r;
}
Regs UpdateLifeBlink(Regs r) {
    uint8_t a;
    if (RAM(0x0114) == 0) a = RAM(0x0116);
    else if (FrameCounter & 0x02) a = PlayerLifeLo;
    else a = 0x16;
    RAM(0x0153) = a; r.a = a; return r;
}
