; Bank 4  ($8000-$BFFF switchable)
; Per-frame scene code at $8010 (scene not identified yet).
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
  jsr Sub_B4_9049              ; $8028
  lda z:PpuMaskShadow          ; $802B
  sta PPU_MASK                 ; $802D
  jsr ApplyScroll              ; $8030
  jsr Sub_B4_80B3              ; $8033
  jsr Sub_B4_8BFB              ; $8036
  inc z:FrameCounter           ; $8039
  jsr DrawHud                  ; $803B
  jsr Sub_B4_90D9              ; $803E
  lda z:MmcPrgShadow           ; $8041
  pha                          ; $8043
  lda #$04                     ; $8044
  sta z:MmcPrgShadow           ; $8046
  jsr CallBank5_A000           ; $8048
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
  asl a                        ; $80B6
  tax                          ; $80B7
  lda Data_B4_80C5,x           ; $80B8
  sta z:$6D                    ; $80BB
  lda Data_B4_80C6,x           ; $80BD
  sta z:$6E                    ; $80C0
  jmp ($006D)                  ; $80C2
Data_B4_80C5:
  .addr Sub_B4_8107, Sub_B4_811D, Sub_B4_8128, Sub_B4_8112, Sub_B4_8133, Sub_B4_8139, Sub_B4_8165, Sub_B4_8177, Sub_B4_8188, Sub_B4_81C1, Sub_B4_81CC, Sub_B4_81F5, Sub_B4_8233, Sub_B4_8239, Sub_B4_8260, Sub_B4_8264, Sub_B4_826D, Sub_B4_8284, Sub_B4_828A, Sub_B4_830E, Sub_B4_8314, Sub_B4_8326, Sub_B4_833D, Sub_B4_8361, Sub_B4_8367, Sub_B4_838D, Sub_B4_8393, Sub_B4_8399, Sub_B4_83B6, Sub_B4_83BC, Sub_B4_83DF, Sub_B4_841D, Sub_B4_8441  ; $80C5 pointer table
Sub_B4_8107:
  lda #$00                     ; $8107
  sta $050A                    ; $8109
  sta $050B                    ; $810C
  sta $050C                    ; $810F
Sub_B4_8112:
  lda #$04                     ; $8112
  sta SceneState               ; $8114
  jsr Sub_B4_84F5              ; $8117
  jmp Loc_B4_8496              ; $811A
Sub_B4_811D:
  lda #$1C                     ; $811D
  sta SceneState               ; $811F
  jsr Sub_B4_84FF              ; $8122
  jmp Loc_B4_8496              ; $8125
Sub_B4_8128:
  lda #$1E                     ; $8128
  sta SceneState               ; $812A
  jsr Sub_B4_84FF              ; $812D
  jmp Loc_B4_8496              ; $8130
Sub_B4_8133:
  inc SceneState               ; $8133
  jmp Sub_B4_90BE              ; $8136
Sub_B4_8139:
  inc SceneState               ; $8139
  jsr FillPaletteBlack         ; $813C
  jsr Sub_B4_846E              ; $813F
  lda #$03                     ; $8142
  sta $051F                    ; $8144
  jsr Sub_B4_909E              ; $8147
  jsr Sub_B4_915B              ; $814A
  jsr Sub_B4_8546              ; $814D
  jsr Sub_B4_9868              ; $8150
  jsr Sub_B4_9963              ; $8153
  jsr Sub_B4_9F94              ; $8156
  jsr Sub_B4_A01B              ; $8159
  jsr Sub_B4_A0D9              ; $815C
  jsr Sub_B4_9006              ; $815F
  jmp ApplyScroll              ; $8162
Sub_B4_8165:
  inc SceneState               ; $8165
  jsr Sub_B4_B474              ; $8168
  jsr Sub_B4_B474              ; $816B
  jsr DrawObjects              ; $816E
  jsr Sub_B4_9049              ; $8171
  jmp ApplyScroll              ; $8174
Sub_B4_8177:
  inc SceneState               ; $8177
  jsr Sub_B4_95C2              ; $817A
  lda #$00                     ; $817D
  sta z:$7C                    ; $817F
  lda #$11                     ; $8181
  sta z:$8A                    ; $8183
  jmp Loc_B4_90B7              ; $8185
Sub_B4_8188:
  lda PPU_STATUS               ; $8188
  jsr ReadJoypads              ; $818B
  jsr Sub_B4_8D25              ; $818E
  jsr Sub_B4_B474              ; $8191
  jsr DrawObjects              ; $8194
  jsr Sub_B4_9603              ; $8197
  ldx z:$7C                    ; $819A
  lda Data_B4_81B8,x           ; $819C
  sta SceneState               ; $819F
  lda z:PlayerLifeHi           ; $81A2
  bne Loc_B4_81AC              ; $81A4
  lda z:PlayerLifeLo           ; $81A6
  cmp #$C9                     ; $81A8
  bcc Loc_B4_81B7              ; $81AA
Loc_B4_81AC:
  lda #$00                     ; $81AC
  sta z:PlayerLifeLo           ; $81AE
  sta z:PlayerLifeHi           ; $81B0
  lda #$1F                     ; $81B2
  sta SceneState               ; $81B4
Loc_B4_81B7:
  rts                          ; $81B7
Data_B4_81B8:
  .incbin "prg_bank_4.bin", $01B8, $9  ; $81B8
Sub_B4_81C1:
  lda #$45                     ; $81C1
  jsr EnqueueByte              ; $81C3
  jsr Sub_B4_AFE8              ; $81C6
  jmp Loc_B4_8509              ; $81C9
Sub_B4_81CC:
  inc SceneState               ; $81CC
  jsr Sub_B4_90BE              ; $81CF
  lda $0501                    ; $81D2
  cmp #$0C                     ; $81D5
  bne Loc_B4_81E7              ; $81D7
  lda $0519                    ; $81D9
  cmp #$02                     ; $81DC
  bne Loc_B4_81E7              ; $81DE
  lda $051A                    ; $81E0
  cmp #$01                     ; $81E3
  beq Loc_B4_81EA              ; $81E5
Loc_B4_81E7:
  jmp Loc_B4_8D1B              ; $81E7
Loc_B4_81EA:
  lda #$00                     ; $81EA
  ldx #$14                     ; $81EC
  tay                          ; $81EE
  jsr Sub_B4_8BC9              ; $81EF
  jmp Loc_B4_82FE              ; $81F2
Sub_B4_81F5:
  lda #$06                     ; $81F5
  sta SceneState               ; $81F7
  jsr FillPaletteBlack         ; $81FA
  jsr Sub_B4_846E              ; $81FD
  jsr Sub_B4_9589              ; $8200
  lda z:PpuCtrlShadow          ; $8203
  and #$FC                     ; $8205
  sta z:PpuCtrlShadow          ; $8207
  lda #$00                     ; $8209
  sta z:$7C                    ; $820B
  sta z:HwScrollX              ; $820D
  sta z:HwScrollY              ; $820F
  sta z:$88                    ; $8211
  sta z:$89                    ; $8213
  jsr Sub_B4_8B2D              ; $8215
  jsr Sub_B4_8546              ; $8218
  jsr Sub_B4_9868              ; $821B
  jsr Sub_B4_9963              ; $821E
  jsr Sub_B4_9F94              ; $8221
  jsr Sub_B4_A01B              ; $8224
  jsr Sub_B4_A0D9              ; $8227
  jsr Sub_B4_9006              ; $822A
  jsr ApplyScroll              ; $822D
  jmp Loc_B4_8AD3              ; $8230
Sub_B4_8233:
  inc SceneState               ; $8233
  jmp Sub_B4_90BE              ; $8236
Sub_B4_8239:
  inc SceneState               ; $8239
  jsr FillPaletteBlack         ; $823C
  jsr Sub_B4_846E              ; $823F
  jsr Sub_B4_8546              ; $8242
  jsr Sub_B4_9F7C              ; $8245
  lda #$00                     ; $8248
  sta z:HwScrollX              ; $824A
  sta z:HwScrollY              ; $824C
  jsr ApplyScroll              ; $824E
  lda z:PpuCtrlShadow          ; $8251
  ora #$02                     ; $8253
  sta z:PpuCtrlShadow          ; $8255
  jsr Sub_B4_86D1              ; $8257
  jsr Sub_B4_9589              ; $825A
  jmp DrawObjects              ; $825D
Sub_B4_8260:
  inc SceneState               ; $8260
  rts                          ; $8263
Sub_B4_8264:
  inc SceneState               ; $8264
  jsr Sub_B4_95C2              ; $8267
  jmp Loc_B4_90B7              ; $826A
Sub_B4_826D:
  jsr ReadJoypads              ; $826D
  lda JoyNew1                  ; $8270
  lsr a                        ; $8273
  bcc Loc_B4_827A              ; $8274
  inc SceneState               ; $8276
  rts                          ; $8279
Loc_B4_827A:
  and #$10                     ; $827A
  beq Loc_B4_8283              ; $827C
  lda #$1B                     ; $827E
  sta SceneState               ; $8280
Loc_B4_8283:
  rts                          ; $8283
Sub_B4_8284:
  inc SceneState               ; $8284
  jmp Sub_B4_90BE              ; $8287
Sub_B4_828A:
  lda z:PpuCtrlShadow          ; $828A
  and #$FD                     ; $828C
  sta z:PpuCtrlShadow          ; $828E
  lda z:$7C                    ; $8290
  asl a                        ; $8292
  tax                          ; $8293
  lda Data_B4_82A1,x           ; $8294
  sta z:$6D                    ; $8297
  lda Data_B4_82A2,x           ; $8299
  sta z:$6E                    ; $829C
  jmp ($006D)                  ; $829E
Data_B4_82A1:
  .incbin "prg_bank_4.bin", $02A1, $1  ; $82A1
Data_B4_82A2:
  .incbin "prg_bank_4.bin", $02A2, $5C  ; $82A2
Loc_B4_82FE:
  lda #$00                     ; $82FE
  sta z:MmcPrgShadow           ; $8300
  sta z:GameState              ; $8302
  rts                          ; $8304
  .incbin "prg_bank_4.bin", $0305, $9  ; $8305
Sub_B4_830E:
  inc SceneState               ; $830E
  jmp Sub_B4_90BE              ; $8311
Sub_B4_8314:
  inc SceneState               ; $8314
  jsr FillPaletteBlack         ; $8317
  jsr Sub_B4_846E              ; $831A
  jsr Sub_B4_A15F              ; $831D
  jsr ApplyScroll              ; $8320
  jmp Sub_B4_86D1              ; $8323
Sub_B4_8326:
  inc SceneState               ; $8326
  lda $052E                    ; $8329
  ldx z:$81                    ; $832C
  cpx #$01                     ; $832E
  bne Loc_B4_8334              ; $8330
  and #$0F                     ; $8332
Loc_B4_8334:
  sta $052A                    ; $8334
  jsr Sub_B4_95C2              ; $8337
  jmp Loc_B4_90B7              ; $833A
Sub_B4_833D:
  jsr ReadJoypads              ; $833D
  lda JoyNew1                  ; $8340
  lsr a                        ; $8343
  bcc Loc_B4_8355              ; $8344
  lda z:$7C                    ; $8346
  sec                          ; $8348
  sbc #$05                     ; $8349
  and #$01                     ; $834B
  tax                          ; $834D
  lda Data_B4_835F,x           ; $834E
  sta SceneState               ; $8351
  rts                          ; $8354
Loc_B4_8355:
  and #$10                     ; $8355
  beq Loc_B4_835E              ; $8357
  lda #$1B                     ; $8359
  sta SceneState               ; $835B
Loc_B4_835E:
  rts                          ; $835E
Data_B4_835F:
  .incbin "prg_bank_4.bin", $035F, $2  ; $835F
Sub_B4_8361:
  inc SceneState               ; $8361
  jmp Sub_B4_90BE              ; $8364
Sub_B4_8367:
  lda #$06                     ; $8367
  sta SceneState               ; $8369
  jsr FillPaletteBlack         ; $836C
  jsr Sub_B4_846E              ; $836F
  jsr Sub_B4_8C18              ; $8372
  jsr Sub_B4_8546              ; $8375
  jsr Sub_B4_9868              ; $8378
  jsr Sub_B4_9963              ; $837B
  jsr Sub_B4_9F94              ; $837E
  jsr Sub_B4_A01B              ; $8381
  jsr Sub_B4_A0D9              ; $8384
  jsr Sub_B4_9006              ; $8387
  jmp ApplyScroll              ; $838A
Sub_B4_838D:
  inc SceneState               ; $838D
  jmp Sub_B4_90BE              ; $8390
Sub_B4_8393:
  jsr Sub_B4_8C18              ; $8393
  jmp Loc_B4_82FE              ; $8396
Sub_B4_8399:
  lda #$06                     ; $8399
  sta SceneState               ; $839B
  jsr Sub_B4_90BE              ; $839E
  lda #$0F                     ; $83A1
  sta $052A                    ; $83A3
  jsr Sub_B4_846E              ; $83A6
  jsr Sub_B4_8546              ; $83A9
  jsr Sub_B4_A0D9              ; $83AC
  lda z:PpuCtrlShadow          ; $83AF
  and #$FD                     ; $83B1
  sta z:PpuCtrlShadow          ; $83B3
  rts                          ; $83B5
Sub_B4_83B6:
  inc SceneState               ; $83B6
  jmp Sub_B4_90BE              ; $83B9
Sub_B4_83BC:
  lda #$06                     ; $83BC
  sta SceneState               ; $83BE
  jsr FillPaletteBlack         ; $83C1
  jsr Sub_B4_846E              ; $83C4
  jsr Sub_B4_8546              ; $83C7
  jsr Sub_B4_9868              ; $83CA
  jsr Sub_B4_9963              ; $83CD
  jsr Sub_B4_9F94              ; $83D0
  jsr Sub_B4_A01B              ; $83D3
  jsr Sub_B4_A0D9              ; $83D6
  jsr Sub_B4_9006              ; $83D9
  jmp ApplyScroll              ; $83DC
Sub_B4_83DF:
  lda #$06                     ; $83DF
  sta SceneState               ; $83E1
  jsr FillPaletteBlack         ; $83E4
  jsr Sub_B4_846E              ; $83E7
  jsr Sub_B4_8546              ; $83EA
  lda $0510                    ; $83ED
  sta $0501                    ; $83F0
  lda $0511                    ; $83F3
  sta $0518                    ; $83F6
  lda $0512                    ; $83F9
  sta $0519                    ; $83FC
  lda $0513                    ; $83FF
  sta $051A                    ; $8402
  jsr Sub_B4_917E              ; $8405
  jsr Sub_B4_9868              ; $8408
  jsr Sub_B4_9963              ; $840B
  jsr Sub_B4_9F94              ; $840E
  jsr Sub_B4_A01B              ; $8411
  jsr Sub_B4_A0D9              ; $8414
  jsr Sub_B4_9006              ; $8417
  jmp ApplyScroll              ; $841A
Sub_B4_841D:
  inc SceneState               ; $841D
  lda #$78                     ; $8420
  sta $058F                    ; $8422
  lda #$05                     ; $8425
  sta $0502                    ; $8427
  ldx #$06                     ; $842A
Loc_B4_842C:
  lda Data_B4_843A,x           ; $842C
  sta $052A,x                  ; $842F
  dex                          ; $8432
  bpl Loc_B4_842C              ; $8433
  lda #$45                     ; $8435
  jmp EnqueueByte              ; $8437
Data_B4_843A:
  .incbin "prg_bank_4.bin", $043A, $7  ; $843A
Sub_B4_8441:
  dec $058F                    ; $8441
  bne Loc_B4_845B              ; $8444
  lda #$05                     ; $8446
  sta z:MmcPrgShadow           ; $8448
  lda #$03                     ; $844A
  sta SceneState               ; $844C
  ldy $0501                    ; $844F
  lda Data_B4_845C,y           ; $8452
  sta $013F                    ; $8455
  jmp Sub_B4_90BE              ; $8458
Loc_B4_845B:
  rts                          ; $845B
Data_B4_845C:
  .incbin "prg_bank_4.bin", $045C, $12  ; $845C
Sub_B4_846E:
  ldx Data_C34D                ; $846E
  bne Loc_B4_8475              ; $8471
Sub_B4_8473:
  ldx #$00                     ; $8473
Loc_B4_8475:
  lda #$F0                     ; $8475
Loc_B4_8477:
  sta OamBuffer,x              ; $8477
  inx                          ; $847A
  inx                          ; $847B
  inx                          ; $847C
  inx                          ; $847D
  bne Loc_B4_8477              ; $847E
  rts                          ; $8480
Sub_B4_8481:
  lda #$BE                     ; $8481
  sta OamBuffer                ; $8483
  lda #$FE                     ; $8486
  sta $0201                    ; $8488
  lda #$20                     ; $848B
  sta $0202                    ; $848D
  lda #$D0                     ; $8490
  sta $0203                    ; $8492
  rts                          ; $8495
Loc_B4_8496:
  lda #$20                     ; $8496
  sta z:GameState              ; $8498
  lda #$03                     ; $849A
  sta $0300                    ; $849C
  lda #$23                     ; $849F
  sta z:$80                    ; $84A1
  lda #$00                     ; $84A3
  sta z:HwScrollX              ; $84A5
  sta z:HwScrollY              ; $84A7
  sta $0503                    ; $84A9
  sta $0504                    ; $84AC
  lda #$00                     ; $84AF
  sta APU_DMC_FREQ             ; $84B1
  sta APU_DMC_RAW              ; $84B4
  lda #$0F                     ; $84B7
  sta APU_SND_CHN              ; $84B9
  lda #$C0                     ; $84BC
  sta JOYPAD2                  ; $84BE
  lda #$00                     ; $84C1
  jsr EnqueueByte              ; $84C3
  lda #$08                     ; $84C6
  jsr EnqueueByte              ; $84C8
  jsr Sub_B4_86D1              ; $84CB
  jsr Sub_B4_8473              ; $84CE
  jsr Sub_B4_8481              ; $84D1
  ldx #$1F                     ; $84D4
  stx z:MmcControlShadow       ; $84D6
  jsr MmcWriteControl          ; $84D8
  ldx #$0C                     ; $84DB
  stx z:MmcChr0Shadow          ; $84DD
  jsr MmcWriteChr0             ; $84DF
  ldx #$0B                     ; $84E2
  stx z:MmcChr1Shadow          ; $84E4
  jsr MmcWriteChr1             ; $84E6
  lda #$06                     ; $84E9
  jsr SetPpuMask               ; $84EB
  lda #$30                     ; $84EE
  sta z:PpuCtrlShadow          ; $84F0
  jmp ApplyScroll              ; $84F2
Sub_B4_84F5:
  lda #$00                     ; $84F5
  ldx #$10                     ; $84F7
Loc_B4_84F9:
  sta SceneState,x             ; $84F9
  inx                          ; $84FC
  bne Loc_B4_84F9              ; $84FD
Sub_B4_84FF:
  lda #$00                     ; $84FF
  ldx #$7F                     ; $8501
Loc_B4_8503:
  sta z:$60,x                  ; $8503
  dex                          ; $8505
  bpl Loc_B4_8503              ; $8506
  rts                          ; $8508
Loc_B4_8509:
  dec z:$8A                    ; $8509
  beq Loc_B4_853E              ; $850B
  ldx z:$72                    ; $850D
  lda Data_B4_8542,x           ; $850F
  beq Loc_B4_853E              ; $8512
  sta z:$60                    ; $8514
  ldy #$03                     ; $8516
Loc_B4_8518:
  tya                          ; $8518
  asl a                        ; $8519
  asl a                        ; $851A
  tax                          ; $851B
  lda $0213,x                  ; $851C
  clc                          ; $851F
  adc z:$60                    ; $8520
  cmp #$2C                     ; $8522
  beq Loc_B4_852A              ; $8524
  cmp #$AC                     ; $8526
  bne Loc_B4_852C              ; $8528
Loc_B4_852A:
  eor #$80                     ; $852A
Loc_B4_852C:
  sta $0213,x                  ; $852C
  dey                          ; $852F
  bpl Loc_B4_8518              ; $8530
  jsr Sub_B4_8583              ; $8532
  lda $0213                    ; $8535
  and #$1F                     ; $8538
  cmp #$1C                     ; $853A
  bne Loc_B4_8541              ; $853C
Loc_B4_853E:
  inc SceneState               ; $853E
Loc_B4_8541:
  rts                          ; $8541
Data_B4_8542:
  .incbin "prg_bank_4.bin", $0542, $4  ; $8542
Sub_B4_8546:
  lda #$00                     ; $8546
  sta $0211                    ; $8548
  lda #$02                     ; $854B
  sta $0215                    ; $854D
  lda #$04                     ; $8550
  sta $0219                    ; $8552
  lda #$06                     ; $8555
  sta $021D                    ; $8557
  lda #$03                     ; $855A
  sta $0212                    ; $855C
  sta $0216                    ; $855F
  sta $021A                    ; $8562
  sta $021E                    ; $8565
  ldx $051A                    ; $8568
  lda Data_B4_85A4,x           ; $856B
  sta $0213                    ; $856E
  lda Data_B4_85A3,x           ; $8571
  sta $0217                    ; $8574
  lda Data_B4_85A2,x           ; $8577
  sta $021B                    ; $857A
  lda Data_B4_85A1,x           ; $857D
  sta $021F                    ; $8580
Sub_B4_8583:
  ldx #$03                     ; $8583
Loc_B4_8585:
  txa                          ; $8585
  asl a                        ; $8586
  asl a                        ; $8587
  tay                          ; $8588
  lda $0213,y                  ; $8589
  cmp #$5A                     ; $858C
  bcc Loc_B4_8594              ; $858E
  cmp #$9F                     ; $8590
  bcc Loc_B4_8598              ; $8592
Loc_B4_8594:
  lda #$F0                     ; $8594
  bne Loc_B4_859A              ; $8596
Loc_B4_8598:
  lda #$CA                     ; $8598
Loc_B4_859A:
  sta $0210,y                  ; $859A
  dex                          ; $859D
  bpl Loc_B4_8585              ; $859E
  rts                          ; $85A0
Data_B4_85A1:
  .incbin "prg_bank_4.bin", $05A1, $1  ; $85A1
Data_B4_85A2:
  .incbin "prg_bank_4.bin", $05A2, $1  ; $85A2
Data_B4_85A3:
  .incbin "prg_bank_4.bin", $05A3, $1  ; $85A3
Data_B4_85A4:
  .incbin "prg_bank_4.bin", $05A4, $4  ; $85A4
Loc_B4_85A8:
  asl a                        ; $85A8
  tax                          ; $85A9
  lda Data_B4_85B7,x           ; $85AA
  sta z:$6D                    ; $85AD
  lda Data_B4_85B8,x           ; $85AF
  sta z:$6E                    ; $85B2
  jmp ($006D)                  ; $85B4
Data_B4_85B7:
  .addr Sub_B4_85D3, Sub_B4_85D8, Sub_B4_85DF, Sub_B4_85E6, Sub_B4_85ED, Sub_B4_85F4, Sub_B4_860D, Sub_B4_861D, Sub_B4_8629, Sub_B4_8657, Sub_B4_866A, Sub_B4_8680, Sub_B4_86AB, Sub_B4_86B4  ; $85B7 pointer table
Sub_B4_85D3:
  lda #$00                     ; $85D3
  sta z:$7C                    ; $85D5
  rts                          ; $85D7
Sub_B4_85D8:
  dec z:$7F                    ; $85D8
  lda #$02                     ; $85DA
  sta z:$7C                    ; $85DC
  rts                          ; $85DE
Sub_B4_85DF:
  inc z:$7E                    ; $85DF
  lda #$02                     ; $85E1
  sta z:$7C                    ; $85E3
  rts                          ; $85E5
Sub_B4_85E6:
  inc z:$7F                    ; $85E6
  lda #$02                     ; $85E8
  sta z:$7C                    ; $85EA
  rts                          ; $85EC
Sub_B4_85ED:
  dec z:$7E                    ; $85ED
  lda #$02                     ; $85EF
  sta z:$7C                    ; $85F1
  rts                          ; $85F3
Sub_B4_85F4:
  lda $0508                    ; $85F4
  ora $050B                    ; $85F7
  bne Loc_B4_8604              ; $85FA
  ldy #$EA                     ; $85FC
  jsr Sub_B4_B402              ; $85FE
  jmp Sub_B4_85D3              ; $8601
Loc_B4_8604:
  lda #$00                     ; $8604
  ldx #$08                     ; $8606
  ldy #$03                     ; $8608
  jmp Sub_B4_8BC9              ; $860A
Sub_B4_860D:
  lda $0508                    ; $860D
  ora $050C                    ; $8610
  bne Sub_B4_85ED              ; $8613
  ldy #$E9                     ; $8615
  jsr Sub_B4_B402              ; $8617
  jmp Sub_B4_85D3              ; $861A
Sub_B4_861D:
  lda #$01                     ; $861D
  sta $050C                    ; $861F
  ldx #$05                     ; $8622
  ldy #$04                     ; $8624
  jmp Sub_B4_8BC9              ; $8626
Sub_B4_8629:
  lda $0508                    ; $8629
  ora $050C                    ; $862C
  bne Loc_B4_8639              ; $862F
  ldy #$E9                     ; $8631
  jsr Sub_B4_B402              ; $8633
  jmp Sub_B4_85D3              ; $8636
Loc_B4_8639:
  lda #$06                     ; $8639
  sta $0510                    ; $863B
  lda #$01                     ; $863E
  sta $0511                    ; $8640
  lda #$07                     ; $8643
  sta $0512                    ; $8645
  lda #$00                     ; $8648
  sta $0513                    ; $864A
Loc_B4_864D:
  lda #$01                     ; $864D
  sta $0503                    ; $864F
  lda #$08                     ; $8652
  sta z:$7C                    ; $8654
  rts                          ; $8656
Sub_B4_8657:
  lda $0508                    ; $8657
  ora $050C                    ; $865A
  beq Loc_B4_8662              ; $865D
  jmp Sub_B4_85ED              ; $865F
Loc_B4_8662:
  ldy #$E9                     ; $8662
  jsr Sub_B4_B402              ; $8664
  jmp Sub_B4_85D3              ; $8667
Sub_B4_866A:
  lda $0508                    ; $866A
  bne Loc_B4_8677              ; $866D
  ldy #$EB                     ; $866F
  jsr Sub_B4_B402              ; $8671
  jmp Sub_B4_85D3              ; $8674
Loc_B4_8677:
  lda #$00                     ; $8677
  ldx #$0B                     ; $8679
  ldy #$03                     ; $867B
  jmp Sub_B4_8BC9              ; $867D
Sub_B4_8680:
  lda $0508                    ; $8680
  ora $050C                    ; $8683
  bne Loc_B4_8690              ; $8686
  ldy #$E9                     ; $8688
  jsr Sub_B4_B402              ; $868A
  jmp Sub_B4_85D3              ; $868D
Loc_B4_8690:
  lda #$04                     ; $8690
  sta $0510                    ; $8692
  lda $0518                    ; $8695
  clc                          ; $8698
  adc #$03                     ; $8699
  sta $0511                    ; $869B
  lda #$00                     ; $869E
  sta $0512                    ; $86A0
  lda #$02                     ; $86A3
  sta $0513                    ; $86A5
  jmp Loc_B4_864D              ; $86A8
Sub_B4_86AB:
  lda #$00                     ; $86AB
  ldx #$11                     ; $86AD
  ldy #$03                     ; $86AF
  jmp Sub_B4_8BC9              ; $86B1
Sub_B4_86B4:
  lda #$0B                     ; $86B4
  sta $0510                    ; $86B6
  lda #$07                     ; $86B9
  sta $0511                    ; $86BB
  lda #$00                     ; $86BE
  sta $0512                    ; $86C0
  lda #$02                     ; $86C3
  sta $0513                    ; $86C5
  lda #$01                     ; $86C8
  ldx #$0E                     ; $86CA
  ldy #$07                     ; $86CC
  jmp Sub_B4_8BC9              ; $86CE
Sub_B4_86D1:
  lda #$00                     ; $86D1
  sta ObjectCount              ; $86D3
  ldx #$10                     ; $86D6
Loc_B4_86D8:
  sta $0300,x                  ; $86D8
  inx                          ; $86DB
  bne Loc_B4_86D8              ; $86DC
  rts                          ; $86DE
Data_B4_86DF:
  .incbin "prg_bank_4.bin", $06DF, $1  ; $86DF
Data_B4_86E0:
  .incbin "prg_bank_4.bin", $06E0, $23  ; $86E0
Data_B4_8703:
  .incbin "prg_bank_4.bin", $0703, $1  ; $8703
Data_B4_8704:
  .incbin "prg_bank_4.bin", $0704, $23  ; $8704
Data_B4_8727:
  .incbin "prg_bank_4.bin", $0727, $1  ; $8727
Data_B4_8728:
  .incbin "prg_bank_4.bin", $0728, $3AB  ; $8728
Loc_B4_8AD3:
  lda ObjectCount              ; $8AD3
  beq Loc_B4_8AD9              ; $8AD6
  rts                          ; $8AD8
Loc_B4_8AD9:
  lda $0501                    ; $8AD9
  asl a                        ; $8ADC
  tax                          ; $8ADD
  lda Data_B4_86DF,x           ; $8ADE
  sta z:$60                    ; $8AE1
  lda Data_B4_86E0,x           ; $8AE3
  sta z:$61                    ; $8AE6
  lda Data_B4_8703,x           ; $8AE8
  sta z:$62                    ; $8AEB
  lda Data_B4_8704,x           ; $8AED
  sta z:$63                    ; $8AF0
  lda Data_B4_8727,x           ; $8AF2
  sta z:$64                    ; $8AF5
  lda Data_B4_8728,x           ; $8AF7
  sta z:$65                    ; $8AFA
  lda $0518                    ; $8AFC
  jsr AslA4                    ; $8AFF
  ora $0519                    ; $8B02
  sta z:$6A                    ; $8B05
  ldy #$00                     ; $8B07
Loc_B4_8B09:
  lda ($60),y                  ; $8B09
  cmp z:$6A                    ; $8B0B
  beq Loc_B4_8B16              ; $8B0D
  bcs Loc_B4_8B15              ; $8B0F
  iny                          ; $8B11
  jmp Loc_B4_8B09              ; $8B12
Loc_B4_8B15:
  rts                          ; $8B15
Loc_B4_8B16:
  lda ($62),y                  ; $8B16
  bmi Loc_B4_8B23              ; $8B18
  cmp $051A                    ; $8B1A
  beq Loc_B4_8B23              ; $8B1D
  iny                          ; $8B1F
  jmp Loc_B4_8B09              ; $8B20
Loc_B4_8B23:
  jsr Sub_B4_8FAB              ; $8B23
  lda ($64),y                  ; $8B26
  ldy #$00                     ; $8B28
  sta (Tmp00),y                ; $8B2A
  rts                          ; $8B2C
Sub_B4_8B2D:
  lda ObjectCount              ; $8B2D
  beq Loc_B4_8B42              ; $8B30
  jsr AslA4                    ; $8B32
  sta z:Tmp00                  ; $8B35
  lda #$03                     ; $8B37
  sta z:Tmp01                  ; $8B39
Loc_B4_8B3B:
  jsr Sub_B4_8B43              ; $8B3B
  lda z:Tmp00                  ; $8B3E
  bne Loc_B4_8B3B              ; $8B40
Loc_B4_8B42:
  rts                          ; $8B42
Sub_B4_8B43:
  ldy #$00                     ; $8B43
  lda (Tmp00),y                ; $8B45
  and #$3F                     ; $8B47
  cmp #$18                     ; $8B49
  bcs Loc_B4_8B57              ; $8B4B
  asl a                        ; $8B4D
  asl a                        ; $8B4E
  adc z:$72                    ; $8B4F
  tax                          ; $8B51
  lda Data_B4_8B69,x           ; $8B52
  bne Loc_B4_8B5A              ; $8B55
Loc_B4_8B57:
  jmp Sub_C43D                 ; $8B57
Loc_B4_8B5A:
  sta (Tmp00),y                ; $8B5A
  tya                          ; $8B5C
  ldy #$08                     ; $8B5D
  sta (Tmp00),y                ; $8B5F
  lda z:Tmp00                  ; $8B61
  sec                          ; $8B63
  sbc #$10                     ; $8B64
  sta z:Tmp00                  ; $8B66
  rts                          ; $8B68
Data_B4_8B69:
  .incbin "prg_bank_4.bin", $0B69, $60  ; $8B69
Sub_B4_8BC9:
  sta $0503                    ; $8BC9
  sty z:$7C                    ; $8BCC
  ldy #$03                     ; $8BCE
Loc_B4_8BD0:
  lda Data_B4_8BE0,x           ; $8BD0
  sta a:$28,y                  ; $8BD3
  dex                          ; $8BD6
  dey                          ; $8BD7
  bne Loc_B4_8BD0              ; $8BD8
  sty z:PaletteDirty           ; $8BDA
  iny                          ; $8BDC
  sty z:$28                    ; $8BDD
  rts                          ; $8BDF
Data_B4_8BE0:
  .incbin "prg_bank_4.bin", $0BE0, $1B  ; $8BE0
Sub_B4_8BFB:
  lda z:PlayerLifeLo           ; $8BFB
  cmp #$32                     ; $8BFD
  ldx z:$8B                    ; $8BFF
  bcs Loc_B4_8C0C              ; $8C01
  bne Loc_B4_8C17              ; $8C03
  lda #$42                     ; $8C05
  sta z:$8B                    ; $8C07
  jmp EnqueueByte              ; $8C09
Loc_B4_8C0C:
  beq Loc_B4_8C17              ; $8C0C
  lda #$00                     ; $8C0E
  sta z:$8B                    ; $8C10
  lda #$44                     ; $8C12
  jmp EnqueueByte              ; $8C14
Loc_B4_8C17:
  rts                          ; $8C17
Sub_B4_8C18:
  jsr Sub_B4_8C1E              ; $8C18
  jmp Sub_B4_917E              ; $8C1B
Sub_B4_8C1E:
  lda z:$82                    ; $8C1E
  asl a                        ; $8C20
  tax                          ; $8C21
  lda Data_B4_8C2F,x           ; $8C22
  sta z:$6D                    ; $8C25
  lda Data_B4_8C30,x           ; $8C27
  sta z:$6E                    ; $8C2A
  jmp ($006D)                  ; $8C2C
Data_B4_8C2F:
  .incbin "prg_bank_4.bin", $0C2F, $1  ; $8C2F
Data_B4_8C30:
  .incbin "prg_bank_4.bin", $0C30, $EB  ; $8C30
Loc_B4_8D1B:
  ldx #$08                     ; $8D1B
Loc_B4_8D1D:
  lda z:$72,x                  ; $8D1D
  sta z:$73,x                  ; $8D1F
  dex                          ; $8D21
  bpl Loc_B4_8D1D              ; $8D22
  rts                          ; $8D24
Sub_B4_8D25:
  lda z:$6F                    ; $8D25
  beq Loc_B4_8D2C              ; $8D27
  jmp Loc_B4_8DB5              ; $8D29
Loc_B4_8D2C:
  lda JoyNew1                  ; $8D2C
  and #$01                     ; $8D2F
  beq Loc_B4_8D4C              ; $8D31
  jsr AslA4                    ; $8D33
  ldy #$00                     ; $8D36
Loc_B4_8D38:
  tax                          ; $8D38
  tya                          ; $8D39
  ora $0309,x                  ; $8D3A
  tay                          ; $8D3D
  txa                          ; $8D3E
  sec                          ; $8D3F
  sbc #$10                     ; $8D40
  bne Loc_B4_8D38              ; $8D42
  tya                          ; $8D44
  asl a                        ; $8D45
  bmi Loc_B4_8D72              ; $8D46
  asl a                        ; $8D48
  bmi Loc_B4_8D8E              ; $8D49
  rts                          ; $8D4B
Loc_B4_8D4C:
  ldy z:AmmoLo                 ; $8D4C
  ldx z:AmmoHi                 ; $8D4E
  bne Loc_B4_8D62              ; $8D50
  lda JoyNew1                  ; $8D52
  and #$04                     ; $8D55
  beq Loc_B4_8D61              ; $8D57
  cpy #$0A                     ; $8D59
  bcs Loc_B4_8D61              ; $8D5B
  dec z:PlayerLifeLo           ; $8D5D
  inc z:AmmoLo                 ; $8D5F
Loc_B4_8D61:
  rts                          ; $8D61
Loc_B4_8D62:
  dex                          ; $8D62
  bne Loc_B4_8D69              ; $8D63
  cpy #$91                     ; $8D65
  bcc Loc_B4_8D71              ; $8D67
Loc_B4_8D69:
  lda #$90                     ; $8D69
  sta z:AmmoLo                 ; $8D6B
  lda #$01                     ; $8D6D
  sta z:AmmoHi                 ; $8D6F
Loc_B4_8D71:
  rts                          ; $8D71
Loc_B4_8D72:
  lda z:AmmoLo                 ; $8D72
  ora z:AmmoHi                 ; $8D74
  beq Loc_B4_8D85              ; $8D76
  inc z:$6F                    ; $8D78
  ldx #$07                     ; $8D7A
Loc_B4_8D7C:
  lda Data_B4_8D86,x           ; $8D7C
  sta $0204,x                  ; $8D7F
  dex                          ; $8D82
  bpl Loc_B4_8D7C              ; $8D83
Loc_B4_8D85:
  rts                          ; $8D85
Data_B4_8D86:
  .incbin "prg_bank_4.bin", $0D86, $8  ; $8D86
Loc_B4_8D8E:
  lda $051F                    ; $8D8E
  beq Loc_B4_8DA8              ; $8D91
  lda ObjectCount              ; $8D93
  jsr AslA4                    ; $8D96
  tax                          ; $8D99
Loc_B4_8D9A:
  lda $0309,x                  ; $8D9A
  tay                          ; $8D9D
  and #$20                     ; $8D9E
  bne Loc_B4_8DA9              ; $8DA0
  txa                          ; $8DA2
  sec                          ; $8DA3
  sbc #$10                     ; $8DA4
  bne Loc_B4_8D9A              ; $8DA6
Loc_B4_8DA8:
  rts                          ; $8DA8
Loc_B4_8DA9:
  tya                          ; $8DA9
  ora #$80                     ; $8DAA
  sta $0309,x                  ; $8DAC
  dec $051F                    ; $8DAF
  jmp Loc_B4_9FF7              ; $8DB2
Loc_B4_8DB5:
  lda JoyNew1                  ; $8DB5
  lsr a                        ; $8DB8
  bcs Loc_B4_8DC1              ; $8DB9
  lsr a                        ; $8DBB
  bcc Loc_B4_8DDF              ; $8DBC
  jmp Sub_B4_8E06              ; $8DBE
Loc_B4_8DC1:
  lda #$0E                     ; $8DC1
  jsr EnqueueByte              ; $8DC3
  jsr Sub_B4_8E06              ; $8DC6
  ldy ObjectCount              ; $8DC9
  beq Loc_B4_8DD6              ; $8DCC
Loc_B4_8DCE:
  jsr Sub_B4_8E13              ; $8DCE
  bcs Loc_B4_8DD6              ; $8DD1
  dey                          ; $8DD3
  bne Loc_B4_8DCE              ; $8DD4
Loc_B4_8DD6:
  ldx z:AmmoLo                 ; $8DD6
  bne Loc_B4_8DDC              ; $8DD8
  dec z:AmmoHi                 ; $8DDA
Loc_B4_8DDC:
  dec z:AmmoLo                 ; $8DDC
  rts                          ; $8DDE
Loc_B4_8DDF:
  bit JoyNew1                  ; $8DDF
  bmi Loc_B4_8DE7              ; $8DE2
  bvs Loc_B4_8DFA              ; $8DE4
Loc_B4_8DE6:
  rts                          ; $8DE6
Loc_B4_8DE7:
  lda $0207                    ; $8DE7
  cmp #$90                     ; $8DEA
  bcs Loc_B4_8DE6              ; $8DEC
  adc #$38                     ; $8DEE
Loc_B4_8DF0:
  sta $0207                    ; $8DF0
  clc                          ; $8DF3
  adc #$08                     ; $8DF4
  sta $020B                    ; $8DF6
  rts                          ; $8DF9
Loc_B4_8DFA:
  lda $0207                    ; $8DFA
  cmp #$50                     ; $8DFD
  bcc Loc_B4_8DE6              ; $8DFF
  sbc #$38                     ; $8E01
  jmp Loc_B4_8DF0              ; $8E03
Sub_B4_8E06:
  lda #$00                     ; $8E06
  sta z:$6F                    ; $8E08
  lda #$F0                     ; $8E0A
  sta $0204                    ; $8E0C
  sta $0208                    ; $8E0F
  rts                          ; $8E12
Sub_B4_8E13:
  tya                          ; $8E13
  beq Sub_B4_8E90              ; $8E14
  jsr AslA4                    ; $8E16
  tax                          ; $8E19
  stx z:$6B                    ; $8E1A
  lda $0309,x                  ; $8E1C
  asl a                        ; $8E1F
  bpl Sub_B4_8E90              ; $8E20
  lda $0300,x                  ; $8E22
  and #$3F                     ; $8E25
  asl a                        ; $8E27
  tax                          ; $8E28
  lda Data_B4_8E36,x           ; $8E29
  sta z:$6D                    ; $8E2C
  lda Data_B4_8E37,x           ; $8E2E
  sta z:$6E                    ; $8E31
  jmp ($006D)                  ; $8E33
Data_B4_8E36:
  .addr Sub_B4_8E90, Sub_B4_8E92, Sub_B4_8E9C, Sub_B4_8E9C, Sub_B4_8E9C, Sub_B4_8E90, Sub_B4_8EA8, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8EB4, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8EBE, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90, Sub_B4_8E90  ; $8E36 pointer table
Sub_B4_8E90:
  clc                          ; $8E90
  rts                          ; $8E91
Sub_B4_8E92:
  ldx z:$6B                    ; $8E92  [heuristic code]
  lda $0302,x                  ; $8E94
  cmp $0207                    ; $8E97
  bne Sub_B4_8E90              ; $8E9A
Sub_B4_8E9C:
  ldx z:$6B                    ; $8E9C
  lda $0309,x                  ; $8E9E
  ora #$80                     ; $8EA1
  sta $0309,x                  ; $8EA3
  sec                          ; $8EA6
  rts                          ; $8EA7
Sub_B4_8EA8:
  ldx z:$6B                    ; $8EA8
  lda ObjectCount,x            ; $8EAA
  cmp #$44                     ; $8EAD
  bcc Sub_B4_8E90              ; $8EAF
  jmp Sub_B4_8E92              ; $8EB1
Sub_B4_8EB4:
  ldx z:$6B                    ; $8EB4
  lda $0305,x                  ; $8EB6
  beq Sub_B4_8E92              ; $8EB9
  jmp Sub_B4_8E90              ; $8EBB
Sub_B4_8EBE:
  ldx z:$6B                    ; $8EBE
  lda $0302,x                  ; $8EC0
  cmp $0207                    ; $8EC3
  bne Sub_B4_8E90              ; $8EC6
  jmp Sub_B4_8E9C              ; $8EC8
  sta z:$60                    ; $8ECB  [heuristic code]
  asl a                        ; $8ECD
  adc z:$60                    ; $8ECE
  tax                          ; $8ED0
  ldy #$14                     ; $8ED1
  jsr Sub_B4_8EDD              ; $8ED3
  ldy z:$60                    ; $8ED6
  ldx Data_B4_8F53,y           ; $8ED8
  ldy #$18                     ; $8EDB
Sub_B4_8EDD:
  lda Data_B4_8EF0,x           ; $8EDD
  sta SceneTimer,y             ; $8EE0
  lda Data_B4_8EF1,x           ; $8EE3
  sta $0527,y                  ; $8EE6
  lda Data_B4_8EF2,x           ; $8EE9
  sta $0528,y                  ; $8EEC
  rts                          ; $8EEF
Data_B4_8EF0:
  .incbin "prg_bank_4.bin", $0EF0, $1  ; $8EF0
Data_B4_8EF1:
  .incbin "prg_bank_4.bin", $0EF1, $1  ; $8EF1
Data_B4_8EF2:
  .incbin "prg_bank_4.bin", $0EF2, $61  ; $8EF2
Data_B4_8F53:
  .incbin "prg_bank_4.bin", $0F53, $58  ; $8F53
Sub_B4_8FAB:
  inc ObjectCount              ; $8FAB
  lda ObjectCount              ; $8FAE
  jsr AslA4                    ; $8FB1
  sta z:Tmp00                  ; $8FB4
  lda #$03                     ; $8FB6
  sta z:Tmp01                  ; $8FB8
  rts                          ; $8FBA
  ldy #$08                     ; $8FBB  [heuristic code]
  lda (Tmp00),y                ; $8FBD
  clc                          ; $8FBF
  adc #$01                     ; $8FC0
  sta (Tmp00),y                ; $8FC2
  rts                          ; $8FC4
  .incbin "prg_bank_4.bin", $0FC5, $8  ; $8FC5
Sub_B4_8FCD:
  ldy #$00                     ; $8FCD
  lda $054C                    ; $8FCF
  bpl Loc_B4_8FD6              ; $8FD2
  ldy #$04                     ; $8FD4
Loc_B4_8FD6:
  sty PPU_CTRL                 ; $8FD6
  and #$3F                     ; $8FD9
  bne Loc_B4_8FDF              ; $8FDB
  lda #$40                     ; $8FDD
Loc_B4_8FDF:
  tay                          ; $8FDF
  lda PPU_STATUS               ; $8FE0
  lda $054A                    ; $8FE3
  and #$23                     ; $8FE6
  sta PPU_ADDR                 ; $8FE8
  lda $054B                    ; $8FEB
  sta PPU_ADDR                 ; $8FEE
  lda PPU_DATA                 ; $8FF1
  ldx #$00                     ; $8FF4
Loc_B4_8FF6:
  lda PPU_DATA                 ; $8FF6
  sta $054D,x                  ; $8FF9
  inx                          ; $8FFC
  dey                          ; $8FFD
  bne Loc_B4_8FF6              ; $8FFE
  lda #$FF                     ; $9000
  sta $054D,x                  ; $9002
  rts                          ; $9005
Sub_B4_9006:
  lda z:PpuCtrlShadow          ; $9006
  and #$FD                     ; $9008
  jsr SetPpuCtrl               ; $900A
  lda #$28                     ; $900D
  sta $054A                    ; $900F
  lda #$10                     ; $9012
  sta $058E                    ; $9014
  lda #$00                     ; $9017
  sta $054B                    ; $9019
  sta $054C                    ; $901C
Loc_B4_901F:
  ldy #$40                     ; $901F
  jsr Sub_B4_8FCD              ; $9021
  jsr ProcessPpuUpdateList     ; $9024
  .incbin "prg_bank_4.bin", $1027, $2  ; $9027
  lda $054B                    ; $9029
  clc                          ; $902C
  adc #$40                     ; $902D
  sta $054B                    ; $902F
  lda $054A                    ; $9032
  adc #$00                     ; $9035
  sta $054A                    ; $9037
  dec $058E                    ; $903A
  bne Loc_B4_901F              ; $903D
  rts                          ; $903F
  .incbin "prg_bank_4.bin", $1040, $9  ; $9040
Sub_B4_9049:
  lda $0502                    ; $9049
  ldx #$00                     ; $904C
  stx $0502                    ; $904E
  asl a                        ; $9051
  tax                          ; $9052
  lda Data_B4_9060,x           ; $9053
  sta z:$6D                    ; $9056
  lda Data_B4_9061,x           ; $9058
  sta z:$6E                    ; $905B
  jmp ($006D)                  ; $905D
Data_B4_9060:
  .incbin "prg_bank_4.bin", $1060, $1  ; $9060
Data_B4_9061:
  .incbin "prg_bank_4.bin", $1061, $F  ; $9061
  rts                          ; $9070
  .incbin "prg_bank_4.bin", $1071, $3  ; $9071
Sub_B4_9074:
  jsr ProcessPpuUpdateList     ; $9074
  .incbin "prg_bank_4.bin", $1077, $2  ; $9077
  rts                          ; $9079
  .incbin "prg_bank_4.bin", $107A, $24  ; $907A
Sub_B4_909E:
  ldx #$05                     ; $909E
Loc_B4_90A0:
  lda Sub_B4_9074,x            ; $90A0
  sta $0520,x                  ; $90A3
  dex                          ; $90A6
  bpl Loc_B4_90A0              ; $90A7
  rts                          ; $90A9
  .incbin "prg_bank_4.bin", $10AA, $D  ; $90AA
Loc_B4_90B7:
  lda z:PpuMaskShadow          ; $90B7
  ora #$18                     ; $90B9
  jmp SetPpuMask               ; $90BB
Sub_B4_90BE:
  lda z:PpuMaskShadow          ; $90BE
  and #$E7                     ; $90C0
  jmp SetPpuMask               ; $90C2
  .incbin "prg_bank_4.bin", $10C5, $14  ; $90C5
Sub_B4_90D9:
  ldx #$1C                     ; $90D9
Loc_B4_90DB:
  lda $02E1,x                  ; $90DB
  cmp #$FE                     ; $90DE
  bne Loc_B4_90E7              ; $90E0
  lda #$F0                     ; $90E2
  sta $02E0,x                  ; $90E4
Loc_B4_90E7:
  dex                          ; $90E7
  dex                          ; $90E8
  dex                          ; $90E9
  dex                          ; $90EA
  bpl Loc_B4_90DB              ; $90EB
  rts                          ; $90ED
  ldy #$00                     ; $90EE  [heuristic code]
  lda (Tmp00),y                ; $90F0
  and #$3F                     ; $90F2
  tax                          ; $90F4
  lda Data_B4_9102,x           ; $90F5
  ldy #$09                     ; $90F8
  sta (Tmp00),y                ; $90FA
  lda Data_B4_912E,x           ; $90FC
  iny                          ; $90FF
  sta (Tmp00),y                ; $9100
Data_B4_9102:
  rts                          ; $9102
  .incbin "prg_bank_4.bin", $1103, $2B  ; $9103
Data_B4_912E:
  .incbin "prg_bank_4.bin", $112E, $2D  ; $912E
Sub_B4_915B:
  ldx $0501                    ; $915B
  cpx #$12                     ; $915E
  bcc Loc_B4_916C              ; $9160
  lda #$00                     ; $9162
  sta z:MmcPrgShadow           ; $9164
  sta z:GameState              ; $9166
  sta $0503                    ; $9168
  rts                          ; $916B
Loc_B4_916C:
  lda Data_B4_9195,x           ; $916C
  sta $0518                    ; $916F
  lda Data_B4_91A7,x           ; $9172
  sta $0519                    ; $9175
  lda Data_B4_91B9,x           ; $9178
  sta $051A                    ; $917B
Sub_B4_917E:
  lda $0501                    ; $917E
  asl a                        ; $9181
  asl a                        ; $9182
  tax                          ; $9183
  ldy #$00                     ; $9184
Loc_B4_9186:
  lda Data_B4_91CB,x           ; $9186
  sta $0514,y                  ; $9189
  inx                          ; $918C
  iny                          ; $918D
  cpy #$04                     ; $918E
  bne Loc_B4_9186              ; $9190
  jmp Sub_B4_9589              ; $9192
Data_B4_9195:
  .incbin "prg_bank_4.bin", $1195, $12  ; $9195
Data_B4_91A7:
  .incbin "prg_bank_4.bin", $11A7, $12  ; $91A7
Data_B4_91B9:
  .incbin "prg_bank_4.bin", $11B9, $12  ; $91B9
Data_B4_91CB:
  .incbin "prg_bank_4.bin", $11CB, $3A0  ; $91CB
Sub_B4_956B:
  lda #$3F                     ; $956B
  sta SceneTimer               ; $956D
  ldx #$00                     ; $9570
  stx $0527                    ; $9572
  lda #$20                     ; $9575
  sta $0528                    ; $9577
  dex                          ; $957A
  stx $0549                    ; $957B
  lda #$0F                     ; $957E
  ldx #$20                     ; $9580
Loc_B4_9582:
  sta $0528,x                  ; $9582
  dex                          ; $9585
  bne Loc_B4_9582              ; $9586
  rts                          ; $9588
Sub_B4_9589:
  jsr Sub_B4_956B              ; $9589
  ldx #$02                     ; $958C
Loc_B4_958E:
  lda Data_B4_95FD,x           ; $958E
  sta $0532,x                  ; $9591
  sta $0542,x                  ; $9594
  lda Data_B4_9600,x           ; $9597
  sta $0536,x                  ; $959A
  sta $0546,x                  ; $959D
  dex                          ; $95A0
  bpl Loc_B4_958E              ; $95A1
  ldy $0501                    ; $95A3
  ldx Data_B4_95E0,y           ; $95A6
  stx z:$87                    ; $95A9
  jsr Sub_B4_95C8              ; $95AB
  lda $0508                    ; $95AE
  beq Sub_B4_95C2              ; $95B1
  lda #$0F                     ; $95B3
  sta $0532                    ; $95B5
  lda #$00                     ; $95B8
  sta $0533                    ; $95BA
  lda #$10                     ; $95BD
  sta $0534                    ; $95BF
Sub_B4_95C2:
  lda #$05                     ; $95C2
  sta $0502                    ; $95C4
  rts                          ; $95C7
Sub_B4_95C8:
  lda Data_B4_95F4,x           ; $95C8
  sta $052E                    ; $95CB
  and #$1F                     ; $95CE
  sta $052B                    ; $95D0
  sta $052F                    ; $95D3
  clc                          ; $95D6
  adc #$10                     ; $95D7
  sta AnimCounter              ; $95D9
  sta $0530                    ; $95DC
  rts                          ; $95DF
Data_B4_95E0:
  .incbin "prg_bank_4.bin", $15E0, $14  ; $95E0
Data_B4_95F4:
  .incbin "prg_bank_4.bin", $15F4, $9  ; $95F4
Data_B4_95FD:
  .incbin "prg_bank_4.bin", $15FD, $3  ; $95FD
Data_B4_9600:
  .incbin "prg_bank_4.bin", $1600, $3  ; $9600
Sub_B4_9603:
  lda ObjectCount              ; $9603
  beq Loc_B4_961A              ; $9606
  jsr AslA4                    ; $9608
  ldy #$00                     ; $960B
Loc_B4_960D:
  tax                          ; $960D
  tya                          ; $960E
  ora $030A,x                  ; $960F
  tay                          ; $9612
  txa                          ; $9613
  sec                          ; $9614
  sbc #$10                     ; $9615
  bne Loc_B4_960D              ; $9617
  tya                          ; $9619
Loc_B4_961A:
  sta z:$71                    ; $961A
  lda JoyNew1                  ; $961C
  bmi Loc_B4_962B              ; $961F
  asl a                        ; $9621
  bmi Loc_B4_9646              ; $9622
  asl a                        ; $9624
  bmi Loc_B4_9660              ; $9625
  asl a                        ; $9627
  bmi Loc_B4_967A              ; $9628
  rts                          ; $962A
Loc_B4_962B:
  bit z:$71                    ; $962B
  bvs Loc_B4_9645              ; $962D
  lda z:$6F                    ; $962F
  bne Loc_B4_9645              ; $9631
  lda $051A                    ; $9633
  clc                          ; $9636
  adc #$01                     ; $9637
  and #$03                     ; $9639
  sta $051A                    ; $963B
  ldx #$01                     ; $963E
  stx z:$7C                    ; $9640
  inx                          ; $9642
  stx z:$72                    ; $9643
Loc_B4_9645:
  rts                          ; $9645
Loc_B4_9646:
  bit z:$71                    ; $9646
  bvs Loc_B4_965F              ; $9648
  lda z:$6F                    ; $964A
  bne Loc_B4_965F              ; $964C
  lda $051A                    ; $964E
  sec                          ; $9651
  sbc #$01                     ; $9652
  and #$03                     ; $9654
  sta $051A                    ; $9656
  ldx #$01                     ; $9659
  stx z:$7C                    ; $965B
  stx z:$72                    ; $965D
Loc_B4_965F:
  rts                          ; $965F
Loc_B4_9660:
  lda z:$71                    ; $9660
  and #$20                     ; $9662
  bne Loc_B4_9679              ; $9664
  lda $051A                    ; $9666
  clc                          ; $9669
  adc #$02                     ; $966A
  and #$03                     ; $966C
  sta $051A                    ; $966E
  lda #$03                     ; $9671
  sta z:$72                    ; $9673
  lda #$01                     ; $9675
  sta z:$7C                    ; $9677
Loc_B4_9679:
  rts                          ; $9679
Loc_B4_967A:
  lda z:$71                    ; $967A
  bmi Loc_B4_96DE              ; $967C
  lda z:$6F                    ; $967E
  bne Loc_B4_96DE              ; $9680
  ldx z:$9B                    ; $9682
  beq Loc_B4_968F              ; $9684
  dex                          ; $9686
  beq Loc_B4_96DE              ; $9687
  dex                          ; $9689
  beq Loc_B4_96DF              ; $968A
  jmp Sub_B4_96EA              ; $968C
Loc_B4_968F:
  ldx $051A                    ; $968F
  beq Loc_B4_96A8              ; $9692
  dex                          ; $9694
  beq Loc_B4_96B6              ; $9695
  dex                          ; $9697
  beq Loc_B4_96C7              ; $9698
  lda $0518                    ; $969A
  beq Loc_B4_96DE              ; $969D
  sec                          ; $969F
  sbc #$01                     ; $96A0
  sta $0518                    ; $96A2
  jmp Loc_B4_96D5              ; $96A5
Loc_B4_96A8:
  lda $0519                    ; $96A8
  beq Loc_B4_96DE              ; $96AB
  sec                          ; $96AD
  sbc #$01                     ; $96AE
  sta $0519                    ; $96B0
  jmp Loc_B4_96D5              ; $96B3
Loc_B4_96B6:
  lda $0518                    ; $96B6
  clc                          ; $96B9
  adc #$01                     ; $96BA
  cmp $0516                    ; $96BC
  beq Loc_B4_96DE              ; $96BF
  sta $0518                    ; $96C1
  jmp Loc_B4_96D5              ; $96C4
Loc_B4_96C7:
  lda $0519                    ; $96C7
  clc                          ; $96CA
  adc #$01                     ; $96CB
  cmp $0517                    ; $96CD
  beq Loc_B4_96DE              ; $96D0
  sta $0519                    ; $96D2
Loc_B4_96D5:
  ldx #$00                     ; $96D5
  stx z:$72                    ; $96D7
  stx z:$84                    ; $96D9
  inx                          ; $96DB
  stx z:$7C                    ; $96DC
Loc_B4_96DE:
  rts                          ; $96DE
Loc_B4_96DF:
  lda z:$83                    ; $96DF
  and #$03                     ; $96E1
  beq Loc_B4_96DE              ; $96E3
  sta z:$81                    ; $96E5
  jmp Loc_B4_9750              ; $96E7
Sub_B4_96EA:
  lda $0501                    ; $96EA
  asl a                        ; $96ED
  tay                          ; $96EE
  lda Data_B4_976E,y           ; $96EF
  sta z:$60                    ; $96F2
  lda Data_B4_976F,y           ; $96F4
  sta z:$61                    ; $96F7
  lda Data_B4_9792,y           ; $96F9
  sta z:$62                    ; $96FC
  lda Data_B4_9793,y           ; $96FE
  sta z:$63                    ; $9701
  lda Data_B4_97B6,y           ; $9703
  sta z:$64                    ; $9706
  lda Data_B4_97B7,y           ; $9708
  sta z:$65                    ; $970B
  lda $0518                    ; $970D
  jsr AslA4                    ; $9710
  ora $0519                    ; $9713
  sta z:$6A                    ; $9716
  ldy #$00                     ; $9718
Loc_B4_971A:
  lda ($60),y                  ; $971A
  cmp z:$6A                    ; $971C
  beq Loc_B4_972D              ; $971E
  bcs Loc_B4_9726              ; $9720
  iny                          ; $9722
  jmp Loc_B4_971A              ; $9723
Loc_B4_9726:
  ldy $051A                    ; $9726
  iny                          ; $9729
  jmp Loc_B4_973B              ; $972A
Loc_B4_972D:
  lda ($62),y                  ; $972D
  cmp $051A                    ; $972F
  beq Loc_B4_9738              ; $9732
  iny                          ; $9734
  jmp Loc_B4_971A              ; $9735
Loc_B4_9738:
  lda ($64),y                  ; $9738
  tay                          ; $973A
Loc_B4_973B:
  lda #$00                     ; $973B
  sta z:$84                    ; $973D
  sta z:$7E                    ; $973F
  sta z:$7F                    ; $9741
  tya                          ; $9743
  bpl Loc_B4_974B              ; $9744
  and #$7F                     ; $9746
  sta z:$82                    ; $9748
  rts                          ; $974A
Loc_B4_974B:
  sta z:$7D                    ; $974B
  jmp Loc_B4_85A8              ; $974D
Loc_B4_9750:
  ldx z:$82                    ; $9750
  lda Data_B4_9758,x           ; $9752
  sta z:$7C                    ; $9755
  rts                          ; $9757
Data_B4_9758:
  .incbin "prg_bank_4.bin", $1758, $16  ; $9758
Data_B4_976E:
  .incbin "prg_bank_4.bin", $176E, $1  ; $976E
Data_B4_976F:
  .incbin "prg_bank_4.bin", $176F, $23  ; $976F
Data_B4_9792:
  .incbin "prg_bank_4.bin", $1792, $1  ; $9792
Data_B4_9793:
  .incbin "prg_bank_4.bin", $1793, $23  ; $9793
Data_B4_97B6:
  .incbin "prg_bank_4.bin", $17B6, $1  ; $97B6
Data_B4_97B7:
  .incbin "prg_bank_4.bin", $17B7, $B1  ; $97B7
Sub_B4_9868:
  jsr Sub_B4_988E              ; $9868
  jsr Sub_B4_98A3              ; $986B
  lda z:$8F                    ; $986E
  ldx #$00                     ; $9870
  jsr Sub_B4_98F6              ; $9872
  lda z:$8F                    ; $9875
  clc                          ; $9877
  adc z:Tmp01                  ; $9878
  jsr Sub_B4_98F6              ; $987A
  lda z:$8F                    ; $987D
  sec                          ; $987F
  sbc z:Tmp01                  ; $9880
  jsr Sub_B4_98F6              ; $9882
  jsr Sub_B4_990C              ; $9885
  jsr Sub_B4_9922              ; $9888
  jmp Loc_B4_9954              ; $988B
Sub_B4_988E:
  lda #$00                     ; $988E
  ldx $0519                    ; $9890
  beq Loc_B4_989C              ; $9893
Loc_B4_9895:
  clc                          ; $9895
  adc $0516                    ; $9896
  dex                          ; $9899
  bne Loc_B4_9895              ; $989A
Loc_B4_989C:
  clc                          ; $989C
  adc $0518                    ; $989D
  sta z:$8F                    ; $98A0
  rts                          ; $98A2
Sub_B4_98A3:
  lda $0516                    ; $98A3
  ldx $051A                    ; $98A6
  beq Loc_B4_98BB              ; $98A9
  dex                          ; $98AB
  beq Loc_B4_98CA              ; $98AC
  dex                          ; $98AE
  beq Loc_B4_98D7              ; $98AF
  sta z:Tmp01                  ; $98B1
  lda #$FF                     ; $98B3
  sta z:Tmp00                  ; $98B5
  ldx #$02                     ; $98B7
  bne Loc_B4_98DE              ; $98B9
Loc_B4_98BB:
  eor #$FF                     ; $98BB
  clc                          ; $98BD
  adc #$01                     ; $98BE
  sta z:Tmp00                  ; $98C0
  lda #$FF                     ; $98C2
  sta z:Tmp01                  ; $98C4
  ldx #$03                     ; $98C6
  bne Loc_B4_98DE              ; $98C8
Loc_B4_98CA:
  eor #$FF                     ; $98CA
  clc                          ; $98CC
  adc #$01                     ; $98CD
  sta z:Tmp01                  ; $98CF
  lda #$01                     ; $98D1
  sta z:Tmp00                  ; $98D3
  bne Loc_B4_98DE              ; $98D5
Loc_B4_98D7:
  sta z:Tmp00                  ; $98D7
  lda #$01                     ; $98D9
  sta z:Tmp01                  ; $98DB
  tax                          ; $98DD
Loc_B4_98DE:
  lda Data_B4_98F0,x           ; $98DE
  sta z:$8C                    ; $98E1
  inx                          ; $98E3
  lda Data_B4_98F0,x           ; $98E4
  sta z:$8D                    ; $98E7
  inx                          ; $98E9
  lda Data_B4_98F0,x           ; $98EA
  sta z:$8E                    ; $98ED
  rts                          ; $98EF
Data_B4_98F0:
  .incbin "prg_bank_4.bin", $18F0, $6  ; $98F0
Sub_B4_98F6:
  sta z:$8F,x                  ; $98F6
  inx                          ; $98F8
  clc                          ; $98F9
  adc z:Tmp00                  ; $98FA
  sta z:$8F,x                  ; $98FC
  inx                          ; $98FE
  clc                          ; $98FF
  adc z:Tmp00                  ; $9900
  sta z:$8F,x                  ; $9902
  inx                          ; $9904
  clc                          ; $9905
  adc z:Tmp00                  ; $9906
  sta z:$8F,x                  ; $9908
  inx                          ; $990A
  rts                          ; $990B
Sub_B4_990C:
  ldx #$0B                     ; $990C
  lda $0514                    ; $990E
  sta z:$60                    ; $9911
  lda $0515                    ; $9913
  sta z:$61                    ; $9916
Loc_B4_9918:
  ldy z:$8F,x                  ; $9918
  lda ($60),y                  ; $991A
  sta z:$8F,x                  ; $991C
  dex                          ; $991E
  bpl Loc_B4_9918              ; $991F
  rts                          ; $9921
Sub_B4_9922:
  ldx #$03                     ; $9922
Loc_B4_9924:
  lda z:$8F,x                  ; $9924
  ldy z:$8D                    ; $9926
  jsr Sub_B4_9943              ; $9928
  sta z:$9B,x                  ; $992B
  lda z:$8F,x                  ; $992D
  ldy z:$8C                    ; $992F
  jsr Sub_B4_9943              ; $9931
  sta z:$9F,x                  ; $9934
  lda z:$8F,x                  ; $9936
  ldy z:$8E                    ; $9938
  jsr Sub_B4_9943              ; $993A
  sta z:$A3,x                  ; $993D
  dex                          ; $993F
  bpl Loc_B4_9924              ; $9940
  rts                          ; $9942
Sub_B4_9943:
  beq Loc_B4_9951              ; $9943
  dey                          ; $9945
  beq Loc_B4_994F              ; $9946
  dey                          ; $9948
  beq Loc_B4_994D              ; $9949
  lsr a                        ; $994B
  lsr a                        ; $994C
Loc_B4_994D:
  lsr a                        ; $994D
  lsr a                        ; $994E
Loc_B4_994F:
  lsr a                        ; $994F
  lsr a                        ; $9950
Loc_B4_9951:
  and #$03                     ; $9951
  rts                          ; $9953
Loc_B4_9954:
  ldx #$07                     ; $9954
Loc_B4_9956:
  lda z:$93,x                  ; $9956
  ldy z:$8D                    ; $9958
  jsr Sub_B4_9943              ; $995A
  sta z:$A7,x                  ; $995D
  dex                          ; $995F
  bpl Loc_B4_9956              ; $9960
  rts                          ; $9962
Sub_B4_9963:
  jsr Sub_B4_9975              ; $9963
  jsr Sub_B4_9A2C              ; $9966
  jsr Sub_B4_9A73              ; $9969
  jsr Sub_B4_9F2F              ; $996C
  jsr CallBank5_A000           ; $996F
  jmp CallBank5_A000           ; $9972
Sub_B4_9975:
  lda PPU_STATUS               ; $9975
  lda #$20                     ; $9978
  sta PPU_ADDR                 ; $997A
  ldy #$00                     ; $997D
  sty PPU_ADDR                 ; $997F
Loc_B4_9982:
  lda Data_B4_99AE,y           ; $9982
  beq Loc_B4_99AD              ; $9985
  bmi Loc_B4_9999              ; $9987
  and #$7F                     ; $9989
  tax                          ; $998B
  iny                          ; $998C
Loc_B4_998D:
  lda Data_B4_99AE,y           ; $998D
  iny                          ; $9990
  sta PPU_DATA                 ; $9991
  dex                          ; $9994
  bne Loc_B4_998D              ; $9995
  beq Loc_B4_9982              ; $9997
Loc_B4_9999:
  and #$7F                     ; $9999
  bne Loc_B4_999F              ; $999B
  lda #$80                     ; $999D
Loc_B4_999F:
  tax                          ; $999F
  iny                          ; $99A0
  lda Data_B4_99AE,y           ; $99A1
  iny                          ; $99A4
Loc_B4_99A5:
  sta PPU_DATA                 ; $99A5
  dex                          ; $99A8
  bne Loc_B4_99A5              ; $99A9
  beq Loc_B4_9982              ; $99AB
Loc_B4_99AD:
  rts                          ; $99AD
Data_B4_99AE:
  .incbin "prg_bank_4.bin", $19AE, $7E  ; $99AE
Sub_B4_9A2C:
  jsr ProcessPpuUpdateList     ; $9A2C
  .addr Data_B4_9A32  ; $9A2F inline pointer (data after a JSR)
  rts                          ; $9A31
Data_B4_9A32:
  .incbin "prg_bank_4.bin", $1A32, $41  ; $9A32
Sub_B4_9A73:
  ldy #$00                     ; $9A73
  sty z:$6C                    ; $9A75
Loc_B4_9A77:
  lda Data_B4_9AF9,y           ; $9A77
  tax                          ; $9A7A
  lda z:$9B,x                  ; $9A7B
  beq Loc_B4_9ACE              ; $9A7D
  sta z:$6A                    ; $9A7F
  lda z:$6C                    ; $9A81
  asl a                        ; $9A83
  tax                          ; $9A84
  lda Data_B4_9B0D,x           ; $9A85
  sta $0523                    ; $9A88
  lda Data_B4_9B0E,x           ; $9A8B
  sta $0524                    ; $9A8E
  jsr $0520                    ; $9A91
  lda z:$6A                    ; $9A94
  cmp #$03                     ; $9A96
  bne Loc_B4_9ACE              ; $9A98
  lda z:$6C                    ; $9A9A
  asl a                        ; $9A9C
  tax                          ; $9A9D
  lda Data_B4_9B35,x           ; $9A9E
  sta $0523                    ; $9AA1
  lda Data_B4_9B36,x           ; $9AA4
  sta $0524                    ; $9AA7
  jsr $0520                    ; $9AAA
  ldy z:$6C                    ; $9AAD
  lda Data_B4_9B5D,y           ; $9AAF
  bmi Loc_B4_9ACE              ; $9AB2
  sta z:$60                    ; $9AB4
  lda $051A                    ; $9AB6
  and #$02                     ; $9AB9
  clc                          ; $9ABB
  adc z:$60                    ; $9ABC
  tax                          ; $9ABE
  lda Data_B4_9B71,x           ; $9ABF
  sta $0523                    ; $9AC2
  lda Data_B4_9B72,x           ; $9AC5
  sta $0524                    ; $9AC8
  jsr $0520                    ; $9ACB
Loc_B4_9ACE:
  inc z:$6C                    ; $9ACE
  ldy z:$6C                    ; $9AD0
  cpy #$14                     ; $9AD2
  bcc Loc_B4_9A77              ; $9AD4
  lda z:$9B                    ; $9AD6
  cmp #$03                     ; $9AD8
  bne Loc_B4_9AE8              ; $9ADA
  lda $051A                    ; $9ADC
  and #$02                     ; $9ADF
  bne Loc_B4_9AE9              ; $9AE1
  jsr ProcessPpuUpdateList     ; $9AE3
  .addr Data_B4_9AF4  ; $9AE6 inline pointer (data after a JSR)
Loc_B4_9AE8:
  rts                          ; $9AE8
Loc_B4_9AE9:
  jsr ProcessPpuUpdateList     ; $9AE9
  .addr Data_B4_9AEF  ; $9AEC inline pointer (data after a JSR)
  rts                          ; $9AEE
Data_B4_9AEF:
  .incbin "prg_bank_4.bin", $1AEF, $5  ; $9AEF
Data_B4_9AF4:
  .incbin "prg_bank_4.bin", $1AF4, $5  ; $9AF4
Data_B4_9AF9:
  .incbin "prg_bank_4.bin", $1AF9, $14  ; $9AF9
Data_B4_9B0D:
  .incbin "prg_bank_4.bin", $1B0D, $1  ; $9B0D
Data_B4_9B0E:
  .incbin "prg_bank_4.bin", $1B0E, $27  ; $9B0E
Data_B4_9B35:
  .incbin "prg_bank_4.bin", $1B35, $1  ; $9B35
Data_B4_9B36:
  .incbin "prg_bank_4.bin", $1B36, $27  ; $9B36
Data_B4_9B5D:
  .incbin "prg_bank_4.bin", $1B5D, $14  ; $9B5D
Data_B4_9B71:
  .incbin "prg_bank_4.bin", $1B71, $1  ; $9B71
Data_B4_9B72:
  .incbin "prg_bank_4.bin", $1B72, $3A1  ; $9B72
Data_B4_9F13:
  .incbin "prg_bank_4.bin", $1F13, $5  ; $9F13
Data_B4_9F18:
  .incbin "prg_bank_4.bin", $1F18, $5  ; $9F18
Data_B4_9F1D:
  .incbin "prg_bank_4.bin", $1F1D, $9  ; $9F1D
Data_B4_9F26:
  .incbin "prg_bank_4.bin", $1F26, $9  ; $9F26
Sub_B4_9F2F:
  lda z:$9B                    ; $9F2F
  bne Loc_B4_9F7B              ; $9F31
  lda z:$A7                    ; $9F33
  bne Loc_B4_9F44              ; $9F35
  lda z:$9F                    ; $9F37
  bne Loc_B4_9F44              ; $9F39
  lda z:$A0                    ; $9F3B
  beq Loc_B4_9F44              ; $9F3D
  jsr ProcessPpuUpdateList     ; $9F3F
  .addr Data_B4_9F1D  ; $9F42 inline pointer (data after a JSR)
Loc_B4_9F44:
  lda z:$AB                    ; $9F44
  bne Loc_B4_9F55              ; $9F46
  lda z:$A3                    ; $9F48
  bne Loc_B4_9F55              ; $9F4A
  lda z:$A4                    ; $9F4C
  beq Loc_B4_9F55              ; $9F4E
  jsr ProcessPpuUpdateList     ; $9F50
  .addr Data_B4_9F26  ; $9F53 inline pointer (data after a JSR)
Loc_B4_9F55:
  lda z:$9C                    ; $9F55
  bne Loc_B4_9F7B              ; $9F57
  lda z:$A8                    ; $9F59
  bne Loc_B4_9F6A              ; $9F5B
  lda z:$A0                    ; $9F5D
  bne Loc_B4_9F6A              ; $9F5F
  lda z:$A1                    ; $9F61
  beq Loc_B4_9F6A              ; $9F63
  jsr ProcessPpuUpdateList     ; $9F65
  .addr Data_B4_9F13  ; $9F68 inline pointer (data after a JSR)
Loc_B4_9F6A:
  lda z:$AC                    ; $9F6A
  bne Loc_B4_9F7B              ; $9F6C
  lda z:$A4                    ; $9F6E
  bne Loc_B4_9F7B              ; $9F70
  lda z:$A5                    ; $9F72
  beq Loc_B4_9F7B              ; $9F74
  jsr ProcessPpuUpdateList     ; $9F76
  .addr Data_B4_9F18  ; $9F79 inline pointer (data after a JSR)
Loc_B4_9F7B:
  rts                          ; $9F7B
Sub_B4_9F7C:
  ldx #$0A                     ; $9F7C
Loc_B4_9F7E:
  lda Data_B4_9F89,x           ; $9F7E
  sta z:Tmp00,x                ; $9F81
  dex                          ; $9F83
  bpl Loc_B4_9F7E              ; $9F84
  jmp a:Tmp00                  ; $9F86
Data_B4_9F89:
  .incbin "prg_bank_4.bin", $1F89, $B  ; $9F89
Sub_B4_9F94:
  lda $051F                    ; $9F94
  and #$03                     ; $9F97
  sta $051F                    ; $9F99
  bne Loc_B4_9F9F              ; $9F9C
  rts                          ; $9F9E
Loc_B4_9F9F:
  tax                          ; $9F9F
  dex                          ; $9FA0
  beq Loc_B4_9FB6              ; $9FA1
  dex                          ; $9FA3
  beq Loc_B4_9FAE              ; $9FA4
  ldy #$46                     ; $9FA6
  jsr Sub_B4_9FD3              ; $9FA8
  jsr Sub_B4_9074              ; $9FAB
Loc_B4_9FAE:
  ldy #$44                     ; $9FAE
  jsr Sub_B4_9FD3              ; $9FB0
  jsr Sub_B4_9074              ; $9FB3
Loc_B4_9FB6:
  ldy #$42                     ; $9FB6
  jsr Sub_B4_9FD3              ; $9FB8
  jmp Sub_B4_9074              ; $9FBB
  lda $051F                    ; $9FBE  [heuristic code]
  and #$03                     ; $9FC1
  beq Loc_B4_9FD2              ; $9FC3
  tax                          ; $9FC5
  dex                          ; $9FC6
  ldy Data_B4_9FE9,x           ; $9FC7
  jsr Sub_B4_9FD3              ; $9FCA
  lda #$01                     ; $9FCD
  sta $0502                    ; $9FCF
Loc_B4_9FD2:
  rts                          ; $9FD2
Sub_B4_9FD3:
  ldx #$0A                     ; $9FD3
Loc_B4_9FD5:
  lda Data_B4_9FEC,x           ; $9FD5
  sta $054A,x                  ; $9FD8
  dex                          ; $9FDB
  bpl Loc_B4_9FD5              ; $9FDC
  tya                          ; $9FDE
  sta $054B                    ; $9FDF
  clc                          ; $9FE2
  adc #$20                     ; $9FE3
  sta $0550                    ; $9FE5
  rts                          ; $9FE8
Data_B4_9FE9:
  .incbin "prg_bank_4.bin", $1FE9, $3  ; $9FE9
Data_B4_9FEC:
  .incbin "prg_bank_4.bin", $1FEC, $B  ; $9FEC
Loc_B4_9FF7:
  lda $051F                    ; $9FF7
  and #$03                     ; $9FFA
  cmp #$03                     ; $9FFC
  beq Loc_B4_A01A              ; $9FFE
  tax                          ; $A000
  ldy Data_B4_9FE9,x           ; $A001
  jsr Sub_B4_9FD3              ; $A004
  lda #$01                     ; $A007
  sta $0502                    ; $A009
  lda #$00                     ; $A00C
  sta $054D                    ; $A00E
  sta $054E                    ; $A011
  sta $0552                    ; $A014
  sta $0553                    ; $A017
Loc_B4_A01A:
  rts                          ; $A01A
Sub_B4_A01B:
  lda $050C                    ; $A01B
  beq Loc_B4_A026              ; $A01E
  jsr Sub_B4_A04D              ; $A020
  jsr $0520                    ; $A023
Loc_B4_A026:
  lda $050B                    ; $A026
  beq Loc_B4_A031              ; $A029
  jsr Sub_B4_A068              ; $A02B
  jsr $0520                    ; $A02E
Loc_B4_A031:
  lda $050A                    ; $A031
  beq Loc_B4_A03C              ; $A034
  jsr Sub_B4_A083              ; $A036
  jsr $0520                    ; $A039
Loc_B4_A03C:
  lda $0508                    ; $A03C
  beq Loc_B4_A047              ; $A03F
  jsr Sub_B4_A09E              ; $A041
  jsr $0520                    ; $A044
Loc_B4_A047:
  rts                          ; $A047
  .incbin "prg_bank_4.bin", $2048, $5  ; $A048
Sub_B4_A04D:
  lda #$58                     ; $A04D
  sta $0523                    ; $A04F
  lda #$A0                     ; $A052
  sta $0524                    ; $A054
  rts                          ; $A057
  .incbin "prg_bank_4.bin", $2058, $10  ; $A058
Sub_B4_A068:
  lda #$73                     ; $A068
  sta $0523                    ; $A06A
  lda #$A0                     ; $A06D
  sta $0524                    ; $A06F
  rts                          ; $A072
  .incbin "prg_bank_4.bin", $2073, $10  ; $A073
Sub_B4_A083:
  lda #$8E                     ; $A083
  sta $0523                    ; $A085
  lda #$A0                     ; $A088
  sta $0524                    ; $A08A
  rts                          ; $A08D
  .incbin "prg_bank_4.bin", $208E, $10  ; $A08E
Sub_B4_A09E:
  lda #$A9                     ; $A09E
  sta $0523                    ; $A0A0
  lda #$A0                     ; $A0A3
  sta $0524                    ; $A0A5
  rts                          ; $A0A8
  .incbin "prg_bank_4.bin", $20A9, $30  ; $A0A9
Sub_B4_A0D9:
  lda z:$9B                    ; $A0D9
  cmp #$02                     ; $A0DB
  beq Loc_B4_A0E4              ; $A0DD
  lda #$00                     ; $A0DF
  sta z:$83                    ; $A0E1
  rts                          ; $A0E3
Loc_B4_A0E4:
  jsr Sub_B4_96EA              ; $A0E4
  ldx z:$82                    ; $A0E7
  lda Data_B4_A0FE,x           ; $A0E9
  sta z:$83                    ; $A0EC
  lsr a                        ; $A0EE
  bcc Loc_B4_A0F4              ; $A0EF
  jsr Sub_B4_A114              ; $A0F1
Loc_B4_A0F4:
  lda z:$83                    ; $A0F4
  and #$02                     ; $A0F6
  beq Loc_B4_A0FD              ; $A0F8
  jmp Loc_B4_A144              ; $A0FA
Loc_B4_A0FD:
  rts                          ; $A0FD
Data_B4_A0FE:
  .incbin "prg_bank_4.bin", $20FE, $16  ; $A0FE
Sub_B4_A114:
  jsr ProcessPpuUpdateList     ; $A114
  .addr Data_B4_A123  ; $A117 inline pointer (data after a JSR)
  jsr Sub_B4_8FAB              ; $A119
  lda #$D4                     ; $A11C
  ldy #$00                     ; $A11E
  sta (Tmp00),y                ; $A120
  rts                          ; $A122
Data_B4_A123:
  .incbin "prg_bank_4.bin", $2123, $21  ; $A123
Loc_B4_A144:
  jsr ProcessPpuUpdateList     ; $A144
  .addr Data_B4_A153  ; $A147 inline pointer (data after a JSR)
  jsr Sub_B4_8FAB              ; $A149
  lda #$D5                     ; $A14C
  ldy #$00                     ; $A14E
  sta (Tmp00),y                ; $A150
  rts                          ; $A152
Data_B4_A153:
  .incbin "prg_bank_4.bin", $2153, $C  ; $A153
Sub_B4_A15F:
  ldx #$0A                     ; $A15F
Loc_B4_A161:
  lda Data_B4_A16C,x           ; $A161
  sta z:Tmp00,x                ; $A164
  dex                          ; $A166
  bpl Loc_B4_A161              ; $A167
  jmp a:Tmp00                  ; $A169
Data_B4_A16C:
  .incbin "prg_bank_4.bin", $216C, $400  ; $A16C
  .incbin "prg_bank_4.bin", $256C, $400  ; $A56C
  .incbin "prg_bank_4.bin", $296C, $400  ; $A96C
  .incbin "prg_bank_4.bin", $2D6C, $27C  ; $AD6C
Sub_B4_AFE8:
  ldx #$05                     ; $AFE8
  stx $0502                    ; $AFEA
  ldx #$0F                     ; $AFED
  stx $052A                    ; $AFEF
  ldx z:$87                    ; $AFF2
  jmp Sub_B4_95C8              ; $AFF4
  .incbin "prg_bank_4.bin", $2FF7, $400  ; $AFF7
  .incbin "prg_bank_4.bin", $33F7, $B  ; $B3F7
Sub_B4_B402:
  lda ObjectCount              ; $B402
  cmp #$0F                     ; $B405
  bcs Loc_B4_B414              ; $B407
  inc ObjectCount              ; $B409
  jsr AslA4                    ; $B40C
  tax                          ; $B40F
  tya                          ; $B410
  sta ObjectTable,x            ; $B411
Loc_B4_B414:
  rts                          ; $B414
  ldx #$02                     ; $B415  [heuristic code]
  ldy #$02                     ; $B417
  lda (Tmp00),y                ; $B419
  cmp #$78                     ; $B41B
  beq Loc_B4_B423              ; $B41D
  bcc Loc_B4_B424              ; $B41F
  dex                          ; $B421
  dex                          ; $B422
Loc_B4_B423:
  dex                          ; $B423
Loc_B4_B424:
  txa                          ; $B424
  ldy #$0C                     ; $B425
  sta (Tmp00),y                ; $B427
  rts                          ; $B429
  lda #$00                     ; $B42A  [heuristic code]
  sta z:HwScrollX              ; $B42C
  sta z:HwScrollY              ; $B42E
  ldy #$0B                     ; $B430
  sta (Tmp00),y                ; $B432
  lda #$FF                     ; $B434
  ldy #$0D                     ; $B436
  sta (Tmp00),y                ; $B438
  inc z:$84                    ; $B43A
  rts                          ; $B43C
  sta z:$6A                    ; $B43D  [heuristic code]
  lda z:PlayerLifeLo           ; $B43F
  sec                          ; $B441
  sbc z:$6A                    ; $B442
  sta z:PlayerLifeLo           ; $B444
  bcs Loc_B4_B44A              ; $B446
  dec z:PlayerLifeHi           ; $B448
Loc_B4_B44A:
  rts                          ; $B44A
  clc                          ; $B44B  [heuristic code]
  adc z:PlayerLifeLo           ; $B44C
  bcs Loc_B4_B454              ; $B44E
  cmp #$C8                     ; $B450
  bcc Loc_B4_B456              ; $B452
Loc_B4_B454:
  lda #$C8                     ; $B454
Loc_B4_B456:
  sta z:PlayerLifeLo           ; $B456
  txa                          ; $B458
  ldx z:AmmoHi                 ; $B459
  clc                          ; $B45B
  adc z:AmmoLo                 ; $B45C
  bcc Loc_B4_B461              ; $B45E
  inx                          ; $B460
Loc_B4_B461:
  cpx #$01                     ; $B461
  bcc Loc_B4_B46F              ; $B463
  bne Loc_B4_B46B              ; $B465
  cmp #$90                     ; $B467
  bcc Loc_B4_B46F              ; $B469
Loc_B4_B46B:
  ldx #$01                     ; $B46B
  lda #$90                     ; $B46D
Loc_B4_B46F:
  stx z:AmmoHi                 ; $B46F
  sta z:AmmoLo                 ; $B471
  rts                          ; $B473
Sub_B4_B474:
  jsr Sub_B4_B4B2              ; $B474
  beq Loc_B4_B4B1              ; $B477
Loc_B4_B479:
  jsr Sub_B4_B4BB              ; $B479
  dec $0302                    ; $B47C
  bne Loc_B4_B479              ; $B47F
  ldy #$06                     ; $B481
  lda Data_C347,y              ; $B483
  sta z:Tmp02                  ; $B486
  jsr Sub_B4_B4B2              ; $B488
  beq Loc_B4_B4B1              ; $B48B
Loc_B4_B48D:
  ldx #$00                     ; $B48D
  lda $0302                    ; $B48F
  jsr AslA4                    ; $B492
  tay                          ; $B495
  lda $0300,y                  ; $B496
  bpl Loc_B4_B4A8              ; $B499
  lda $0304,y                  ; $B49B
  asl a                        ; $B49E
  asl a                        ; $B49F
  adc z:Tmp02                  ; $B4A0
  bcs Loc_B4_B4A8              ; $B4A2
  ldx z:Tmp02                  ; $B4A4
  sta z:Tmp02                  ; $B4A6
Loc_B4_B4A8:
  txa                          ; $B4A8
  sta $0303,y                  ; $B4A9
  dec $0302                    ; $B4AC
  bne Loc_B4_B48D              ; $B4AF
Loc_B4_B4B1:
  rts                          ; $B4B1
Sub_B4_B4B2:
  lda ObjectCount              ; $B4B2
  and #$0F                     ; $B4B5
  sta $0302                    ; $B4B7
  rts                          ; $B4BA
Sub_B4_B4BB:
  lda $0302                    ; $B4BB
  jsr AslA4                    ; $B4BE
  tay                          ; $B4C1
  sta z:Tmp00                  ; $B4C2
  lda #$03                     ; $B4C4
  sta z:Tmp01                  ; $B4C6
  lda $0300,y                  ; $B4C8
  and #$3F                     ; $B4CB
  asl a                        ; $B4CD
  tax                          ; $B4CE
  lda Data_B4_B4DC,x           ; $B4CF
  sta z:Tmp02                  ; $B4D2
  lda Data_B4_B4DD,x           ; $B4D4
  sta z:Tmp03                  ; $B4D7
  jmp ($0002)                  ; $B4D9
Data_B4_B4DC:
  .incbin "prg_bank_4.bin", $34DC, $1  ; $B4DC
Data_B4_B4DD:
  .incbin "prg_bank_4.bin", $34DD, $400  ; $B4DD
  .incbin "prg_bank_4.bin", $38DD, $400  ; $B8DD
  .incbin "prg_bank_4.bin", $3CDD, $320  ; $BCDD
Data_B4_BFFD:
  .incbin "prg_bank_4.bin", $3FFD, $3  ; $BFFD
