#include "runtime.h"

Cpu R; int g_budget = 0x7FFFFFFF; jmp_buf g_jmp; int g_abort; const char *g_unsupported_why;

uint8_t rd(uint16_t a) { if (a < 0x2000) return g_ram[a & 0x7FF]; if (a < 0x8000) return io_read(a); return ROMB(a); }
void wr(uint16_t a, uint8_t v) { if (a < 0x2000) g_ram[a & 0x7FF] = v; else io_write(a, v); }
uint16_t rd16zp(uint8_t a) { return (uint16_t)(rd(a) | rd((uint8_t)(a + 1)) << 8); }
uint16_t rd16bug(uint16_t a) { return (uint16_t)(rd(a) | rd((uint16_t)((a & 0xFF00) | ((a + 1) & 0xFF))) << 8); }
void adc(uint8_t m) {
    unsigned r = R.a + m + R.c;
    R.v = (uint8_t)((~(R.a ^ m) & (R.a ^ r) & 0x80) != 0); R.c = r > 0xFF; R.a = (uint8_t)r; NZ(R.a);
}
void sbc(uint8_t m) { adc((uint8_t)~m); }
void cmp8(uint8_t r, uint8_t m) { R.c = r >= m; NZ((uint8_t)(r - m)); }
void bit8(uint8_t m) { R.z = (R.a & m) == 0; R.n = m >> 7; R.v = (m >> 6) & 1; }
uint8_t asl8(uint8_t v) { R.c = v >> 7; v <<= 1; NZ(v); return v; }
uint8_t lsr8(uint8_t v) { R.c = v & 1; v >>= 1; NZ(v); return v; }
uint8_t rol8(uint8_t v) { uint8_t c = R.c; R.c = v >> 7; v = (uint8_t)(v << 1 | c); NZ(v); return v; }
uint8_t ror8(uint8_t v) { uint8_t c = R.c; R.c = v & 1; v = (uint8_t)(v >> 1 | c << 7); NZ(v); return v; }
uint16_t g_ret_exp, g_ret_got;
void ret_check(uint16_t ret) {
    uint16_t got = (uint16_t)(g_ram[0x100 + ((R.sp + 2) & 0xFF)] << 8 | g_ram[0x100 + ((R.sp + 1) & 0xFF)]);
    R.sp += 2; if (got != ret) { g_ret_exp = ret; g_ret_got = got; g_abort = 5; longjmp(g_jmp, 5); }
}
void push16(uint16_t v) { push((uint8_t)(v >> 8)); push((uint8_t)v); }
void push(uint8_t v) { g_ram[0x100 + R.sp] = v; R.sp--; }
uint8_t pull(void) { R.sp++; return g_ram[0x100 + R.sp]; }
uint8_t getp(void) { return (uint8_t)(R.c | R.z << 1 | R.i << 2 | R.d << 3 | R.v << 6 | R.n << 7); }
void setp(uint8_t p) { R.c = p & 1; R.z = (p >> 1) & 1; R.i = (p >> 2) & 1; R.d = (p >> 3) & 1; R.v = (p >> 6) & 1; R.n = (p >> 7) & 1; }
void cpu_brk(void) { g_abort = 2; longjmp(g_jmp, 2); }
void cpu_unsupported(const char *why) { g_unsupported_why = why; g_abort = 3; longjmp(g_jmp, 3); }
uint16_t g_unknown_addr;
void cpu_unknown_target(uint16_t a) { g_unknown_addr = a; g_abort = 4; longjmp(g_jmp, 4); }

/* test/host helper: run a lifted routine with a loop budget; returns 0 or the abort code */
int g_unwind;
int g13_run(void (*f)(void), int budget) { g_budget = budget; g_abort = 0; g_unwind = 0; if (setjmp(g_jmp)) return g_abort; f(); if (g_unwind) { g_unwind = 0; return 6; } return 0; }

/* instruction trace (tools/autotest.py compares it with the 6502 simulator to find the first divergence) */
int g_trace_on; uint16_t g_tr_pc[100000]; uint8_t g_tr_reg[100000][6]; int g_tr_n;
void g13_trace(uint16_t pc) {
    if (g_tr_n >= 100000) return;
    g_tr_pc[g_tr_n] = pc; uint8_t *t = g_tr_reg[g_tr_n++];
    t[0] = R.a; t[1] = R.x; t[2] = R.y; t[3] = R.c; t[4] = R.z; t[5] = R.n;
}
void g13_trace_start(void) { g_tr_n = 0; g_trace_on = 1; }
void g13_trace_stop(void) { g_trace_on = 0; }

const char *g_rts_fn;
void rts_slow(uint8_t sp0, const char *fn) {
    while ((uint8_t)(sp0 - R.sp) >= 2 && (uint8_t)(sp0 - R.sp) < 0x80) {      /* words we pushed ourselves: RTS jumps to the last one + 1 */
        uint8_t lo = pull(); uint16_t t = (uint16_t)((lo | pull() << 8) + 1);
        call_addr(t);
    }
    if (R.sp != sp0) { g_rts_fn = fn; g_ret_exp = 0xE000 | sp0; g_ret_got = 0xE000 | R.sp; g_abort = 6; longjmp(g_jmp, 6); }   /* the routine returned past its caller: not representable */
}
