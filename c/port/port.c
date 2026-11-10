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

static void render_line(int y) {
    uint8_t bg[256], bgop[256]; uint32_t *out = g_frame[y];
    uint32_t backdrop = PAL[palette[0] & 0x3F];
    if (!rendering()) { for (int x = 0; x < 256; x++) out[x] = backdrop; return; }
    /* background */
    if (mask & 0x08) {
        uint16_t vv = v; unsigned fy = (vv >> 12) & 7;
        for (int tile = 0; tile < 33; tile++) {
            uint8_t nt = *nt_ptr(0x2000 | (vv & 0x0FFF));
            uint8_t at = *nt_ptr(0x23C0 | (vv & 0x0C00) | ((vv >> 4) & 0x38) | ((vv >> 2) & 7));
            int shift = ((vv >> 4) & 4) | (vv & 2);
            unsigned pal = (at >> shift) & 3;
            uint16_t pa = (uint16_t)(((ctrl & 0x10) ? 0x1000 : 0) + nt * 16 + fy);
            uint8_t lo = chr_read(pa), hi = chr_read(pa + 8);
            for (int px = 0; px < 8; px++) {
                int x = tile * 8 + px - fine_x; if (x < 0 || x > 255) continue;
                unsigned c = ((lo >> (7 - px)) & 1) | (((hi >> (7 - px)) & 1) << 1);
                bg[x] = (uint8_t)(c ? (pal << 2 | c) : 0); bgop[x] = c != 0;
            }
            if ((vv & 0x1F) == 31) { vv = (uint16_t)((vv & ~0x1F) ^ 0x400); } else vv++;
        }
        if (!(mask & 0x02)) for (int x = 0; x < 8; x++) { bg[x] = 0; bgop[x] = 0; }
    } else { memset(bg, 0, sizeof bg); memset(bgop, 0, sizeof bgop); }
    uint8_t col[256], prio[256]; memset(prio, 0, sizeof prio);
    for (int x = 0; x < 256; x++) col[x] = bg[x];
    /* sprites */
    if (mask & 0x10) {
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
            if (spzero[x] && bgop[x] && x < 255 && (mask & 0x08)) status |= 0x40;          /* sprite 0 hit */
            if (!bgop[x] || !spri[x]) { col[x] = sp[x]; }
        }
    }
    for (int x = 0; x < 256; x++) {
        uint8_t c = col[x]; if ((c & 3) == 0) c = 0;
        out[x] = PAL[palette[c & 0x1F] & 0x3F];
    }
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
static void advance_line(void) {
    if (line < 240) { render_line(line); end_of_line_updates(); }
    line++; line_start_dot += 341;
    if (line == 241) {                                    /* vblank begins */
        status |= 0x80;
        if (ctrl & 0x80) nmi_pending = 1;
        g_frames++;
        if (g_apu_enabled) apu_render_frame();
        if (present_cb) present_cb(g_frames, (const uint32_t (*)[256])g_frame);
        if (g_quit) longjmp(g_jmp, 99);
    } else if (line == 262) {
        line = 0;
    }
    if (line == 261) {                                    /* pre-render line: flags clear, vertical bits copied */
        status &= (uint8_t)~0xE0;
    }
    if (line == 0 && rendering()) v = (uint16_t)((v & ~0x7BE0) | (t & 0x7BE0));
}
static void catch_up(void) {                              /* run the PPU to the current CPU time */
    uint64_t dots = g_cycles * 3;
    while (line_start_dot + 341 <= dots) advance_line();
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
    if (addr >= 0x2000 && addr < 0x4000) {
        catch_up();
        switch (addr & 7) {
        case 0: { uint8_t old = ctrl; ctrl = d; t = (uint16_t)((t & ~0x0C00) | ((d & 3) << 10)); if (!(old & 0x80) && (d & 0x80) && (status & 0x80)) nmi_pending = 1; break; }
        case 1: mask = d; break;
        case 3: oam_addr = d; break;
        case 4: oam[oam_addr++] = d; break;
        case 5: if (!w_latch) { fine_x = d & 7; t = (uint16_t)((t & ~0x1F) | (d >> 3)); } else { t = (uint16_t)((t & ~0x73E0) | ((d & 7) << 12) | ((d >> 3) << 5)); } w_latch ^= 1; break;
        case 6: if (!w_latch) { t = (uint16_t)((t & 0x00FF) | ((d & 0x3F) << 8)); } else { t = (uint16_t)((t & 0xFF00) | d); v = t; } w_latch ^= 1; break;
        case 7: ppu_write(v & 0x3FFF, d); v = (uint16_t)(v + ((ctrl & 4) ? 32 : 1)); break;
        }
        return;
    }
    if (addr == 0x4014) {                                 /* OAM DMA from CPU page d */
        for (int i = 0; i < 256; i++) oam[(uint8_t)(oam_addr + i)] = g_ram[((d << 8) + i) & 0x7FF];
        g_cycles += 513; return;
    }
    if (addr >= 0x4000 && addr <= 0x4013 || addr == 0x4015 || addr == 0x4017) { apu_write(addr, d); return; }
    if (addr == 0x4016) { pad_idx = 0; return; }                                   /* strobe restarts the shift register */
    if (addr >= 0x8000) {                                  /* MMC1 serial port */
        if (d & 0x80) { mmc_shift = 0; mmc_count = 0; mmc_control |= 0x0C; return; }
        mmc_shift |= (uint8_t)((d & 1) << mmc_count); mmc_count++;
        if (mmc_count == 5) {
            switch ((addr >> 13) & 3) { case 0: mmc_control = mmc_shift; break; case 1: mmc_chr0 = mmc_shift; break; case 2: mmc_chr1 = mmc_shift; break; default: mmc_prg = mmc_shift; g_bank = mmc_prg & 7; }
            mmc_shift = 0; mmc_count = 0;
        }
    }
}

/* ---- interrupts and frame loop --------------------------------------------------------------------------------------- */
void port_poll(void) {
    catch_up();
    if (nmi_pending && !in_nmi) {
        nmi_pending = 0; in_nmi = 1;
        Cpu saved = R; uint8_t sp = R.sp;
        R.sp = (uint8_t)(sp - 3);
        Nmi();
        R = saved; in_nmi = 0;
    }
}
void port_set_present(void (*cb)(unsigned long, const uint32_t (*)[256])) { present_cb = cb; }
void port_set_pad(uint8_t b) { g_pad = b; }
int port_load(const char *path) {
    FILE *f = fopen(path, "rb"); if (!f) return 1;
    uint8_t hdr[16]; if (fread(hdr, 1, 16, f) != 16 || memcmp(hdr, "NES\x1A", 4)) { fclose(f); return 2; }
    if (hdr[4] != 8 || hdr[5] != 16) { fclose(f); return 3; }                      /* this port is for the 128 KB PRG / 128 KB CHR MMC1 board */
    if (fread(g_prg_store, 1, 0x20000, f) != 0x20000 || fread(g_chr, 1, 0x20000, f) != 0x20000) { fclose(f); return 4; }
    fclose(f); g_prg = g_prg_store; return 0;
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
