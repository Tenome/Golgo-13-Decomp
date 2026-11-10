/* Native port host: machine state, PPU renderer and frame loop for the lifted C (c/auto/<ver>, built with PORT_CYCLES).
 * It provides the same hooks as c/core.c (g_ram, g_prg, g_bank, io_read, io_write, g_pad) with a real PPU behind them, so the
 * game logic runs as plain C. Time is the sum of the nominal cycle counts the lifter emits (CYC); the PPU renders lazily up to
 * the current cycle, which gives mid-frame scroll writes and sprite-0 hits. */
#pragma once
#include <stdint.h>

extern uint64_t g_cycles;                /* CPU cycles since power-on (3 PPU dots each) */
extern uint8_t g_chr[0x20000];           /* 128 KB CHR-ROM, filled by port_load */
extern uint32_t g_frame[240][256];       /* last completed picture, 0x00RRGGBB */
extern unsigned long g_frames;           /* completed pictures */
extern int g_quit;

int port_load(const char *rom_path);     /* iNES file -> PRG/CHR; 0 on success */
void port_poll(void);                    /* interrupt check, called at every loop head of the lifted code */
void port_set_present(void (*cb)(unsigned long frame, const uint32_t (*fb)[256]));
void port_run(unsigned long frames);     /* power on and run until `frames` pictures were produced */
void port_set_pad(uint8_t buttons);      /* controller 1 */
