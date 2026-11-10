/* Shared machine state and I/O hooks (c/core.c). Used by the hand-lifted routines (golgo13.h) and the mechanical ones (auto/runtime.h).
 * Golgo 13: routines lifted from 6502 assembly to C.
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

