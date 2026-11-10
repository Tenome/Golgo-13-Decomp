/* Simple NES APU: two pulse channels, triangle and noise (no DMC, no frame IRQ). The lifted sound driver writes the registers;
 * once per picture the port asks for one frame of samples, which go through a ring buffer to the audio callback. */
#include <stdint.h>
#include <string.h>
#include "apu.h"

int g_apu_enabled;
static const uint8_t LEN[32] = {10,254,20,2,40,4,80,6,160,8,60,10,14,12,26,14,12,16,24,18,48,20,96,22,192,24,72,26,16,28,32,30};
static const uint8_t DUTY[4][8] = {{0,1,0,0,0,0,0,0},{0,1,1,0,0,0,0,0},{0,1,1,1,1,0,0,0},{1,0,0,1,1,1,1,1}};
static const uint8_t TRI[32] = {15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
static const uint16_t NOISE_P[16] = {4,8,16,32,64,96,128,160,202,254,380,508,762,1016,2034,4068};

typedef struct { uint8_t duty, constvol, vol, loop, haltlen, sweep_en, sweep_period, sweep_neg, sweep_shift, enabled; uint16_t timer; uint8_t len;
                 uint8_t env_start, env_div, env_decay, sw_div, sw_reload; double phase; } Pulse;
static Pulse pu[2];
static struct { uint8_t linear_reload_val, control, reload, linear, enabled, len; uint16_t timer; double phase; } tri;
static struct { uint8_t constvol, vol, loop, haltlen, mode, enabled, len; uint16_t period; uint8_t env_start, env_div, env_decay; uint16_t lfsr; double acc; } nz = { .period = 4, .lfsr = 1 };

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
static void quarter_tick(void) {                           /* 240 Hz: envelopes and the triangle's linear counter */
    for (int i = 0; i < 2; i++) clock_env(&pu[i].env_start, &pu[i].env_div, &pu[i].env_decay, pu[i].vol, pu[i].loop);
    clock_env(&nz.env_start, &nz.env_div, &nz.env_decay, nz.vol, nz.loop);
    if (tri.reload) tri.linear = tri.linear_reload_val; else if (tri.linear) tri.linear--;
    if (!tri.control) tri.reload = 0;
}
static void half_tick(void) {                              /* 120 Hz: length counters and sweeps */
    for (int i = 0; i < 2; i++) {
        Pulse *p = &pu[i]; if (!p->haltlen && p->len) p->len--;
        if (p->sw_reload) { p->sw_div = p->sweep_period; p->sw_reload = 0; }
        else if (p->sw_div) p->sw_div--;
        else { p->sw_div = p->sweep_period; int t = sweep_target(p, i); if (p->sweep_en && p->sweep_shift && p->timer >= 8 && t <= 0x7FF && t >= 0) p->timer = (uint16_t)t; }
    }
    if (!tri.control && tri.len) tri.len--;
    if (!nz.haltlen && nz.len) nz.len--;
}

#define RATE 44100
static int16_t ring[RATE]; static volatile unsigned rpos, wpos;
void apu_render_frame(void) {                              /* one picture worth of samples (RATE / 60.0988) */
    static double carry; double n = RATE / 60.0988 + carry; int cnt = (int)n; carry = n - cnt;
    static int q, h;
    for (int i = 0; i < cnt; i++) {
        if (++q >= RATE / 240) { q = 0; quarter_tick(); if (h++ & 1) half_tick(); }
        int pv[2] = {0, 0};
        for (int c = 0; c < 2; c++) {
            Pulse *p = &pu[c]; if (!p->len || p->timer < 8 || sweep_target(p, c) > 0x7FF) continue;
            double f = 1789773.0 / (16.0 * (p->timer + 1)); p->phase += f / RATE; p->phase -= (int)p->phase;
            if (DUTY[p->duty][(int)(p->phase * 8)]) pv[c] = p->constvol ? p->vol : p->env_decay;
        }
        int tv = 0;
        if (tri.len && tri.linear && tri.timer >= 2) { double f = 1789773.0 / (32.0 * (tri.timer + 1)); tri.phase += f / RATE; tri.phase -= (int)tri.phase; tv = TRI[(int)(tri.phase * 32)]; }
        int nv = 0;
        if (nz.len) {
            nz.acc += 1789773.0 / nz.period / RATE;
            while (nz.acc >= 1) { nz.acc -= 1; int b = nz.mode ? 6 : 1; uint16_t fb = (uint16_t)((nz.lfsr & 1) ^ ((nz.lfsr >> b) & 1)); nz.lfsr = (uint16_t)((nz.lfsr >> 1) | (fb << 14)); }
            if (!(nz.lfsr & 1)) nv = nz.constvol ? nz.vol : nz.env_decay;
        }
        double ps = pv[0] + pv[1]; double po = ps ? 95.88 / (8128.0 / ps + 100) : 0;
        double ts = tv / 8227.0 + nv / 12241.0; double to = ts ? 159.79 / (1.0 / ts + 100) : 0;
        ring[wpos++ % RATE] = (int16_t)((po + to) * 30000);
    }
}
void apu_fill(int16_t *out, int n) {
    for (int i = 0; i < n; i++) out[i] = (rpos != wpos) ? ring[rpos++ % RATE] : 0;
}
