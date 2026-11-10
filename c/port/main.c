/* Native port driver: runs the lifted game headless or with a frame dump.
 *   golgo13_port ROM [--frames N] [--input route.txt] [--out DIR] [--shot-every N]
 * route.txt uses NESRecomp's format: one `<frame> BUTTONS` line per change (A B SELECT START UP DOWN LEFT RIGHT joined by +, '-' = none). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "port.h"
#include "apu.h"

typedef struct { unsigned long frame; uint8_t buttons; } Step;
static Step steps[100000]; static int nsteps, next_step;
static unsigned long limit = 600, shot_every; static const char *outdir; static FILE *wav; static unsigned wav_samples;

static int load_route(const char *path) {
    FILE *f = fopen(path, "r"); if (!f) return 1; char line[256];
    while (fgets(line, sizeof line, f) && nsteps < 100000) {
        unsigned long fr; char btn[200] = "-"; if (sscanf(line, "%lu %199[^\r\n]", &fr, btn) < 1) continue;
        uint8_t b = 0;
        static const struct { const char *n; uint8_t v; } map[] = {{"A", 1}, {"B", 2}, {"SELECT", 4}, {"START", 8}, {"UP", 16}, {"DOWN", 32}, {"LEFT", 64}, {"RIGHT", 128}};
        for (int i = 0; i < 8; i++) { const char *p = strstr(btn, map[i].n); if (p && (p == btn || p[-1] == '+') && (p[strlen(map[i].n)] == 0 || p[strlen(map[i].n)] == '+')) b |= map[i].v; }
        steps[nsteps].frame = fr; steps[nsteps].buttons = b; nsteps++;
    }
    fclose(f); return 0;
}
static void present(unsigned long frame, const uint32_t (*fb)[256]) {
    while (next_step < nsteps && steps[next_step].frame <= frame) port_set_pad(steps[next_step++].buttons);
    if (outdir && shot_every && frame % shot_every == 0) {
        char path[512]; snprintf(path, sizeof path, "%s/frame_%06lu.ppm", outdir, frame);
        FILE *f = fopen(path, "wb");
        if (f) { fprintf(f, "P6\n256 240\n255\n"); for (int y = 0; y < 240; y++) for (int x = 0; x < 256; x++) { uint32_t c = fb[y][x]; fputc(c >> 16, f); fputc(c >> 8, f); fputc(c, f); } fclose(f); }
    }
    if (wav) { int16_t buf[1024]; unsigned n = 735 + (frame % 5 == 0); apu_fill(buf, (int)n); fwrite(buf, 2, n, wav); wav_samples += n; }
    if (frame >= limit) g_quit = 1;
}
int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: %s ROM [--frames N] [--input route.txt] [--out DIR] [--shot-every N]\n", argv[0]); return 2; }
    for (int i = 2; i < argc; i++) {
        if (!strcmp(argv[i], "--frames") && i + 1 < argc) limit = strtoul(argv[++i], 0, 10);
        else if (!strcmp(argv[i], "--input") && i + 1 < argc) { if (load_route(argv[++i])) { fprintf(stderr, "cannot read route\n"); return 2; } }
        else if (!strcmp(argv[i], "--out") && i + 1 < argc) outdir = argv[++i];
        else if (!strcmp(argv[i], "--shot-every") && i + 1 < argc) shot_every = strtoul(argv[++i], 0, 10);
        else if (!strcmp(argv[i], "--wav") && i + 1 < argc) { wav = fopen(argv[++i], "wb"); if (wav) { g_apu_enabled = 1; unsigned char h[44] = {0}; fwrite(h, 1, 44, wav); } }
    }
    int rc = port_load(argv[1]); if (rc) { fprintf(stderr, "cannot load ROM (%d)\n", rc); return 1; }
    port_set_present(present); port_run(limit);
    if (wav) {                                           /* 44.1 kHz mono 16-bit WAV */
        unsigned bytes = wav_samples * 2, rate = 44100, br = rate * 2; unsigned char h[44] = {'R','I','F','F',0,0,0,0,'W','A','V','E','f','m','t',' ',16,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,2,0,16,0,'d','a','t','a'};
        unsigned v = bytes + 36; memcpy(h + 4, &v, 4); memcpy(h + 24, &rate, 4); memcpy(h + 28, &br, 4); memcpy(h + 40, &bytes, 4);
        fseek(wav, 0, SEEK_SET); fwrite(h, 1, 44, wav); fclose(wav);
    }
    printf("ran %lu frames, %llu CPU cycles\n", g_frames, (unsigned long long)g_cycles);
    return 0;
}
