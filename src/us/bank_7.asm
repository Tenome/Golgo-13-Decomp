; Bank 7  ($C000-$FFFF fixed)
; Fixed bank: reset, NMI, PPU / MMC1 / joypad helpers and the street-scene gameplay loop.
.segment "PRG_BANK_7"

Reset:
  sei                          ; $C000
  lda #$C0                     ; $C001
  sta MMC1_RESET               ; $C003
  sei                          ; $C006
  cld                          ; $C007
  ldx #$00                     ; $C008
  stx PPU_CTRL                 ; $C00A
  stx PPU_MASK                 ; $C00D
  dex                          ; $C010
  txs                          ; $C011
Loc_C012:
  lda PPU_STATUS               ; $C012
  bpl Loc_C012                 ; $C015
Loc_C017:
  lda PPU_STATUS               ; $C017
  bpl Loc_C017                 ; $C01A
  lda #$02                     ; $C01C
  sta z:Tmp00                  ; $C01E
  lda #$00                     ; $C020
  sta z:Tmp01                  ; $C022
  tay                          ; $C024
Loc_C025:
  sta (Tmp00),y                ; $C025
  inc z:Tmp00                  ; $C027
  bne Loc_C025                 ; $C029
  inc z:Tmp01                  ; $C02B
  ldx z:Tmp01                  ; $C02D
  cpx #$08                     ; $C02F
  bmi Loc_C025                 ; $C031
  lda #$00                     ; $C033
  sta APU_DMC_FREQ             ; $C035
  sta APU_DMC_RAW              ; $C038
  lda #$0F                     ; $C03B
  sta APU_SND_CHN              ; $C03D
  lda #$C0                     ; $C040
  sta JOYPAD2                  ; $C042
  lda #$30                     ; $C045
  sta z:GameState              ; $C047
  lda #$1F                     ; $C049
  sta z:MmcControlShadow       ; $C04B
  jsr MmcWriteControl          ; $C04D
  lda #$05                     ; $C050
  sta z:MmcPrgShadow           ; $C052
  jsr MmcWritePrg              ; $C054
  cli                          ; $C057
  lda #$B0                     ; $C058
  jsr SetPpuCtrl               ; $C05A
  lda #$00                     ; $C05D
  jsr SetPpuMask               ; $C05F
  sta $0100                    ; $C062
  sta $0104                    ; $C065
  lda #$C8                     ; $C068
  sta z:PlayerLifeLo           ; $C06A
  lda #$00                     ; $C06C
  sta z:PlayerLifeHi           ; $C06E
  sta z:AmmoLo                 ; $C070
  sta z:AmmoHi                 ; $C072
  lda #$01                     ; $C074
  sta z:$3C                    ; $C076
MainIdleLoop:
  nop                          ; $C078
  nop                          ; $C079
  lda #$01                     ; $C07A
  sta z:$2F                    ; $C07C
  jmp MainIdleLoop             ; $C07E
Nmi:
  jsr MmcWritePrg              ; $C081
  lda z:MmcPrgShadow           ; $C084
  bne Loc_C08B                 ; $C086
  jmp Loc_C0E3                 ; $C088
Loc_C08B:
  jmp $8010                    ; $C08B
  .incbin "prg_bank_7.bin", $008E, $32  ; $C08E
Sub_C0C0:
  dec z:MmcPrgShadow           ; $C0C0
  jsr MmcWritePrg              ; $C0C2
  jsr $AF00                    ; $C0C5
  jsr $8D00                    ; $C0C8
  jsr DrawObjects              ; $C0CB
  inc z:MmcPrgShadow           ; $C0CE
  jsr MmcWritePrg              ; $C0D0
  rts                          ; $C0D3
  .incbin "prg_bank_7.bin", $00D4, $C  ; $C0D4
Loc_C0E0:
  jmp Loc_CB2C                 ; $C0E0
Loc_C0E3:
  jmp Loc_C9F9                 ; $C0E3
CallBank5_A000:
  lda z:MmcPrgShadow           ; $C0E6
  sta $0105                    ; $C0E8
  lda #$05                     ; $C0EB
  sta z:MmcPrgShadow           ; $C0ED
  jsr MmcWritePrg              ; $C0EF
  jsr $A000                    ; $C0F2
  lda $0105                    ; $C0F5
  sta z:MmcPrgShadow           ; $C0F8
  jsr MmcWritePrg              ; $C0FA
  rts                          ; $C0FD
  .incbin "prg_bank_7.bin", $00FE, $2  ; $C0FE
ProcessPpuUpdateList:
  jsr Sub_C170                 ; $C100
  ldx PPU_STATUS               ; $C103
  ldy #$00                     ; $C106
  lda (Tmp00),y                ; $C108
  bpl Loc_C10F                 ; $C10A
  jmp Loc_C16F                 ; $C10C
Loc_C10F:
  pha                          ; $C10F
  sta PPU_ADDR                 ; $C110
  iny                          ; $C113
  lda (Tmp00),y                ; $C114
  sta PPU_ADDR                 ; $C116
  iny                          ; $C119
  lda (Tmp00),y                ; $C11A
  asl a                        ; $C11C
  pha                          ; $C11D
  lda z:PpuCtrlShadow          ; $C11E
  ora #$04                     ; $C120
  bcs Loc_C126                 ; $C122
  and #$FB                     ; $C124
Loc_C126:
  sta PPU_CTRL                 ; $C126
  sta z:PpuCtrlShadow          ; $C129
  pla                          ; $C12B
  asl a                        ; $C12C
  php                          ; $C12D
  bcc Loc_C133                 ; $C12E
  ora #$02                     ; $C130
  iny                          ; $C132
Loc_C133:
  plp                          ; $C133
  clc                          ; $C134
  bne Loc_C138                 ; $C135
  sec                          ; $C137
Loc_C138:
  ror a                        ; $C138
  lsr a                        ; $C139
  tax                          ; $C13A
Loc_C13B:
  bcs Loc_C13E                 ; $C13B
  iny                          ; $C13D
Loc_C13E:
  lda (Tmp00),y                ; $C13E
  sta PPU_DATA                 ; $C140
  dex                          ; $C143
  bne Loc_C13B                 ; $C144
  pla                          ; $C146
  cmp #$3F                     ; $C147
  bne Loc_C157                 ; $C149
  sta PPU_ADDR                 ; $C14B
  stx PPU_ADDR                 ; $C14E
  stx PPU_ADDR                 ; $C151
  stx PPU_ADDR                 ; $C154
Loc_C157:
  sec                          ; $C157
  tya                          ; $C158
  adc z:Tmp00                  ; $C159
  sta z:Tmp00                  ; $C15B
  lda #$00                     ; $C15D
  adc z:Tmp01                  ; $C15F
  sta z:Tmp01                  ; $C161
  ldx PPU_STATUS               ; $C163
  ldy #$00                     ; $C166
  lda (Tmp00),y                ; $C168
  bmi Loc_C16F                 ; $C16A
  jmp Loc_C10F                 ; $C16C
Loc_C16F:
  rts                          ; $C16F
Sub_C170:
  tsx                          ; $C170
  lda $0103,x                  ; $C171
  sta z:$05                    ; $C174
  lda $0104,x                  ; $C176
  sta z:$06                    ; $C179
  ldy #$01                     ; $C17B
  lda ($05),y                  ; $C17D
  sta z:Tmp00                  ; $C17F
  iny                          ; $C181
  lda ($05),y                  ; $C182
  sta z:Tmp01                  ; $C184
  clc                          ; $C186
  lda #$02                     ; $C187
  adc z:$05                    ; $C189
  sta $0103,x                  ; $C18B
  lda #$00                     ; $C18E
  adc z:$06                    ; $C190
  sta $0104,x                  ; $C192
  rts                          ; $C195
ApplyScroll:
  lda PPU_STATUS               ; $C196
  lda z:HwScrollX              ; $C199
  sta PPU_SCROLL               ; $C19B
  lda z:HwScrollY              ; $C19E
  sta PPU_SCROLL               ; $C1A0
  lda z:PpuCtrlShadow          ; $C1A3
  sta PPU_CTRL                 ; $C1A5
  rts                          ; $C1A8
BinToDecimal:
  lda #$00                     ; $C1A9
  sta z:Tmp00                  ; $C1AB
  sta z:Tmp01                  ; $C1AD
  sta z:Tmp02                  ; $C1AF
Loc_C1B1:
  sec                          ; $C1B1
  lda z:Tmp03                  ; $C1B2
  sbc #$64                     ; $C1B4
  sta z:Tmp03                  ; $C1B6
  lda z:$04                    ; $C1B8
  sbc #$00                     ; $C1BA
  sta z:$04                    ; $C1BC
  inc z:Tmp02                  ; $C1BE
  bcs Loc_C1B1                 ; $C1C0
  dec z:Tmp02                  ; $C1C2
  clc                          ; $C1C4
  lda #$64                     ; $C1C5
  adc z:Tmp03                  ; $C1C7
  sta z:Tmp03                  ; $C1C9
  lda #$00                     ; $C1CB
  sta z:$04                    ; $C1CD
Loc_C1CF:
  sec                          ; $C1CF
  lda z:Tmp03                  ; $C1D0
  sbc #$0A                     ; $C1D2
  sta z:Tmp03                  ; $C1D4
  inc z:Tmp01                  ; $C1D6
  bcs Loc_C1CF                 ; $C1D8
  dec z:Tmp01                  ; $C1DA
  clc                          ; $C1DC
  lda #$0A                     ; $C1DD
  adc z:Tmp03                  ; $C1DF
  sta z:Tmp00                  ; $C1E1
  rts                          ; $C1E3
DoOamDma:
  lda #$00                     ; $C1E4
  sta OAM_ADDR                 ; $C1E6
  lda #$02                     ; $C1E9
  sta OAM_DMA                  ; $C1EB
  rts                          ; $C1EE
AslA6:
  asl a                        ; $C1EF
AslA5:
  asl a                        ; $C1F0
AslA4:
  asl a                        ; $C1F1
AslA3:
  asl a                        ; $C1F2
  asl a                        ; $C1F3
  asl a                        ; $C1F4
  rts                          ; $C1F5
LsrA6:
  lsr a                        ; $C1F6
LsrA5:
  lsr a                        ; $C1F7
LsrA4:
  lsr a                        ; $C1F8
LsrA3:
  lsr a                        ; $C1F9
  lsr a                        ; $C1FA
  lsr a                        ; $C1FB
  rts                          ; $C1FC
SetPpuCtrl:
  sta z:PpuCtrlShadow          ; $C1FD
  sta PPU_CTRL                 ; $C1FF
  rts                          ; $C202
SetPpuMask:
  sta z:PpuMaskShadow          ; $C203
  sta PPU_MASK                 ; $C205
  rts                          ; $C208
ResetPpuScroll:
  lda PPU_STATUS               ; $C209  [heuristic code]
  lda #$00                     ; $C20C
  sta PPU_SCROLL               ; $C20E
  sta PPU_SCROLL               ; $C211
  lda z:PpuCtrlShadow          ; $C214
  and #$FC                     ; $C216
  jsr SetPpuCtrl               ; $C218
  rts                          ; $C21B
SetPpuAddrFromBuf:
  lda PPU_STATUS               ; $C21C
  lda PpuAddrBufHi             ; $C21F
  sta PPU_ADDR                 ; $C222
  lda PpuAddrBufLo             ; $C225
  sta PPU_ADDR                 ; $C228
  rts                          ; $C22B
EnqueueByte:
  stx SaveX                    ; $C22C
  inc ByteQueue                ; $C22F
  ldx ByteQueue                ; $C232
  sta ByteQueue,x              ; $C235
  ldx SaveX                    ; $C238
  rts                          ; $C23B
TickClock:
  inc z:FrameCounter           ; $C23C
  inc z:FrameInSecond          ; $C23E
  lda #$3B                     ; $C240
  cmp z:FrameInSecond          ; $C242
  bcc Loc_C247                 ; $C244
  rts                          ; $C246
Loc_C247:
  lda #$00                     ; $C247
  sta z:FrameInSecond          ; $C249
  inc z:SecondCounter          ; $C24B
  rts                          ; $C24D
FillPaletteBlack:
  jsr SetPaletteAddr           ; $C24E
  lda #$0F                     ; $C251
Loc_C253:
  sta PPU_DATA                 ; $C253
  inx                          ; $C256
  cpx #$20                     ; $C257
  bmi Loc_C253                 ; $C259
  jmp Loc_C26C                 ; $C25B
UploadPalette:
  jsr SetPaletteAddr           ; $C25E
Loc_C261:
  lda PaletteBuffer,x          ; $C261
  sta PPU_DATA                 ; $C264
  inx                          ; $C267
  cpx #$20                     ; $C268
  bmi Loc_C261                 ; $C26A
Loc_C26C:
  jsr ResetPpuAddr             ; $C26C
  rts                          ; $C26F
SetPaletteAddr:
  lda z:PpuCtrlShadow          ; $C270
  and #$FB                     ; $C272
  jsr SetPpuCtrl               ; $C274
  lda PPU_STATUS               ; $C277
  ldy #$3F                     ; $C27A
  sty PPU_ADDR                 ; $C27C
  ldx #$00                     ; $C27F
  stx PPU_ADDR                 ; $C281
  rts                          ; $C284
ResetPpuAddr:
  sty PPU_ADDR                 ; $C285
  lda #$00                     ; $C288
  sta PPU_ADDR                 ; $C28A
  sta PPU_ADDR                 ; $C28D
  sta PPU_ADDR                 ; $C290
  rts                          ; $C293
WaitSprite0:
  lda PPU_STATUS               ; $C294
  and #$40                     ; $C297
  bne WaitSprite0              ; $C299
Loc_C29B:
  lda PPU_STATUS               ; $C29B
  and #$40                     ; $C29E
  beq Loc_C29B                 ; $C2A0
  rts                          ; $C2A2
GetRandomByte:
  inc RandomIndex              ; $C2A3
  lda #$1F                     ; $C2A6
  cmp RandomIndex              ; $C2A8
  bcs Loc_C2B2                 ; $C2AB
  lda #$00                     ; $C2AD
  sta RandomIndex              ; $C2AF
Loc_C2B2:
  ldx RandomIndex              ; $C2B2
  lda RandomTable,x            ; $C2B5
  rts                          ; $C2B8
RandomTable:
  .incbin "prg_bank_7.bin", $02B9, $20  ; $C2B9
ReadJoypads:
  lda JoyHeld1                 ; $C2D9
  pha                          ; $C2DC
  ldx #$01                     ; $C2DD
  stx JOYPAD1                  ; $C2DF
  dex                          ; $C2E2
  stx JOYPAD1                  ; $C2E3
  jsr ReadJoypadPort           ; $C2E6
  inx                          ; $C2E9
  jsr ReadJoypadPort           ; $C2EA
  pla                          ; $C2ED
  eor #$FF                     ; $C2EE
  and JoyHeld1                 ; $C2F0
  sta JoyNew1                  ; $C2F3
  rts                          ; $C2F6
ReadJoypadPort:
  ldy #$08                     ; $C2F7
Loc_C2F9:
  lda JOYPAD1,x                ; $C2F9
  sta z:Tmp00                  ; $C2FC
  lsr a                        ; $C2FE
  ora z:Tmp00                  ; $C2FF
  lsr a                        ; $C301
  ror JoyHeld1,x               ; $C302
  dey                          ; $C305
  bne Loc_C2F9                 ; $C306
  rts                          ; $C308
DrawObjects:
  lda $0300                    ; $C309
  asl a                        ; $C30C
  tay                          ; $C30D
  lda Data_C347,y              ; $C30E
  tax                          ; $C311
  lda Data_C348,y              ; $C312
  tay                          ; $C315
  beq Loc_C321                 ; $C316
  lda #$F0                     ; $C318
Loc_C31A:
  sta OamBuffer,x              ; $C31A
  inx                          ; $C31D
  dey                          ; $C31E
  bne Loc_C31A                 ; $C31F
Loc_C321:
  lda ObjectCount              ; $C321
  beq Loc_C346                 ; $C324
  sta z:$08                    ; $C326
  lda #$10                     ; $C328
  sta z:Tmp00                  ; $C32A
  lda #$03                     ; $C32C
  sta z:Tmp01                  ; $C32E
Loc_C330:
  ldy #$03                     ; $C330
  lda (Tmp00),y                ; $C332
  beq Loc_C339                 ; $C334
  jsr Sub_C355                 ; $C336
Loc_C339:
  lda z:Tmp00                  ; $C339
  clc                          ; $C33B
  adc #$10                     ; $C33C
  sta z:Tmp00                  ; $C33E
  dec z:$08                    ; $C340
  lda z:$08                    ; $C342
  bne Loc_C330                 ; $C344
Loc_C346:
  rts                          ; $C346
Data_C347:
  .incbin "prg_bank_7.bin", $0347, $1  ; $C347
Data_C348:
  .incbin "prg_bank_7.bin", $0348, $5  ; $C348
Data_C34D:
  .incbin "prg_bank_7.bin", $034D, $8  ; $C34D
Sub_C355:
  ldy #$00                     ; $C355
  lda (Tmp00),y                ; $C357
  and #$80                     ; $C359
  bne Loc_C360                 ; $C35B
  jmp Loc_C3FB                 ; $C35D
Loc_C360:
  ldy #$03                     ; $C360
  lda (Tmp00),y                ; $C362
  bne Loc_C369                 ; $C364
  jmp Loc_C3FB                 ; $C366
Loc_C369:
  jsr Sub_C3FC                 ; $C369
  ldy #$01                     ; $C36C
  lda (Tmp02),y                ; $C36E
  ldy #$0F                     ; $C370
  sta (Tmp00),y                ; $C372
  lda z:Tmp02                  ; $C374
  clc                          ; $C376
  adc #$02                     ; $C377
  sta z:Tmp02                  ; $C379
  lda z:Tmp03                  ; $C37B
  adc #$00                     ; $C37D
  sta z:Tmp03                  ; $C37F
  ldy #$03                     ; $C381
  lda (Tmp00),y                ; $C383
  and #$FC                     ; $C385
  sta z:$04                    ; $C387
  lda #$02                     ; $C389
  sta z:$05                    ; $C38B
  ldy #$04                     ; $C38D
  lda (Tmp00),y                ; $C38F
  beq Loc_C3FB                 ; $C391
  and #$3F                     ; $C393
  tax                          ; $C395
  ldy #$02                     ; $C396
  lda (Tmp00),y                ; $C398
  sta z:$07                    ; $C39A
  dey                          ; $C39C
  lda (Tmp00),y                ; $C39D
  sta z:$06                    ; $C39F
  dey                          ; $C3A1
Loc_C3A2:
  lda z:$06                    ; $C3A2
  clc                          ; $C3A4
  bmi Loc_C3B2                 ; $C3A5
  lda (Tmp02),y                ; $C3A7
  bpl Loc_C3BD                 ; $C3A9
  adc z:$06                    ; $C3AB
  bmi Loc_C3F0                 ; $C3AD
  jmp Loc_C3BF                 ; $C3AF
Loc_C3B2:
  lda (Tmp02),y                ; $C3B2
  bmi Loc_C3BD                 ; $C3B4
  adc z:$06                    ; $C3B6
  bpl Loc_C3F0                 ; $C3B8
  jmp Loc_C3BF                 ; $C3BA
Loc_C3BD:
  adc z:$06                    ; $C3BD
Loc_C3BF:
  sta ($04),y                  ; $C3BF
  iny                          ; $C3C1
  lda (Tmp02),y                ; $C3C2
  sta ($04),y                  ; $C3C4
  iny                          ; $C3C6
  lda (Tmp02),y                ; $C3C7
  sta ($04),y                  ; $C3C9
  iny                          ; $C3CB
  lda z:$07                    ; $C3CC
  bmi Loc_C3DB                 ; $C3CE
  lda (Tmp02),y                ; $C3D0
  bpl Loc_C3E6                 ; $C3D2
  adc z:$07                    ; $C3D4
  bmi Loc_C3ED                 ; $C3D6
  jmp Loc_C3E8                 ; $C3D8
Loc_C3DB:
  lda (Tmp02),y                ; $C3DB
  bmi Loc_C3E6                 ; $C3DD
  adc z:$07                    ; $C3DF
  bpl Loc_C3ED                 ; $C3E1
  jmp Loc_C3E8                 ; $C3E3
Loc_C3E6:
  adc z:$07                    ; $C3E6
Loc_C3E8:
  sta ($04),y                  ; $C3E8
  jmp Loc_C3F7                 ; $C3EA
Loc_C3ED:
  dey                          ; $C3ED
  dey                          ; $C3EE
  dey                          ; $C3EF
Loc_C3F0:
  lda #$F0                     ; $C3F0
  sta ($04),y                  ; $C3F2
  iny                          ; $C3F4
  iny                          ; $C3F5
  iny                          ; $C3F6
Loc_C3F7:
  iny                          ; $C3F7
  dex                          ; $C3F8
  bne Loc_C3A2                 ; $C3F9
Loc_C3FB:
  rts                          ; $C3FB
Sub_C3FC:
  ldy #$00                     ; $C3FC
  lda (Tmp00),y                ; $C3FE
  and #$3F                     ; $C400
  asl a                        ; $C402
  tay                          ; $C403
  lda z:GameState              ; $C404
  cmp #$10                     ; $C406
  bcs Loc_C413                 ; $C408
  ldx $A800,y                  ; $C40A
  lda $A801,y                  ; $C40D
  jmp Loc_C426                 ; $C410
Loc_C413:
  cmp #$20                     ; $C413
  bcs Loc_C420                 ; $C415
  ldx $B200,y                  ; $C417
  lda $B201,y                  ; $C41A
  jmp Loc_C426                 ; $C41D
Loc_C420:
  ldx $B580,y                  ; $C420
  lda $B581,y                  ; $C423
Loc_C426:
  stx z:Tmp02                  ; $C426
  sta z:Tmp03                  ; $C428
  ldy #$05                     ; $C42A
  lda (Tmp00),y                ; $C42C
  and #$1F                     ; $C42E
  asl a                        ; $C430
  tay                          ; $C431
  lda (Tmp02),y                ; $C432
  tax                          ; $C434
  iny                          ; $C435
  lda (Tmp02),y                ; $C436
  sta z:Tmp03                  ; $C438
  stx z:Tmp02                  ; $C43A
  rts                          ; $C43C
Sub_C43D:
  lda z:Tmp00                  ; $C43D
  sta z:Tmp02                  ; $C43F
  clc                          ; $C441
  adc #$10                     ; $C442
  sta z:$04                    ; $C444
  lda #$03                     ; $C446
  sta z:Tmp03                  ; $C448
  sta z:$05                    ; $C44A
  lda ObjectCount              ; $C44C
  jsr AslA4                    ; $C44F
  sec                          ; $C452
  sbc z:Tmp00                  ; $C453
  bne Loc_C460                 ; $C455
  lda z:Tmp02                  ; $C457
  sta z:$04                    ; $C459
  ldy #$0F                     ; $C45B
  jmp Loc_C46C                 ; $C45D
Loc_C460:
  tax                          ; $C460
  ldy #$00                     ; $C461
Loc_C463:
  lda ($04),y                  ; $C463
  sta (Tmp02),y                ; $C465
  iny                          ; $C467
  dex                          ; $C468
  bne Loc_C463                 ; $C469
  dey                          ; $C46B
Loc_C46C:
  lda #$00                     ; $C46C
  ldx #$10                     ; $C46E
Loc_C470:
  sta ($04),y                  ; $C470
  dey                          ; $C472
  dex                          ; $C473
  bne Loc_C470                 ; $C474
  dec ObjectCount              ; $C476
  lda z:Tmp00                  ; $C479
  sec                          ; $C47B
  sbc #$10                     ; $C47C
  sta z:Tmp00                  ; $C47E
  rts                          ; $C480
  lda z:ScrollPage             ; $C481  [heuristic code]
  and #$01                     ; $C483
  asl a                        ; $C485
  asl a                        ; $C486
  adc #$20                     ; $C487
  sta z:Tmp01                  ; $C489
  lda z:Tmp03                  ; $C48B
  adc z:ScrollX                ; $C48D
  pha                          ; $C48F
  bcc Loc_C499                 ; $C490
  lda z:Tmp01                  ; $C492
  clc                          ; $C494
  adc #$04                     ; $C495
  sta z:Tmp01                  ; $C497
Loc_C499:
  pla                          ; $C499
  and #$F8                     ; $C49A
  lsr a                        ; $C49C
  lsr a                        ; $C49D
  lsr a                        ; $C49E
  sta z:Tmp00                  ; $C49F
  lda z:Tmp02                  ; $C4A1
  adc z:ScrollY                ; $C4A3
  bcc Loc_C4AC                 ; $C4A5
  adc #$0F                     ; $C4A7
  jmp Loc_C4B2                 ; $C4A9
Loc_C4AC:
  cmp #$F0                     ; $C4AC
  bcc Loc_C4B2                 ; $C4AE
  and #$0F                     ; $C4B0
Loc_C4B2:
  pha                          ; $C4B2
  and #$38                     ; $C4B3
  asl a                        ; $C4B5
  asl a                        ; $C4B6
  adc z:Tmp00                  ; $C4B7
  sta z:Tmp00                  ; $C4B9
  pla                          ; $C4BB
  and #$C0                     ; $C4BC
  rol a                        ; $C4BE
  rol a                        ; $C4BF
  rol a                        ; $C4C0
  adc z:Tmp01                  ; $C4C1
  and #$27                     ; $C4C3
  sta z:Tmp01                  ; $C4C5
  rts                          ; $C4C7
Sub_C4C8:
  lda z:Tmp03                  ; $C4C8
  clc                          ; $C4CA
  adc z:ScrollX                ; $C4CB
  lsr a                        ; $C4CD
  lsr a                        ; $C4CE
  lsr a                        ; $C4CF
  sta z:Tmp00                  ; $C4D0
  lda z:Tmp02                  ; $C4D2
  clc                          ; $C4D4
  adc z:ScrollY                ; $C4D5
  pha                          ; $C4D7
  and #$38                     ; $C4D8
  asl a                        ; $C4DA
  asl a                        ; $C4DB
  adc z:Tmp00                  ; $C4DC
  sta z:Tmp00                  ; $C4DE
  pla                          ; $C4E0
  and #$C0                     ; $C4E1
  rol a                        ; $C4E3
  rol a                        ; $C4E4
  rol a                        ; $C4E5
  adc #$20                     ; $C4E6
  sta z:Tmp01                  ; $C4E8
  rts                          ; $C4EA
LoadPaletteSet:
  lda z:MmcPrgShadow           ; $C4EB
  pha                          ; $C4ED
  lda #$02                     ; $C4EE
  sta z:MmcPrgShadow           ; $C4F0
  jsr MmcWritePrg              ; $C4F2
  lda z:PaletteSetIndex        ; $C4F5
  asl a                        ; $C4F7
  tax                          ; $C4F8
  lda $BA6C,x                  ; $C4F9
  jsr AslA4                    ; $C4FC
  clc                          ; $C4FF
  adc #$42                     ; $C500
  sta z:Tmp00                  ; $C502
  lda #$00                     ; $C504
  adc #$BB                     ; $C506
  sta z:Tmp01                  ; $C508
  lda $BA6C,x                  ; $C50A
  jsr LsrA4                    ; $C50D
  clc                          ; $C510
  adc z:Tmp01                  ; $C511
  sta z:Tmp01                  ; $C513
  lda $BA6D,x                  ; $C515
  jsr AslA4                    ; $C518
  clc                          ; $C51B
  adc #$A2                     ; $C51C
  sta z:Tmp02                  ; $C51E
  lda #$00                     ; $C520
  adc #$BD                     ; $C522
  sta z:Tmp03                  ; $C524
  lda $BA6D,x                  ; $C526
  jsr LsrA4                    ; $C529
  clc                          ; $C52C
  adc z:Tmp03                  ; $C52D
  sta z:Tmp03                  ; $C52F
  ldx #$00                     ; $C531
  ldy #$00                     ; $C533
Loc_C535:
  lda (Tmp00),y                ; $C535
  sta PaletteBuffer,x          ; $C537
  iny                          ; $C53A
  inx                          ; $C53B
  cpx #$10                     ; $C53C
  bcc Loc_C535                 ; $C53E
  ldy #$00                     ; $C540
Loc_C542:
  lda (Tmp02),y                ; $C542
  sta PaletteBuffer,x          ; $C544
  iny                          ; $C547
  inx                          ; $C548
  cpx #$20                     ; $C549
  bcc Loc_C542                 ; $C54B
  pla                          ; $C54D
  sta z:MmcPrgShadow           ; $C54E
  jsr MmcWritePrg              ; $C550
  rts                          ; $C553
MmcWriteControl:
  lda z:MmcControlShadow       ; $C554
  sta MMC1_CONTROL             ; $C556
  lsr a                        ; $C559
  sta MMC1_CONTROL             ; $C55A
  lsr a                        ; $C55D
  sta MMC1_CONTROL             ; $C55E
  lsr a                        ; $C561
  sta MMC1_CONTROL             ; $C562
  lsr a                        ; $C565
  sta MMC1_CONTROL             ; $C566
  rts                          ; $C569
MmcWriteChr0:
  lda z:MmcChr0Shadow          ; $C56A
  sta MMC1_CHR0                ; $C56C
  lsr a                        ; $C56F
  sta MMC1_CHR0                ; $C570
  lsr a                        ; $C573
  sta MMC1_CHR0                ; $C574
  lsr a                        ; $C577
  sta MMC1_CHR0                ; $C578
  lsr a                        ; $C57B
  sta MMC1_CHR0                ; $C57C
  rts                          ; $C57F
MmcWriteChr1:
  lda z:MmcChr1Shadow          ; $C580
MmcWriteChr1A:
  sta MMC1_CHR1                ; $C582
  lsr a                        ; $C585
  sta MMC1_CHR1                ; $C586
  lsr a                        ; $C589
  sta MMC1_CHR1                ; $C58A
  lsr a                        ; $C58D
  sta MMC1_CHR1                ; $C58E
  lsr a                        ; $C591
  sta MMC1_CHR1                ; $C592
  rts                          ; $C595
MmcWritePrg:
  lda z:MmcPrgShadow           ; $C596
  sta MMC1_PRG                 ; $C598
  lsr a                        ; $C59B
  sta MMC1_PRG                 ; $C59C
  lsr a                        ; $C59F
  sta MMC1_PRG                 ; $C5A0
  lsr a                        ; $C5A3
  sta MMC1_PRG                 ; $C5A4
  lsr a                        ; $C5A7
  sta MMC1_PRG                 ; $C5A8
  rts                          ; $C5AB
Sub_C5AC:
  lda z:$15                    ; $C5AC
  beq Loc_C5BA                 ; $C5AE
  jsr Sub_CD74                 ; $C5B0
  lda #$00                     ; $C5B3
  sta z:$15                    ; $C5B5
  jmp Loc_C5CA                 ; $C5B7
Loc_C5BA:
  lda #$00                     ; $C5BA
  sta PPU_MASK                 ; $C5BC
  jsr UploadPalette            ; $C5BF
  jsr $90B0                    ; $C5C2
  lda z:PpuMaskShadow          ; $C5C5
  sta PPU_MASK                 ; $C5C7
Loc_C5CA:
  lda z:PpuCtrlShadow          ; $C5CA
  and #$FC                     ; $C5CC
  sta z:PpuCtrlShadow          ; $C5CE
  lda z:ScrollX                ; $C5D0
  sta z:HwScrollX              ; $C5D2
  lda z:ScrollY                ; $C5D4
  sta z:HwScrollY              ; $C5D6
  jsr ApplyScroll              ; $C5D8
  lda JoyHeld1                 ; $C5DB
  and #$F0                     ; $C5DE
  beq Loc_C5FB                 ; $C5E0
  jsr Sub_C5FF                 ; $C5E2
  lda z:$15                    ; $C5E5
  beq Loc_C5FB                 ; $C5E7
  jsr Sub_CE7E                 ; $C5E9
  jsr Sub_CEDA                 ; $C5EC
  jsr ApplyScroll              ; $C5EF
  jsr Sub_C711                 ; $C5F2
  jsr Sub_C77C                 ; $C5F5
  jsr Sub_C7F6                 ; $C5F8
Loc_C5FB:
  jsr Sub_C85F                 ; $C5FB
  rts                          ; $C5FE
Sub_C5FF:
  lda #$00                     ; $C5FF
  sta z:$15                    ; $C601
  lda JoyHeld1                 ; $C603
  and #$C0                     ; $C606
  beq Loc_C671                 ; $C608
  cmp #$40                     ; $C60A
  bne Loc_C637                 ; $C60C
  lda z:ScrollX                ; $C60E
  beq Loc_C61D                 ; $C610
  and #$0F                     ; $C612
  cmp #$08                     ; $C614
  bne Loc_C625                 ; $C616
  inc z:$15                    ; $C618
  jmp Loc_C625                 ; $C61A
Loc_C61D:
  dec z:ScrollPage             ; $C61D
  lda z:ScrollPage             ; $C61F
  and #$03                     ; $C621
  sta z:ScrollPage             ; $C623
Loc_C625:
  lda $0101                    ; $C625
  bne Loc_C62F                 ; $C628
  dec z:ScrollX                ; $C62A
  inc $0494                    ; $C62C
Loc_C62F:
  dec z:ScrollX                ; $C62F
  inc $0494                    ; $C631
  jmp Loc_C671                 ; $C634
Loc_C637:
  lda z:ScrollX                ; $C637
  and #$0F                     ; $C639
  cmp #$08                     ; $C63B
  beq Loc_C65E                 ; $C63D
  lda $0101                    ; $C63F
  bne Loc_C64D                 ; $C642
  lda z:ScrollX                ; $C644
  cmp #$FE                     ; $C646
  bcc Loc_C662                 ; $C648
  jmp Loc_C653                 ; $C64A
Loc_C64D:
  lda z:ScrollX                ; $C64D
  cmp #$FF                     ; $C64F
  bcc Loc_C662                 ; $C651
Loc_C653:
  inc z:ScrollPage             ; $C653
  lda z:ScrollPage             ; $C655
  and #$03                     ; $C657
  sta z:ScrollPage             ; $C659
  jmp Loc_C662                 ; $C65B
Loc_C65E:
  inc z:$15                    ; $C65E
  inc z:$15                    ; $C660
Loc_C662:
  lda $0101                    ; $C662
  bne Loc_C66C                 ; $C665
  inc z:ScrollX                ; $C667
  dec $0494                    ; $C669
Loc_C66C:
  inc z:ScrollX                ; $C66C
  dec $0494                    ; $C66E
Loc_C671:
  lda JoyHeld1                 ; $C671
  and #$30                     ; $C674
  bne Loc_C67B                 ; $C676
  jmp Loc_C710                 ; $C678
Loc_C67B:
  cmp #$10                     ; $C67B
  bne Loc_C6C8                 ; $C67D
  lda $0238                    ; $C67F
  cmp #$18                     ; $C682
  bcc Loc_C6B2                 ; $C684
  lda $0101                    ; $C686
  bne Loc_C69D                 ; $C689
  dec $0238                    ; $C68B
  dec $023C                    ; $C68E
  dec $0240                    ; $C691
  dec $0244                    ; $C694
  dec $0248                    ; $C697
  dec $024C                    ; $C69A
Loc_C69D:
  dec $0238                    ; $C69D
  dec $023C                    ; $C6A0
  dec $0240                    ; $C6A3
  dec $0244                    ; $C6A6
  dec $0248                    ; $C6A9
  dec $024C                    ; $C6AC
  jmp Loc_C710                 ; $C6AF
Loc_C6B2:
  lda z:ScrollY                ; $C6B2
  beq Loc_C710                 ; $C6B4
  lda $0101                    ; $C6B6
  bne Loc_C6C0                 ; $C6B9
  dec z:ScrollY                ; $C6BB
  inc $0493                    ; $C6BD
Loc_C6C0:
  dec z:ScrollY                ; $C6C0
  inc $0493                    ; $C6C2
  jmp Loc_C710                 ; $C6C5
Loc_C6C8:
  lda $0238                    ; $C6C8
  cmp #$88                     ; $C6CB
  bcs Loc_C6FB                 ; $C6CD
  lda $0101                    ; $C6CF
  bne Loc_C6E6                 ; $C6D2
  inc $0238                    ; $C6D4
  inc $023C                    ; $C6D7
  inc $0240                    ; $C6DA
  inc $0244                    ; $C6DD
  inc $0248                    ; $C6E0
  inc $024C                    ; $C6E3
Loc_C6E6:
  inc $0238                    ; $C6E6
  inc $023C                    ; $C6E9
  inc $0240                    ; $C6EC
  inc $0244                    ; $C6EF
  inc $0248                    ; $C6F2
  inc $024C                    ; $C6F5
  jmp Loc_C710                 ; $C6F8
Loc_C6FB:
  lda z:ScrollY                ; $C6FB
  cmp #$4E                     ; $C6FD
  bcs Loc_C710                 ; $C6FF
  lda $0101                    ; $C701
  bne Loc_C70B                 ; $C704
  inc z:ScrollY                ; $C706
  dec $0493                    ; $C708
Loc_C70B:
  inc z:ScrollY                ; $C70B
  dec $0493                    ; $C70D
Loc_C710:
  rts                          ; $C710
Sub_C711:
  lda z:$15                    ; $C711
  cmp #$01                     ; $C713
  bne Loc_C71C                 ; $C715
  lda z:ScrollPage             ; $C717
  jmp Loc_C720                 ; $C719
Loc_C71C:
  ldx z:ScrollPage             ; $C71C
  inx                          ; $C71E
  txa                          ; $C71F
Loc_C720:
  and #$03                     ; $C720
  jsr AslA5                    ; $C722
  sta z:Tmp00                  ; $C725
  lda z:ScrollX                ; $C727
  and #$F0                     ; $C729
  jsr LsrA3                    ; $C72B
  ora z:Tmp00                  ; $C72E
  tay                          ; $C730
  lda ($2C),y                  ; $C731
  sta z:Tmp00                  ; $C733
  iny                          ; $C735
  lda ($2C),y                  ; $C736
  sta z:Tmp01                  ; $C738
  lda $0111                    ; $C73A
  asl a                        ; $C73D
  tax                          ; $C73E
  lda Data_C75B,x              ; $C73F
  sta z:$20                    ; $C742
  sta z:$22                    ; $C744
  lda Data_C75C,x              ; $C746
  sta z:$21                    ; $C749
  sta z:$23                    ; $C74B
  ldx #$00                     ; $C74D
  ldy #$00                     ; $C74F
  jsr Sub_C761                 ; $C751
  ldx #$02                     ; $C754
  iny                          ; $C756
  jsr Sub_C761                 ; $C757
  rts                          ; $C75A
Data_C75B:
  .incbin "prg_bank_7.bin", $075B, $1  ; $C75B
Data_C75C:
  .incbin "prg_bank_7.bin", $075C, $5  ; $C75C
Sub_C761:
  lda a:Tmp00,y                ; $C761
  jsr LsrA5                    ; $C764
  clc                          ; $C767
  adc z:$21,x                  ; $C768
  sta z:$21,x                  ; $C76A
  lda a:Tmp00,y                ; $C76C
  jsr AslA3                    ; $C76F
  clc                          ; $C772
  adc z:$20,x                  ; $C773
  sta z:$20,x                  ; $C775
  bcc Loc_C77B                 ; $C777
  inc z:$21,x                  ; $C779
Loc_C77B:
  rts                          ; $C77B
Sub_C77C:
  ldy #$00                     ; $C77C
Loc_C77E:
  lda ($20),y                  ; $C77E
  asl a                        ; $C780
  asl a                        ; $C781
  sta a:Tmp00,y                ; $C782
  iny                          ; $C785
  cpy #$07                     ; $C786
  bcc Loc_C77E                 ; $C788
  ldy #$00                     ; $C78A
Loc_C78C:
  lda ($22),y                  ; $C78C
  asl a                        ; $C78E
  asl a                        ; $C78F
  sta a:$07,y                  ; $C790
  iny                          ; $C793
  cpy #$08                     ; $C794
  bcc Loc_C78C                 ; $C796
  lda #$02                     ; $C798
  sta z:MmcPrgShadow           ; $C79A
  jsr MmcWritePrg              ; $C79C
  lda $0112                    ; $C79F
  asl a                        ; $C7A2
  tax                          ; $C7A3
  lda Data_C7DC,x              ; $C7A4
  sta z:$F6                    ; $C7A7
  lda Data_C7DD,x              ; $C7A9
  sta z:$F7                    ; $C7AC
  ldy #$00                     ; $C7AE
  ldx #$00                     ; $C7B0
Loc_C7B2:
  tya                          ; $C7B2
  pha                          ; $C7B3
  lda a:Tmp00,y                ; $C7B4
  tay                          ; $C7B7
  lda ($F6),y                  ; $C7B8
  sta z:$60,x                  ; $C7BA
  iny                          ; $C7BC
  lda ($F6),y                  ; $C7BD
  sta z:$80,x                  ; $C7BF
  iny                          ; $C7C1
  lda ($F6),y                  ; $C7C2
  sta z:$61,x                  ; $C7C4
  iny                          ; $C7C6
  lda ($F6),y                  ; $C7C7
  sta z:$81,x                  ; $C7C9
  inx                          ; $C7CB
  inx                          ; $C7CC
  pla                          ; $C7CD
  tay                          ; $C7CE
  iny                          ; $C7CF
  cpy #$0F                     ; $C7D0
  bcc Loc_C7B2                 ; $C7D2
  lda #$02                     ; $C7D4
  sta z:MmcPrgShadow           ; $C7D6
  jsr MmcWritePrg              ; $C7D8
  rts                          ; $C7DB
Data_C7DC:
  .incbin "prg_bank_7.bin", $07DC, $1  ; $C7DC
Data_C7DD:
  .incbin "prg_bank_7.bin", $07DD, $19  ; $C7DD
Sub_C7F6:
  ldy #$00                     ; $C7F6
  ldx #$00                     ; $C7F8
Loc_C7FA:
  lda ($20),y                  ; $C7FA
  and #$C0                     ; $C7FC
  clc                          ; $C7FE
  rol a                        ; $C7FF
  rol a                        ; $C800
  rol a                        ; $C801
  sta z:Tmp00,x                ; $C802
  cpx #$03                     ; $C804
  bcs Loc_C818                 ; $C806
  iny                          ; $C808
  lda ($20),y                  ; $C809
  and #$C0                     ; $C80B
  lsr a                        ; $C80D
  lsr a                        ; $C80E
  ora z:Tmp00,x                ; $C80F
  sta z:Tmp00,x                ; $C811
  iny                          ; $C813
  inx                          ; $C814
  jmp Loc_C7FA                 ; $C815
Loc_C818:
  ldy #$00                     ; $C818
Loc_C81A:
  lda ($22),y                  ; $C81A
  and #$C0                     ; $C81C
  lsr a                        ; $C81E
  lsr a                        ; $C81F
  ora z:Tmp00,x                ; $C820
  sta z:Tmp00,x                ; $C822
  iny                          ; $C824
  inx                          ; $C825
  lda ($22),y                  ; $C826
  and #$C0                     ; $C828
  clc                          ; $C82A
  rol a                        ; $C82B
  rol a                        ; $C82C
  rol a                        ; $C82D
  sta z:Tmp00,x                ; $C82E
  iny                          ; $C830
  cpx #$07                     ; $C831
  bcc Loc_C81A                 ; $C833
  ldx #$00                     ; $C835
  lda z:ScrollX                ; $C837
  and #$10                     ; $C839
  beq Loc_C851                 ; $C83B
Loc_C83D:
  asl z:Tmp00,x                ; $C83D
  asl z:Tmp00,x                ; $C83F
  lda z:$E0,x                  ; $C841
  and #$33                     ; $C843
  ora z:Tmp00,x                ; $C845
  sta z:$E0,x                  ; $C847
  inx                          ; $C849
  cpx #$08                     ; $C84A
  bcc Loc_C83D                 ; $C84C
  jmp Loc_C85E                 ; $C84E
Loc_C851:
  lda z:$E0,x                  ; $C851
  and #$CC                     ; $C853
  ora z:Tmp00,x                ; $C855
  sta z:$E0,x                  ; $C857
  inx                          ; $C859
  cpx #$08                     ; $C85A
  bcc Loc_C851                 ; $C85C
Loc_C85E:
  rts                          ; $C85E
Sub_C85F:
  lda z:ScrollX                ; $C85F
  ldx #$00                     ; $C861
  cmp #$12                     ; $C863
  bcc Loc_C87B                 ; $C865
  ldx #$06                     ; $C867
  cmp #$70                     ; $C869
  bcc Loc_C87B                 ; $C86B
  ldx #$0C                     ; $C86D
  cmp #$92                     ; $C86F
  bcc Loc_C87B                 ; $C871
  ldx #$12                     ; $C873
  cmp #$F0                     ; $C875
  bcc Loc_C87B                 ; $C877
  ldx #$18                     ; $C879
Loc_C87B:
  lda Data_C90B,x              ; $C87B
  sta $022D                    ; $C87E
  lda Data_C90C,x              ; $C881
  sta $022F                    ; $C884
  lda Data_C90D,x              ; $C887
  sta $0231                    ; $C88A
  lda Data_C90E,x              ; $C88D
  sta $0233                    ; $C890
  lda Data_C90F,x              ; $C893
  sta $0235                    ; $C896
  lda Data_C910,x              ; $C899
  sta $0237                    ; $C89C
  ldx z:ScrollPage             ; $C89F
  bne Loc_C8A8                 ; $C8A1
  lda #$D4                     ; $C8A3
  jmp Loc_C8BA                 ; $C8A5
Loc_C8A8:
  dex                          ; $C8A8
  bne Loc_C8B0                 ; $C8A9
  lda #$D8                     ; $C8AB
  jmp Loc_C8BA                 ; $C8AD
Loc_C8B0:
  dex                          ; $C8B0
  bne Loc_C8B8                 ; $C8B1
  lda #$DC                     ; $C8B3
  jmp Loc_C8BA                 ; $C8B5
Loc_C8B8:
  lda #$D0                     ; $C8B8
Loc_C8BA:
  sta z:Tmp00                  ; $C8BA
  ldx #$00                     ; $C8BC
Loc_C8BE:
  lda $022D,x                  ; $C8BE
  cmp #$F0                     ; $C8C1
  bne Loc_C8CA                 ; $C8C3
  lda #$FE                     ; $C8C5
  jmp Loc_C8DC                 ; $C8C7
Loc_C8CA:
  clc                          ; $C8CA
  adc z:Tmp00                  ; $C8CB
  cmp #$D0                     ; $C8CD
  bcs Loc_C8D6                 ; $C8CF
  adc #$10                     ; $C8D1
  jmp Loc_C8DC                 ; $C8D3
Loc_C8D6:
  cmp #$E0                     ; $C8D6
  bcc Loc_C8DC                 ; $C8D8
  sbc #$10                     ; $C8DA
Loc_C8DC:
  sta $022D,x                  ; $C8DC
  inx                          ; $C8DF
  inx                          ; $C8E0
  inx                          ; $C8E1
  inx                          ; $C8E2
  cpx #$0C                     ; $C8E3
  bcc Loc_C8BE                 ; $C8E5
  lda z:ScrollX                ; $C8E7
  lsr a                        ; $C8E9
  sta z:Tmp01                  ; $C8EA
  lda #$BC                     ; $C8EC
  sec                          ; $C8EE
  sbc z:Tmp01                  ; $C8EF
  sta z:Tmp02                  ; $C8F1
  ldx #$00                     ; $C8F3
Loc_C8F5:
  lda $022F,x                  ; $C8F5
  cmp #$F0                     ; $C8F8
  beq Loc_C8FF                 ; $C8FA
  clc                          ; $C8FC
  adc z:Tmp02                  ; $C8FD
Loc_C8FF:
  sta $022F,x                  ; $C8FF
  inx                          ; $C902
  inx                          ; $C903
  inx                          ; $C904
  inx                          ; $C905
  cpx #$0C                     ; $C906
  bcc Loc_C8F5                 ; $C908
  rts                          ; $C90A
Data_C90B:
  .incbin "prg_bank_7.bin", $090B, $1  ; $C90B
Data_C90C:
  .incbin "prg_bank_7.bin", $090C, $1  ; $C90C
Data_C90D:
  .incbin "prg_bank_7.bin", $090D, $1  ; $C90D
Data_C90E:
  .incbin "prg_bank_7.bin", $090E, $1  ; $C90E
Data_C90F:
  .incbin "prg_bank_7.bin", $090F, $1  ; $C90F
Data_C910:
  .incbin "prg_bank_7.bin", $0910, $19  ; $C910
DrawHud:
  lda z:GameState              ; $C929
  cmp #$07                     ; $C92B
  beq Loc_C940                 ; $C92D
  ldy #$00                     ; $C92F
  lda z:FrameCounter           ; $C931
  and #$01                     ; $C933
  bne Loc_C93D                 ; $C935
  jsr Sub_C941                 ; $C937
  jmp Loc_C940                 ; $C93A
Loc_C93D:
  jsr Sub_C962                 ; $C93D
Loc_C940:
  rts                          ; $C940
Sub_C941:
  ldx #$00                     ; $C941
  lda z:GameState              ; $C943
  cmp #$10                     ; $C945
  bcc Loc_C94F                 ; $C947
  cmp #$30                     ; $C949
  bcs Loc_C94F                 ; $C94B
  ldx #$10                     ; $C94D
Loc_C94F:
  ldy #$00                     ; $C94F
  jsr InitHudSprites           ; $C951
  lda z:PlayerLifeLo           ; $C954
  sta z:Tmp03                  ; $C956
  lda z:PlayerLifeHi           ; $C958
  sta z:$04                    ; $C95A
  ldx #$00                     ; $C95C
  jsr DrawHudNumber            ; $C95E
  rts                          ; $C961
Sub_C962:
  ldx #$20                     ; $C962
  lda z:GameState              ; $C964
  cmp #$10                     ; $C966
  bcc Loc_C970                 ; $C968
  cmp #$30                     ; $C96A
  bcs Loc_C970                 ; $C96C
  ldx #$30                     ; $C96E
Loc_C970:
  ldy #$10                     ; $C970
  jsr InitHudSprites           ; $C972
  lda z:AmmoLo                 ; $C975
  sta z:Tmp03                  ; $C977
  lda z:AmmoHi                 ; $C979
  sta z:$04                    ; $C97B
  ldx #$10                     ; $C97D
  jsr DrawHudNumber            ; $C97F
  rts                          ; $C982
InitHudSprites:
  lda #$10                     ; $C983
  sta z:$05                    ; $C985
Loc_C987:
  lda Data_C9B9,x              ; $C987
  sta $02E0,y                  ; $C98A
  inx                          ; $C98D
  iny                          ; $C98E
  dec z:$05                    ; $C98F
  bne Loc_C987                 ; $C991
  rts                          ; $C993
DrawHudNumber:
  jsr BinToDecimal             ; $C994
  lda z:Tmp02                  ; $C997
  bne Loc_C9A2                 ; $C999
  lda z:Tmp01                  ; $C99B
  bne Loc_C9A8                 ; $C99D
  jmp Loc_C9B0                 ; $C99F
Loc_C9A2:
  asl a                        ; $C9A2
  adc #$E4                     ; $C9A3
  sta $02E9,x                  ; $C9A5
Loc_C9A8:
  lda z:Tmp01                  ; $C9A8
  asl a                        ; $C9AA
  adc #$E4                     ; $C9AB
  sta $02E5,x                  ; $C9AD
Loc_C9B0:
  lda z:Tmp00                  ; $C9B0
  asl a                        ; $C9B2
  adc #$E4                     ; $C9B3
  sta $02E1,x                  ; $C9B5
  rts                          ; $C9B8
Data_C9B9:
  .incbin "prg_bank_7.bin", $09B9, $40  ; $C9B9
Loc_C9F9:
  lda z:PpuCtrlShadow          ; $C9F9
  and #$7F                     ; $C9FB
  jsr SetPpuCtrl               ; $C9FD
  jsr TickClock                ; $CA00
  lda $013A                    ; $CA03
  beq Loc_CA0B                 ; $CA06
  jmp Loc_CB95                 ; $CA08
Loc_CA0B:
  jsr Sub_E664                 ; $CA0B
  beq Loc_CA13                 ; $CA0E
  jmp Loc_CB9B                 ; $CA10
Loc_CA13:
  lda z:GameState              ; $CA13
  cmp #$0C                     ; $CA15
  bne Loc_CA1F                 ; $CA17
  jsr Sub_DBD5                 ; $CA19
  jmp Loc_CB9B                 ; $CA1C
Loc_CA1F:
  lda z:GameState              ; $CA1F
  bne Loc_CA5C                 ; $CA21
  lda #$00                     ; $CA23
  sta $0300                    ; $CA25
  lda #$1F                     ; $CA28
  sta z:MmcControlShadow       ; $CA2A
  jsr MmcWriteControl          ; $CA2C
  lda #$00                     ; $CA2F
  sta z:MmcPrgShadow           ; $CA31
  jsr MmcWritePrg              ; $CA33
  lda $0106                    ; $CA36
  cmp #$03                     ; $CA39
  bcs Loc_CA4F                 ; $CA3B
  jsr DoOamDma                 ; $CA3D
  jsr DoOamDma                 ; $CA40
  lda PPU_STATUS               ; $CA43
  jsr Sub_FD61                 ; $CA46
  lda PPU_STATUS               ; $CA49
  jmp Loc_CB8E                 ; $CA4C
Loc_CA4F:
  jsr Sub_CBA3                 ; $CA4F
  inc z:GameState              ; $CA52
  lda #$00                     ; $CA54
  jsr EnqueueByte              ; $CA56
  jmp Loc_CB8E                 ; $CA59
Loc_CA5C:
  cmp #$01                     ; $CA5C
  bne Loc_CA66                 ; $CA5E
  jsr Sub_D0FB                 ; $CA60
  jmp Loc_CB8E                 ; $CA63
Loc_CA66:
  cmp #$02                     ; $CA66
  bne Loc_CA79                 ; $CA68
  jsr Sub_D7B2                 ; $CA6A
  jsr DoOamDma                 ; $CA6D
  jsr Sub_D8CB                 ; $CA70
  lda PPU_STATUS               ; $CA73
  jmp Loc_CB8E                 ; $CA76
Loc_CA79:
  cmp #$03                     ; $CA79
  bne Loc_CA97                 ; $CA7B
  jsr DoOamDma                 ; $CA7D
  jsr Sub_F6BC                 ; $CA80
  jsr UploadPaletteIfDirty     ; $CA83
  jsr ApplyScroll              ; $CA86
  jsr Sub_E939                 ; $CA89
  jsr Sub_F634                 ; $CA8C
  jsr Sub_FB00                 ; $CA8F
  lda #$00                     ; $CA92
  jmp Loc_CB1F                 ; $CA94
Loc_CA97:
  cmp #$04                     ; $CA97
  bne Loc_CAB2                 ; $CA99
  jsr DoOamDma                 ; $CA9B
  jsr Sub_F61E                 ; $CA9E
  jsr ApplyScroll              ; $CAA1
  jsr Sub_F394                 ; $CAA4
  jsr Sub_F698                 ; $CAA7
  jsr Sub_FC1A                 ; $CAAA
  lda #$01                     ; $CAAD
  jmp Loc_CB1F                 ; $CAAF
Loc_CAB2:
  cmp #$05                     ; $CAB2
  bne Loc_CAD0                 ; $CAB4
  jsr DoOamDma                 ; $CAB6
  jsr Sub_F6BC                 ; $CAB9
  jsr UploadPaletteIfDirty     ; $CABC
  jsr ApplyScroll              ; $CABF
  jsr Sub_EF19                 ; $CAC2
  jsr Sub_F664                 ; $CAC5
  jsr Sub_FD18                 ; $CAC8
  lda #$04                     ; $CACB
  jmp Loc_CB1F                 ; $CACD
Loc_CAD0:
  cmp #$06                     ; $CAD0
  bne Loc_CAE6                 ; $CAD2
  jsr DoOamDma                 ; $CAD4
  jsr UploadPalette            ; $CAD7
  jsr ApplyScroll              ; $CADA
  jsr Sub_DF44                 ; $CADD
  jsr DrawHud                  ; $CAE0
  jmp Loc_CB39                 ; $CAE3
Loc_CAE6:
  jsr DoOamDma                 ; $CAE6
  lda $0421                    ; $CAE9
  cmp #$04                     ; $CAEC
  bcs Loc_CB00                 ; $CAEE
  lda z:$30                    ; $CAF0
  cmp #$04                     ; $CAF2
  beq Loc_CB11                 ; $CAF4
  cmp #$08                     ; $CAF6
  bcs Loc_CB11                 ; $CAF8
  jsr UploadPalette            ; $CAFA
  jmp Loc_CB11                 ; $CAFD
Loc_CB00:
  lda #$03                     ; $CB00
  sta z:MmcPrgShadow           ; $CB02
  jsr MmcWritePrg              ; $CB04
  jsr $8081                    ; $CB07
  lda #$00                     ; $CB0A
  sta z:MmcPrgShadow           ; $CB0C
  jsr MmcWritePrg              ; $CB0E
Loc_CB11:
  jsr ApplyScroll              ; $CB11
  jsr Sub_D32D                 ; $CB14
  lda #$06                     ; $CB17
  sta $0300                    ; $CB19
  jmp Loc_CB39                 ; $CB1C
Loc_CB1F:
  sta $0300                    ; $CB1F
  lda #$06                     ; $CB22
  sta z:MmcPrgShadow           ; $CB24
  jsr MmcWritePrg              ; $CB26
  jmp $8010                    ; $CB29
Loc_CB2C:
  lda #$00                     ; $CB2C
  sta z:MmcPrgShadow           ; $CB2E
  jsr MmcWritePrg              ; $CB30
  jsr Sub_E883                 ; $CB33
  jsr DrawHud                  ; $CB36
Loc_CB39:
  jsr Sub_D255                 ; $CB39
  lda z:$15                    ; $CB3C
  bne Loc_CB62                 ; $CB3E
  jsr Sub_DB07                 ; $CB40
  lda $0404                    ; $CB43
  cmp #$FF                     ; $CB46
  beq Loc_CB62                 ; $CB48
  lda #$00                     ; $CB4A
  sta $0421                    ; $CB4C
  sta $0403                    ; $CB4F
  lda #$01                     ; $CB52
  sta $0402                    ; $CB54
  lda z:ScrollX                ; $CB57
  sta z:HwScrollX              ; $CB59
  jsr ApplyScroll              ; $CB5B
  lda #$03                     ; $CB5E
  sta z:MmcPrgShadow           ; $CB60
Loc_CB62:
  jsr Sub_E089                 ; $CB62
  lda $0600                    ; $CB65
  cmp #$60                     ; $CB68
  bne Loc_CB75                 ; $CB6A
  lda #$00                     ; $CB6C
  sta JoyHeld1                 ; $CB6E
  jsr Sub_DBD5                 ; $CB71
Loc_CB74:
  rts                          ; $CB74
Loc_CB75:
  jsr ReadJoypads              ; $CB75
  lda z:PlayerLifeLo           ; $CB78
  beq Loc_CB80                 ; $CB7A
  lda z:PaletteDirty           ; $CB7C
  beq Loc_CB88                 ; $CB7E
Loc_CB80:
  lda #$00                     ; $CB80
  sta JoyHeld1                 ; $CB82
  sta JoyNew1                  ; $CB85
Loc_CB88:
  jsr Sub_F29D                 ; $CB88
  jsr Sub_DBD5                 ; $CB8B
Loc_CB8E:
  lda $0600                    ; $CB8E
  cmp #$60                     ; $CB91
  beq Loc_CB74                 ; $CB93
Loc_CB95:
  jsr CallBank5_A000           ; $CB95
  jsr Sub_E5FD                 ; $CB98
Loc_CB9B:
  lda z:PpuCtrlShadow          ; $CB9B
  ora #$80                     ; $CB9D
  jsr SetPpuCtrl               ; $CB9F
  rti                          ; $CBA2
Sub_CBA3:
  lda #$00                     ; $CBA3
  sta z:$30                    ; $CBA5
  sta $013D                    ; $CBA7
  sta $0114                    ; $CBAA
  sta $0117                    ; $CBAD
  sta $0421                    ; $CBB0
  lda #$10                     ; $CBB3
  sta z:$0F                    ; $CBB5
  lda z:$29                    ; $CBB7
  sta z:PaletteSetIndex        ; $CBB9
  jsr Sub_CCD3                 ; $CBBB
  lda #$01                     ; $CBBE
  sta z:FireMode               ; $CBC0
  lda #$00                     ; $CBC2
  sta $0138                    ; $CBC4
  ldx #$06                     ; $CBC7
  lda #$00                     ; $CBC9
  sta z:Tmp00                  ; $CBCB
  sta z:Tmp01                  ; $CBCD
Loc_CBCF:
  clc                          ; $CBCF
  adc z:PaletteSetIndex        ; $CBD0
  bcc Loc_CBD6                 ; $CBD2
  inc z:Tmp01                  ; $CBD4
Loc_CBD6:
  dex                          ; $CBD6
  bne Loc_CBCF                 ; $CBD7
  sta z:Tmp00                  ; $CBD9
  lda #$09                     ; $CBDB
  clc                          ; $CBDD
  adc z:Tmp00                  ; $CBDE
  sta z:$2C                    ; $CBE0
  bcc Loc_CBE6                 ; $CBE2
  inc z:Tmp01                  ; $CBE4
Loc_CBE6:
  lda #$80                     ; $CBE6
  clc                          ; $CBE8
  adc z:Tmp01                  ; $CBE9
  sta z:$2D                    ; $CBEB
  lda z:$2A                    ; $CBED
  jsr LsrA4                    ; $CBEF
  sta z:ScrollPage             ; $CBF2
  dec z:ScrollPage             ; $CBF4
  lda z:$2A                    ; $CBF6
  jsr AslA4                    ; $CBF8
  sec                          ; $CBFB
  sbc #$08                     ; $CBFC
  sta z:ScrollX                ; $CBFE
  bcs Loc_CC04                 ; $CC00
  dec z:ScrollPage             ; $CC02
Loc_CC04:
  lda #$00                     ; $CC04
  sta z:ScrollY                ; $CC06
  sta z:$15                    ; $CC08
  sta z:PaletteDirty           ; $CC0A
  sta $010E                    ; $CC0C
  sta $010F                    ; $CC0F
  sta z:$32                    ; $CC12
  lda z:PpuCtrlShadow          ; $CC14
  and #$FC                     ; $CC16
  sta z:PpuCtrlShadow          ; $CC18
  ldx #$00                     ; $CC1A
  lda #$0F                     ; $CC1C
Loc_CC1E:
  sta PaletteBuffer,x          ; $CC1E
  inx                          ; $CC21
  cpx #$20                     ; $CC22
  bcc Loc_CC1E                 ; $CC24
  jsr UploadPalette            ; $CC26
  jsr ApplyScroll              ; $CC29
  lda z:PpuMaskShadow          ; $CC2C
  and #$E7                     ; $CC2E
  jsr SetPpuMask               ; $CC30
  lda #$F0                     ; $CC33
  ldx #$00                     ; $CC35
Loc_CC37:
  sta OamBuffer,x              ; $CC37
  inx                          ; $CC3A
  bne Loc_CC37                 ; $CC3B
  ldx #$00                     ; $CC3D
Loc_CC3F:
  lda Data_CC9B,x              ; $CC3F
  sta OamBuffer,x              ; $CC42
  inx                          ; $CC45
  cpx #$38                     ; $CC46
  bcc Loc_CC3F                 ; $CC48
  ldy #$03                     ; $CC4A
  lda ($2C),y                  ; $CC4C
  jsr LsrA4                    ; $CC4E
  sta $0111                    ; $CC51
  lda ($2C),y                  ; $CC54
  and #$0F                     ; $CC56
  sta $0112                    ; $CC58
  iny                          ; $CC5B
  lda ($2C),y                  ; $CC5C
  and #$1F                     ; $CC5E
  sta z:MmcChr0Shadow          ; $CC60
  iny                          ; $CC62
  lda ($2C),y                  ; $CC63
  and #$1F                     ; $CC65
  sta z:MmcChr1Shadow          ; $CC67
  jsr MmcWriteChr0             ; $CC69
  jsr MmcWriteChr1             ; $CC6C
  ldy #$00                     ; $CC6F
  lda ($2C),y                  ; $CC71
  sta z:Tmp02                  ; $CC73
  iny                          ; $CC75
  lda ($2C),y                  ; $CC76
  sta z:Tmp03                  ; $CC78
  iny                          ; $CC7A
  lda ($2C),y                  ; $CC7B
  and #$0F                     ; $CC7D
  asl a                        ; $CC7F
  tay                          ; $CC80
  iny                          ; $CC81
Loc_CC82:
  lda (Tmp02),y                ; $CC82
  sta $0160,y                  ; $CC84
  dey                          ; $CC87
  cpy #$FF                     ; $CC88
  bne Loc_CC82                 ; $CC8A
  ldx #$00                     ; $CC8C
  txa                          ; $CC8E
  sta ObjectCount              ; $CC8F
Loc_CC92:
  sta ObjectTable,x            ; $CC92
  inx                          ; $CC95
  cpx #$F0                     ; $CC96
  bne Loc_CC92                 ; $CC98
  rts                          ; $CC9A
Data_CC9B:
  .incbin "prg_bank_7.bin", $0C9B, $38  ; $CC9B
Sub_CCD3:
  ldx #$00                     ; $CCD3
  lda z:PaletteSetIndex        ; $CCD5
  cmp #$12                     ; $CCD7
  bcc Loc_CCE6                 ; $CCD9
  inx                          ; $CCDB
  cmp #$30                     ; $CCDC
  bcc Loc_CCE6                 ; $CCDE
  inx                          ; $CCE0
  cmp #$40                     ; $CCE1
  bcc Loc_CCE6                 ; $CCE3
  inx                          ; $CCE5
Loc_CCE6:
  stx z:$16                    ; $CCE6
  rts                          ; $CCE8
UploadPaletteIfDirty:
  lda z:PaletteDirty           ; $CCE9
  beq Loc_CCF1                 ; $CCEB
  jsr UploadPalette            ; $CCED
  rts                          ; $CCF0
Loc_CCF1:
  lda z:$15                    ; $CCF1
  beq Loc_CCFF                 ; $CCF3
  jsr Sub_CD74                 ; $CCF5
  lda #$00                     ; $CCF8
  sta z:$15                    ; $CCFA
  jmp Loc_CD2A                 ; $CCFC
Loc_CCFF:
  lda $0421                    ; $CCFF
  cmp #$04                     ; $CD02
  bcs Loc_CD16                 ; $CD04
  lda #$00                     ; $CD06
  sta PPU_MASK                 ; $CD08
  jsr UploadPalette            ; $CD0B
  lda z:PpuMaskShadow          ; $CD0E
  sta PPU_MASK                 ; $CD10
  jmp Loc_CD2A                 ; $CD13
Loc_CD16:
  lda #$03                     ; $CD16
  sta z:MmcPrgShadow           ; $CD18
  jsr MmcWritePrg              ; $CD1A
  jsr $8081                    ; $CD1D
  jsr ApplyScroll              ; $CD20
  lda #$00                     ; $CD23
  sta z:MmcPrgShadow           ; $CD25
  jsr MmcWritePrg              ; $CD27
Loc_CD2A:
  lda z:ScrollX                ; $CD2A
  sta z:HwScrollX              ; $CD2C
  lda z:ScrollY                ; $CD2E
  sta z:HwScrollY              ; $CD30
  jsr ApplyScroll              ; $CD32
  lda JoyHeld1                 ; $CD35
  and #$C0                     ; $CD38
  beq Loc_CD73                 ; $CD3A
  lda z:$13                    ; $CD3C
  bne Loc_CD50                 ; $CD3E
  lda z:FireMode               ; $CD40
  and #$0F                     ; $CD42
  cmp #$01                     ; $CD44
  beq Loc_CD50                 ; $CD46
  cmp #$03                     ; $CD48
  beq Loc_CD50                 ; $CD4A
  cmp #$04                     ; $CD4C
  bne Loc_CD73                 ; $CD4E
Loc_CD50:
  lda #$00                     ; $CD50
  sta z:$15                    ; $CD52
  jsr Sub_CDE0                 ; $CD54
  jsr Sub_D0AB                 ; $CD57
  lda z:$15                    ; $CD5A
  beq Loc_CD73                 ; $CD5C
  jsr Sub_CE7E                 ; $CD5E
  jsr Sub_CEDA                 ; $CD61
  jsr ApplyScroll              ; $CD64
  jsr Sub_CF13                 ; $CD67
  jsr Sub_CFC2                 ; $CD6A
  jsr Sub_D042                 ; $CD6D
  jsr ApplyScroll              ; $CD70
Loc_CD73:
  rts                          ; $CD73
Sub_CD74:
  lda #$00                     ; $CD74
  sta PPU_MASK                 ; $CD76
  lda z:PpuCtrlShadow          ; $CD79
  ora #$04                     ; $CD7B
  jsr SetPpuCtrl               ; $CD7D
  lda PPU_STATUS               ; $CD80
  lda z:$1D                    ; $CD83
  sta PPU_ADDR                 ; $CD85
  lda z:$1C                    ; $CD88
  sta PPU_ADDR                 ; $CD8A
  ldx #$00                     ; $CD8D
Loc_CD8F:
  lda z:$60,x                  ; $CD8F
  sta PPU_DATA                 ; $CD91
  inx                          ; $CD94
  cpx #$1E                     ; $CD95
  bcc Loc_CD8F                 ; $CD97
  lda PPU_STATUS               ; $CD99
  lda z:$1D                    ; $CD9C
  sta PPU_ADDR                 ; $CD9E
  ldx z:$1C                    ; $CDA1
  inx                          ; $CDA3
  stx PPU_ADDR                 ; $CDA4
  ldx #$00                     ; $CDA7
Loc_CDA9:
  lda z:$80,x                  ; $CDA9
  sta PPU_DATA                 ; $CDAB
  inx                          ; $CDAE
  cpx #$1E                     ; $CDAF
  bcc Loc_CDA9                 ; $CDB1
  lda z:PpuCtrlShadow          ; $CDB3
  and #$FB                     ; $CDB5
  jsr SetPpuCtrl               ; $CDB7
  ldx #$00                     ; $CDBA
Loc_CDBC:
  lda PPU_STATUS               ; $CDBC
  lda z:$1F                    ; $CDBF
  sta PPU_ADDR                 ; $CDC1
  lda z:$1E                    ; $CDC4
  sta PPU_ADDR                 ; $CDC6
  lda z:$E0,x                  ; $CDC9
  sta PPU_DATA                 ; $CDCB
  lda z:$1E                    ; $CDCE
  clc                          ; $CDD0
  adc #$08                     ; $CDD1
  sta z:$1E                    ; $CDD3
  inx                          ; $CDD5
  cpx #$08                     ; $CDD6
  bcc Loc_CDBC                 ; $CDD8
  lda z:PpuMaskShadow          ; $CDDA
  sta PPU_MASK                 ; $CDDC
  rts                          ; $CDDF
Sub_CDE0:
  lda z:$32                    ; $CDE0
  beq Loc_CDF9                 ; $CDE2
  lda $023B                    ; $CDE4
  cmp #$78                     ; $CDE7
  beq Loc_CDF9                 ; $CDE9
  bcs Loc_CDF2                 ; $CDEB
  lda #$01                     ; $CDED
  jmp Loc_CDF4                 ; $CDEF
Loc_CDF2:
  lda #$02                     ; $CDF2
Loc_CDF4:
  sta z:$32                    ; $CDF4
  jmp Loc_CE7D                 ; $CDF6
Loc_CDF9:
  lda JoyHeld1                 ; $CDF9
  and #$C0                     ; $CDFC
  cmp #$40                     ; $CDFE
  bne Loc_CE23                 ; $CE00
  lda z:ScrollX                ; $CE02
  beq Loc_CE13                 ; $CE04
  and #$0F                     ; $CE06
  cmp #$08                     ; $CE08
  bne Loc_CE0E                 ; $CE0A
  inc z:$15                    ; $CE0C
Loc_CE0E:
  dec z:ScrollX                ; $CE0E
  jmp Loc_CE79                 ; $CE10
Loc_CE13:
  lda z:ScrollPage             ; $CE13
  bne Loc_CE1C                 ; $CE15
  lda #$01                     ; $CE17
  jmp Loc_CE7B                 ; $CE19
Loc_CE1C:
  dec z:ScrollPage             ; $CE1C
  dec z:ScrollX                ; $CE1E
  jmp Loc_CE79                 ; $CE20
Loc_CE23:
  lda z:ScrollX                ; $CE23
  beq Loc_CE60                 ; $CE25
  and #$0F                     ; $CE27
  cmp #$08                     ; $CE29
  bne Loc_CE31                 ; $CE2B
  inc z:$15                    ; $CE2D
  inc z:$15                    ; $CE2F
Loc_CE31:
  lda z:$13                    ; $CE31
  cmp #$03                     ; $CE33
  bne Loc_CE53                 ; $CE35
  lda z:ScrollX                ; $CE37
  cmp #$FE                     ; $CE39
  bcc Loc_CE46                 ; $CE3B
  inc z:ScrollPage             ; $CE3D
  lda #$00                     ; $CE3F
  sta z:ScrollX                ; $CE41
  jmp Loc_CE79                 ; $CE43
Loc_CE46:
  inc z:ScrollX                ; $CE46
  inc z:ScrollX                ; $CE48
  lda z:ScrollX                ; $CE4A
  and #$FE                     ; $CE4C
  sta z:ScrollX                ; $CE4E
  jmp Loc_CE79                 ; $CE50
Loc_CE53:
  lda z:ScrollX                ; $CE53
  cmp #$FF                     ; $CE55
  bne Loc_CE5B                 ; $CE57
  inc z:ScrollPage             ; $CE59
Loc_CE5B:
  inc z:ScrollX                ; $CE5B
  jmp Loc_CE79                 ; $CE5D
Loc_CE60:
  ldy #$02                     ; $CE60
  lda ($2C),y                  ; $CE62
  and #$0F                     ; $CE64
  cmp z:ScrollPage             ; $CE66
  bne Loc_CE6F                 ; $CE68
  lda #$02                     ; $CE6A
  jmp Loc_CE7B                 ; $CE6C
Loc_CE6F:
  lda z:$13                    ; $CE6F
  cmp #$03                     ; $CE71
  bne Loc_CE77                 ; $CE73
  inc z:ScrollX                ; $CE75
Loc_CE77:
  inc z:ScrollX                ; $CE77
Loc_CE79:
  lda #$00                     ; $CE79
Loc_CE7B:
  sta z:$32                    ; $CE7B
Loc_CE7D:
  rts                          ; $CE7D
Sub_CE7E:
  lda z:ScrollX                ; $CE7E
  and #$F0                     ; $CE80
  lsr a                        ; $CE82
  lsr a                        ; $CE83
  tax                          ; $CE84
  lda Data_CE9A,x              ; $CE85
  sta z:$1C                    ; $CE88
  lda Data_CE9B,x              ; $CE8A
  sta z:$1D                    ; $CE8D
  lda Data_CE9C,x              ; $CE8F
  sta z:$1E                    ; $CE92
  lda Data_CE9D,x              ; $CE94
  sta z:$1F                    ; $CE97
  rts                          ; $CE99
Data_CE9A:
  .incbin "prg_bank_7.bin", $0E9A, $1  ; $CE9A
Data_CE9B:
  .incbin "prg_bank_7.bin", $0E9B, $1  ; $CE9B
Data_CE9C:
  .incbin "prg_bank_7.bin", $0E9C, $1  ; $CE9C
Data_CE9D:
  .incbin "prg_bank_7.bin", $0E9D, $3D  ; $CE9D
Sub_CEDA:
  lda z:PpuCtrlShadow          ; $CEDA
  and #$FB                     ; $CEDC
  jsr SetPpuCtrl               ; $CEDE
  lda PPU_STATUS               ; $CEE1
  lda z:$1F                    ; $CEE4
  sta PPU_ADDR                 ; $CEE6
  lda z:$1E                    ; $CEE9
  sta PPU_ADDR                 ; $CEEB
  lda PPU_DATA                 ; $CEEE
  ldx #$00                     ; $CEF1
Loc_CEF3:
  lda PPU_DATA                 ; $CEF3
  sta z:$E0,x                  ; $CEF6
  lda PPU_DATA                 ; $CEF8
  lda PPU_DATA                 ; $CEFB
  lda PPU_DATA                 ; $CEFE
  lda PPU_DATA                 ; $CF01
  lda PPU_DATA                 ; $CF04
  lda PPU_DATA                 ; $CF07
  lda PPU_DATA                 ; $CF0A
  inx                          ; $CF0D
  cpx #$08                     ; $CF0E
  bcc Loc_CEF3                 ; $CF10
  rts                          ; $CF12
Sub_CF13:
  lda z:ScrollPage             ; $CF13
  asl a                        ; $CF15
  tax                          ; $CF16
  lda z:$15                    ; $CF17
  cmp #$01                     ; $CF19
  beq Loc_CF1F                 ; $CF1B
  inx                          ; $CF1D
  inx                          ; $CF1E
Loc_CF1F:
  lda $0160,x                  ; $CF1F
  sta z:Tmp00                  ; $CF22
  lda $0161,x                  ; $CF24
  sta z:Tmp01                  ; $CF27
  lda #$B5                     ; $CF29
  sta z:Tmp02                  ; $CF2B
  sta z:$04                    ; $CF2D
  lda #$84                     ; $CF2F
  sta z:Tmp03                  ; $CF31
  sta z:$05                    ; $CF33
  ldx #$00                     ; $CF35
  ldy #$00                     ; $CF37
  jsr Sub_CF84                 ; $CF39
  ldx #$02                     ; $CF3C
  iny                          ; $CF3E
  jsr Sub_CF84                 ; $CF3F
  lda z:ScrollX                ; $CF42
  and #$F0                     ; $CF44
  jsr LsrA4                    ; $CF46
  tay                          ; $CF49
  lda (Tmp02),y                ; $CF4A
  sta z:$06                    ; $CF4C
  lda ($04),y                  ; $CF4E
  sta z:$07                    ; $CF50
  lda $0111                    ; $CF52
  asl a                        ; $CF55
  tax                          ; $CF56
  lda Data_CF74,x              ; $CF57
  tay                          ; $CF5A
  lda Data_CF75,x              ; $CF5B
  sty z:$20                    ; $CF5E
  sty z:$22                    ; $CF60
  sta z:$21                    ; $CF62
  sta z:$23                    ; $CF64
  ldx #$00                     ; $CF66
  ldy #$00                     ; $CF68
  jsr Sub_CFA3                 ; $CF6A
  ldx #$02                     ; $CF6D
  iny                          ; $CF6F
  jsr Sub_CFA3                 ; $CF70
  rts                          ; $CF73
Data_CF74:
  .incbin "prg_bank_7.bin", $0F74, $1  ; $CF74
Data_CF75:
  .incbin "prg_bank_7.bin", $0F75, $F  ; $CF75
Sub_CF84:
  lda a:Tmp00,y                ; $CF84
  and #$F0                     ; $CF87
  jsr LsrA4                    ; $CF89
  clc                          ; $CF8C
  adc z:Tmp03,x                ; $CF8D
  sta z:Tmp03,x                ; $CF8F
  lda a:Tmp00,y                ; $CF91
  and #$0F                     ; $CF94
  jsr AslA4                    ; $CF96
  clc                          ; $CF99
  adc z:Tmp02,x                ; $CF9A
  sta z:Tmp02,x                ; $CF9C
  bcc Loc_CFA2                 ; $CF9E
  inc z:Tmp03,x                ; $CFA0
Loc_CFA2:
  rts                          ; $CFA2
Sub_CFA3:
  lda a:$06,y                  ; $CFA3
  and #$E0                     ; $CFA6
  jsr LsrA5                    ; $CFA8
  clc                          ; $CFAB
  adc z:$21,x                  ; $CFAC
  sta z:$21,x                  ; $CFAE
  lda a:$06,y                  ; $CFB0
  and #$1F                     ; $CFB3
  jsr AslA3                    ; $CFB5
  clc                          ; $CFB8
  adc z:$20,x                  ; $CFB9
  sta z:$20,x                  ; $CFBB
  bcc Loc_CFC1                 ; $CFBD
  inc z:$21,x                  ; $CFBF
Loc_CFC1:
  rts                          ; $CFC1
Sub_CFC2:
  ldy #$00                     ; $CFC2
Loc_CFC4:
  lda ($20),y                  ; $CFC4
  and #$3F                     ; $CFC6
  asl a                        ; $CFC8
  asl a                        ; $CFC9
  sta a:Tmp00,y                ; $CFCA
  iny                          ; $CFCD
  cpy #$07                     ; $CFCE
  bcc Loc_CFC4                 ; $CFD0
  ldy #$00                     ; $CFD2
Loc_CFD4:
  lda ($22),y                  ; $CFD4
  and #$3F                     ; $CFD6
  asl a                        ; $CFD8
  asl a                        ; $CFD9
  sta a:$07,y                  ; $CFDA
  iny                          ; $CFDD
  cpy #$08                     ; $CFDE
  bcc Loc_CFD4                 ; $CFE0
  lda z:MmcPrgShadow           ; $CFE2
  pha                          ; $CFE4
  lda #$02                     ; $CFE5
  sta z:MmcPrgShadow           ; $CFE7
  jsr MmcWritePrg              ; $CFE9
  lda $0112                    ; $CFEC
  asl a                        ; $CFEF
  tay                          ; $CFF0
  lda Data_D028,y              ; $CFF1
  sta z:$F6                    ; $CFF4
  lda Data_D029,y              ; $CFF6
  sta z:$F7                    ; $CFF9
  ldx #$00                     ; $CFFB
  ldy #$00                     ; $CFFD
Loc_CFFF:
  tya                          ; $CFFF
  pha                          ; $D000
  lda a:Tmp00,y                ; $D001
  tay                          ; $D004
  lda ($F6),y                  ; $D005
  sta z:$60,x                  ; $D007
  iny                          ; $D009
  lda ($F6),y                  ; $D00A
  sta z:$80,x                  ; $D00C
  iny                          ; $D00E
  lda ($F6),y                  ; $D00F
  sta z:$61,x                  ; $D011
  iny                          ; $D013
  lda ($F6),y                  ; $D014
  sta z:$81,x                  ; $D016
  inx                          ; $D018
  inx                          ; $D019
  pla                          ; $D01A
  tay                          ; $D01B
  iny                          ; $D01C
  cpy #$0F                     ; $D01D
  bcc Loc_CFFF                 ; $D01F
  pla                          ; $D021
  sta z:MmcPrgShadow           ; $D022
  jsr MmcWritePrg              ; $D024
  rts                          ; $D027
Data_D028:
  .incbin "prg_bank_7.bin", $1028, $1  ; $D028
Data_D029:
  .incbin "prg_bank_7.bin", $1029, $19  ; $D029
Sub_D042:
  ldy #$00                     ; $D042
  ldx #$00                     ; $D044
Loc_D046:
  lda ($20),y                  ; $D046
  and #$C0                     ; $D048
  clc                          ; $D04A
  rol a                        ; $D04B
  rol a                        ; $D04C
  rol a                        ; $D04D
  sta z:Tmp00,x                ; $D04E
  cpx #$03                     ; $D050
  bcs Loc_D064                 ; $D052
  iny                          ; $D054
  lda ($20),y                  ; $D055
  and #$C0                     ; $D057
  lsr a                        ; $D059
  lsr a                        ; $D05A
  ora z:Tmp00,x                ; $D05B
  sta z:Tmp00,x                ; $D05D
  iny                          ; $D05F
  inx                          ; $D060
  jmp Loc_D046                 ; $D061
Loc_D064:
  ldy #$00                     ; $D064
Loc_D066:
  lda ($22),y                  ; $D066
  and #$C0                     ; $D068
  lsr a                        ; $D06A
  lsr a                        ; $D06B
  ora z:Tmp00,x                ; $D06C
  sta z:Tmp00,x                ; $D06E
  iny                          ; $D070
  inx                          ; $D071
  lda ($22),y                  ; $D072
  and #$C0                     ; $D074
  clc                          ; $D076
  rol a                        ; $D077
  rol a                        ; $D078
  rol a                        ; $D079
  sta z:Tmp00,x                ; $D07A
  iny                          ; $D07C
  cpx #$07                     ; $D07D
  bcc Loc_D066                 ; $D07F
  ldx #$00                     ; $D081
  lda z:ScrollX                ; $D083
  and #$10                     ; $D085
  beq Loc_D09D                 ; $D087
Loc_D089:
  asl z:Tmp00,x                ; $D089
  asl z:Tmp00,x                ; $D08B
  lda z:$E0,x                  ; $D08D
  and #$33                     ; $D08F
  ora z:Tmp00,x                ; $D091
  sta z:$E0,x                  ; $D093
  inx                          ; $D095
  cpx #$08                     ; $D096
  bcc Loc_D089                 ; $D098
  jmp Loc_D0AA                 ; $D09A
Loc_D09D:
  lda z:$E0,x                  ; $D09D
  and #$CC                     ; $D09F
  ora z:Tmp00,x                ; $D0A1
  sta z:$E0,x                  ; $D0A3
  inx                          ; $D0A5
  cpx #$08                     ; $D0A6
  bcc Loc_D09D                 ; $D0A8
Loc_D0AA:
  rts                          ; $D0AA
Sub_D0AB:
  lda z:$32                    ; $D0AB
  beq Loc_D0FA                 ; $D0AD
  cmp #$01                     ; $D0AF
  bne Loc_D0D8                 ; $D0B1
  lda JoyHeld1                 ; $D0B3
  and #$C0                     ; $D0B6
  beq Loc_D0FA                 ; $D0B8
  cmp #$40                     ; $D0BA
  bne Loc_D0CB                 ; $D0BC
  lda $023B                    ; $D0BE
  cmp #$11                     ; $D0C1
  bcc Loc_D0FA                 ; $D0C3
  dec $023B                    ; $D0C5
  jmp Loc_D0FA                 ; $D0C8
Loc_D0CB:
  lda $023B                    ; $D0CB
  cmp #$78                     ; $D0CE
  bcs Loc_D0FA                 ; $D0D0
  inc $023B                    ; $D0D2
  jmp Loc_D0FA                 ; $D0D5
Loc_D0D8:
  lda JoyHeld1                 ; $D0D8
  and #$C0                     ; $D0DB
  beq Loc_D0FA                 ; $D0DD
  cmp #$40                     ; $D0DF
  bne Loc_D0F0                 ; $D0E1
  lda $023B                    ; $D0E3
  cmp #$79                     ; $D0E6
  bcc Loc_D0F0                 ; $D0E8
  dec $023B                    ; $D0EA
  jmp Loc_D0FA                 ; $D0ED
Loc_D0F0:
  lda $023B                    ; $D0F0
  cmp #$E0                     ; $D0F3
  bcs Loc_D0FA                 ; $D0F5
  inc $023B                    ; $D0F7
Loc_D0FA:
  rts                          ; $D0FA
Sub_D0FB:
  lda #$00                     ; $D0FB
  jsr SetPpuMask               ; $D0FD
  lda z:ScrollX                ; $D100
  clc                          ; $D102
  adc #$10                     ; $D103
  sta z:ScrollX                ; $D105
  bcc Loc_D10B                 ; $D107
  inc z:ScrollPage             ; $D109
Loc_D10B:
  lda #$80                     ; $D10B
  sta JoyHeld1                 ; $D10D
  lda z:ScrollX                ; $D110
  and #$F0                     ; $D112
  ora #$08                     ; $D114
  sta z:ScrollX                ; $D116
  jsr DoOamDma                 ; $D118
  jsr UploadPaletteIfDirty     ; $D11B
  jsr ApplyScroll              ; $D11E
  lda z:FrameCounter           ; $D121
  and #$FE                     ; $D123
  sta z:FrameCounter           ; $D125
  lda z:$0F                    ; $D127
  beq Loc_D12E                 ; $D129
  dec z:$0F                    ; $D12B
  rts                          ; $D12D
Loc_D12E:
  sta JoyHeld1                 ; $D12E
  lda z:ScrollX                ; $D131
  and #$F0                     ; $D133
  sta z:ScrollX                ; $D135
  inc z:GameState              ; $D137
  rts                          ; $D139
Sub_D13A:
  jsr LoadPaletteSet           ; $D13A
  jsr UploadPalette            ; $D13D
  lda $0153                    ; $D140
  sta $0116                    ; $D143
  lda z:ScrollX                ; $D146
  sta z:HwScrollX              ; $D148
  jsr ApplyScroll              ; $D14A
  jsr Sub_F4B8                 ; $D14D
  lda #$00                     ; $D150
  sta z:$28                    ; $D152
  sta z:$29                    ; $D154
  sta z:$2A                    ; $D156
  sta z:$2B                    ; $D158
  sta z:$15                    ; $D15A
  jsr MmcWriteChr0             ; $D15C
  jsr MmcWriteChr1             ; $D15F
  ldy #$02                     ; $D162
  lda ($2C),y                  ; $D164
  jsr LsrA4                    ; $D166
  clc                          ; $D169
  adc #$03                     ; $D16A
  sta z:GameState              ; $D16C
  lda #$18                     ; $D16E
  jsr SetPpuMask               ; $D170
  jsr Sub_D177                 ; $D173
  rts                          ; $D176
Sub_D177:
  lda z:PaletteSetIndex        ; $D177
  asl a                        ; $D179
  tax                          ; $D17A
  lda Data_D1B7,x              ; $D17B
  and #$80                     ; $D17E
  beq Loc_D1A2                 ; $D180
  lda $0100                    ; $D182
  asl a                        ; $D185
  tay                          ; $D186
  lda Data_F6EC,y              ; $D187
  sta z:Tmp00                  ; $D18A
  lda Data_F6ED,y              ; $D18C
  sta z:Tmp01                  ; $D18F
  ldy #$00                     ; $D191
Loc_D193:
  lda (Tmp00),y                ; $D193
  cmp z:PaletteSetIndex        ; $D195
  beq Loc_D1A2                 ; $D197
  cmp #$FF                     ; $D199
  beq Loc_D1B6                 ; $D19B
  iny                          ; $D19D
  iny                          ; $D19E
  jmp Loc_D193                 ; $D19F
Loc_D1A2:
  txa                          ; $D1A2
  pha                          ; $D1A3
  lda Data_D1B7,x              ; $D1A4
  and #$3F                     ; $D1A7
  jsr EnqueueByte              ; $D1A9
  pla                          ; $D1AC
  tax                          ; $D1AD
  lda Data_D1B8,x              ; $D1AE
  beq Loc_D1B6                 ; $D1B1
  jsr EnqueueByte              ; $D1B3
Loc_D1B6:
  rts                          ; $D1B6
Data_D1B7:
  .incbin "prg_bank_7.bin", $11B7, $1  ; $D1B7
Data_D1B8:
  .incbin "prg_bank_7.bin", $11B8, $9D  ; $D1B8
Sub_D255:
  lda z:GameState              ; $D255
  cmp #$03                     ; $D257
  bne Loc_D28D                 ; $D259
  lda z:$15                    ; $D25B
  bne Loc_D28D                 ; $D25D
  lda $0113                    ; $D25F
  bne Loc_D28D                 ; $D262
  ldy ObjectCount              ; $D264
  beq Loc_D28D                 ; $D267
  ldx #$00                     ; $D269
Loc_D26B:
  lda $0317,x                  ; $D26B
  cmp #$80                     ; $D26E
  bcs Loc_D27B                 ; $D270
  txa                          ; $D272
  clc                          ; $D273
  adc #$10                     ; $D274
  tax                          ; $D276
  dey                          ; $D277
  bne Loc_D26B                 ; $D278
  rts                          ; $D27A
Loc_D27B:
  sec                          ; $D27B
  sbc #$80                     ; $D27C
  sta $0400                    ; $D27E
  jsr Sub_D28E                 ; $D281
  beq Loc_D28D                 ; $D284
  sta $0113                    ; $D286
  lda #$03                     ; $D289
  sta z:MmcPrgShadow           ; $D28B
Loc_D28D:
  rts                          ; $D28D
Sub_D28E:
  lda $0311,x                  ; $D28E
  sta z:Tmp00                  ; $D291
  lda $0312,x                  ; $D293
  sta z:Tmp01                  ; $D296
  lda $0238                    ; $D298
  sec                          ; $D29B
  sbc z:Tmp00                  ; $D29C
  cmp #$F0                     ; $D29E
  bcs Loc_D2A6                 ; $D2A0
  cmp #$10                     ; $D2A2
  bcs Loc_D305                 ; $D2A4
Loc_D2A6:
  lda $023B                    ; $D2A6
  sec                          ; $D2A9
  sbc z:Tmp01                  ; $D2AA
  cmp #$EA                     ; $D2AC
  bcs Loc_D2B4                 ; $D2AE
  cmp #$16                     ; $D2B0
  bcs Loc_D305                 ; $D2B2
Loc_D2B4:
  lda #$00                     ; $D2B4
  sta $0410                    ; $D2B6
  sta $0403                    ; $D2B9
  lda #$02                     ; $D2BC
  sta z:$5D                    ; $D2BE
  sta z:Tmp03                  ; $D2C0
  sta z:$05                    ; $D2C2
  sta $0402                    ; $D2C4
  lda z:GameState              ; $D2C7
  cmp #$03                     ; $D2C9
  bne Loc_D2D2                 ; $D2CB
  lda #$58                     ; $D2CD
  jmp Loc_D2D4                 ; $D2CF
Loc_D2D2:
  lda #$4C                     ; $D2D2
Loc_D2D4:
  sta z:Tmp02                  ; $D2D4
  lda $0314,x                  ; $D2D6
  asl a                        ; $D2D9
  asl a                        ; $D2DA
  sta z:$04                    ; $D2DB
  lda $0313,x                  ; $D2DD
  clc                          ; $D2E0
  adc z:$04                    ; $D2E1
  sta z:$04                    ; $D2E3
  sta z:$5C                    ; $D2E5
  lda $0313,x                  ; $D2E7
  sec                          ; $D2EA
  sbc z:Tmp02                  ; $D2EB
  cmp #$30                     ; $D2ED
  bcc Loc_D2F5                 ; $D2EF
  lda z:Tmp02                  ; $D2F1
  sta z:$5C                    ; $D2F3
Loc_D2F5:
  jsr Sub_D308                 ; $D2F5
  jsr Sub_D318                 ; $D2F8
  lda #$00                     ; $D2FB
  sta $0110                    ; $D2FD
  lda #$01                     ; $D300
  jmp Loc_D307                 ; $D302
Loc_D305:
  lda #$00                     ; $D305
Loc_D307:
  rts                          ; $D307
Sub_D308:
  ldy #$00                     ; $D308
Loc_D30A:
  lda #$F0                     ; $D30A
  sta (Tmp02),y                ; $D30C
  inc z:Tmp02                  ; $D30E
  lda z:Tmp02                  ; $D310
  cmp $0313,x                  ; $D312
  bcc Loc_D30A                 ; $D315
  rts                          ; $D317
Sub_D318:
  ldy #$00                     ; $D318
Loc_D31A:
  lda #$F0                     ; $D31A
  sta ($04),y                  ; $D31C
  inc z:$04                    ; $D31E
  lda z:$04                    ; $D320
  cmp #$E0                     ; $D322
  bcc Loc_D31A                 ; $D324
  rts                          ; $D326
  .incbin "prg_bank_7.bin", $1327, $6  ; $D327
Sub_D32D:
  lda z:$30                    ; $D32D
  bne Loc_D341                 ; $D32F
  jsr Sub_D3A4                 ; $D331
  lda z:PlayerSpriteFrame      ; $D334
  cmp #$03                     ; $D336
  bcc Loc_D33D                 ; $D338
  inc z:$30                    ; $D33A
  rts                          ; $D33C
Loc_D33D:
  jsr CopyPlayerSprites        ; $D33D
  rts                          ; $D340
Loc_D341:
  cmp #$01                     ; $D341
  bne Loc_D349                 ; $D343
  jsr Sub_D4D3                 ; $D345
  rts                          ; $D348
Loc_D349:
  cmp #$02                     ; $D349
  bne Loc_D351                 ; $D34B
  jsr Sub_D573                 ; $D34D
  rts                          ; $D350
Loc_D351:
  cmp #$03                     ; $D351
  bne Loc_D359                 ; $D353
  jsr Sub_D5BD                 ; $D355
  rts                          ; $D358
Loc_D359:
  cmp #$04                     ; $D359
  bne Loc_D361                 ; $D35B
  jsr Sub_D5E2                 ; $D35D
  rts                          ; $D360
Loc_D361:
  cmp #$05                     ; $D361
  bne Loc_D369                 ; $D363
  jsr Sub_D607                 ; $D365
  rts                          ; $D368
Loc_D369:
  cmp #$06                     ; $D369
  bne Loc_D371                 ; $D36B
  jsr Sub_D6A4                 ; $D36D
  rts                          ; $D370
Loc_D371:
  cmp #$07                     ; $D371
  bne Loc_D379                 ; $D373
  jsr Sub_D710                 ; $D375
  rts                          ; $D378
Loc_D379:
  ldx z:FireMode               ; $D379
  lda Data_F77A,x              ; $D37B
  and #$40                     ; $D37E
  beq Loc_D389                 ; $D380
  txa                          ; $D382
  pha                          ; $D383
  jsr Sub_D740                 ; $D384
  pla                          ; $D387
  tax                          ; $D388
Loc_D389:
  lda Data_F77A,x              ; $D389
  and #$80                     ; $D38C
  beq Loc_D393                 ; $D38E
  inc $0100                    ; $D390
Loc_D393:
  lda #$A1                     ; $D393
  sta $0238                    ; $D395
  lda #$10                     ; $D398
  sta $023B                    ; $D39A
  lda #$00                     ; $D39D
  sta z:$33                    ; $D39F
  sta z:$34                    ; $D3A1
  rts                          ; $D3A3
Sub_D3A4:
  lda z:$31                    ; $D3A4
  bne Loc_D3AF                 ; $D3A6
  lda JoyHeld1                 ; $D3A8
  and #$01                     ; $D3AB
  beq Loc_D3D2                 ; $D3AD
Loc_D3AF:
  inc z:$31                    ; $D3AF
  lda z:$31                    ; $D3B1
  cmp #$0E                     ; $D3B3
  bcs Loc_D3BC                 ; $D3B5
  lda #$00                     ; $D3B7
  jmp Loc_D3D0                 ; $D3B9
Loc_D3BC:
  cmp #$1C                     ; $D3BC
  bcs Loc_D3C5                 ; $D3BE
  lda #$01                     ; $D3C0
  jmp Loc_D3D0                 ; $D3C2
Loc_D3C5:
  cmp #$2A                     ; $D3C5
  bcs Loc_D3CE                 ; $D3C7
  lda #$02                     ; $D3C9
  jmp Loc_D3D0                 ; $D3CB
Loc_D3CE:
  lda #$03                     ; $D3CE
Loc_D3D0:
  sta z:PlayerSpriteFrame      ; $D3D0
Loc_D3D2:
  rts                          ; $D3D2
CopyPlayerSprites:
  ldx z:PlayerSpriteFrame      ; $D3D3
  beq Loc_D3E0                 ; $D3D5
  lda #$00                     ; $D3D7
Loc_D3D9:
  clc                          ; $D3D9
  adc #$4C                     ; $D3DA
  dex                          ; $D3DC
  bne Loc_D3D9                 ; $D3DD
  tax                          ; $D3DF
Loc_D3E0:
  ldy #$00                     ; $D3E0
Loc_D3E2:
  lda Data_D3EF,x              ; $D3E2
  sta $0238,y                  ; $D3E5
  inx                          ; $D3E8
  iny                          ; $D3E9
  cpy #$4C                     ; $D3EA
  bcc Loc_D3E2                 ; $D3EC
  rts                          ; $D3EE
Data_D3EF:
  .incbin "prg_bank_7.bin", $13EF, $E4  ; $D3EF
Sub_D4D3:
  lda $0100                    ; $D4D3
  asl a                        ; $D4D6
  tax                          ; $D4D7
  lda Data_F6EC,x              ; $D4D8
  sta z:Tmp00                  ; $D4DB
  lda Data_F6ED,x              ; $D4DD
  sta z:Tmp01                  ; $D4E0
  ldy #$00                     ; $D4E2
Loc_D4E4:
  lda (Tmp00),y                ; $D4E4
  cmp #$FF                     ; $D4E6
  bne Loc_D4EF                 ; $D4E8
  lda #$08                     ; $D4EA
  jmp Loc_D530                 ; $D4EC
Loc_D4EF:
  cmp z:PaletteSetIndex        ; $D4EF
  beq Loc_D4F8                 ; $D4F1
  iny                          ; $D4F3
  iny                          ; $D4F4
  jmp Loc_D4E4                 ; $D4F5
Loc_D4F8:
  iny                          ; $D4F8
  lda (Tmp00),y                ; $D4F9
  sta z:Tmp02                  ; $D4FB
  asl a                        ; $D4FD
  clc                          ; $D4FE
  adc z:Tmp02                  ; $D4FF
  tax                          ; $D501
  stx z:FireMode               ; $D502
  lda Data_F77A,x              ; $D504
  and #$03                     ; $D507
  beq Loc_D519                 ; $D509
  cmp #$02                     ; $D50B
  beq Loc_D514                 ; $D50D
  lda #$05                     ; $D50F
  jmp Loc_D5F9                 ; $D511
Loc_D514:
  lda #$03                     ; $D514
  jmp Loc_D530                 ; $D516
Loc_D519:
  lda Data_F77A,x              ; $D519
  and #$10                     ; $D51C
  asl a                        ; $D51E
  tay                          ; $D51F
  ldx #$00                     ; $D520
Loc_D522:
  lda Data_D533,y              ; $D522
  sta $02C0,x                  ; $D525
  iny                          ; $D528
  inx                          ; $D529
  cpx #$20                     ; $D52A
  bcc Loc_D522                 ; $D52C
  lda #$02                     ; $D52E
Loc_D530:
  sta z:$30                    ; $D530
  rts                          ; $D532
Data_D533:
  .incbin "prg_bank_7.bin", $1533, $40  ; $D533
Sub_D573:
  lda $02C3                    ; $D573
  cmp #$88                     ; $D576
  bcs Loc_D57F                 ; $D578
  inc z:$30                    ; $D57A
  jmp Loc_D5BC                 ; $D57C
Loc_D57F:
  lda z:FrameCounter           ; $D57F
  and #$01                     ; $D581
  bne Loc_D592                 ; $D583
  ldx #$00                     ; $D585
Loc_D587:
  dec $02C3,x                  ; $D587
  inx                          ; $D58A
  inx                          ; $D58B
  inx                          ; $D58C
  inx                          ; $D58D
  cpx #$20                     ; $D58E
  bcc Loc_D587                 ; $D590
Loc_D592:
  lda z:FrameCounter           ; $D592
  and #$0F                     ; $D594
  cmp #$02                     ; $D596
  bne Loc_D5BC                 ; $D598
  lda $02C1                    ; $D59A
  and #$10                     ; $D59D
  bne Loc_D5A6                 ; $D59F
  lda #$10                     ; $D5A1
  jmp Loc_D5A8                 ; $D5A3
Loc_D5A6:
  lda #$F0                     ; $D5A6
Loc_D5A8:
  clc                          ; $D5A8
  adc $02C1                    ; $D5A9
  ldx #$00                     ; $D5AC
Loc_D5AE:
  sta $02C1,x                  ; $D5AE
  clc                          ; $D5B1
  adc #$02                     ; $D5B2
  inx                          ; $D5B4
  inx                          ; $D5B5
  inx                          ; $D5B6
  inx                          ; $D5B7
  cpx #$20                     ; $D5B8
  bcc Loc_D5AE                 ; $D5BA
Loc_D5BC:
  rts                          ; $D5BC
Sub_D5BD:
  ldx z:FireMode               ; $D5BD
  lda Data_F77B,x              ; $D5BF
  sta $0400                    ; $D5C2
Loc_D5C5:
  lda #$8C                     ; $D5C5
  sta z:$5C                    ; $D5C7
  lda #$02                     ; $D5C9
  sta z:$5D                    ; $D5CB
  sta $0402                    ; $D5CD
  lda #$00                     ; $D5D0
  sta $0410                    ; $D5D2
  sta $0403                    ; $D5D5
  lda #$03                     ; $D5D8
  sta z:MmcPrgShadow           ; $D5DA
  jsr MmcWritePrg              ; $D5DC
  inc z:$30                    ; $D5DF
  rts                          ; $D5E1
Sub_D5E2:
  ldx z:FireMode               ; $D5E2
  lda Data_F77A,x              ; $D5E4
  and #$0C                     ; $D5E7
  bne Loc_D5F0                 ; $D5E9
  lda #$08                     ; $D5EB
  jmp Loc_D600                 ; $D5ED
Loc_D5F0:
  cmp #$0C                     ; $D5F0
  bne Loc_D5F9                 ; $D5F2
  lda #$06                     ; $D5F4
  jmp Loc_D600                 ; $D5F6
Loc_D5F9:
  lda #$0F                     ; $D5F9
  jsr EnqueueByte              ; $D5FB
  lda #$05                     ; $D5FE
Loc_D600:
  sta z:$30                    ; $D600
  lda #$00                     ; $D602
  sta z:$31                    ; $D604
  rts                          ; $D606
Sub_D607:
  inc z:$31                    ; $D607
  lda z:$31                    ; $D609
  cmp #$01                     ; $D60B
  bne Loc_D61C                 ; $D60D
  ldx #$00                     ; $D60F
  lda #$F0                     ; $D611
Loc_D613:
  sta $02C0,x                  ; $D613
  inx                          ; $D616
  cpx #$20                     ; $D617
  bcc Loc_D613                 ; $D619
  rts                          ; $D61B
Loc_D61C:
  cmp #$02                     ; $D61C
  bne Loc_D625                 ; $D61E
  lda #$00                     ; $D620
  jmp Loc_D62B                 ; $D622
Loc_D625:
  cmp #$40                     ; $D625
  bne Loc_D64B                 ; $D627
  lda #$14                     ; $D629
Loc_D62B:
  sta z:Tmp00                  ; $D62B
  ldx z:FireMode               ; $D62D
  lda Data_F77A,x              ; $D62F
  and #$08                     ; $D632
  beq Loc_D638                 ; $D634
  lda #$28                     ; $D636
Loc_D638:
  clc                          ; $D638
  adc z:Tmp00                  ; $D639
  tax                          ; $D63B
  ldy #$00                     ; $D63C
Loc_D63E:
  lda Data_D654,x              ; $D63E
  sta $02C0,y                  ; $D641
  inx                          ; $D644
  iny                          ; $D645
  cpy #$14                     ; $D646
  bcc Loc_D63E                 ; $D648
  rts                          ; $D64A
Loc_D64B:
  cmp #$70                     ; $D64B
  bcc Loc_D653                 ; $D64D
  inc z:$30                    ; $D64F
  inc z:$30                    ; $D651
Loc_D653:
  rts                          ; $D653
Data_D654:
  .incbin "prg_bank_7.bin", $1654, $50  ; $D654
Sub_D6A4:
  inc z:$31                    ; $D6A4
  lda z:$31                    ; $D6A6
  cmp #$E8                     ; $D6A8
  bcc Loc_D6AF                 ; $D6AA
  inc z:$30                    ; $D6AC
  rts                          ; $D6AE
Loc_D6AF:
  ldx #$00                     ; $D6AF
Loc_D6B1:
  lda Data_D6D4,x              ; $D6B1
  cmp z:$31                    ; $D6B4
  beq Loc_D6BF                 ; $D6B6
  inx                          ; $D6B8
  inx                          ; $D6B9
  cpx #$0C                     ; $D6BA
  bcc Loc_D6B1                 ; $D6BC
  rts                          ; $D6BE
Loc_D6BF:
  ldy Data_D6D5,x              ; $D6BF
  ldx #$00                     ; $D6C2
Loc_D6C4:
  lda Data_D6E0,y              ; $D6C4
  sta $02C1,x                  ; $D6C7
  iny                          ; $D6CA
  inx                          ; $D6CB
  inx                          ; $D6CC
  inx                          ; $D6CD
  inx                          ; $D6CE
  cpx #$20                     ; $D6CF
  bcc Loc_D6C4                 ; $D6D1
  rts                          ; $D6D3
Data_D6D4:
  .incbin "prg_bank_7.bin", $16D4, $1  ; $D6D4
Data_D6D5:
  .incbin "prg_bank_7.bin", $16D5, $B  ; $D6D5
Data_D6E0:
  .incbin "prg_bank_7.bin", $16E0, $30  ; $D6E0
Sub_D710:
  ldx z:FireMode               ; $D710
  lda Data_F77C,x              ; $D712
  sta $0400                    ; $D715
  cmp #$0A                     ; $D718
  bne Loc_D723                 ; $D71A
  lda #$00                     ; $D71C
  ldy #$08                     ; $D71E
  jmp Loc_D736                 ; $D720
Loc_D723:
  cmp #$28                     ; $D723
  bne Loc_D72E                 ; $D725
  lda #$1E                     ; $D727
  ldy #$14                     ; $D729
  jmp Loc_D736                 ; $D72B
Loc_D72E:
  cmp #$2A                     ; $D72E
  bne Loc_D73D                 ; $D730
  lda #$22                     ; $D732
  ldy #$15                     ; $D734
Loc_D736:
  jsr EnqueueByte              ; $D736
  tya                          ; $D739
  jsr EnqueueByte              ; $D73A
Loc_D73D:
  jmp Loc_D5C5                 ; $D73D
Sub_D740:
  nop                          ; $D740
  cpx #$09                     ; $D741
  bne Loc_D756                 ; $D743
  lda #$09                     ; $D745
  ldx #$00                     ; $D747
  ldy #$72                     ; $D749
Loc_D74B:
  sta z:$29                    ; $D74B
  stx z:$2A                    ; $D74D
  sty z:$2B                    ; $D74F
  lda #$01                     ; $D751
  sta z:$28                    ; $D753
  rts                          ; $D755
Loc_D756:
  cpx #$12                     ; $D756
  bne Loc_D763                 ; $D758
  lda #$08                     ; $D75A
  ldx #$00                     ; $D75C
  ldy #$A7                     ; $D75E
  jmp Loc_D74B                 ; $D760
Loc_D763:
  cpx #$1E                     ; $D763
  bne Loc_D770                 ; $D765
  lda #$0A                     ; $D767
  ldx #$00                     ; $D769
  ldy #$43                     ; $D76B
  jmp Loc_D74B                 ; $D76D
Loc_D770:
  cpx #$2D                     ; $D770
  bne Loc_D77D                 ; $D772
  lda #$19                     ; $D774
  ldx #$00                     ; $D776
  ldy #$A7                     ; $D778
  jmp Loc_D74B                 ; $D77A
Loc_D77D:
  cpx #$33                     ; $D77D
  bne Loc_D78A                 ; $D77F
  lda #$1C                     ; $D781
  ldx #$00                     ; $D783
  ldy #$A1                     ; $D785
  jmp Loc_D74B                 ; $D787
Loc_D78A:
  cpx #$3C                     ; $D78A
  bne Loc_D797                 ; $D78C
  lda #$17                     ; $D78E
  ldx #$2E                     ; $D790
  ldy #$A7                     ; $D792
  jmp Loc_D74B                 ; $D794
Loc_D797:
  cpx #$42                     ; $D797
  bne Loc_D7A4                 ; $D799
  lda #$84                     ; $D79B
  ldx #$00                     ; $D79D
  ldy #$00                     ; $D79F
  jmp Loc_D74B                 ; $D7A1
Loc_D7A4:
  cpx #$87                     ; $D7A4
  bne Loc_D7B1                 ; $D7A6
  lda #$1D                     ; $D7A8
  ldx #$20                     ; $D7AA
  ldy #$A8                     ; $D7AC
  jmp Loc_D74B                 ; $D7AE
Loc_D7B1:
  rts                          ; $D7B1
Sub_D7B2:
  lda $0438                    ; $D7B2
  bne Loc_D7BA                 ; $D7B5
  jmp Loc_D824                 ; $D7B7
Loc_D7BA:
  cmp #$80                     ; $D7BA
  beq Loc_D7C1                 ; $D7BC
  jmp Loc_D823                 ; $D7BE
Loc_D7C1:
  lda z:$16                    ; $D7C1
  asl a                        ; $D7C3
  tay                          ; $D7C4
  lda Data_D883,y              ; $D7C5
  sta z:Tmp00                  ; $D7C8
  lda Data_D884,y              ; $D7CA
  sta z:Tmp01                  ; $D7CD
  ldy #$00                     ; $D7CF
Loc_D7D1:
  lda (Tmp00),y                ; $D7D1
  cmp #$FF                     ; $D7D3
  beq Loc_D7EF                 ; $D7D5
  cmp z:PaletteSetIndex        ; $D7D7
  beq Loc_D7E2                 ; $D7D9
  bcs Loc_D7EF                 ; $D7DB
  iny                          ; $D7DD
Loc_D7DE:
  iny                          ; $D7DE
  jmp Loc_D7D1                 ; $D7DF
Loc_D7E2:
  iny                          ; $D7E2
  lda (Tmp00),y                ; $D7E3
  sta z:Tmp02                  ; $D7E5
  and #$0F                     ; $D7E7
  cmp z:ScrollPage             ; $D7E9
  beq Loc_D7FD                 ; $D7EB
  bcc Loc_D7DE                 ; $D7ED
Loc_D7EF:
  lda #$00                     ; $D7EF
  sta $0405                    ; $D7F1
  sta $0438                    ; $D7F4
  jsr Sub_D13A                 ; $D7F7
  jmp Loc_D823                 ; $D7FA
Loc_D7FD:
  lda z:Tmp02                  ; $D7FD
  jsr LsrA4                    ; $D7FF
  sta $0405                    ; $D802
  sta $050E                    ; $D805
  dec $050E                    ; $D808
  jsr Sub_D86D                 ; $D80B
  lda #$1F                     ; $D80E
  sta MMC1_CHR0                ; $D810
  lsr a                        ; $D813
  sta MMC1_CHR0                ; $D814
  lsr a                        ; $D817
  sta MMC1_CHR0                ; $D818
  lsr a                        ; $D81B
  sta MMC1_CHR0                ; $D81C
  lsr a                        ; $D81F
  sta MMC1_CHR0                ; $D820
Loc_D823:
  rts                          ; $D823
Loc_D824:
  lda z:$16                    ; $D824
  asl a                        ; $D826
  tay                          ; $D827
  lda Data_D88B,y              ; $D828
  sta z:Tmp00                  ; $D82B
  lda Data_D88C,y              ; $D82D
  sta z:Tmp01                  ; $D830
  ldy #$00                     ; $D832
Loc_D834:
  lda (Tmp00),y                ; $D834
  cmp #$FF                     ; $D836
  beq Loc_D852                 ; $D838
  cmp z:PaletteSetIndex        ; $D83A
  beq Loc_D845                 ; $D83C
  bcs Loc_D852                 ; $D83E
  iny                          ; $D840
Loc_D841:
  iny                          ; $D841
  jmp Loc_D834                 ; $D842
Loc_D845:
  iny                          ; $D845
  lda (Tmp00),y                ; $D846
  sta z:Tmp02                  ; $D848
  and #$0F                     ; $D84A
  cmp z:ScrollPage             ; $D84C
  beq Loc_D85F                 ; $D84E
  bcc Loc_D841                 ; $D850
Loc_D852:
  lda #$00                     ; $D852
  sta $0405                    ; $D854
  lda #$80                     ; $D857
  sta $0438                    ; $D859
  jmp Loc_D823                 ; $D85C
Loc_D85F:
  jsr Sub_D86D                 ; $D85F
  lda z:Tmp02                  ; $D862
  jsr LsrA4                    ; $D864
  sta $0405                    ; $D867
  jmp Loc_D823                 ; $D86A
Sub_D86D:
  lda #$0D                     ; $D86D
  sta MMC1_CHR1                ; $D86F
  lsr a                        ; $D872
  sta MMC1_CHR1                ; $D873
  lsr a                        ; $D876
  sta MMC1_CHR1                ; $D877
  lsr a                        ; $D87A
  sta MMC1_CHR1                ; $D87B
  lsr a                        ; $D87E
  sta MMC1_CHR1                ; $D87F
  rts                          ; $D882
Data_D883:
  .incbin "prg_bank_7.bin", $1883, $1  ; $D883
Data_D884:
  .incbin "prg_bank_7.bin", $1884, $7  ; $D884
Data_D88B:
  .incbin "prg_bank_7.bin", $188B, $1  ; $D88B
Data_D88C:
  .incbin "prg_bank_7.bin", $188C, $3F  ; $D88C
Sub_D8CB:
  lda $0405                    ; $D8CB
  bne Loc_D8D3                 ; $D8CE
  jmp Loc_D99C                 ; $D8D0
Loc_D8D3:
  lda $0438                    ; $D8D3
  bmi Loc_D8DB                 ; $D8D6
  jmp Loc_D99D                 ; $D8D8
Loc_D8DB:
  and #$7F                     ; $D8DB
  beq Loc_D8E6                 ; $D8DD
  cmp #$01                     ; $D8DF
  beq Loc_D918                 ; $D8E1
  jmp Loc_D92D                 ; $D8E3
Loc_D8E6:
  jsr Sub_DA0A                 ; $D8E6
  lda $0405                    ; $D8E9
  asl a                        ; $D8EC
  tay                          ; $D8ED
  lda $830E,y                  ; $D8EE
  sta z:$08                    ; $D8F1
  lda $830F,y                  ; $D8F3
  sta z:$09                    ; $D8F6
  jsr a:$05                    ; $D8F8
  jsr ProcessPpuUpdateList     ; $D8FB
  .incbin "prg_bank_7.bin", $18FE, $2  ; $D8FE
  jsr Sub_DA4B                 ; $D900
  lda #$0F                     ; $D903
  sta $014F                    ; $D905
  ldy #$24                     ; $D908
  sty $0439                    ; $D90A
  lda #$28                     ; $D90D
  sta $043A                    ; $D90F
  inc $0438                    ; $D912
  jmp Loc_D99C                 ; $D915
Loc_D918:
  jsr UploadPalette            ; $D918
  jsr ApplyScroll              ; $D91B
  lda z:PpuMaskShadow          ; $D91E
  ora #$18                     ; $D920
  sta z:PpuMaskShadow          ; $D922
  sta PPU_MASK                 ; $D924
  inc $0438                    ; $D927
  jmp Loc_D99C                 ; $D92A
Loc_D92D:
  dec $043A                    ; $D92D
  bne Loc_D99C                 ; $D930
  dec $0439                    ; $D932
  dec $0439                    ; $D935
  dec $0439                    ; $D938
  dec $0439                    ; $D93B
  beq Loc_D967                 ; $D93E
  ldy $0439                    ; $D940
  lda Data_DAB6,y              ; $D943
  sta $043A                    ; $D946
  dey                          ; $D949
  lda Data_DAB6,y              ; $D94A
  sta $0151                    ; $D94D
  dey                          ; $D950
  lda Data_DAB6,y              ; $D951
  sta $0152                    ; $D954
  dey                          ; $D957
  lda Data_DAB6,y              ; $D958
  sta $014F                    ; $D95B
  jsr UploadPalette            ; $D95E
  jsr ApplyScroll              ; $D961
  jmp Loc_D99C                 ; $D964
Loc_D967:
  lda z:PpuMaskShadow          ; $D967
  and #$E7                     ; $D969
  jsr SetPpuMask               ; $D96B
  lda z:PpuCtrlShadow          ; $D96E
  and #$FD                     ; $D970
  jsr SetPpuCtrl               ; $D972
  ldy #$00                     ; $D975
Loc_D977:
  lda $0202,y                  ; $D977
  and #$DF                     ; $D97A
  sta $0202,y                  ; $D97C
  iny                          ; $D97F
  iny                          ; $D980
  iny                          ; $D981
  iny                          ; $D982
  bne Loc_D977                 ; $D983
  ldy #$00                     ; $D985
  lda #$F0                     ; $D987
Loc_D989:
  sta $0280,y                  ; $D989
  iny                          ; $D98C
  iny                          ; $D98D
  iny                          ; $D98E
  iny                          ; $D98F
  cpy #$30                     ; $D990
  bcc Loc_D989                 ; $D992
  lda #$00                     ; $D994
  sta $0438                    ; $D996
  jsr Sub_D13A                 ; $D999
Loc_D99C:
  rts                          ; $D99C
Loc_D99D:
  lda $0438                    ; $D99D
  beq Loc_D9A9                 ; $D9A0
  cmp #$01                     ; $D9A2
  beq Loc_D9CE                 ; $D9A4
  jmp Loc_D9E1                 ; $D9A6
Loc_D9A9:
  jsr Sub_DA0A                 ; $D9A9
  lda $0405                    ; $D9AC
  asl a                        ; $D9AF
  tay                          ; $D9B0
  lda $832A,y                  ; $D9B1
  sta z:$08                    ; $D9B4
  lda $832B,y                  ; $D9B6
  sta z:$09                    ; $D9B9
  jsr a:$05                    ; $D9BB
  lda #$20                     ; $D9BE
  sta $014F                    ; $D9C0
  lda #$96                     ; $D9C3
  sta $043A                    ; $D9C5
  inc $0438                    ; $D9C8
  jmp Loc_D99C                 ; $D9CB
Loc_D9CE:
  jsr UploadPalette            ; $D9CE
  jsr ApplyScroll              ; $D9D1
  lda z:PpuMaskShadow          ; $D9D4
  ora #$08                     ; $D9D6
  jsr SetPpuMask               ; $D9D8
  inc $0438                    ; $D9DB
  jmp Loc_D99C                 ; $D9DE
Loc_D9E1:
  lda z:FrameCounter           ; $D9E1
  and #$01                     ; $D9E3
  bne Loc_D99C                 ; $D9E5
  dec $043A                    ; $D9E7
  beq Loc_D9EF                 ; $D9EA
  jmp Loc_D99C                 ; $D9EC
Loc_D9EF:
  lda z:PpuMaskShadow          ; $D9EF
  and #$E7                     ; $D9F1
  jsr SetPpuMask               ; $D9F3
  lda z:PpuCtrlShadow          ; $D9F6
  and #$FD                     ; $D9F8
  jsr SetPpuCtrl               ; $D9FA
  lda #$80                     ; $D9FD
  sta $0438                    ; $D9FF
  lda #$00                     ; $DA02
  sta $0405                    ; $DA04
  jmp Loc_D99C                 ; $DA07
Sub_DA0A:
  lda z:PpuMaskShadow          ; $DA0A
  and #$E7                     ; $DA0C
  jsr SetPpuMask               ; $DA0E
  lda z:PpuCtrlShadow          ; $DA11
  ora #$02                     ; $DA13
  jsr SetPpuCtrl               ; $DA15
  lda #$00                     ; $DA18
  sta z:HwScrollX              ; $DA1A
  jsr Sub_DA77                 ; $DA1C
  jsr ApplyScroll              ; $DA1F
  ldy #$00                     ; $DA22
Loc_DA24:
  lda Data_DA45,y              ; $DA24
  sta a:$05,y                  ; $DA27
  iny                          ; $DA2A
  cpy #$08                     ; $DA2B
  bne Loc_DA24                 ; $DA2D
  lda #$03                     ; $DA2F
  sta MMC1_PRG                 ; $DA31
  lsr a                        ; $DA34
  sta MMC1_PRG                 ; $DA35
  lsr a                        ; $DA38
  sta MMC1_PRG                 ; $DA39
  lsr a                        ; $DA3C
  sta MMC1_PRG                 ; $DA3D
  lsr a                        ; $DA40
  sta MMC1_PRG                 ; $DA41
  rts                          ; $DA44
Data_DA45:
  .incbin "prg_bank_7.bin", $1A45, $6  ; $DA45
Sub_DA4B:
  lda #$0F                     ; $DA4B
  sta $0150                    ; $DA4D
  sta $0151                    ; $DA50
  sta $0152                    ; $DA53
  sta $0153                    ; $DA56
  ldy #$00                     ; $DA59
Loc_DA5B:
  lda $0202,y                  ; $DA5B
  ora #$20                     ; $DA5E
  sta $0202,y                  ; $DA60
  iny                          ; $DA63
  iny                          ; $DA64
  iny                          ; $DA65
  iny                          ; $DA66
  bne Loc_DA5B                 ; $DA67
  ldy #$00                     ; $DA69
Loc_DA6B:
  lda Data_DAD7,y              ; $DA6B
  sta $0280,y                  ; $DA6E
  iny                          ; $DA71
  cpy #$30                     ; $DA72
  bcc Loc_DA6B                 ; $DA74
  rts                          ; $DA76
Sub_DA77:
  lda PPU_STATUS               ; $DA77
  lda z:PpuCtrlShadow          ; $DA7A
  and #$FB                     ; $DA7C
  jsr SetPpuCtrl               ; $DA7E
  lda #$28                     ; $DA81
  sta PPU_ADDR                 ; $DA83
  ldy #$00                     ; $DA86
  sta PPU_ADDR                 ; $DA88
  ldx #$04                     ; $DA8B
Loc_DA8D:
  ldy #$00                     ; $DA8D
  lda #$6B                     ; $DA8F
Loc_DA91:
  sta PPU_DATA                 ; $DA91
  dey                          ; $DA94
  bne Loc_DA91                 ; $DA95
  dex                          ; $DA97
  bne Loc_DA8D                 ; $DA98
  lda #$2B                     ; $DA9A
  sta PPU_ADDR                 ; $DA9C
  lda #$C0                     ; $DA9F
  sta PPU_ADDR                 ; $DAA1
  ldy #$FF                     ; $DAA4
  ldx #$40                     ; $DAA6
Loc_DAA8:
  sty PPU_DATA                 ; $DAA8
  dex                          ; $DAAB
  bne Loc_DAA8                 ; $DAAC
  rts                          ; $DAAE
  .incbin "prg_bank_7.bin", $1AAF, $7  ; $DAAF
Data_DAB6:
  .incbin "prg_bank_7.bin", $1AB6, $21  ; $DAB6
Data_DAD7:
  .incbin "prg_bank_7.bin", $1AD7, $30  ; $DAD7
Sub_DB07:
  lda $0421                    ; $DB07
  beq Loc_DB0F                 ; $DB0A
  jmp Loc_DB57                 ; $DB0C
Loc_DB0F:
  lda z:$16                    ; $DB0F
  asl a                        ; $DB11
  clc                          ; $DB12
  adc #$81                     ; $DB13
  sta z:Tmp00                  ; $DB15
  lda #$00                     ; $DB17
  adc #$DB                     ; $DB19
  sta z:Tmp01                  ; $DB1B
  ldy #$00                     ; $DB1D
  lda (Tmp00),y                ; $DB1F
  sta z:Tmp02                  ; $DB21
  iny                          ; $DB23
  lda (Tmp00),y                ; $DB24
  sta z:Tmp03                  ; $DB26
  ldy #$00                     ; $DB28
Loc_DB2A:
  lda (Tmp02),y                ; $DB2A
  cmp #$FF                     ; $DB2C
  beq Loc_DB57                 ; $DB2E
  cmp z:PaletteSetIndex        ; $DB30
  beq Loc_DB3D                 ; $DB32
  bcs Loc_DB57                 ; $DB34
  iny                          ; $DB36
Loc_DB37:
  iny                          ; $DB37
Loc_DB38:
  iny                          ; $DB38
  iny                          ; $DB39
  jmp Loc_DB2A                 ; $DB3A
Loc_DB3D:
  iny                          ; $DB3D
  lda (Tmp02),y                ; $DB3E
  sta z:Tmp00                  ; $DB40
  and #$0F                     ; $DB42
  cmp z:ScrollPage             ; $DB44
  beq Loc_DB4D                 ; $DB46
  bcs Loc_DB57                 ; $DB48
  jmp Loc_DB37                 ; $DB4A
Loc_DB4D:
  lda z:Tmp00                  ; $DB4D
  and #$F0                     ; $DB4F
  cmp z:ScrollX                ; $DB51
  beq Loc_DB5F                 ; $DB53
  bcc Loc_DB38                 ; $DB55
Loc_DB57:
  lda #$FF                     ; $DB57
  sta $0404                    ; $DB59
  jmp Loc_DB80                 ; $DB5C
Loc_DB5F:
  iny                          ; $DB5F
  lda (Tmp02),y                ; $DB60
  tax                          ; $DB62
  lda $0430,x                  ; $DB63
  bne Loc_DB57                 ; $DB66
  lda z:GameState              ; $DB68
  cmp #$07                     ; $DB6A
  beq Loc_DB75                 ; $DB6C
  lda $023B                    ; $DB6E
  cmp #$78                     ; $DB71
  bne Loc_DB57                 ; $DB73
Loc_DB75:
  lda #$01                     ; $DB75
  sta $0430,x                  ; $DB77
  iny                          ; $DB7A
  lda (Tmp02),y                ; $DB7B
  sta $0404                    ; $DB7D
Loc_DB80:
  rts                          ; $DB80
  .incbin "prg_bank_7.bin", $1B81, $54  ; $DB81
Sub_DBD5:
  lda z:$28                    ; $DBD5
  cmp #$01                     ; $DBD7
  bne Loc_DBE7                 ; $DBD9
  lda z:$29                    ; $DBDB
  cmp #$50                     ; $DBDD
  bcs Loc_DBE8                 ; $DBDF
  sta z:PaletteSetIndex        ; $DBE1
  lda #$00                     ; $DBE3
  sta z:GameState              ; $DBE5
Loc_DBE7:
  rts                          ; $DBE7
Loc_DBE8:
  cmp #$69                     ; $DBE8
  beq Loc_DC02                 ; $DBEA
  cmp #$77                     ; $DBEC
  beq Loc_DC06                 ; $DBEE
  cmp #$78                     ; $DBF0
  bcs Loc_DC0A                 ; $DBF2
  tax                          ; $DBF4
  lda Data_DBDE,x              ; $DBF5
  bne Loc_DBFE                 ; $DBF8
  jsr Sub_DC48                 ; $DBFA
  rts                          ; $DBFD
Loc_DBFE:
  jsr Sub_DE15                 ; $DBFE
  rts                          ; $DC01
Loc_DC02:
  jsr Sub_DDD0                 ; $DC02
  rts                          ; $DC05
Loc_DC06:
  jsr Sub_DED0                 ; $DC06
  rts                          ; $DC09
Loc_DC0A:
  cmp #$90                     ; $DC0A
  bcs Loc_DC23                 ; $DC0C
  sec                          ; $DC0E
  sbc #$78                     ; $DC0F
  sta $0501                    ; $DC11
  lda z:$2A                    ; $DC14
  sta SceneState               ; $DC16
  lda #$00                     ; $DC19
  sta $0502                    ; $DC1B
  lda #$04                     ; $DC1E
  sta z:MmcPrgShadow           ; $DC20
  rts                          ; $DC22
Loc_DC23:
  sec                          ; $DC23
  sbc #$8F                     ; $DC24
  sta SceneState               ; $DC26
  lda #$05                     ; $DC29
  sta z:MmcPrgShadow           ; $DC2B
  rts                          ; $DC2D
  .incbin "prg_bank_7.bin", $1C2E, $1A  ; $DC2E
Sub_DC48:
  jsr HideEnemySprites         ; $DC48
  inc z:PaletteDirty           ; $DC4B
  lda z:PaletteDirty           ; $DC4D
  cmp #$40                     ; $DC4F
  bcc Loc_DC57                 ; $DC51
  jsr Sub_DDD0                 ; $DC53
  rts                          ; $DC56
Loc_DC57:
  lda #$F8                     ; $DC57
  sta z:$04                    ; $DC59
  lda #$20                     ; $DC5B
  sta z:$05                    ; $DC5D
  jsr Sub_DC87                 ; $DC5F
  lda z:PaletteDirty           ; $DC62
  cmp #$02                     ; $DC64
  bne Loc_DC6D                 ; $DC66
  lda #$11                     ; $DC68
  jsr EnqueueByte              ; $DC6A
Loc_DC6D:
  lda z:PaletteDirty           ; $DC6D
  cmp #$10                     ; $DC6F
  bcc Loc_DC76                 ; $DC71
  jsr AnimatePalette           ; $DC73
Loc_DC76:
  rts                          ; $DC76
HideEnemySprites:
  lda #$F0                     ; $DC77
  ldx #$5C                     ; $DC79
Loc_DC7B:
  sta OamBuffer,x              ; $DC7B
  inx                          ; $DC7E
  inx                          ; $DC7F
  inx                          ; $DC80
  inx                          ; $DC81
  cpx #$E0                     ; $DC82
  bcc Loc_DC7B                 ; $DC84
  rts                          ; $DC86
Sub_DC87:
  lda z:PaletteDirty           ; $DC87
  and #$1C                     ; $DC89
  lsr a                        ; $DC8B
  tax                          ; $DC8C
  lda Data_DCC4,x              ; $DC8D
  sta z:Tmp02                  ; $DC90
  lda Data_DCC5,x              ; $DC92
  sta z:Tmp03                  ; $DC95
  ldy #$00                     ; $DC97
  lda (Tmp02),y                ; $DC99
  tax                          ; $DC9B
  ldy #$01                     ; $DC9C
Loc_DC9E:
  lda $0238                    ; $DC9E
  adc z:$04                    ; $DCA1
  adc (Tmp02),y                ; $DCA3
  sta $025B,y                  ; $DCA5
  iny                          ; $DCA8
  lda (Tmp02),y                ; $DCA9
  sta $025B,y                  ; $DCAB
  iny                          ; $DCAE
  lda (Tmp02),y                ; $DCAF
  sta $025B,y                  ; $DCB1
  iny                          ; $DCB4
  lda $023B                    ; $DCB5
  adc z:$05                    ; $DCB8
  adc (Tmp02),y                ; $DCBA
  sta $025B,y                  ; $DCBC
  iny                          ; $DCBF
  dex                          ; $DCC0
  bne Loc_DC9E                 ; $DCC1
  rts                          ; $DCC3
Data_DCC4:
  .incbin "prg_bank_7.bin", $1CC4, $1  ; $DCC4
Data_DCC5:
  .incbin "prg_bank_7.bin", $1CC5, $10B  ; $DCC5
Sub_DDD0:
  lda z:$29                    ; $DDD0
  sta z:PaletteSetIndex        ; $DDD2
  lda #$00                     ; $DDD4
  sta z:PaletteDirty           ; $DDD6
  lda #$10                     ; $DDD8
  sta z:GameState              ; $DDDA
  lda #$02                     ; $DDDC
  sta z:MmcPrgShadow           ; $DDDE
  rts                          ; $DDE0
AnimatePalette:
  lda z:FrameCounter           ; $DDE1
  and #$02                     ; $DDE3
  beq Loc_DDE9                 ; $DDE5
  lda #$04                     ; $DDE7
Loc_DDE9:
  tax                          ; $DDE9
  ldy #$00                     ; $DDEA
Loc_DDEC:
  lda Data_DE0D,x              ; $DDEC
  sta PaletteBuffer,y          ; $DDEF
  iny                          ; $DDF2
  lda Data_DE0E,x              ; $DDF3
  sta PaletteBuffer,y          ; $DDF6
  iny                          ; $DDF9
  lda Data_DE0F,x              ; $DDFA
  sta PaletteBuffer,y          ; $DDFD
  iny                          ; $DE00
  lda Data_DE10,x              ; $DE01
  sta PaletteBuffer,y          ; $DE04
  iny                          ; $DE07
  cpy #$10                     ; $DE08
  bcc Loc_DDEC                 ; $DE0A
  rts                          ; $DE0C
Data_DE0D:
  .incbin "prg_bank_7.bin", $1E0D, $1  ; $DE0D
Data_DE0E:
  .incbin "prg_bank_7.bin", $1E0E, $1  ; $DE0E
Data_DE0F:
  .incbin "prg_bank_7.bin", $1E0F, $1  ; $DE0F
Data_DE10:
  .incbin "prg_bank_7.bin", $1E10, $5  ; $DE10
Sub_DE15:
  jsr HideEnemySprites         ; $DE15
  ldy #$0C                     ; $DE18
  inc z:PaletteDirty           ; $DE1A
  lda z:PaletteDirty           ; $DE1C
  cmp #$50                     ; $DE1E
  bcc Loc_DE26                 ; $DE20
  jsr Sub_DDD0                 ; $DE22
  rts                          ; $DE25
Loc_DE26:
  cmp #$20                     ; $DE26
  bcc Loc_DE44                 ; $DE28
  cmp #$30                     ; $DE2A
  bcc Loc_DE3D                 ; $DE2C
  cmp #$39                     ; $DE2E
  bcs Loc_DE3D                 ; $DE30
  cmp #$30                     ; $DE32
  bne Loc_DE3B                 ; $DE34
  lda #$0E                     ; $DE36
  jsr EnqueueByte              ; $DE38
Loc_DE3B:
  ldy #$12                     ; $DE3B
Loc_DE3D:
  ldx #$C8                     ; $DE3D
  lda #$C0                     ; $DE3F
  jmp Loc_DE4F                 ; $DE41
Loc_DE44:
  sta z:Tmp00                  ; $DE44
  lsr a                        ; $DE46
  adc #$B8                     ; $DE47
  tax                          ; $DE49
  lda #$E0                     ; $DE4A
  sec                          ; $DE4C
  sbc z:Tmp00                  ; $DE4D
Loc_DE4F:
  stx $025F                    ; $DE4F
  sta $025C                    ; $DE52
  ldx #$00                     ; $DE55
Loc_DE57:
  lda $025C                    ; $DE57
  clc                          ; $DE5A
  adc Data_DE88,x              ; $DE5B
  sta $025C,x                  ; $DE5E
  inx                          ; $DE61
  lda Data_DE88,x              ; $DE62
  sta $025C,x                  ; $DE65
  inx                          ; $DE68
  lda Data_DE88,x              ; $DE69
  sta $025C,x                  ; $DE6C
  inx                          ; $DE6F
  lda $025F                    ; $DE70
  clc                          ; $DE73
  adc Data_DE88,x              ; $DE74
  sta $025C,x                  ; $DE77
  inx                          ; $DE7A
  dey                          ; $DE7B
  bne Loc_DE57                 ; $DE7C
  lda z:PaletteDirty           ; $DE7E
  cmp #$30                     ; $DE80
  bcc Loc_DE87                 ; $DE82
  jsr AnimatePalette           ; $DE84
Loc_DE87:
  rts                          ; $DE87
Data_DE88:
  .incbin "prg_bank_7.bin", $1E88, $48  ; $DE88
Sub_DED0:
  jsr HideEnemySprites         ; $DED0
  inc z:PaletteDirty           ; $DED3
  lda z:PaletteDirty           ; $DED5
  cmp #$80                     ; $DED7
  bcc Loc_DEDF                 ; $DED9
  jsr Sub_DF02                 ; $DEDB
  rts                          ; $DEDE
Loc_DEDF:
  lda #$00                     ; $DEDF
  sta z:$04                    ; $DEE1
  lda #$00                     ; $DEE3
  sta z:$05                    ; $DEE5
  jsr Sub_DC87                 ; $DEE7
  jsr Sub_DF12                 ; $DEEA
  lda z:PaletteDirty           ; $DEED
  cmp #$02                     ; $DEEF
  bne Loc_DEF8                 ; $DEF1
  lda #$11                     ; $DEF3
  jsr EnqueueByte              ; $DEF5
Loc_DEF8:
  lda z:PaletteDirty           ; $DEF8
  cmp #$10                     ; $DEFA
  bcc Loc_DF01                 ; $DEFC
  jsr AnimatePalette           ; $DEFE
Loc_DF01:
  rts                          ; $DF01
Sub_DF02:
  lda #$00                     ; $DF02
  sta z:GameState              ; $DF04
  sta z:$1B                    ; $DF06
  sta z:PaletteDirty           ; $DF08
  sta $0139                    ; $DF0A
  lda #$1F                     ; $DF0D
  sta z:$29                    ; $DF0F
  rts                          ; $DF11
Sub_DF12:
  lda $0139                    ; $DF12
  bne Loc_DF3D                 ; $DF15
  lda z:PaletteDirty           ; $DF17
  cmp #$20                     ; $DF19
  bcc Loc_DF3D                 ; $DF1B
  lda z:PaletteDirty           ; $DF1D
  sec                          ; $DF1F
  sbc #$20                     ; $DF20
  clc                          ; $DF22
  adc $0238                    ; $DF23
  sta $028C                    ; $DF26
  cmp #$D0                     ; $DF29
  bcs Loc_DF3E                 ; $DF2B
  lda #$AE                     ; $DF2D
  sta $028D                    ; $DF2F
  lda #$00                     ; $DF32
  sta $028E                    ; $DF34
  lda $023B                    ; $DF37
  sta $028F                    ; $DF3A
Loc_DF3D:
  rts                          ; $DF3D
Loc_DF3E:
  lda #$F1                     ; $DF3E
  sta $0139                    ; $DF40
  rts                          ; $DF43
Sub_DF44:
  lda z:$29                    ; $DF44
  bne Loc_DF4B                 ; $DF46
  jsr Sub_E079                 ; $DF48
Loc_DF4B:
  lda z:FrameCounter           ; $DF4B
  and #$07                     ; $DF4D
  bne Loc_DF5E                 ; $DF4F
  inc z:$29                    ; $DF51
  lda z:$29                    ; $DF53
  cmp #$90                     ; $DF55
  bcc Loc_DF5E                 ; $DF57
  ldx #$02                     ; $DF59
  jmp Loc_DF97                 ; $DF5B
Loc_DF5E:
  lda z:$29                    ; $DF5E
  cmp #$18                     ; $DF60
  bcs Loc_DF6B                 ; $DF62
  tax                          ; $DF64
  lda Data_DFA4,x              ; $DF65
  jmp Loc_DF6D                 ; $DF68
Loc_DF6B:
  lda #$09                     ; $DF6B
Loc_DF6D:
  asl a                        ; $DF6D
  asl a                        ; $DF6E
  asl a                        ; $DF6F
  tax                          ; $DF70
  ldy #$00                     ; $DF71
Loc_DF73:
  lda Data_DFBC,x              ; $DF73
  sta $0260,y                  ; $DF76
  inx                          ; $DF79
  iny                          ; $DF7A
  cpy #$08                     ; $DF7B
  bcc Loc_DF73                 ; $DF7D
  ldx #$00                     ; $DF7F
Loc_DF81:
  lda Data_E00C,x              ; $DF81
  sta $0268,x                  ; $DF84
  inx                          ; $DF87
  cpx #$08                     ; $DF88
  bcc Loc_DF81                 ; $DF8A
  jsr Sub_E018                 ; $DF8C
  jsr Sub_E042                 ; $DF8F
  jsr Sub_E05E                 ; $DF92
  ldx #$00                     ; $DF95
Loc_DF97:
  lda Data_E014,x              ; $DF97
  sta $0238                    ; $DF9A
  lda Data_E015,x              ; $DF9D
  sta $023B                    ; $DFA0
  rts                          ; $DFA3
Data_DFA4:
  .incbin "prg_bank_7.bin", $1FA4, $18  ; $DFA4
Data_DFBC:
  .incbin "prg_bank_7.bin", $1FBC, $43  ; $DFBC
Data_DFFF:
  .incbin "prg_bank_7.bin", $1FFF, $D  ; $DFFF
Data_E00C:
  .incbin "prg_bank_7.bin", $200C, $8  ; $E00C
Data_E014:
  .incbin "prg_bank_7.bin", $2014, $1  ; $E014
Data_E015:
  .incbin "prg_bank_7.bin", $2015, $3  ; $E015
Sub_E018:
  ldx #$00                     ; $E018
  lda z:$29                    ; $E01A
  cmp #$20                     ; $E01C
  bcc Loc_E035                 ; $E01E
  inx                          ; $E020
  cmp #$23                     ; $E021
  bcc Loc_E035                 ; $E023
  inx                          ; $E025
  cmp #$26                     ; $E026
  bcc Loc_E035                 ; $E028
  inx                          ; $E02A
  cmp #$29                     ; $E02B
  bcc Loc_E035                 ; $E02D
  inx                          ; $E02F
  cmp #$2C                     ; $E030
  bcc Loc_E035                 ; $E032
  inx                          ; $E034
Loc_E035:
  lda Data_E03C,x              ; $E035
  sta $0157                    ; $E038
  rts                          ; $E03B
Data_E03C:
  .incbin "prg_bank_7.bin", $203C, $6  ; $E03C
Sub_E042:
  lda z:$29                    ; $E042
  cmp #$30                     ; $E044
  bcc Loc_E05D                 ; $E046
  lda z:FrameCounter           ; $E048
  and #$07                     ; $E04A
  bne Loc_E05D                 ; $E04C
  lda z:PlayerLifeLo           ; $E04E
  clc                          ; $E050
  adc #$0A                     ; $E051
  sta z:PlayerLifeLo           ; $E053
  cmp #$C8                     ; $E055
  bcc Loc_E05D                 ; $E057
  lda #$C8                     ; $E059
  sta z:PlayerLifeLo           ; $E05B
Loc_E05D:
  rts                          ; $E05D
Sub_E05E:
  lda z:$29                    ; $E05E
  cmp #$50                     ; $E060
  bcc Loc_E078                 ; $E062
  bne Loc_E06E                 ; $E064
  lda #$40                     ; $E066
  sta $013D                    ; $E068
  jmp Loc_E078                 ; $E06B
Loc_E06E:
  cmp #$70                     ; $E06E
  bcs Loc_E078                 ; $E070
  inc $013D                    ; $E072
  jsr Sub_E8D3                 ; $E075
Loc_E078:
  rts                          ; $E078
Sub_E079:
  ldx #$00                     ; $E079
  lda #$FD                     ; $E07B
Loc_E07D:
  sta $0205,x                  ; $E07D
  inx                          ; $E080
  inx                          ; $E081
  inx                          ; $E082
  inx                          ; $E083
  cpx #$3C                     ; $E084
  bcc Loc_E07D                 ; $E086
  rts                          ; $E088
Sub_E089:
  lda z:$28                    ; $E089
  beq Loc_E08E                 ; $E08B
  rts                          ; $E08D
Loc_E08E:
  lda z:ScrollPage             ; $E08E
  jsr AslA4                    ; $E090
  sta z:Tmp02                  ; $E093
  lda z:ScrollX                ; $E095
  clc                          ; $E097
  adc $023B                    ; $E098
  ror a                        ; $E09B
  lsr a                        ; $E09C
  lsr a                        ; $E09D
  lsr a                        ; $E09E
  clc                          ; $E09F
  adc z:Tmp02                  ; $E0A0
  sta z:Tmp02                  ; $E0A2
  lda z:PaletteSetIndex        ; $E0A4
  asl a                        ; $E0A6
  tax                          ; $E0A7
  lda Data_E192,x              ; $E0A8
  sta z:Tmp00                  ; $E0AB
  lda Data_E193,x              ; $E0AD
  sta z:Tmp01                  ; $E0B0
  ldy #$00                     ; $E0B2
  lda (Tmp00),y                ; $E0B4
  bne Loc_E0BB                 ; $E0B6
  jmp Loc_E178                 ; $E0B8
Loc_E0BB:
  tax                          ; $E0BB
  iny                          ; $E0BC
Loc_E0BD:
  iny                          ; $E0BD
  lda (Tmp00),y                ; $E0BE
  jsr AslA4                    ; $E0C0
  sta z:$04                    ; $E0C3
  iny                          ; $E0C5
  lda (Tmp00),y                ; $E0C6
  and #$F0                     ; $E0C8
  clc                          ; $E0CA
  adc z:$04                    ; $E0CB
  sta z:$05                    ; $E0CD
  lda $0238                    ; $E0CF
  cmp z:$04                    ; $E0D2
  bcs Loc_E0D9                 ; $E0D4
  jmp Loc_E16E                 ; $E0D6
Loc_E0D9:
  cmp z:$05                    ; $E0D9
  beq Loc_E0E2                 ; $E0DB
  bcc Loc_E0E2                 ; $E0DD
  jmp Loc_E16E                 ; $E0DF
Loc_E0E2:
  dey                          ; $E0E2
  dey                          ; $E0E3
  lda (Tmp00),y                ; $E0E4
  sta z:$04                    ; $E0E6
  iny                          ; $E0E8
  iny                          ; $E0E9
  lda (Tmp00),y                ; $E0EA
  and #$0F                     ; $E0EC
  clc                          ; $E0EE
  adc z:$04                    ; $E0EF
  sta z:$05                    ; $E0F1
  lda z:Tmp02                  ; $E0F3
  cmp z:$04                    ; $E0F5
  bcc Loc_E16E                 ; $E0F7
  cmp z:$05                    ; $E0F9
  beq Loc_E0FF                 ; $E0FB
  bcs Loc_E16E                 ; $E0FD
Loc_E0FF:
  dey                          ; $E0FF
  lda z:GameState              ; $E100
  cmp #$03                     ; $E102
  bne Loc_E10A                 ; $E104
  lda z:$13                    ; $E106
  bne Loc_E123                 ; $E108
Loc_E10A:
  iny                          ; $E10A
  iny                          ; $E10B
  lda (Tmp00),y                ; $E10C
  sta z:$29                    ; $E10E
  dey                          ; $E110
  dey                          ; $E111
  lda (Tmp00),y                ; $E112
  cmp #$80                     ; $E114
  bcc Loc_E123                 ; $E116
  lda JoyHeld1                 ; $E118
  and #$10                     ; $E11B
  bne Loc_E123                 ; $E11D
  iny                          ; $E11F
  jmp Loc_E16E                 ; $E120
Loc_E123:
  lda z:$29                    ; $E123
  cmp #$50                     ; $E125
  bcc Loc_E155                 ; $E127
  cmp #$78                     ; $E129
  bcs Loc_E155                 ; $E12B
  lda z:$1B                    ; $E12D
  bne Loc_E154                 ; $E12F
  jsr Sub_E17D                 ; $E131
  lda z:$29                    ; $E134
  cmp #$69                     ; $E136
  beq Loc_E154                 ; $E138
  lda #$01                     ; $E13A
  sta z:PaletteDirty           ; $E13C
  lda z:PaletteSetIndex        ; $E13E
  cmp #$1B                     ; $E140
  beq Loc_E154                 ; $E142
  cmp #$3C                     ; $E144
  beq Loc_E154                 ; $E146
  cmp #$4C                     ; $E148
  beq Loc_E154                 ; $E14A
  cmp #$4D                     ; $E14C
  beq Loc_E154                 ; $E14E
  lda #$01                     ; $E150
  sta z:$1B                    ; $E152
Loc_E154:
  rts                          ; $E154
Loc_E155:
  jsr Sub_E17D                 ; $E155
  lda #$00                     ; $E158
  sta z:$1B                    ; $E15A
  sta $0113                    ; $E15C
  sta z:PaletteDirty           ; $E15F
  sta $0430                    ; $E161
  sta $0431                    ; $E164
  sta $0432                    ; $E167
  sta $0433                    ; $E16A
  rts                          ; $E16D
Loc_E16E:
  iny                          ; $E16E
  iny                          ; $E16F
  iny                          ; $E170
  iny                          ; $E171
  dex                          ; $E172
  beq Loc_E178                 ; $E173
  jmp Loc_E0BD                 ; $E175
Loc_E178:
  lda #$00                     ; $E178
  sta z:$28                    ; $E17A
  rts                          ; $E17C
Sub_E17D:
  lda #$01                     ; $E17D
  sta z:$28                    ; $E17F
  iny                          ; $E181
  iny                          ; $E182
  lda (Tmp00),y                ; $E183
  sta z:$29                    ; $E185
  iny                          ; $E187
  lda (Tmp00),y                ; $E188
  sta z:$2A                    ; $E18A
  iny                          ; $E18C
  lda (Tmp00),y                ; $E18D
  sta z:$2B                    ; $E18F
  rts                          ; $E191
Data_E192:
  .incbin "prg_bank_7.bin", $2192, $1  ; $E192
Data_E193:
  .incbin "prg_bank_7.bin", $2193, $400  ; $E193
  .incbin "prg_bank_7.bin", $2593, $6A  ; $E593
Sub_E5FD:
  lda z:GameState              ; $E5FD
  cmp #$03                     ; $E5FF
  bcc Loc_E613                 ; $E601
  cmp #$07                     ; $E603
  bcs Loc_E613                 ; $E605
  lda $013A                    ; $E607
  bne Loc_E634                 ; $E60A
  lda JoyNew1                  ; $E60C
  and #$08                     ; $E60F
  bne Loc_E614                 ; $E611
Loc_E613:
  rts                          ; $E613
Loc_E614:
  lda $0238                    ; $E614
  sta $013B                    ; $E617
  lda $023B                    ; $E61A
  sta $013C                    ; $E61D
  lda #$01                     ; $E620
  sta z:MmcPrgShadow           ; $E622
  lda #$00                     ; $E624
  sta SceneState               ; $E626
  lda #$02                     ; $E629
  sta $013A                    ; $E62B
  lda #$00                     ; $E62E
  sta $0117                    ; $E630
  rts                          ; $E633
Loc_E634:
  dec $013A                    ; $E634
  lda $013A                    ; $E637
  cmp #$01                     ; $E63A
  bne Loc_E65B                 ; $E63C
  ldx #$00                     ; $E63E
Loc_E640:
  lda Data_CC9B,x              ; $E640
  sta OamBuffer,x              ; $E643
  inx                          ; $E646
  cpx #$04                     ; $E647
  bcc Loc_E640                 ; $E649
  lda $013B                    ; $E64B
  sta $0238                    ; $E64E
  lda $013C                    ; $E651
  sta $023B                    ; $E654
  jsr DoOamDma                 ; $E657
  rts                          ; $E65A
Loc_E65B:
  jsr Sub_D177                 ; $E65B
  lda #$18                     ; $E65E
  jsr SetPpuMask               ; $E660
  rts                          ; $E663
Sub_E664:
  lda $013E                    ; $E664
  bne Loc_E66C                 ; $E667
  lda #$00                     ; $E669
  rts                          ; $E66B
Loc_E66C:
  lda #$00                     ; $E66C
  sta $013E                    ; $E66E
  lda $013F                    ; $E671
  cmp #$78                     ; $E674
  bcc Loc_E67B                 ; $E676
  jmp Loc_E6EF                 ; $E678
Loc_E67B:
  cmp #$50                     ; $E67B
  bcs Loc_E6D1                 ; $E67D
  lda $0100                    ; $E67F
  asl a                        ; $E682
  tax                          ; $E683
  lda Data_E712,x              ; $E684
  sta z:$04                    ; $E687
  lda Data_E713,x              ; $E689
  sta z:$05                    ; $E68C
  ldy #$00                     ; $E68E
  lda ($04),y                  ; $E690
  tax                          ; $E692
Loc_E693:
  cpx #$00                     ; $E693
  beq Loc_E6C4                 ; $E695
  iny                          ; $E697
  lda ($04),y                  ; $E698
  cmp $013F                    ; $E69A
  beq Loc_E6A5                 ; $E69D
  iny                          ; $E69F
  iny                          ; $E6A0
  iny                          ; $E6A1
  jmp Loc_E693                 ; $E6A2
Loc_E6A5:
  iny                          ; $E6A5
  lda ($04),y                  ; $E6A6
  sta z:$29                    ; $E6A8
  iny                          ; $E6AA
  lda ($04),y                  ; $E6AB
  and #$F0                     ; $E6AD
  sta z:$2A                    ; $E6AF
  lda ($04),y                  ; $E6B1
  and #$0F                     ; $E6B3
  sta $0100                    ; $E6B5
  iny                          ; $E6B8
  lda ($04),y                  ; $E6B9
  sta z:$2B                    ; $E6BB
  lda #$00                     ; $E6BD
  sta z:$1B                    ; $E6BF
  jmp Loc_E6CC                 ; $E6C1
Loc_E6C4:
  lda #$00                     ; $E6C4
  sta z:$29                    ; $E6C6
  sta z:$2A                    ; $E6C8
  sta z:$2B                    ; $E6CA
Loc_E6CC:
  ldx #$00                     ; $E6CC
  jmp Loc_E705                 ; $E6CE
Loc_E6D1:
  sta z:PaletteSetIndex        ; $E6D1
  cmp #$69                     ; $E6D3
  bne Loc_E6E4                 ; $E6D5
  lda #$5A                     ; $E6D7
  sta z:$04                    ; $E6D9
  lda #$E8                     ; $E6DB
  sta z:$05                    ; $E6DD
  ldy #$00                     ; $E6DF
  jmp Loc_E6A5                 ; $E6E1
Loc_E6E4:
  lda #$00                     ; $E6E4
  sta z:PaletteDirty           ; $E6E6
  lda #$02                     ; $E6E8
  ldx #$10                     ; $E6EA
  jmp Loc_E703                 ; $E6EC
Loc_E6EF:
  sec                          ; $E6EF
  sbc #$78                     ; $E6F0
  sta $0501                    ; $E6F2
  lda #$03                     ; $E6F5
  sta SceneState               ; $E6F7
  lda #$00                     ; $E6FA
  sta $0502                    ; $E6FC
  lda #$04                     ; $E6FF
  ldx #$20                     ; $E701
Loc_E703:
  sta z:MmcPrgShadow           ; $E703
Loc_E705:
  stx z:GameState              ; $E705
  lda #$03                     ; $E707
  sta $0106                    ; $E709
  jsr Sub_E85E                 ; $E70C
  lda #$01                     ; $E70F
  rts                          ; $E711
Data_E712:
  .incbin "prg_bank_7.bin", $2712, $1  ; $E712
Data_E713:
  .incbin "prg_bank_7.bin", $2713, $14B  ; $E713
Sub_E85E:
  lda #$C8                     ; $E85E
  sta z:PlayerLifeLo           ; $E860
  lda #$00                     ; $E862
  sta z:PlayerLifeHi           ; $E864
  lda z:AmmoHi                 ; $E866
  and #$01                     ; $E868
  lsr a                        ; $E86A
  sta z:AmmoHi                 ; $E86B
  lda z:AmmoLo                 ; $E86D
  ror a                        ; $E86F
  sta z:AmmoLo                 ; $E870
  lda z:AmmoLo                 ; $E872
  cmp #$0A                     ; $E874
  bcs Loc_E882                 ; $E876
  lda z:$29                    ; $E878
  cmp #$77                     ; $E87A
  beq Loc_E882                 ; $E87C
  lda #$0A                     ; $E87E
  sta z:AmmoLo                 ; $E880
Loc_E882:
  rts                          ; $E882
Sub_E883:
  jsr Sub_E916                 ; $E883
  lda $013D                    ; $E886
  beq Loc_E899                 ; $E889
  jsr Sub_E8D3                 ; $E88B
  inc $013D                    ; $E88E
  lda $013D                    ; $E891
  cmp #$80                     ; $E894
  bcs Loc_E8A5                 ; $E896
  rts                          ; $E898
Loc_E899:
  lda z:PlayerLifeLo           ; $E899
  ora z:PlayerLifeHi           ; $E89B
  bne Loc_E8BE                 ; $E89D
  lda #$01                     ; $E89F
  sta $013D                    ; $E8A1
  rts                          ; $E8A4
Loc_E8A5:
  lda #$00                     ; $E8A5
  sta $013D                    ; $E8A7
  lda #$05                     ; $E8AA
  sta z:MmcPrgShadow           ; $E8AC
  lda #$03                     ; $E8AE
  sta SceneState               ; $E8B0
  lda z:PaletteSetIndex        ; $E8B3
  sta $013F                    ; $E8B5
  lda #$0B                     ; $E8B8
  jsr EnqueueByte              ; $E8BA
  rts                          ; $E8BD
Loc_E8BE:
  lda z:SecondCounter          ; $E8BE
  and #$03                     ; $E8C0
  bne Loc_E8D2                 ; $E8C2
  lda z:FrameInSecond          ; $E8C4
  cmp #$09                     ; $E8C6
  bne Loc_E8D2                 ; $E8C8
  dec z:PlayerLifeLo           ; $E8CA
  cmp #$FF                     ; $E8CC
  bne Loc_E8D2                 ; $E8CE
  dec z:PlayerLifeHi           ; $E8D0
Loc_E8D2:
  rts                          ; $E8D2
Sub_E8D3:
  lda $013D                    ; $E8D3
  cmp #$40                     ; $E8D6
  bne Loc_E8DF                 ; $E8D8
  lda #$30                     ; $E8DA
  jmp Loc_E8EE                 ; $E8DC
Loc_E8DF:
  cmp #$50                     ; $E8DF
  bne Loc_E8E8                 ; $E8E1
  lda #$20                     ; $E8E3
  jmp Loc_E8EE                 ; $E8E5
Loc_E8E8:
  cmp #$60                     ; $E8E8
  bne Loc_E905                 ; $E8EA
  lda #$10                     ; $E8EC
Loc_E8EE:
  sta z:$04                    ; $E8EE
  ldx #$00                     ; $E8F0
Loc_E8F2:
  lda PaletteBuffer,x          ; $E8F2
  cmp z:$04                    ; $E8F5
  bcc Loc_E8FF                 ; $E8F7
  sec                          ; $E8F9
  sbc #$10                     ; $E8FA
  sta PaletteBuffer,x          ; $E8FC
Loc_E8FF:
  inx                          ; $E8FF
  cpx #$20                     ; $E900
  bcc Loc_E8F2                 ; $E902
  rts                          ; $E904
Loc_E905:
  cmp #$70                     ; $E905
  bcc Loc_E915                 ; $E907
  ldx #$00                     ; $E909
  lda #$0F                     ; $E90B
Loc_E90D:
  sta PaletteBuffer,x          ; $E90D
  inx                          ; $E910
  cpx #$20                     ; $E911
  bcc Loc_E90D                 ; $E913
Loc_E915:
  rts                          ; $E915
Sub_E916:
  lda $0117                    ; $E916
  bne Loc_E928                 ; $E919
  lda z:PlayerLifeLo           ; $E91B
  cmp #$32                     ; $E91D
  bcs Loc_E938                 ; $E91F
  ldx #$01                     ; $E921
  lda #$42                     ; $E923
  jmp Loc_E932                 ; $E925
Loc_E928:
  lda z:PlayerLifeLo           ; $E928
  cmp #$32                     ; $E92A
  bcc Loc_E938                 ; $E92C
  ldx #$00                     ; $E92E
  lda #$44                     ; $E930
Loc_E932:
  stx $0117                    ; $E932
  jsr EnqueueByte              ; $E935
Loc_E938:
  rts                          ; $E938
Sub_E939:
  lda z:PaletteDirty           ; $E939
  bne Loc_E960                 ; $E93B
  lda z:$30                    ; $E93D
  beq Loc_E947                 ; $E93F
  jsr Sub_E971                 ; $E941
  jmp Loc_E94A                 ; $E944
Loc_E947:
  jsr Sub_EA02                 ; $E947
Loc_E94A:
  lda z:$33                    ; $E94A
  beq Loc_E954                 ; $E94C
  jsr Sub_EA2D                 ; $E94E
  jmp Loc_E957                 ; $E951
Loc_E954:
  jsr Sub_EA61                 ; $E954
Loc_E957:
  jsr Sub_EAD9                 ; $E957
  jsr Sub_EB2F                 ; $E95A
  jsr Sub_EBE4                 ; $E95D
Loc_E960:
  rts                          ; $E960
Data_E961:
  .incbin "prg_bank_7.bin", $2961, $10  ; $E961
Sub_E971:
  ldx z:$31                    ; $E971
  lda Data_E9D2,x              ; $E973
  cpx #$30                     ; $E976
  bcc Loc_E97C                 ; $E978
  lda #$06                     ; $E97A
Loc_E97C:
  clc                          ; $E97C
  adc $0238                    ; $E97D
  sta $0238                    ; $E980
  inc z:$31                    ; $E983
  lda z:$31                    ; $E985
  cmp #$18                     ; $E987
  bcs Loc_E999                 ; $E989
  lda JoyHeld1                 ; $E98B
  and #$02                     ; $E98E
  bne Loc_E9C6                 ; $E990
  lda #$18                     ; $E992
  sta z:$31                    ; $E994
  jmp Loc_E9C6                 ; $E996
Loc_E999:
  ldx z:MmcChr1Shadow          ; $E999
  lda z:$3F                    ; $E99B
  cmp Data_E961,x              ; $E99D
  bcc Loc_E9C6                 ; $E9A0
  lda $0238                    ; $E9A2
  cmp #$90                     ; $E9A5
  bcs Loc_E9B0                 ; $E9A7
  lda JoyHeld1                 ; $E9A9
  and #$20                     ; $E9AC
  bne Loc_E9C6                 ; $E9AE
Loc_E9B0:
  lda #$00                     ; $E9B0
  sta z:$30                    ; $E9B2
  sta z:$33                    ; $E9B4
  lda z:FireMode               ; $E9B6
  and #$10                     ; $E9B8
  sta z:FireMode               ; $E9BA
  lda $0238                    ; $E9BC
  and #$F0                     ; $E9BF
  ora #$02                     ; $E9C1
  sta $0238                    ; $E9C3
Loc_E9C6:
  lda z:FireMode               ; $E9C6
  and #$0F                     ; $E9C8
  cmp #$04                     ; $E9CA
  bcs Loc_E9D1                 ; $E9CC
  jsr UpdateFireMode           ; $E9CE
Loc_E9D1:
  rts                          ; $E9D1
Data_E9D2:
  .incbin "prg_bank_7.bin", $29D2, $30  ; $E9D2
Sub_EA02:
  lda z:FireMode               ; $EA02
  and #$0F                     ; $EA04
  cmp #$03                     ; $EA06
  bcs Loc_EA2C                 ; $EA08
  lda JoyNew1                  ; $EA0A
  and #$02                     ; $EA0D
  beq Loc_EA16                 ; $EA0F
  lda #$00                     ; $EA11
  jmp Loc_EA21                 ; $EA13
Loc_EA16:
  ldx z:MmcChr1Shadow          ; $EA16
  lda z:$3F                    ; $EA18
  cmp Data_E961,x              ; $EA1A
  bcs Loc_EA2C                 ; $EA1D
  lda #$20                     ; $EA1F
Loc_EA21:
  sta z:$31                    ; $EA21
  lda #$01                     ; $EA23
  sta z:$30                    ; $EA25
  ldx #$03                     ; $EA27
  jsr SetFireModeLow           ; $EA29
Loc_EA2C:
  rts                          ; $EA2C
Sub_EA2D:
  inc z:$34                    ; $EA2D
  lda z:FireMode               ; $EA2F
  and #$0F                     ; $EA31
  cmp #$04                     ; $EA33
  bne Loc_EA42                 ; $EA35
  lda z:$34                    ; $EA37
  cmp #$20                     ; $EA39
  bcc Loc_EA60                 ; $EA3B
  ldx #$03                     ; $EA3D
  jmp Loc_EA59                 ; $EA3F
Loc_EA42:
  cmp #$06                     ; $EA42
  bne Loc_EA51                 ; $EA44
  lda z:$34                    ; $EA46
  cmp #$20                     ; $EA48
  bcc Loc_EA60                 ; $EA4A
  ldx #$00                     ; $EA4C
  jmp Loc_EA59                 ; $EA4E
Loc_EA51:
  lda z:$34                    ; $EA51
  cmp #$E0                     ; $EA53
  bcc Loc_EA60                 ; $EA55
  ldx #$00                     ; $EA57
Loc_EA59:
  jsr SetFireModeLow           ; $EA59
  lda #$00                     ; $EA5C
  sta z:$33                    ; $EA5E
Loc_EA60:
  rts                          ; $EA60
Sub_EA61:
  lda JoyNew1                  ; $EA61
  and #$01                     ; $EA64
  beq Loc_EAA9                 ; $EA66
  lda z:$3C                    ; $EA68
  beq Loc_EA81                 ; $EA6A
  lda z:AmmoLo                 ; $EA6C
  ora z:AmmoHi                 ; $EA6E
  beq Loc_EA81                 ; $EA70
  lda z:FireMode               ; $EA72
  and #$0F                     ; $EA74
  cmp #$03                     ; $EA76
  beq Loc_EA9C                 ; $EA78
  bcs Loc_EA9E                 ; $EA7A
  ldx #$06                     ; $EA7C
  jmp Loc_EA9E                 ; $EA7E
Loc_EA81:
  lda z:FireMode               ; $EA81
  and #$0F                     ; $EA83
  cmp #$03                     ; $EA85
  beq Loc_EA9C                 ; $EA87
  bcs Loc_EAA9                 ; $EA89
  lda #$01                     ; $EA8B
  sta z:$30                    ; $EA8D
  lda #$20                     ; $EA8F
  sta z:$31                    ; $EA91
  lda $0238                    ; $EA93
  sec                          ; $EA96
  sbc #$18                     ; $EA97
  sta $0238                    ; $EA99
Loc_EA9C:
  ldx #$04                     ; $EA9C
Loc_EA9E:
  jsr SetFireModeLow           ; $EA9E
  lda #$01                     ; $EAA1
  sta z:$33                    ; $EAA3
  lda #$00                     ; $EAA5
  sta z:$34                    ; $EAA7
Loc_EAA9:
  rts                          ; $EAA9
SetFireModeLow:
  lda z:FireMode               ; $EAAA
  and #$10                     ; $EAAC
  sta z:FireMode               ; $EAAE
  txa                          ; $EAB0
  ora z:FireMode               ; $EAB1
  sta z:FireMode               ; $EAB3
  rts                          ; $EAB5
UpdateFireMode:
  lda JoyHeld1                 ; $EAB6
  and #$C0                     ; $EAB9
  beq Loc_EACE                 ; $EABB
  cmp #$40                     ; $EABD
  bne Loc_EAC8                 ; $EABF
  lda z:FireMode               ; $EAC1
  ora #$10                     ; $EAC3
  jmp Loc_EACC                 ; $EAC5
Loc_EAC8:
  lda z:FireMode               ; $EAC8
  and #$0F                     ; $EACA
Loc_EACC:
  sta z:FireMode               ; $EACC
Loc_EACE:
  rts                          ; $EACE
UseAmmo:
  cpx #$06                     ; $EACF
  bcc Loc_EAD8                 ; $EAD1
  lda #$FF                     ; $EAD3
  jsr AdjustAmmo               ; $EAD5
Loc_EAD8:
  rts                          ; $EAD8
Sub_EAD9:
  lda z:FireMode               ; $EAD9
  and #$0F                     ; $EADB
  cmp #$01                     ; $EADD
  bcs Loc_EAED                 ; $EADF
  lda JoyHeld1                 ; $EAE1
  and #$C0                     ; $EAE4
  beq Loc_EB09                 ; $EAE6
  ldx #$01                     ; $EAE8
  jmp Loc_EAF8                 ; $EAEA
Loc_EAED:
  bne Loc_EAFE                 ; $EAED
  lda JoyHeld1                 ; $EAEF
  and #$C0                     ; $EAF2
  bne Loc_EB09                 ; $EAF4
  ldx #$00                     ; $EAF6
Loc_EAF8:
  jsr SetFireModeLow           ; $EAF8
  jsr UseAmmo                  ; $EAFB
Loc_EAFE:
  lda z:FireMode               ; $EAFE
  and #$0F                     ; $EB00
  cmp #$04                     ; $EB02
  bcs Loc_EB09                 ; $EB04
  jsr UpdateFireMode           ; $EB06
Loc_EB09:
  lda z:FireMode               ; $EB09
  and #$0F                     ; $EB0B
  cmp #$02                     ; $EB0D
  beq Loc_EB1F                 ; $EB0F
  bcs Loc_EB2E                 ; $EB11
  lda JoyHeld1                 ; $EB13
  and #$20                     ; $EB16
  beq Loc_EB2E                 ; $EB18
  ldx #$02                     ; $EB1A
  jmp Loc_EB28                 ; $EB1C
Loc_EB1F:
  lda JoyHeld1                 ; $EB1F
  and #$20                     ; $EB22
  bne Loc_EB2E                 ; $EB24
  ldx #$00                     ; $EB26
Loc_EB28:
  jsr SetFireModeLow           ; $EB28
  jsr UseAmmo                  ; $EB2B
Loc_EB2E:
  rts                          ; $EB2E
Sub_EB2F:
  lda z:FireMode               ; $EB2F
  and #$0F                     ; $EB31
  bne Loc_EB38                 ; $EB33
  jmp Loc_EBD7                 ; $EB35
Loc_EB38:
  cmp #$01                     ; $EB38
  bne Loc_EB55                 ; $EB3A
  lda z:FrameCounter           ; $EB3C
  and #$30                     ; $EB3E
  jsr LsrA4                    ; $EB40
  cmp #$02                     ; $EB43
  bne Loc_EB4C                 ; $EB45
  lda #$00                     ; $EB47
  jmp Loc_EBD9                 ; $EB49
Loc_EB4C:
  cmp #$03                     ; $EB4C
  bne Loc_EB52                 ; $EB4E
  lda #$02                     ; $EB50
Loc_EB52:
  jmp Loc_EBD9                 ; $EB52
Loc_EB55:
  cmp #$02                     ; $EB55
  bne Loc_EB5E                 ; $EB57
  lda #$04                     ; $EB59
  jmp Loc_EBD9                 ; $EB5B
Loc_EB5E:
  cmp #$03                     ; $EB5E
  bne Loc_EB72                 ; $EB60
  lda z:$31                    ; $EB62
  cmp #$08                     ; $EB64
  bcs Loc_EB6D                 ; $EB66
  lda #$04                     ; $EB68
  jmp Loc_EBD9                 ; $EB6A
Loc_EB6D:
  lda #$05                     ; $EB6D
  jmp Loc_EBD9                 ; $EB6F
Loc_EB72:
  cmp #$04                     ; $EB72
  bne Loc_EB7B                 ; $EB74
  lda #$06                     ; $EB76
  jmp Loc_EBD9                 ; $EB78
Loc_EB7B:
  cmp #$06                     ; $EB7B
  bne Loc_EBA8                 ; $EB7D
  lda z:$34                    ; $EB7F
  cmp #$08                     ; $EB81
  bne Loc_EB8B                 ; $EB83
  jsr Sub_EEC9                 ; $EB85
  jmp Loc_EB91                 ; $EB88
Loc_EB8B:
  bcc Loc_EBD7                 ; $EB8B
  cmp #$10                     ; $EB8D
  bcs Loc_EB96                 ; $EB8F
Loc_EB91:
  lda #$08                     ; $EB91
  jmp Loc_EBD9                 ; $EB93
Loc_EB96:
  cmp #$18                     ; $EB96
  bcs Loc_EB9F                 ; $EB98
  lda #$09                     ; $EB9A
  jmp Loc_EBD9                 ; $EB9C
Loc_EB9F:
  cmp #$20                     ; $EB9F
  bcs Loc_EBD7                 ; $EBA1
  lda #$08                     ; $EBA3
  jmp Loc_EBD9                 ; $EBA5
Loc_EBA8:
  inc z:$34                    ; $EBA8
  lda z:$34                    ; $EBAA
  cmp #$20                     ; $EBAC
  bcs Loc_EBB5                 ; $EBAE
  lda #$00                     ; $EBB0
  jmp Loc_EBD9                 ; $EBB2
Loc_EBB5:
  cmp #$E0                     ; $EBB5
  bcs Loc_EBD2                 ; $EBB7
  and #$1F                     ; $EBB9
  cmp #$0A                     ; $EBBB
  bcs Loc_EBC4                 ; $EBBD
  lda #$0A                     ; $EBBF
  jmp Loc_EBD9                 ; $EBC1
Loc_EBC4:
  cmp #$16                     ; $EBC4
  bcs Loc_EBCD                 ; $EBC6
  lda #$0B                     ; $EBC8
  jmp Loc_EBD9                 ; $EBCA
Loc_EBCD:
  lda #$0C                     ; $EBCD
  jmp Loc_EBD9                 ; $EBCF
Loc_EBD2:
  ldx #$00                     ; $EBD2
  jsr SetFireModeLow           ; $EBD4
Loc_EBD7:
  lda #$07                     ; $EBD7
Loc_EBD9:
  sta z:Tmp02                  ; $EBD9
  lda z:FireMode               ; $EBDB
  and #$10                     ; $EBDD
  ora z:Tmp02                  ; $EBDF
  sta z:PlayerSpriteFrame      ; $EBE1
  rts                          ; $EBE3
Sub_EBE4:
  lda #$F0                     ; $EBE4
  sta $0248                    ; $EBE6
  sta $024C                    ; $EBE9
  sta $0250                    ; $EBEC
  sta $0254                    ; $EBEF
  lda z:PlayerSpriteFrame      ; $EBF2
  asl a                        ; $EBF4
  tax                          ; $EBF5
  lda Data_EC2F,x              ; $EBF6
  sta z:Tmp00                  ; $EBF9
  lda Data_EC30,x              ; $EBFB
  sta z:Tmp01                  ; $EBFE
  ldy #$00                     ; $EC00
  lda (Tmp00),y                ; $EC02
  tax                          ; $EC04
  inc z:Tmp00                  ; $EC05
  bne Loc_EC0B                 ; $EC07
  inc z:Tmp01                  ; $EC09
Loc_EC0B:
  lda (Tmp00),y                ; $EC0B
  clc                          ; $EC0D
  adc $0238                    ; $EC0E
  sta $0238,y                  ; $EC11
  iny                          ; $EC14
  lda (Tmp00),y                ; $EC15
  sta $0238,y                  ; $EC17
  iny                          ; $EC1A
  lda (Tmp00),y                ; $EC1B
  sta $0238,y                  ; $EC1D
  iny                          ; $EC20
  lda (Tmp00),y                ; $EC21
  clc                          ; $EC23
  adc $023B                    ; $EC24
  sta $0238,y                  ; $EC27
  iny                          ; $EC2A
  dex                          ; $EC2B
  bne Loc_EC0B                 ; $EC2C
  rts                          ; $EC2E
Data_EC2F:
  .incbin "prg_bank_7.bin", $2C2F, $1  ; $EC2F
Data_EC30:
  .incbin "prg_bank_7.bin", $2C30, $287  ; $EC30
AdjustAmmo:
  clc                          ; $EEB7
  adc z:AmmoLo                 ; $EEB8
  sta z:AmmoLo                 ; $EEBA
  bcs Loc_EEC8                 ; $EEBC
  dec z:AmmoHi                 ; $EEBE
  bpl Loc_EEC8                 ; $EEC0
  lda #$00                     ; $EEC2
  sta z:AmmoLo                 ; $EEC4
  sta z:AmmoHi                 ; $EEC6
Loc_EEC8:
  rts                          ; $EEC8
Sub_EEC9:
  lda z:AmmoLo                 ; $EEC9
  bne Loc_EED2                 ; $EECB
  lda z:AmmoHi                 ; $EECD
  bne Loc_EED2                 ; $EECF
  rts                          ; $EED1
Loc_EED2:
  ldx #$58                     ; $EED2
Loc_EED4:
  lda OamBuffer,x              ; $EED4
  cmp #$E8                     ; $EED7
  bcs Loc_EEE4                 ; $EED9
  inx                          ; $EEDB
  inx                          ; $EEDC
  inx                          ; $EEDD
  inx                          ; $EEDE
  cpx #$68                     ; $EEDF
  bcc Loc_EED4                 ; $EEE1
  rts                          ; $EEE3
Loc_EEE4:
  lda $0238                    ; $EEE4
  clc                          ; $EEE7
  adc #$03                     ; $EEE8
  sta OamBuffer,x              ; $EEEA
  lda #$BE                     ; $EEED
  sta $0201,x                  ; $EEEF
  lda z:FireMode               ; $EEF2
  and #$10                     ; $EEF4
  bne Loc_EEFF                 ; $EEF6
  ldy #$00                     ; $EEF8
  lda #$18                     ; $EEFA
  jmp Loc_EF03                 ; $EEFC
Loc_EEFF:
  ldy #$40                     ; $EEFF
  lda #$F0                     ; $EF01
Loc_EF03:
  clc                          ; $EF03
  adc $023B                    ; $EF04
  sta $0203,x                  ; $EF07
  tya                          ; $EF0A
  sta $0202,x                  ; $EF0B
  lda #$FF                     ; $EF0E
  jsr AdjustAmmo               ; $EF10
  lda #$0E                     ; $EF13
  jsr EnqueueByte              ; $EF15
  rts                          ; $EF18
Sub_EF19:
  lda z:PaletteDirty           ; $EF19
  bne Loc_EF2C                 ; $EF1B
  jsr Sub_EF2D                 ; $EF1D
  jsr Sub_EF7B                 ; $EF20
  jsr Sub_EFA9                 ; $EF23
  jsr Sub_EFAA                 ; $EF26
  jsr Sub_F23D                 ; $EF29
Loc_EF2C:
  rts                          ; $EF2C
Sub_EF2D:
  lda z:FireMode               ; $EF2D
  and #$0F                     ; $EF2F
  bne Loc_EF36                 ; $EF31
  jsr UpdateFireMode           ; $EF33
Loc_EF36:
  ldx #$00                     ; $EF36
  jsr SetFireModeLow           ; $EF38
  ldx #$01                     ; $EF3B
  lda z:FireMode               ; $EF3D
  and #$10                     ; $EF3F
  bne Loc_EF4D                 ; $EF41
  lda JoyHeld1                 ; $EF43
  and #$80                     ; $EF46
  bne Loc_EF63                 ; $EF48
  jmp Loc_EF54                 ; $EF4A
Loc_EF4D:
  lda JoyHeld1                 ; $EF4D
  and #$40                     ; $EF50
  bne Loc_EF63                 ; $EF52
Loc_EF54:
  lda JoyHeld1                 ; $EF54
  and #$30                     ; $EF57
  inx                          ; $EF59
  cmp #$10                     ; $EF5A
  beq Loc_EF63                 ; $EF5C
  inx                          ; $EF5E
  cmp #$20                     ; $EF5F
  bne Loc_EF66                 ; $EF61
Loc_EF63:
  jsr SetFireModeLow           ; $EF63
Loc_EF66:
  lda JoyHeld1                 ; $EF66
  and #$30                     ; $EF69
  beq Loc_EF7A                 ; $EF6B
  cmp #$10                     ; $EF6D
  bne Loc_EF77                 ; $EF6F
  dec $0238                    ; $EF71
  jmp Loc_EF7A                 ; $EF74
Loc_EF77:
  inc $0238                    ; $EF77
Loc_EF7A:
  rts                          ; $EF7A
Sub_EF7B:
  lda z:FireMode               ; $EF7B
  and #$10                     ; $EF7D
  beq Loc_EF83                 ; $EF7F
  lda #$0C                     ; $EF81
Loc_EF83:
  sta z:PlayerSpriteFrame      ; $EF83
  lda z:FireMode               ; $EF85
  and #$03                     ; $EF87
  tax                          ; $EF89
  lda Data_EFA5,x              ; $EF8A
  clc                          ; $EF8D
  adc z:PlayerSpriteFrame      ; $EF8E
  sta z:PlayerSpriteFrame      ; $EF90
  lda z:FrameCounter           ; $EF92
  and #$30                     ; $EF94
  jsr LsrA4                    ; $EF96
  cmp #$03                     ; $EF99
  bne Loc_EF9F                 ; $EF9B
  lda #$01                     ; $EF9D
Loc_EF9F:
  clc                          ; $EF9F
  adc z:PlayerSpriteFrame      ; $EFA0
  sta z:PlayerSpriteFrame      ; $EFA2
  rts                          ; $EFA4
Data_EFA5:
  .incbin "prg_bank_7.bin", $2FA5, $4  ; $EFA5
Sub_EFA9:
  rts                          ; $EFA9
Sub_EFAA:
  lda #$00                     ; $EFAA
  sta z:Tmp01                  ; $EFAC
  lda z:PlayerSpriteFrame      ; $EFAE
  asl a                        ; $EFB0
  asl a                        ; $EFB1
  asl a                        ; $EFB2
  pha                          ; $EFB3
  asl a                        ; $EFB4
  rol z:Tmp01                  ; $EFB5
  sta z:Tmp00                  ; $EFB7
  pla                          ; $EFB9
  clc                          ; $EFBA
  adc z:Tmp00                  ; $EFBB
  sta z:Tmp00                  ; $EFBD
  lda z:Tmp01                  ; $EFBF
  adc #$00                     ; $EFC1
  sta z:Tmp01                  ; $EFC3
  lda z:Tmp00                  ; $EFC5
  clc                          ; $EFC7
  adc #$FD                     ; $EFC8
  sta z:Tmp00                  ; $EFCA
  lda z:Tmp01                  ; $EFCC
  adc #$EF                     ; $EFCE
  sta z:Tmp01                  ; $EFD0
  ldy #$00                     ; $EFD2
Loc_EFD4:
  lda (Tmp00),y                ; $EFD4
  cmp #$FF                     ; $EFD6
  beq Loc_EFDE                 ; $EFD8
  clc                          ; $EFDA
  adc $0238                    ; $EFDB
Loc_EFDE:
  sta $0238,y                  ; $EFDE
  iny                          ; $EFE1
  lda (Tmp00),y                ; $EFE2
  sta $0238,y                  ; $EFE4
  iny                          ; $EFE7
  lda (Tmp00),y                ; $EFE8
  sta $0238,y                  ; $EFEA
  iny                          ; $EFED
  lda (Tmp00),y                ; $EFEE
  clc                          ; $EFF0
  adc $023B                    ; $EFF1
  sta $0238,y                  ; $EFF4
  iny                          ; $EFF7
  cpy #$18                     ; $EFF8
  bcc Loc_EFD4                 ; $EFFA
  rts                          ; $EFFC
  .incbin "prg_bank_7.bin", $2FFD, $240  ; $EFFD
Sub_F23D:
  lda z:FireMode               ; $F23D
  and #$0F                     ; $F23F
  cmp #$02                     ; $F241
  bcs Loc_F29C                 ; $F243
  tay                          ; $F245
  lda JoyNew1                  ; $F246
  and #$01                     ; $F249
  beq Loc_F29C                 ; $F24B
  lda z:AmmoLo                 ; $F24D
  ora z:AmmoHi                 ; $F24F
  beq Loc_F29C                 ; $F251
  ldx #$54                     ; $F253
Loc_F255:
  lda OamBuffer,x              ; $F255
  cmp #$E8                     ; $F258
  bcs Loc_F265                 ; $F25A
  inx                          ; $F25C
  inx                          ; $F25D
  inx                          ; $F25E
  inx                          ; $F25F
  cpx #$5C                     ; $F260
  bcc Loc_F255                 ; $F262
  rts                          ; $F264
Loc_F265:
  lda #$07                     ; $F265
  cpy #$00                     ; $F267
  beq Loc_F26D                 ; $F269
  lda #$10                     ; $F26B
Loc_F26D:
  clc                          ; $F26D
  adc $0238                    ; $F26E
  sta OamBuffer,x              ; $F271
  lda #$3C                     ; $F274
  sta $0201,x                  ; $F276
  lda z:FireMode               ; $F279
  and #$10                     ; $F27B
  asl a                        ; $F27D
  asl a                        ; $F27E
  sta $0202,x                  ; $F27F
  bne Loc_F289                 ; $F282
  lda #$18                     ; $F284
  jmp Loc_F28B                 ; $F286
Loc_F289:
  lda #$F4                     ; $F289
Loc_F28B:
  clc                          ; $F28B
  adc $023B                    ; $F28C
  sta $0203,x                  ; $F28F
  lda #$0F                     ; $F292
  jsr EnqueueByte              ; $F294
  lda #$FF                     ; $F297
  jsr AdjustAmmo               ; $F299
Loc_F29C:
  rts                          ; $F29C
Sub_F29D:
  lda #$00                     ; $F29D
  sta z:$3E                    ; $F29F
  lda z:$13                    ; $F2A1
  bne Loc_F2AB                 ; $F2A3
  jsr Sub_F2DA                 ; $F2A5
  jmp Loc_F2D9                 ; $F2A8
Loc_F2AB:
  cmp #$02                     ; $F2AB
  bne Loc_F2D9                 ; $F2AD
  ldx #$00                     ; $F2AF
  lda $023B                    ; $F2B1
  cmp #$78                     ; $F2B4
  bne Loc_F2C1                 ; $F2B6
  lda z:ScrollX                ; $F2B8
  and #$07                     ; $F2BA
  beq Loc_F2C8                 ; $F2BC
  jmp Loc_F2C9                 ; $F2BE
Loc_F2C1:
  lda $023B                    ; $F2C1
  and #$07                     ; $F2C4
  bne Loc_F2C9                 ; $F2C6
Loc_F2C8:
  inx                          ; $F2C8
Loc_F2C9:
  lda $0238                    ; $F2C9
  and #$07                     ; $F2CC
  bne Loc_F2D2                 ; $F2CE
  inx                          ; $F2D0
  inx                          ; $F2D1
Loc_F2D2:
  cpx #$00                     ; $F2D2
  beq Loc_F2D9                 ; $F2D4
  jsr Sub_F2FA                 ; $F2D6
Loc_F2D9:
  rts                          ; $F2D9
Sub_F2DA:
  lda #$01                     ; $F2DA
  sta z:$3E                    ; $F2DC
  lda $0238                    ; $F2DE
  clc                          ; $F2E1
  adc #$2F                     ; $F2E2
  sta z:Tmp02                  ; $F2E4
  lda $023B                    ; $F2E6
  clc                          ; $F2E9
  adc #$07                     ; $F2EA
  sta z:Tmp03                  ; $F2EC
  jsr Sub_C4C8                 ; $F2EE
  lda z:Tmp00                  ; $F2F1
  sta z:$40                    ; $F2F3
  lda z:Tmp01                  ; $F2F5
  sta z:$41                    ; $F2F7
  rts                          ; $F2F9
Sub_F2FA:
  cpx #$01                     ; $F2FA
  bne Loc_F318                 ; $F2FC
  ldy #$08                     ; $F2FE
  lda JoyHeld1                 ; $F300
  and #$C0                     ; $F303
  bne Loc_F30A                 ; $F305
  jmp Loc_F38F                 ; $F307
Loc_F30A:
  cmp #$80                     ; $F30A
  bne Loc_F313                 ; $F30C
Loc_F30E:
  ldx #$10                     ; $F30E
  jmp Loc_F371                 ; $F310
Loc_F313:
  ldx #$F8                     ; $F313
  jmp Loc_F371                 ; $F315
Loc_F318:
  cpx #$02                     ; $F318
  bne Loc_F333                 ; $F31A
  ldx #$08                     ; $F31C
  lda JoyHeld1                 ; $F31E
  and #$30                     ; $F321
  beq Loc_F38F                 ; $F323
  cmp #$10                     ; $F325
  bne Loc_F32E                 ; $F327
Loc_F329:
  ldy #$F8                     ; $F329
  jmp Loc_F371                 ; $F32B
Loc_F32E:
  ldy #$10                     ; $F32E
  jmp Loc_F371                 ; $F330
Loc_F333:
  lda JoyHeld1                 ; $F333
  and #$F0                     ; $F336
  cmp #$10                     ; $F338
  beq Loc_F329                 ; $F33A
  cmp #$20                     ; $F33C
  beq Loc_F32E                 ; $F33E
  cmp #$80                     ; $F340
  beq Loc_F30E                 ; $F342
  cmp #$40                     ; $F344
  beq Loc_F313                 ; $F346
  cmp #$90                     ; $F348
  bne Loc_F353                 ; $F34A
  ldy #$F8                     ; $F34C
  ldx #$10                     ; $F34E
  jmp Loc_F371                 ; $F350
Loc_F353:
  cmp #$A0                     ; $F353
  bne Loc_F35E                 ; $F355
  ldy #$10                     ; $F357
  ldx #$10                     ; $F359
  jmp Loc_F371                 ; $F35B
Loc_F35E:
  cmp #$50                     ; $F35E
  bne Loc_F369                 ; $F360
  ldy #$F8                     ; $F362
  ldx #$F8                     ; $F364
  jmp Loc_F371                 ; $F366
Loc_F369:
  cmp #$60                     ; $F369
  bne Loc_F38F                 ; $F36B
  ldy #$10                     ; $F36D
  ldx #$F8                     ; $F36F
Loc_F371:
  sta z:$3E                    ; $F371
  tya                          ; $F373
  clc                          ; $F374
  adc $0238                    ; $F375
  sta z:Tmp02                  ; $F378
  txa                          ; $F37A
  clc                          ; $F37B
  adc $023B                    ; $F37C
  sta z:Tmp03                  ; $F37F
  jsr Sub_C4C8                 ; $F381
  lda z:Tmp00                  ; $F384
  sta z:$40                    ; $F386
  lda z:Tmp01                  ; $F388
  sta z:$41                    ; $F38A
  jmp Loc_F393                 ; $F38C
Loc_F38F:
  lda #$00                     ; $F38F
  sta z:$3E                    ; $F391
Loc_F393:
  rts                          ; $F393
Sub_F394:
  jsr Sub_F39E                 ; $F394
  jsr Sub_F430                 ; $F397
  jsr Sub_F470                 ; $F39A
  rts                          ; $F39D
Sub_F39E:
  lda JoyHeld1                 ; $F39E
  and #$10                     ; $F3A1
  beq Loc_F3AF                 ; $F3A3
  lda $0238                    ; $F3A5
  cmp #$12                     ; $F3A8
  bcc Loc_F3AF                 ; $F3AA
  dec $0238                    ; $F3AC
Loc_F3AF:
  lda JoyHeld1                 ; $F3AF
  and #$20                     ; $F3B2
  beq Loc_F3C3                 ; $F3B4
  lda $0238                    ; $F3B6
  cmp #$C8                     ; $F3B9
  bcs Loc_F3C3                 ; $F3BB
  inc $0238                    ; $F3BD
  inc $0238                    ; $F3C0
Loc_F3C3:
  lda z:ScrollPage             ; $F3C3
  cmp #$0F                     ; $F3C5
  bcs Loc_F3F1                 ; $F3C7
  lda JoyHeld1                 ; $F3C9
  and #$40                     ; $F3CC
  beq Loc_F3E0                 ; $F3CE
  lda $023B                    ; $F3D0
  cmp #$18                     ; $F3D3
  bcc Loc_F3F1                 ; $F3D5
  dec $023B                    ; $F3D7
  dec $023B                    ; $F3DA
  jmp Loc_F3F1                 ; $F3DD
Loc_F3E0:
  lda JoyHeld1                 ; $F3E0
  and #$80                     ; $F3E3
  beq Loc_F3F1                 ; $F3E5
  lda $023B                    ; $F3E7
  cmp #$E0                     ; $F3EA
  bcs Loc_F3F1                 ; $F3EC
  inc $023B                    ; $F3EE
Loc_F3F1:
  ldx #$00                     ; $F3F1
  ldy #$3C                     ; $F3F3
Loc_F3F5:
  lda Data_F428,x              ; $F3F5
  clc                          ; $F3F8
  adc $0238                    ; $F3F9
  sta OamBuffer,y              ; $F3FC
  iny                          ; $F3FF
  iny                          ; $F400
  iny                          ; $F401
  inx                          ; $F402
  lda Data_F428,x              ; $F403
  clc                          ; $F406
  adc $023B                    ; $F407
  sta OamBuffer,y              ; $F40A
  iny                          ; $F40D
  inx                          ; $F40E
  cpx #$08                     ; $F40F
  bcc Loc_F3F5                 ; $F411
  lda z:FrameCounter           ; $F413
  and #$02                     ; $F415
  bne Loc_F427                 ; $F417
  lda $0247                    ; $F419
  sec                          ; $F41C
  sbc #$0E                     ; $F41D
  sta $0247                    ; $F41F
  sbc #$08                     ; $F422
  sta $024B                    ; $F424
Loc_F427:
  rts                          ; $F427
Data_F428:
  .incbin "prg_bank_7.bin", $3428, $8  ; $F428
Sub_F430:
  lda JoyHeld1                 ; $F430
  and #$10                     ; $F433
  beq Loc_F43C                 ; $F435
  ldx #$05                     ; $F437
  jmp Loc_F44A                 ; $F439
Loc_F43C:
  lda JoyHeld1                 ; $F43C
  and #$20                     ; $F43F
  beq Loc_F448                 ; $F441
  ldx #$0A                     ; $F443
  jmp Loc_F44A                 ; $F445
Loc_F448:
  ldx #$00                     ; $F448
Loc_F44A:
  ldy #$39                     ; $F44A
Loc_F44C:
  lda Data_F461,x              ; $F44C
  sta OamBuffer,y              ; $F44F
  inx                          ; $F452
  iny                          ; $F453
  lda #$00                     ; $F454
  sta OamBuffer,y              ; $F456
  iny                          ; $F459
  iny                          ; $F45A
  iny                          ; $F45B
  cpy #$4D                     ; $F45C
  bcc Loc_F44C                 ; $F45E
  rts                          ; $F460
Data_F461:
  .incbin "prg_bank_7.bin", $3461, $F  ; $F461
Sub_F470:
  lda z:AmmoLo                 ; $F470
  ora z:AmmoHi                 ; $F472
  beq Loc_F4B7                 ; $F474
  lda JoyNew1                  ; $F476
  and #$01                     ; $F479
  beq Loc_F4B7                 ; $F47B
  jsr GetRandomByte            ; $F47D
  ldx #$4C                     ; $F480
Loc_F482:
  lda OamBuffer,x              ; $F482
  cmp #$E8                     ; $F485
  bcs Loc_F494                 ; $F487
  inx                          ; $F489
  inx                          ; $F48A
  inx                          ; $F48B
  inx                          ; $F48C
  cpx #$5C                     ; $F48D
  bcc Loc_F482                 ; $F48F
  jmp Loc_F4B7                 ; $F491
Loc_F494:
  lda $0238                    ; $F494
  sta OamBuffer,x              ; $F497
  lda #$16                     ; $F49A
  sta $0201,x                  ; $F49C
  lda #$00                     ; $F49F
  sta $0202,x                  ; $F4A1
  lda $023B                    ; $F4A4
  clc                          ; $F4A7
  adc #$08                     ; $F4A8
  sta $0203,x                  ; $F4AA
  lda #$FF                     ; $F4AD
  jsr AdjustAmmo               ; $F4AF
  lda #$0F                     ; $F4B2
  jsr EnqueueByte              ; $F4B4
Loc_F4B7:
  rts                          ; $F4B7
Sub_F4B8:
  lda #$00                     ; $F4B8
  sta z:$30                    ; $F4BA
  sta z:$31                    ; $F4BC
  ldy #$02                     ; $F4BE
  lda ($2C),y                  ; $F4C0
  jsr LsrA4                    ; $F4C2
  sta z:$13                    ; $F4C5
  bne Loc_F4CC                 ; $F4C7
  jmp Loc_F4E4                 ; $F4C9
Loc_F4CC:
  cmp #$01                     ; $F4CC
  bne Loc_F4D3                 ; $F4CE
  jmp Loc_F55A                 ; $F4D0
Loc_F4D3:
  cmp #$02                     ; $F4D3
  bne Loc_F4DA                 ; $F4D5
  jmp Loc_F579                 ; $F4D7
Loc_F4DA:
  cmp #$03                     ; $F4DA
  bne Loc_F4E1                 ; $F4DC
  jmp Loc_F5DB                 ; $F4DE
Loc_F4E1:
  jmp Loc_F5FA                 ; $F4E1
Loc_F4E4:
  lda #$00                     ; $F4E4
  sta z:PlayerSpriteFrame      ; $F4E6
  lda z:$2B                    ; $F4E8
  and #$F0                     ; $F4EA
  sta $0238                    ; $F4EC
  inc $0238                    ; $F4EF
  lda #$02                     ; $F4F2
  sta $0239                    ; $F4F4
  lda #$00                     ; $F4F7
  sta $023A                    ; $F4F9
  lda z:$2B                    ; $F4FC
  jsr AslA4                    ; $F4FE
  ora #$08                     ; $F501
  sta $023B                    ; $F503
  ldx #$00                     ; $F506
Loc_F508:
  lda Data_F53E,x              ; $F508
  cmp #$F0                     ; $F50B
  bne Loc_F515                 ; $F50D
  sta $023C,x                  ; $F50F
  jmp Loc_F532                 ; $F512
Loc_F515:
  clc                          ; $F515
  adc $0238                    ; $F516
  sta $023C,x                  ; $F519
  lda Data_F53F,x              ; $F51C
  sta $023D,x                  ; $F51F
  lda Data_F540,x              ; $F522
  sta $023E,x                  ; $F525
  lda Data_F541,x              ; $F528
  clc                          ; $F52B
  adc $023B                    ; $F52C
  sta $023F,x                  ; $F52F
Loc_F532:
  inx                          ; $F532
  inx                          ; $F533
  inx                          ; $F534
  inx                          ; $F535
  cpx #$1C                     ; $F536
  bcs Loc_F508                 ; $F538
  jsr Sub_F606                 ; $F53A
  rts                          ; $F53D
Data_F53E:
  .incbin "prg_bank_7.bin", $353E, $1  ; $F53E
Data_F53F:
  .incbin "prg_bank_7.bin", $353F, $1  ; $F53F
Data_F540:
  .incbin "prg_bank_7.bin", $3540, $1  ; $F540
Data_F541:
  .incbin "prg_bank_7.bin", $3541, $19  ; $F541
Loc_F55A:
  lda z:$2B                    ; $F55A
  and #$F0                     ; $F55C
  sta $0238                    ; $F55E
  lda z:$2B                    ; $F561
  jsr AslA4                    ; $F563
  sta $023B                    ; $F566
  ldx #$3A                     ; $F569
  lda #$00                     ; $F56B
Loc_F56D:
  sta OamBuffer,x              ; $F56D
  inx                          ; $F570
  inx                          ; $F571
  inx                          ; $F572
  inx                          ; $F573
  cpx #$4E                     ; $F574
  bcc Loc_F56D                 ; $F576
  rts                          ; $F578
Loc_F579:
  lda z:$2B                    ; $F579
  and #$F0                     ; $F57B
  sta $0238                    ; $F57D
  lda #$00                     ; $F580
  sta $0239                    ; $F582
  sta $023A                    ; $F585
  lda z:$2B                    ; $F588
  jsr AslA4                    ; $F58A
  clc                          ; $F58D
  adc #$08                     ; $F58E
  sta $023B                    ; $F590
  ldx #$00                     ; $F593
Loc_F595:
  lda Data_F5CB,x              ; $F595
  cmp #$F0                     ; $F598
  bne Loc_F5A2                 ; $F59A
  sta $023C,x                  ; $F59C
  jmp Loc_F5BF                 ; $F59F
Loc_F5A2:
  clc                          ; $F5A2
  adc $0238                    ; $F5A3
  sta $023C,x                  ; $F5A6
  lda Data_F5CC,x              ; $F5A9
  sta $023D,x                  ; $F5AC
  lda Data_F5CD,x              ; $F5AF
  sta $023E,x                  ; $F5B2
  lda Data_F5CE,x              ; $F5B5
  clc                          ; $F5B8
  adc $023B                    ; $F5B9
  sta $023F,x                  ; $F5BC
Loc_F5BF:
  inx                          ; $F5BF
  inx                          ; $F5C0
  inx                          ; $F5C1
  inx                          ; $F5C2
  cpx #$10                     ; $F5C3
  bcs Loc_F595                 ; $F5C5
  jsr Sub_F606                 ; $F5C7
  rts                          ; $F5CA
Data_F5CB:
  .incbin "prg_bank_7.bin", $35CB, $1  ; $F5CB
Data_F5CC:
  .incbin "prg_bank_7.bin", $35CC, $1  ; $F5CC
Data_F5CD:
  .incbin "prg_bank_7.bin", $35CD, $1  ; $F5CD
Data_F5CE:
  .incbin "prg_bank_7.bin", $35CE, $D  ; $F5CE
Loc_F5DB:
  lda z:$2B                    ; $F5DB
  and #$F0                     ; $F5DD
  sta $0238                    ; $F5DF
  lda z:$2B                    ; $F5E2
  jsr AslA4                    ; $F5E4
  sta $023B                    ; $F5E7
  ldx #$3A                     ; $F5EA
  lda #$00                     ; $F5EC
Loc_F5EE:
  sta OamBuffer,x              ; $F5EE
  inx                          ; $F5F1
  inx                          ; $F5F2
  inx                          ; $F5F3
  inx                          ; $F5F4
  cpx #$5A                     ; $F5F5
  bcc Loc_F5EE                 ; $F5F7
  rts                          ; $F5F9
Loc_F5FA:
  lda #$00                     ; $F5FA
  sta z:$30                    ; $F5FC
  sta z:$31                    ; $F5FE
  sta z:PlayerSpriteFrame      ; $F600
  jsr CopyPlayerSprites        ; $F602
  rts                          ; $F605
Sub_F606:
  lda $023B                    ; $F606
  cmp #$78                     ; $F609
  bne Loc_F612                 ; $F60B
  lda #$00                     ; $F60D
  jmp Loc_F61B                 ; $F60F
Loc_F612:
  bcs Loc_F619                 ; $F612
  lda #$01                     ; $F614
  jmp Loc_F61B                 ; $F616
Loc_F619:
  lda #$02                     ; $F619
Loc_F61B:
  sta z:$32                    ; $F61B
  rts                          ; $F61D
Sub_F61E:
  lda JoyHeld1                 ; $F61E
  pha                          ; $F621
  lda z:FrameCounter           ; $F622
  and #$01                     ; $F624
  clc                          ; $F626
  ror a                        ; $F627
  ror a                        ; $F628
  sta JoyHeld1                 ; $F629
  jsr UploadPaletteIfDirty     ; $F62C
  pla                          ; $F62F
  sta JoyHeld1                 ; $F630
  rts                          ; $F633
Sub_F634:
  ldx #$58                     ; $F634
Loc_F636:
  lda OamBuffer,x              ; $F636
  cmp #$E8                     ; $F639
  bcs Loc_F65B                 ; $F63B
  lda $0202,x                  ; $F63D
  and #$40                     ; $F640
  bne Loc_F649                 ; $F642
  lda #$06                     ; $F644
  jmp Loc_F64B                 ; $F646
Loc_F649:
  lda #$FA                     ; $F649
Loc_F64B:
  clc                          ; $F64B
  adc $0203,x                  ; $F64C
  sta $0203,x                  ; $F64F
  cmp #$F6                     ; $F652
  bcc Loc_F65B                 ; $F654
  lda #$F0                     ; $F656
  sta OamBuffer,x              ; $F658
Loc_F65B:
  inx                          ; $F65B
  inx                          ; $F65C
  inx                          ; $F65D
  inx                          ; $F65E
  cpx #$68                     ; $F65F
  bcc Loc_F636                 ; $F661
  rts                          ; $F663
Sub_F664:
  ldx #$54                     ; $F664
Loc_F666:
  lda OamBuffer,x              ; $F666
  cmp #$E8                     ; $F669
  bcs Loc_F68F                 ; $F66B
  lda $0202,x                  ; $F66D
  and #$40                     ; $F670
  bne Loc_F679                 ; $F672
  lda #$04                     ; $F674
  jmp Loc_F67B                 ; $F676
Loc_F679:
  lda #$FC                     ; $F679
Loc_F67B:
  clc                          ; $F67B
  adc $0203,x                  ; $F67C
  sta $0203,x                  ; $F67F
  cmp #$08                     ; $F682
  bcc Loc_F68A                 ; $F684
  cmp #$F0                     ; $F686
  bcc Loc_F68F                 ; $F688
Loc_F68A:
  lda #$F0                     ; $F68A
  sta OamBuffer,x              ; $F68C
Loc_F68F:
  inx                          ; $F68F
  inx                          ; $F690
  inx                          ; $F691
  inx                          ; $F692
  cpx #$5C                     ; $F693
  bcc Loc_F666                 ; $F695
  rts                          ; $F697
Sub_F698:
  ldx #$4C                     ; $F698
Loc_F69A:
  lda OamBuffer,x              ; $F69A
  cmp #$E8                     ; $F69D
  bcs Loc_F6B3                 ; $F69F
  lda $0203,x                  ; $F6A1
  clc                          ; $F6A4
  adc #$08                     ; $F6A5
  sta $0203,x                  ; $F6A7
  cmp #$F6                     ; $F6AA
  bcc Loc_F6B3                 ; $F6AC
  lda #$F0                     ; $F6AE
  sta OamBuffer,x              ; $F6B0
Loc_F6B3:
  inx                          ; $F6B3
  inx                          ; $F6B4
  inx                          ; $F6B5
  inx                          ; $F6B6
  cpx #$5C                     ; $F6B7
  bcc Loc_F69A                 ; $F6B9
  rts                          ; $F6BB
Sub_F6BC:
  lda z:$3E                    ; $F6BC
  beq Loc_F6EB                 ; $F6BE
  lda PPU_STATUS               ; $F6C0
  lda z:$41                    ; $F6C3
  sta PPU_ADDR                 ; $F6C5
  lda z:$40                    ; $F6C8
  sta PPU_ADDR                 ; $F6CA
  lda PPU_DATA                 ; $F6CD
  lda PPU_DATA                 ; $F6D0
  sta z:$3F                    ; $F6D3
  lda z:$13                    ; $F6D5
  cmp #$02                     ; $F6D7
  bne Loc_F6EB                 ; $F6D9
  lda z:$3F                    ; $F6DB
  cmp #$60                     ; $F6DD
  bcc Loc_F6EB                 ; $F6DF
  lda z:$3E                    ; $F6E1
  eor #$FF                     ; $F6E3
  and JoyHeld1                 ; $F6E5
  sta JoyHeld1                 ; $F6E8
Loc_F6EB:
  rts                          ; $F6EB
Data_F6EC:
  .incbin "prg_bank_7.bin", $36EC, $1  ; $F6EC
Data_F6ED:
  .incbin "prg_bank_7.bin", $36ED, $8D  ; $F6ED
Data_F77A:
  .incbin "prg_bank_7.bin", $377A, $1  ; $F77A
Data_F77B:
  .incbin "prg_bank_7.bin", $377B, $1  ; $F77B
Data_F77C:
  .incbin "prg_bank_7.bin", $377C, $88  ; $F77C
Sub_F804:
  lda $0119                    ; $F804
  beq Loc_F823                 ; $F807
  lda $011C                    ; $F809
  and #$F0                     ; $F80C
  lsr a                        ; $F80E
  lsr a                        ; $F80F
  clc                          ; $F810
  adc $011A                    ; $F811
  sta z:$08                    ; $F814
  lda $011C                    ; $F816
  and #$0F                     ; $F819
  asl a                        ; $F81B
  asl a                        ; $F81C
  clc                          ; $F81D
  adc $011B                    ; $F81E
  sta z:$09                    ; $F821
Loc_F823:
  lda $011E                    ; $F823
  beq Loc_F842                 ; $F826
  lda $0121                    ; $F828
  and #$F0                     ; $F82B
  lsr a                        ; $F82D
  lsr a                        ; $F82E
  clc                          ; $F82F
  adc $011F                    ; $F830
  sta z:$0A                    ; $F833
  lda $0121                    ; $F835
  and #$0F                     ; $F838
  asl a                        ; $F83A
  asl a                        ; $F83B
  clc                          ; $F83C
  adc $0120                    ; $F83D
  sta z:$0B                    ; $F840
Loc_F842:
  lda $0123                    ; $F842
  beq Loc_F861                 ; $F845
  lda $0126                    ; $F847
  and #$F0                     ; $F84A
  lsr a                        ; $F84C
  lsr a                        ; $F84D
  clc                          ; $F84E
  adc $0124                    ; $F84F
  sta z:$0C                    ; $F852
  lda $0126                    ; $F854
  and #$0F                     ; $F857
  asl a                        ; $F859
  asl a                        ; $F85A
  clc                          ; $F85B
  adc $0125                    ; $F85C
  sta z:$0D                    ; $F85F
Loc_F861:
  ldx ObjectCount              ; $F861
  bne Loc_F867                 ; $F864
  rts                          ; $F866
Loc_F867:
  lda #$10                     ; $F867
  sta z:Tmp00                  ; $F869
  lda #$03                     ; $F86B
  sta z:Tmp01                  ; $F86D
Loc_F86F:
  ldy #$00                     ; $F86F
  lda (Tmp00),y                ; $F871
  and #$C0                     ; $F873
  cmp #$C0                     ; $F875
  beq Loc_F87C                 ; $F877
  jmp Loc_F976                 ; $F879
Loc_F87C:
  ldy #$0F                     ; $F87C
  lda (Tmp00),y                ; $F87E
  bne Loc_F885                 ; $F880
  jmp Loc_F976                 ; $F882
Loc_F885:
  ldy #$01                     ; $F885
  lda (Tmp00),y                ; $F887
  sta z:Tmp02                  ; $F889
  iny                          ; $F88B
  lda (Tmp00),y                ; $F88C
  sta z:Tmp03                  ; $F88E
  ldy #$0F                     ; $F890
  lda (Tmp00),y                ; $F892
  and #$F0                     ; $F894
  lsr a                        ; $F896
  lsr a                        ; $F897
  clc                          ; $F898
  adc z:Tmp02                  ; $F899
  sta z:$04                    ; $F89B
  bcc Loc_F8A2                 ; $F89D
  jmp Loc_F976                 ; $F89F
Loc_F8A2:
  lda (Tmp00),y                ; $F8A2
  and #$0F                     ; $F8A4
  asl a                        ; $F8A6
  asl a                        ; $F8A7
  clc                          ; $F8A8
  adc z:Tmp03                  ; $F8A9
  sta z:$05                    ; $F8AB
  bcc Loc_F8B2                 ; $F8AD
  jmp Loc_F976                 ; $F8AF
Loc_F8B2:
  lda $0119                    ; $F8B2
  beq Loc_F8F6                 ; $F8B5
  lda $011A                    ; $F8B7
  cmp #$E0                     ; $F8BA
  bcs Loc_F8F6                 ; $F8BC
  sec                          ; $F8BE
  sbc z:$04                    ; $F8BF
  bcs Loc_F8CD                 ; $F8C1
  lda z:$08                    ; $F8C3
  sec                          ; $F8C5
  sbc z:Tmp02                  ; $F8C6
  bcc Loc_F8F6                 ; $F8C8
  jmp Loc_F8D4                 ; $F8CA
Loc_F8CD:
  lda z:$08                    ; $F8CD
  sec                          ; $F8CF
  sbc z:Tmp02                  ; $F8D0
  bcs Loc_F8F6                 ; $F8D2
Loc_F8D4:
  lda $011B                    ; $F8D4
  sec                          ; $F8D7
  sbc z:$05                    ; $F8D8
  bcs Loc_F8E6                 ; $F8DA
  lda z:$09                    ; $F8DC
  sec                          ; $F8DE
  sbc z:Tmp03                  ; $F8DF
  bcc Loc_F8F6                 ; $F8E1
  jmp Loc_F8ED                 ; $F8E3
Loc_F8E6:
  lda z:$09                    ; $F8E6
  sec                          ; $F8E8
  sbc z:Tmp03                  ; $F8E9
  bcs Loc_F8F6                 ; $F8EB
Loc_F8ED:
  ldy #$04                     ; $F8ED
  lda (Tmp00),y                ; $F8EF
  ora $0119                    ; $F8F1
  sta (Tmp00),y                ; $F8F4
Loc_F8F6:
  lda $011E                    ; $F8F6
  beq Loc_F936                 ; $F8F9
  lda $011F                    ; $F8FB
  sec                          ; $F8FE
  sbc z:$04                    ; $F8FF
  bcs Loc_F90D                 ; $F901
  lda z:$0A                    ; $F903
  sec                          ; $F905
  sbc z:Tmp02                  ; $F906
  bcc Loc_F936                 ; $F908
  jmp Loc_F914                 ; $F90A
Loc_F90D:
  lda z:$0A                    ; $F90D
  sec                          ; $F90F
  sbc z:Tmp02                  ; $F910
  bcs Loc_F936                 ; $F912
Loc_F914:
  lda $0120                    ; $F914
  sec                          ; $F917
  sbc z:$05                    ; $F918
  bcs Loc_F926                 ; $F91A
  lda z:$0B                    ; $F91C
  sec                          ; $F91E
  sbc z:Tmp03                  ; $F91F
  bcc Loc_F936                 ; $F921
  jmp Loc_F92D                 ; $F923
Loc_F926:
  lda z:$0B                    ; $F926
  sec                          ; $F928
  sbc z:Tmp03                  ; $F929
  bcs Loc_F936                 ; $F92B
Loc_F92D:
  ldy #$04                     ; $F92D
  lda (Tmp00),y                ; $F92F
  ora $011E                    ; $F931
  sta (Tmp00),y                ; $F934
Loc_F936:
  lda $0123                    ; $F936
  beq Loc_F976                 ; $F939
  lda $0124                    ; $F93B
  sec                          ; $F93E
  sbc z:$04                    ; $F93F
  bcs Loc_F94D                 ; $F941
  lda z:$0C                    ; $F943
  sec                          ; $F945
  sbc z:Tmp02                  ; $F946
  bcc Loc_F976                 ; $F948
  jmp Loc_F954                 ; $F94A
Loc_F94D:
  lda z:$0C                    ; $F94D
  sec                          ; $F94F
  sbc z:Tmp02                  ; $F950
  bcs Loc_F976                 ; $F952
Loc_F954:
  lda $0125                    ; $F954
  sec                          ; $F957
  sbc z:$05                    ; $F958
  bcs Loc_F966                 ; $F95A
  lda z:$0D                    ; $F95C
  sec                          ; $F95E
  sbc z:Tmp03                  ; $F95F
  bcc Loc_F976                 ; $F961
  jmp Loc_F96D                 ; $F963
Loc_F966:
  lda z:$0D                    ; $F966
  sec                          ; $F968
  sbc z:Tmp03                  ; $F969
  bcs Loc_F976                 ; $F96B
Loc_F96D:
  ldy #$04                     ; $F96D
  lda (Tmp00),y                ; $F96F
  ora $0123                    ; $F971
  sta (Tmp00),y                ; $F974
Loc_F976:
  lda z:Tmp00                  ; $F976
  clc                          ; $F978
  adc #$10                     ; $F979
  sta z:Tmp00                  ; $F97B
  dex                          ; $F97D
  beq Loc_F983                 ; $F97E
  jmp Loc_F86F                 ; $F980
Loc_F983:
  rts                          ; $F983
Sub_F984:
  lda $0114                    ; $F984
  beq Loc_F98A                 ; $F987
  rts                          ; $F989
Loc_F98A:
  lda #$10                     ; $F98A
  sta z:Tmp00                  ; $F98C
  lda #$03                     ; $F98E
  sta z:Tmp01                  ; $F990
  ldx ObjectCount              ; $F992
  bne Loc_F998                 ; $F995
  rts                          ; $F997
Loc_F998:
  ldy #$04                     ; $F998
  lda (Tmp00),y                ; $F99A
  and #$80                     ; $F99C
  beq Loc_F9F2                 ; $F99E
  ldy #$00                     ; $F9A0
  lda (Tmp00),y                ; $F9A2
  and #$3F                     ; $F9A4
  beq Loc_F9F1                 ; $F9A6
  cmp #$27                     ; $F9A8
  bne Loc_F9B4                 ; $F9AA
  lda z:FireMode               ; $F9AC
  and #$0F                     ; $F9AE
  cmp #$03                     ; $F9B0
  bcc Loc_FA05                 ; $F9B2
Loc_F9B4:
  lda #$43                     ; $F9B4
  jsr EnqueueByte              ; $F9B6
  lda #$10                     ; $F9B9
  sta $0114                    ; $F9BB
  ldy #$00                     ; $F9BE
  lda (Tmp00),y                ; $F9C0
  and #$3F                     ; $F9C2
  tay                          ; $F9C4
  lda z:PlayerLifeLo           ; $F9C5
  sec                          ; $F9C7
  sbc Data_FA1D,y              ; $F9C8
  bcs Loc_F9CF                 ; $F9CB
  lda #$00                     ; $F9CD
Loc_F9CF:
  sta z:PlayerLifeLo           ; $F9CF
  ldy #$00                     ; $F9D1
  lda (Tmp00),y                ; $F9D3
  and #$3F                     ; $F9D5
  cmp #$09                     ; $F9D7
  beq Loc_F9EB                 ; $F9D9
  cmp #$16                     ; $F9DB
  beq Loc_F9EB                 ; $F9DD
  cmp #$18                     ; $F9DF
  beq Loc_F9EB                 ; $F9E1
  cmp #$22                     ; $F9E3
  beq Loc_F9EB                 ; $F9E5
  cmp #$25                     ; $F9E7
  bne Loc_F9F1                 ; $F9E9
Loc_F9EB:
  ldy #$06                     ; $F9EB
  lda #$00                     ; $F9ED
  sta (Tmp00),y                ; $F9EF
Loc_F9F1:
  rts                          ; $F9F1
Loc_F9F2:
  ldy #$04                     ; $F9F2
  lda (Tmp00),y                ; $F9F4
  and #$7F                     ; $F9F6
  sta (Tmp00),y                ; $F9F8
  lda z:Tmp00                  ; $F9FA
  clc                          ; $F9FC
  adc #$10                     ; $F9FD
  sta z:Tmp00                  ; $F9FF
  dex                          ; $FA01
  bne Loc_F998                 ; $FA02
  rts                          ; $FA04
Loc_FA05:
  lda #$07                     ; $FA05
  sta z:FireMode               ; $FA07
  lda #$00                     ; $FA09
  sta z:$34                    ; $FA0B
  lda #$C8                     ; $FA0D
  sta z:PlayerLifeLo           ; $FA0F
  ldy #$0B                     ; $FA11
  lda #$F0                     ; $FA13
  sta (Tmp00),y                ; $FA15
  lda #$01                     ; $FA17
  sta $0138                    ; $FA19
  rts                          ; $FA1C
Data_FA1D:
  .incbin "prg_bank_7.bin", $3A1D, $2A  ; $FA1D
Sub_FA47:
  lda $0115                    ; $FA47
  beq Loc_FA50                 ; $FA4A
  dec $0115                    ; $FA4C
  rts                          ; $FA4F
Loc_FA50:
  lda #$10                     ; $FA50
  sta z:Tmp00                  ; $FA52
  lda #$03                     ; $FA54
  sta z:Tmp01                  ; $FA56
  ldx ObjectCount              ; $FA58
  bne Loc_FA5E                 ; $FA5B
  rts                          ; $FA5D
Loc_FA5E:
  ldy #$04                     ; $FA5E
  lda (Tmp00),y                ; $FA60
  and #$40                     ; $FA62
  beq Loc_FA7B                 ; $FA64
  lda #$40                     ; $FA66
  sta $0115                    ; $FA68
  lda #$0D                     ; $FA6B
  jsr EnqueueByte              ; $FA6D
  ldy #$06                     ; $FA70
  lda (Tmp00),y                ; $FA72
  beq Loc_FA7B                 ; $FA74
  sec                          ; $FA76
  sbc #$01                     ; $FA77
  sta (Tmp00),y                ; $FA79
Loc_FA7B:
  ldy #$04                     ; $FA7B
  lda (Tmp00),y                ; $FA7D
  and #$3F                     ; $FA7F
  sta (Tmp00),y                ; $FA81
  lda z:Tmp00                  ; $FA83
  clc                          ; $FA85
  adc #$10                     ; $FA86
  sta z:Tmp00                  ; $FA88
  dex                          ; $FA8A
  bne Loc_FA5E                 ; $FA8B
  rts                          ; $FA8D
TickObjectStates:
  lda #$10                     ; $FA8E
  sta z:Tmp00                  ; $FA90
  lda #$03                     ; $FA92
  sta z:Tmp01                  ; $FA94
  ldx ObjectCount              ; $FA96
  beq Loc_FAFF                 ; $FA99
Loc_FA9B:
  ldy #$06                     ; $FA9B
  lda (Tmp00),y                ; $FA9D
  and #$F0                     ; $FA9F
  beq Loc_FAAD                 ; $FAA1
  lda (Tmp00),y                ; $FAA3
  sec                          ; $FAA5
  sbc #$10                     ; $FAA6
  sta (Tmp00),y                ; $FAA8
  jmp Loc_FAED                 ; $FAAA
Loc_FAAD:
  ldy #$04                     ; $FAAD
  lda (Tmp00),y                ; $FAAF
  and #$60                     ; $FAB1
  beq Loc_FAED                 ; $FAB3
  ldy #$06                     ; $FAB5
  lda (Tmp00),y                ; $FAB7
  and #$0F                     ; $FAB9
  beq Loc_FAED                 ; $FABB
  cmp #$0F                     ; $FABD
  beq Loc_FAED                 ; $FABF
  lda (Tmp00),y                ; $FAC1
  sec                          ; $FAC3
  sbc #$01                     ; $FAC4
  ora #$F0                     ; $FAC6
  sta (Tmp00),y                ; $FAC8
  ldy #$04                     ; $FACA
  lda (Tmp00),y                ; $FACC
  and #$60                     ; $FACE
  cmp #$40                     ; $FAD0
  bne Loc_FADA                 ; $FAD2
  ldx $0122                    ; $FAD4
  jmp Loc_FAE8                 ; $FAD7
Loc_FADA:
  ldx $0127                    ; $FADA
  cpx #$40                     ; $FADD
  bcc Loc_FAE8                 ; $FADF
  ldx #$5C                     ; $FAE1
  lda #$F0                     ; $FAE3
  sta $0204,x                  ; $FAE5
Loc_FAE8:
  lda #$F0                     ; $FAE8
  sta OamBuffer,x              ; $FAEA
Loc_FAED:
  ldy #$04                     ; $FAED
  lda (Tmp00),y                ; $FAEF
  and #$1F                     ; $FAF1
  sta (Tmp00),y                ; $FAF3
  lda z:Tmp00                  ; $FAF5
  clc                          ; $FAF7
  adc #$10                     ; $FAF8
  sta z:Tmp00                  ; $FAFA
  dex                          ; $FAFC
  bne Loc_FA9B                 ; $FAFD
Loc_FAFF:
  rts                          ; $FAFF
Sub_FB00:
  lda $0114                    ; $FB00
  beq Loc_FB13                 ; $FB03
  lda z:FrameCounter           ; $FB05
  and #$01                     ; $FB07
  bne Loc_FB0E                 ; $FB09
  dec $0114                    ; $FB0B
Loc_FB0E:
  lda #$00                     ; $FB0E
  jmp Loc_FB3A                 ; $FB10
Loc_FB13:
  lda z:FireMode               ; $FB13
  and #$0F                     ; $FB15
  cmp #$02                     ; $FB17
  beq Loc_FB22                 ; $FB19
  lda #$08                     ; $FB1B
  ldx #$81                     ; $FB1D
  jmp Loc_FB26                 ; $FB1F
Loc_FB22:
  lda #$12                     ; $FB22
  ldx #$61                     ; $FB24
Loc_FB26:
  adc $0238                    ; $FB26
  sta $011A                    ; $FB29
  lda $023B                    ; $FB2C
  clc                          ; $FB2F
  adc #$06                     ; $FB30
  sta $011B                    ; $FB32
  stx $011C                    ; $FB35
  lda #$80                     ; $FB38
Loc_FB3A:
  sta $0119                    ; $FB3A
  lda $0115                    ; $FB3D
  beq Loc_FB48                 ; $FB40
  dec $0115                    ; $FB42
  jmp Loc_FB7F                 ; $FB45
Loc_FB48:
  lda z:FireMode               ; $FB48
  and #$0F                     ; $FB4A
  cmp #$04                     ; $FB4C
  bne Loc_FB7A                 ; $FB4E
  lda z:$34                    ; $FB50
  cmp #$02                     ; $FB52
  bne Loc_FB7A                 ; $FB54
  lda $0238                    ; $FB56
  adc #$10                     ; $FB59
  sta $011F                    ; $FB5B
  ldx #$0E                     ; $FB5E
  lda z:FireMode               ; $FB60
  and #$10                     ; $FB62
  beq Loc_FB68                 ; $FB64
  ldx #$EE                     ; $FB66
Loc_FB68:
  txa                          ; $FB68
  clc                          ; $FB69
  adc $023B                    ; $FB6A
  sta $0120                    ; $FB6D
  lda #$35                     ; $FB70
  sta $0121                    ; $FB72
  lda #$40                     ; $FB75
  jmp Loc_FB7C                 ; $FB77
Loc_FB7A:
  lda #$00                     ; $FB7A
Loc_FB7C:
  sta $011E                    ; $FB7C
Loc_FB7F:
  jsr ClearObjectStatusBits    ; $FB7F
  jsr Sub_F804                 ; $FB82
  jsr Sub_F984                 ; $FB85
  jsr Sub_FA47                 ; $FB88
  lda $0258                    ; $FB8B
  cmp #$E8                     ; $FB8E
  bcc Loc_FB97                 ; $FB90
  lda #$00                     ; $FB92
  jmp Loc_FBAC                 ; $FB94
Loc_FB97:
  sta $011F                    ; $FB97
  lda $025B                    ; $FB9A
  sta $0120                    ; $FB9D
  lda #$12                     ; $FBA0
  sta $0121                    ; $FBA2
  lda #$58                     ; $FBA5
  sta $0122                    ; $FBA7
  lda #$40                     ; $FBAA
Loc_FBAC:
  sta $011E                    ; $FBAC
  lda $025C                    ; $FBAF
  cmp #$E8                     ; $FBB2
  bcc Loc_FBBB                 ; $FBB4
  lda #$00                     ; $FBB6
  jmp Loc_FBD0                 ; $FBB8
Loc_FBBB:
  sta $0124                    ; $FBBB
  lda $025F                    ; $FBBE
  sta $0125                    ; $FBC1
  lda #$12                     ; $FBC4
  sta $0126                    ; $FBC6
  lda #$5C                     ; $FBC9
  sta $0127                    ; $FBCB
  lda #$20                     ; $FBCE
Loc_FBD0:
  sta $0123                    ; $FBD0
  jsr ClearObjectStatusBits    ; $FBD3
  jsr Sub_F804                 ; $FBD6
  jsr TickObjectStates         ; $FBD9
  jsr UpdateLifeBlink          ; $FBDC
  rts                          ; $FBDF
ClearObjectStatusBits:
  ldx ObjectCount              ; $FBE0
  beq Loc_FBFD                 ; $FBE3
  lda #$10                     ; $FBE5
  sta z:Tmp00                  ; $FBE7
  lda #$03                     ; $FBE9
  sta z:Tmp01                  ; $FBEB
  ldy #$04                     ; $FBED
Loc_FBEF:
  lda (Tmp00),y                ; $FBEF
  and #$1F                     ; $FBF1
  sta (Tmp00),y                ; $FBF3
  tya                          ; $FBF5
  clc                          ; $FBF6
  adc #$10                     ; $FBF7
  tay                          ; $FBF9
  dex                          ; $FBFA
  bne Loc_FBEF                 ; $FBFB
Loc_FBFD:
  rts                          ; $FBFD
UpdateLifeBlink:
  lda $0114                    ; $FBFE
  bne Loc_FC09                 ; $FC01
  lda $0116                    ; $FC03
  jmp Loc_FC16                 ; $FC06
Loc_FC09:
  lda z:FrameCounter           ; $FC09
  and #$02                     ; $FC0B
  bne Loc_FC14                 ; $FC0D
  lda #$16                     ; $FC0F
  jmp Loc_FC16                 ; $FC11
Loc_FC14:
  lda z:PlayerLifeLo           ; $FC14
Loc_FC16:
  sta $0153                    ; $FC16
  rts                          ; $FC19
Sub_FC1A:
  lda $0114                    ; $FC1A
  beq Loc_FC2D                 ; $FC1D
  lda z:FrameCounter           ; $FC1F
  and #$01                     ; $FC21
  bne Loc_FC28                 ; $FC23
  dec $0114                    ; $FC25
Loc_FC28:
  lda #$00                     ; $FC28
  jmp Loc_FC40                 ; $FC2A
Loc_FC2D:
  lda $0238                    ; $FC2D
  sta $011A                    ; $FC30
  lda $023B                    ; $FC33
  sta $011B                    ; $FC36
  lda #$44                     ; $FC39
  sta $011C                    ; $FC3B
  lda #$80                     ; $FC3E
Loc_FC40:
  sta $0119                    ; $FC40
  lda z:FrameCounter           ; $FC43
  and #$01                     ; $FC45
  bne Loc_FC4F                 ; $FC47
  jsr Sub_FC62                 ; $FC49
  jmp Loc_FC52                 ; $FC4C
Loc_FC4F:
  jsr Sub_FCBD                 ; $FC4F
Loc_FC52:
  jsr ClearObjectStatusBits    ; $FC52
  jsr Sub_F804                 ; $FC55
  jsr Sub_F984                 ; $FC58
  jsr TickObjectStates         ; $FC5B
  jsr UpdateLifeBlink          ; $FC5E
  rts                          ; $FC61
Sub_FC62:
  lda $024C                    ; $FC62
  cmp #$E8                     ; $FC65
  bcc Loc_FC6E                 ; $FC67
  lda #$00                     ; $FC69
  jmp Loc_FC8C                 ; $FC6B
Loc_FC6E:
  sta $011F                    ; $FC6E
  lda $024F                    ; $FC71
  sta $0120                    ; $FC74
  cmp #$E0                     ; $FC77
  bcc Loc_FC80                 ; $FC79
  lda #$00                     ; $FC7B
  jmp Loc_FC8C                 ; $FC7D
Loc_FC80:
  lda #$14                     ; $FC80
  sta $0121                    ; $FC82
  lda #$4C                     ; $FC85
  sta $0122                    ; $FC87
  lda #$40                     ; $FC8A
Loc_FC8C:
  sta $011E                    ; $FC8C
  lda $0250                    ; $FC8F
  cmp #$E8                     ; $FC92
  bcc Loc_FC9B                 ; $FC94
  lda #$00                     ; $FC96
  jmp Loc_FCB9                 ; $FC98
Loc_FC9B:
  sta $0124                    ; $FC9B
  lda $0253                    ; $FC9E
  sta $0125                    ; $FCA1
  cmp #$E0                     ; $FCA4
  bcc Loc_FCAD                 ; $FCA6
  lda #$00                     ; $FCA8
  jmp Loc_FCB9                 ; $FCAA
Loc_FCAD:
  lda #$14                     ; $FCAD
  sta $0126                    ; $FCAF
  lda #$50                     ; $FCB2
  sta $0127                    ; $FCB4
  lda #$20                     ; $FCB7
Loc_FCB9:
  sta $0123                    ; $FCB9
  rts                          ; $FCBC
Sub_FCBD:
  lda $0254                    ; $FCBD
  cmp #$E8                     ; $FCC0
  bcc Loc_FCC9                 ; $FCC2
  lda #$00                     ; $FCC4
  jmp Loc_FCE7                 ; $FCC6
Loc_FCC9:
  sta $011F                    ; $FCC9
  lda $0257                    ; $FCCC
  sta $0120                    ; $FCCF
  cmp #$E0                     ; $FCD2
  bcc Loc_FCDB                 ; $FCD4
  lda #$00                     ; $FCD6
  jmp Loc_FCE7                 ; $FCD8
Loc_FCDB:
  lda #$14                     ; $FCDB
  sta $0121                    ; $FCDD
  lda #$54                     ; $FCE0
  sta $0122                    ; $FCE2
  lda #$40                     ; $FCE5
Loc_FCE7:
  sta $011E                    ; $FCE7
  lda $0258                    ; $FCEA
  cmp #$E8                     ; $FCED
  bcc Loc_FCF6                 ; $FCEF
  lda #$00                     ; $FCF1
  jmp Loc_FD14                 ; $FCF3
Loc_FCF6:
  sta $0124                    ; $FCF6
  lda $025B                    ; $FCF9
  sta $0125                    ; $FCFC
  cmp #$E0                     ; $FCFF
  bcc Loc_FD08                 ; $FD01
  lda #$00                     ; $FD03
  jmp Loc_FD14                 ; $FD05
Loc_FD08:
  lda #$14                     ; $FD08
  sta $0126                    ; $FD0A
  lda #$58                     ; $FD0D
  sta $0127                    ; $FD0F
  lda #$20                     ; $FD12
Loc_FD14:
  sta $0123                    ; $FD14
  rts                          ; $FD17
Sub_FD18:
  lda $0114                    ; $FD18
  beq Loc_FD2B                 ; $FD1B
  lda z:FrameCounter           ; $FD1D
  and #$01                     ; $FD1F
  bne Loc_FD26                 ; $FD21
  dec $0114                    ; $FD23
Loc_FD26:
  lda #$00                     ; $FD26
  jmp Loc_FD4B                 ; $FD28
Loc_FD2B:
  lda $0238                    ; $FD2B
  sta $011A                    ; $FD2E
  lda $023B                    ; $FD31
  sta $011B                    ; $FD34
  lda z:FireMode               ; $FD37
  and #$0F                     ; $FD39
  cmp #$01                     ; $FD3B
  bne Loc_FD44                 ; $FD3D
  lda #$44                     ; $FD3F
  jmp Loc_FD46                 ; $FD41
Loc_FD44:
  lda #$63                     ; $FD44
Loc_FD46:
  sta $011C                    ; $FD46
  lda #$80                     ; $FD49
Loc_FD4B:
  sta $0119                    ; $FD4B
  jsr Sub_FCBD                 ; $FD4E
  jsr ClearObjectStatusBits    ; $FD51
  jsr Sub_F804                 ; $FD54
  jsr Sub_F984                 ; $FD57
  jsr TickObjectStates         ; $FD5A
  jsr UpdateLifeBlink          ; $FD5D
  rts                          ; $FD60
Sub_FD61:
  lda #$1F                     ; $FD61
  sta z:MmcChr0Shadow          ; $FD63
  jsr MmcWriteChr0             ; $FD65
  lda $0106                    ; $FD68
  beq Loc_FD7B                 ; $FD6B
  cmp #$01                     ; $FD6D
  beq Loc_FDAA                 ; $FD6F
  cmp #$03                     ; $FD71
  bcc Loc_FD78                 ; $FD73
  jmp Loc_FE68                 ; $FD75
Loc_FD78:
  jmp Loc_FE38                 ; $FD78
Loc_FD7B:
  sta $0107                    ; $FD7B
  lda $012A                    ; $FD7E
  cmp #$03                     ; $FD81
  bne Loc_FD95                 ; $FD83
  lda JoyHeld1                 ; $FD85
  and #$FB                     ; $FD88
  cmp #$1B                     ; $FD8A
  bne Loc_FD95                 ; $FD8C
  lda JoyHeld2                 ; $FD8E
  cmp #$53                     ; $FD91
  beq Loc_FD9D                 ; $FD93
Loc_FD95:
  lda #$03                     ; $FD95
  sta $0106                    ; $FD97
  jmp Loc_FE68                 ; $FD9A
Loc_FD9D:
  inc $0106                    ; $FD9D
  lda #$0F                     ; $FDA0
  sta z:MmcChr0Shadow          ; $FDA2
  jsr MmcWriteChr0             ; $FDA4
  jmp Loc_FE68                 ; $FDA7
Loc_FDAA:
  lda #$10                     ; $FDAA
  jsr SetPpuMask               ; $FDAC
  lda #$B0                     ; $FDAF
  jsr SetPpuCtrl               ; $FDB1
  lda PPU_STATUS               ; $FDB4
  lda #$3F                     ; $FDB7
  sta PPU_ADDR                 ; $FDB9
  ldx #$10                     ; $FDBC
  stx PPU_ADDR                 ; $FDBE
Loc_FDC1:
  lda Data_FE5C,x              ; $FDC1
  sta PPU_DATA                 ; $FDC4
  inx                          ; $FDC7
  cpx #$20                     ; $FDC8
  bcc Loc_FDC1                 ; $FDCA
  jsr ResetPpuAddr             ; $FDCC
  jsr ApplyScroll              ; $FDCF
  lda z:FrameCounter           ; $FDD2
  and #$07                     ; $FDD4
  bne Loc_FDF1                 ; $FDD6
  lda JoyHeld1                 ; $FDD8
  and #$30                     ; $FDDB
  beq Loc_FDF1                 ; $FDDD
  cmp #$10                     ; $FDDF
  bne Loc_FDE9                 ; $FDE1
  jsr Sub_FEA7                 ; $FDE3
  jmp Loc_FDF1                 ; $FDE6
Loc_FDE9:
  lda $0107                    ; $FDE9
  beq Loc_FDF1                 ; $FDEC
  jsr Sub_FEC1                 ; $FDEE
Loc_FDF1:
  lda $0107                    ; $FDF1
  and #$0F                     ; $FDF4
  tax                          ; $FDF6
  lda Data_FE7C,x              ; $FDF7
  sta $02D9                    ; $FDFA
  lda $0107                    ; $FDFD
  jsr LsrA4                    ; $FE00
  tax                          ; $FE03
  lda Data_FE7C,x              ; $FE04
  sta $02DD                    ; $FE07
  lda #$70                     ; $FE0A
  sta $02D8                    ; $FE0C
  sta $02DC                    ; $FE0F
  lda #$00                     ; $FE12
  sta $02DA                    ; $FE14
  sta $02DE                    ; $FE17
  lda #$80                     ; $FE1A
  sta $02DB                    ; $FE1C
  lda #$78                     ; $FE1F
  sta $02DF                    ; $FE21
  lda JoyNew1                  ; $FE24
  and #$01                     ; $FE27
  beq Loc_FE68                 ; $FE29
  inc $0106                    ; $FE2B
  lda #$00                     ; $FE2E
  sta z:MmcChr0Shadow          ; $FE30
  jsr MmcWriteChr0             ; $FE32
  jmp Loc_FE68                 ; $FE35
Loc_FE38:
  lda $0107                    ; $FE38
  sta z:$29                    ; $FE3B
  bne Loc_FE44                 ; $FE3D
  lda #$00                     ; $FE3F
  jmp Loc_FE46                 ; $FE41
Loc_FE44:
  lda #$32                     ; $FE44
Loc_FE46:
  sta z:AmmoLo                 ; $FE46
  ldx #$00                     ; $FE48
Loc_FE4A:
  lda Data_FE8C,x              ; $FE4A
  cmp #$FF                     ; $FE4D
  beq Loc_FE61                 ; $FE4F
  cmp $0107                    ; $FE51
  beq Loc_FE5B                 ; $FE54
  inx                          ; $FE56
  inx                          ; $FE57
  jmp Loc_FE4A                 ; $FE58
Loc_FE5B:
  lda Data_FE8D,x              ; $FE5B
  sta $0100                    ; $FE5E
Loc_FE61:
  lda #$77                     ; $FE61
  sta z:$2B                    ; $FE63
  inc $0106                    ; $FE65
Loc_FE68:
  jsr ReadJoypads              ; $FE68
  rts                          ; $FE6B
  .incbin "prg_bank_7.bin", $3E6C, $10  ; $FE6C
Data_FE7C:
  .incbin "prg_bank_7.bin", $3E7C, $E  ; $FE7C
Data_FE8A:
  .incbin "prg_bank_7.bin", $3E8A, $2  ; $FE8A
Data_FE8C:
  .incbin "prg_bank_7.bin", $3E8C, $1  ; $FE8C
Data_FE8D:
  .incbin "prg_bank_7.bin", $3E8D, $1  ; $FE8D
Data_FE8E:
  .incbin "prg_bank_7.bin", $3E8E, $19  ; $FE8E
Sub_FEA7:
  ldx #$00                     ; $FEA7
Loc_FEA9:
  lda Data_FE8C,x              ; $FEA9
  cmp $0107                    ; $FEAC
  beq Loc_FEB6                 ; $FEAF
  inx                          ; $FEB1
  inx                          ; $FEB2
  jmp Loc_FEA9                 ; $FEB3
Loc_FEB6:
  lda Data_FE8E,x              ; $FEB6
  cmp #$FF                     ; $FEB9
  beq Loc_FEC0                 ; $FEBB
Loc_FEBD:
  sta $0107                    ; $FEBD
Loc_FEC0:
  rts                          ; $FEC0
Sub_FEC1:
  ldx #$00                     ; $FEC1
Loc_FEC3:
  lda Data_FE8C,x              ; $FEC3
  cmp $0107                    ; $FEC6
  beq Loc_FED0                 ; $FEC9
  inx                          ; $FECB
  inx                          ; $FECC
  jmp Loc_FEC3                 ; $FECD
Loc_FED0:
  cpx #$00                     ; $FED0
  beq Loc_FEC0                 ; $FED2
  lda Data_FE8A,x              ; $FED4
  jmp Loc_FEBD                 ; $FED7
  .incbin "prg_bank_7.bin", $3EDA, $120  ; $FEDA

.segment "PRG_BANK_7"
; hardware vectors
  .addr Nmi, Reset, Nmi
