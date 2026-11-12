/* NES APU for the native port: two pulse channels, triangle and noise (the game never starts the DMC: it only writes $00 to $4010/$4011).
 * The lifted sound driver writes the registers; once per picture the port asks for one frame of samples, which go through a ring buffer
 * to the audio callback.
 *
 * What is modelled (after the documented hardware behaviour):
 *  - the frame counter in CPU cycles, in 4-step or 5-step mode. Golgo 13 writes $C0 to $4017 at start-up, i.e. 5-step mode with no IRQ:
 *    envelopes and the triangle's linear counter tick 4 times and length counters / sweeps 2 times per 37,282 CPU cycles (about 192 Hz / 96 Hz,
 *    not the 240 Hz / 120 Hz of the 4-step mode), and the write itself clocks all of them once;
 *  - pulse duty cycles, envelopes, sweep units with the pulse 1 / pulse 2 negate difference and the mute rules, length counters;
 *  - the triangle with its linear counter, the noise LFSR in both modes;
 *  - the non-linear mixer, 4x oversampling averaged down to 44.1 kHz (against aliasing) and the console's output filters
 *    (high-pass about 90 Hz and 442 Hz, low-pass about 14 kHz).
 * Not modelled: the DMC and the frame IRQ (unused), sub-sample phase accuracy of the channels. */
#include <stdint.h>
#include <string.h>
#include "apu.h"

int g_apu_enabled;
#define CPU_HZ 1789773.0
#define RATE 44100
#define OVERSAMPLE 4
static const uint8_t LEN[32] = {10,254,20,2,40,4,80,6,160,8,60,10,14,12,26,14,12,16,24,18,48,20,96,22,192,24,72,26,16,28,32,30};
static const uint8_t DUTY[4][8] = {{0,1,0,0,0,0,0,0},{0,1,1,0,0,0,0,0},{0,1,1,1,1,0,0,0},{1,0,0,1,1,1,1,1}};
static const uint8_t TRI[32] = {15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
static const uint16_t NOISE_P[16] = {4,8,16,32,64,96,128,160,202,254,380,508,762,1016,2034,4068};

typedef struct { uint8_t duty, constvol, vol, loop, haltlen, sweep_en, sweep_period, sweep_neg, sweep_shift, enabled; uint16_t timer; uint8_t len;
                 uint8_t env_start, env_div, env_decay, sw_div, sw_reload; double phase; } Pulse;
static Pulse pu[2];
static struct { uint8_t linear_reload_val, control, reload, linear, enabled, len; uint16_t timer; double phase; } tri;
static struct { uint8_t constvol, vol, loop, haltlen, mode, enabled, len; uint16_t period; uint8_t env_start, env_div, env_decay; uint16_t lfsr; double acc; } nz = { .period = 4, .lfsr = 1 };

/* ---- frame counter ---- */
static int fc_mode5; static double fc_cycles;
static void quarter_tick(void);
static void half_tick(void);
static void clock_frame_step(int step) {
    if (!fc_mode5) { quarter_tick(); if (step == 1 || step == 3) half_tick(); }
    else { if (step != 3) quarter_tick(); if (step == 1 || step == 4) half_tick(); }
}
static void advance_frame_counter(double cycles) {
    static const double T4[4] = {7457, 14913, 22371, 29829}, T5[5] = {7457, 14913, 22371, 29829, 37281};
    const double *T = fc_mode5 ? T5 : T4; const int n = fc_mode5 ? 5 : 4; const double wrap = fc_mode5 ? 37282 : 29830;
    double before = fc_cycles; fc_cycles += cycles;
    for (int i = 0; i < n; i++) if (before < T[i] && fc_cycles >= T[i]) clock_frame_step(i);
    if (fc_cycles >= wrap) fc_cycles -= wrap;
}

void apu_write(uint16_t a, uint8_t d) {
    if (a >= 0x4000 && a <= 0x4007) {
        Pulse *p = &pu[(a >> 2) & 1];
        switch (a & 3) {
        case 0: p->duty = d >> 6; p->haltlen = (d >> 5) & 1; p->loop = p->haltlen; p->constvol = (d >> 4) & 1; p->vol = d & 15; break;
        case 1: p->sweep_en = d >> 7; p->sweep_period = (d >> 4) & 7; p->sweep_neg = (d >> 3) & 1; p->sweep_shift = d & 7; p->sw_reload = 1; break;
        case 2: p->timer = (uint16_t)((p->timer & 0x700) | d); break;
        case 3: p->timer = (uint16_t)((p->timer & 0xFF) | ((d & 7) << 8)); if (p->enabled) p->len = LEN[d >> 3]; p->env_start = 1; p->phase = 0; break;
        }
        return;
    }
    switch (a) {
    case 0x4008: tri.control = d >> 7; tri.linear_reload_val = d & 0x7F; break;
    case 0x400A: tri.timer = (uint16_t)((tri.timer & 0x700) | d); break;
    case 0x400B: tri.timer = (uint16_t)((tri.timer & 0xFF) | ((d & 7) << 8)); if (tri.enabled) tri.len = LEN[d >> 3]; tri.reload = 1; break;
    case 0x400C: nz.haltlen = (d >> 5) & 1; nz.loop = nz.haltlen; nz.constvol = (d >> 4) & 1; nz.vol = d & 15; break;
    case 0x400E: nz.mode = d >> 7; nz.period = NOISE_P[d & 15]; break;
    case 0x400F: if (nz.enabled) nz.len = LEN[d >> 3]; nz.env_start = 1; break;
    case 0x4015:
        pu[0].enabled = d & 1; pu[1].enabled = (d >> 1) & 1; tri.enabled = (d >> 2) & 1; nz.enabled = (d >> 3) & 1;
        if (!pu[0].enabled) pu[0].len = 0;
        if (!pu[1].enabled) pu[1].len = 0;
        if (!tri.enabled) tri.len = 0;
        if (!nz.enabled) nz.len = 0;
        break;
    case 0x4017:                                           /* frame counter: bit 7 = 5-step mode (the IRQ inhibit bit is not needed) */
        fc_mode5 = d >> 7; fc_cycles = 0;
        if (fc_mode5) { quarter_tick(); half_tick(); }     /* 5-step mode clocks everything once at the write */
        break;
    }
}
uint8_t apu_read_status(void) { return (uint8_t)((pu[0].len > 0) | ((pu[1].len > 0) << 1) | ((tri.len > 0) << 2) | ((nz.len > 0) << 3)); }

static void clock_env(uint8_t *start, uint8_t *div, uint8_t *decay, uint8_t vol, uint8_t loop) {
    if (*start) { *start = 0; *decay = 15; *div = vol; return; }
    if (*div) (*div)--; else { *div = vol; if (*decay) (*decay)--; else if (loop) *decay = 15; }
}
static int sweep_target(Pulse *p, int ch) {
    int d = p->timer >> p->sweep_shift;
    return p->sweep_neg ? p->timer - d - (ch == 0) : p->timer + d;
}
static void quarter_tick(void) {                           /* envelopes and the triangle's linear counter */
    for (int i = 0; i < 2; i++) clock_env(&pu[i].env_start, &pu[i].env_div, &pu[i].env_decay, pu[i].vol, pu[i].loop);
    clock_env(&nz.env_start, &nz.env_div, &nz.env_decay, nz.vol, nz.loop);
    if (tri.reload) tri.linear = tri.linear_reload_val; else if (tri.linear) tri.linear--;
    if (!tri.control) tri.reload = 0;
}
static void half_tick(void) {                              /* length counters and sweeps */
    for (int i = 0; i < 2; i++) {
        Pulse *p = &pu[i]; if (!p->haltlen && p->len) p->len--;
        if (p->sw_reload) { p->sw_div = p->sweep_period; p->sw_reload = 0; }
        else if (p->sw_div) p->sw_div--;
        else { p->sw_div = p->sweep_period; int t = sweep_target(p, i); if (p->sweep_en && p->sweep_shift && p->timer >= 8 && t <= 0x7FF && t >= 0) p->timer = (uint16_t)t; }
    }
    if (!tri.control && tri.len) tri.len--;
    if (!nz.haltlen && nz.len) nz.len--;
}

/* ---- output stage ---- */
static int16_t ring[RATE]; static volatile unsigned rpos, wpos;
static double hp1_prev_in, hp1_prev_out, hp2_prev_in, hp2_prev_out, lp_prev;
static double filter(double x) {                           /* first-order high-pass 90 Hz, high-pass 442 Hz, low-pass 14 kHz at 44.1 kHz */
    const double r1 = 1.0 - 2.0 * 3.14159265358979 * 90.0 / RATE, r2 = 1.0 - 2.0 * 3.14159265358979 * 442.0 / RATE, k = 2.0 * 3.14159265358979 * 14000.0 / RATE;
    double y1 = x - hp1_prev_in + r1 * hp1_prev_out; hp1_prev_in = x; hp1_prev_out = y1;
    double y2 = y1 - hp2_prev_in + r2 * hp2_prev_out; hp2_prev_in = y1; hp2_prev_out = y2;
    lp_prev += (y2 - lp_prev) * (k / (1.0 + k)); return lp_prev;
}
static double mix_one(void) {                              /* one oversampled step (CPU_HZ / (RATE * OVERSAMPLE) CPU cycles) */
    const double dt = 1.0 / (RATE * OVERSAMPLE); int pv[2] = {0, 0};
    for (int c = 0; c < 2; c++) {
        Pulse *p = &pu[c]; if (!p->len || p->timer < 8 || sweep_target(p, c) > 0x7FF) continue;
        double f = CPU_HZ / (16.0 * (p->timer + 1)); p->phase += f * dt; p->phase -= (int)p->phase;
        if (DUTY[p->duty][(int)(p->phase * 8)]) pv[c] = p->constvol ? p->vol : p->env_decay;
    }
    int tv = 0;
    if (tri.len && tri.linear && tri.timer >= 2) { double f = CPU_HZ / (32.0 * (tri.timer + 1)); tri.phase += f * dt; tri.phase -= (int)tri.phase; tv = TRI[(int)(tri.phase * 32)]; }
    int nv = 0;
    if (nz.len) {
        nz.acc += CPU_HZ / nz.period * dt;
        while (nz.acc >= 1) { nz.acc -= 1; int b = nz.mode ? 6 : 1; uint16_t fb = (uint16_t)((nz.lfsr & 1) ^ ((nz.lfsr >> b) & 1)); nz.lfsr = (uint16_t)((nz.lfsr >> 1) | (fb << 14)); }
        if (!(nz.lfsr & 1)) nv = nz.constvol ? nz.vol : nz.env_decay;
    }
    double ps = pv[0] + pv[1]; double po = ps ? 95.88 / (8128.0 / ps + 100) : 0;
    double ts = tv / 8227.0 + nv / 12241.0; double to = ts ? 159.79 / (1.0 / ts + 100) : 0;
    return po + to;
}
void apu_render_frame(void) {                              /* one picture worth of samples (RATE / 60.0988) */
    static double carry; double n = RATE / 60.0988 + carry; int cnt = (int)n; carry = n - cnt;
    for (int i = 0; i < cnt; i++) {
        advance_frame_counter(CPU_HZ / RATE);
        double acc = 0; for (int k = 0; k < OVERSAMPLE; k++) acc += mix_one();
        double y = filter(acc / OVERSAMPLE) * 27500.0;   /* gain chosen to match the loudness of a reference emulator */
        if (y > 32767) y = 32767; if (y < -32768) y = -32768;
        ring[wpos++ % RATE] = (int16_t)y;
    }
}
void apu_fill(int16_t *out, int n) {
    for (int i = 0; i < n; i++) out[i] = (rpos != wpos) ? ring[rpos++ % RATE] : 0;
}
