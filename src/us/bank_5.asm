; Bank 5  ($8000-$BFFF switchable)
; Intro, Vic Tokai logo, title screen, act title cards and the 'To be continued' screen.
.segment "PRG_BANK_5"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B5_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_5.bin", $0009, $7  ; $8009
Bank5Nmi:
  lda PPU_STATUS               ; $8010
  lda z:PpuCtrlShadow          ; $8013
  and #$7F                     ; $8015
  jsr SetPpuCtrl               ; $8017
  lda $0600                    ; $801A
  cmp #$60                     ; $801D
  beq Loc_B5_8032              ; $801F
  jsr DoOamDma                 ; $8021
  jsr UploadPalette            ; $8024
  lda z:PpuMaskShadow          ; $8027
  sta PPU_MASK                 ; $8029
  jsr ApplyScroll              ; $802C
  jmp Loc_B5_8035              ; $802F
Loc_B5_8032:
  jsr $0568                    ; $8032
Loc_B5_8035:
  jsr Bank5SceneDispatch       ; $8035
  jsr ApplyScroll              ; $8038
  jsr ReadJoypads              ; $803B
  jsr Sub_B5_838E              ; $803E
  jsr Sub_B5_9082              ; $8041
  lda PPU_STATUS               ; $8044
  lda z:PpuCtrlShadow          ; $8047
  ora #$80                     ; $8049
  jsr SetPpuCtrl               ; $804B
  rti                          ; $804E
Bank5SceneDispatch:
  lda SceneState               ; $804F
  asl a                        ; $8052
  tax                          ; $8053
  lda Data_B5_8061,x           ; $8054
  sta z:Tmp00                  ; $8057
  lda Data_B5_8062,x           ; $8059
  sta z:Tmp01                  ; $805C
  jmp ($0000)                  ; $805E
Data_B5_8061:
  .addr Sub_B5_8139, Sub_B5_8153, Sub_B5_8158, Sub_B5_815D, Sub_B5_816B, Sub_B5_8176, Sub_B5_818A, Sub_B5_819E, Sub_B5_81AC, Sub_B5_81BD, Sub_B5_81CB, Sub_B5_81E2, Sub_B5_81EB, Sub_B5_81F6, Sub_B5_820B, Sub_B5_821C, Sub_B5_822A, Sub_B5_8236, Sub_B5_8253, Sub_B5_825E, Sub_B5_828A, Sub_B5_829D, Sub_B5_82B7, Sub_B5_82C5, Sub_B5_82E0, Sub_B5_82FB, Sub_B5_8306, Sub_B5_8311, Sub_B5_8322, Sub_B5_8333, Sub_B5_8344, Sub_B5_8358, Sub_B5_8361, Sub_B5_836C, Sub_B5_837A, Sub_B5_8386, Sub_B5_838A, Sub_B5_83B3, Sub_B5_83C2, Sub_B5_83DB, Sub_B5_83EC, Sub_B5_843C, Sub_B5_8457, Sub_B5_8488, Sub_B5_8496, Sub_B5_85BC, Sub_B5_85C2, Sub_B5_85D0, Sub_B5_82FB, Sub_B5_8306, Sub_B5_8311, Sub_B5_8322, Sub_B5_8333, Sub_B5_8344, Sub_B5_8358, Sub_B5_849F, Sub_B5_84A5, Sub_B5_84B0, Sub_B5_84CA, Sub_B5_84DA, Sub_B5_84F3, Sub_B5_8488, Sub_B5_8496, Sub_B5_82FB, Sub_B5_8306, Sub_B5_8311, Sub_B5_8322, Sub_B5_8333, Sub_B5_8344, Sub_B5_8358, Sub_B5_8513, Sub_B5_8520, Sub_B5_8535, Sub_B5_8554, Sub_B5_8566, Sub_B5_857E, Sub_B5_8591, Sub_B5_85A8, Sub_B5_8608, Sub_B5_860E, Sub_B5_861F, Sub_B5_862D, Sub_B5_8646, Sub_B5_864C, Sub_B5_865D, Sub_B5_8672, Sub_B5_8678, Sub_B5_868E, Sub_B5_869C, Sub_B5_86A2, Sub_B5_86BB, Sub_B5_86CC, Sub_B5_86D2, Sub_B5_86DD  ; $8061 pointer table
  .incbin "prg_bank_5.bin", $011D, $1C  ; $811D
Sub_B5_8139:
  lda #$04                     ; $8139
Loc_B5_813B:
  sta SceneState               ; $813B
  jsr Sub_B5_8966              ; $813E
  jsr Sub_B5_90B3              ; $8141
  jsr Sub_B5_90A0              ; $8144
  lda #$00                     ; $8147
  jsr EnqueueByte              ; $8149
Sub_B5_814C:
  lda z:PpuMaskShadow          ; $814C
  and #$E7                     ; $814E
  jmp SetPpuMask               ; $8150
Sub_B5_8153:
  lda #$2B                     ; $8153
  jmp Loc_B5_813B              ; $8155
Sub_B5_8158:
  lda #$3D                     ; $8158
  jmp Loc_B5_813B              ; $815A
Sub_B5_815D:
  lda #$5F                     ; $815D
  ldx $050F                    ; $815F
  cpx #$33                     ; $8162
  bcc Loc_B5_8168              ; $8164
  lda #$68                     ; $8166
Loc_B5_8168:
  jmp Loc_B5_813B              ; $8168
Sub_B5_816B:
  inc SceneState               ; $816B
  lda #$00                     ; $816E
  sta $012A                    ; $8170
  jmp Loc_B5_8AAB              ; $8173
Sub_B5_8176:
  dec SceneTimer               ; $8176
  bne Loc_B5_8189              ; $8179
  inc SceneState               ; $817B
  lda #$0E                     ; $817E
  jsr EnqueueByte              ; $8180
Sub_B5_8183:
  lda z:PpuMaskShadow          ; $8183
  ora #$18                     ; $8185
  sta z:PpuMaskShadow          ; $8187
Loc_B5_8189:
  rts                          ; $8189
Sub_B5_818A:
  jsr Sub_B5_9237              ; $818A
  jsr Sub_B5_92DB              ; $818D
  lda $053F                    ; $8190
  bne Loc_B5_819D              ; $8193
  inc SceneState               ; $8195
  lda #$28                     ; $8198
  sta SceneTimer               ; $819A
Loc_B5_819D:
  rts                          ; $819D
Sub_B5_819E:
  dec SceneTimer               ; $819E
  bne Loc_B5_81AB              ; $81A1
  inc SceneState               ; $81A3
  lda #$01                     ; $81A6
  sta SceneSubState            ; $81A8
Loc_B5_81AB:
  rts                          ; $81AB
Sub_B5_81AC:
  jsr Bank5SubStateDispatch    ; $81AC
  lda AnimCounter              ; $81AF
  bne Loc_B5_81BC              ; $81B2
  inc SceneState               ; $81B4
  lda #$B4                     ; $81B7
  sta SceneTimer               ; $81B9
Loc_B5_81BC:
  rts                          ; $81BC
Sub_B5_81BD:
  dec SceneTimer               ; $81BD
  bne Loc_B5_81CA              ; $81C0
  inc SceneState               ; $81C2
  lda #$03                     ; $81C5
  sta SceneSubState            ; $81C7
Loc_B5_81CA:
  rts                          ; $81CA
Sub_B5_81CB:
  jsr Bank5SubStateDispatch    ; $81CB
  lda AnimCounter              ; $81CE
  bne Loc_B5_81E1              ; $81D1
  inc SceneState               ; $81D3
  lda #$1E                     ; $81D6
  sta SceneTimer               ; $81D8
  jsr Sub_B5_895B              ; $81DB
  jmp Sub_B5_8971              ; $81DE
Loc_B5_81E1:
  rts                          ; $81E1
Sub_B5_81E2:
  dec SceneTimer               ; $81E2
  bne Loc_B5_81EA              ; $81E5
  inc SceneState               ; $81E7
Loc_B5_81EA:
  rts                          ; $81EA
Sub_B5_81EB:
  inc SceneState               ; $81EB
  lda #$01                     ; $81EE
  sta $012A                    ; $81F0
  jmp Loc_B5_8FED              ; $81F3
Sub_B5_81F6:
  lda $0600                    ; $81F6
  cmp #$60                     ; $81F9
  beq Loc_B5_8205              ; $81FB
  inc SceneState               ; $81FD
  lda #$29                     ; $8200
  jsr EnqueueByte              ; $8202
Loc_B5_8205:
  jsr Sub_B5_8E22              ; $8205
  jmp Loc_B5_8F5D              ; $8208
Sub_B5_820B:
  jsr Sub_B5_8CC4              ; $820B
  lda $052E                    ; $820E
  bne Loc_B5_821B              ; $8211
  inc SceneState               ; $8213
  lda #$3C                     ; $8216
  sta SceneTimer               ; $8218
Loc_B5_821B:
  rts                          ; $821B
Sub_B5_821C:
  dec SceneTimer               ; $821C
  bne Loc_B5_8229              ; $821F
  inc SceneState               ; $8221
  lda #$04                     ; $8224
  sta SceneSubState            ; $8226
Loc_B5_8229:
  rts                          ; $8229
Sub_B5_822A:
  jsr Bank5SubStateDispatch    ; $822A
  lda AnimCounter              ; $822D
  bne Loc_B5_8235              ; $8230
  inc SceneState               ; $8232
Loc_B5_8235:
  rts                          ; $8235
Sub_B5_8236:
  inc SceneState               ; $8236
  lda #$02                     ; $8239
  sta $012A                    ; $823B
  jsr Sub_B5_897C              ; $823E
Loc_B5_8241:
  lda #$E0                     ; $8241
  sta $0528                    ; $8243
  lda #$10                     ; $8246
  sta $0529                    ; $8248
  lda #$01                     ; $824B
  sta $052A                    ; $824D
  jmp EnqueueByte              ; $8250
Sub_B5_8253:
  dec SceneTimer               ; $8253
  bne Loc_B5_825B              ; $8256
  inc SceneState               ; $8258
Loc_B5_825B:
  jmp Sub_B5_8183              ; $825B
Sub_B5_825E:
  inc z:HwScrollX              ; $825E
  inc z:HwScrollX              ; $8260
  bne Loc_B5_8280              ; $8262
  inc SceneState               ; $8264
  lda #$33                     ; $8267
  sta z:PpuCtrlShadow          ; $8269
  lda #$5A                     ; $826B
  sta SceneTimer               ; $826D
  lda #$09                     ; $8270
  sta SceneSubState            ; $8272
  ldx #$03                     ; $8275
Loc_B5_8277:
  lda Data_B5_8286,x           ; $8277
  sta OamBuffer,x              ; $827A
  dex                          ; $827D
  bpl Loc_B5_8277              ; $827E
Loc_B5_8280:
  jsr ApplyScroll              ; $8280
  jmp Loc_B5_874E              ; $8283
Data_B5_8286:
  .incbin "prg_bank_5.bin", $0286, $4  ; $8286
Sub_B5_828A:
  jsr Bank5SubStateDispatch    ; $828A
  lda AnimCounter              ; $828D
  bne Loc_B5_829A              ; $8290
  inc SceneState               ; $8292
  lda #$96                     ; $8295
  sta SceneTimer               ; $8297
Loc_B5_829A:
  jmp Loc_B5_82E9              ; $829A
Sub_B5_829D:
  dec SceneTimer               ; $829D
  bne Loc_B5_82B4              ; $82A0
  inc SceneState               ; $82A2
  lda #$02                     ; $82A5
  sta $053B                    ; $82A7
  lda #$00                     ; $82AA
  sta $053E                    ; $82AC
  lda #$0A                     ; $82AF
  sta SceneSubState            ; $82B1
Loc_B5_82B4:
  jmp Loc_B5_82E9              ; $82B4
Sub_B5_82B7:
  jsr Bank5SubStateDispatch    ; $82B7
  lda AnimCounter              ; $82BA
  bne Loc_B5_82C2              ; $82BD
  inc SceneState               ; $82BF
Loc_B5_82C2:
  jmp Loc_B5_82E9              ; $82C2
Sub_B5_82C5:
  inc z:HwScrollX              ; $82C5
  inc z:HwScrollX              ; $82C7
  bne Loc_B5_82DA              ; $82C9
  inc SceneState               ; $82CB
  lda #$30                     ; $82CE
  sta z:PpuCtrlShadow          ; $82D0
  lda #$3C                     ; $82D2
  sta SceneTimer               ; $82D4
  jmp Sub_B5_814C              ; $82D7
Loc_B5_82DA:
  jsr ApplyScroll              ; $82DA
  jmp Loc_B5_874E              ; $82DD
Sub_B5_82E0:
  dec SceneTimer               ; $82E0
  bne Loc_B5_82E8              ; $82E3
  inc SceneState               ; $82E5
Loc_B5_82E8:
  rts                          ; $82E8
Loc_B5_82E9:
  lda #$0D                     ; $82E9
  jsr MmcWriteChr1A            ; $82EB
Loc_B5_82EE:
  bit PPU_STATUS               ; $82EE
  bvs Loc_B5_82EE              ; $82F1
Loc_B5_82F3:
  bit PPU_STATUS               ; $82F3
  bvc Loc_B5_82F3              ; $82F6
  jmp MmcWriteChr1             ; $82F8
Sub_B5_82FB:
  inc SceneState               ; $82FB
  lda #$03                     ; $82FE
  sta $012A                    ; $8300
  jmp Sub_B5_9206              ; $8303
Sub_B5_8306:
  inc SceneState               ; $8306
  lda #$05                     ; $8309
  sta SceneSubState            ; $830B
  jmp Sub_B5_8183              ; $830E
Sub_B5_8311:
  jsr Bank5SubStateDispatch    ; $8311
  lda AnimCounter              ; $8314
  bne Loc_B5_8321              ; $8317
  inc SceneState               ; $8319
  lda #$3C                     ; $831C
  sta SceneTimer               ; $831E
Loc_B5_8321:
  rts                          ; $8321
Sub_B5_8322:
  dec SceneTimer               ; $8322
  bne Loc_B5_8332              ; $8325
  inc SceneState               ; $8327
  lda #$0F                     ; $832A
  sta $0141                    ; $832C
  sta $0142                    ; $832F
Loc_B5_8332:
  rts                          ; $8332
Sub_B5_8333:
  jsr Sub_B5_887E              ; $8333
  lda $052B                    ; $8336
  bne Loc_B5_8343              ; $8339
  inc SceneState               ; $833B
  lda #$06                     ; $833E
  sta SceneSubState            ; $8340
Loc_B5_8343:
  rts                          ; $8343
Sub_B5_8344:
  jsr Bank5SubStateDispatch    ; $8344
  lda AnimCounter              ; $8347
  bne Loc_B5_8357              ; $834A
  inc SceneState               ; $834C
  jsr Sub_B5_814C              ; $834F
  lda #$28                     ; $8352
  sta SceneTimer               ; $8354
Loc_B5_8357:
  rts                          ; $8357
Sub_B5_8358:
  dec SceneTimer               ; $8358
  bne Loc_B5_8360              ; $835B
  inc SceneState               ; $835D
Loc_B5_8360:
  rts                          ; $8360
Sub_B5_8361:
  inc SceneState               ; $8361
  lda #$04                     ; $8364
  sta $012A                    ; $8366
  jmp Loc_B5_903F              ; $8369
Sub_B5_836C:
  inc SceneState               ; $836C
  lda #$3C                     ; $836F
  sta $0547                    ; $8371
  jsr Sub_B5_8F3A              ; $8374
  jmp Sub_B5_8183              ; $8377
Sub_B5_837A:
  jsr $0513                    ; $837A
  lda $0547                    ; $837D
  bne Loc_B5_8385              ; $8380
  inc SceneState               ; $8382
Loc_B5_8385:
  rts                          ; $8385
Sub_B5_8386:
  inc SceneState               ; $8386
  rts                          ; $8389
Sub_B5_838A:
  inc SceneState               ; $838A
  rts                          ; $838D
Sub_B5_838E:
  lda SceneState               ; $838E
  cmp #$61                     ; $8391
  beq Loc_B5_83A1              ; $8393
  cmp #$64                     ; $8395
  beq Loc_B5_83A1              ; $8397
  cmp #$05                     ; $8399
  bcc Loc_B5_83B2              ; $839B
  cmp #$25                     ; $839D
  bcs Loc_B5_83B2              ; $839F
Loc_B5_83A1:
  lda JoyNew1                  ; $83A1
  and #$08                     ; $83A4
  beq Loc_B5_83B2              ; $83A6
  lda #$25                     ; $83A8
  sta SceneState               ; $83AA
  lda #$00                     ; $83AD
  sta $0600                    ; $83AF
Loc_B5_83B2:
  rts                          ; $83B2
Sub_B5_83B3:
  inc SceneState               ; $83B3
  jsr Sub_B5_90C8              ; $83B6
  lda $052A                    ; $83B9
  bne Loc_B5_83C1              ; $83BC
  jmp EnqueueByte              ; $83BE
Loc_B5_83C1:
  rts                          ; $83C1
Sub_B5_83C2:
  inc SceneState               ; $83C2
  lda #$00                     ; $83C5
  sta AnimCounter              ; $83C7
  lda #$07                     ; $83CA
  sta SceneSubState            ; $83CC
  jsr Sub_B5_8183              ; $83CF
  lda $052A                    ; $83D2
  bne Loc_B5_83DA              ; $83D5
  jmp Loc_B5_8241              ; $83D7
Loc_B5_83DA:
  rts                          ; $83DA
Sub_B5_83DB:
  jsr Bank5SubStateDispatch    ; $83DB
  lda AnimCounter              ; $83DE
  bne Loc_B5_83E6              ; $83E1
  inc SceneState               ; $83E3
Loc_B5_83E6:
  jsr Sub_B5_8462              ; $83E6
  jmp Loc_B5_8467              ; $83E9
Sub_B5_83EC:
  jsr Sub_B5_8462              ; $83EC
  lda JoyNew1                  ; $83EF
  and #$08                     ; $83F2
  beq Loc_B5_8418              ; $83F4
  jsr Sub_B5_814C              ; $83F6
  lda #$00                     ; $83F9
  sta z:MmcPrgShadow           ; $83FB
  sta z:GameState              ; $83FD
  lda #$C8                     ; $83FF
  sta z:PlayerLifeLo           ; $8401
  jsr Sub_B5_8971              ; $8403
  lda $050F                    ; $8406
  beq Loc_B5_8418              ; $8409
  lda #$01                     ; $840B
  sta $013E                    ; $840D
  lda #$03                     ; $8410
  sta $0106                    ; $8412
  jmp Loc_B5_8426              ; $8415
Loc_B5_8418:
  sta $013E                    ; $8418
  sta $0106                    ; $841B
  sta z:$28                    ; $841E
  sta z:$29                    ; $8420
  sta z:$2A                    ; $8422
  sta z:$2B                    ; $8424
Loc_B5_8426:
  lda $0528                    ; $8426
  ora $0529                    ; $8429
  bne Loc_B5_8439              ; $842C
  inc SceneState               ; $842E
  sta $052A                    ; $8431
  lda #$08                     ; $8434
  sta SceneSubState            ; $8436
Loc_B5_8439:
  jmp Loc_B5_8467              ; $8439
Sub_B5_843C:
  jsr Bank5SubStateDispatch    ; $843C
  lda AnimCounter              ; $843F
  bne Loc_B5_8451              ; $8442
  inc SceneState               ; $8444
  lda #$3C                     ; $8447
  sta SceneTimer               ; $8449
  lda #$00                     ; $844C
  jmp EnqueueByte              ; $844E
Loc_B5_8451:
  jsr Sub_B5_8462              ; $8451
  jmp Loc_B5_8467              ; $8454
Sub_B5_8457:
  dec SceneTimer               ; $8457
  bne Loc_B5_8461              ; $845A
  lda #$00                     ; $845C
  sta SceneState               ; $845E
Loc_B5_8461:
  rts                          ; $8461
Sub_B5_8462:
  lda z:MmcChr1Shadow          ; $8462
  jmp MmcWriteChr1A            ; $8464
Loc_B5_8467:
  lda z:MmcPrgShadow           ; $8467
  beq Loc_B5_8487              ; $8469
  lda z:PpuMaskShadow          ; $846B
  and #$18                     ; $846D
  cmp #$18                     ; $846F
  bne Loc_B5_8487              ; $8471
Loc_B5_8473:
  bit PPU_STATUS               ; $8473
  bvs Loc_B5_8473              ; $8476
Loc_B5_8478:
  bit PPU_STATUS               ; $8478
  bvc Loc_B5_8478              ; $847B
  ldx #$C8                     ; $847D
Loc_B5_847F:
  dex                          ; $847F
  bne Loc_B5_847F              ; $8480
  lda #$0D                     ; $8482
  jmp MmcWriteChr1A            ; $8484
Loc_B5_8487:
  rts                          ; $8487
Sub_B5_8488:
  inc SceneState               ; $8488
  lda #$3C                     ; $848B
  sta SceneTimer               ; $848D
  jsr Sub_B5_895B              ; $8490
  jmp Sub_B5_814C              ; $8493
Sub_B5_8496:
  dec SceneTimer               ; $8496
  bne Loc_B5_849E              ; $8499
  inc SceneState               ; $849B
Loc_B5_849E:
  rts                          ; $849E
Sub_B5_849F:
  inc SceneState               ; $849F
  jmp Loc_B5_948C              ; $84A2
Sub_B5_84A5:
  inc SceneState               ; $84A5
  jsr Sub_B5_8183              ; $84A8
  lda #$15                     ; $84AB
  jmp EnqueueByte              ; $84AD
Sub_B5_84B0:
  jsr Sub_B5_9974              ; $84B0
  jsr Sub_B5_9438              ; $84B3
  lda SceneTimer               ; $84B6
  beq Loc_B5_84C9              ; $84B9
  inc SceneState               ; $84BB
  lda #$00                     ; $84BE
  tax                          ; $84C0
  jsr Sub_B5_9895              ; $84C1
  lda #$01                     ; $84C4
  jsr Sub_B5_9895              ; $84C6
Loc_B5_84C9:
  rts                          ; $84C9
Sub_B5_84CA:
  lda JoyNew1                  ; $84CA
  and #$01                     ; $84CD
  beq Loc_B5_84D9              ; $84CF
  inc SceneState               ; $84D1
  lda #$0F                     ; $84D4
  jmp EnqueueByte              ; $84D6
Loc_B5_84D9:
  rts                          ; $84D9
Sub_B5_84DA:
  jsr Sub_B5_986D              ; $84DA
  lda $0505                    ; $84DD
  bne Loc_B5_84F2              ; $84E0
  inc SceneState               ; $84E2
  lda #$5A                     ; $84E5
  sta SceneTimer               ; $84E7
  jsr Sub_B5_895B              ; $84EA
  lda #$00                     ; $84ED
  jmp EnqueueByte              ; $84EF
Loc_B5_84F2:
  rts                          ; $84F2
Sub_B5_84F3:
  dec SceneTimer               ; $84F3
  bne Loc_B5_8512              ; $84F6
  ldy #$00                     ; $84F8
  sty z:MmcPrgShadow           ; $84FA
  sty z:PaletteDirty           ; $84FC
  sty z:GameState              ; $84FE
  iny                          ; $8500
  sty z:$28                    ; $8501
  sty $0507                    ; $8503
  ldy #$03                     ; $8506
  sty z:$29                    ; $8508
  ldy #$70                     ; $850A
  sty z:$2A                    ; $850C
  ldy #$AA                     ; $850E
  sty z:$2B                    ; $8510
Loc_B5_8512:
  rts                          ; $8512
Sub_B5_8513:
  jsr Sub_B5_849F              ; $8513
  jsr Sub_B5_8971              ; $8516
  lda #$05                     ; $8519
  ldx #$00                     ; $851B
  jmp Sub_B5_9895              ; $851D
Sub_B5_8520:
  inc SceneState               ; $8520
  jsr Sub_B5_8183              ; $8523
Loc_B5_8526:
  lda #$72                     ; $8526
  sta $0528                    ; $8528
  lda #$04                     ; $852B
  sta $0529                    ; $852D
  lda #$1E                     ; $8530
  jmp EnqueueByte              ; $8532
Sub_B5_8535:
  lda JoyNew1                  ; $8535
  and #$02                     ; $8538
  beq Loc_B5_854B              ; $853A
  inc SceneState               ; $853C
  lda #$06                     ; $853F
  ldx #$00                     ; $8541
  jsr Sub_B5_9895              ; $8543
  lda #$1D                     ; $8546
  jmp EnqueueByte              ; $8548
Loc_B5_854B:
  lda $0528                    ; $854B
  ora $0529                    ; $854E
  beq Loc_B5_8526              ; $8551
  rts                          ; $8553
Sub_B5_8554:
  jsr Sub_B5_976B              ; $8554
  lda JoyNew1                  ; $8557
  and #$01                     ; $855A
  beq Loc_B5_854B              ; $855C
  inc SceneState               ; $855E
  lda #$0F                     ; $8561
  jmp EnqueueByte              ; $8563
Sub_B5_8566:
  jsr Sub_B5_9848              ; $8566
  lda $052E                    ; $8569
  bne Loc_B5_854B              ; $856C
  inc SceneState               ; $856E
  lda #$3C                     ; $8571
  sta SceneTimer               ; $8573
  jsr Sub_B5_8971              ; $8576
  lda #$07                     ; $8579
  jmp Sub_B5_9895              ; $857B
Sub_B5_857E:
  dec SceneTimer               ; $857E
  bne Loc_B5_854B              ; $8581
  inc SceneState               ; $8583
  lda #$F0                     ; $8586
  sta SceneTimer               ; $8588
  jsr Sub_B5_895B              ; $858B
  jmp Sub_B5_8971              ; $858E
Sub_B5_8591:
  dec SceneTimer               ; $8591
  bne Loc_B5_854B              ; $8594
  inc SceneState               ; $8596
  lda #$02                     ; $8599
  sta SceneTimer               ; $859B
  lda #$33                     ; $859E
  sta z:PpuCtrlShadow          ; $85A0
  lda #$20                     ; $85A2
  sta $014F                    ; $85A4
  rts                          ; $85A7
Sub_B5_85A8:
  lda $0528                    ; $85A8
  ora $0529                    ; $85AB
  bne Loc_B5_85BB              ; $85AE
  dec SceneTimer               ; $85B0
  beq Loc_B5_85B8              ; $85B3
  jmp Loc_B5_8526              ; $85B5
Loc_B5_85B8:
  inc SceneState               ; $85B8
Loc_B5_85BB:
  rts                          ; $85BB
Sub_B5_85BC:
  inc SceneState               ; $85BC
  jmp Loc_B5_9785              ; $85BF
Sub_B5_85C2:
  dec SceneTimer               ; $85C2
  bne Loc_B5_85CF              ; $85C5
  inc SceneState               ; $85C7
  lda #$15                     ; $85CA
  jmp EnqueueByte              ; $85CC
Loc_B5_85CF:
  rts                          ; $85CF
Sub_B5_85D0:
  lda #$1A                     ; $85D0
  sta z:MmcChr0Shadow          ; $85D2
  jsr MmcWriteChr0             ; $85D4
  lda #$1E                     ; $85D7
  jsr SetPpuMask               ; $85D9
  jsr Sub_B5_9681              ; $85DC
Loc_B5_85DF:
  bit PPU_STATUS               ; $85DF
  bvs Loc_B5_85DF              ; $85E2
Loc_B5_85E4:
  bit PPU_STATUS               ; $85E4
  bvc Loc_B5_85E4              ; $85E7
  ldx #$04                     ; $85E9
  ldy #$01                     ; $85EB
Loc_B5_85ED:
  dey                          ; $85ED
  bne Loc_B5_85ED              ; $85EE
  dex                          ; $85F0
  bne Loc_B5_85ED              ; $85F1
  lda #$0F                     ; $85F3
  sta z:MmcChr0Shadow          ; $85F5
  jsr MmcWriteChr0             ; $85F7
  lda JoyNew1                  ; $85FA
  and #$08                     ; $85FD
  beq Loc_B5_8607              ; $85FF
  inc SceneState               ; $8601
  jmp Sub_B5_814C              ; $8604
Loc_B5_8607:
  rts                          ; $8607
Sub_B5_8608:
  inc SceneState               ; $8608
  jmp Loc_B5_9D4A              ; $860B
Sub_B5_860E:
  dec SceneTimer               ; $860E
  bne Loc_B5_861E              ; $8611
  inc SceneState               ; $8613
  jsr Sub_B5_8183              ; $8616
  lda #$78                     ; $8619
  sta SceneTimer               ; $861B
Loc_B5_861E:
  rts                          ; $861E
Sub_B5_861F:
  dec SceneTimer               ; $861F
  bne Loc_B5_862C              ; $8622
  inc SceneState               ; $8624
  lda #$78                     ; $8627
  sta SceneTimer               ; $8629
Loc_B5_862C:
  rts                          ; $862C
Sub_B5_862D:
  dec SceneTimer               ; $862D
  bne Loc_B5_8643              ; $8630
  inc SceneState               ; $8632
  lda #$1C                     ; $8635
  ldx #$10                     ; $8637
  ldy #$0D                     ; $8639
  jsr Sub_B5_8FDE              ; $863B
  lda #$00                     ; $863E
  sta $0512                    ; $8640
Loc_B5_8643:
  jmp Sub_B5_814C              ; $8643
Sub_B5_8646:
  inc SceneState               ; $8646
  jmp Loc_B5_9A2E              ; $8649
Sub_B5_864C:
  lda $0512                    ; $864C
  beq Loc_B5_8659              ; $864F
  dec SceneTimer               ; $8651
  bne Loc_B5_865C              ; $8654
  jsr Sub_B5_8183              ; $8656
Loc_B5_8659:
  inc SceneState               ; $8659
Loc_B5_865C:
  rts                          ; $865C
Sub_B5_865D:
  lda $0512                    ; $865D
  beq Loc_B5_866E              ; $8660
  dec SceneTimer               ; $8662
  bne Loc_B5_866D              ; $8665
  dec SceneState               ; $8667
  dec SceneState               ; $866A
Loc_B5_866D:
  rts                          ; $866D
Loc_B5_866E:
  inc SceneState               ; $866E
  rts                          ; $8671
Sub_B5_8672:
  inc SceneState               ; $8672
  jmp Loc_B5_9D88              ; $8675
Sub_B5_8678:
  dec SceneTimer               ; $8678
  bne Loc_B5_868D              ; $867B
  lda $0507                    ; $867D
  beq Loc_B5_868A              ; $8680
  jsr Sub_B5_8183              ; $8682
  lda #$78                     ; $8685
  sta SceneTimer               ; $8687
Loc_B5_868A:
  inc SceneState               ; $868A
Loc_B5_868D:
  rts                          ; $868D
Sub_B5_868E:
  lda $0507                    ; $868E
  beq Loc_B5_8698              ; $8691
  dec SceneTimer               ; $8693
  bne Loc_B5_869B              ; $8696
Loc_B5_8698:
  inc SceneState               ; $8698
Loc_B5_869B:
  rts                          ; $869B
Sub_B5_869C:
  inc SceneState               ; $869C
  jmp Loc_B5_903F              ; $869F
Sub_B5_86A2:
  lda $0507                    ; $86A2
  beq Loc_B5_86B7              ; $86A5
  lda #$01                     ; $86A7
  sta $0545                    ; $86A9
  lda #$3C                     ; $86AC
  sta $0547                    ; $86AE
  jsr Sub_B5_8F3A              ; $86B1
  jsr Sub_B5_8183              ; $86B4
Loc_B5_86B7:
  inc SceneState               ; $86B7
  rts                          ; $86BA
Sub_B5_86BB:
  lda $0507                    ; $86BB
  beq Loc_B5_86C8              ; $86BE
  jsr $0513                    ; $86C0
  lda $0547                    ; $86C3
  bne Loc_B5_86CB              ; $86C6
Loc_B5_86C8:
  inc SceneState               ; $86C8
Loc_B5_86CB:
  rts                          ; $86CB
Sub_B5_86CC:
  inc SceneState               ; $86CC
  jmp Loc_B5_9D0C              ; $86CF
Sub_B5_86D2:
  inc SceneState               ; $86D2
  lda #$01                     ; $86D5
  sta SceneSubState            ; $86D7
  jmp Sub_B5_8183              ; $86DA
Sub_B5_86DD:
  jsr Bank5SubStateDispatch    ; $86DD
  lda AnimCounter              ; $86E0
  bne Loc_B5_86E8              ; $86E3
  inc SceneState               ; $86E5
Loc_B5_86E8:
  rts                          ; $86E8
  .incbin "prg_bank_5.bin", $06E9, $1  ; $86E9
  inc SceneState               ; $86EA
  lda #$06                     ; $86ED
  sta $012A                    ; $86EF
  jmp Loc_B5_9DBB              ; $86F2
  dec SceneTimer               ; $86F5
  bne Loc_B5_8700              ; $86F8
  inc SceneState               ; $86FA
  jmp Sub_B5_8183              ; $86FD
Loc_B5_8700:
  rts                          ; $8700
  lda $0528                    ; $8701
  ora $0529                    ; $8704
  bne Loc_B5_870C              ; $8707
  inc SceneState               ; $8709
Loc_B5_870C:
  rts                          ; $870C
  inc SceneState               ; $870D
  jmp Sub_B5_814C              ; $8710
  inc SceneState               ; $8713
  rts                          ; $8716
  inc SceneState               ; $8717
  rts                          ; $871A
  inc SceneState               ; $871B
  jmp Sub_B5_814C              ; $871E
  inc SceneState               ; $8721
  rts                          ; $8724
  lda #$25                     ; $8725
  sta SceneState               ; $8727
  rts                          ; $872A
  .incbin "prg_bank_5.bin", $072B, $9  ; $872B
Data_B5_8734:
  .incbin "prg_bank_5.bin", $0734, $1A  ; $8734
Loc_B5_874E:
  ldx #$04                     ; $874E
  jsr Sub_B5_8973              ; $8750
  lda $053A                    ; $8753
  sec                          ; $8756
  sbc $053B                    ; $8757
  sta $053A                    ; $875A
  bcs Loc_B5_8762              ; $875D
  dec $0539                    ; $875F
Loc_B5_8762:
  lda $053D                    ; $8762
  sec                          ; $8765
  sbc $053E                    ; $8766
  sta $053D                    ; $8769
  bcs Loc_B5_8771              ; $876C
  dec $053C                    ; $876E
Loc_B5_8771:
  ldx $053C                    ; $8771
  beq Loc_B5_877A              ; $8774
  inx                          ; $8776
  beq Loc_B5_8783              ; $8777
  rts                          ; $8779
Loc_B5_877A:
  ldy $0539                    ; $877A
  beq Loc_B5_878C              ; $877D
  iny                          ; $877F
  beq Loc_B5_87A3              ; $8780
  rts                          ; $8782
Loc_B5_8783:
  ldy $0539                    ; $8783
  beq Loc_B5_87BA              ; $8786
  iny                          ; $8788
  beq Loc_B5_87CD              ; $8789
  rts                          ; $878B
Loc_B5_878C:
  jsr Sub_B5_87E0              ; $878C
  bcs Loc_B5_879D              ; $878F
  jsr Sub_B5_87E8              ; $8791
  bcs Loc_B5_879D              ; $8794
  cmp #$F0                     ; $8796
  bcs Loc_B5_879D              ; $8798
  jsr Sub_B5_87F3              ; $879A
Loc_B5_879D:
  jsr Sub_B5_8806              ; $879D
  bcc Loc_B5_878C              ; $87A0
  rts                          ; $87A2
Loc_B5_87A3:
  jsr Sub_B5_87E0              ; $87A3
  bcc Loc_B5_87B4              ; $87A6
  jsr Sub_B5_87E8              ; $87A8
  bcs Loc_B5_87B4              ; $87AB
  cmp #$F0                     ; $87AD
  bcs Loc_B5_87B4              ; $87AF
  jsr Sub_B5_87F3              ; $87B1
Loc_B5_87B4:
  jsr Sub_B5_8806              ; $87B4
  bcc Loc_B5_87A3              ; $87B7
  rts                          ; $87B9
Loc_B5_87BA:
  jsr Sub_B5_87E0              ; $87BA
  bcs Loc_B5_87C7              ; $87BD
  jsr Sub_B5_87E8              ; $87BF
  bcc Loc_B5_87C7              ; $87C2
  jsr Sub_B5_87F3              ; $87C4
Loc_B5_87C7:
  jsr Sub_B5_8806              ; $87C7
  bcc Loc_B5_87BA              ; $87CA
  rts                          ; $87CC
Loc_B5_87CD:
  jsr Sub_B5_87E0              ; $87CD
  bcc Loc_B5_87DA              ; $87D0
  jsr Sub_B5_87E8              ; $87D2
  bcc Loc_B5_87DA              ; $87D5
  jsr Sub_B5_87F3              ; $87D7
Loc_B5_87DA:
  jsr Sub_B5_8806              ; $87DA
  bcc Loc_B5_87CD              ; $87DD
  rts                          ; $87DF
Sub_B5_87E0:
  lda Data_B5_880E,x           ; $87E0
  clc                          ; $87E3
  adc $053A                    ; $87E4
  rts                          ; $87E7
Sub_B5_87E8:
  sta $0207,y                  ; $87E8
  lda Data_B5_880C,x           ; $87EB
  clc                          ; $87EE
  adc $053D                    ; $87EF
  rts                          ; $87F2
Sub_B5_87F3:
  sta $0204,y                  ; $87F3
  lda Data_B5_880D,x           ; $87F6
  sta $0205,y                  ; $87F9
  lda #$00                     ; $87FC
  sta $0206,y                  ; $87FE
  iny                          ; $8801
  iny                          ; $8802
  iny                          ; $8803
  iny                          ; $8804
  rts                          ; $8805
Sub_B5_8806:
  inx                          ; $8806
  inx                          ; $8807
  inx                          ; $8808
  cpx #$72                     ; $8809
  rts                          ; $880B
Data_B5_880C:
  .incbin "prg_bank_5.bin", $080C, $1  ; $880C
Data_B5_880D:
  .incbin "prg_bank_5.bin", $080D, $1  ; $880D
Data_B5_880E:
  .incbin "prg_bank_5.bin", $080E, $70  ; $880E
Sub_B5_887E:
  jsr Sub_B5_8971              ; $887E
  ldx $052B                    ; $8881
  inx                          ; $8884
  cpx #$59                     ; $8885
  bcc Loc_B5_888B              ; $8887
  ldx #$00                     ; $8889
Loc_B5_888B:
  stx $052B                    ; $888B
  cpx #$14                     ; $888E
  bcc Loc_B5_8896              ; $8890
  cpx #$39                     ; $8892
  bcc Loc_B5_8897              ; $8894
Loc_B5_8896:
  rts                          ; $8896
Loc_B5_8897:
  txa                          ; $8897
  sec                          ; $8898
  sbc #$14                     ; $8899
  tax                          ; $889B
  lda Data_B5_8919,x           ; $889C
  tax                          ; $889F
  ldy Data_B5_893E,x           ; $88A0
  sty z:Tmp02                  ; $88A3
  asl a                        ; $88A5
  tax                          ; $88A6
  lda Data_B5_88E3,x           ; $88A7
  sta z:Tmp00                  ; $88AA
  lda Data_B5_88E4,x           ; $88AC
  sta z:Tmp01                  ; $88AF
  ldx #$00                     ; $88B1
  ldy #$00                     ; $88B3
Loc_B5_88B5:
  lda (Tmp00),y                ; $88B5
  beq Loc_B5_88E2              ; $88B7
  and #$F0                     ; $88B9
  lsr a                        ; $88BB
  adc #$5F                     ; $88BC
  sta OamBuffer,x              ; $88BE
  lda (Tmp00),y                ; $88C1
  and #$0F                     ; $88C3
  asl a                        ; $88C5
  asl a                        ; $88C6
  asl a                        ; $88C7
  adc #$30                     ; $88C8
  sta $0203,x                  ; $88CA
  lda z:Tmp02                  ; $88CD
  inc z:Tmp02                  ; $88CF
  inc z:Tmp02                  ; $88D1
  sta $0201,x                  ; $88D3
  lda #$00                     ; $88D6
  sta $0202,x                  ; $88D8
  iny                          ; $88DB
  inx                          ; $88DC
  inx                          ; $88DD
  inx                          ; $88DE
  inx                          ; $88DF
  bne Loc_B5_88B5              ; $88E0
Loc_B5_88E2:
  rts                          ; $88E2
Data_B5_88E3:
  .incbin "prg_bank_5.bin", $08E3, $1  ; $88E3
Data_B5_88E4:
  .incbin "prg_bank_5.bin", $08E4, $35  ; $88E4
Data_B5_8919:
  .incbin "prg_bank_5.bin", $0919, $25  ; $8919
Data_B5_893E:
  .incbin "prg_bank_5.bin", $093E, $6  ; $893E
Sub_B5_8944:
  ldy PPU_STATUS               ; $8944
  stx PPU_ADDR                 ; $8947
  ldx #$00                     ; $894A
  stx PPU_ADDR                 ; $894C
  ldy #$04                     ; $894F
Loc_B5_8951:
  sta PPU_DATA                 ; $8951
  dex                          ; $8954
  bne Loc_B5_8951              ; $8955
  dey                          ; $8957
  bne Loc_B5_8951              ; $8958
  rts                          ; $895A
Sub_B5_895B:
  lda #$0F                     ; $895B
Sub_B5_895D:
  ldx #$1F                     ; $895D
Sub_B5_895F:
  sta PaletteBuffer,x          ; $895F
  dex                          ; $8962
  bpl Sub_B5_895F              ; $8963
  rts                          ; $8965
Sub_B5_8966:
  lda #$00                     ; $8966
  ldx #$10                     ; $8968
Loc_B5_896A:
  sta SceneState,x             ; $896A
  inx                          ; $896D
  bne Loc_B5_896A              ; $896E
  rts                          ; $8970
Sub_B5_8971:
  ldx #$00                     ; $8971
Sub_B5_8973:
  lda #$F0                     ; $8973
Loc_B5_8975:
  sta OamBuffer,x              ; $8975
  inx                          ; $8978
  bne Loc_B5_8975              ; $8979
  rts                          ; $897B
Sub_B5_897C:
  jsr Sub_B5_814C              ; $897C
  lda #$1E                     ; $897F
  ldx #$0F                     ; $8981
  ldy #$0E                     ; $8983
  jsr Sub_B5_8FDE              ; $8985
  lda #$FF                     ; $8988
  ldx #$20                     ; $898A
  jsr Sub_B5_8944              ; $898C
  ldx #$2C                     ; $898F
  jsr Sub_B5_8944              ; $8991
  jsr Sub_B5_8971              ; $8994
  jsr ProcessPpuUpdateList     ; $8997
  .addr Data_B5_89D9  ; $899A inline pointer (data after a JSR)
  ldx #$03                     ; $899C
Loc_B5_899E:
  lda Data_B5_89D2,x           ; $899E
  sta PaletteBuffer,x          ; $89A1
  lda Data_B5_89D5,x           ; $89A4
  sta $0150,x                  ; $89A7
  dex                          ; $89AA
  bne Loc_B5_899E              ; $89AB
  lda #$01                     ; $89AD
  sta $0539                    ; $89AF
  lda #$80                     ; $89B2
  sta $053A                    ; $89B4
  lda #$03                     ; $89B7
  sta $053B                    ; $89B9
  lda #$00                     ; $89BC
  sta $053C                    ; $89BE
  lda #$80                     ; $89C1
  sta $053D                    ; $89C3
  lda #$01                     ; $89C6
  sta $053E                    ; $89C8
  lda #$1E                     ; $89CB
  sta SceneTimer               ; $89CD
  jmp Sub_B5_90B9              ; $89D0
  .incbin "prg_bank_5.bin", $09D3, $2  ; $89D3
Data_B5_89D5:
  .incbin "prg_bank_5.bin", $09D5, $4  ; $89D5
Data_B5_89D9:
  .incbin "prg_bank_5.bin", $09D9, $D2  ; $89D9
Loc_B5_8AAB:
  lda #$1C                     ; $8AAB
  ldx #$0C                     ; $8AAD
  ldy #$08                     ; $8AAF
  jsr Sub_B5_8FDE              ; $8AB1
  jsr Sub_B5_8FCA              ; $8AB4
  lda #$00                     ; $8AB7
  ldx #$20                     ; $8AB9
  jsr Sub_B5_8944              ; $8ABB
  jsr ProcessPpuUpdateList     ; $8ABE
  .addr Data_B5_8ADC  ; $8AC1 inline pointer (data after a JSR)
  ldx #$07                     ; $8AC3
Loc_B5_8AC5:
  lda Data_B5_8AD4,x           ; $8AC5
  sta $0150,x                  ; $8AC8
  dex                          ; $8ACB
  bpl Loc_B5_8AC5              ; $8ACC
  lda #$3C                     ; $8ACE
  sta SceneTimer               ; $8AD0
  rts                          ; $8AD3
Data_B5_8AD4:
  .incbin "prg_bank_5.bin", $0AD4, $8  ; $8AD4
Data_B5_8ADC:
  .incbin "prg_bank_5.bin", $0ADC, $5  ; $8ADC
Bank5SubStateDispatch:
  lda SceneSubState            ; $8AE1
  asl a                        ; $8AE4
  tax                          ; $8AE5
  lda Data_B5_8AF3,x           ; $8AE6
  sta z:Tmp00                  ; $8AE9
  lda Data_B5_8AF4,x           ; $8AEB
  sta z:Tmp01                  ; $8AEE
  jmp ($0000)                  ; $8AF0
Data_B5_8AF3:
  .addr Sub_B5_8B09, Sub_B5_8B12, Sub_B5_8B29, Sub_B5_8B3F, Sub_B5_8B67, Sub_B5_8B92, Sub_B5_8BCF, Sub_B5_8BF0, Sub_B5_8C48, Sub_B5_8C61, Sub_B5_8C8E  ; $8AF3 pointer table
Sub_B5_8B09:
  ldy #$00                     ; $8B09
  sty AnimCounter              ; $8B0B
  sty SceneSubState            ; $8B0E
  rts                          ; $8B11
Sub_B5_8B12:
  jsr Bank5NextAnimFrame       ; $8B12
  cmp #$05                     ; $8B15
  bcc Loc_B5_8B1C              ; $8B17
  jmp Sub_B5_8B09              ; $8B19
Loc_B5_8B1C:
  tax                          ; $8B1C
  lda Data_B5_8B24,x           ; $8B1D
  sta $014F                    ; $8B20
  rts                          ; $8B23
Data_B5_8B24:
  ora (FrameInSecond,x)        ; $8B24  [heuristic code]
  and ($31,x)                  ; $8B26
  .incbin "prg_bank_5.bin", $0B28, $1  ; $8B28
Sub_B5_8B29:
  jsr Bank5NextAnimFrame       ; $8B29
  cmp #$04                     ; $8B2C
  bcc Sub_B5_8B33              ; $8B2E
  jmp Sub_B5_8B09              ; $8B30
Sub_B5_8B33:
  tax                          ; $8B33
  lda Data_B5_8B3B,x           ; $8B34
  sta $014F                    ; $8B37
  rts                          ; $8B3A
Data_B5_8B3B:
  .incbin "prg_bank_5.bin", $0B3B, $4  ; $8B3B
Sub_B5_8B3F:
  jsr Bank5NextAnimFrame       ; $8B3F
  cmp #$04                     ; $8B42
  bcc Loc_B5_8B4C              ; $8B44
  jsr Sub_B5_895B              ; $8B46
  jmp Sub_B5_8B09              ; $8B49
Loc_B5_8B4C:
  jsr Sub_B5_8B33              ; $8B4C
  lda Data_B5_8B5F,x           ; $8B4F
  sta $0152                    ; $8B52
  lda Data_B5_8B63,x           ; $8B55
  sta $0150                    ; $8B58
  sta $0153                    ; $8B5B
  rts                          ; $8B5E
Data_B5_8B5F:
  .incbin "prg_bank_5.bin", $0B5F, $4  ; $8B5F
Data_B5_8B63:
  .incbin "prg_bank_5.bin", $0B63, $4  ; $8B63
Sub_B5_8B67:
  jsr Bank5NextAnimFrame       ; $8B67
  cmp #$03                     ; $8B6A
  bcc Loc_B5_8B74              ; $8B6C
  jsr Sub_B5_8B09              ; $8B6E
  jmp Sub_B5_895B              ; $8B71
Loc_B5_8B74:
  sta z:Tmp00                  ; $8B74
  asl a                        ; $8B76
  adc z:Tmp00                  ; $8B77
  tax                          ; $8B79
  ldy #$01                     ; $8B7A
Loc_B5_8B7C:
  lda Data_B5_8B89,x           ; $8B7C
  sta PaletteBuffer,y          ; $8B7F
  inx                          ; $8B82
  iny                          ; $8B83
  cpy #$04                     ; $8B84
  bcc Loc_B5_8B7C              ; $8B86
  rts                          ; $8B88
Data_B5_8B89:
  .incbin "prg_bank_5.bin", $0B89, $9  ; $8B89
Sub_B5_8B92:
  jsr Bank5NextAnimFrame       ; $8B92
  cmp #$04                     ; $8B95
  bcc Loc_B5_8B9C              ; $8B97
  jmp Sub_B5_8B09              ; $8B99
Loc_B5_8B9C:
  sta z:Tmp00                  ; $8B9C
  asl a                        ; $8B9E
  adc z:Tmp00                  ; $8B9F
  tax                          ; $8BA1
  ldy #$01                     ; $8BA2
Loc_B5_8BA4:
  lda Data_B5_8BB7,x           ; $8BA4
  sta PaletteBuffer,y          ; $8BA7
  lda Data_B5_8BC3,x           ; $8BAA
  sta $014C,y                  ; $8BAD
  inx                          ; $8BB0
  iny                          ; $8BB1
  cpy #$04                     ; $8BB2
  bcc Loc_B5_8BA4              ; $8BB4
  rts                          ; $8BB6
Data_B5_8BB7:
  .incbin "prg_bank_5.bin", $0BB7, $C  ; $8BB7
Data_B5_8BC3:
  .incbin "prg_bank_5.bin", $0BC3, $C  ; $8BC3
Sub_B5_8BCF:
  jsr Bank5NextAnimFrame       ; $8BCF
  cmp #$03                     ; $8BD2
  bcc Loc_B5_8BD9              ; $8BD4
  jmp Sub_B5_8B09              ; $8BD6
Loc_B5_8BD9:
  tax                          ; $8BD9
  lda Data_B5_8BED,x           ; $8BDA
  tax                          ; $8BDD
  ldy #$0D                     ; $8BDE
Loc_B5_8BE0:
  lda Data_B5_8BC3,x           ; $8BE0
  sta PaletteBuffer,y          ; $8BE3
  inx                          ; $8BE6
  iny                          ; $8BE7
  cpy #$10                     ; $8BE8
  bcc Loc_B5_8BE0              ; $8BEA
  rts                          ; $8BEC
Data_B5_8BED:
  .incbin "prg_bank_5.bin", $0BED, $3  ; $8BED
Sub_B5_8BF0:
  jsr Bank5NextAnimFrame       ; $8BF0
  cmp #$04                     ; $8BF3
  bcc Loc_B5_8BFA              ; $8BF5
  jmp Sub_B5_8B09              ; $8BF7
Loc_B5_8BFA:
  tax                          ; $8BFA
  ldy #$01                     ; $8BFB
Loc_B5_8BFD:
  jsr Sub_B5_8C0C              ; $8BFD
  jsr Sub_B5_8C0C              ; $8C00
  jsr Sub_B5_8C0C              ; $8C03
  iny                          ; $8C06
  cpy #$10                     ; $8C07
  bcc Loc_B5_8BFD              ; $8C09
  rts                          ; $8C0B
Sub_B5_8C0C:
  lda Data_B5_8C18,x           ; $8C0C
  sta PaletteBuffer,y          ; $8C0F
  inx                          ; $8C12
  inx                          ; $8C13
  inx                          ; $8C14
  inx                          ; $8C15
  iny                          ; $8C16
  rts                          ; $8C17
Data_B5_8C18:
  .incbin "prg_bank_5.bin", $0C18, $30  ; $8C18
Sub_B5_8C48:
  jsr Bank5NextAnimFrame       ; $8C48
  cmp #$03                     ; $8C4B
  bcc Loc_B5_8C57              ; $8C4D
  beq Loc_B5_8C54              ; $8C4F
  jmp Sub_B5_8B09              ; $8C51
Loc_B5_8C54:
  jmp Sub_B5_895B              ; $8C54
Loc_B5_8C57:
  tax                          ; $8C57
  lda Data_B5_8C5E,x           ; $8C58
  jmp Loc_B5_8BFA              ; $8C5B
Data_B5_8C5E:
  .incbin "prg_bank_5.bin", $0C5E, $3  ; $8C5E
Sub_B5_8C61:
  jsr Bank5NextAnimFrame       ; $8C61
  cmp #$05                     ; $8C64
  bcc Loc_B5_8C6B              ; $8C66
  jmp Sub_B5_8B09              ; $8C68
Loc_B5_8C6B:
  tax                          ; $8C6B
  lda Data_B5_8C7F,x           ; $8C6C
  sta $014D                    ; $8C6F
  lda Data_B5_8C84,x           ; $8C72
  sta $014E                    ; $8C75
  lda Data_B5_8C89,x           ; $8C78
  sta $014F                    ; $8C7B
  rts                          ; $8C7E
Data_B5_8C7F:
  .incbin "prg_bank_5.bin", $0C7F, $5  ; $8C7F
Data_B5_8C84:
  .incbin "prg_bank_5.bin", $0C84, $5  ; $8C84
Data_B5_8C89:
  .incbin "prg_bank_5.bin", $0C89, $5  ; $8C89
Sub_B5_8C8E:
  jsr Bank5NextAnimFrame       ; $8C8E
  cmp #$05                     ; $8C91
  bcc Loc_B5_8C98              ; $8C93
  jmp Sub_B5_8B09              ; $8C95
Loc_B5_8C98:
  tax                          ; $8C98
  lda Data_B5_8CAC,x           ; $8C99
  sta $014D                    ; $8C9C
  lda Data_B5_8CB1,x           ; $8C9F
  sta $014E                    ; $8CA2
  lda Data_B5_8CB6,x           ; $8CA5
  sta $014F                    ; $8CA8
  rts                          ; $8CAB
Data_B5_8CAC:
  .incbin "prg_bank_5.bin", $0CAC, $5  ; $8CAC
Data_B5_8CB1:
  .incbin "prg_bank_5.bin", $0CB1, $5  ; $8CB1
Data_B5_8CB6:
  .incbin "prg_bank_5.bin", $0CB6, $5  ; $8CB6
Bank5NextAnimFrame:
  inc AnimCounter              ; $8CBB
  lda AnimCounter              ; $8CBE
  lsr a                        ; $8CC1
  lsr a                        ; $8CC2
  rts                          ; $8CC3
Sub_B5_8CC4:
  ldx #$38                     ; $8CC4
  jsr Sub_B5_8973              ; $8CC6
  lda $052E                    ; $8CC9
  bne Loc_B5_8CD3              ; $8CCC
  lda #$11                     ; $8CCE
  jsr EnqueueByte              ; $8CD0
Loc_B5_8CD3:
  lda $052E                    ; $8CD3
  cmp #$0F                     ; $8CD6
  bcc Loc_B5_8CE0              ; $8CD8
  ldx #$00                     ; $8CDA
  stx $052E                    ; $8CDC
  rts                          ; $8CDF
Loc_B5_8CE0:
  asl a                        ; $8CE0
  tay                          ; $8CE1
  lda Data_B5_8D3A,y           ; $8CE2
  sta z:Tmp00                  ; $8CE5
  lda Data_B5_8D3B,y           ; $8CE7
  sta z:Tmp01                  ; $8CEA
  ldy #$00                     ; $8CEC
Loc_B5_8CEE:
  lda (Tmp00),y                ; $8CEE
  beq Loc_B5_8D22              ; $8CF0
  and #$F0                     ; $8CF2
  lsr a                        ; $8CF4
  adc $0532                    ; $8CF5
  sta $0250,x                  ; $8CF8
  lda (Tmp00),y                ; $8CFB
  and #$0F                     ; $8CFD
  asl a                        ; $8CFF
  asl a                        ; $8D00
  asl a                        ; $8D01
  adc $0531                    ; $8D02
  sta $0253,x                  ; $8D05
  iny                          ; $8D08
  lda (Tmp00),y                ; $8D09
  and #$0F                     ; $8D0B
  ora #$A0                     ; $8D0D
  sta $0251,x                  ; $8D0F
  lda (Tmp00),y                ; $8D12
  and #$F0                     ; $8D14
  ora #$23                     ; $8D16
  sta $0252,x                  ; $8D18
  iny                          ; $8D1B
  inx                          ; $8D1C
  inx                          ; $8D1D
  inx                          ; $8D1E
  inx                          ; $8D1F
  bpl Loc_B5_8CEE              ; $8D20
Loc_B5_8D22:
  dec $052F                    ; $8D22
  bpl Loc_B5_8D2F              ; $8D25
  lda #$07                     ; $8D27
  sta $052F                    ; $8D29
  inc $052E                    ; $8D2C
Loc_B5_8D2F:
  lda $052E                    ; $8D2F
  cmp #$06                     ; $8D32
  bcc Loc_B5_8D37              ; $8D34
  rts                          ; $8D36
Loc_B5_8D37:
  jmp Sub_B5_8E22              ; $8D37
Data_B5_8D3A:
  .incbin "prg_bank_5.bin", $0D3A, $1  ; $8D3A
Data_B5_8D3B:
  .incbin "prg_bank_5.bin", $0D3B, $E7  ; $8D3B
Sub_B5_8E22:
  lda #$F0                     ; $8E22
  ldx #$13                     ; $8E24
Loc_B5_8E26:
  sta $0238,x                  ; $8E26
  dex                          ; $8E29
  bpl Loc_B5_8E26              ; $8E2A
  ldx #$3C                     ; $8E2C
Loc_B5_8E2E:
  lda Data_B5_8EB2,x           ; $8E2E
  clc                          ; $8E31
  adc $0531                    ; $8E32
  sta $02C3,x                  ; $8E35
  lda Data_B5_8EB1,x           ; $8E38
  sta $02C2,x                  ; $8E3B
  lda Data_B5_8EB0,x           ; $8E3E
  sta $02C1,x                  ; $8E41
  lda Data_B5_8EAF,x           ; $8E44
  clc                          ; $8E47
  adc $0532                    ; $8E48
  sta $02C0,x                  ; $8E4B
  dex                          ; $8E4E
  dex                          ; $8E4F
  dex                          ; $8E50
  dex                          ; $8E51
  bpl Loc_B5_8E2E              ; $8E52
  lda $0533                    ; $8E54
  clc                          ; $8E57
  adc #$10                     ; $8E58
  sta $0533                    ; $8E5A
  ldx #$0C                     ; $8E5D
Loc_B5_8E5F:
  lda $0533                    ; $8E5F
  and #$20                     ; $8E62
  clc                          ; $8E64
  adc $02F3,x                  ; $8E65
  sta $02F3,x                  ; $8E68
  dex                          ; $8E6B
  dex                          ; $8E6C
  dex                          ; $8E6D
  dex                          ; $8E6E
  bpl Loc_B5_8E5F              ; $8E6F
  lda $0531                    ; $8E71
  cmp #$20                     ; $8E74
  bcc Loc_B5_8E8F              ; $8E76
  cmp #$A0                     ; $8E78
  beq Loc_B5_8E99              ; $8E7A
  bcs Loc_B5_8E9A              ; $8E7C
  lda z:HwScrollX              ; $8E7E
  cmp $0534                    ; $8E80
  beq Loc_B5_8E8F              ; $8E83
  ldx $0535                    ; $8E85
  stx $0534                    ; $8E88
  sta $0535                    ; $8E8B
  rts                          ; $8E8E
Loc_B5_8E8F:
  lda $0533                    ; $8E8F
  and #$10                     ; $8E92
  beq Loc_B5_8E99              ; $8E94
  inc $0531                    ; $8E96
Loc_B5_8E99:
  rts                          ; $8E99
Loc_B5_8E9A:
  ldx #$3C                     ; $8E9A
Loc_B5_8E9C:
  lda $02C3,x                  ; $8E9C
  bpl Loc_B5_8EA6              ; $8E9F
  lda #$F0                     ; $8EA1
  sta $02C0,x                  ; $8EA3
Loc_B5_8EA6:
  dex                          ; $8EA6
  dex                          ; $8EA7
  dex                          ; $8EA8
  dex                          ; $8EA9
  bpl Loc_B5_8E9C              ; $8EAA
  jmp Loc_B5_8E8F              ; $8EAC
Data_B5_8EAF:
  .incbin "prg_bank_5.bin", $0EAF, $1  ; $8EAF
Data_B5_8EB0:
  .incbin "prg_bank_5.bin", $0EB0, $1  ; $8EB0
Data_B5_8EB1:
  .incbin "prg_bank_5.bin", $0EB1, $1  ; $8EB1
Data_B5_8EB2:
  .incbin "prg_bank_5.bin", $0EB2, $3D  ; $8EB2
Data_B5_8EEF:
  .incbin "prg_bank_5.bin", $0EEF, $4B  ; $8EEF
Sub_B5_8F3A:
  ldx #$0A                     ; $8F3A
Loc_B5_8F3C:
  lda Data_B5_8F46,x           ; $8F3C
  sta $0513,x                  ; $8F3F
  dex                          ; $8F42
  bpl Loc_B5_8F3C              ; $8F43
  rts                          ; $8F45
Data_B5_8F46:
  .incbin "prg_bank_5.bin", $0F46, $B  ; $8F46
Sub_B5_8F51:
  ldx #$19                     ; $8F51
Loc_B5_8F53:
  lda Data_B5_8734,x           ; $8F53
  sta $05B8,x                  ; $8F56
  dex                          ; $8F59
  bpl Loc_B5_8F53              ; $8F5A
  rts                          ; $8F5C
Loc_B5_8F5D:
  lda #$C0                     ; $8F5D
  ldx #$00                     ; $8F5F
  jsr Sub_B5_8F91              ; $8F61
  lda #$A0                     ; $8F64
  ldx #$01                     ; $8F66
  jsr Sub_B5_8F91              ; $8F68
  ldx $0536                    ; $8F6B
  jsr Sub_B5_8F88              ; $8F6E
  tay                          ; $8F71
  lda Data_B5_8FA1,y           ; $8F72
  sta $0156                    ; $8F75
  ldx $0537                    ; $8F78
  jsr Sub_B5_8F88              ; $8F7B
  ora #$08                     ; $8F7E
  tay                          ; $8F80
  lda Data_B5_8FA1,y           ; $8F81
  sta $015B                    ; $8F84
  rts                          ; $8F87
Sub_B5_8F88:
  bpl Loc_B5_8F8D              ; $8F88
  lda #$00                     ; $8F8A
  rts                          ; $8F8C
Loc_B5_8F8D:
  lda Data_B5_8FB1,x           ; $8F8D
  rts                          ; $8F90
Sub_B5_8F91:
  ldy $0536,x                  ; $8F91
  iny                          ; $8F94
  bmi Loc_B5_8F9C              ; $8F95
  cpy #$19                     ; $8F97
  bcc Loc_B5_8F9C              ; $8F99
  tay                          ; $8F9B
Loc_B5_8F9C:
  tya                          ; $8F9C
  sta $0536,x                  ; $8F9D
  rts                          ; $8FA0
Data_B5_8FA1:
  .incbin "prg_bank_5.bin", $0FA1, $10  ; $8FA1
Data_B5_8FB1:
  .incbin "prg_bank_5.bin", $0FB1, $19  ; $8FB1
Sub_B5_8FCA:
  ldx #$07                     ; $8FCA
Loc_B5_8FCC:
  lda Data_B5_8FD6,x           ; $8FCC
  sta $051E,x                  ; $8FCF
  dex                          ; $8FD2
  bpl Loc_B5_8FCC              ; $8FD3
  rts                          ; $8FD5
Data_B5_8FD6:
  .incbin "prg_bank_5.bin", $0FD6, $8  ; $8FD6
Sub_B5_8FDE:
  sta z:MmcControlShadow       ; $8FDE
  stx z:MmcChr0Shadow          ; $8FE0
  sty z:MmcChr1Shadow          ; $8FE2
  jsr MmcWriteControl          ; $8FE4
  jsr MmcWriteChr0             ; $8FE7
  jmp MmcWriteChr1             ; $8FEA
Loc_B5_8FED:
  jsr Sub_B5_814C              ; $8FED
  lda #$1F                     ; $8FF0
  ldx #$1A                     ; $8FF2
  ldy #$08                     ; $8FF4
  jsr Sub_B5_8FDE              ; $8FF6
  lda #$60                     ; $8FF9
  sta $0600                    ; $8FFB
  lda #$00                     ; $8FFE
  sta z:GameState              ; $9000
  lda #$03                     ; $9002
  sta $0106                    ; $9004
  lda #$01                     ; $9007
  sta z:$28                    ; $9009
  lda #$2E                     ; $900B
  sta z:$29                    ; $900D
  lda #$00                     ; $900F
  sta z:$2A                    ; $9011
  lda #$64                     ; $9013
  sta z:$2B                    ; $9015
  lda #$B0                     ; $9017
  sta $0541                    ; $9019
  lda #$06                     ; $901C
  sta $0542                    ; $901E
  lda #$40                     ; $9021
  sta $0532                    ; $9023
  lda #$B0                     ; $9026
  sta $0531                    ; $9028
  lda #$C8                     ; $902B
  sta z:PlayerLifeLo           ; $902D
  ldx #$4A                     ; $902F
Loc_B5_9031:
  lda Data_B5_8EEF,x           ; $9031
  sta $0568,x                  ; $9034
  dex                          ; $9037
  bpl Loc_B5_9031              ; $9038
  lda #$15                     ; $903A
  jmp EnqueueByte              ; $903C
Loc_B5_903F:
  jsr Sub_B5_814C              ; $903F
  lda #$1F                     ; $9042
  ldx #$0F                     ; $9044
  ldy #$0D                     ; $9046
  jsr Sub_B5_8FDE              ; $9048
  jsr Sub_B5_895B              ; $904B
  lda #$FF                     ; $904E
  ldx #$20                     ; $9050
  jsr Sub_B5_8944              ; $9052
  ldx #$2C                     ; $9055
  jsr Sub_B5_8944              ; $9057
  lda #$20                     ; $905A
  sta $014F                    ; $905C
  lda #$00                     ; $905F
  sta z:HwScrollX              ; $9061
  sta z:HwScrollY              ; $9063
  sta $0543                    ; $9065
  sta $0545                    ; $9068
  sta $0546                    ; $906B
  rts                          ; $906E
  lda #$0F                     ; $906F  [heuristic code]
  sta $015F                    ; $9071
  lda #$03                     ; $9074
  ldx #$36                     ; $9076
Loc_B5_9078:
  sta OamBuffer,x              ; $9078
  dex                          ; $907B
  dex                          ; $907C
  dex                          ; $907D
  dex                          ; $907E
  bpl Loc_B5_9078              ; $907F
  rts                          ; $9081
Sub_B5_9082:
  lda $0528                    ; $9082
  ora $0529                    ; $9085
  beq Loc_B5_9092              ; $9088
  dec $0528                    ; $908A
  bne Loc_B5_9092              ; $908D
  dec $0529                    ; $908F
Loc_B5_9092:
  lda z:MmcPrgShadow           ; $9092
  pha                          ; $9094
  lda #$05                     ; $9095
  sta z:MmcPrgShadow           ; $9097
  jsr CallBank5_A000           ; $9099
  pla                          ; $909C
  sta z:MmcPrgShadow           ; $909D
  rts                          ; $909F
Sub_B5_90A0:
  lda #$00                     ; $90A0
  sta APU_DMC_FREQ             ; $90A2
  sta APU_DMC_RAW              ; $90A5
  lda #$0F                     ; $90A8
  sta APU_SND_CHN              ; $90AA
  lda #$C0                     ; $90AD
  sta JOYPAD2                  ; $90AF
  rts                          ; $90B2
Sub_B5_90B3:
  jsr Sub_B5_895B              ; $90B3
  jsr Sub_B5_8971              ; $90B6
Sub_B5_90B9:
  lda #$30                     ; $90B9
  sta z:PpuCtrlShadow          ; $90BB
  lda #$06                     ; $90BD
  sta z:PpuMaskShadow          ; $90BF
  lda #$00                     ; $90C1
  sta z:HwScrollX              ; $90C3
  sta z:HwScrollY              ; $90C5
  rts                          ; $90C7
Sub_B5_90C8:
  jsr Sub_B5_9206              ; $90C8
  lda #$08                     ; $90CB
  sta z:HwScrollY              ; $90CD
  lda #$10                     ; $90CF
  sta z:HwScrollX              ; $90D1
  jsr ProcessPpuUpdateList     ; $90D3
  .addr Data_B5_911E  ; $90D6 inline pointer (data after a JSR)
  lda $050F                    ; $90D8
  and #$3F                     ; $90DB
  sta z:Tmp03                  ; $90DD
  inc z:Tmp03                  ; $90DF
  lda #$00                     ; $90E1
  sta z:$04                    ; $90E3
  jsr BinToDecimal             ; $90E5
  lda PPU_STATUS               ; $90E8
  lda #$22                     ; $90EB
  sta PPU_ADDR                 ; $90ED
  lda #$C8                     ; $90F0
  sta PPU_ADDR                 ; $90F2
  ldy #$FF                     ; $90F5
  lda z:Tmp01                  ; $90F7
  beq Loc_B5_9101              ; $90F9
  clc                          ; $90FB
  adc #$A0                     ; $90FC
  sta PPU_DATA                 ; $90FE
Loc_B5_9101:
  sty PPU_DATA                 ; $9101
  lda z:Tmp00                  ; $9104
  clc                          ; $9106
  adc #$A0                     ; $9107
  sta PPU_DATA                 ; $9109
  ldx #$03                     ; $910C
Loc_B5_910E:
  lda Data_B5_911A,x           ; $910E
  sta OamBuffer,x              ; $9111
  dex                          ; $9114
  bpl Loc_B5_910E              ; $9115
  jmp Sub_B5_895B              ; $9117
Data_B5_911A:
  .incbin "prg_bank_5.bin", $111A, $4  ; $911A
Data_B5_911E:
  .incbin "prg_bank_5.bin", $111E, $E8  ; $911E
Sub_B5_9206:
  jsr Sub_B5_814C              ; $9206
  lda #$1C                     ; $9209
  ldx #$0F                     ; $920B
  ldy #$0E                     ; $920D
  jsr Sub_B5_8FDE              ; $920F
  jsr Sub_B5_895B              ; $9212
  jsr Sub_B5_8971              ; $9215
  lda #$FF                     ; $9218
  ldx #$20                     ; $921A
  jsr Sub_B5_8944              ; $921C
  jsr Sub_B5_8F51              ; $921F
  ldy #$02                     ; $9222
  jsr $05B8                    ; $9224
  jsr Sub_B5_895B              ; $9227
  lda #$27                     ; $922A
  sta $0151                    ; $922C
  lda #$20                     ; $922F
  sta $0153                    ; $9231
  jmp Sub_B5_90B9              ; $9234
Sub_B5_9237:
  lda $0540                    ; $9237
  asl a                        ; $923A
  tax                          ; $923B
  lda Data_B5_9259,x           ; $923C
  sta $0521                    ; $923F
  lda Data_B5_925A,x           ; $9242
  sta $0522                    ; $9245
  jsr $051E                    ; $9248
  ldx $0540                    ; $924B
  inx                          ; $924E
  cpx #$0C                     ; $924F
  bcc Loc_B5_9255              ; $9251
  ldx #$00                     ; $9253
Loc_B5_9255:
  stx $0540                    ; $9255
  rts                          ; $9258
Data_B5_9259:
  .incbin "prg_bank_5.bin", $1259, $1  ; $9259
Data_B5_925A:
  .incbin "prg_bank_5.bin", $125A, $81  ; $925A
Sub_B5_92DB:
  jsr Sub_B5_8971              ; $92DB
  ldx $053F                    ; $92DE
  txa                          ; $92E1
  inx                          ; $92E2
  cpx #$0E                     ; $92E3
  bcc Loc_B5_92E9              ; $92E5
  ldx #$00                     ; $92E7
Loc_B5_92E9:
  stx $053F                    ; $92E9
  and #$FE                     ; $92EC
  tax                          ; $92EE
  lda Data_B5_932F,x           ; $92EF
  sta z:Tmp00                  ; $92F2
  lda Data_B5_9330,x           ; $92F4
  sta z:Tmp01                  ; $92F7
  ldx #$00                     ; $92F9
  ldy #$00                     ; $92FB
Loc_B5_92FD:
  lda (Tmp00),y                ; $92FD
  beq Loc_B5_932E              ; $92FF
  and #$F0                     ; $9301
  lsr a                        ; $9303
  adc #$3F                     ; $9304
  sta OamBuffer,x              ; $9306
  lda (Tmp00),y                ; $9309
  and #$0F                     ; $930B
  asl a                        ; $930D
  asl a                        ; $930E
  asl a                        ; $930F
  adc #$40                     ; $9310
  sta $0203,x                  ; $9312
  iny                          ; $9315
  lda (Tmp00),y                ; $9316
  and #$3E                     ; $9318
  clc                          ; $931A
  adc #$40                     ; $931B
  sta $0201,x                  ; $931D
  lda (Tmp00),y                ; $9320
  and #$C1                     ; $9322
  sta $0202,x                  ; $9324
  iny                          ; $9327
  inx                          ; $9328
  inx                          ; $9329
  inx                          ; $932A
  inx                          ; $932B
  bne Loc_B5_92FD              ; $932C
Loc_B5_932E:
  rts                          ; $932E
Data_B5_932F:
  .incbin "prg_bank_5.bin", $132F, $1  ; $932F
Data_B5_9330:
  .incbin "prg_bank_5.bin", $1330, $108  ; $9330
Sub_B5_9438:
  inc $0503                    ; $9438
  beq Sub_B5_9438              ; $943B
  jsr GetRandomByte            ; $943D
  adc $0503                    ; $9440
  and #$F0                     ; $9443
  ora JoyHeld1                 ; $9445
  ldx $0502                    ; $9448
  asl a                        ; $944B
  bcc Loc_B5_9451              ; $944C
  dec $0501                    ; $944E
Loc_B5_9451:
  asl a                        ; $9451
  bcc Loc_B5_9457              ; $9452
  inc $0501                    ; $9454
Loc_B5_9457:
  asl a                        ; $9457
  bcc Loc_B5_945F              ; $9458
  cpx #$48                     ; $945A
  bcc Loc_B5_945F              ; $945C
  dex                          ; $945E
Loc_B5_945F:
  asl a                        ; $945F
  bcc Loc_B5_9467              ; $9460
  cpx #$FF                     ; $9462
  beq Loc_B5_9467              ; $9464
  inx                          ; $9466
Loc_B5_9467:
  stx $0502                    ; $9467
  lda JoyNew1                  ; $946A
  and #$02                     ; $946D
  bne Loc_B5_9472              ; $946F
  rts                          ; $9471
Loc_B5_9472:
  cpx #$6C                     ; $9472
  bcc Loc_B5_948B              ; $9474
  cpx #$74                     ; $9476
  bcs Loc_B5_948B              ; $9478
  ldy $0501                    ; $947A
  cpy #$70                     ; $947D
  bcc Loc_B5_948B              ; $947F
  cpy #$78                     ; $9481
  bcs Loc_B5_948B              ; $9483
  sta SceneTimer               ; $9485
  jmp Sub_B5_8971              ; $9488
Loc_B5_948B:
  rts                          ; $948B
Loc_B5_948C:
  lda #$30                     ; $948C
  sta z:PpuCtrlShadow          ; $948E
  lda #$06                     ; $9490
  jsr SetPpuMask               ; $9492
  lda #$1E                     ; $9495
  ldx #$0F                     ; $9497
  ldy #$0D                     ; $9499
  jsr Sub_B5_8FDE              ; $949B
  lda #$FE                     ; $949E
  ldx #$20                     ; $94A0
  jsr Sub_B5_8944              ; $94A2
  lda #$FF                     ; $94A5
  ldx #$2C                     ; $94A7
  jsr Sub_B5_8944              ; $94A9
  jsr ProcessPpuUpdateList     ; $94AC
  .addr Data_B5_94E7  ; $94AF inline pointer (data after a JSR)
  ldy #$1F                     ; $94B1
Loc_B5_94B3:
  lda Data_B5_94C7,y           ; $94B3
  sta PaletteBuffer,y          ; $94B6
  dey                          ; $94B9
  bpl Loc_B5_94B3              ; $94BA
  ldy #$00                     ; $94BC
  sty $0501                    ; $94BE
  ldy #$D0                     ; $94C1
  sty $0502                    ; $94C3
  rts                          ; $94C6
Data_B5_94C7:
  .incbin "prg_bank_5.bin", $14C7, $20  ; $94C7
Data_B5_94E7:
  .incbin "prg_bank_5.bin", $14E7, $19A  ; $94E7
Sub_B5_9681:
  ldy #$78                     ; $9681
  sty $0511                    ; $9683
  ldy #$4E                     ; $9686
  jsr Sub_B5_997B              ; $9688
  lda $0510                    ; $968B
  and #$3C                     ; $968E
  lsr a                        ; $9690
  lsr a                        ; $9691
  bit $0510                    ; $9692
  bvc Loc_B5_969C              ; $9695
  eor #$0F                     ; $9697
  clc                          ; $9699
  adc #$01                     ; $969A
Loc_B5_969C:
  tay                          ; $969C
  lda Data_B5_975A,y           ; $969D
  bit $0510                    ; $96A0
  bpl Loc_B5_96AA              ; $96A3
  eor #$FF                     ; $96A5
  clc                          ; $96A7
  adc #$01                     ; $96A8
Loc_B5_96AA:
  clc                          ; $96AA
  adc #$44                     ; $96AB
  sta z:Tmp00                  ; $96AD
  ldy #$00                     ; $96AF
Loc_B5_96B1:
  lda Data_B5_972C,y           ; $96B1
  and #$30                     ; $96B4
  clc                          ; $96B6
  adc z:Tmp00                  ; $96B7
  sta OamBuffer,x              ; $96B9
  inx                          ; $96BC
  lda Data_B5_972D,y           ; $96BD
  sta OamBuffer,x              ; $96C0
  inx                          ; $96C3
  lda #$01                     ; $96C4
  sta OamBuffer,x              ; $96C6
  inx                          ; $96C9
  lda Data_B5_972C,y           ; $96CA
  and #$0F                     ; $96CD
  asl a                        ; $96CF
  asl a                        ; $96D0
  asl a                        ; $96D1
  sta OamBuffer,x              ; $96D2
  inx                          ; $96D5
  iny                          ; $96D6
  iny                          ; $96D7
  cpy #$2E                     ; $96D8
  bcc Loc_B5_96B1              ; $96DA
  lda $0510                    ; $96DC
  lsr a                        ; $96DF
  lda #$08                     ; $96E0
  bcc Loc_B5_96E6              ; $96E2
  lda #$30                     ; $96E4
Loc_B5_96E6:
  sta z:Tmp01                  ; $96E6
  ldy #$05                     ; $96E8
Loc_B5_96EA:
  lda z:Tmp00                  ; $96EA
  sta OamBuffer,x              ; $96EC
  inx                          ; $96EF
  lda #$CE                     ; $96F0
  sta OamBuffer,x              ; $96F2
  inx                          ; $96F5
  lda #$01                     ; $96F6
  sta OamBuffer,x              ; $96F8
  inx                          ; $96FB
  lda z:Tmp01                  ; $96FC
  sta OamBuffer,x              ; $96FE
  clc                          ; $9701
  adc #$08                     ; $9702
  sta z:Tmp01                  ; $9704
  inx                          ; $9706
  dey                          ; $9707
  bne Loc_B5_96EA              ; $9708
  lda $0510                    ; $970A
  lsr a                        ; $970D
  lsr a                        ; $970E
  and #$0F                     ; $970F
  tax                          ; $9711
  and #$08                     ; $9712
  beq Loc_B5_971A              ; $9714
  txa                          ; $9716
  eor #$0F                     ; $9717
  tax                          ; $9719
Loc_B5_971A:
  lda Data_B5_9724,x           ; $971A
  sta $0143                    ; $971D
  inc $0510                    ; $9720
  rts                          ; $9723
Data_B5_9724:
  .incbin "prg_bank_5.bin", $1724, $8  ; $9724
Data_B5_972C:
  .incbin "prg_bank_5.bin", $172C, $1  ; $972C
Data_B5_972D:
  .incbin "prg_bank_5.bin", $172D, $2D  ; $972D
Data_B5_975A:
  .incbin "prg_bank_5.bin", $175A, $11  ; $975A
Sub_B5_976B:
  inc $0504                    ; $976B
  lda $0504                    ; $976E
  lsr a                        ; $9771
  lsr a                        ; $9772
  and #$07                     ; $9773
  tay                          ; $9775
  lda Data_B5_977D,y           ; $9776
  sta $0159                    ; $9779
  rts                          ; $977C
Data_B5_977D:
  .incbin "prg_bank_5.bin", $177D, $8  ; $977D
Loc_B5_9785:
  lda #$30                     ; $9785
  sta z:PpuCtrlShadow          ; $9787
  lda #$06                     ; $9789
  jsr SetPpuMask               ; $978B
  lda #$1D                     ; $978E
  ldx #$1A                     ; $9790
  ldy #$0D                     ; $9792
  jsr Sub_B5_8FDE              ; $9794
  lda #$FF                     ; $9797
  ldx #$20                     ; $9799
  jsr Sub_B5_8944              ; $979B
  lda #$22                     ; $979E
  jsr Sub_B5_895D              ; $97A0
  jsr Sub_B5_8971              ; $97A3
  jsr ProcessPpuUpdateList     ; $97A6
  .addr Data_B5_97DF  ; $97A9 inline pointer (data after a JSR)
  lda #$0F                     ; $97AB
  sta $014F                    ; $97AD
  ldy #$07                     ; $97B0
Loc_B5_97B2:
  lda Data_B5_97D7,y           ; $97B2
  sta $0150,y                  ; $97B5
  dey                          ; $97B8
  bpl Loc_B5_97B2              ; $97B9
  lda #$12                     ; $97BB
  sta SceneTimer               ; $97BD
  lda #$C0                     ; $97C0
  sta $0502                    ; $97C2
  lda #$28                     ; $97C5
  sta $0501                    ; $97C7
  lda #$00                     ; $97CA
  sta $0510                    ; $97CC
  jsr Sub_B5_9681              ; $97CF
  lda #$00                     ; $97D2
  jmp EnqueueByte              ; $97D4
Data_B5_97D7:
  .incbin "prg_bank_5.bin", $17D7, $8  ; $97D7
Data_B5_97DF:
  .incbin "prg_bank_5.bin", $17DF, $69  ; $97DF
Sub_B5_9848:
  lda #$58                     ; $9848
  sta $0531                    ; $984A
  lda #$58                     ; $984D
  sta $0532                    ; $984F
  jsr Sub_B5_8971              ; $9852
  jsr Sub_B5_8CC4              ; $9855
  ldx #$C0                     ; $9858
  jsr Sub_B5_8973              ; $985A
  ldy #$06                     ; $985D
  lda $052E                    ; $985F
  cmp #$06                     ; $9862
  bcc Loc_B5_9867              ; $9864
  iny                          ; $9866
Loc_B5_9867:
  tya                          ; $9867
  ldx #$C0                     ; $9868
  jmp Sub_B5_9895              ; $986A
Sub_B5_986D:
  jsr Sub_B5_8971              ; $986D
  lda #$00                     ; $9870
  tax                          ; $9872
  jsr Sub_B5_9895              ; $9873
  lda $0505                    ; $9876
  lsr a                        ; $9879
  lsr a                        ; $987A
  lsr a                        ; $987B
  bne Loc_B5_9880              ; $987C
  lda #$01                     ; $987E
Loc_B5_9880:
  cmp #$04                     ; $9880
  bcc Loc_B5_9886              ; $9882
  lda #$04                     ; $9884
Loc_B5_9886:
  jsr Sub_B5_9895              ; $9886
  ldy $0505                    ; $9889
  iny                          ; $988C
  bpl Loc_B5_9891              ; $988D
  ldy #$00                     ; $988F
Loc_B5_9891:
  sty $0505                    ; $9891
  rts                          ; $9894
Sub_B5_9895:
  asl a                        ; $9895
  tay                          ; $9896
  lda Data_B5_98D5,y           ; $9897
  sta z:Tmp00                  ; $989A
  lda Data_B5_98D6,y           ; $989C
  sta z:Tmp01                  ; $989F
  ldy #$00                     ; $98A1
Loc_B5_98A3:
  lda (Tmp00),y                ; $98A3
  beq Loc_B5_98D4              ; $98A5
  and #$F0                     ; $98A7
  lsr a                        ; $98A9
  adc #$57                     ; $98AA
  sta OamBuffer,x              ; $98AC
  lda (Tmp00),y                ; $98AF
  and #$0F                     ; $98B1
  asl a                        ; $98B3
  asl a                        ; $98B4
  adc #$60                     ; $98B5
  sta $0203,x                  ; $98B7
  iny                          ; $98BA
  lda (Tmp00),y                ; $98BB
  and #$FC                     ; $98BD
  sec                          ; $98BF
  ror a                        ; $98C0
  sta $0201,x                  ; $98C1
  lda (Tmp00),y                ; $98C4
  and #$03                     ; $98C6
  ora #$20                     ; $98C8
  sta $0202,x                  ; $98CA
  iny                          ; $98CD
  inx                          ; $98CE
  inx                          ; $98CF
  inx                          ; $98D0
  inx                          ; $98D1
  bne Loc_B5_98A3              ; $98D2
Loc_B5_98D4:
  rts                          ; $98D4
Data_B5_98D5:
  .incbin "prg_bank_5.bin", $18D5, $1  ; $98D5
Data_B5_98D6:
  .incbin "prg_bank_5.bin", $18D6, $9E  ; $98D6
Sub_B5_9974:
  ldy #$84                     ; $9974
  sty $0511                    ; $9976
  ldy #$00                     ; $9979
Sub_B5_997B:
  jsr Sub_B5_8971              ; $997B
Loc_B5_997E:
  lda Data_B5_99AA,y           ; $997E
  clc                          ; $9981
  adc $0502                    ; $9982
  sta OamBuffer,x              ; $9985
  inx                          ; $9988
  iny                          ; $9989
  lda Data_B5_99AA,y           ; $998A
  sta OamBuffer,x              ; $998D
  inx                          ; $9990
  iny                          ; $9991
  lda #$20                     ; $9992
  sta OamBuffer,x              ; $9994
  inx                          ; $9997
  lda Data_B5_99AA,y           ; $9998
  clc                          ; $999B
  adc $0501                    ; $999C
  sta OamBuffer,x              ; $999F
  inx                          ; $99A2
  iny                          ; $99A3
  cpy $0511                    ; $99A4
  bcc Loc_B5_997E              ; $99A7
  rts                          ; $99A9
Data_B5_99AA:
  .incbin "prg_bank_5.bin", $19AA, $84  ; $99AA
Loc_B5_9A2E:
  jsr Sub_B5_814C              ; $9A2E
  jsr Sub_B5_895B              ; $9A31
  jsr Sub_B5_8971              ; $9A34
  jsr Sub_B5_8FCA              ; $9A37
  lda #$FF                     ; $9A3A
  ldx #$20                     ; $9A3C
  jsr Sub_B5_8944              ; $9A3E
  ldx $0512                    ; $9A41
  lda Data_B5_9CB8,x           ; $9A44
  bpl Loc_B5_9A4F              ; $9A47
  lda #$00                     ; $9A49
  sta $0512                    ; $9A4B
  rts                          ; $9A4E
Loc_B5_9A4F:
  sta z:PaletteSetIndex        ; $9A4F
  jsr LoadPaletteSet           ; $9A51
  lda #$0F                     ; $9A54
  tax                          ; $9A56
  jsr Sub_B5_895F              ; $9A57
  lda #$20                     ; $9A5A
  sta $014F                    ; $9A5C
  jsr ProcessPpuUpdateList     ; $9A5F
  .addr Data_B5_9AF5  ; $9A62 inline pointer (data after a JSR)
  lda $0512                    ; $9A64
  asl a                        ; $9A67
  tax                          ; $9A68
  lda Data_B5_9AFB,x           ; $9A69
  sta $0521                    ; $9A6C
  lda Data_B5_9AFC,x           ; $9A6F
  sta $0522                    ; $9A72
  jsr $051E                    ; $9A75
  lda $0512                    ; $9A78
  asl a                        ; $9A7B
  tax                          ; $9A7C
  lda Data_B5_9CF3,x           ; $9A7D
  sta z:Tmp01                  ; $9A80
  lda Data_B5_9CF2,x           ; $9A82
  sta z:Tmp00                  ; $9A85
  beq Loc_B5_9AB7              ; $9A87
  ldx #$38                     ; $9A89
  ldy #$40                     ; $9A8B
  lsr a                        ; $9A8D
  bcc Loc_B5_9A94              ; $9A8E
  ldx #$35                     ; $9A90
  ldy #$44                     ; $9A92
Loc_B5_9A94:
  stx z:Tmp02                  ; $9A94
  sty z:Tmp03                  ; $9A96
  asl a                        ; $9A98
  sta z:Tmp00                  ; $9A99
  ldx #$0B                     ; $9A9B
Loc_B5_9A9D:
  lda Data_B5_9CC6,x           ; $9A9D
  sta OamBuffer,x              ; $9AA0
  dex                          ; $9AA3
  bpl Loc_B5_9A9D              ; $9AA4
  lda z:Tmp02                  ; $9AA6
  sta $0203                    ; $9AA8
  lda z:Tmp03                  ; $9AAB
  sta $0207                    ; $9AAD
  ldx #$01                     ; $9AB0
  ldy #$03                     ; $9AB2
  jsr Sub_B5_9AE5              ; $9AB4
Loc_B5_9AB7:
  ldx #$2F                     ; $9AB7
  ldy #$1F                     ; $9AB9
Loc_B5_9ABB:
  lda Data_B5_9CD2,y           ; $9ABB
  sta OamBuffer,x              ; $9ABE
  dex                          ; $9AC1
  dey                          ; $9AC2
  bpl Loc_B5_9ABB              ; $9AC3
  lda z:Tmp01                  ; $9AC5
  and #$F0                     ; $9AC7
  sta z:Tmp00                  ; $9AC9
  ldx #$11                     ; $9ACB
  ldy #$08                     ; $9ACD
  jsr Sub_B5_9AE5              ; $9ACF
  inc $0512                    ; $9AD2
  lda #$3C                     ; $9AD5
  sta SceneTimer               ; $9AD7
  lda z:Tmp01                  ; $9ADA
  and #$07                     ; $9ADC
  ora #$10                     ; $9ADE
  sta z:MmcChr0Shadow          ; $9AE0
  jmp MmcWriteChr0             ; $9AE2
Sub_B5_9AE5:
  lda z:Tmp00                  ; $9AE5
  ora OamBuffer,x              ; $9AE7
  sta OamBuffer,x              ; $9AEA
  inx                          ; $9AED
  inx                          ; $9AEE
  inx                          ; $9AEF
  inx                          ; $9AF0
  dey                          ; $9AF1
  bne Sub_B5_9AE5              ; $9AF2
  rts                          ; $9AF4
Data_B5_9AF5:
  .incbin "prg_bank_5.bin", $1AF5, $6  ; $9AF5
Data_B5_9AFB:
  .incbin "prg_bank_5.bin", $1AFB, $1  ; $9AFB
Data_B5_9AFC:
  .incbin "prg_bank_5.bin", $1AFC, $1BC  ; $9AFC
Data_B5_9CB8:
  .incbin "prg_bank_5.bin", $1CB8, $E  ; $9CB8
Data_B5_9CC6:
  .incbin "prg_bank_5.bin", $1CC6, $C  ; $9CC6
Data_B5_9CD2:
  .incbin "prg_bank_5.bin", $1CD2, $20  ; $9CD2
Data_B5_9CF2:
  .incbin "prg_bank_5.bin", $1CF2, $1  ; $9CF2
Data_B5_9CF3:
  .incbin "prg_bank_5.bin", $1CF3, $19  ; $9CF3
Loc_B5_9D0C:
  jsr Sub_B5_814C              ; $9D0C
  lda #$1C                     ; $9D0F
  ldx #$14                     ; $9D11
  ldy #$14                     ; $9D13
  jsr Sub_B5_8FDE              ; $9D15
  jsr Sub_B5_895B              ; $9D18
  jsr Sub_B5_8971              ; $9D1B
  lda #$FF                     ; $9D1E
  ldx #$20                     ; $9D20
  jsr Sub_B5_8944              ; $9D22
  jsr ProcessPpuUpdateList     ; $9D25
  .addr Data_B5_9D2D  ; $9D28 inline pointer (data after a JSR)
  jmp Sub_B5_90B9              ; $9D2A
Data_B5_9D2D:
  .incbin "prg_bank_5.bin", $1D2D, $1D  ; $9D2D
Loc_B5_9D4A:
  jsr Sub_B5_814C              ; $9D4A
  lda #$1C                     ; $9D4D
  ldx #$1F                     ; $9D4F
  ldy #$0D                     ; $9D51
  jsr Sub_B5_8FDE              ; $9D53
  jsr Sub_B5_895B              ; $9D56
  jsr Sub_B5_8971              ; $9D59
  lda #$FF                     ; $9D5C
  ldx #$20                     ; $9D5E
  jsr Sub_B5_8944              ; $9D60
  jsr ProcessPpuUpdateList     ; $9D63
  .addr Data_B5_9D7A  ; $9D66 inline pointer (data after a JSR)
  lda #$20                     ; $9D68
  sta $014F                    ; $9D6A
  lda #$78                     ; $9D6D
  sta SceneTimer               ; $9D6F
  jsr Sub_B5_90B9              ; $9D72
  lda #$0A                     ; $9D75
  jmp EnqueueByte              ; $9D77
Data_B5_9D7A:
  .incbin "prg_bank_5.bin", $1D7A, $E  ; $9D7A
Loc_B5_9D88:
  jsr Sub_B5_814C              ; $9D88
  lda #$1C                     ; $9D8B
  ldx #$1F                     ; $9D8D
  ldy #$0D                     ; $9D8F
  jsr Sub_B5_8FDE              ; $9D91
  jsr Sub_B5_895B              ; $9D94
  jsr Sub_B5_8971              ; $9D97
  lda #$FF                     ; $9D9A
  ldx #$20                     ; $9D9C
  jsr Sub_B5_8944              ; $9D9E
  jsr ProcessPpuUpdateList     ; $9DA1
  .addr Data_B5_9DAE  ; $9DA4 inline pointer (data after a JSR)
  lda #$20                     ; $9DA6
  sta $014F                    ; $9DA8
  jmp Sub_B5_90B9              ; $9DAB
Data_B5_9DAE:
  .incbin "prg_bank_5.bin", $1DAE, $D  ; $9DAE
Loc_B5_9DBB:
  jsr Sub_B5_814C              ; $9DBB
  lda #$1C                     ; $9DBE
  ldx #$0B                     ; $9DC0
  ldy #$0D                     ; $9DC2
  jsr Sub_B5_8FDE              ; $9DC4
  jsr Sub_B5_895B              ; $9DC7
  jsr Sub_B5_8971              ; $9DCA
  lda #$FF                     ; $9DCD
  ldx #$20                     ; $9DCF
  jsr Sub_B5_8944              ; $9DD1
  lda #$20                     ; $9DD4
  sta $014F                    ; $9DD6
  jsr ProcessPpuUpdateList     ; $9DD9
  .addr Data_B5_9E01  ; $9DDC inline pointer (data after a JSR)
  inc $050F                    ; $9DDE
  lda #$C8                     ; $9DE1
  sta z:PlayerLifeLo           ; $9DE3
  lda #$1E                     ; $9DE5
  sta SceneTimer               ; $9DE7
  lda #$80                     ; $9DEA
  sta $0528                    ; $9DEC
  lda #$02                     ; $9DEF
  sta $0529                    ; $9DF1
  jsr Sub_B5_90B9              ; $9DF4
  lda #$0B                     ; $9DF7
  jsr EnqueueByte              ; $9DF9
  lda #$29                     ; $9DFC
  jmp EnqueueByte              ; $9DFE
Data_B5_9E01:
  .incbin "prg_bank_5.bin", $1E01, $1FF  ; $9E01
  lda ByteQueue                ; $A000
  beq Loc_B5_A013              ; $A003
  lda #$00                     ; $A005
  sta z:Tmp00                  ; $A007
Loc_B5_A009:
  jsr Sub_B5_A044              ; $A009
  inc z:Tmp00                  ; $A00C
  dec ByteQueue                ; $A00E
  bne Loc_B5_A009              ; $A011
Loc_B5_A013:
  lda #$00                     ; $A013
  sta z:$F5                    ; $A015
  sta z:$F4                    ; $A017
Loc_B5_A019:
  lda z:$F4                    ; $A019
  asl a                        ; $A01B
  tax                          ; $A01C
  lda Data_B5_A444,x           ; $A01D
  sta z:ScriptPtrLo            ; $A020
  lda Data_B5_A445,x           ; $A022
  sta z:ScriptPtrHi            ; $A025
  ldy #$00                     ; $A027
  lda (ScriptPtrLo),y          ; $A029
  lsr a                        ; $A02B
  bcc Loc_B5_A031              ; $A02C
  jsr Sub_B5_A0C9              ; $A02E
Loc_B5_A031:
  ldy #$00                     ; $A031
  lda (ScriptPtrLo),y          ; $A033
  lsr a                        ; $A035
  ror z:$F5                    ; $A036
  inc z:$F4                    ; $A038
  lda z:$F4                    ; $A03A
  cmp #$08                     ; $A03C
  bne Loc_B5_A019              ; $A03E
  jsr Sub_B5_A3C7              ; $A040
  rts                          ; $A043
Sub_B5_A044:
  ldx z:Tmp00                  ; $A044
  lda $06E1,x                  ; $A046
  bne Loc_B5_A065              ; $A049
  ldx #$00                     ; $A04B
Loc_B5_A04D:
  txa                          ; $A04D
  asl a                        ; $A04E
  tay                          ; $A04F
  lda Data_B5_A444,y           ; $A050
  sta z:ScriptPtrLo            ; $A053
  lda Data_B5_A445,y           ; $A055
  sta z:ScriptPtrHi            ; $A058
  ldy #$00                     ; $A05A
  tya                          ; $A05C
  sta (ScriptPtrLo),y          ; $A05D
  inx                          ; $A05F
  cpx #$08                     ; $A060
  bne Loc_B5_A04D              ; $A062
  rts                          ; $A064
Loc_B5_A065:
  dec $06E1,x                  ; $A065
  lda $06E1,x                  ; $A068
  asl a                        ; $A06B
  tax                          ; $A06C
  lda Data_B5_A5A6,x           ; $A06D
  sta z:$F2                    ; $A070
  inx                          ; $A072
  lda Data_B5_A5A6,x           ; $A073
  sta z:$F3                    ; $A076
  ldy #$00                     ; $A078
  sty z:Tmp01                  ; $A07A
Loc_B5_A07C:
  ldy z:Tmp01                  ; $A07C
  lda ($F2),y                  ; $A07E
  cmp #$FF                     ; $A080
  beq Loc_B5_A0C8              ; $A082
  asl a                        ; $A084
  tax                          ; $A085
  lda Data_B5_A444,x           ; $A086
  sta z:ScriptPtrLo            ; $A089
  lda Data_B5_A445,x           ; $A08B
  sta z:ScriptPtrHi            ; $A08E
  ldy #$17                     ; $A090
  lda #$00                     ; $A092
Loc_B5_A094:
  sta (ScriptPtrLo),y          ; $A094
  dey                          ; $A096
  bpl Loc_B5_A094              ; $A097
  lda #$01                     ; $A099
  iny                          ; $A09B
  sta (ScriptPtrLo),y          ; $A09C
  lda Data_B5_A454,x           ; $A09E
  ldy #$0B                     ; $A0A1
  sta (ScriptPtrLo),y          ; $A0A3
  iny                          ; $A0A5
  lda Data_B5_A455,x           ; $A0A6
  sta (ScriptPtrLo),y          ; $A0A9
  inc z:Tmp01                  ; $A0AB
  ldy z:Tmp01                  ; $A0AD
  lda ($F2),y                  ; $A0AF
  pha                          ; $A0B1
  iny                          ; $A0B2
  lda ($F2),y                  ; $A0B3
  sty z:Tmp01                  ; $A0B5
  ldy #$04                     ; $A0B7
  sta (ScriptPtrLo),y          ; $A0B9
  pla                          ; $A0BB
  dey                          ; $A0BC
  sta (ScriptPtrLo),y          ; $A0BD
  ldy #$01                     ; $A0BF
  tya                          ; $A0C1
  sta (ScriptPtrLo),y          ; $A0C2
  inc z:Tmp01                  ; $A0C4
  bne Loc_B5_A07C              ; $A0C6
Loc_B5_A0C8:
  rts                          ; $A0C8
Sub_B5_A0C9:
  lda z:$F4                    ; $A0C9
  and #$03                     ; $A0CB
  asl a                        ; $A0CD
  asl a                        ; $A0CE
  sta $06CF                    ; $A0CF
  jsr Sub_B5_A357              ; $A0D2
  ldy #$01                     ; $A0D5
  lda (ScriptPtrLo),y          ; $A0D7
  sec                          ; $A0D9
  sbc #$01                     ; $A0DA
  beq Loc_B5_A0E1              ; $A0DC
  sta (ScriptPtrLo),y          ; $A0DE
  rts                          ; $A0E0
Loc_B5_A0E1:
  iny                          ; $A0E1
  lda (ScriptPtrLo),y          ; $A0E2
  dey                          ; $A0E4
  sta (ScriptPtrLo),y          ; $A0E5
  ldy #$07                     ; $A0E7
  lda #$00                     ; $A0E9
  sta (ScriptPtrLo),y          ; $A0EB
  jsr Sub_B5_A363              ; $A0ED
  ldy #$10                     ; $A0F0
  lda #$08                     ; $A0F2
  sta (ScriptPtrLo),y          ; $A0F4
  ldy #$03                     ; $A0F6
  lda (ScriptPtrLo),y          ; $A0F8
  sta z:Tmp02                  ; $A0FA
  iny                          ; $A0FC
  lda (ScriptPtrLo),y          ; $A0FD
  sta z:Tmp03                  ; $A0FF
  ldy #$00                     ; $A101
  sty z:Tmp01                  ; $A103
Loc_B5_A105:
  ldy z:Tmp01                  ; $A105
  inc z:Tmp01                  ; $A107
  lda (Tmp02),y                ; $A109
  bpl Loc_B5_A113              ; $A10B
  jsr Sub_B5_A1A3              ; $A10D
  jmp Loc_B5_A105              ; $A110
Loc_B5_A113:
  tax                          ; $A113
  ldy #$14                     ; $A114
  lda (ScriptPtrLo),y          ; $A116
  beq Loc_B5_A140              ; $A118
  sta z:$F6                    ; $A11A
  iny                          ; $A11C
  clc                          ; $A11D
  lda (ScriptPtrLo),y          ; $A11E
  adc #$01                     ; $A120
  sta (ScriptPtrLo),y          ; $A122
  sta z:$F7                    ; $A124
  txa                          ; $A126
Loc_B5_A127:
  clc                          ; $A127
  adc z:$F6                    ; $A128
  tay                          ; $A12A
  and #$0F                     ; $A12B
  cmp #$0C                     ; $A12D
  tya                          ; $A12F
  bcc Loc_B5_A13B              ; $A130
  ldx z:$F6                    ; $A132
  bpl *+5                      ; $A134
  sbc #$04                     ; $A136
  bit $0469                    ; $A138
Loc_B5_A13B:
  dec z:$F7                    ; $A13B
  bne Loc_B5_A127              ; $A13D
  tax                          ; $A13F
Loc_B5_A140:
  txa                          ; $A140
  and #$0F                     ; $A141
  asl a                        ; $A143
  tay                          ; $A144
  lda Data_B5_A424,y           ; $A145
  sta z:$04                    ; $A148
  lda Data_B5_A425,y           ; $A14A
  sta z:$05                    ; $A14D
  txa                          ; $A14F
  lsr a                        ; $A150
  lsr a                        ; $A151
  lsr a                        ; $A152
  lsr a                        ; $A153
  beq Loc_B5_A15E              ; $A154
  tax                          ; $A156
Loc_B5_A157:
  lsr z:$05                    ; $A157
  ror z:$04                    ; $A159
  dex                          ; $A15B
  bne Loc_B5_A157              ; $A15C
Loc_B5_A15E:
  ldy #$11                     ; $A15E
  lda z:$04                    ; $A160
  sta (ScriptPtrLo),y          ; $A162
  iny                          ; $A164
  lda z:$05                    ; $A165
  ora #$08                     ; $A167
  sta (ScriptPtrLo),y          ; $A169
  jsr Sub_B5_A17F              ; $A16B
Loc_B5_A16E:
  ldy #$03                     ; $A16E
  lda z:Tmp01                  ; $A170
  clc                          ; $A172
  adc z:Tmp02                  ; $A173
  sta (ScriptPtrLo),y          ; $A175
  iny                          ; $A177
  lda z:Tmp03                  ; $A178
  adc #$00                     ; $A17A
  sta (ScriptPtrLo),y          ; $A17C
  rts                          ; $A17E
Sub_B5_A17F:
  jsr Sub_B5_A402              ; $A17F
  bne Loc_B5_A1A2              ; $A182
Sub_B5_A184:
  ldx $06CF                    ; $A184
  lda $06D0,x                  ; $A187
  ora #$20                     ; $A18A
  sta $06D0,x                  ; $A18C
  ldy #$10                     ; $A18F
  lda (ScriptPtrLo),y          ; $A191
  sta $06D1,x                  ; $A193
  iny                          ; $A196
  lda (ScriptPtrLo),y          ; $A197
  sta $06D2,x                  ; $A199
  iny                          ; $A19C
  lda (ScriptPtrLo),y          ; $A19D
  sta $06D3,x                  ; $A19F
Loc_B5_A1A2:
  rts                          ; $A1A2
Sub_B5_A1A3:
  sta z:$06                    ; $A1A3
  and #$7F                     ; $A1A5
  lsr a                        ; $A1A7
  lsr a                        ; $A1A8
  lsr a                        ; $A1A9
  lsr a                        ; $A1AA
  jsr Sub_B5_A464              ; $A1AB
  .addr Sub_B5_A1BE, Sub_B5_A1BE, Sub_B5_A1CE, Sub_B5_A1CE, Sub_B5_A1EA, Sub_B5_A1FF, Sub_B5_A22E  ; $A1AE pointer table
  .incbin "prg_bank_5.bin", $21BC, $2  ; $A1BC
Sub_B5_A1BE:
  lda z:$06                    ; $A1BE
  and #$1F                     ; $A1C0
  tax                          ; $A1C2
  lda Data_B5_A496,x           ; $A1C3
  ldy #$01                     ; $A1C6
  sta (ScriptPtrLo),y          ; $A1C8
  iny                          ; $A1CA
  sta (ScriptPtrLo),y          ; $A1CB
  rts                          ; $A1CD
Sub_B5_A1CE:
  lda z:$06                    ; $A1CE
  and #$1F                     ; $A1D0
  asl a                        ; $A1D2
  tax                          ; $A1D3
  ldy #$05                     ; $A1D4
  lda Data_B5_A4B6,x           ; $A1D6
  sta (ScriptPtrLo),y          ; $A1D9
  iny                          ; $A1DB
  lda Data_B5_A4B7,x           ; $A1DC
  sta (ScriptPtrLo),y          ; $A1DF
  iny                          ; $A1E1
  lda #$00                     ; $A1E2
  sta (ScriptPtrLo),y          ; $A1E4
  jsr Sub_B5_A363              ; $A1E6
  rts                          ; $A1E9
Sub_B5_A1EA:
  lda z:$06                    ; $A1EA
  and #$0F                     ; $A1EC
  ldy #$11                     ; $A1EE
  sta (ScriptPtrLo),y          ; $A1F0
  lda #$08                     ; $A1F2
  iny                          ; $A1F4
  sta (ScriptPtrLo),y          ; $A1F5
  jsr Sub_B5_A17F              ; $A1F7
  pla                          ; $A1FA
  pla                          ; $A1FB
  jmp Loc_B5_A16E              ; $A1FC
Sub_B5_A1FF:
  lda z:$06                    ; $A1FF
  and #$0F                     ; $A201
  cmp #$08                     ; $A203
  bcs Loc_B5_A21A              ; $A205
  clc                          ; $A207
  ror a                        ; $A208
  ror a                        ; $A209
  ror a                        ; $A20A
  pha                          ; $A20B
  ldy #$0F                     ; $A20C
  lda (ScriptPtrLo),y          ; $A20E
  and #$3F                     ; $A210
  sta (ScriptPtrLo),y          ; $A212
  pla                          ; $A214
  ora (ScriptPtrLo),y          ; $A215
  sta (ScriptPtrLo),y          ; $A217
  rts                          ; $A219
Loc_B5_A21A:
  and #$03                     ; $A21A
  tax                          ; $A21C
  lda Data_B5_A420,x           ; $A21D
  ldy #$14                     ; $A220
  cmp (ScriptPtrLo),y          ; $A222
  sta (ScriptPtrLo),y          ; $A224
  beq Loc_B5_A22D              ; $A226
  lda #$00                     ; $A228
  iny                          ; $A22A
  sta (ScriptPtrLo),y          ; $A22B
Loc_B5_A22D:
  rts                          ; $A22D
Sub_B5_A22E:
  lda z:$06                    ; $A22E
  and #$0F                     ; $A230
  ldy #$0D                     ; $A232
  sta (ScriptPtrLo),y          ; $A234
  rts                          ; $A236
  lda z:$06                    ; $A237
  and #$07                     ; $A239
  jsr Sub_B5_A464              ; $A23B
  .addr Sub_B5_A24E, Sub_B5_A269, Sub_B5_A284, Sub_B5_A2A8, Sub_B5_A2F4, Sub_B5_A321, Sub_B5_A32C, Sub_B5_A32C  ; $A23E pointer table
Sub_B5_A24E:
  ldy z:Tmp01                  ; $A24E
  lda (Tmp02),y                ; $A250
  pha                          ; $A252
  iny                          ; $A253
  lda (Tmp02),y                ; $A254
  pha                          ; $A256
  ldy #$00                     ; $A257
  sty z:Tmp01                  ; $A259
  ldy #$04                     ; $A25B
  pla                          ; $A25D
  sta (ScriptPtrLo),y          ; $A25E
  sta z:Tmp03                  ; $A260
  dey                          ; $A262
  pla                          ; $A263
  sta (ScriptPtrLo),y          ; $A264
  sta z:Tmp02                  ; $A266
  rts                          ; $A268
Sub_B5_A269:
  ldy z:Tmp01                  ; $A269
  lda (Tmp02),y                ; $A26B
  ldy #$13                     ; $A26D
  sta (ScriptPtrLo),y          ; $A26F
  inc z:Tmp01                  ; $A271
  lda z:Tmp01                  ; $A273
  clc                          ; $A275
  adc z:Tmp02                  ; $A276
  ldy #$09                     ; $A278
  sta (ScriptPtrLo),y          ; $A27A
  iny                          ; $A27C
  lda z:Tmp03                  ; $A27D
  adc #$00                     ; $A27F
  sta (ScriptPtrLo),y          ; $A281
  rts                          ; $A283
Sub_B5_A284:
  ldy #$13                     ; $A284
  lda (ScriptPtrLo),y          ; $A286
  sec                          ; $A288
  sbc #$01                     ; $A289
  beq Loc_B5_A2A7              ; $A28B
  sta (ScriptPtrLo),y          ; $A28D
  ldy #$09                     ; $A28F
  lda (ScriptPtrLo),y          ; $A291
  pha                          ; $A293
  iny                          ; $A294
  lda (ScriptPtrLo),y          ; $A295
  ldy #$04                     ; $A297
  sta (ScriptPtrLo),y          ; $A299
  sta z:Tmp03                  ; $A29B
  dey                          ; $A29D
  pla                          ; $A29E
  sta (ScriptPtrLo),y          ; $A29F
  sta z:Tmp02                  ; $A2A1
  lda #$00                     ; $A2A3
  sta z:Tmp01                  ; $A2A5
Loc_B5_A2A7:
  rts                          ; $A2A7
Sub_B5_A2A8:
  ldy z:Tmp01                  ; $A2A8
  lda (Tmp02),y                ; $A2AA
  ldy #$03                     ; $A2AC
  sta (ScriptPtrLo),y          ; $A2AE
  inc z:Tmp01                  ; $A2B0
  ldy z:Tmp01                  ; $A2B2
  lda (Tmp02),y                ; $A2B4
  ldy #$04                     ; $A2B6
  sta (ScriptPtrLo),y          ; $A2B8
  inc z:Tmp01                  ; $A2BA
  lda z:Tmp01                  ; $A2BC
  clc                          ; $A2BE
  adc z:Tmp02                  ; $A2BF
  pha                          ; $A2C1
  lda z:Tmp03                  ; $A2C2
  adc #$00                     ; $A2C4
  pha                          ; $A2C6
  ldy #$0B                     ; $A2C7
  lda (ScriptPtrLo),y          ; $A2C9
  sta z:$08                    ; $A2CB
  clc                          ; $A2CD
  adc #$02                     ; $A2CE
  sta (ScriptPtrLo),y          ; $A2D0
  iny                          ; $A2D2
  lda (ScriptPtrLo),y          ; $A2D3
  sta z:$09                    ; $A2D5
  adc #$00                     ; $A2D7
  sta (ScriptPtrLo),y          ; $A2D9
  ldy #$01                     ; $A2DB
  pla                          ; $A2DD
  sta ($08),y                  ; $A2DE
  dey                          ; $A2E0
  pla                          ; $A2E1
  sta ($08),y                  ; $A2E2
  lda #$00                     ; $A2E4
  sta z:Tmp01                  ; $A2E6
  ldy #$03                     ; $A2E8
  lda (ScriptPtrLo),y          ; $A2EA
  sta z:Tmp02                  ; $A2EC
  iny                          ; $A2EE
  lda (ScriptPtrLo),y          ; $A2EF
  sta z:Tmp03                  ; $A2F1
  rts                          ; $A2F3
Sub_B5_A2F4:
  ldy #$0B                     ; $A2F4
  sec                          ; $A2F6
  lda (ScriptPtrLo),y          ; $A2F7
  sbc #$02                     ; $A2F9
  sta (ScriptPtrLo),y          ; $A2FB
  sta z:$08                    ; $A2FD
  iny                          ; $A2FF
  lda (ScriptPtrLo),y          ; $A300
  sbc #$00                     ; $A302
  sta (ScriptPtrLo),y          ; $A304
  sta z:$09                    ; $A306
  ldy #$00                     ; $A308
  lda ($08),y                  ; $A30A
  pha                          ; $A30C
  iny                          ; $A30D
  lda ($08),y                  ; $A30E
  ldy #$04                     ; $A310
  sta (ScriptPtrLo),y          ; $A312
  sta z:Tmp03                  ; $A314
  dey                          ; $A316
  pla                          ; $A317
  sta (ScriptPtrLo),y          ; $A318
  sta z:Tmp02                  ; $A31A
  lda #$00                     ; $A31C
  sta z:Tmp01                  ; $A31E
  rts                          ; $A320
Sub_B5_A321:
  ldy z:Tmp01                  ; $A321
  lda (Tmp02),y                ; $A323
  inc z:Tmp01                  ; $A325
  ldy #$10                     ; $A327
  sta (ScriptPtrLo),y          ; $A329
  rts                          ; $A32B
Sub_B5_A32C:
  lda #$00                     ; $A32C
  ldy #$00                     ; $A32E
  sta (ScriptPtrLo),y          ; $A330
  lda #$04                     ; $A332
  bit z:$F4                    ; $A334
  beq Loc_B5_A354              ; $A336
  lda z:$F4                    ; $A338
  and #$03                     ; $A33A
  asl a                        ; $A33C
  tax                          ; $A33D
  lda Data_B5_A444,x           ; $A33E
  sta z:ScriptPtrLo            ; $A341
  lda Data_B5_A445,x           ; $A343
  sta z:ScriptPtrHi            ; $A346
  jsr Sub_B5_A184              ; $A348
  ldy #$0F                     ; $A34B
  lda (ScriptPtrLo),y          ; $A34D
  ora #$20                     ; $A34F
  sta $06D0,x                  ; $A351
Loc_B5_A354:
  pla                          ; $A354
  pla                          ; $A355
  rts                          ; $A356
Sub_B5_A357:
  ldy #$0E                     ; $A357
  lda (ScriptPtrLo),y          ; $A359
  beq Sub_B5_A363              ; $A35B
  sec                          ; $A35D
  sbc #$01                     ; $A35E
  sta (ScriptPtrLo),y          ; $A360
  rts                          ; $A362
Sub_B5_A363:
  ldy #$05                     ; $A363
  lda (ScriptPtrLo),y          ; $A365
  sta z:$04                    ; $A367
  iny                          ; $A369
  lda (ScriptPtrLo),y          ; $A36A
  sta z:$05                    ; $A36C
  iny                          ; $A36E
  lda (ScriptPtrLo),y          ; $A36F
  tay                          ; $A371
  lda ($04),y                  ; $A372
  pha                          ; $A374
  iny                          ; $A375
  lda ($04),y                  ; $A376
  pha                          ; $A378
  ldy #$07                     ; $A379
  lda (ScriptPtrLo),y          ; $A37B
  clc                          ; $A37D
  adc #$02                     ; $A37E
  sta (ScriptPtrLo),y          ; $A380
  ldy #$0E                     ; $A382
  pla                          ; $A384
  sta (ScriptPtrLo),y          ; $A385
  iny                          ; $A387
  lda (ScriptPtrLo),y          ; $A388
  and #$C0                     ; $A38A
  sta z:$04                    ; $A38C
  pla                          ; $A38E
  ora z:$04                    ; $A38F
  sta z:$04                    ; $A391
  and #$10                     ; $A393
  beq Loc_B5_A3B1              ; $A395
  lda z:$04                    ; $A397
  and #$0F                     ; $A399
  ldy #$0D                     ; $A39B
  sec                          ; $A39D
  sbc (ScriptPtrLo),y          ; $A39E
  bcs Loc_B5_A3A4              ; $A3A0
  lda #$00                     ; $A3A2
Loc_B5_A3A4:
  and #$0F                     ; $A3A4
  pha                          ; $A3A6
  lda z:$04                    ; $A3A7
  and #$D0                     ; $A3A9
  sta z:$04                    ; $A3AB
  pla                          ; $A3AD
  ora z:$04                    ; $A3AE
  .incbin "prg_bank_5.bin", $23B0, $1  ; $A3B0
Loc_B5_A3B1:
  lda z:$04                    ; $A3B1
  ldy #$0F                     ; $A3B3
  sta (ScriptPtrLo),y          ; $A3B5
  jsr Sub_B5_A402              ; $A3B7
  bne Loc_B5_A3C6              ; $A3BA
  ldy #$0F                     ; $A3BC
  lda (ScriptPtrLo),y          ; $A3BE
  ldx $06CF                    ; $A3C0
  sta $06D0,x                  ; $A3C3
Loc_B5_A3C6:
  rts                          ; $A3C6
Sub_B5_A3C7:
  lda z:$F5                    ; $A3C7
  lsr a                        ; $A3C9
  lsr a                        ; $A3CA
  lsr a                        ; $A3CB
  lsr a                        ; $A3CC
  ora z:$F5                    ; $A3CD
  and #$0F                     ; $A3CF
  sta APU_SND_CHN              ; $A3D1
  ldx #$00                     ; $A3D4
Loc_B5_A3D6:
  lda $06D0,x                  ; $A3D6
  pha                          ; $A3D9
  and #$DF                     ; $A3DA
  sta APU_PL1_VOL,x            ; $A3DC
  sta $06D0,x                  ; $A3DF
  pla                          ; $A3E2
  and #$20                     ; $A3E3
  beq Loc_B5_A3F9              ; $A3E5
  lda $06D1,x                  ; $A3E7
  sta APU_PL1_SWEEP,x          ; $A3EA
  lda $06D2,x                  ; $A3ED
  sta APU_PL1_LO,x             ; $A3F0
  lda $06D3,x                  ; $A3F3
  sta APU_PL1_HI,x             ; $A3F6
Loc_B5_A3F9:
  inx                          ; $A3F9
  inx                          ; $A3FA
  inx                          ; $A3FB
  inx                          ; $A3FC
  cpx #$10                     ; $A3FD
  bne Loc_B5_A3D6              ; $A3FF
  rts                          ; $A401
Sub_B5_A402:
  lda z:$F4                    ; $A402
  cmp #$04                     ; $A404
  bcc Loc_B5_A40B              ; $A406
  lda #$00                     ; $A408
  rts                          ; $A40A
Loc_B5_A40B:
  ora #$04                     ; $A40B
  asl a                        ; $A40D
  tax                          ; $A40E
  lda Data_B5_A444,x           ; $A40F
  sta z:$0A                    ; $A412
  lda Data_B5_A445,x           ; $A414
  sta z:$0B                    ; $A417
  ldy #$00                     ; $A419
  lda ($0A),y                  ; $A41B
  and #$01                     ; $A41D
  rts                          ; $A41F
Data_B5_A420:
  .incbin "prg_bank_5.bin", $2420, $4  ; $A420
Data_B5_A424:
  .incbin "prg_bank_5.bin", $2424, $1  ; $A424
Data_B5_A425:
  .incbin "prg_bank_5.bin", $2425, $1F  ; $A425
Data_B5_A444:
  .incbin "prg_bank_5.bin", $2444, $1  ; $A444
Data_B5_A445:
  .incbin "prg_bank_5.bin", $2445, $F  ; $A445
Data_B5_A454:
  .incbin "prg_bank_5.bin", $2454, $1  ; $A454
Data_B5_A455:
  .incbin "prg_bank_5.bin", $2455, $F  ; $A455
Sub_B5_A464:
  asl a                        ; $A464
  tay                          ; $A465
  pla                          ; $A466
  sta z:$4C                    ; $A467
  pla                          ; $A469
  sta z:$4D                    ; $A46A
  iny                          ; $A46C
  lda ($4C),y                  ; $A46D
  sta z:$4E                    ; $A46F
  iny                          ; $A471
  lda ($4C),y                  ; $A472
  sta z:$4F                    ; $A474
  jmp ($004E)                  ; $A476
  .incbin "prg_bank_5.bin", $2479, $1D  ; $A479
Data_B5_A496:
  .incbin "prg_bank_5.bin", $2496, $20  ; $A496
Data_B5_A4B6:
  .incbin "prg_bank_5.bin", $24B6, $1  ; $A4B6
Data_B5_A4B7:
  .incbin "prg_bank_5.bin", $24B7, $EF  ; $A4B7
Data_B5_A5A6:
  .incbin "prg_bank_5.bin", $25A6, $400  ; $A5A6
  .incbin "prg_bank_5.bin", $29A6, $400  ; $A9A6
  .incbin "prg_bank_5.bin", $2DA6, $400  ; $ADA6
  .incbin "prg_bank_5.bin", $31A6, $400  ; $B1A6
  .incbin "prg_bank_5.bin", $35A6, $400  ; $B5A6
  .incbin "prg_bank_5.bin", $39A6, $400  ; $B9A6
  .incbin "prg_bank_5.bin", $3DA6, $257  ; $BDA6
Data_B5_BFFD:
  .incbin "prg_bank_5.bin", $3FFD, $3  ; $BFFD
