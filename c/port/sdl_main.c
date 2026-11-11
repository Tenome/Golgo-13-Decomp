/* Windowed native port: lifted game logic + c/port/port.c PPU, SDL2 for video, keyboard/gamepad input and (optional) audio.
 *   golgo13_play [ROM] [--scale N] [--fullscreen] [--frames N] [--mute]
 * Built with -DEMBEDDED_ROM (tools/build_port.py --embed) the ROM image is inside the exe and it starts with no arguments at all.
 * Keys: arrows = D-pad, Z = A, X = B, Enter = Start, Right Shift = Select, F11 = full screen, M = mute, Esc = quit. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SDL_MAIN_HANDLED
#include <SDL.h>
#include "port.h"
#ifdef EMBEDDED_ROM
extern const unsigned char g_embedded_rom[]; extern const unsigned long g_embedded_rom_size;
#endif

static SDL_Window *win; static SDL_Renderer *ren; static SDL_Texture *tex;
static int fs; static unsigned long limit; static Uint64 t0; static unsigned long t0_frame;
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
    SDL_Event e; while (SDL_PollEvent(&e)) {
        if (e.type == SDL_QUIT || (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE)) g_quit = 1;
        if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_F11) { fs = !fs; SDL_SetWindowFullscreen(win, fs ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0); }
        if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_m && !e.key.repeat) { g_apu_enabled = !g_apu_enabled; }
    }
    port_set_pad(poll_input());
    SDL_UpdateTexture(tex, NULL, fb, 256 * 4); SDL_RenderClear(ren); SDL_RenderCopy(ren, tex, NULL, NULL); SDL_RenderPresent(ren);
    if (!t0) { t0 = SDL_GetPerformanceCounter(); t0_frame = frame; }
    double want = (double)(frame - t0_frame) / 60.0988;                       /* pace to the console's frame rate */
    double have = (double)(SDL_GetPerformanceCounter() - t0) / SDL_GetPerformanceFrequency();
    if (want > have + 0.002) SDL_Delay((Uint32)((want - have) * 1000.0));
    if (limit && frame >= limit) g_quit = 1;
}
static void SDLCALL audio_cb(void *ud, Uint8 *stream, int len) { (void)ud; apu_fill((int16_t *)stream, len / 2); }
static void fail(const char *msg) { fprintf(stderr, "%s\n", msg); SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Golgo 13", msg, NULL); }
int main(int argc, char **argv) {
    int scale = 3, mute = 0, fullscreen = 0; const char *rom = NULL;
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "--scale") && i + 1 < argc) scale = atoi(argv[++i]);
        else if (!strcmp(argv[i], "--frames") && i + 1 < argc) limit = strtoul(argv[++i], 0, 10);
        else if (!strcmp(argv[i], "--mute")) mute = 1;
        else if (!strcmp(argv[i], "--fullscreen")) fullscreen = 1;
        else if (argv[i][0] != '-') rom = argv[i];
    }
    int rc = 1;
#ifdef EMBEDDED_ROM
    if (!rom) rc = port_load_memory(g_embedded_rom, g_embedded_rom_size); else
#endif
    if (rom) rc = port_load(rom);
    else { fail("No game data: run this program with a ROM path, or use a build made with --embed."); return 2; }
    if (rc) { fail("The ROM could not be loaded (it must be the 256 KB Golgo 13 image)."); return 1; }
    SDL_SetMainReady();
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMECONTROLLER)) { fail(SDL_GetError()); return 1; }
    win = SDL_CreateWindow("Golgo 13", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 256 * scale, 240 * scale, SDL_WINDOW_RESIZABLE | (fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0));
    fs = fullscreen;
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
