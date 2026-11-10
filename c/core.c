#include "golgo13.h"

uint8_t g_ram[0x800];
const uint8_t *g_prg;
uint8_t g_bank;
uint16_t g_iolog_addr[IOLOG_MAX];
uint8_t g_iolog_val[IOLOG_MAX];
int g_iolog_n;
static uint8_t mmc_shift, mmc_count;

static unsigned io_ctr;
void iolog_reset(void) { g_iolog_n = 0; mmc_shift = 0; mmc_count = 0; io_ctr = 0; }
void io_write(uint16_t addr, uint8_t v) {
    if (g_iolog_n < IOLOG_MAX) { g_iolog_addr[g_iolog_n] = addr; g_iolog_val[g_iolog_n] = v; g_iolog_n++; }
    if (addr >= 0x8000) {                       /* MMC1 serial port */
        if (v & 0x80) { mmc_shift = 0; mmc_count = 0; return; }
        mmc_shift |= (uint8_t)((v & 1) << mmc_count); mmc_count++;
        if (mmc_count == 5) { if (addr >= 0xE000) g_bank = mmc_shift & 7; mmc_shift = 0; mmc_count = 0; }
    }
}

/* tests: $2002 and the joypad ports return a deterministic pattern (so polling loops end), everything else reads 0;
 * tools/sim6502.py implements the same pattern. The host replaces this with the real PPU/controller state. */
uint8_t io_read(uint16_t addr) {
    unsigned n = io_ctr++;
    if (addr == 0x2002) return (uint8_t)((n % 3 == 0 ? 0x80 : 0) | (n % 2 == 0 ? 0x40 : 0));
    if (addr == 0x4016 || addr == 0x4017) return (uint8_t)(n & 1);
    return 0;
}

