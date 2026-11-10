#pragma once
#include <stdint.h>
void apu_write(uint16_t addr, uint8_t value);   /* $4000-$4017 */
uint8_t apu_read_status(void);                   /* $4015 */
void apu_render_frame(void);                     /* append one picture of samples to the ring buffer */
void apu_fill(int16_t *out, int n);              /* audio callback: copy samples out (silence on underrun) */
extern int g_apu_enabled;
