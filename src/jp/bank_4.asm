; Bank 4  ($8000-$BFFF switchable)
; First-person building scenes: 3-D corridor view with doors and a compass (18 mazes selected by MazeIndex = TransitionTarget - $78), enemies, ammo and life items; per-frame scene code at $8010.
.segment "PRG_BANK_4"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B4_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_4.bin", $0009, $7  ; $8009
Bank4Nmi:
  lda PPU_STATUS               ; $8010
  lda z:PpuCtrlShadow          ; $8013
  and #$7B                     ; $8015
  jsr SetPpuCtrl               ; $8017
  lda #$00                     ; $801A
  sta PPU_MASK                 ; $801C
  lda PPU_STATUS               ; $801F
  jsr DoOamDma                 ; $8022
  lda PPU_STATUS               ; $8025
  jsr Sub_B4_905D              ; $8028
  lda z:PpuMaskShadow          ; $802B
  sta PPU_MASK                 ; $802D
  jsr ApplyScroll              ; $8030
  jsr Sub_B4_80B3              ; $8033
  jsr Sub_B4_8C07              ; $8036
  inc z:FrameCounter           ; $8039
  jsr DrawHud                  ; $803B
  jsr Sub_B4_90F1              ; $803E
  lda z:MmcPrgShadow           ; $8041
  pha                          ; $8043
  lda #$04                     ; $8044
  sta z:MmcPrgShadow           ; $8046
  jsr RunSoundDriver           ; $8048
  lda PPU_STATUS               ; $804B
  pla                          ; $804E
  sta z:MmcPrgShadow           ; $804F
  lda z:PpuMaskShadow          ; $8051
  and #$18                     ; $8053
  cmp #$18                     ; $8055
  bne Loc_B4_8098              ; $8057
  lda z:$80                    ; $8059
  ldx #$00                     ; $805B
  ldy #$20                     ; $805D
Loc_B4_805F:
  bit PPU_STATUS               ; $805F
  bvs Loc_B4_805F              ; $8062
Loc_B4_8064:
  bit PPU_STATUS               ; $8064
  bvc Loc_B4_8064              ; $8067
  stx PPU_SCROLL               ; $8069
  ldx PPU_STATUS               ; $806C
  sta PPU_ADDR                 ; $806F
  sty PPU_ADDR                 ; $8072
  ldx #$04                     ; $8075
  ldy #$5A                     ; $8077
Loc_B4_8079:
  dey                          ; $8079
  bne Loc_B4_8079              ; $807A
  dex                          ; $807C
  bne Loc_B4_8079              ; $807D
  ldx PPU_STATUS               ; $807F
  sta PPU_ADDR                 ; $8082
  ldy #$A0                     ; $8085
  sty PPU_ADDR                 ; $8087
  ldx #$5A                     ; $808A
Loc_B4_808C:
  dex                          ; $808C
  bne Loc_B4_808C              ; $808D
  ldx PPU_STATUS               ; $808F
  sta PPU_ADDR                 ; $8092
  sty PPU_ADDR                 ; $8095
Loc_B4_8098:
  lda PPU_STATUS               ; $8098
  lda z:PpuCtrlShadow          ; $809B
  ora #$80                     ; $809D
  jsr SetPpuCtrl               ; $809F
  rti                          ; $80A2
  .incbin "prg_bank_4.bin", $00A3, $10  ; $80A3
Sub_B4_80B3:
  lda SceneState               ; $80B3
  cmp #$21                     ; $80B6
Loc_B4_80B8:
  bcs Loc_B4_80B8              ; $80B8
  asl a                        ; $80BA
  tax                          ; $80BB
  lda Data_B4_80C9,x           ; $80BC
  sta z:$6D                    ; $80BF
  lda Data_B4_80CA,x           ; $80C1
  sta z:$6E                    ; $80C4
  jmp ($006D)                  ; $80C6
Data_B4_80C9:
  .addr Bank4Tbl80C9_00, Bank4Tbl80C9_01, Bank4Tbl80C9_02, Bank4Tbl80C9_03, Bank4Tbl80C9_04, Bank4Tbl80C9_05, Bank4Tbl80C9_06, Bank4Tbl80C9_07, Bank4Tbl80C9_08, Bank4Tbl80C9_09, Bank4Tbl80C9_0A, Bank4Tbl80C9_0B, Bank4Tbl80C9_0C, Bank4Tbl80C9_0D, Bank4Tbl80C9_0E, Bank4Tbl80C9_0F, Bank4Tbl80C9_10, Bank4Tbl80C9_11, Bank4Tbl80C9_12, Bank4Tbl80C9_13, Bank4Tbl80C9_14, Bank4Tbl80C9_15, Bank4Tbl80C9_16, Bank4Tbl80C9_17, Bank4Tbl80C9_18, Bank4Tbl80C9_19, Bank4Tbl80C9_1A, Bank4Tbl80C9_1B, Bank4Tbl80C9_1C, Bank4Tbl80C9_1D, Bank4Tbl80C9_1E, Bank4Tbl80C9_1F, Bank4Tbl80C9_20  ; $80C9 pointer table
Bank4Tbl80C9_00:
  lda #$00                     ; $810B
  sta $050A                    ; $810D
  sta $050B                    ; $8110
  sta $050C                    ; $8113
Bank4Tbl80C9_03:
  lda #$04                     ; $8116
  sta SceneState               ; $8118
  jsr Sub_B4_84FD              ; $811B
  jmp Loc_B4_849E              ; $811E
Bank4Tbl80C9_01:
  lda #$1C                     ; $8121
  sta SceneState               ; $8123
  jsr Sub_B4_8507              ; $8126
  jmp Loc_B4_849E              ; $8129
Bank4Tbl80C9_02:
  lda #$1E                     ; $812C
  sta SceneState               ; $812E
  jsr Sub_B4_8507              ; $8131
  jmp Loc_B4_849E              ; $8134
Bank4Tbl80C9_04:
  inc SceneState               ; $8137
  jmp Sub_B4_90D6              ; $813A
Bank4Tbl80C9_05:
  inc SceneState               ; $813D
  jsr FillPaletteBlack         ; $8140
  jsr Sub_B4_8476              ; $8143
  lda #$03                     ; $8146
  sta $051F                    ; $8148
  jsr Sub_B4_90B6              ; $814B
  jsr Sub_B4_9173              ; $814E
  jsr Sub_B4_854E              ; $8151
  jsr Sub_B4_9880              ; $8154
  jsr Sub_B4_997B              ; $8157
  jsr Sub_B4_9FAC              ; $815A
  jsr Sub_B4_A033              ; $815D
  jsr Sub_B4_A0F1              ; $8160
  jsr Sub_B4_901A              ; $8163
  jmp ApplyScroll              ; $8166
Bank4Tbl80C9_06:
  inc SceneState               ; $8169
  jsr Sub_B4_B4B1              ; $816C
  jsr Sub_B4_B4B1              ; $816F
  jsr DrawObjects              ; $8172
  jsr Sub_B4_905D              ; $8175
  jmp ApplyScroll              ; $8178
Bank4Tbl80C9_07:
  inc SceneState               ; $817B
  jsr Sub_B4_95DA              ; $817E
  lda #$00                     ; $8181
  sta z:$7C                    ; $8183
  lda #$11                     ; $8185
  sta z:$8A                    ; $8187
  jmp Loc_B4_90CF              ; $8189
Bank4Tbl80C9_08:
  lda PPU_STATUS               ; $818C
  jsr ReadJoypads              ; $818F
  jsr Sub_B4_8D35              ; $8192
  jsr Sub_B4_B4B1              ; $8195
  jsr DrawObjects              ; $8198
  jsr Sub_B4_961B              ; $819B
  ldx z:$7C                    ; $819E
  lda Data_B4_81BC,x           ; $81A0
  sta SceneState               ; $81A3
  lda z:PlayerLifeHi           ; $81A6
  bne Loc_B4_81B0              ; $81A8
  lda z:PlayerLifeLo           ; $81AA
  cmp #$C9                     ; $81AC
  bcc Loc_B4_81BB              ; $81AE
Loc_B4_81B0:
  lda #$00                     ; $81B0
  sta z:PlayerLifeLo           ; $81B2
  sta z:PlayerLifeHi           ; $81B4
  lda #$1F                     ; $81B6
  sta SceneState               ; $81B8
Loc_B4_81BB:
  rts                          ; $81BB
Data_B4_81BC:
  .incbin "prg_bank_4.bin", $01BC, $9  ; $81BC
Bank4Tbl80C9_09:
  lda #$45                     ; $81C5
  jsr QueueSound               ; $81C7
  jsr Sub_B4_B011              ; $81CA
  jmp Loc_B4_8511              ; $81CD
Bank4Tbl80C9_0A:
  inc SceneState               ; $81D0
  jsr Sub_B4_90D6              ; $81D3
  lda MazeIndex                ; $81D6
  cmp #$0C                     ; $81D9
  bne Loc_B4_81EB              ; $81DB
  lda PlayerCellY              ; $81DD
  cmp #$02                     ; $81E0
  bne Loc_B4_81EB              ; $81E2
  lda PlayerFacing             ; $81E4
  cmp #$01                     ; $81E7
  beq Loc_B4_81EE              ; $81E9
Loc_B4_81EB:
  jmp Loc_B4_8D2B              ; $81EB
Loc_B4_81EE:
  lda #$00                     ; $81EE
  ldx #$14                     ; $81F0
  tay                          ; $81F2
  jsr Sub_B4_8BD5              ; $81F3
  jmp Loc_B4_8306              ; $81F6
Bank4Tbl80C9_0B:
  lda #$06                     ; $81F9
  sta SceneState               ; $81FB
  jsr FillPaletteBlack         ; $81FE
  jsr Sub_B4_8476              ; $8201
  jsr Sub_B4_95A1              ; $8204
  lda z:PpuCtrlShadow          ; $8207
  and #$FC                     ; $8209
  sta z:PpuCtrlShadow          ; $820B
  lda #$00                     ; $820D
  sta z:$7C                    ; $820F
  sta z:HwScrollX              ; $8211
  sta z:HwScrollY              ; $8213
  sta z:$88                    ; $8215
  sta z:$89                    ; $8217
  jsr Sub_B4_8B39              ; $8219
  jsr Sub_B4_854E              ; $821C
  jsr Sub_B4_9880              ; $821F
  jsr Sub_B4_997B              ; $8222
  jsr Sub_B4_9FAC              ; $8225
  jsr Sub_B4_A033              ; $8228
  jsr Sub_B4_A0F1              ; $822B
  jsr Sub_B4_901A              ; $822E
  jsr ApplyScroll              ; $8231
  jmp Loc_B4_8ADF              ; $8234
Bank4Tbl80C9_0C:
  inc SceneState               ; $8237
  jmp Sub_B4_90D6              ; $823A
Bank4Tbl80C9_0D:
  inc SceneState               ; $823D
  jsr FillPaletteBlack         ; $8240
  jsr Sub_B4_8476              ; $8243
  jsr Sub_B4_854E              ; $8246
  jsr Sub_B4_9F94              ; $8249
  lda #$00                     ; $824C
  sta z:HwScrollX              ; $824E
  sta z:HwScrollY              ; $8250
  jsr ApplyScroll              ; $8252
  lda z:PpuCtrlShadow          ; $8255
  ora #$02                     ; $8257
  sta z:PpuCtrlShadow          ; $8259
  jsr Sub_B4_86DD              ; $825B
  jsr Sub_B4_95A1              ; $825E
  jmp DrawObjects              ; $8261
Bank4Tbl80C9_0E:
  inc SceneState               ; $8264
  rts                          ; $8267
Bank4Tbl80C9_0F:
  inc SceneState               ; $8268
  jsr Sub_B4_95DA              ; $826B
  jmp Loc_B4_90CF              ; $826E
Bank4Tbl80C9_10:
  jsr ReadJoypads              ; $8271
  lda JoyNew1                  ; $8274
  lsr a                        ; $8277
  bcc Loc_B4_827E              ; $8278
  inc SceneState               ; $827A
  rts                          ; $827D
Loc_B4_827E:
  and #$10                     ; $827E
  beq Loc_B4_8287              ; $8280
  lda #$1B                     ; $8282
  sta SceneState               ; $8284
Loc_B4_8287:
  rts                          ; $8287
Bank4Tbl80C9_11:
  inc SceneState               ; $8288
  jmp Sub_B4_90D6              ; $828B
Bank4Tbl80C9_12:
  lda z:PpuCtrlShadow          ; $828E
  and #$FD                     ; $8290
  sta z:PpuCtrlShadow          ; $8292
  lda z:$7C                    ; $8294
  cmp #$09                     ; $8296
Loc_B4_8298:
  bcs Loc_B4_8298              ; $8298
  asl a                        ; $829A
  tax                          ; $829B
  lda Data_B4_82A9,x           ; $829C
  sta z:$6D                    ; $829F
  lda Data_B4_82AA,x           ; $82A1
  sta z:$6E                    ; $82A4
  jmp ($006D)                  ; $82A6
Data_B4_82A9:
  .incbin "prg_bank_4.bin", $02A9, $1  ; $82A9
Data_B4_82AA:
  .incbin "prg_bank_4.bin", $02AA, $5C  ; $82AA
Loc_B4_8306:
  lda #$00                     ; $8306
  sta z:MmcPrgShadow           ; $8308
  sta z:GameState              ; $830A
  rts                          ; $830C
  .incbin "prg_bank_4.bin", $030D, $9  ; $830D
Bank4Tbl80C9_13:
  inc SceneState               ; $8316
  jmp Sub_B4_90D6              ; $8319
Bank4Tbl80C9_14:
  inc SceneState               ; $831C
  jsr FillPaletteBlack         ; $831F
  jsr Sub_B4_8476              ; $8322
  jsr Sub_B4_A177              ; $8325
  jsr ApplyScroll              ; $8328
  jmp Sub_B4_86DD              ; $832B
Bank4Tbl80C9_15:
  inc SceneState               ; $832E
  lda $052E                    ; $8331
  ldx z:$81                    ; $8334
  cpx #$01                     ; $8336
  bne Loc_B4_833C              ; $8338
  and #$0F                     ; $833A
Loc_B4_833C:
  sta $052A                    ; $833C
  jsr Sub_B4_95DA              ; $833F
  jmp Loc_B4_90CF              ; $8342
Bank4Tbl80C9_16:
  jsr ReadJoypads              ; $8345
  lda JoyNew1                  ; $8348
  lsr a                        ; $834B
  bcc Loc_B4_835D              ; $834C
  lda z:$7C                    ; $834E
  sec                          ; $8350
  sbc #$05                     ; $8351
  and #$01                     ; $8353
  tax                          ; $8355
  lda Data_B4_8367,x           ; $8356
  sta SceneState               ; $8359
  rts                          ; $835C
Loc_B4_835D:
  and #$10                     ; $835D
  beq Loc_B4_8366              ; $835F
  lda #$1B                     ; $8361
  sta SceneState               ; $8363
Loc_B4_8366:
  rts                          ; $8366
Data_B4_8367:
  .incbin "prg_bank_4.bin", $0367, $2  ; $8367
Bank4Tbl80C9_17:
  inc SceneState               ; $8369
  jmp Sub_B4_90D6              ; $836C
Bank4Tbl80C9_18:
  lda #$06                     ; $836F
  sta SceneState               ; $8371
  jsr FillPaletteBlack         ; $8374
  jsr Sub_B4_8476              ; $8377
  jsr Sub_B4_8C24              ; $837A
  jsr Sub_B4_854E              ; $837D
  jsr Sub_B4_9880              ; $8380
  jsr Sub_B4_997B              ; $8383
  jsr Sub_B4_9FAC              ; $8386
  jsr Sub_B4_A033              ; $8389
  jsr Sub_B4_A0F1              ; $838C
  jsr Sub_B4_901A              ; $838F
  jmp ApplyScroll              ; $8392
Bank4Tbl80C9_19:
  inc SceneState               ; $8395
  jmp Sub_B4_90D6              ; $8398
Bank4Tbl80C9_1A:
  jsr Sub_B4_8C24              ; $839B
  jmp Loc_B4_8306              ; $839E
Bank4Tbl80C9_1B:
  lda #$06                     ; $83A1
  sta SceneState               ; $83A3
  jsr Sub_B4_90D6              ; $83A6
  lda #$0F                     ; $83A9
  sta $052A                    ; $83AB
  jsr Sub_B4_8476              ; $83AE
  jsr Sub_B4_854E              ; $83B1
  jsr Sub_B4_A0F1              ; $83B4
  lda z:PpuCtrlShadow          ; $83B7
  and #$FD                     ; $83B9
  sta z:PpuCtrlShadow          ; $83BB
  rts                          ; $83BD
Bank4Tbl80C9_1C:
  inc SceneState               ; $83BE
  jmp Sub_B4_90D6              ; $83C1
Bank4Tbl80C9_1D:
  lda #$06                     ; $83C4
  sta SceneState               ; $83C6
  jsr FillPaletteBlack         ; $83C9
  jsr Sub_B4_8476              ; $83CC
  jsr Sub_B4_854E              ; $83CF
  jsr Sub_B4_9880              ; $83D2
  jsr Sub_B4_997B              ; $83D5
  jsr Sub_B4_9FAC              ; $83D8
  jsr Sub_B4_A033              ; $83DB
  jsr Sub_B4_A0F1              ; $83DE
  jsr Sub_B4_901A              ; $83E1
  jmp ApplyScroll              ; $83E4
Bank4Tbl80C9_1E:
  lda #$06                     ; $83E7
  sta SceneState               ; $83E9
  jsr FillPaletteBlack         ; $83EC
  jsr Sub_B4_8476              ; $83EF
  jsr Sub_B4_854E              ; $83F2
  lda $0510                    ; $83F5
  sta MazeIndex                ; $83F8
  lda $0511                    ; $83FB
  sta PlayerCellX              ; $83FE
  lda $0512                    ; $8401
  sta PlayerCellY              ; $8404
  lda $0513                    ; $8407
  sta PlayerFacing             ; $840A
  jsr Sub_B4_9196              ; $840D
  jsr Sub_B4_9880              ; $8410
  jsr Sub_B4_997B              ; $8413
  jsr Sub_B4_9FAC              ; $8416
  jsr Sub_B4_A033              ; $8419
  jsr Sub_B4_A0F1              ; $841C
  jsr Sub_B4_901A              ; $841F
  jmp ApplyScroll              ; $8422
Bank4Tbl80C9_1F:
  inc SceneState               ; $8425
  lda #$78                     ; $8428
  sta $058F                    ; $842A
  lda #$05                     ; $842D
  sta PpuOpRequest             ; $842F
  ldx #$06                     ; $8432
Loc_B4_8434:
  lda Data_B4_8442,x           ; $8434
  sta $052A,x                  ; $8437
  dex                          ; $843A
  bpl Loc_B4_8434              ; $843B
  lda #$45                     ; $843D
  jmp QueueSound               ; $843F
Data_B4_8442:
  .incbin "prg_bank_4.bin", $0442, $7  ; $8442
Bank4Tbl80C9_20:
  dec $058F                    ; $8449
  bne Loc_B4_8463              ; $844C
  lda #$05                     ; $844E
  sta z:MmcPrgShadow           ; $8450
  lda #$03                     ; $8452
  sta SceneState               ; $8454
  ldy MazeIndex                ; $8457
  lda Data_B4_8464,y           ; $845A
  sta $013F                    ; $845D
  jmp Sub_B4_90D6              ; $8460
Loc_B4_8463:
  rts                          ; $8463
Data_B4_8464:
  .incbin "prg_bank_4.bin", $0464, $12  ; $8464
Sub_B4_8476:
  ldx Data_C34D                ; $8476
  bne Loc_B4_847D              ; $8479
Sub_B4_847B:
  ldx #$00                     ; $847B
Loc_B4_847D:
  lda #$F0                     ; $847D
Loc_B4_847F:
  sta OamBuffer,x              ; $847F
  inx                          ; $8482
  inx                          ; $8483
  inx                          ; $8484
  inx                          ; $8485
  bne Loc_B4_847F              ; $8486
  rts                          ; $8488
Sub_B4_8489:
  lda #$BE                     ; $8489
  sta OamBuffer                ; $848B
  lda #$FE                     ; $848E
  sta $0201                    ; $8490
  lda #$20                     ; $8493
  sta $0202                    ; $8495
  lda #$D0                     ; $8498
  sta $0203                    ; $849A
  rts                          ; $849D
Loc_B4_849E:
  lda #$20                     ; $849E
  sta z:GameState              ; $84A0
  lda #$03                     ; $84A2
  sta $0300                    ; $84A4
  lda #$23                     ; $84A7
  sta z:$80                    ; $84A9
  lda #$00                     ; $84AB
  sta z:HwScrollX              ; $84AD
  sta z:HwScrollY              ; $84AF
  sta $0503                    ; $84B1
  sta $0504                    ; $84B4
  lda #$00                     ; $84B7
  sta APU_DMC_FREQ             ; $84B9
  sta APU_DMC_RAW              ; $84BC
  lda #$0F                     ; $84BF
  sta APU_SND_CHN              ; $84C1
  lda #$C0                     ; $84C4
  sta JOYPAD2                  ; $84C6
  lda #$00                     ; $84C9
  jsr QueueSound               ; $84CB
  lda #$08                     ; $84CE
  jsr QueueSound               ; $84D0
  jsr Sub_B4_86DD              ; $84D3
  jsr Sub_B4_847B              ; $84D6
  jsr Sub_B4_8489              ; $84D9
  ldx #$1F                     ; $84DC
  stx z:MmcControlShadow       ; $84DE
  jsr MmcWriteControl          ; $84E0
  ldx #$0C                     ; $84E3
  stx z:MmcChr0Shadow          ; $84E5
  jsr MmcWriteChr0             ; $84E7
  ldx #$0B                     ; $84EA
  stx z:MmcChr1Shadow          ; $84EC
  jsr MmcWriteChr1             ; $84EE
  lda #$06                     ; $84F1
  jsr SetPpuMask               ; $84F3
  lda #$30                     ; $84F6
  sta z:PpuCtrlShadow          ; $84F8
  jmp ApplyScroll              ; $84FA
Sub_B4_84FD:
  lda #$00                     ; $84FD
  ldx #$10                     ; $84FF
Loc_B4_8501:
  sta SceneState,x             ; $8501
  inx                          ; $8504
  bne Loc_B4_8501              ; $8505
Sub_B4_8507:
  lda #$00                     ; $8507
  ldx #$7F                     ; $8509
Loc_B4_850B:
  sta z:$60,x                  ; $850B
  dex                          ; $850D
  bpl Loc_B4_850B              ; $850E
  rts                          ; $8510
Loc_B4_8511:
  dec z:$8A                    ; $8511
  beq Loc_B4_8546              ; $8513
  ldx z:$72                    ; $8515
  lda Data_B4_854A,x           ; $8517
  beq Loc_B4_8546              ; $851A
  sta z:$60                    ; $851C
  ldy #$03                     ; $851E
Loc_B4_8520:
  tya                          ; $8520
  asl a                        ; $8521
  asl a                        ; $8522
  tax                          ; $8523
  lda $0213,x                  ; $8524
  clc                          ; $8527
  adc z:$60                    ; $8528
  cmp #$2C                     ; $852A
  beq Loc_B4_8532              ; $852C
  cmp #$AC                     ; $852E
  bne Loc_B4_8534              ; $8530
Loc_B4_8532:
  eor #$80                     ; $8532
Loc_B4_8534:
  sta $0213,x                  ; $8534
  dey                          ; $8537
  bpl Loc_B4_8520              ; $8538
  jsr Sub_B4_858B              ; $853A
  lda $0213                    ; $853D
  and #$1F                     ; $8540
  cmp #$1C                     ; $8542
  bne Loc_B4_8549              ; $8544
Loc_B4_8546:
  inc SceneState               ; $8546
Loc_B4_8549:
  rts                          ; $8549
Data_B4_854A:
  .incbin "prg_bank_4.bin", $054A, $4  ; $854A
Sub_B4_854E:
  lda #$00                     ; $854E
  sta $0211                    ; $8550
  lda #$02                     ; $8553
  sta $0215                    ; $8555
  lda #$04                     ; $8558
  sta $0219                    ; $855A
  lda #$06                     ; $855D
  sta $021D                    ; $855F
  lda #$03                     ; $8562
  sta $0212                    ; $8564
  sta $0216                    ; $8567
  sta $021A                    ; $856A
  sta $021E                    ; $856D
  ldx PlayerFacing             ; $8570
  lda Data_B4_85AC,x           ; $8573
  sta $0213                    ; $8576
  lda Data_B4_85AB,x           ; $8579
  sta $0217                    ; $857C
  lda Data_B4_85AA,x           ; $857F
  sta $021B                    ; $8582
  lda Data_B4_85A9,x           ; $8585
  sta $021F                    ; $8588
Sub_B4_858B:
  ldx #$03                     ; $858B
Loc_B4_858D:
  txa                          ; $858D
  asl a                        ; $858E
  asl a                        ; $858F
  tay                          ; $8590
  lda $0213,y                  ; $8591
  cmp #$5A                     ; $8594
  bcc Loc_B4_859C              ; $8596
  cmp #$9F                     ; $8598
  bcc Loc_B4_85A0              ; $859A
Loc_B4_859C:
  lda #$F0                     ; $859C
  bne Loc_B4_85A2              ; $859E
Loc_B4_85A0:
  lda #$CA                     ; $85A0
Loc_B4_85A2:
  sta $0210,y                  ; $85A2
  dex                          ; $85A5
  bpl Loc_B4_858D              ; $85A6
  rts                          ; $85A8
Data_B4_85A9:
  .incbin "prg_bank_4.bin", $05A9, $1  ; $85A9
Data_B4_85AA:
  .incbin "prg_bank_4.bin", $05AA, $1  ; $85AA
Data_B4_85AB:
  .incbin "prg_bank_4.bin", $05AB, $1  ; $85AB
Data_B4_85AC:
  .incbin "prg_bank_4.bin", $05AC, $4  ; $85AC
Loc_B4_85B0:
  cmp #$0E                     ; $85B0
Loc_B4_85B2:
  bcs Loc_B4_85B2              ; $85B2
  asl a                        ; $85B4
  tax                          ; $85B5
  lda Data_B4_85C3,x           ; $85B6
  sta z:$6D                    ; $85B9
  lda Data_B4_85C4,x           ; $85BB
  sta z:$6E                    ; $85BE
  jmp ($006D)                  ; $85C0
Data_B4_85C3:
  .addr Bank4Tbl85C3_00, Bank4Tbl85C3_01, Bank4Tbl85C3_02, Bank4Tbl85C3_03, Bank4Tbl85C3_04, Bank4Tbl85C3_05, Bank4Tbl85C3_06, Bank4Tbl85C3_07, Bank4Tbl85C3_08, Bank4Tbl85C3_09, Bank4Tbl85C3_0A, Bank4Tbl85C3_0B, Bank4Tbl85C3_0C, Bank4Tbl85C3_0D  ; $85C3 pointer table
Bank4Tbl85C3_00:
  lda #$00                     ; $85DF
  sta z:$7C                    ; $85E1
  rts                          ; $85E3
Bank4Tbl85C3_01:
  dec z:$7F                    ; $85E4
  lda #$02                     ; $85E6
  sta z:$7C                    ; $85E8
  rts                          ; $85EA
Bank4Tbl85C3_02:
  inc z:$7E                    ; $85EB
  lda #$02                     ; $85ED
  sta z:$7C                    ; $85EF
  rts                          ; $85F1
Bank4Tbl85C3_03:
  inc z:$7F                    ; $85F2
  lda #$02                     ; $85F4
  sta z:$7C                    ; $85F6
  rts                          ; $85F8
Bank4Tbl85C3_04:
  dec z:$7E                    ; $85F9
  lda #$02                     ; $85FB
  sta z:$7C                    ; $85FD
  rts                          ; $85FF
Bank4Tbl85C3_05:
  lda $0508                    ; $8600
  ora $050B                    ; $8603
  bne Loc_B4_8610              ; $8606
  ldy #$EA                     ; $8608
  jsr Sub_B4_B43F              ; $860A
  jmp Bank4Tbl85C3_00          ; $860D
Loc_B4_8610:
  lda #$00                     ; $8610
  ldx #$08                     ; $8612
  ldy #$03                     ; $8614
  jmp Sub_B4_8BD5              ; $8616
Bank4Tbl85C3_06:
  lda $0508                    ; $8619
  ora $050C                    ; $861C
  bne Bank4Tbl85C3_04          ; $861F
  ldy #$E9                     ; $8621
  jsr Sub_B4_B43F              ; $8623
  jmp Bank4Tbl85C3_00          ; $8626
Bank4Tbl85C3_07:
  lda #$01                     ; $8629
  sta $050C                    ; $862B
  ldx #$05                     ; $862E
  ldy #$04                     ; $8630
  jmp Sub_B4_8BD5              ; $8632
Bank4Tbl85C3_08:
  lda $0508                    ; $8635
  ora $050C                    ; $8638
  bne Loc_B4_8645              ; $863B
  ldy #$E9                     ; $863D
  jsr Sub_B4_B43F              ; $863F
  jmp Bank4Tbl85C3_00          ; $8642
Loc_B4_8645:
  lda #$06                     ; $8645
  sta $0510                    ; $8647
  lda #$01                     ; $864A
  sta $0511                    ; $864C
  lda #$07                     ; $864F
  sta $0512                    ; $8651
  lda #$00                     ; $8654
  sta $0513                    ; $8656
Loc_B4_8659:
  lda #$01                     ; $8659
  sta $0503                    ; $865B
  lda #$08                     ; $865E
  sta z:$7C                    ; $8660
  rts                          ; $8662
Bank4Tbl85C3_09:
  lda $0508                    ; $8663
  ora $050C                    ; $8666
  beq Loc_B4_866E              ; $8669
  jmp Bank4Tbl85C3_04          ; $866B
Loc_B4_866E:
  ldy #$E9                     ; $866E
  jsr Sub_B4_B43F              ; $8670
  jmp Bank4Tbl85C3_00          ; $8673
Bank4Tbl85C3_0A:
  lda $0508                    ; $8676
  bne Loc_B4_8683              ; $8679
  ldy #$EB                     ; $867B
  jsr Sub_B4_B43F              ; $867D
  jmp Bank4Tbl85C3_00          ; $8680
Loc_B4_8683:
  lda #$00                     ; $8683
  ldx #$0B                     ; $8685
  ldy #$03                     ; $8687
  jmp Sub_B4_8BD5              ; $8689
Bank4Tbl85C3_0B:
  lda $0508                    ; $868C
  ora $050C                    ; $868F
  bne Loc_B4_869C              ; $8692
  ldy #$E9                     ; $8694
  jsr Sub_B4_B43F              ; $8696
  jmp Bank4Tbl85C3_00          ; $8699
Loc_B4_869C:
  lda #$04                     ; $869C
  sta $0510                    ; $869E
  lda PlayerCellX              ; $86A1
  clc                          ; $86A4
  adc #$03                     ; $86A5
  sta $0511                    ; $86A7
  lda #$00                     ; $86AA
  sta $0512                    ; $86AC
  lda #$02                     ; $86AF
  sta $0513                    ; $86B1
  jmp Loc_B4_8659              ; $86B4
Bank4Tbl85C3_0C:
  lda #$00                     ; $86B7
  ldx #$11                     ; $86B9
  ldy #$03                     ; $86BB
  jmp Sub_B4_8BD5              ; $86BD
Bank4Tbl85C3_0D:
  lda #$0B                     ; $86C0
  sta $0510                    ; $86C2
  lda #$07                     ; $86C5
  sta $0511                    ; $86C7
  lda #$00                     ; $86CA
  sta $0512                    ; $86CC
  lda #$02                     ; $86CF
  sta $0513                    ; $86D1
  lda #$01                     ; $86D4
  ldx #$0E                     ; $86D6
  ldy #$07                     ; $86D8
  jmp Sub_B4_8BD5              ; $86DA
Sub_B4_86DD:
  lda #$00                     ; $86DD
  sta ObjectCount              ; $86DF
  ldx #$10                     ; $86E2
Loc_B4_86E4:
  sta $0300,x                  ; $86E4
  inx                          ; $86E7
  bne Loc_B4_86E4              ; $86E8
  rts                          ; $86EA
Data_B4_86EB:
  .incbin "prg_bank_4.bin", $06EB, $1  ; $86EB
Data_B4_86EC:
  .incbin "prg_bank_4.bin", $06EC, $23  ; $86EC
Data_B4_870F:
  .incbin "prg_bank_4.bin", $070F, $1  ; $870F
Data_B4_8710:
  .incbin "prg_bank_4.bin", $0710, $23  ; $8710
Data_B4_8733:
  .incbin "prg_bank_4.bin", $0733, $1  ; $8733
Data_B4_8734:
  .incbin "prg_bank_4.bin", $0734, $3AB  ; $8734
Loc_B4_8ADF:
  lda ObjectCount              ; $8ADF
  beq Loc_B4_8AE5              ; $8AE2
  rts                          ; $8AE4
Loc_B4_8AE5:
  lda MazeIndex                ; $8AE5
  asl a                        ; $8AE8
  tax                          ; $8AE9
  lda Data_B4_86EB,x           ; $8AEA
  sta z:$60                    ; $8AED
  lda Data_B4_86EC,x           ; $8AEF
  sta z:$61                    ; $8AF2
  lda Data_B4_870F,x           ; $8AF4
  sta z:$62                    ; $8AF7
  lda Data_B4_8710,x           ; $8AF9
  sta z:$63                    ; $8AFC
  lda Data_B4_8733,x           ; $8AFE
  sta z:$64                    ; $8B01
  lda Data_B4_8734,x           ; $8B03
  sta z:$65                    ; $8B06
  lda PlayerCellX              ; $8B08
  jsr AslA4                    ; $8B0B
  ora PlayerCellY              ; $8B0E
  sta z:$6A                    ; $8B11
  ldy #$00                     ; $8B13
Loc_B4_8B15:
  lda ($60),y                  ; $8B15
  cmp z:$6A                    ; $8B17
  beq Loc_B4_8B22              ; $8B19
  bcs Loc_B4_8B21              ; $8B1B
  iny                          ; $8B1D
  jmp Loc_B4_8B15              ; $8B1E
Loc_B4_8B21:
  rts                          ; $8B21
Loc_B4_8B22:
  lda ($62),y                  ; $8B22
  bmi Loc_B4_8B2F              ; $8B24
  cmp PlayerFacing             ; $8B26
  beq Loc_B4_8B2F              ; $8B29
  iny                          ; $8B2B
  jmp Loc_B4_8B15              ; $8B2C
Loc_B4_8B2F:
  jsr Sub_B4_8FBF              ; $8B2F
  lda ($64),y                  ; $8B32
  ldy #$00                     ; $8B34
  sta (Tmp00),y                ; $8B36
  rts                          ; $8B38
Sub_B4_8B39:
  lda ObjectCount              ; $8B39
  beq Loc_B4_8B4E              ; $8B3C
  jsr AslA4                    ; $8B3E
  sta z:Tmp00                  ; $8B41
  lda #$03                     ; $8B43
  sta z:Tmp01                  ; $8B45
Loc_B4_8B47:
  jsr Sub_B4_8B4F              ; $8B47
  lda z:Tmp00                  ; $8B4A
  bne Loc_B4_8B47              ; $8B4C
Loc_B4_8B4E:
  rts                          ; $8B4E
Sub_B4_8B4F:
  ldy #$00                     ; $8B4F
  lda (Tmp00),y                ; $8B51
  and #$3F                     ; $8B53
  cmp #$18                     ; $8B55
  bcs Loc_B4_8B63              ; $8B57
  asl a                        ; $8B59
  asl a                        ; $8B5A
  adc z:$72                    ; $8B5B
  tax                          ; $8B5D
  lda Data_B4_8B75,x           ; $8B5E
  bne Loc_B4_8B66              ; $8B61
Loc_B4_8B63:
  jmp RemoveObject             ; $8B63
Loc_B4_8B66:
  sta (Tmp00),y                ; $8B66
  tya                          ; $8B68
  ldy #$08                     ; $8B69
  sta (Tmp00),y                ; $8B6B
  lda z:Tmp00                  ; $8B6D
  sec                          ; $8B6F
  sbc #$10                     ; $8B70
  sta z:Tmp00                  ; $8B72
  rts                          ; $8B74
Data_B4_8B75:
  .incbin "prg_bank_4.bin", $0B75, $60  ; $8B75
Sub_B4_8BD5:
  sta $0503                    ; $8BD5
  sty z:$7C                    ; $8BD8
  ldy #$03                     ; $8BDA
Loc_B4_8BDC:
  lda Data_B4_8BEC,x           ; $8BDC
  sta a:TransitionPending,y    ; $8BDF
  dex                          ; $8BE2
  dey                          ; $8BE3
  bne Loc_B4_8BDC              ; $8BE4
  sty z:PaletteDirty           ; $8BE6
  iny                          ; $8BE8
  sty z:TransitionPending      ; $8BE9
  rts                          ; $8BEB
Data_B4_8BEC:
  .incbin "prg_bank_4.bin", $0BEC, $1B  ; $8BEC
Sub_B4_8C07:
  lda z:PlayerLifeLo           ; $8C07
  cmp #$32                     ; $8C09
  ldx z:$8B                    ; $8C0B
  bcs Loc_B4_8C18              ; $8C0D
  bne Loc_B4_8C23              ; $8C0F
  lda #$42                     ; $8C11
  sta z:$8B                    ; $8C13
  jmp QueueSound               ; $8C15
Loc_B4_8C18:
  beq Loc_B4_8C23              ; $8C18
  lda #$00                     ; $8C1A
  sta z:$8B                    ; $8C1C
  lda #$44                     ; $8C1E
  jmp QueueSound               ; $8C20
Loc_B4_8C23:
  rts                          ; $8C23
Sub_B4_8C24:
  jsr Sub_B4_8C2A              ; $8C24
  jmp Sub_B4_9196              ; $8C27
Sub_B4_8C2A:
  lda z:$82                    ; $8C2A
  cmp #$16                     ; $8C2C
Loc_B4_8C2E:
  bcs Loc_B4_8C2E              ; $8C2E
  asl a                        ; $8C30
  tax                          ; $8C31
  lda Data_B4_8C3F,x           ; $8C32
  sta z:$6D                    ; $8C35
  lda Data_B4_8C40,x           ; $8C37
  sta z:$6E                    ; $8C3A
  jmp ($006D)                  ; $8C3C
Data_B4_8C3F:
  .incbin "prg_bank_4.bin", $0C3F, $1  ; $8C3F
Data_B4_8C40:
  .incbin "prg_bank_4.bin", $0C40, $EB  ; $8C40
Loc_B4_8D2B:
  ldx #$08                     ; $8D2B
Loc_B4_8D2D:
  lda z:$72,x                  ; $8D2D
  sta z:$73,x                  ; $8D2F
  dex                          ; $8D31
  bpl Loc_B4_8D2D              ; $8D32
  rts                          ; $8D34
Sub_B4_8D35:
  lda z:$6F                    ; $8D35
  beq Loc_B4_8D3C              ; $8D37
  jmp Loc_B4_8DC5              ; $8D39
Loc_B4_8D3C:
  lda JoyNew1                  ; $8D3C
  and #$01                     ; $8D3F
  beq Loc_B4_8D5C              ; $8D41
  jsr AslA4                    ; $8D43
  ldy #$00                     ; $8D46
Loc_B4_8D48:
  tax                          ; $8D48
  tya                          ; $8D49
  ora $0309,x                  ; $8D4A
  tay                          ; $8D4D
  txa                          ; $8D4E
  sec                          ; $8D4F
  sbc #$10                     ; $8D50
  bne Loc_B4_8D48              ; $8D52
  tya                          ; $8D54
  asl a                        ; $8D55
  bmi Loc_B4_8D82              ; $8D56
  asl a                        ; $8D58
  bmi Loc_B4_8D9E              ; $8D59
  rts                          ; $8D5B
Loc_B4_8D5C:
  ldy z:AmmoLo                 ; $8D5C
  ldx z:AmmoHi                 ; $8D5E
  bne Loc_B4_8D72              ; $8D60
  lda JoyNew1                  ; $8D62
  and #$04                     ; $8D65
  beq Loc_B4_8D71              ; $8D67
  cpy #$0A                     ; $8D69
  bcs Loc_B4_8D71              ; $8D6B
  dec z:PlayerLifeLo           ; $8D6D
  inc z:AmmoLo                 ; $8D6F
Loc_B4_8D71:
  rts                          ; $8D71
Loc_B4_8D72:
  dex                          ; $8D72
  bne Loc_B4_8D79              ; $8D73
  cpy #$91                     ; $8D75
  bcc Loc_B4_8D81              ; $8D77
Loc_B4_8D79:
  lda #$90                     ; $8D79
  sta z:AmmoLo                 ; $8D7B
  lda #$01                     ; $8D7D
  sta z:AmmoHi                 ; $8D7F
Loc_B4_8D81:
  rts                          ; $8D81
Loc_B4_8D82:
  lda z:AmmoLo                 ; $8D82
  ora z:AmmoHi                 ; $8D84
  beq Loc_B4_8D95              ; $8D86
  inc z:$6F                    ; $8D88
  ldx #$07                     ; $8D8A
Loc_B4_8D8C:
  lda Data_B4_8D96,x           ; $8D8C
  sta $0204,x                  ; $8D8F
  dex                          ; $8D92
  bpl Loc_B4_8D8C              ; $8D93
Loc_B4_8D95:
  rts                          ; $8D95
Data_B4_8D96:
  .incbin "prg_bank_4.bin", $0D96, $8  ; $8D96
Loc_B4_8D9E:
  lda $051F                    ; $8D9E
  beq Loc_B4_8DB8              ; $8DA1
  lda ObjectCount              ; $8DA3
  jsr AslA4                    ; $8DA6
  tax                          ; $8DA9
Loc_B4_8DAA:
  lda $0309,x                  ; $8DAA
  tay                          ; $8DAD
  and #$20                     ; $8DAE
  bne Loc_B4_8DB9              ; $8DB0
  txa                          ; $8DB2
  sec                          ; $8DB3
  sbc #$10                     ; $8DB4
  bne Loc_B4_8DAA              ; $8DB6
Loc_B4_8DB8:
  rts                          ; $8DB8
Loc_B4_8DB9:
  tya                          ; $8DB9
  ora #$80                     ; $8DBA
  sta $0309,x                  ; $8DBC
  dec $051F                    ; $8DBF
  jmp Loc_B4_A00F              ; $8DC2
Loc_B4_8DC5:
  lda JoyNew1                  ; $8DC5
  lsr a                        ; $8DC8
  bcs Loc_B4_8DD1              ; $8DC9
  lsr a                        ; $8DCB
  bcc Loc_B4_8DEF              ; $8DCC
  jmp Sub_B4_8E16              ; $8DCE
Loc_B4_8DD1:
  lda #$0E                     ; $8DD1
  jsr QueueSound               ; $8DD3
  jsr Sub_B4_8E16              ; $8DD6
  ldy ObjectCount              ; $8DD9
  beq Loc_B4_8DE6              ; $8DDC
Loc_B4_8DDE:
  jsr Sub_B4_8E23              ; $8DDE
  bcs Loc_B4_8DE6              ; $8DE1
  dey                          ; $8DE3
  bne Loc_B4_8DDE              ; $8DE4
Loc_B4_8DE6:
  ldx z:AmmoLo                 ; $8DE6
  bne Loc_B4_8DEC              ; $8DE8
  dec z:AmmoHi                 ; $8DEA
Loc_B4_8DEC:
  dec z:AmmoLo                 ; $8DEC
  rts                          ; $8DEE
Loc_B4_8DEF:
  bit JoyNew1                  ; $8DEF
  bmi Loc_B4_8DF7              ; $8DF2
  bvs Loc_B4_8E0A              ; $8DF4
Loc_B4_8DF6:
  rts                          ; $8DF6
Loc_B4_8DF7:
  lda $0207                    ; $8DF7
  cmp #$90                     ; $8DFA
  bcs Loc_B4_8DF6              ; $8DFC
  adc #$38                     ; $8DFE
Loc_B4_8E00:
  sta $0207                    ; $8E00
  clc                          ; $8E03
  adc #$08                     ; $8E04
  sta $020B                    ; $8E06
  rts                          ; $8E09
Loc_B4_8E0A:
  lda $0207                    ; $8E0A
  cmp #$50                     ; $8E0D
  bcc Loc_B4_8DF6              ; $8E0F
  sbc #$38                     ; $8E11
  jmp Loc_B4_8E00              ; $8E13
Sub_B4_8E16:
  lda #$00                     ; $8E16
  sta z:$6F                    ; $8E18
  lda #$F0                     ; $8E1A
  sta $0204                    ; $8E1C
  sta $0208                    ; $8E1F
  rts                          ; $8E22
Sub_B4_8E23:
  tya                          ; $8E23
  beq Bank4Tbl8E4A_00          ; $8E24
  jsr AslA4                    ; $8E26
  tax                          ; $8E29
  stx z:$6B                    ; $8E2A
  lda $0309,x                  ; $8E2C
  asl a                        ; $8E2F
  bpl Bank4Tbl8E4A_00          ; $8E30
  lda $0300,x                  ; $8E32
  and #$3F                     ; $8E35
  cmp #$2D                     ; $8E37
Loc_B4_8E39:
  bcs Loc_B4_8E39              ; $8E39
  asl a                        ; $8E3B
  tax                          ; $8E3C
  lda Data_B4_8E4A,x           ; $8E3D
  sta z:$6D                    ; $8E40
  lda Data_B4_8E4B,x           ; $8E42
  sta z:$6E                    ; $8E45
  jmp ($006D)                  ; $8E47
Data_B4_8E4A:
  ldy z:$8E                    ; $8E4A  [heuristic code]
  ldx z:$8E                    ; $8E4C
  bcs Loc_B4_8DDE              ; $8E4E
  bcs *-112                    ; $8E50
  bcs *-112                    ; $8E52
  ldy z:$8E                    ; $8E54
  ldy Data_B4_A48E,x           ; $8E56
  stx Bank4Tbl8E4A_00          ; $8E59
  ldy z:$8E                    ; $8E5C
  iny                          ; $8E5E
  stx Bank4Tbl8E4A_00          ; $8E5F
  ldy z:$8E                    ; $8E62
  ldy z:$8E                    ; $8E64
  ldy z:$8E                    ; $8E66
  ldy z:$8E                    ; $8E68
  ldy z:$8E                    ; $8E6A
  .incbin "prg_bank_4.bin", $0E6C, $38  ; $8E6C
Bank4Tbl8E4A_00:
  clc                          ; $8EA4
  rts                          ; $8EA5
Bank4Tbl8E4A_01:
  ldx z:$6B                    ; $8EA6
  lda $0302,x                  ; $8EA8
  cmp $0207                    ; $8EAB
  bne Bank4Tbl8E4A_00          ; $8EAE
Bank4Tbl8E4A_02:
  ldx z:$6B                    ; $8EB0
  lda $0309,x                  ; $8EB2
  ora #$80                     ; $8EB5
  sta $0309,x                  ; $8EB7
  sec                          ; $8EBA
  rts                          ; $8EBB
Bank4Tbl8E4A_06:
  ldx z:$6B                    ; $8EBC
  lda ObjectCount,x            ; $8EBE
  cmp #$44                     ; $8EC1
  bcc Bank4Tbl8E4A_00          ; $8EC3
  jmp Bank4Tbl8E4A_01          ; $8EC5
Bank4Tbl8E4A_0A:
  ldx z:$6B                    ; $8EC8
  lda $0305,x                  ; $8ECA
  beq Bank4Tbl8E4A_01          ; $8ECD
  jmp Bank4Tbl8E4A_00          ; $8ECF
Bank4Tbl8E4A_11:
  ldx z:$6B                    ; $8ED2
  lda $0302,x                  ; $8ED4
  cmp $0207                    ; $8ED7
  bne Bank4Tbl8E4A_00          ; $8EDA
  jmp Bank4Tbl8E4A_02          ; $8EDC
  sta z:$60                    ; $8EDF  [heuristic code]
  asl a                        ; $8EE1
  adc z:$60                    ; $8EE2
  tax                          ; $8EE4
  ldy #$14                     ; $8EE5
  jsr Sub_B4_8EF1              ; $8EE7
  ldy z:$60                    ; $8EEA
  ldx Data_B4_8F67,y           ; $8EEC
  ldy #$18                     ; $8EEF
Sub_B4_8EF1:
  lda Data_B4_8F04,x           ; $8EF1
  sta SceneTimer,y             ; $8EF4
  lda Data_B4_8F05,x           ; $8EF7
  sta $0527,y                  ; $8EFA
  lda Data_B4_8F06,x           ; $8EFD
  sta $0528,y                  ; $8F00
  rts                          ; $8F03
Data_B4_8F04:
  .incbin "prg_bank_4.bin", $0F04, $1  ; $8F04
Data_B4_8F05:
  .incbin "prg_bank_4.bin", $0F05, $1  ; $8F05
Data_B4_8F06:
  .incbin "prg_bank_4.bin", $0F06, $61  ; $8F06
Data_B4_8F67:
  .incbin "prg_bank_4.bin", $0F67, $1E  ; $8F67
Sub_B4_8F85:
  ldy #$05                     ; $8F85
  sta (Tmp00),y                ; $8F87
  asl a                        ; $8F89
  tax                          ; $8F8A
  ldy #$00                     ; $8F8B
  lda (Tmp00),y                ; $8F8D
  and #$3F                     ; $8F8F
  asl a                        ; $8F91
  tay                          ; $8F92
  lda Data_B4_B580,y           ; $8F93
  sta z:$60                    ; $8F96
  lda Data_B4_B581,y           ; $8F98
  sta z:$61                    ; $8F9B
  txa                          ; $8F9D
  tay                          ; $8F9E
  lda ($60),y                  ; $8F9F
  sta z:$62                    ; $8FA1
  iny                          ; $8FA3
  lda ($60),y                  ; $8FA4
  sta z:$63                    ; $8FA6
  ldy #$00                     ; $8FA8
  lda ($62),y                  ; $8FAA
  ldy #$04                     ; $8FAC
  sta (Tmp00),y                ; $8FAE
  asl a                        ; $8FB0
  asl a                        ; $8FB1
  dey                          ; $8FB2
  clc                          ; $8FB3
  adc (Tmp00),y                ; $8FB4
  bcc Loc_B4_8FBE              ; $8FB6
  lda #$00                     ; $8FB8
  sta (Tmp00),y                ; $8FBA
  ldx #$10                     ; $8FBC
Loc_B4_8FBE:
  rts                          ; $8FBE
Sub_B4_8FBF:
  inc ObjectCount              ; $8FBF
  lda ObjectCount              ; $8FC2
  jsr AslA4                    ; $8FC5
  sta z:Tmp00                  ; $8FC8
  lda #$03                     ; $8FCA
  sta z:Tmp01                  ; $8FCC
  rts                          ; $8FCE
Sub_B4_8FCF:
  ldy #$08                     ; $8FCF
Sub_B4_8FD1:
  lda (Tmp00),y                ; $8FD1
  clc                          ; $8FD3
  adc #$01                     ; $8FD4
  sta (Tmp00),y                ; $8FD6
  rts                          ; $8FD8
Sub_B4_8FD9:
  lda (Tmp00),y                ; $8FD9
  sec                          ; $8FDB
  sbc #$01                     ; $8FDC
  sta (Tmp00),y                ; $8FDE
  rts                          ; $8FE0
Sub_B4_8FE1:
  ldy #$00                     ; $8FE1
  lda $054C                    ; $8FE3
  bpl Loc_B4_8FEA              ; $8FE6
  ldy #$04                     ; $8FE8
Loc_B4_8FEA:
  sty PPU_CTRL                 ; $8FEA
  and #$3F                     ; $8FED
  bne Loc_B4_8FF3              ; $8FEF
  lda #$40                     ; $8FF1
Loc_B4_8FF3:
  tay                          ; $8FF3
  lda PPU_STATUS               ; $8FF4
  lda $054A                    ; $8FF7
  and #$23                     ; $8FFA
  sta PPU_ADDR                 ; $8FFC
  lda $054B                    ; $8FFF
  sta PPU_ADDR                 ; $9002
  lda PPU_DATA                 ; $9005
  ldx #$00                     ; $9008
Loc_B4_900A:
  lda PPU_DATA                 ; $900A
  sta $054D,x                  ; $900D
  inx                          ; $9010
  dey                          ; $9011
  bne Loc_B4_900A              ; $9012
  lda #$FF                     ; $9014
  sta $054D,x                  ; $9016
  rts                          ; $9019
Sub_B4_901A:
  lda z:PpuCtrlShadow          ; $901A
  and #$FD                     ; $901C
  jsr SetPpuCtrl               ; $901E
  lda #$28                     ; $9021
  sta $054A                    ; $9023
  lda #$10                     ; $9026
  sta $058E                    ; $9028
  lda #$00                     ; $902B
  sta $054B                    ; $902D
  sta $054C                    ; $9030
Loc_B4_9033:
  ldy #$40                     ; $9033
  jsr Sub_B4_8FE1              ; $9035
  jsr ProcessPpuUpdateList     ; $9038
  .incbin "prg_bank_4.bin", $103B, $2  ; $903B
  lda $054B                    ; $903D
  clc                          ; $9040
  adc #$40                     ; $9041
  sta $054B                    ; $9043
  lda $054A                    ; $9046
  adc #$00                     ; $9049
  sta $054A                    ; $904B
  dec $058E                    ; $904E
  bne Loc_B4_9033              ; $9051
  rts                          ; $9053
  .incbin "prg_bank_4.bin", $1054, $9  ; $9054
Sub_B4_905D:
  lda PpuOpRequest             ; $905D
  ldx #$00                     ; $9060
  stx PpuOpRequest             ; $9062
  cmp #$08                     ; $9065
Loc_B4_9067:
  bcs Loc_B4_9067              ; $9067
  asl a                        ; $9069
  tax                          ; $906A
  lda Data_B4_9078,x           ; $906B
  sta z:$6D                    ; $906E
  lda Data_B4_9079,x           ; $9070
  sta z:$6E                    ; $9073
  jmp ($006D)                  ; $9075
Data_B4_9078:
  .incbin "prg_bank_4.bin", $1078, $1  ; $9078
Data_B4_9079:
  .incbin "prg_bank_4.bin", $1079, $13  ; $9079
Sub_B4_908C:
  jsr ProcessPpuUpdateList     ; $908C
  .incbin "prg_bank_4.bin", $108F, $2  ; $908F
  rts                          ; $9091
  .incbin "prg_bank_4.bin", $1092, $24  ; $9092
Sub_B4_90B6:
  ldx #$05                     ; $90B6
Loc_B4_90B8:
  lda Sub_B4_908C,x            ; $90B8
  sta $0520,x                  ; $90BB
  dex                          ; $90BE
  bpl Loc_B4_90B8              ; $90BF
  rts                          ; $90C1
  .incbin "prg_bank_4.bin", $10C2, $C  ; $90C2
  rts                          ; $90CE
Loc_B4_90CF:
  lda z:PpuMaskShadow          ; $90CF
  ora #$18                     ; $90D1
  jmp SetPpuMask               ; $90D3
Sub_B4_90D6:
  lda z:PpuMaskShadow          ; $90D6
  and #$E7                     ; $90D8
  jmp SetPpuMask               ; $90DA
Sub_B4_90DD:
  inc z:$85                    ; $90DD
  beq Sub_B4_90DD              ; $90DF
  jsr GetRandomByte            ; $90E1
  adc z:$85                    ; $90E4
  rts                          ; $90E6
  stx z:$86                    ; $90E7  [heuristic code]
  jsr Sub_B4_90DD              ; $90E9
  ldx z:$86                    ; $90EC
  adc z:$0A                    ; $90EE
  rts                          ; $90F0
Sub_B4_90F1:
  ldx #$1C                     ; $90F1
Loc_B4_90F3:
  lda $02E1,x                  ; $90F3
  cmp #$FE                     ; $90F6
  bne Loc_B4_90FF              ; $90F8
  lda #$F0                     ; $90FA
  sta $02E0,x                  ; $90FC
Loc_B4_90FF:
  dex                          ; $90FF
  dex                          ; $9100
  dex                          ; $9101
  dex                          ; $9102
  bpl Loc_B4_90F3              ; $9103
  rts                          ; $9105
Sub_B4_9106:
  ldy #$00                     ; $9106
  lda (Tmp00),y                ; $9108
  and #$3F                     ; $910A
  tax                          ; $910C
  lda Data_B4_911A,x           ; $910D
  ldy #$09                     ; $9110
  sta (Tmp00),y                ; $9112
  lda Data_B4_9146,x           ; $9114
  iny                          ; $9117
  sta (Tmp00),y                ; $9118
Data_B4_911A:
  rts                          ; $911A
  .incbin "prg_bank_4.bin", $111B, $2B  ; $911B
Data_B4_9146:
  .incbin "prg_bank_4.bin", $1146, $2D  ; $9146
Sub_B4_9173:
  ldx MazeIndex                ; $9173
  cpx #$12                     ; $9176
  bcc Loc_B4_9184              ; $9178
  lda #$00                     ; $917A
  sta z:MmcPrgShadow           ; $917C
  sta z:GameState              ; $917E
  sta $0503                    ; $9180
  rts                          ; $9183
Loc_B4_9184:
  lda Data_B4_91AD,x           ; $9184
  sta PlayerCellX              ; $9187
  lda Data_B4_91BF,x           ; $918A
  sta PlayerCellY              ; $918D
  lda Data_B4_91D1,x           ; $9190
  sta PlayerFacing             ; $9193
Sub_B4_9196:
  lda MazeIndex                ; $9196
  asl a                        ; $9199
  asl a                        ; $919A
  tax                          ; $919B
  ldy #$00                     ; $919C
Loc_B4_919E:
  lda Data_B4_91E3,x           ; $919E
  sta MazeMapPtrLo,y           ; $91A1
  inx                          ; $91A4
  iny                          ; $91A5
  cpy #$04                     ; $91A6
  bne Loc_B4_919E              ; $91A8
  jmp Sub_B4_95A1              ; $91AA
Data_B4_91AD:
  .incbin "prg_bank_4.bin", $11AD, $12  ; $91AD
Data_B4_91BF:
  .incbin "prg_bank_4.bin", $11BF, $12  ; $91BF
Data_B4_91D1:
  .incbin "prg_bank_4.bin", $11D1, $12  ; $91D1
Data_B4_91E3:
  .incbin "prg_bank_4.bin", $11E3, $3A0  ; $91E3
Sub_B4_9583:
  lda #$3F                     ; $9583
  sta SceneTimer               ; $9585
  ldx #$00                     ; $9588
  stx $0527                    ; $958A
  lda #$20                     ; $958D
  sta $0528                    ; $958F
  dex                          ; $9592
  stx $0549                    ; $9593
  lda #$0F                     ; $9596
  ldx #$20                     ; $9598
Loc_B4_959A:
  sta $0528,x                  ; $959A
  dex                          ; $959D
  bne Loc_B4_959A              ; $959E
  rts                          ; $95A0
Sub_B4_95A1:
  jsr Sub_B4_9583              ; $95A1
  ldx #$02                     ; $95A4
Loc_B4_95A6:
  lda Data_B4_9615,x           ; $95A6
  sta $0532,x                  ; $95A9
  sta $0542,x                  ; $95AC
  lda Data_B4_9618,x           ; $95AF
  sta $0536,x                  ; $95B2
  sta $0546,x                  ; $95B5
  dex                          ; $95B8
  bpl Loc_B4_95A6              ; $95B9
  ldy MazeIndex                ; $95BB
  ldx Data_B4_95F8,y           ; $95BE
  stx z:$87                    ; $95C1
  jsr Sub_B4_95E0              ; $95C3
  lda $0508                    ; $95C6
  beq Sub_B4_95DA              ; $95C9
  lda #$0F                     ; $95CB
  sta $0532                    ; $95CD
  lda #$00                     ; $95D0
  sta $0533                    ; $95D2
  lda #$10                     ; $95D5
  sta $0534                    ; $95D7
Sub_B4_95DA:
  lda #$05                     ; $95DA
  sta PpuOpRequest             ; $95DC
  rts                          ; $95DF
Sub_B4_95E0:
  lda Data_B4_960C,x           ; $95E0
  sta $052E                    ; $95E3
  and #$1F                     ; $95E6
  sta $052B                    ; $95E8
  sta $052F                    ; $95EB
  clc                          ; $95EE
  adc #$10                     ; $95EF
  sta AnimCounter              ; $95F1
  sta $0530                    ; $95F4
  rts                          ; $95F7
Data_B4_95F8:
  .incbin "prg_bank_4.bin", $15F8, $14  ; $95F8
Data_B4_960C:
  .incbin "prg_bank_4.bin", $160C, $9  ; $960C
Data_B4_9615:
  .incbin "prg_bank_4.bin", $1615, $3  ; $9615
Data_B4_9618:
  .incbin "prg_bank_4.bin", $1618, $3  ; $9618
Sub_B4_961B:
  lda ObjectCount              ; $961B
  beq Loc_B4_9632              ; $961E
  jsr AslA4                    ; $9620
  ldy #$00                     ; $9623
Loc_B4_9625:
  tax                          ; $9625
  tya                          ; $9626
  ora $030A,x                  ; $9627
  tay                          ; $962A
  txa                          ; $962B
  sec                          ; $962C
  sbc #$10                     ; $962D
  bne Loc_B4_9625              ; $962F
  tya                          ; $9631
Loc_B4_9632:
  sta z:$71                    ; $9632
  lda JoyNew1                  ; $9634
  bmi Loc_B4_9643              ; $9637
  asl a                        ; $9639
  bmi Loc_B4_965E              ; $963A
  asl a                        ; $963C
  bmi Loc_B4_9678              ; $963D
  asl a                        ; $963F
  bmi Loc_B4_9692              ; $9640
  rts                          ; $9642
Loc_B4_9643:
  bit z:$71                    ; $9643
  bvs Loc_B4_965D              ; $9645
  lda z:$6F                    ; $9647
  bne Loc_B4_965D              ; $9649
  lda PlayerFacing             ; $964B
  clc                          ; $964E
  adc #$01                     ; $964F
  and #$03                     ; $9651
  sta PlayerFacing             ; $9653
  ldx #$01                     ; $9656
  stx z:$7C                    ; $9658
  inx                          ; $965A
  stx z:$72                    ; $965B
Loc_B4_965D:
  rts                          ; $965D
Loc_B4_965E:
  bit z:$71                    ; $965E
  bvs Loc_B4_9677              ; $9660
  lda z:$6F                    ; $9662
  bne Loc_B4_9677              ; $9664
  lda PlayerFacing             ; $9666
  sec                          ; $9669
  sbc #$01                     ; $966A
  and #$03                     ; $966C
  sta PlayerFacing             ; $966E
  ldx #$01                     ; $9671
  stx z:$7C                    ; $9673
  stx z:$72                    ; $9675
Loc_B4_9677:
  rts                          ; $9677
Loc_B4_9678:
  lda z:$71                    ; $9678
  and #$20                     ; $967A
  bne Loc_B4_9691              ; $967C
  lda PlayerFacing             ; $967E
  clc                          ; $9681
  adc #$02                     ; $9682
  and #$03                     ; $9684
  sta PlayerFacing             ; $9686
  lda #$03                     ; $9689
  sta z:$72                    ; $968B
  lda #$01                     ; $968D
  sta z:$7C                    ; $968F
Loc_B4_9691:
  rts                          ; $9691
Loc_B4_9692:
  lda z:$71                    ; $9692
  bmi Loc_B4_96F6              ; $9694
  lda z:$6F                    ; $9696
  bne Loc_B4_96F6              ; $9698
  ldx z:$9B                    ; $969A
  beq Loc_B4_96A7              ; $969C
  dex                          ; $969E
  beq Loc_B4_96F6              ; $969F
  dex                          ; $96A1
  beq Loc_B4_96F7              ; $96A2
  jmp Sub_B4_9702              ; $96A4
Loc_B4_96A7:
  ldx PlayerFacing             ; $96A7
  beq Loc_B4_96C0              ; $96AA
  dex                          ; $96AC
  beq Loc_B4_96CE              ; $96AD
  dex                          ; $96AF
  beq Loc_B4_96DF              ; $96B0
  lda PlayerCellX              ; $96B2
  beq Loc_B4_96F6              ; $96B5
  sec                          ; $96B7
  sbc #$01                     ; $96B8
  sta PlayerCellX              ; $96BA
  jmp Loc_B4_96ED              ; $96BD
Loc_B4_96C0:
  lda PlayerCellY              ; $96C0
  beq Loc_B4_96F6              ; $96C3
  sec                          ; $96C5
  sbc #$01                     ; $96C6
  sta PlayerCellY              ; $96C8
  jmp Loc_B4_96ED              ; $96CB
Loc_B4_96CE:
  lda PlayerCellX              ; $96CE
  clc                          ; $96D1
  adc #$01                     ; $96D2
  cmp MazeWidth                ; $96D4
  beq Loc_B4_96F6              ; $96D7
  sta PlayerCellX              ; $96D9
  jmp Loc_B4_96ED              ; $96DC
Loc_B4_96DF:
  lda PlayerCellY              ; $96DF
  clc                          ; $96E2
  adc #$01                     ; $96E3
  cmp $0517                    ; $96E5
  beq Loc_B4_96F6              ; $96E8
  sta PlayerCellY              ; $96EA
Loc_B4_96ED:
  ldx #$00                     ; $96ED
  stx z:$72                    ; $96EF
  stx z:$84                    ; $96F1
  inx                          ; $96F3
  stx z:$7C                    ; $96F4
Loc_B4_96F6:
  rts                          ; $96F6
Loc_B4_96F7:
  lda z:$83                    ; $96F7
  and #$03                     ; $96F9
  beq Loc_B4_96F6              ; $96FB
  sta z:$81                    ; $96FD
  jmp Loc_B4_9768              ; $96FF
Sub_B4_9702:
  lda MazeIndex                ; $9702
  asl a                        ; $9705
  tay                          ; $9706
  lda Data_B4_9786,y           ; $9707
  sta z:$60                    ; $970A
  lda Data_B4_9787,y           ; $970C
  sta z:$61                    ; $970F
  lda Data_B4_97AA,y           ; $9711
  sta z:$62                    ; $9714
  lda Data_B4_97AB,y           ; $9716
  sta z:$63                    ; $9719
  lda Data_B4_97CE,y           ; $971B
  sta z:$64                    ; $971E
  lda Data_B4_97CF,y           ; $9720
  sta z:$65                    ; $9723
  lda PlayerCellX              ; $9725
  jsr AslA4                    ; $9728
  ora PlayerCellY              ; $972B
  sta z:$6A                    ; $972E
  ldy #$00                     ; $9730
Loc_B4_9732:
  lda ($60),y                  ; $9732
  cmp z:$6A                    ; $9734
  beq Loc_B4_9745              ; $9736
  bcs Loc_B4_973E              ; $9738
  iny                          ; $973A
  jmp Loc_B4_9732              ; $973B
Loc_B4_973E:
  ldy PlayerFacing             ; $973E
  iny                          ; $9741
  jmp Loc_B4_9753              ; $9742
Loc_B4_9745:
  lda ($62),y                  ; $9745
  cmp PlayerFacing             ; $9747
  beq Loc_B4_9750              ; $974A
  iny                          ; $974C
  jmp Loc_B4_9732              ; $974D
Loc_B4_9750:
  lda ($64),y                  ; $9750
  tay                          ; $9752
Loc_B4_9753:
  lda #$00                     ; $9753
  sta z:$84                    ; $9755
  sta z:$7E                    ; $9757
  sta z:$7F                    ; $9759
  tya                          ; $975B
  bpl Loc_B4_9763              ; $975C
  and #$7F                     ; $975E
  sta z:$82                    ; $9760
  rts                          ; $9762
Loc_B4_9763:
  sta z:$7D                    ; $9763
  jmp Loc_B4_85B0              ; $9765
Loc_B4_9768:
  ldx z:$82                    ; $9768
  lda Data_B4_9770,x           ; $976A
  sta z:$7C                    ; $976D
  rts                          ; $976F
Data_B4_9770:
  .incbin "prg_bank_4.bin", $1770, $16  ; $9770
Data_B4_9786:
  .incbin "prg_bank_4.bin", $1786, $1  ; $9786
Data_B4_9787:
  .incbin "prg_bank_4.bin", $1787, $23  ; $9787
Data_B4_97AA:
  .incbin "prg_bank_4.bin", $17AA, $1  ; $97AA
Data_B4_97AB:
  .incbin "prg_bank_4.bin", $17AB, $23  ; $97AB
Data_B4_97CE:
  .incbin "prg_bank_4.bin", $17CE, $1  ; $97CE
Data_B4_97CF:
  .incbin "prg_bank_4.bin", $17CF, $B1  ; $97CF
Sub_B4_9880:
  jsr Sub_B4_98A6              ; $9880
  jsr Sub_B4_98BB              ; $9883
  lda z:$8F                    ; $9886
  ldx #$00                     ; $9888
  jsr Sub_B4_990E              ; $988A
  lda z:$8F                    ; $988D
  clc                          ; $988F
  adc z:Tmp01                  ; $9890
  jsr Sub_B4_990E              ; $9892
  lda z:$8F                    ; $9895
  sec                          ; $9897
  sbc z:Tmp01                  ; $9898
  jsr Sub_B4_990E              ; $989A
  jsr Sub_B4_9924              ; $989D
  jsr Sub_B4_993A              ; $98A0
  jmp Loc_B4_996C              ; $98A3
Sub_B4_98A6:
  lda #$00                     ; $98A6
  ldx PlayerCellY              ; $98A8
  beq Loc_B4_98B4              ; $98AB
Loc_B4_98AD:
  clc                          ; $98AD
  adc MazeWidth                ; $98AE
  dex                          ; $98B1
  bne Loc_B4_98AD              ; $98B2
Loc_B4_98B4:
  clc                          ; $98B4
  adc PlayerCellX              ; $98B5
  sta z:$8F                    ; $98B8
  rts                          ; $98BA
Sub_B4_98BB:
  lda MazeWidth                ; $98BB
  ldx PlayerFacing             ; $98BE
  beq Loc_B4_98D3              ; $98C1
  dex                          ; $98C3
  beq Loc_B4_98E2              ; $98C4
  dex                          ; $98C6
  beq Loc_B4_98EF              ; $98C7
  sta z:Tmp01                  ; $98C9
  lda #$FF                     ; $98CB
  sta z:Tmp00                  ; $98CD
  ldx #$02                     ; $98CF
  bne Loc_B4_98F6              ; $98D1
Loc_B4_98D3:
  eor #$FF                     ; $98D3
  clc                          ; $98D5
  adc #$01                     ; $98D6
  sta z:Tmp00                  ; $98D8
  lda #$FF                     ; $98DA
  sta z:Tmp01                  ; $98DC
  ldx #$03                     ; $98DE
  bne Loc_B4_98F6              ; $98E0
Loc_B4_98E2:
  eor #$FF                     ; $98E2
  clc                          ; $98E4
  adc #$01                     ; $98E5
  sta z:Tmp01                  ; $98E7
  lda #$01                     ; $98E9
  sta z:Tmp00                  ; $98EB
  bne Loc_B4_98F6              ; $98ED
Loc_B4_98EF:
  sta z:Tmp00                  ; $98EF
  lda #$01                     ; $98F1
  sta z:Tmp01                  ; $98F3
  tax                          ; $98F5
Loc_B4_98F6:
  lda Data_B4_9908,x           ; $98F6
  sta z:$8C                    ; $98F9
  inx                          ; $98FB
  lda Data_B4_9908,x           ; $98FC
  sta z:$8D                    ; $98FF
  inx                          ; $9901
  lda Data_B4_9908,x           ; $9902
  sta z:$8E                    ; $9905
  rts                          ; $9907
Data_B4_9908:
  .incbin "prg_bank_4.bin", $1908, $6  ; $9908
Sub_B4_990E:
  sta z:$8F,x                  ; $990E
  inx                          ; $9910
  clc                          ; $9911
  adc z:Tmp00                  ; $9912
  sta z:$8F,x                  ; $9914
  inx                          ; $9916
  clc                          ; $9917
  adc z:Tmp00                  ; $9918
  sta z:$8F,x                  ; $991A
  inx                          ; $991C
  clc                          ; $991D
  adc z:Tmp00                  ; $991E
  sta z:$8F,x                  ; $9920
  inx                          ; $9922
  rts                          ; $9923
Sub_B4_9924:
  ldx #$0B                     ; $9924
  lda MazeMapPtrLo             ; $9926
  sta z:$60                    ; $9929
  lda MazeMapPtrHi             ; $992B
  sta z:$61                    ; $992E
Loc_B4_9930:
  ldy z:$8F,x                  ; $9930
  lda ($60),y                  ; $9932
  sta z:$8F,x                  ; $9934
  dex                          ; $9936
  bpl Loc_B4_9930              ; $9937
  rts                          ; $9939
Sub_B4_993A:
  ldx #$03                     ; $993A
Loc_B4_993C:
  lda z:$8F,x                  ; $993C
  ldy z:$8D                    ; $993E
  jsr Sub_B4_995B              ; $9940
  sta z:$9B,x                  ; $9943
  lda z:$8F,x                  ; $9945
  ldy z:$8C                    ; $9947
  jsr Sub_B4_995B              ; $9949
  sta z:$9F,x                  ; $994C
  lda z:$8F,x                  ; $994E
  ldy z:$8E                    ; $9950
  jsr Sub_B4_995B              ; $9952
  sta z:$A3,x                  ; $9955
  dex                          ; $9957
  bpl Loc_B4_993C              ; $9958
  rts                          ; $995A
Sub_B4_995B:
  beq Loc_B4_9969              ; $995B
  dey                          ; $995D
  beq Loc_B4_9967              ; $995E
  dey                          ; $9960
  beq Loc_B4_9965              ; $9961
  lsr a                        ; $9963
  lsr a                        ; $9964
Loc_B4_9965:
  lsr a                        ; $9965
  lsr a                        ; $9966
Loc_B4_9967:
  lsr a                        ; $9967
  lsr a                        ; $9968
Loc_B4_9969:
  and #$03                     ; $9969
  rts                          ; $996B
Loc_B4_996C:
  ldx #$07                     ; $996C
Loc_B4_996E:
  lda z:$93,x                  ; $996E
  ldy z:$8D                    ; $9970
  jsr Sub_B4_995B              ; $9972
  sta z:$A7,x                  ; $9975
  dex                          ; $9977
  bpl Loc_B4_996E              ; $9978
  rts                          ; $997A
Sub_B4_997B:
  jsr Sub_B4_998D              ; $997B
  jsr Sub_B4_9A44              ; $997E
  jsr Sub_B4_9A8B              ; $9981
  jsr Sub_B4_9F47              ; $9984
  jsr RunSoundDriver           ; $9987
  jmp RunSoundDriver           ; $998A
Sub_B4_998D:
  lda PPU_STATUS               ; $998D
  lda #$20                     ; $9990
  sta PPU_ADDR                 ; $9992
  ldy #$00                     ; $9995
  sty PPU_ADDR                 ; $9997
Loc_B4_999A:
  lda Data_B4_99C6,y           ; $999A
  beq Loc_B4_99C5              ; $999D
  bmi Loc_B4_99B1              ; $999F
  and #$7F                     ; $99A1
  tax                          ; $99A3
  iny                          ; $99A4
Loc_B4_99A5:
  lda Data_B4_99C6,y           ; $99A5
  iny                          ; $99A8
  sta PPU_DATA                 ; $99A9
  dex                          ; $99AC
  bne Loc_B4_99A5              ; $99AD
  beq Loc_B4_999A              ; $99AF
Loc_B4_99B1:
  and #$7F                     ; $99B1
  bne Loc_B4_99B7              ; $99B3
  lda #$80                     ; $99B5
Loc_B4_99B7:
  tax                          ; $99B7
  iny                          ; $99B8
  lda Data_B4_99C6,y           ; $99B9
  iny                          ; $99BC
Loc_B4_99BD:
  sta PPU_DATA                 ; $99BD
  dex                          ; $99C0
  bne Loc_B4_99BD              ; $99C1
  beq Loc_B4_999A              ; $99C3
Loc_B4_99C5:
  rts                          ; $99C5
Data_B4_99C6:
  .incbin "prg_bank_4.bin", $19C6, $7E  ; $99C6
Sub_B4_9A44:
  jsr ProcessPpuUpdateList     ; $9A44
  .addr Data_B4_9A4A  ; $9A47 inline pointer (data after a JSR)
  rts                          ; $9A49
Data_B4_9A4A:
  .incbin "prg_bank_4.bin", $1A4A, $41  ; $9A4A
Sub_B4_9A8B:
  ldy #$00                     ; $9A8B
  sty z:$6C                    ; $9A8D
Loc_B4_9A8F:
  lda Data_B4_9B11,y           ; $9A8F
  tax                          ; $9A92
  lda z:$9B,x                  ; $9A93
  beq Loc_B4_9AE6              ; $9A95
  sta z:$6A                    ; $9A97
  lda z:$6C                    ; $9A99
  asl a                        ; $9A9B
  tax                          ; $9A9C
  lda Data_B4_9B25,x           ; $9A9D
  sta $0523                    ; $9AA0
  lda Data_B4_9B26,x           ; $9AA3
  sta $0524                    ; $9AA6
  jsr $0520                    ; $9AA9
  lda z:$6A                    ; $9AAC
  cmp #$03                     ; $9AAE
  bne Loc_B4_9AE6              ; $9AB0
  lda z:$6C                    ; $9AB2
  asl a                        ; $9AB4
  tax                          ; $9AB5
  lda Data_B4_9B4D,x           ; $9AB6
  sta $0523                    ; $9AB9
  lda Data_B4_9B4E,x           ; $9ABC
  sta $0524                    ; $9ABF
  jsr $0520                    ; $9AC2
  ldy z:$6C                    ; $9AC5
  lda Data_B4_9B75,y           ; $9AC7
  bmi Loc_B4_9AE6              ; $9ACA
  sta z:$60                    ; $9ACC
  lda PlayerFacing             ; $9ACE
  and #$02                     ; $9AD1
  clc                          ; $9AD3
  adc z:$60                    ; $9AD4
  tax                          ; $9AD6
  lda Data_B4_9B89,x           ; $9AD7
  sta $0523                    ; $9ADA
  lda Data_B4_9B8A,x           ; $9ADD
  sta $0524                    ; $9AE0
  jsr $0520                    ; $9AE3
Loc_B4_9AE6:
  inc z:$6C                    ; $9AE6
  ldy z:$6C                    ; $9AE8
  cpy #$14                     ; $9AEA
  bcc Loc_B4_9A8F              ; $9AEC
  lda z:$9B                    ; $9AEE
  cmp #$03                     ; $9AF0
  bne Loc_B4_9B00              ; $9AF2
  lda PlayerFacing             ; $9AF4
  and #$02                     ; $9AF7
  bne Loc_B4_9B01              ; $9AF9
  jsr ProcessPpuUpdateList     ; $9AFB
  .addr Data_B4_9B0C  ; $9AFE inline pointer (data after a JSR)
Loc_B4_9B00:
  rts                          ; $9B00
Loc_B4_9B01:
  jsr ProcessPpuUpdateList     ; $9B01
  .addr Data_B4_9B07  ; $9B04 inline pointer (data after a JSR)
  rts                          ; $9B06
Data_B4_9B07:
  .incbin "prg_bank_4.bin", $1B07, $5  ; $9B07
Data_B4_9B0C:
  .incbin "prg_bank_4.bin", $1B0C, $5  ; $9B0C
Data_B4_9B11:
  .incbin "prg_bank_4.bin", $1B11, $14  ; $9B11
Data_B4_9B25:
  .incbin "prg_bank_4.bin", $1B25, $1  ; $9B25
Data_B4_9B26:
  .incbin "prg_bank_4.bin", $1B26, $27  ; $9B26
Data_B4_9B4D:
  .incbin "prg_bank_4.bin", $1B4D, $1  ; $9B4D
Data_B4_9B4E:
  .incbin "prg_bank_4.bin", $1B4E, $27  ; $9B4E
Data_B4_9B75:
  .incbin "prg_bank_4.bin", $1B75, $14  ; $9B75
Data_B4_9B89:
  .incbin "prg_bank_4.bin", $1B89, $1  ; $9B89
Data_B4_9B8A:
  .incbin "prg_bank_4.bin", $1B8A, $3A1  ; $9B8A
Data_B4_9F2B:
  .incbin "prg_bank_4.bin", $1F2B, $5  ; $9F2B
Data_B4_9F30:
  .incbin "prg_bank_4.bin", $1F30, $5  ; $9F30
Data_B4_9F35:
  .incbin "prg_bank_4.bin", $1F35, $9  ; $9F35
Data_B4_9F3E:
  .incbin "prg_bank_4.bin", $1F3E, $9  ; $9F3E
Sub_B4_9F47:
  lda z:$9B                    ; $9F47
  bne Loc_B4_9F93              ; $9F49
  lda z:$A7                    ; $9F4B
  bne Loc_B4_9F5C              ; $9F4D
  lda z:$9F                    ; $9F4F
  bne Loc_B4_9F5C              ; $9F51
  lda z:$A0                    ; $9F53
  beq Loc_B4_9F5C              ; $9F55
  jsr ProcessPpuUpdateList     ; $9F57
  .addr Data_B4_9F35  ; $9F5A inline pointer (data after a JSR)
Loc_B4_9F5C:
  lda z:$AB                    ; $9F5C
  bne Loc_B4_9F6D              ; $9F5E
  lda z:$A3                    ; $9F60
  bne Loc_B4_9F6D              ; $9F62
  lda z:$A4                    ; $9F64
  beq Loc_B4_9F6D              ; $9F66
  jsr ProcessPpuUpdateList     ; $9F68
  .addr Data_B4_9F3E  ; $9F6B inline pointer (data after a JSR)
Loc_B4_9F6D:
  lda z:$9C                    ; $9F6D
  bne Loc_B4_9F93              ; $9F6F
  lda z:$A8                    ; $9F71
  bne Loc_B4_9F82              ; $9F73
  lda z:$A0                    ; $9F75
  bne Loc_B4_9F82              ; $9F77
  lda z:$A1                    ; $9F79
  beq Loc_B4_9F82              ; $9F7B
  jsr ProcessPpuUpdateList     ; $9F7D
  .addr Data_B4_9F2B  ; $9F80 inline pointer (data after a JSR)
Loc_B4_9F82:
  lda z:$AC                    ; $9F82
  bne Loc_B4_9F93              ; $9F84
  lda z:$A4                    ; $9F86
  bne Loc_B4_9F93              ; $9F88
  lda z:$A5                    ; $9F8A
  beq Loc_B4_9F93              ; $9F8C
  jsr ProcessPpuUpdateList     ; $9F8E
  .addr Data_B4_9F30  ; $9F91 inline pointer (data after a JSR)
Loc_B4_9F93:
  rts                          ; $9F93
Sub_B4_9F94:
  ldx #$0A                     ; $9F94
Loc_B4_9F96:
  lda Data_B4_9FA1,x           ; $9F96
  sta z:Tmp00,x                ; $9F99
  dex                          ; $9F9B
  bpl Loc_B4_9F96              ; $9F9C
  jmp a:Tmp00                  ; $9F9E
Data_B4_9FA1:
  .incbin "prg_bank_4.bin", $1FA1, $B  ; $9FA1
Sub_B4_9FAC:
  lda $051F                    ; $9FAC
  and #$03                     ; $9FAF
  sta $051F                    ; $9FB1
  bne Loc_B4_9FB7              ; $9FB4
  rts                          ; $9FB6
Loc_B4_9FB7:
  tax                          ; $9FB7
  dex                          ; $9FB8
  beq Loc_B4_9FCE              ; $9FB9
  dex                          ; $9FBB
  beq Loc_B4_9FC6              ; $9FBC
  ldy #$46                     ; $9FBE
  jsr Sub_B4_9FEB              ; $9FC0
  jsr Sub_B4_908C              ; $9FC3
Loc_B4_9FC6:
  ldy #$44                     ; $9FC6
  jsr Sub_B4_9FEB              ; $9FC8
  jsr Sub_B4_908C              ; $9FCB
Loc_B4_9FCE:
  ldy #$42                     ; $9FCE
  jsr Sub_B4_9FEB              ; $9FD0
  jmp Sub_B4_908C              ; $9FD3
  lda $051F                    ; $9FD6  [heuristic code]
  and #$03                     ; $9FD9
  beq Loc_B4_9FEA              ; $9FDB
  tax                          ; $9FDD
  dex                          ; $9FDE
  ldy Data_B4_A001,x           ; $9FDF
  jsr Sub_B4_9FEB              ; $9FE2
  lda #$01                     ; $9FE5
  sta PpuOpRequest             ; $9FE7
Loc_B4_9FEA:
  rts                          ; $9FEA
Sub_B4_9FEB:
  ldx #$0A                     ; $9FEB
Loc_B4_9FED:
  lda Data_B4_A004,x           ; $9FED
  sta $054A,x                  ; $9FF0
  dex                          ; $9FF3
  bpl Loc_B4_9FED              ; $9FF4
  tya                          ; $9FF6
  sta $054B                    ; $9FF7
  clc                          ; $9FFA
  adc #$20                     ; $9FFB
  sta $0550                    ; $9FFD
  rts                          ; $A000
Data_B4_A001:
  .incbin "prg_bank_4.bin", $2001, $3  ; $A001
Data_B4_A004:
  .incbin "prg_bank_4.bin", $2004, $B  ; $A004
Loc_B4_A00F:
  lda $051F                    ; $A00F
  and #$03                     ; $A012
  cmp #$03                     ; $A014
  beq Loc_B4_A032              ; $A016
  tax                          ; $A018
  ldy Data_B4_A001,x           ; $A019
  jsr Sub_B4_9FEB              ; $A01C
  lda #$01                     ; $A01F
  sta PpuOpRequest             ; $A021
  lda #$00                     ; $A024
  sta $054D                    ; $A026
  sta $054E                    ; $A029
  sta $0552                    ; $A02C
  sta $0553                    ; $A02F
Loc_B4_A032:
  rts                          ; $A032
Sub_B4_A033:
  lda $050C                    ; $A033
  beq Loc_B4_A03E              ; $A036
  jsr Sub_B4_A065              ; $A038
  jsr $0520                    ; $A03B
Loc_B4_A03E:
  lda $050B                    ; $A03E
  beq Loc_B4_A049              ; $A041
  jsr Sub_B4_A080              ; $A043
  jsr $0520                    ; $A046
Loc_B4_A049:
  lda $050A                    ; $A049
  beq Loc_B4_A054              ; $A04C
  jsr Sub_B4_A09B              ; $A04E
  jsr $0520                    ; $A051
Loc_B4_A054:
  lda $0508                    ; $A054
  beq Loc_B4_A05F              ; $A057
  jsr Sub_B4_A0B6              ; $A059
  jsr $0520                    ; $A05C
Loc_B4_A05F:
  rts                          ; $A05F
  .incbin "prg_bank_4.bin", $2060, $5  ; $A060
Sub_B4_A065:
  lda #$70                     ; $A065
  sta $0523                    ; $A067
  lda #$A0                     ; $A06A
  sta $0524                    ; $A06C
  rts                          ; $A06F
  .incbin "prg_bank_4.bin", $2070, $10  ; $A070
Sub_B4_A080:
  lda #$8B                     ; $A080
  sta $0523                    ; $A082
  lda #$A0                     ; $A085
  sta $0524                    ; $A087
  rts                          ; $A08A
  .incbin "prg_bank_4.bin", $208B, $10  ; $A08B
Sub_B4_A09B:
  lda #$A6                     ; $A09B
  sta $0523                    ; $A09D
  lda #$A0                     ; $A0A0
  sta $0524                    ; $A0A2
  rts                          ; $A0A5
  .incbin "prg_bank_4.bin", $20A6, $10  ; $A0A6
Sub_B4_A0B6:
  lda #$C1                     ; $A0B6
  sta $0523                    ; $A0B8
  lda #$A0                     ; $A0BB
  sta $0524                    ; $A0BD
  rts                          ; $A0C0
  .incbin "prg_bank_4.bin", $20C1, $30  ; $A0C1
Sub_B4_A0F1:
  lda z:$9B                    ; $A0F1
  cmp #$02                     ; $A0F3
  beq Loc_B4_A0FC              ; $A0F5
  lda #$00                     ; $A0F7
  sta z:$83                    ; $A0F9
  rts                          ; $A0FB
Loc_B4_A0FC:
  jsr Sub_B4_9702              ; $A0FC
  ldx z:$82                    ; $A0FF
  lda Data_B4_A116,x           ; $A101
  sta z:$83                    ; $A104
  lsr a                        ; $A106
  bcc Loc_B4_A10C              ; $A107
  jsr Sub_B4_A12C              ; $A109
Loc_B4_A10C:
  lda z:$83                    ; $A10C
  and #$02                     ; $A10E
  beq Loc_B4_A115              ; $A110
  jmp Loc_B4_A15C              ; $A112
Loc_B4_A115:
  rts                          ; $A115
Data_B4_A116:
  .incbin "prg_bank_4.bin", $2116, $16  ; $A116
Sub_B4_A12C:
  jsr ProcessPpuUpdateList     ; $A12C
  .addr Data_B4_A13B  ; $A12F inline pointer (data after a JSR)
  jsr Sub_B4_8FBF              ; $A131
  lda #$D4                     ; $A134
  ldy #$00                     ; $A136
  sta (Tmp00),y                ; $A138
  rts                          ; $A13A
Data_B4_A13B:
  .incbin "prg_bank_4.bin", $213B, $21  ; $A13B
Loc_B4_A15C:
  jsr ProcessPpuUpdateList     ; $A15C
  .addr Data_B4_A16B  ; $A15F inline pointer (data after a JSR)
  jsr Sub_B4_8FBF              ; $A161
  lda #$D5                     ; $A164
  ldy #$00                     ; $A166
  sta (Tmp00),y                ; $A168
  rts                          ; $A16A
Data_B4_A16B:
  .incbin "prg_bank_4.bin", $216B, $C  ; $A16B
Sub_B4_A177:
  ldx #$0A                     ; $A177
Loc_B4_A179:
  lda Data_B4_A184,x           ; $A179
  sta z:Tmp00,x                ; $A17C
  dex                          ; $A17E
  bpl Loc_B4_A179              ; $A17F
  jmp a:Tmp00                  ; $A181
Data_B4_A184:
  .incbin "prg_bank_4.bin", $2184, $1CD  ; $A184
  tax                          ; $A351
  lsr a                        ; $A352
  bcc Loc_B4_A359              ; $A353
  cmp #$18                     ; $A355
  bcs Loc_B4_A35E              ; $A357
Loc_B4_A359:
  ldy #$02                     ; $A359
  jsr Sub_B4_8FD9              ; $A35B
Loc_B4_A35E:
  txa                          ; $A35E
  lsr a                        ; $A35F
  tax                          ; $A360
  lda Data_B4_A393,x           ; $A361
  bcc Loc_B4_A36A              ; $A364
  adc Data_B4_A394,x           ; $A366
  ror a                        ; $A369
Loc_B4_A36A:
  ldy #$01                     ; $A36A
  sta (Tmp00),y                ; $A36C
  txa                          ; $A36E
  lsr a                        ; $A36F
  lsr a                        ; $A370
  tax                          ; $A371
  lda Data_B4_A389,x           ; $A372
  jmp Sub_B4_8F85              ; $A375
  .incbin "prg_bank_4.bin", $2378, $11  ; $A378
Data_B4_A389:
  .incbin "prg_bank_4.bin", $2389, $A  ; $A389
Data_B4_A393:
  .incbin "prg_bank_4.bin", $2393, $1  ; $A393
Data_B4_A394:
  .incbin "prg_bank_4.bin", $2394, $FA  ; $A394
Data_B4_A48E:
  .incbin "prg_bank_4.bin", $248E, $16B  ; $A48E
  lda #$01                     ; $A5F9
  sta $054D                    ; $A5FB
  lda #$FF                     ; $A5FE
  sta $054E                    ; $A600
  lda #$01                     ; $A603
  sta PpuOpRequest             ; $A605
  jmp Sub_B4_8FCF              ; $A608
  ldy #$0B                     ; $A60B  [heuristic code]
  jsr Sub_B4_8FD1              ; $A60D
  cmp #$18                     ; $A610
  bcs Loc_B4_A62B              ; $A612
  lda $054B                    ; $A614
  clc                          ; $A617
  adc #$20                     ; $A618
  sta $054B                    ; $A61A
  lda $054A                    ; $A61D
  adc #$00                     ; $A620
  sta $054A                    ; $A622
  lda #$01                     ; $A625
  sta PpuOpRequest             ; $A627
  rts                          ; $A62A
Loc_B4_A62B:
  lda #$00                     ; $A62B
  sta (Tmp00),y                ; $A62D
  jmp Sub_B4_8FCF              ; $A62F
  .incbin "prg_bank_4.bin", $2632, $39A  ; $A632
  sta (Tmp00),y                ; $A9CC
  lda #$14                     ; $A9CE
  ldx #$05                     ; $A9D0
  jsr Sub_B4_B488              ; $A9D2
  lda #$04                     ; $A9D5
  jmp Sub_B4_8F85              ; $A9D7
  rts                          ; $A9DA  [heuristic code]
  ldy #$01                     ; $A9DB  [heuristic code]
  clc                          ; $A9DD
  adc (Tmp00),y                ; $A9DE
  sta (Tmp00),y                ; $A9E0
  rts                          ; $A9E2
  ldy #$08                     ; $A9E3  [heuristic code]
  lda (Tmp00),y                ; $A9E5
  bne Loc_B4_A9FB              ; $A9E7
  lda #$3C                     ; $A9E9
  ldy #$0B                     ; $A9EB
  sta (Tmp00),y                ; $A9ED
  jsr Sub_B4_9106              ; $A9EF
  lda z:$72                    ; $A9F2
  cmp #$03                     ; $A9F4
  bne Loc_B4_A9F8              ; $A9F6
Loc_B4_A9F8:
  jmp Sub_B4_8FCF              ; $A9F8
Loc_B4_A9FB:
  ldy #$0B                     ; $A9FB
  jsr Sub_B4_8FD1              ; $A9FD
  bne Loc_B4_AA10              ; $AA00
  lda #$80                     ; $AA02
  sta (Tmp00),y                ; $AA04
  lda #$0F                     ; $AA06
  jsr Sub_B4_B47A              ; $AA08
  ldy #$53                     ; $AA0B
  jmp Sub_B4_B43F              ; $AA0D
Loc_B4_AA10:
  rts                          ; $AA10
  .incbin "prg_bank_4.bin", $2A11, $11F  ; $AA11
  lda #$05                     ; $AB30
  jsr Sub_B4_8F85              ; $AB32
  jmp Sub_B4_8FCF              ; $AB35
  .incbin "prg_bank_4.bin", $2B38, $10A  ; $AB38
  sta (Tmp00),y                ; $AC42
  lda #$14                     ; $AC44
  ldy #$08                     ; $AC46
  sta (Tmp00),y                ; $AC48
  jsr Sub_B4_B42F              ; $AC4A
  lda #$FF                     ; $AC4D
  ldy #$0D                     ; $AC4F
  sta (Tmp00),y                ; $AC51
  lda #$00                     ; $AC53
  sta z:HwScrollY              ; $AC55
  sta z:HwScrollX              ; $AC57
  jsr Sub_B4_B011              ; $AC59
  lda #$06                     ; $AC5C
  jmp Sub_B4_8F85              ; $AC5E
  .incbin "prg_bank_4.bin", $2C61, $379  ; $AC61
Loc_B4_AFDA:
  inc z:$88                    ; $AFDA
  lda z:$88                    ; $AFDC
  lsr a                        ; $AFDE
  bcc Loc_B4_B010              ; $AFDF
  lsr a                        ; $AFE1
  bcs Loc_B4_B010              ; $AFE2
  and #$03                     ; $AFE4
  cmp #$03                     ; $AFE6
  beq Sub_B4_B011              ; $AFE8
  ldx #$05                     ; $AFEA
  stx PpuOpRequest             ; $AFEC
  asl a                        ; $AFEF
  asl a                        ; $AFF0
  tax                          ; $AFF1
  lda Data_B4_B020,x           ; $AFF2
  sta $052A                    ; $AFF5
  lda Data_B4_B021,x           ; $AFF8
  sta $052E                    ; $AFFB
  lda Data_B4_B022,x           ; $AFFE
  sta $052B                    ; $B001
  sta $052F                    ; $B004
  lda Data_B4_B023,x           ; $B007
  sta AnimCounter              ; $B00A
  sta $0530                    ; $B00D
Loc_B4_B010:
  rts                          ; $B010
Sub_B4_B011:
  ldx #$05                     ; $B011
  stx PpuOpRequest             ; $B013
  ldx #$0F                     ; $B016
  stx $052A                    ; $B018
  ldx z:$87                    ; $B01B
  jmp Sub_B4_95E0              ; $B01D
Data_B4_B020:
  .incbin "prg_bank_4.bin", $3020, $1  ; $B020
Data_B4_B021:
  .incbin "prg_bank_4.bin", $3021, $1  ; $B021
Data_B4_B022:
  .incbin "prg_bank_4.bin", $3022, $1  ; $B022
Data_B4_B023:
  .incbin "prg_bank_4.bin", $3023, $1F1  ; $B023
  lda (Tmp00),y                ; $B214
  and #$7F                     ; $B216
  sta (Tmp00),y                ; $B218
  lda #$30                     ; $B21A
  jsr Sub_B4_B3FF              ; $B21C
  jmp Loc_B4_B3C9              ; $B21F
  .incbin "prg_bank_4.bin", $3222, $22  ; $B222
Loc_B4_B244:
  lda #$D9                     ; $B244
  sta ObjectTable,x            ; $B246
  lda (Tmp00),y                ; $B249
  adc #$08                     ; $B24B
  sta $031B,x                  ; $B24D
  ldy #$02                     ; $B250
  lda (Tmp00),y                ; $B252
  sta $0312,x                  ; $B254
  jmp Sub_B4_8FCF              ; $B257
  .incbin "prg_bank_4.bin", $325A, $45  ; $B25A
  rts                          ; $B29F
  bvc *+66                     ; $B2A0  [heuristic code]
  bmi Loc_B4_B244              ; $B2A2
  php                          ; $B2A4
  lda (Tmp00),y                ; $B2A5
  cmp #$03                     ; $B2A7
Loc_B4_B2A9:
  bcs Loc_B4_B2A9              ; $B2A9
  asl a                        ; $B2AB
  tax                          ; $B2AC
  lda Data_B4_B2BA,x           ; $B2AD
  sta z:$6D                    ; $B2B0
  lda Data_B4_B2BB,x           ; $B2B2
  sta z:$6E                    ; $B2B5
  jmp ($006D)                  ; $B2B7
Data_B4_B2BA:
  .addr Sub_B4_B2C0, Sub_B4_B2D1, Sub_B4_B2E6  ; $B2BA pointer table
Sub_B4_B2C0:
  lda #$FF                     ; $B2C0
  ldy #$0B                     ; $B2C2
  sta (Tmp00),y                ; $B2C4
  lda #$0D                     ; $B2C6
  jsr Sub_B4_B47A              ; $B2C8
  jsr Sub_B4_9106              ; $B2CB
  jmp Sub_B4_8FCF              ; $B2CE
Sub_B4_B2D1:
  ldy #$0B                     ; $B2D1
  jsr Sub_B4_8FD1              ; $B2D3
  bne Loc_B4_B2D9              ; $B2D6
  rts                          ; $B2D8
Loc_B4_B2D9:
  cmp #$0A                     ; $B2D9
  bcc Sub_B4_B2E6              ; $B2DB
  lda #$00                     ; $B2DD
  ldy #$0A                     ; $B2DF
  sta (Tmp00),y                ; $B2E1
  jsr Sub_B4_8FCF              ; $B2E3
Sub_B4_B2E6:
  ldy #$0B                     ; $B2E6
  jsr Sub_B4_8FD1              ; $B2E8
  and #$0F                     ; $B2EB
  bne Loc_B4_B2F4              ; $B2ED
  lda #$07                     ; $B2EF
  jsr Sub_B4_B47A              ; $B2F1
Loc_B4_B2F4:
  jmp Loc_B4_AFDA              ; $B2F4
  ldy #$08                     ; $B2F7  [heuristic code]
  lda (Tmp00),y                ; $B2F9
  bne Loc_B4_B31C              ; $B2FB
  lda #$01                     ; $B2FD
  sta (Tmp00),y                ; $B2FF
  lda $0508                    ; $B301
  ora $050A                    ; $B304
  bne Loc_B4_B311              ; $B307
  ldy #$00                     ; $B309
  lda (Tmp00),y                ; $B30B
  and #$7F                     ; $B30D
  sta (Tmp00),y                ; $B30F
Loc_B4_B311:
  lda #$A3                     ; $B311
  ldy #$01                     ; $B313
  sta (Tmp00),y                ; $B315
  lda #$01                     ; $B317
  jmp Sub_B4_8F85              ; $B319
Loc_B4_B31C:
  ldy #$0B                     ; $B31C
  jsr Sub_B4_8FD9              ; $B31E
  beq Loc_B4_B328              ; $B321
  and #$01                     ; $B323
  jmp Sub_B4_8F85              ; $B325
Loc_B4_B328:
  jmp RemoveObject             ; $B328
  .incbin "prg_bank_4.bin", $332B, $5E  ; $B32B
Loc_B4_B389:
  rts                          ; $B389
  .incbin "prg_bank_4.bin", $338A, $3F  ; $B38A
Loc_B4_B3C9:
  lda #$00                     ; $B3C9
  jsr Sub_B4_8F85              ; $B3CB
  jsr Sub_B4_9106              ; $B3CE
  jmp Sub_B4_8FCF              ; $B3D1
Data_B4_B3D4:
  sei                          ; $B3D4  [heuristic code]
  rti                          ; $B3D5
  sei                          ; $B3D6  [heuristic code]
  bcs Loc_B4_B389              ; $B3D7
  rti                          ; $B3D9
  bcs Loc_B4_B41C              ; $B3DA  [heuristic code]
  jsr Sub_B4_90DD              ; $B3DC
  and #$07                     ; $B3DF
  tay                          ; $B3E1
  sty z:$60                    ; $B3E2
  ldx Data_B4_B3D4,y           ; $B3E4
  lda #$68                     ; $B3E7
  jsr Sub_B4_B3F9              ; $B3E9
  ldx z:$60                    ; $B3EC
  rts                          ; $B3EE
  .incbin "prg_bank_4.bin", $33EF, $A  ; $B3EF
Sub_B4_B3F9:
  jsr Sub_B4_B3FF              ; $B3F9
  txa                          ; $B3FC
  iny                          ; $B3FD
  bit $01A0                    ; $B3FE
  sta (Tmp00),y                ; $B401
  rts                          ; $B403
  .incbin "prg_bank_4.bin", $3404, $18  ; $B404
Loc_B4_B41C:
  .incbin "prg_bank_4.bin", $341C, $13  ; $B41C
Sub_B4_B42F:
  ldy #$0A                     ; $B42F
  lda (Tmp00),y                ; $B431
  ora #$E0                     ; $B433
  sta (Tmp00),y                ; $B435
  rts                          ; $B437
  .incbin "prg_bank_4.bin", $3438, $7  ; $B438
Sub_B4_B43F:
  lda ObjectCount              ; $B43F
  cmp #$0F                     ; $B442
  bcs Loc_B4_B451              ; $B444
  inc ObjectCount              ; $B446
  jsr AslA4                    ; $B449
  tax                          ; $B44C
  tya                          ; $B44D
  sta ObjectTable,x            ; $B44E
Loc_B4_B451:
  rts                          ; $B451
  ldx #$02                     ; $B452  [heuristic code]
  ldy #$02                     ; $B454
  lda (Tmp00),y                ; $B456
  cmp #$78                     ; $B458
  beq Loc_B4_B460              ; $B45A
  bcc Loc_B4_B461              ; $B45C
  dex                          ; $B45E
  dex                          ; $B45F
Loc_B4_B460:
  dex                          ; $B460
Loc_B4_B461:
  txa                          ; $B461
  ldy #$0C                     ; $B462
  sta (Tmp00),y                ; $B464
  rts                          ; $B466
  lda #$00                     ; $B467  [heuristic code]
  sta z:HwScrollX              ; $B469
  sta z:HwScrollY              ; $B46B
  ldy #$0B                     ; $B46D
  sta (Tmp00),y                ; $B46F
  lda #$FF                     ; $B471
  ldy #$0D                     ; $B473
  sta (Tmp00),y                ; $B475
  inc z:$84                    ; $B477
  rts                          ; $B479
Sub_B4_B47A:
  sta z:$6A                    ; $B47A
  lda z:PlayerLifeLo           ; $B47C
  sec                          ; $B47E
  sbc z:$6A                    ; $B47F
  sta z:PlayerLifeLo           ; $B481
  bcs Loc_B4_B487              ; $B483
  dec z:PlayerLifeHi           ; $B485
Loc_B4_B487:
  rts                          ; $B487
Sub_B4_B488:
  clc                          ; $B488
  adc z:PlayerLifeLo           ; $B489
  bcs Loc_B4_B491              ; $B48B
  cmp #$C8                     ; $B48D
  bcc Loc_B4_B493              ; $B48F
Loc_B4_B491:
  lda #$C8                     ; $B491
Loc_B4_B493:
  sta z:PlayerLifeLo           ; $B493
  txa                          ; $B495
  ldx z:AmmoHi                 ; $B496
  clc                          ; $B498
  adc z:AmmoLo                 ; $B499
  bcc Loc_B4_B49E              ; $B49B
  inx                          ; $B49D
Loc_B4_B49E:
  cpx #$01                     ; $B49E
  bcc Loc_B4_B4AC              ; $B4A0
  bne Loc_B4_B4A8              ; $B4A2
  cmp #$90                     ; $B4A4
  bcc Loc_B4_B4AC              ; $B4A6
Loc_B4_B4A8:
  ldx #$01                     ; $B4A8
  lda #$90                     ; $B4AA
Loc_B4_B4AC:
  stx z:AmmoHi                 ; $B4AC
  sta z:AmmoLo                 ; $B4AE
  rts                          ; $B4B0
Sub_B4_B4B1:
  jsr Sub_B4_B4EF              ; $B4B1
  beq Loc_B4_B4EE              ; $B4B4
Loc_B4_B4B6:
  jsr Sub_B4_B4F8              ; $B4B6
  dec $0302                    ; $B4B9
  bne Loc_B4_B4B6              ; $B4BC
  ldy #$06                     ; $B4BE
  lda Data_C347,y              ; $B4C0
  sta z:Tmp02                  ; $B4C3
  jsr Sub_B4_B4EF              ; $B4C5
  beq Loc_B4_B4EE              ; $B4C8
Loc_B4_B4CA:
  ldx #$00                     ; $B4CA
  lda $0302                    ; $B4CC
  jsr AslA4                    ; $B4CF
  tay                          ; $B4D2
  lda $0300,y                  ; $B4D3
  bpl Loc_B4_B4E5              ; $B4D6
  lda $0304,y                  ; $B4D8
  asl a                        ; $B4DB
  asl a                        ; $B4DC
  adc z:Tmp02                  ; $B4DD
  bcs Loc_B4_B4E5              ; $B4DF
  ldx z:Tmp02                  ; $B4E1
  sta z:Tmp02                  ; $B4E3
Loc_B4_B4E5:
  txa                          ; $B4E5
  sta $0303,y                  ; $B4E6
  dec $0302                    ; $B4E9
  bne Loc_B4_B4CA              ; $B4EC
Loc_B4_B4EE:
  rts                          ; $B4EE
Sub_B4_B4EF:
  lda ObjectCount              ; $B4EF
  and #$0F                     ; $B4F2
  sta $0302                    ; $B4F4
  rts                          ; $B4F7
Sub_B4_B4F8:
  lda $0302                    ; $B4F8
  jsr AslA4                    ; $B4FB
  tay                          ; $B4FE
  sta z:Tmp00                  ; $B4FF
  lda #$03                     ; $B501
  sta z:Tmp01                  ; $B503
  lda $0300,y                  ; $B505
  and #$3F                     ; $B508
  cmp #$2D                     ; $B50A
Loc_B4_B50C:
  bcs Loc_B4_B50C              ; $B50C
  asl a                        ; $B50E
  tax                          ; $B50F
  lda Data_B4_B51D,x           ; $B510
  sta z:Tmp02                  ; $B513
  lda Data_B4_B51E,x           ; $B515
  sta z:Tmp03                  ; $B518
  jmp ($0002)                  ; $B51A
Data_B4_B51D:
  .incbin "prg_bank_4.bin", $351D, $1  ; $B51D
Data_B4_B51E:
  .incbin "prg_bank_4.bin", $351E, $62  ; $B51E
Data_B4_B580:
  .incbin "prg_bank_4.bin", $3580, $1  ; $B580
Data_B4_B581:
  .incbin "prg_bank_4.bin", $3581, $400  ; $B581
  .incbin "prg_bank_4.bin", $3981, $400  ; $B981
  .incbin "prg_bank_4.bin", $3D81, $27C  ; $BD81
Data_B4_BFFD:
  .incbin "prg_bank_4.bin", $3FFD, $3  ; $BFFD
