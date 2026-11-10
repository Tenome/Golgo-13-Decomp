/* Windowed native port: lifted game logic + c/port/port.c PPU, SDL2 for video, keyboard/gamepad input and (optional) audio.
 *   golgo13_play ROM [--scale N] [--frames N] [--mute]
 * Keys: arrows = D-pad, Z = A, X = B, Enter = Start, Right Shift = Select, Esc = quit. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SDL_MAIN_HANDLED
#include <SDL.h>
#include "port.h"

static SDL_Window *win; static SDL_Renderer *ren; static SDL_Texture *tex;
static unsigned long limit; static Uint64 t0; static unsigned long t0_frame;
#include "apu.h"

static uint8_t poll_input(void) {
    const Uint8 *k = SDL_GetKeyboardState(NULL); uint8_t b = 0;
    if (k[SDL_SCANCODE_Z]) b |= 1; if (k[SDL_SCANCODE_X]) b |= 2; if (k[SDL_SCANCODE_RSHIFT]) b |= 4; if (k[SDL_SCANCODE_RETURN]) b |= 8;
    if (k[SDL_SCANCODE_UP]) b |= 16; if (k[SDL_SCANCODE_DOWN]) b |= 32; if (k[SDL_SCANCODE_LEFT]) b |= 64; if (k[SDL_SCANCODE_RIGHT]) b |= 128;
    static SDL_GameController *gc; if (!gc) for (int i = 0; i < SDL_NumJoysticks(); i++) if (SDL_IsGameController(i)) { gc = SDL_GameControllerOpen(i); break; }
    if (gc) {
        if (SDL_GameControllerGetButton(gc, SDL_CONTROLLER_BUTTON_B)) b |= 1; if (SDL_GameControllerGetButton(gc, SDL_CONTROLLER_BUTTON_A)) b |= 2;
        if (SDL_GameControllerGetButton(gc, SDL_CONTROLLER_BUTTON_BACK)) b |= 4; if (SDL_GameControllerGetButton(gc, SDL_CONTROLLER_BUTTON_START)) b |= 8;
        if (SDL_GameControllerGetButton(gc, SDL_CONTROLLER_BUTTON_DPAD_UP)) b |= 16; if (SDL_GameControllerGetButton(gc, SDL_CONTROLLER_BUTTON_DPAD_DOWN)) b |= 32;
        if (SDL_GameControllerGetButton(gc, SDL_CONTROLLER_BUTTON_DPAD_LEFT)) b |= 64; if (SDL_GameControllerGetButton(gc, SDL_CONTROLLER_BUTTON_DPAD_RIGHT)) b |= 128;
        int ax = SDL_GameControllerGetAxis(gc, SDL_CONTROLLER_AXIS_LEFTX); if (ax < -16000) b |= 64; if (ax > 16000) b |= 128;
    }
    return b;
}
static void present(unsigned long frame, const uint32_t (*fb)[256]) {
    SDL_Event e; while (SDL_PollEvent(&e)) if (e.type == SDL_QUIT || (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE)) g_quit = 1;
    port_set_pad(poll_input());
    SDL_UpdateTexture(tex, NULL, fb, 256 * 4); SDL_RenderClear(ren); SDL_RenderCopy(ren, tex, NULL, NULL); SDL_RenderPresent(ren);
    if (!t0) { t0 = SDL_GetPerformanceCounter(); t0_frame = frame; }
    double want = (double)(frame - t0_frame) / 60.0988;                       /* pace to the console's frame rate */
    double have = (double)(SDL_GetPerformanceCounter() - t0) / SDL_GetPerformanceFrequency();
    if (want > have + 0.002) SDL_Delay((Uint32)((want - have) * 1000.0));
    if (limit && frame >= limit) g_quit = 1;
}
static void SDLCALL audio_cb(void *ud, Uint8 *stream, int len) { (void)ud; apu_fill((int16_t *)stream, len / 2); }
int main(int argc, char **argv) {
    int scale = 3, mute = 0;
    if (argc < 2) { fprintf(stderr, "usage: %s ROM [--scale N] [--frames N] [--mute]\n", argv[0]); return 2; }
    for (int i = 2; i < argc; i++) {
        if (!strcmp(argv[i], "--scale") && i + 1 < argc) scale = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--frames") && i + 1 < argc) limit = strtoul(argv[++i], 0, 10);
        else if (!strcmp(argv[i], "--mute")) mute = 1;
    }
    int rc = port_load(argv[1]); if (rc) { fprintf(stderr, "cannot load ROM (%d)\n", rc); return 1; }
    SDL_SetMainReady();
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMECONTROLLER)) { fprintf(stderr, "SDL: %s\n", SDL_GetError()); return 1; }
    win = SDL_CreateWindow("Golgo 13 (native port)", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 256 * scale, 240 * scale, SDL_WINDOW_RESIZABLE);
    ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!ren) ren = SDL_CreateRenderer(win, -1, 0);
    SDL_RenderSetLogicalSize(ren, 256, 240);
    tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, 256, 240);
    if (!mute) {
        SDL_AudioSpec want = {0}, got; want.freq = 44100; want.format = AUDIO_S16SYS; want.channels = 1; want.samples = 1024; want.callback = audio_cb;
        if (SDL_OpenAudio(&want, &got) == 0) { g_apu_enabled = 1; SDL_PauseAudio(0); }
    }
    port_set_present(present); port_run(limit);
    SDL_Quit(); return 0;
}
