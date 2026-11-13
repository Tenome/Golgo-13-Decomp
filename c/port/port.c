#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include "port.h"
#include "../auto/runtime.h"
#include "apu.h"

/* ---- machine state shared with the lifted code ------------------------------------------------------------------- */
uint8_t g_ram[0x800];
const uint8_t *g_prg;
uint8_t g_bank;
uint8_t g_pad;
uint8_t g_chr[0x20000];
static uint8_t g_prg_store[0x20000];
uint64_t g_cycles;
uint32_t g_frame[240][256];
unsigned long g_frames;
int g_quit;
uint16_t g_iolog_addr[IOLOG_MAX]; uint8_t g_iolog_val[IOLOG_MAX]; int g_iolog_n;   /* unused by the port (declared in core.h) */
void iolog_reset(void) {}

extern uint16_t g_unknown_addr;
extern void Nmi(void);
extern void Reset(void);

/* ---- MMC1 ---------------------------------------------------------------------------------------------------------- */
static uint8_t mmc_shift, mmc_count, mmc_control = 0x0C, mmc_chr0, mmc_chr1, mmc_prg;

/* ---- PPU ----------------------------------------------------------------------------------------------------------- */
static uint8_t vram[2][0x400], oam[256], palette[32];
static uint8_t ctrl, mask, status, oam_addr, read_buf;
static uint16_t v, t; static uint8_t fine_x, w_latch;
static int line = 241;                         /* current scanline: 0-239 visible, 240 post, 241-260 vblank, 261 pre-render */
static uint64_t line_start_dot;                /* absolute PPU dot at which `line` began */
static int nmi_pending, in_nmi;
static void (*present_cb)(unsigned long, const uint32_t (*)[256]);

static const uint32_t PAL[64] = {
    0x666666,0x002A88,0x1412A7,0x3B00A4,0x5C007E,0x6E0040,0x6C0600,0x561D00,0x333500,0x0B4800,0x005200,0x004F08,0x00404D,0x000000,0x000000,0x000000,
    0xADADAD,0x155FD9,0x4240FF,0x7527FE,0xA01ACC,0xB71E7B,0xB53120,0x994E00,0x6B6D00,0x388700,0x0C9300,0x008F32,0x007C8D,0x000000,0x000000,0x000000,
    0xFFFEFF,0x64B0FF,0x9290FF,0xC676FF,0xF36AFF,0xFE6ECC,0xFE8170,0xEA9E22,0xBCBE00,0x88D800,0x5CE430,0x45E082,0x48CDDE,0x4F4F4F,0x000000,0x000000,
    0xFFFEFF,0xC0DFFF,0xD3D2FF,0xE8C8FF,0xFBC2FF,0xFEC4EA,0xFECCC5,0xF7D8A5,0xE4E594,0xCFEF96,0xBDF4AB,0xB3F3CC,0xB5EBF2,0xB8B8B8,0x000000,0x000000 };

static uint8_t chr_read(uint16_t a) {                     /* PPU $0000-$1FFF through the MMC1 CHR banks */
    unsigned bank;
    if (mmc_control & 0x10) bank = (a < 0x1000 ? mmc_chr0 : mmc_chr1) & 0x1F;                 /* 4 KB banks */
    else bank = ((mmc_chr0 & 0x1E) | (a >= 0x1000 ? 1 : 0));                                  /* one 8 KB bank */
    return g_chr[(bank * 0x1000 + (a & 0xFFF)) & 0x1FFFF];
}
static uint8_t *nt_ptr(uint16_t a) {                      /* nametable $2000-$2FFF with the MMC1 mirroring */
    unsigned n = (a >> 10) & 3, phys;
    switch (mmc_control & 3) { case 0: phys = 0; break; case 1: phys = 1; break; case 2: phys = n & 1; break; default: phys = n >> 1; }
    return &vram[phys][a & 0x3FF];
}
static uint8_t ppu_read(uint16_t a) {
    a &= 0x3FFF;
    if (a < 0x2000) return chr_read(a);
    if (a < 0x3F00) return *nt_ptr(a);
    a &= 0x1F; if ((a & 0x13) == 0x10) a &= 0x0F; return palette[a];
}
static void ppu_write(uint16_t a, uint8_t d) {
    a &= 0x3FFF;
    if (a < 0x2000) return;                                /* CHR-ROM */
    if (a < 0x3F00) { *nt_ptr(a) = d; return; }
    a &= 0x1F; if ((a & 0x13) == 0x10) a &= 0x0F; palette[a] = d & 0x3F;
}
static inline int rendering(void) { return (mask & 0x18) != 0; }

static uint16_t line_v0;                          /* v at the start of the line */
static struct { int tile; uint16_t v; } vev[8]; static int nvev;   /* v written by the CPU during the visible part: from which tile it applies */
/* MMC1 registers changed by the CPU during the line: the background reads its pattern bytes while the line is drawn, so a bank switch only
 * applies to the tiles fetched after it; the sprites are fetched in the blanking time after the line and see the final state. */
static uint8_t ls_chr0, ls_chr1, ls_ctrl;                          /* state at the start of the line */
static struct { int dot; uint8_t chr0, chr1, ctrl; } mev[16]; static int nmev;
static uint8_t bgbuf[256], bgopbuf[256]; static int bg_on;           /* background of the line being drawn (filled at dot 256) */

static void render_bg(int y) {
    (void)y; bg_on = rendering();
    memset(bgbuf, 0, sizeof bgbuf); memset(bgopbuf, 0, sizeof bgopbuf);
    if (!bg_on || !(mask & 0x08)) return;
    uint8_t save0 = mmc_chr0, save1 = mmc_chr1, savec = mmc_control;
    uint16_t vv = line_v0; unsigned fy;
    for (int tile = 0; tile < 33; tile++) {
        for (int e = 0; e < nvev; e++) if (vev[e].tile == tile) vv = vev[e].v;          /* a $2006 write took effect for this tile */
        int fetch_dot = tile < 2 ? -1 : 8 * (tile - 2) + 6;                              /* tile 0/1 were fetched in the previous blanking time */
        mmc_chr0 = ls_chr0; mmc_chr1 = ls_chr1; mmc_control = ls_ctrl;
        for (int e = 0; e < nmev; e++) if (mev[e].dot <= fetch_dot) { mmc_chr0 = mev[e].chr0; mmc_chr1 = mev[e].chr1; mmc_control = mev[e].ctrl; }
        fy = (vv >> 12) & 7;
        uint8_t nt = *nt_ptr(0x2000 | (vv & 0x0FFF));
        uint8_t at = *nt_ptr(0x23C0 | (vv & 0x0C00) | ((vv >> 4) & 0x38) | ((vv >> 2) & 7));
        int shift = ((vv >> 4) & 4) | (vv & 2);
        unsigned pal = (at >> shift) & 3;
        uint16_t pa = (uint16_t)(((ctrl & 0x10) ? 0x1000 : 0) + nt * 16 + fy);
        uint8_t lo = chr_read(pa), hi = chr_read(pa + 8);
        for (int px = 0; px < 8; px++) {
            int x = tile * 8 + px - fine_x; if (x < 0 || x > 255) continue;
            unsigned c = ((lo >> (7 - px)) & 1) | (((hi >> (7 - px)) & 1) << 1);
            bgbuf[x] = (uint8_t)(c ? (pal << 2 | c) : 0); bgopbuf[x] = c != 0;
        }
        if ((vv & 0x1F) == 31) { vv = (uint16_t)((vv & ~0x1F) ^ 0x400); } else vv++;
    }
    mmc_chr0 = save0; mmc_chr1 = save1; mmc_control = savec;
    if (!(mask & 0x02)) for (int x = 0; x < 8; x++) { bgbuf[x] = 0; bgopbuf[x] = 0; }
}

/* sprites + final picture of line y (with `probe`: only the x of the sprite 0 hit, -1 = none) */
static int render_obj(int y, int probe) {
    uint32_t *out = g_frame[y]; int hit_x = -1;
    uint8_t col[256]; memcpy(col, bgbuf, sizeof col);
    if (y > 0 && rendering() && (mask & 0x10)) {           /* the first line never shows sprites: their data is fetched one line ahead and the pre-render line fetches none */
        int h = (ctrl & 0x20) ? 16 : 8, count = 0; int idx[8];
        for (int i = 0; i < 64 && count < 8; i++) { int row = y - (oam[i * 4] + 1); if (row >= 0 && row < h) idx[count++] = i; }
        uint8_t sp[256], spop[256], spri[256], spzero[256]; memset(spop, 0, sizeof spop); memset(spzero, 0, sizeof spzero);
        for (int k = count - 1; k >= 0; k--) {                  /* low OAM index wins: draw it last */
            int i = idx[k]; uint8_t ty = oam[i * 4 + 1], at = oam[i * 4 + 2], sx = oam[i * 4 + 3];
            int row = y - (oam[i * 4] + 1); if (at & 0x80) row = h - 1 - row;
            uint16_t pa;
            if (h == 8) pa = (uint16_t)(((ctrl & 0x08) ? 0x1000 : 0) + ty * 16 + row);
            else pa = (uint16_t)(((ty & 1) ? 0x1000 : 0) + (ty & 0xFE) * 16 + (row & 8) * 2 + (row & 7));
            uint8_t lo = chr_read(pa), hi = chr_read(pa + 8);
            for (int px = 0; px < 8; px++) {
                int bit = (at & 0x40) ? px : 7 - px, x = sx + px; if (x > 255) continue;
                unsigned c = ((lo >> bit) & 1) | (((hi >> bit) & 1) << 1); if (!c) continue;
                if (x < 8 && !(mask & 0x04)) continue;
                sp[x] = (uint8_t)(0x10 | ((at & 3) << 2) | c); spop[x] = 1; spri[x] = (at >> 5) & 1; spzero[x] = (i == 0);
            }
        }
        for (int x = 0; x < 256; x++) {
            if (!spop[x]) continue;
            if (spzero[x] && bgopbuf[x] && x < 255 && (mask & 0x08)) { if (hit_x < 0) hit_x = x; if (!probe) status |= 0x40; }          /* sprite 0 hit */
            if (!bgopbuf[x] || !spri[x]) { col[x] = sp[x]; }
        }
    }
    if (probe) return hit_x;
    uint32_t backdrop = PAL[palette[0] & 0x3F];
    for (int x = 0; x < 256; x++) {
        uint8_t c = col[x]; if ((c & 3) == 0) c = 0;
        out[x] = bg_on ? PAL[palette[c & 0x1F] & 0x3F] : backdrop;
    }
    return hit_x;
}
/* the sprite 0 probe at the start of a line: where will the hit happen (uses the registers as they are then) */
static int probe_line(int y) {
    if (!rendering()) return -1;
    uint16_t sv0 = line_v0; int sn = nvev, sm = nmev; nvev = nmev = 0;
    render_bg(y); int hx = render_obj(y, 1); nvev = sn; nmev = sm; (void)sv0; return hx;
}

static void end_of_line_updates(void) {                   /* what the PPU does to v at the end of a rendered line */
    if (!rendering()) return;
    if ((v & 0x7000) != 0x7000) v += 0x1000;
    else {
        v &= ~0x7000; int y = (v & 0x03E0) >> 5;
        if (y == 29) { y = 0; v ^= 0x0800; } else if (y == 31) y = 0; else y++;
        v = (uint16_t)((v & ~0x03E0) | (y << 5));
    }
    v = (uint16_t)((v & ~0x041F) | (t & 0x041F));          /* horizontal bits copied from t */
}
/* Timing of one scanline (341 dots), as far as the game needs it:
 *   dot 0      line starts; sprite 0 is probed once for this line (where the hit will happen)
 *   dot 1      line 241: vblank flag, NMI request, the picture of the frame is complete
 *   dot 256    the visible part is over: the line is drawn with the registers as they are NOW, then the vertical increment and the
 *              horizontal copy of v happen. Writes the CPU makes in the horizontal blanking therefore belong to the next line.
 * (The real PPU fetches while it draws; drawing the whole line at dot 256 is exact for writes that land in the blanking time, which is what
 *  the game's raster tricks use, and an approximation for writes during the visible part.) */
static int line_rendered, vbl_set = 1, s0_valid; static uint64_t s0_dot;
static void next_line(void) {
    line++; line_start_dot += 341; line_rendered = 0;
    if (line == 241) vbl_set = 0;
    else if (line == 262) line = 0;
    if (line == 261) status &= (uint8_t)~0xE0;           /* pre-render line: flags clear */
    if (line == 0 && rendering()) v = (uint16_t)((v & ~0x7FFF) | (t & 0x7FFF));      /* the pre-render line copies the vertical bits (dots 280-304) and the horizontal ones (dot 257) from t */
    line_v0 = v; nvev = 0; ls_chr0 = mmc_chr0; ls_chr1 = mmc_chr1; ls_ctrl = mmc_control; nmev = 0;
    s0_valid = 0;
    if (line < 240) { int hx = probe_line(line); if (hx >= 0) { s0_valid = 1; s0_dot = line_start_dot + 2 + (uint64_t)hx; if (getenv("G13_WLOG") && g_frames == (unsigned long)atoi(getenv("G13_WLOG"))) fprintf(stderr, "sprite0 hit planned: line %d x %d" "%c", line, hx, 10); } }
}
static void catch_up(void) {                              /* run the PPU to the current CPU time */
    uint64_t dots = g_cycles * 3;
    for (;;) {
        if (line < 240 && line_rendered == 0 && line_start_dot + 256 <= dots) { render_bg(line); end_of_line_updates(); line_rendered = 1; }
        if (line < 240 && line_rendered == 1 && line_start_dot + 321 <= dots) { render_obj(line, 0); line_rendered = 2; }
        if (line == 241 && !vbl_set && line_start_dot + 1 <= dots) {
            vbl_set = 1; status |= 0x80;
            if (ctrl & 0x80) nmi_pending = 1;
            g_frames++;
            if (g_apu_enabled) apu_render_frame();
            if (present_cb) present_cb(g_frames, (const uint32_t (*)[256])g_frame);
            if (g_quit) longjmp(g_jmp, 99);
        }
        if (line_start_dot + 341 <= dots) { next_line(); continue; }
        break;
    }
    if (s0_valid && dots >= s0_dot) status |= 0x40;
}

static unsigned pad_idx;
/* ---- register access ----------------------------------------------------------------------------------------------- */
uint8_t io_read(uint16_t addr) {
    if (addr >= 0x2000 && addr < 0x4000) {
        catch_up();
        switch (addr & 7) {
        case 2: { uint8_t s = status; status &= (uint8_t)~0x80; w_latch = 0; return s; }
        case 4: return oam[oam_addr];
        case 7: { uint8_t r = read_buf; uint16_t a = v & 0x3FFF; read_buf = ppu_read(a); if (a >= 0x3F00) r = read_buf; v = (uint16_t)(v + ((ctrl & 4) ? 32 : 1)); return r; }
        default: return 0;
        }
    }
    if (addr == 0x4015) return apu_read_status();
    if (addr == 0x4016) { unsigned i = pad_idx++; return (uint8_t)(i < 8 ? (g_pad >> i) & 1 : 1); }
    return 0;
}
void io_write(uint16_t addr, uint8_t d) {
    if (getenv("G13_WLOG") && g_frames == (unsigned long)atoi(getenv("G13_WLOG")) && ((addr >= 0x2000 && addr < 0x2008) || addr >= 0x8000 || addr == 0x4014)) fprintf(stderr, "W %04X=%02X cyc %llu line %d dot %d" "%c", addr, d, (unsigned long long)g_cycles, line, (int)(g_cycles * 3 - line_start_dot), 10);
    if (addr >= 0x2000 && addr < 0x4000) {
        catch_up();
        switch (addr & 7) {
        case 0: { uint8_t old = ctrl; ctrl = d; t = (uint16_t)((t & ~0x0C00) | ((d & 3) << 10)); if (!(old & 0x80) && (d & 0x80) && (status & 0x80)) nmi_pending = 1; break; }
        case 1: mask = d; break;
        case 3: oam_addr = d; break;
        case 4: oam[oam_addr++] = d; break;
        case 5: if (!w_latch) { fine_x = d & 7; t = (uint16_t)((t & ~0x1F) | (d >> 3)); } else { t = (uint16_t)((t & ~0x73E0) | ((d & 7) << 12) | ((d >> 3) << 5)); } w_latch ^= 1; break;
        case 6: if (getenv("G13_PPULOG") && g_frames >= 3590 && g_frames <= 3590) fprintf(stderr, "f%lu line %d dot %d $2006=%02X latch %d\n", g_frames, line, (int)(g_cycles * 3 - line_start_dot), d, w_latch);
                if (!w_latch) { t = (uint16_t)((t & 0x00FF) | ((d & 0x3F) << 8)); } else {
                    t = (uint16_t)((t & 0xFF00) | d); v = t;
                    if (line < 240 && rendering() && nvev < 8) {         /* the background fetch of tile m happens 2 tiles before it is shown: the write applies from tile (next fetch group + 2) */
                        int dot = (int)(g_cycles * 3 - line_start_dot), tile = (dot + 7) / 8 + 2;
                        if (tile <= 32) { vev[nvev].tile = tile; vev[nvev].v = v; nvev++; }
                    }
                } w_latch ^= 1; break;
        case 7: ppu_write(v & 0x3FFF, d); v = (uint16_t)(v + ((ctrl & 4) ? 32 : 1)); break;
        }
        return;
    }
    if (addr == 0x4014) {                                 /* OAM DMA from CPU page d */
        for (int i = 0; i < 256; i++) oam[(uint8_t)(oam_addr + i)] = g_ram[((d << 8) + i) & 0x7FF];
        g_cycles += 513 + (g_cycles & 1); return;      /* the CPU is halted: 513 cycles, 514 when the DMA starts on an odd one */
    }
    if (addr >= 0x4000 && addr <= 0x4013 || addr == 0x4015 || addr == 0x4017) { apu_write(addr, d); return; }
    if (addr == 0x4016) { pad_idx = 0; return; }                                   /* strobe restarts the shift register */
    if (addr >= 0x8000) {                                  /* MMC1 serial port */
        if (d & 0x80) { mmc_shift = 0; mmc_count = 0; mmc_control |= 0x0C; return; }
        mmc_shift |= (uint8_t)((d & 1) << mmc_count); mmc_count++;
        if (mmc_count == 5) {
            switch ((addr >> 13) & 3) { case 0: mmc_control = mmc_shift; break; case 1: mmc_chr0 = mmc_shift; break; case 2: mmc_chr1 = mmc_shift; break; default: mmc_prg = mmc_shift; g_bank = mmc_prg & 7; }
            mmc_shift = 0; mmc_count = 0;
            if (line < 240 && nmev < 16) { mev[nmev].dot = (int)(g_cycles * 3 - line_start_dot); mev[nmev].chr0 = mmc_chr0; mev[nmev].chr1 = mmc_chr1; mev[nmev].ctrl = mmc_control; nmev++; }
        }
    }
}

/* ---- interrupts and frame loop --------------------------------------------------------------------------------------- */
void port_poll(void) {
    catch_up();
    if (nmi_pending && !in_nmi) {
        nmi_pending = 0; in_nmi = 1; g_cycles += 7;      /* interrupt sequence */
        Cpu saved = R; uint8_t sp = R.sp;
        R.sp = (uint8_t)(sp - 3);
        Nmi();
        R = saved; in_nmi = 0;
    }
}
void port_set_present(void (*cb)(unsigned long, const uint32_t (*)[256])) { present_cb = cb; }
void port_set_pad(uint8_t b) { g_pad = b; }
int port_load_memory(const uint8_t *rom, size_t n) {
    if (n < 16 + 0x40000 || memcmp(rom, "NES", 4)) return 2;
    if (rom[4] != 8 || rom[5] != 16) return 3;                                     /* this port is for the 128 KB PRG / 128 KB CHR MMC1 board */
    memcpy(g_prg_store, rom + 16, 0x20000); memcpy(g_chr, rom + 16 + 0x20000, 0x20000); g_prg = g_prg_store; return 0;
}
int port_load(const char *path) {
    FILE *f = fopen(path, "rb"); if (!f) return 1;
    static uint8_t buf[16 + 0x40000 + 0x2000]; size_t n = fread(buf, 1, sizeof buf, f); fclose(f);
    return port_load_memory(buf, n);
}
void port_run(unsigned long frames) {
    (void)frames;
    memset(g_ram, 0, sizeof g_ram); R = (Cpu){0}; R.sp = 0xFD; R.i = 1;
    g_cycles = 0; line = 241; line_start_dot = 0; g_frames = 0; g_bank = 0;
    int jr = setjmp(g_jmp);
    if (jr) { if (jr != 99) fprintf(stderr, "lifted code aborted: code %d (4 = no routine for $%04X in bank %d, 5/6 = stack tricks, 3 = %s)\n", jr, g_unknown_addr, g_bank, g_unsupported_why ? g_unsupported_why : "-");
        if (jr == 4 && g_unknown_addr < 0x2000) { fprintf(stderr, "RAM at $%04X:", g_unknown_addr); for (int i = 0; i < 16; i++) fprintf(stderr, " %02X", g_ram[(g_unknown_addr + i) & 0x7FF]); fprintf(stderr, "\n"); }
        return; }   /* 99 = g_quit */
    Reset();                                                                    /* ends in the idle loop; NMIs arrive through port_poll */
}
