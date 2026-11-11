; Bank 5  ($8000-$BFFF switchable)
; Intro and cutscenes: helicopter briefing ('Approach / Close up / Snipe'), sniper-scope intro, title screen, skyline with helicopter, office briefing (man in a suit at a window), act title cards, 'To be continued'. SceneState = TransitionTarget - $8F.
.segment "PRG_BANK_5"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B5_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_5.bin", $0009, $1  ; $8009
CallBank5FromBank4A:
  jmp Loc_B5_BD80              ; $800A
CallBank5FromBank4B:
  jmp Loc_B5_BDF9              ; $800D
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
  jsr Sub_B5_804F              ; $8035
  jsr ApplyScroll              ; $8038
  jsr ReadJoypads              ; $803B
  jsr SkipSceneOnStart         ; $803E
  jsr RunSoundDriverBank5Timed ; $8041
  lda PPU_STATUS               ; $8044
  lda z:PpuCtrlShadow          ; $8047
  ora #$80                     ; $8049
  jsr SetPpuCtrl               ; $804B
  rti                          ; $804E
Sub_B5_804F:
  lda SceneState               ; $804F
  cmp #$6C                     ; $8052
Loc_B5_8054:
  bcs Loc_B5_8054              ; $8054
  asl a                        ; $8056
  tax                          ; $8057
  lda Data_B5_8065,x           ; $8058
  sta z:Tmp00                  ; $805B
  lda Data_B5_8066,x           ; $805D
  sta z:Tmp01                  ; $8060
  jmp ($0000)                  ; $8062
Data_B5_8065:
  .addr Bank5Tbl8065_00, Bank5Tbl8065_01, Bank5Tbl8065_02, Bank5Tbl8065_03, Bank5Tbl8065_04, Bank5Scene_05, Bank5Tbl8065_06, Bank5Tbl8065_07, Bank5Tbl8065_08, Bank5Tbl8065_09, Bank5Tbl8065_0A, Bank5Scene_0B, Bank5Tbl8065_0C, Bank5Scene_0D, Bank5Tbl8065_0E, Bank5Tbl8065_0F, Bank5Tbl8065_10, Bank5Tbl8065_11, Bank5Tbl8065_12, Bank5Tbl8065_13, Bank5Tbl8065_14, Bank5Scene_17, Bank5Tbl8065_16, Bank5Tbl8065_17, Bank5Tbl8065_18, Bank5Tbl8065_19, Bank5Tbl8065_1A, Bank5Tbl8065_1B, Bank5Tbl8065_1C, Bank5Scene_1F, Bank5Tbl8065_1E, Bank5Tbl8065_1F, Bank5Tbl8065_20, Bank5Tbl8065_21, Bank5Tbl8065_22, Bank5Tbl8065_23, Bank5Tbl8065_24, Bank5Tbl8065_25, Bank5Tbl8065_26, Bank5Tbl8065_27, Bank5Tbl8065_28, Bank5Tbl8065_29, Bank5Tbl8065_2A, Bank5Tbl8065_2B, Bank5Tbl8065_2C, Bank5Tbl8065_2D, Bank5Scene_2E, Bank5Tbl8065_2F, Bank5Tbl8065_17, Bank5Tbl8065_18, Bank5Tbl8065_19, Bank5Tbl8065_1A, Bank5Tbl8065_1B, Bank5Tbl8065_1C, Bank5Scene_1F, Bank5Tbl8065_37, Bank5Tbl8065_38, Bank5Tbl8065_39, Bank5Tbl8065_3A, Bank5Tbl8065_3B, Bank5Scene_3C, Bank5Tbl8065_2B, Bank5Tbl8065_2C, Bank5Tbl8065_17, Bank5Tbl8065_18, Bank5Tbl8065_19, Bank5Tbl8065_1A, Bank5Tbl8065_1B, Bank5Tbl8065_1C, Bank5Scene_1F, Bank5Tbl8065_46, Bank5Tbl8065_47, Bank5Tbl8065_48, Bank5Tbl8065_49, Bank5Tbl8065_4A, Bank5Tbl8065_4B, Bank5Scene_4C, Bank5Tbl8065_4D, Bank5Tbl8065_4E, Bank5Tbl8065_4F, Bank5Scene_50, Bank5Tbl8065_51, Bank5Tbl8065_52, Bank5Tbl8065_53, Bank5Scene_54, Bank5Tbl8065_55, Bank5Tbl8065_56, Bank5Scene_57, Bank5Tbl8065_58, Bank5Scene_59, Bank5Scene_5A, Bank5Tbl8065_5B, Bank5Tbl8065_5C, Bank5Tbl8065_5D  ; $8065 pointer table
  .incbin "prg_bank_5.bin", $0121, $1C  ; $8121
Bank5Tbl8065_00:
  lda #$04                     ; $813D
Loc_B5_813F:
  sta SceneState               ; $813F
  jsr ClearSceneStateTailB5    ; $8142
  jsr BlankScreenAndInitPpu    ; $8145
  jsr InitDmcAndJoypad2        ; $8148
  lda #$00                     ; $814B
  jsr QueueSound               ; $814D
Sub_B5_8150:
  lda z:PpuMaskShadow          ; $8150
  and #$E7                     ; $8152
  jmp SetPpuMask               ; $8154
Bank5Tbl8065_01:
  lda #$2B                     ; $8157
  jmp Loc_B5_813F              ; $8159
Bank5Tbl8065_02:
  lda #$3D                     ; $815C
  jmp Loc_B5_813F              ; $815E
Bank5Tbl8065_03:
  lda #$5F                     ; $8161
  ldx $050F                    ; $8163
  cpx #$33                     ; $8166
  bcc Loc_B5_816C              ; $8168
  lda #$68                     ; $816A
Loc_B5_816C:
  jmp Loc_B5_813F              ; $816C
Bank5Tbl8065_04:
  inc SceneState               ; $816F
  lda #$00                     ; $8172
  sta $012A                    ; $8174
  jmp Loc_B5_8A1A              ; $8177
Bank5Scene_05:
  dec SceneTimer               ; $817A
  bne Loc_B5_818D              ; $817D
  inc SceneState               ; $817F
  lda #$0E                     ; $8182
  jsr QueueSound               ; $8184
EnableRendering:
  lda z:PpuMaskShadow          ; $8187
  ora #$18                     ; $8189
  sta z:PpuMaskShadow          ; $818B
Loc_B5_818D:
  rts                          ; $818D
Bank5Tbl8065_06:
  jsr AnimateSkylineWindows    ; $818E
  jsr AnimateHelicopterSprite  ; $8191
  lda $053F                    ; $8194
  bne Loc_B5_81A1              ; $8197
  inc SceneState               ; $8199
  lda #$28                     ; $819C
  sta SceneTimer               ; $819E
Loc_B5_81A1:
  rts                          ; $81A1
Bank5Tbl8065_07:
  dec SceneTimer               ; $81A2
  bne Loc_B5_81AF              ; $81A5
  inc SceneState               ; $81A7
  lda #$01                     ; $81AA
  sta SceneSubState            ; $81AC
Loc_B5_81AF:
  rts                          ; $81AF
Bank5Tbl8065_08:
  jsr Sub_B5_8A50              ; $81B0
  lda AnimCounter              ; $81B3
  bne Loc_B5_81C0              ; $81B6
  inc SceneState               ; $81B8
  lda #$B4                     ; $81BB
  sta SceneTimer               ; $81BD
Loc_B5_81C0:
  rts                          ; $81C0
Bank5Tbl8065_09:
  dec SceneTimer               ; $81C1
  bne Loc_B5_81CE              ; $81C4
  inc SceneState               ; $81C6
  lda #$03                     ; $81C9
  sta SceneSubState            ; $81CB
Loc_B5_81CE:
  rts                          ; $81CE
Bank5Tbl8065_0A:
  jsr Sub_B5_8A50              ; $81CF
  lda AnimCounter              ; $81D2
  bne Loc_B5_81E5              ; $81D5
  inc SceneState               ; $81D7
  lda #$1E                     ; $81DA
  sta SceneTimer               ; $81DC
  jsr FillPaletteBufferBlack   ; $81DF
  jmp HideAllSpritesB5         ; $81E2
Loc_B5_81E5:
  rts                          ; $81E5
Bank5Scene_0B:
  dec SceneTimer               ; $81E6
  bne Loc_B5_81EE              ; $81E9
  inc SceneState               ; $81EB
Loc_B5_81EE:
  rts                          ; $81EE
Bank5Tbl8065_0C:
  inc SceneState               ; $81EF
  lda #$01                     ; $81F2
  sta $012A                    ; $81F4
  jmp Loc_B5_8FCC              ; $81F7
Bank5Scene_0D:
  lda $0600                    ; $81FA
  cmp #$60                     ; $81FD
  beq Loc_B5_8209              ; $81FF
  inc SceneState               ; $8201
  lda #$29                     ; $8204
  jsr QueueSound               ; $8206
Loc_B5_8209:
  jsr DrawOfficeSpeakerSprites ; $8209
  jmp Loc_B5_8F3C              ; $820C
Bank5Tbl8065_0E:
  jsr AnimateOfficeSpeaker     ; $820F
  lda $052E                    ; $8212
  bne Loc_B5_821F              ; $8215
  inc SceneState               ; $8217
  lda #$3C                     ; $821A
  sta SceneTimer               ; $821C
Loc_B5_821F:
  rts                          ; $821F
Bank5Tbl8065_0F:
  dec SceneTimer               ; $8220
  bne Loc_B5_822D              ; $8223
  inc SceneState               ; $8225
  lda #$04                     ; $8228
  sta SceneSubState            ; $822A
Loc_B5_822D:
  rts                          ; $822D
Bank5Tbl8065_10:
  jsr Sub_B5_8A50              ; $822E
  lda AnimCounter              ; $8231
  bne Loc_B5_8239              ; $8234
  inc SceneState               ; $8236
Loc_B5_8239:
  rts                          ; $8239
Bank5Tbl8065_11:
  inc SceneState               ; $823A
  lda #$02                     ; $823D
  sta $012A                    ; $823F
  jsr Sub_B5_8951              ; $8242
Loc_B5_8245:
  lda #$E0                     ; $8245
  sta $0528                    ; $8247
  lda #$10                     ; $824A
  sta $0529                    ; $824C
  lda #$01                     ; $824F
  sta $052A                    ; $8251
  jmp QueueSound               ; $8254
Bank5Tbl8065_12:
  dec SceneTimer               ; $8257
  bne Loc_B5_825F              ; $825A
  inc SceneState               ; $825C
Loc_B5_825F:
  jmp EnableRendering          ; $825F
Bank5Tbl8065_13:
  inc z:HwScrollX              ; $8262
  inc z:HwScrollX              ; $8264
  bne Loc_B5_8274              ; $8266
  inc SceneState               ; $8268
  lda #$33                     ; $826B
  sta z:PpuCtrlShadow          ; $826D
  lda #$5A                     ; $826F
  sta SceneTimer               ; $8271
Loc_B5_8274:
  jsr ApplyScroll              ; $8274
  jmp Loc_B5_8725              ; $8277
Bank5Tbl8065_14:
  dec SceneTimer               ; $827A
  bne Loc_B5_828C              ; $827D
  inc SceneState               ; $827F
  lda #$02                     ; $8282
  sta $053B                    ; $8284
  lda #$00                     ; $8287
  sta $053E                    ; $8289
Loc_B5_828C:
  rts                          ; $828C
Bank5Scene_17:
  inc z:HwScrollX              ; $828D
  inc z:HwScrollX              ; $828F
  bne Loc_B5_82A2              ; $8291
  inc SceneState               ; $8293
  lda #$30                     ; $8296
  sta z:PpuCtrlShadow          ; $8298
  lda #$3C                     ; $829A
  sta SceneTimer               ; $829C
  jsr Sub_B5_8150              ; $829F
Loc_B5_82A2:
  jsr ApplyScroll              ; $82A2
  jmp Loc_B5_8725              ; $82A5
Bank5Tbl8065_16:
  dec SceneTimer               ; $82A8
  bne Loc_B5_82B0              ; $82AB
  inc SceneState               ; $82AD
Loc_B5_82B0:
  rts                          ; $82B0
Bank5Tbl8065_17:
  inc SceneState               ; $82B1
  lda #$03                     ; $82B4
  sta $012A                    ; $82B6
  jmp Loc_B5_91AE              ; $82B9
Bank5Tbl8065_18:
  inc SceneState               ; $82BC
  lda #$05                     ; $82BF
  sta SceneSubState            ; $82C1
  jmp EnableRendering          ; $82C4
Bank5Tbl8065_19:
  jsr Sub_B5_8A50              ; $82C7
  lda AnimCounter              ; $82CA
  bne Loc_B5_82D7              ; $82CD
  inc SceneState               ; $82CF
  lda #$3C                     ; $82D2
  sta SceneTimer               ; $82D4
Loc_B5_82D7:
  rts                          ; $82D7
Bank5Tbl8065_1A:
  dec SceneTimer               ; $82D8
  bne Loc_B5_82E8              ; $82DB
  inc SceneState               ; $82DD
  lda #$0F                     ; $82E0
  sta $0141                    ; $82E2
  sta $0142                    ; $82E5
Loc_B5_82E8:
  rts                          ; $82E8
Bank5Tbl8065_1B:
  jsr Sub_B5_8853              ; $82E9
  lda $052B                    ; $82EC
  bne Loc_B5_82F9              ; $82EF
  inc SceneState               ; $82F1
  lda #$06                     ; $82F4
  sta SceneSubState            ; $82F6
Loc_B5_82F9:
  rts                          ; $82F9
Bank5Tbl8065_1C:
  jsr Sub_B5_8A50              ; $82FA
  lda AnimCounter              ; $82FD
  bne Loc_B5_830D              ; $8300
  inc SceneState               ; $8302
  jsr Sub_B5_8150              ; $8305
  lda #$28                     ; $8308
  sta SceneTimer               ; $830A
Loc_B5_830D:
  rts                          ; $830D
Bank5Scene_1F:
  dec SceneTimer               ; $830E
  bne Loc_B5_8316              ; $8311
  inc SceneState               ; $8313
Loc_B5_8316:
  rts                          ; $8316
Bank5Tbl8065_1E:
  inc SceneState               ; $8317
  lda #$04                     ; $831A
  sta $012A                    ; $831C
  jmp Loc_B5_901E              ; $831F
Bank5Tbl8065_1F:
  inc SceneState               ; $8322
  lda #$3C                     ; $8325
  sta $0547                    ; $8327
  jsr CopyRamStub0513          ; $832A
  jmp EnableRendering          ; $832D
Bank5Tbl8065_20:
  jsr $0513                    ; $8330
  lda $0547                    ; $8333
  bne Loc_B5_833B              ; $8336
  inc SceneState               ; $8338
Loc_B5_833B:
  rts                          ; $833B
Bank5Tbl8065_21:
  inc SceneState               ; $833C
  lda #$05                     ; $833F
  sta $012A                    ; $8341
  jmp Loc_B5_8EEA              ; $8344
Bank5Tbl8065_22:
  dec SceneTimer               ; $8347
  bne Loc_B5_8352              ; $834A
  inc SceneState               ; $834C
  jmp EnableRendering          ; $834F
Loc_B5_8352:
  rts                          ; $8352
Bank5Tbl8065_23:
  jsr Sub_B5_8E5E              ; $8353
  lda $0538                    ; $8356
  bne Loc_B5_8366              ; $8359
  inc SceneState               ; $835B
  lda #$5A                     ; $835E
  sta SceneTimer               ; $8360
  jmp Sub_B5_8150              ; $8363
Loc_B5_8366:
  rts                          ; $8366
Bank5Tbl8065_24:
  dec SceneTimer               ; $8367
  bne Loc_B5_836F              ; $836A
Bank5Scene_24:
  inc SceneState               ; $836C
Loc_B5_836F:
  rts                          ; $836F
SkipSceneOnStart:
  lda SceneState               ; $8370
  cmp #$61                     ; $8373
  beq Loc_B5_8383              ; $8375
  cmp #$64                     ; $8377
  beq Loc_B5_8383              ; $8379
  cmp #$05                     ; $837B
  bcc Loc_B5_8394              ; $837D
  cmp #$25                     ; $837F
  bcs Loc_B5_8394              ; $8381
Loc_B5_8383:
  lda JoyNew1                  ; $8383
  and #$08                     ; $8386
  beq Loc_B5_8394              ; $8388
  lda #$25                     ; $838A
  sta SceneState               ; $838C
  lda #$00                     ; $838F
  sta $0600                    ; $8391
Loc_B5_8394:
  rts                          ; $8394
Bank5Tbl8065_25:
  inc SceneState               ; $8395
  jsr Sub_B5_90A7              ; $8398
  lda $052A                    ; $839B
  bne Loc_B5_83A3              ; $839E
  jmp QueueSound               ; $83A0
Loc_B5_83A3:
  rts                          ; $83A3
Bank5Tbl8065_26:
  inc SceneState               ; $83A4
  lda #$00                     ; $83A7
  sta AnimCounter              ; $83A9
  lda #$07                     ; $83AC
  sta SceneSubState            ; $83AE
  jsr EnableRendering          ; $83B1
  lda $052A                    ; $83B4
  bne Loc_B5_83BC              ; $83B7
  jmp Loc_B5_8245              ; $83B9
Loc_B5_83BC:
  rts                          ; $83BC
Bank5Tbl8065_27:
  jsr Sub_B5_8A50              ; $83BD
  lda AnimCounter              ; $83C0
  bne Loc_B5_83C8              ; $83C3
  inc SceneState               ; $83C5
Loc_B5_83C8:
  rts                          ; $83C8
Bank5Tbl8065_28:
  lda JoyNew1                  ; $83C9
  and #$08                     ; $83CC
  beq Loc_B5_83EF              ; $83CE
  lda #$00                     ; $83D0
  sta z:MmcPrgShadow           ; $83D2
  sta z:GameState              ; $83D4
  lda #$C8                     ; $83D6
  sta z:PlayerLifeLo           ; $83D8
  jsr HideAllSpritesB5         ; $83DA
  lda $050F                    ; $83DD
  beq Loc_B5_83EF              ; $83E0
  lda #$01                     ; $83E2
  sta $013E                    ; $83E4
  lda #$03                     ; $83E7
  sta $0106                    ; $83E9
  jmp Loc_B5_83FD              ; $83EC
Loc_B5_83EF:
  sta $013E                    ; $83EF
  sta $0106                    ; $83F2
  sta z:TransitionPending      ; $83F5
  sta z:TransitionTarget       ; $83F7
  sta z:$2A                    ; $83F9
  sta z:$2B                    ; $83FB
Loc_B5_83FD:
  lda $0528                    ; $83FD
  ora $0529                    ; $8400
  bne Loc_B5_8410              ; $8403
  inc SceneState               ; $8405
  sta $052A                    ; $8408
  lda #$08                     ; $840B
  sta SceneSubState            ; $840D
Loc_B5_8410:
  rts                          ; $8410
Bank5Tbl8065_29:
  jsr Sub_B5_8A50              ; $8411
  lda AnimCounter              ; $8414
  bne Loc_B5_8426              ; $8417
  inc SceneState               ; $8419
  lda #$3C                     ; $841C
  sta SceneTimer               ; $841E
  lda #$00                     ; $8421
  jmp QueueSound               ; $8423
Loc_B5_8426:
  rts                          ; $8426
Bank5Tbl8065_2A:
  dec SceneTimer               ; $8427
  bne Loc_B5_8431              ; $842A
  lda #$00                     ; $842C
  sta SceneState               ; $842E
Loc_B5_8431:
  rts                          ; $8431
Bank5Tbl8065_2B:
  inc SceneState               ; $8432
  lda #$3C                     ; $8435
  sta SceneTimer               ; $8437
  jsr FillPaletteBufferBlack   ; $843A
  jmp Sub_B5_8150              ; $843D
Bank5Tbl8065_2C:
  dec SceneTimer               ; $8440
  bne Loc_B5_8448              ; $8443
  inc SceneState               ; $8445
Loc_B5_8448:
  rts                          ; $8448
Bank5Tbl8065_37:
  inc SceneState               ; $8449
  jmp Loc_B5_9434              ; $844C
Bank5Tbl8065_38:
  inc SceneState               ; $844F
  jsr EnableRendering          ; $8452
  lda #$15                     ; $8455
  jmp QueueSound               ; $8457
Bank5Tbl8065_39:
  jsr Sub_B5_98FB              ; $845A
  jsr MoveSceneSpriteRandomly  ; $845D
  lda SceneTimer               ; $8460
  beq Loc_B5_8473              ; $8463
  inc SceneState               ; $8465
  lda #$00                     ; $8468
  tax                          ; $846A
  jsr DrawSpriteListToOam      ; $846B
  lda #$01                     ; $846E
  jsr DrawSpriteListToOam      ; $8470
Loc_B5_8473:
  rts                          ; $8473
Bank5Tbl8065_3A:
  lda JoyNew1                  ; $8474
  and #$01                     ; $8477
  beq Loc_B5_8483              ; $8479
  inc SceneState               ; $847B
  lda #$0F                     ; $847E
  jmp QueueSound               ; $8480
Loc_B5_8483:
  rts                          ; $8483
Bank5Tbl8065_3B:
  jsr Sub_B5_97F4              ; $8484
  lda $0505                    ; $8487
  bne Loc_B5_849C              ; $848A
  inc SceneState               ; $848C
  lda #$5A                     ; $848F
  sta SceneTimer               ; $8491
  jsr FillPaletteBufferBlack   ; $8494
  lda #$00                     ; $8497
  jmp QueueSound               ; $8499
Loc_B5_849C:
  rts                          ; $849C
Bank5Scene_3C:
  dec SceneTimer               ; $849D
  bne Loc_B5_84BC              ; $84A0
  ldy #$00                     ; $84A2
  sty z:MmcPrgShadow           ; $84A4
  sty z:PaletteDirty           ; $84A6
  sty z:GameState              ; $84A8
  iny                          ; $84AA
  sty z:TransitionPending      ; $84AB
  sty $0507                    ; $84AD
  ldy #$03                     ; $84B0
  sty z:TransitionTarget       ; $84B2
  ldy #$70                     ; $84B4
  sty z:$2A                    ; $84B6
  ldy #$AA                     ; $84B8
  sty z:$2B                    ; $84BA
Loc_B5_84BC:
  rts                          ; $84BC
Bank5Tbl8065_46:
  jsr Bank5Tbl8065_37          ; $84BD
  jsr HideAllSpritesB5         ; $84C0
  lda #$05                     ; $84C3
  ldx #$00                     ; $84C5
  jmp DrawSpriteListToOam      ; $84C7
Bank5Tbl8065_47:
  inc SceneState               ; $84CA
  jsr EnableRendering          ; $84CD
Loc_B5_84D0:
  lda #$72                     ; $84D0
  sta $0528                    ; $84D2
  lda #$04                     ; $84D5
  sta $0529                    ; $84D7
  lda #$1E                     ; $84DA
  jmp QueueSound               ; $84DC
Bank5Tbl8065_48:
  lda JoyNew1                  ; $84DF
  and #$02                     ; $84E2
  beq Loc_B5_84F5              ; $84E4
  inc SceneState               ; $84E6
  lda #$06                     ; $84E9
  ldx #$00                     ; $84EB
  jsr DrawSpriteListToOam      ; $84ED
  lda #$1D                     ; $84F0
  jmp QueueSound               ; $84F2
Loc_B5_84F5:
  lda $0528                    ; $84F5
  ora $0529                    ; $84F8
  beq Loc_B5_84D0              ; $84FB
  rts                          ; $84FD
Bank5Tbl8065_49:
  jsr AnimateIntroTile         ; $84FE
  lda JoyNew1                  ; $8501
  and #$01                     ; $8504
  beq Loc_B5_84F5              ; $8506
  inc SceneState               ; $8508
  lda #$0F                     ; $850B
  jmp QueueSound               ; $850D
Bank5Tbl8065_4A:
  jsr DrawOfficeScene          ; $8510
  lda $052E                    ; $8513
  bne Loc_B5_84F5              ; $8516
  inc SceneState               ; $8518
  lda #$3C                     ; $851B
  sta SceneTimer               ; $851D
  jsr HideAllSpritesB5         ; $8520
  lda #$07                     ; $8523
  jmp DrawSpriteListToOam      ; $8525
Bank5Tbl8065_4B:
  dec SceneTimer               ; $8528
  bne Loc_B5_84F5              ; $852B
  inc SceneState               ; $852D
  lda #$F0                     ; $8530
  sta SceneTimer               ; $8532
  jsr FillPaletteBufferBlack   ; $8535
  jmp HideAllSpritesB5         ; $8538
Bank5Scene_4C:
  dec SceneTimer               ; $853B
  bne Loc_B5_84F5              ; $853E
  inc SceneState               ; $8540
  lda #$02                     ; $8543
  sta SceneTimer               ; $8545
  lda #$33                     ; $8548
  sta z:PpuCtrlShadow          ; $854A
  lda #$20                     ; $854C
  sta $014F                    ; $854E
  rts                          ; $8551
Bank5Tbl8065_4D:
  lda $0528                    ; $8552
  ora $0529                    ; $8555
  bne Loc_B5_8565              ; $8558
  dec SceneTimer               ; $855A
  beq Loc_B5_8562              ; $855D
  jmp Loc_B5_84D0              ; $855F
Loc_B5_8562:
  inc SceneState               ; $8562
Loc_B5_8565:
  rts                          ; $8565
Bank5Tbl8065_2D:
  inc SceneState               ; $8566
  jmp Loc_B5_970C              ; $8569
Bank5Scene_2E:
  dec SceneTimer               ; $856C
  bne Loc_B5_8579              ; $856F
  inc SceneState               ; $8571
  lda #$15                     ; $8574
  jmp QueueSound               ; $8576
Loc_B5_8579:
  rts                          ; $8579
Bank5Tbl8065_2F:
  lda #$1A                     ; $857A
  sta z:MmcChr0Shadow          ; $857C
  jsr MmcWriteChr0             ; $857E
  lda #$1E                     ; $8581
  jsr SetPpuMask               ; $8583
  jsr Sub_B5_9608              ; $8586
Loc_B5_8589:
  bit PPU_STATUS               ; $8589
  bvs Loc_B5_8589              ; $858C
Loc_B5_858E:
  bit PPU_STATUS               ; $858E
  bvc Loc_B5_858E              ; $8591
  ldx #$04                     ; $8593
  ldy #$01                     ; $8595
Loc_B5_8597:
  dey                          ; $8597
  bne Loc_B5_8597              ; $8598
  dex                          ; $859A
  bne Loc_B5_8597              ; $859B
  lda #$0F                     ; $859D
  sta z:MmcChr0Shadow          ; $859F
  jsr MmcWriteChr0             ; $85A1
  lda JoyNew1                  ; $85A4
  and #$08                     ; $85A7
  beq Loc_B5_85B1              ; $85A9
  inc SceneState               ; $85AB
  jmp Sub_B5_8150              ; $85AE
Loc_B5_85B1:
  rts                          ; $85B1
Bank5Tbl8065_4E:
  inc SceneState               ; $85B2
  jmp Loc_B5_9CCF              ; $85B5
Bank5Tbl8065_4F:
  dec SceneTimer               ; $85B8
  bne Loc_B5_85C8              ; $85BB
  inc SceneState               ; $85BD
  jsr EnableRendering          ; $85C0
  lda #$78                     ; $85C3
  sta SceneTimer               ; $85C5
Loc_B5_85C8:
  rts                          ; $85C8
Bank5Scene_50:
  dec SceneTimer               ; $85C9
  bne Loc_B5_85D6              ; $85CC
  inc SceneState               ; $85CE
  lda #$78                     ; $85D1
  sta SceneTimer               ; $85D3
Loc_B5_85D6:
  rts                          ; $85D6
Bank5Tbl8065_51:
  dec SceneTimer               ; $85D7
  bne Loc_B5_85ED              ; $85DA
  inc SceneState               ; $85DC
  lda #$1C                     ; $85DF
  ldx #$10                     ; $85E1
  ldy #$0D                     ; $85E3
  jsr SetMmcControlChr0Chr1    ; $85E5
  lda #$00                     ; $85E8
  sta $0512                    ; $85EA
Loc_B5_85ED:
  jmp Sub_B5_8150              ; $85ED
Bank5Tbl8065_52:
  inc SceneState               ; $85F0
  jmp Loc_B5_99B5              ; $85F3
Bank5Tbl8065_53:
  lda $0512                    ; $85F6
  beq Loc_B5_8603              ; $85F9
  dec SceneTimer               ; $85FB
  bne Loc_B5_8606              ; $85FE
  jsr EnableRendering          ; $8600
Loc_B5_8603:
  inc SceneState               ; $8603
Loc_B5_8606:
  rts                          ; $8606
Bank5Scene_54:
  lda $0512                    ; $8607
  beq Loc_B5_8618              ; $860A
  dec SceneTimer               ; $860C
  bne Loc_B5_8617              ; $860F
  dec SceneState               ; $8611
  dec SceneState               ; $8614
Loc_B5_8617:
  rts                          ; $8617
Loc_B5_8618:
  inc SceneState               ; $8618
  rts                          ; $861B
Bank5Tbl8065_55:
  inc SceneState               ; $861C
  jmp Loc_B5_9D0D              ; $861F
Bank5Tbl8065_56:
  dec SceneTimer               ; $8622
  bne Loc_B5_8637              ; $8625
  lda $0507                    ; $8627
  beq Loc_B5_8634              ; $862A
  jsr EnableRendering          ; $862C
  lda #$78                     ; $862F
  sta SceneTimer               ; $8631
Loc_B5_8634:
  inc SceneState               ; $8634
Loc_B5_8637:
  rts                          ; $8637
Bank5Scene_57:
  lda $0507                    ; $8638
  beq Loc_B5_8642              ; $863B
  dec SceneTimer               ; $863D
  bne Loc_B5_8645              ; $8640
Loc_B5_8642:
  inc SceneState               ; $8642
Loc_B5_8645:
  rts                          ; $8645
Bank5Tbl8065_58:
  inc SceneState               ; $8646
  jmp Loc_B5_901E              ; $8649
Bank5Scene_59:
  lda $0507                    ; $864C
  beq Loc_B5_8661              ; $864F
  lda #$01                     ; $8651
  sta $0545                    ; $8653
  lda #$3C                     ; $8656
  sta $0547                    ; $8658
  jsr CopyRamStub0513          ; $865B
  jsr EnableRendering          ; $865E
Loc_B5_8661:
  inc SceneState               ; $8661
  rts                          ; $8664
Bank5Scene_5A:
  lda $0507                    ; $8665
  beq Loc_B5_8672              ; $8668
  jsr $0513                    ; $866A
  lda $0547                    ; $866D
  bne Loc_B5_8675              ; $8670
Loc_B5_8672:
  inc SceneState               ; $8672
Loc_B5_8675:
  rts                          ; $8675
Bank5Tbl8065_5B:
  inc SceneState               ; $8676
  jmp Loc_B5_9C91              ; $8679
Bank5Tbl8065_5C:
  inc SceneState               ; $867C
  lda #$01                     ; $867F
  sta SceneSubState            ; $8681
  jmp EnableRendering          ; $8684
Bank5Tbl8065_5D:
  jsr Sub_B5_8A50              ; $8687
  lda AnimCounter              ; $868A
  bne Loc_B5_8692              ; $868D
  inc SceneState               ; $868F
Loc_B5_8692:
  rts                          ; $8692
  .incbin "prg_bank_5.bin", $0693, $1  ; $8693
Sub_B5_8694:
  inc SceneState               ; $8694
  lda #$06                     ; $8697
  sta $012A                    ; $8699
  jmp Loc_B5_9DB4              ; $869C
Sub_B5_869F:
  dec SceneTimer               ; $869F
  bne Loc_B5_86AA              ; $86A2
  inc SceneState               ; $86A4
  jmp EnableRendering          ; $86A7
Loc_B5_86AA:
  rts                          ; $86AA
Sub_B5_86AB:
  lda $0528                    ; $86AB
  ora $0529                    ; $86AE
  bne Loc_B5_86B6              ; $86B1
  inc SceneState               ; $86B3
Loc_B5_86B6:
  rts                          ; $86B6
Sub_B5_86B7:
  inc SceneState               ; $86B7
  lda #$07                     ; $86BA
  sta $012A                    ; $86BC
  jmp Loc_B5_9E0C              ; $86BF
Sub_B5_86C2:
  dec SceneTimer               ; $86C2
  bne Loc_B5_86CD              ; $86C5
  inc SceneState               ; $86C7
  jmp EnableRendering          ; $86CA
Loc_B5_86CD:
  rts                          ; $86CD
Sub_B5_86CE:
  lda $0528                    ; $86CE
  ora $0529                    ; $86D1
  bne Loc_B5_86D9              ; $86D4
  inc SceneState               ; $86D6
Loc_B5_86D9:
  rts                          ; $86D9
Sub_B5_86DA:
  inc SceneState               ; $86DA
  jsr GetRandomByte            ; $86DD
  and #$07                     ; $86E0
  sta $012A                    ; $86E2
  jmp Loc_B5_9D40              ; $86E5
Sub_B5_86E8:
  dec SceneTimer               ; $86E8
  bne Loc_B5_86F3              ; $86EB
  inc SceneState               ; $86ED
  jmp EnableRendering          ; $86F0
Loc_B5_86F3:
  rts                          ; $86F3
Sub_B5_86F4:
  lda $0528                    ; $86F4
  ora $0529                    ; $86F7
  bne Loc_B5_8701              ; $86FA
SetSceneState25:
  lda #$25                     ; $86FC
  sta SceneState               ; $86FE
Loc_B5_8701:
  rts                          ; $8701
  dec SceneTimer               ; $8702  [heuristic code]
  beq Loc_B5_8708              ; $8705
  rts                          ; $8707
Loc_B5_8708:
  jmp ($FFFC)                  ; $8708
Data_B5_870B:
  .incbin "prg_bank_5.bin", $070B, $1A  ; $870B
Loc_B5_8725:
  jsr HideAllSpritesB5         ; $8725
  lda $053A                    ; $8728
  sec                          ; $872B
  sbc $053B                    ; $872C
  sta $053A                    ; $872F
  bcs Loc_B5_8737              ; $8732
  dec $0539                    ; $8734
Loc_B5_8737:
  lda $053D                    ; $8737
  sec                          ; $873A
  sbc $053E                    ; $873B
  sta $053D                    ; $873E
  bcs Loc_B5_8746              ; $8741
  dec $053C                    ; $8743
Loc_B5_8746:
  ldx $053C                    ; $8746
  beq Loc_B5_874F              ; $8749
  inx                          ; $874B
  beq Loc_B5_8758              ; $874C
  rts                          ; $874E
Loc_B5_874F:
  ldy $0539                    ; $874F
  beq Loc_B5_8761              ; $8752
  iny                          ; $8754
  beq Loc_B5_8778              ; $8755
  rts                          ; $8757
Loc_B5_8758:
  ldy $0539                    ; $8758
  beq Loc_B5_878F              ; $875B
  iny                          ; $875D
  beq Loc_B5_87A2              ; $875E
  rts                          ; $8760
Loc_B5_8761:
  jsr Sub_B5_87B5              ; $8761
  bcs Loc_B5_8772              ; $8764
  jsr Sub_B5_87BD              ; $8766
  bcs Loc_B5_8772              ; $8769
  cmp #$F0                     ; $876B
  bcs Loc_B5_8772              ; $876D
  jsr Sub_B5_87C8              ; $876F
Loc_B5_8772:
  jsr Sub_B5_87DB              ; $8772
  bcc Loc_B5_8761              ; $8775
  rts                          ; $8777
Loc_B5_8778:
  jsr Sub_B5_87B5              ; $8778
  bcc Loc_B5_8789              ; $877B
  jsr Sub_B5_87BD              ; $877D
  bcs Loc_B5_8789              ; $8780
  cmp #$F0                     ; $8782
  bcs Loc_B5_8789              ; $8784
  jsr Sub_B5_87C8              ; $8786
Loc_B5_8789:
  jsr Sub_B5_87DB              ; $8789
  bcc Loc_B5_8778              ; $878C
  rts                          ; $878E
Loc_B5_878F:
  jsr Sub_B5_87B5              ; $878F
  bcs Loc_B5_879C              ; $8792
  jsr Sub_B5_87BD              ; $8794
  bcc Loc_B5_879C              ; $8797
  jsr Sub_B5_87C8              ; $8799
Loc_B5_879C:
  jsr Sub_B5_87DB              ; $879C
  bcc Loc_B5_878F              ; $879F
  rts                          ; $87A1
Loc_B5_87A2:
  jsr Sub_B5_87B5              ; $87A2
  bcc Loc_B5_87AF              ; $87A5
  jsr Sub_B5_87BD              ; $87A7
  bcc Loc_B5_87AF              ; $87AA
  jsr Sub_B5_87C8              ; $87AC
Loc_B5_87AF:
  jsr Sub_B5_87DB              ; $87AF
  bcc Loc_B5_87A2              ; $87B2
  rts                          ; $87B4
Sub_B5_87B5:
  lda Data_B5_87E3,x           ; $87B5
  clc                          ; $87B8
  adc $053A                    ; $87B9
  rts                          ; $87BC
Sub_B5_87BD:
  sta $0203,y                  ; $87BD
  lda Data_B5_87E1,x           ; $87C0
  clc                          ; $87C3
  adc $053D                    ; $87C4
  rts                          ; $87C7
Sub_B5_87C8:
  sta OamBuffer,y              ; $87C8
  lda Data_B5_87E2,x           ; $87CB
  sta $0201,y                  ; $87CE
  lda #$00                     ; $87D1
  sta $0202,y                  ; $87D3
  iny                          ; $87D6
  iny                          ; $87D7
  iny                          ; $87D8
  iny                          ; $87D9
  rts                          ; $87DA
Sub_B5_87DB:
  inx                          ; $87DB
  inx                          ; $87DC
  inx                          ; $87DD
  cpx #$72                     ; $87DE
  rts                          ; $87E0
Data_B5_87E1:
  .incbin "prg_bank_5.bin", $07E1, $1  ; $87E1
Data_B5_87E2:
  .incbin "prg_bank_5.bin", $07E2, $1  ; $87E2
Data_B5_87E3:
  .incbin "prg_bank_5.bin", $07E3, $70  ; $87E3
Sub_B5_8853:
  jsr HideAllSpritesB5         ; $8853
  ldx $052B                    ; $8856
  inx                          ; $8859
  cpx #$59                     ; $885A
  bcc Loc_B5_8860              ; $885C
  ldx #$00                     ; $885E
Loc_B5_8860:
  stx $052B                    ; $8860
  cpx #$14                     ; $8863
  bcc Loc_B5_886B              ; $8865
  cpx #$39                     ; $8867
  bcc Loc_B5_886C              ; $8869
Loc_B5_886B:
  rts                          ; $886B
Loc_B5_886C:
  txa                          ; $886C
  sec                          ; $886D
  sbc #$14                     ; $886E
  tax                          ; $8870
  lda Data_B5_88EE,x           ; $8871
  tax                          ; $8874
  ldy Data_B5_8913,x           ; $8875
  sty z:Tmp02                  ; $8878
  asl a                        ; $887A
  tax                          ; $887B
  lda Data_B5_88B8,x           ; $887C
  sta z:Tmp00                  ; $887F
  lda Data_B5_88B9,x           ; $8881
  sta z:Tmp01                  ; $8884
  ldx #$00                     ; $8886
  ldy #$00                     ; $8888
Loc_B5_888A:
  lda (Tmp00),y                ; $888A
  beq Loc_B5_88B7              ; $888C
  and #$F0                     ; $888E
  lsr a                        ; $8890
  adc #$5F                     ; $8891
  sta OamBuffer,x              ; $8893
  lda (Tmp00),y                ; $8896
  and #$0F                     ; $8898
  asl a                        ; $889A
  asl a                        ; $889B
  asl a                        ; $889C
  adc #$30                     ; $889D
  sta $0203,x                  ; $889F
  lda z:Tmp02                  ; $88A2
  inc z:Tmp02                  ; $88A4
  inc z:Tmp02                  ; $88A6
  sta $0201,x                  ; $88A8
  lda #$00                     ; $88AB
  sta $0202,x                  ; $88AD
  iny                          ; $88B0
  inx                          ; $88B1
  inx                          ; $88B2
  inx                          ; $88B3
  inx                          ; $88B4
  bne Loc_B5_888A              ; $88B5
Loc_B5_88B7:
  rts                          ; $88B7
Data_B5_88B8:
  cpy z:$88                    ; $88B8  [heuristic code]
  dex                          ; $88BA
  dey                          ; $88BB
  .incbin "prg_bank_5.bin", $08BC, $32  ; $88BC
Data_B5_88EE:
  .incbin "prg_bank_5.bin", $08EE, $25  ; $88EE
Data_B5_8913:
  .incbin "prg_bank_5.bin", $0913, $6  ; $8913
FillNametableWithA:
  ldy PPU_STATUS               ; $8919
  stx PPU_ADDR                 ; $891C
  ldx #$00                     ; $891F
  stx PPU_ADDR                 ; $8921
  ldy #$04                     ; $8924
Loc_B5_8926:
  sta PPU_DATA                 ; $8926
  dex                          ; $8929
  bne Loc_B5_8926              ; $892A
  dey                          ; $892C
  bne Loc_B5_8926              ; $892D
  rts                          ; $892F
FillPaletteBufferBlack:
  lda #$0F                     ; $8930
FillPaletteBufferWithA:
  ldx #$1F                     ; $8932
Sub_B5_8934:
  sta PaletteBuffer,x          ; $8934
  dex                          ; $8937
  bpl Sub_B5_8934              ; $8938
  rts                          ; $893A
ClearSceneStateTailB5:
  lda #$00                     ; $893B
  ldx #$10                     ; $893D
Loc_B5_893F:
  sta SceneState,x             ; $893F
  inx                          ; $8942
  bne Loc_B5_893F              ; $8943
  rts                          ; $8945
HideAllSpritesB5:
  ldx #$00                     ; $8946
HideSpritesFromX:
  lda #$F0                     ; $8948
Loc_B5_894A:
  sta OamBuffer,x              ; $894A
  inx                          ; $894D
  bne Loc_B5_894A              ; $894E
  rts                          ; $8950
Sub_B5_8951:
  jsr Sub_B5_8150              ; $8951
  lda #$1E                     ; $8954
  ldx #$0F                     ; $8956
  ldy #$0E                     ; $8958
  jsr SetMmcControlChr0Chr1    ; $895A
  lda #$FF                     ; $895D
  ldx #$20                     ; $895F
  jsr FillNametableWithA       ; $8961
  ldx #$2C                     ; $8964
  jsr FillNametableWithA       ; $8966
  jsr ProcessPpuUpdateList     ; $8969
  .addr Data_B5_89AB  ; $896C inline pointer (data after a JSR)
  ldx #$03                     ; $896E
Loc_B5_8970:
  lda Data_B5_89A4,x           ; $8970
  sta PaletteBuffer,x          ; $8973
  lda Data_B5_89A7,x           ; $8976
  sta $0150,x                  ; $8979
  dex                          ; $897C
  bne Loc_B5_8970              ; $897D
  lda #$01                     ; $897F
  sta $0539                    ; $8981
  lda #$80                     ; $8984
  sta $053A                    ; $8986
  lda #$03                     ; $8989
  sta $053B                    ; $898B
  lda #$00                     ; $898E
  sta $053C                    ; $8990
  lda #$80                     ; $8993
  sta $053D                    ; $8995
  lda #$01                     ; $8998
  sta $053E                    ; $899A
  lda #$1E                     ; $899D
  sta SceneTimer               ; $899F
  jmp InitScenePpuState        ; $89A2
  rol z:$08                    ; $89A5  [heuristic code]
Data_B5_89A7:
  ora (FrameCounter,x)         ; $89A7
  ora ($0F,x)                  ; $89A9
Data_B5_89AB:
  and $04A6                    ; $89AB
  pha                          ; $89AE
  eor #$4A                     ; $89AF
  .incbin "prg_bank_5.bin", $09B1, $69  ; $89B1
Loc_B5_8A1A:
  lda #$1C                     ; $8A1A
  ldx #$0C                     ; $8A1C
  ldy #$08                     ; $8A1E
  jsr SetMmcControlChr0Chr1    ; $8A20
  jsr CopyRamStub051E          ; $8A23
  lda #$00                     ; $8A26
  ldx #$20                     ; $8A28
  jsr FillNametableWithA       ; $8A2A
  jsr ProcessPpuUpdateList     ; $8A2D
  .addr Data_B5_8A4B  ; $8A30 inline pointer (data after a JSR)
  ldx #$07                     ; $8A32
Loc_B5_8A34:
  lda Data_B5_8A43,x           ; $8A34
  sta $0150,x                  ; $8A37
  dex                          ; $8A3A
  bpl Loc_B5_8A34              ; $8A3B
  lda #$3C                     ; $8A3D
  sta SceneTimer               ; $8A3F
  rts                          ; $8A42
Data_B5_8A43:
  .incbin "prg_bank_5.bin", $0A43, $8  ; $8A43
Data_B5_8A4B:
  .incbin "prg_bank_5.bin", $0A4B, $5  ; $8A4B
Sub_B5_8A50:
  lda SceneSubState            ; $8A50
  cmp #$09                     ; $8A53
Loc_B5_8A55:
  bcs Loc_B5_8A55              ; $8A55
  asl a                        ; $8A57
  tax                          ; $8A58
  lda Data_B5_8A66,x           ; $8A59
  sta z:Tmp00                  ; $8A5C
  lda Data_B5_8A67,x           ; $8A5E
  sta z:Tmp01                  ; $8A61
  jmp ($0000)                  ; $8A63
Data_B5_8A66:
  .addr Bank5Tbl8A66_00, Bank5Tbl8A66_01, Bank5Tbl8A66_02, Bank5Tbl8A66_03, Bank5Tbl8A66_04, Bank5Tbl8A66_05, Bank5Tbl8A66_06, Bank5Tbl8A66_07, Bank5Tbl8A66_08  ; $8A66 pointer table
Bank5Tbl8A66_00:
  ldy #$00                     ; $8A78
  sty AnimCounter              ; $8A7A
  sty SceneSubState            ; $8A7D
  rts                          ; $8A80
Bank5Tbl8A66_01:
  jsr Bank5NextAnimFrame       ; $8A81
  cmp #$05                     ; $8A84
  bcc Loc_B5_8A8B              ; $8A86
  jmp Bank5Tbl8A66_00          ; $8A88
Loc_B5_8A8B:
  tax                          ; $8A8B
  lda Data_B5_8A93,x           ; $8A8C
  sta $014F                    ; $8A8F
  rts                          ; $8A92
Data_B5_8A93:
  .incbin "prg_bank_5.bin", $0A93, $5  ; $8A93
Bank5Tbl8A66_02:
  jsr Bank5NextAnimFrame       ; $8A98
  cmp #$04                     ; $8A9B
  bcc Sub_B5_8AA2              ; $8A9D
  jmp Bank5Tbl8A66_00          ; $8A9F
Sub_B5_8AA2:
  tax                          ; $8AA2
  lda Data_B5_8AAA,x           ; $8AA3
  sta $014F                    ; $8AA6
  rts                          ; $8AA9
Data_B5_8AAA:
  .incbin "prg_bank_5.bin", $0AAA, $4  ; $8AAA
Bank5Tbl8A66_03:
  jsr Bank5NextAnimFrame       ; $8AAE
  cmp #$04                     ; $8AB1
  bcc Loc_B5_8ABB              ; $8AB3
  jsr FillPaletteBufferBlack   ; $8AB5
  jmp Bank5Tbl8A66_00          ; $8AB8
Loc_B5_8ABB:
  jsr Sub_B5_8AA2              ; $8ABB
  lda Data_B5_8ACE,x           ; $8ABE
  sta $0152                    ; $8AC1
  lda Data_B5_8AD2,x           ; $8AC4
  sta $0150                    ; $8AC7
  sta $0153                    ; $8ACA
  rts                          ; $8ACD
Data_B5_8ACE:
  .incbin "prg_bank_5.bin", $0ACE, $4  ; $8ACE
Data_B5_8AD2:
  .incbin "prg_bank_5.bin", $0AD2, $4  ; $8AD2
Bank5Tbl8A66_04:
  jsr Bank5NextAnimFrame       ; $8AD6
  cmp #$03                     ; $8AD9
  bcc Loc_B5_8AE3              ; $8ADB
  jsr Bank5Tbl8A66_00          ; $8ADD
  jmp FillPaletteBufferBlack   ; $8AE0
Loc_B5_8AE3:
  sta z:Tmp00                  ; $8AE3
  asl a                        ; $8AE5
  adc z:Tmp00                  ; $8AE6
  tax                          ; $8AE8
  ldy #$01                     ; $8AE9
Loc_B5_8AEB:
  lda Data_B5_8AF8,x           ; $8AEB
  sta PaletteBuffer,y          ; $8AEE
  inx                          ; $8AF1
  iny                          ; $8AF2
  cpy #$04                     ; $8AF3
  bcc Loc_B5_8AEB              ; $8AF5
  rts                          ; $8AF7
Data_B5_8AF8:
  .incbin "prg_bank_5.bin", $0AF8, $9  ; $8AF8
Bank5Tbl8A66_05:
  jsr Bank5NextAnimFrame       ; $8B01
  cmp #$04                     ; $8B04
  bcc Loc_B5_8B0B              ; $8B06
  jmp Bank5Tbl8A66_00          ; $8B08
Loc_B5_8B0B:
  sta z:Tmp00                  ; $8B0B
  asl a                        ; $8B0D
  adc z:Tmp00                  ; $8B0E
  tax                          ; $8B10
  ldy #$01                     ; $8B11
Loc_B5_8B13:
  lda Data_B5_8B26,x           ; $8B13
  sta PaletteBuffer,y          ; $8B16
  lda Data_B5_8B32,x           ; $8B19
  sta $014C,y                  ; $8B1C
  inx                          ; $8B1F
  iny                          ; $8B20
  cpy #$04                     ; $8B21
  bcc Loc_B5_8B13              ; $8B23
  rts                          ; $8B25
Data_B5_8B26:
  .incbin "prg_bank_5.bin", $0B26, $C  ; $8B26
Data_B5_8B32:
  .incbin "prg_bank_5.bin", $0B32, $C  ; $8B32
Bank5Tbl8A66_06:
  jsr Bank5NextAnimFrame       ; $8B3E
  cmp #$03                     ; $8B41
  bcc Loc_B5_8B48              ; $8B43
  jmp Bank5Tbl8A66_00          ; $8B45
Loc_B5_8B48:
  tax                          ; $8B48
  lda Data_B5_8B5C,x           ; $8B49
  tax                          ; $8B4C
  ldy #$0D                     ; $8B4D
Loc_B5_8B4F:
  lda Data_B5_8B32,x           ; $8B4F
  sta PaletteBuffer,y          ; $8B52
  inx                          ; $8B55
  iny                          ; $8B56
  cpy #$10                     ; $8B57
  bcc Loc_B5_8B4F              ; $8B59
  rts                          ; $8B5B
Data_B5_8B5C:
  .incbin "prg_bank_5.bin", $0B5C, $3  ; $8B5C
Bank5Tbl8A66_07:
  jsr Bank5NextAnimFrame       ; $8B5F
  cmp #$03                     ; $8B62
  bcc Loc_B5_8B69              ; $8B64
  jmp Bank5Tbl8A66_00          ; $8B66
Loc_B5_8B69:
  sta z:Tmp00                  ; $8B69
  asl a                        ; $8B6B
  adc z:Tmp00                  ; $8B6C
  tax                          ; $8B6E
Loc_B5_8B6F:
  ldy #$01                     ; $8B6F
Loc_B5_8B71:
  lda Data_B5_8B8A,x           ; $8B71
  sta PaletteBuffer,y          ; $8B74
  lda Data_B5_8B93,x           ; $8B77
  sta $014C,y                  ; $8B7A
  lda Data_B5_8B9C,x           ; $8B7D
  sta $0150,y                  ; $8B80
  inx                          ; $8B83
  iny                          ; $8B84
  cpy #$04                     ; $8B85
  bcc Loc_B5_8B71              ; $8B87
  rts                          ; $8B89
Data_B5_8B8A:
  .incbin "prg_bank_5.bin", $0B8A, $9  ; $8B8A
Data_B5_8B93:
  .incbin "prg_bank_5.bin", $0B93, $9  ; $8B93
Data_B5_8B9C:
  .incbin "prg_bank_5.bin", $0B9C, $9  ; $8B9C
Bank5Tbl8A66_08:
  jsr Bank5NextAnimFrame       ; $8BA5
  cmp #$02                     ; $8BA8
  bcc Loc_B5_8BB2              ; $8BAA
  jsr Bank5Tbl8A66_00          ; $8BAC
  jmp FillPaletteBufferBlack   ; $8BAF
Loc_B5_8BB2:
  tax                          ; $8BB2
  lda Data_B5_8BBA,x           ; $8BB3
  tax                          ; $8BB6
  jmp Loc_B5_8B6F              ; $8BB7
Data_B5_8BBA:
  .incbin "prg_bank_5.bin", $0BBA, $2  ; $8BBA
Bank5NextAnimFrame:
  inc AnimCounter              ; $8BBC
  lda AnimCounter              ; $8BBF
  lsr a                        ; $8BC2
  lsr a                        ; $8BC3
  rts                          ; $8BC4
AnimateOfficeSpeaker:
  ldx #$38                     ; $8BC5
  jsr HideSpritesFromX         ; $8BC7
  lda $052E                    ; $8BCA
  bne Loc_B5_8BD4              ; $8BCD
  lda #$11                     ; $8BCF
  jsr QueueSound               ; $8BD1
Loc_B5_8BD4:
  lda $052E                    ; $8BD4
  cmp #$0F                     ; $8BD7
  bcc Loc_B5_8BE1              ; $8BD9
  ldx #$00                     ; $8BDB
  stx $052E                    ; $8BDD
  rts                          ; $8BE0
Loc_B5_8BE1:
  asl a                        ; $8BE1
  tay                          ; $8BE2
  lda Data_B5_8C3B,y           ; $8BE3
  sta z:Tmp00                  ; $8BE6
  lda Data_B5_8C3C,y           ; $8BE8
  sta z:Tmp01                  ; $8BEB
  ldy #$00                     ; $8BED
Loc_B5_8BEF:
  lda (Tmp00),y                ; $8BEF
  beq Loc_B5_8C23              ; $8BF1
  and #$F0                     ; $8BF3
  lsr a                        ; $8BF5
  adc $0532                    ; $8BF6
  sta $0250,x                  ; $8BF9
  lda (Tmp00),y                ; $8BFC
  and #$0F                     ; $8BFE
  asl a                        ; $8C00
  asl a                        ; $8C01
  asl a                        ; $8C02
  adc $0531                    ; $8C03
  sta $0253,x                  ; $8C06
  iny                          ; $8C09
  lda (Tmp00),y                ; $8C0A
  and #$0F                     ; $8C0C
  ora #$A0                     ; $8C0E
  sta $0251,x                  ; $8C10
  lda (Tmp00),y                ; $8C13
  and #$F0                     ; $8C15
  ora #$23                     ; $8C17
  sta $0252,x                  ; $8C19
  iny                          ; $8C1C
  inx                          ; $8C1D
  inx                          ; $8C1E
  inx                          ; $8C1F
  inx                          ; $8C20
  bpl Loc_B5_8BEF              ; $8C21
Loc_B5_8C23:
  dec $052F                    ; $8C23
  bpl Loc_B5_8C30              ; $8C26
  lda #$07                     ; $8C28
  sta $052F                    ; $8C2A
  inc $052E                    ; $8C2D
Loc_B5_8C30:
  lda $052E                    ; $8C30
  cmp #$06                     ; $8C33
  bcc Loc_B5_8C38              ; $8C35
  rts                          ; $8C37
Loc_B5_8C38:
  jmp DrawOfficeSpeakerSprites ; $8C38
Data_B5_8C3B:
  .incbin "prg_bank_5.bin", $0C3B, $1  ; $8C3B
Data_B5_8C3C:
  .incbin "prg_bank_5.bin", $0C3C, $E7  ; $8C3C
DrawOfficeSpeakerSprites:
  lda #$F0                     ; $8D23
  ldx #$13                     ; $8D25
Loc_B5_8D27:
  sta PlayerSpriteY0,x         ; $8D27
  dex                          ; $8D2A
  bpl Loc_B5_8D27              ; $8D2B
  ldx #$3C                     ; $8D2D
Loc_B5_8D2F:
  lda Data_B5_8DB3,x           ; $8D2F
  clc                          ; $8D32
  adc $0531                    ; $8D33
  sta $02C3,x                  ; $8D36
  lda Data_B5_8DB2,x           ; $8D39
  sta $02C2,x                  ; $8D3C
  lda Data_B5_8DB1,x           ; $8D3F
  sta $02C1,x                  ; $8D42
  lda Data_B5_8DB0,x           ; $8D45
  clc                          ; $8D48
  adc $0532                    ; $8D49
  sta $02C0,x                  ; $8D4C
  dex                          ; $8D4F
  dex                          ; $8D50
  dex                          ; $8D51
  dex                          ; $8D52
  bpl Loc_B5_8D2F              ; $8D53
  lda $0533                    ; $8D55
  clc                          ; $8D58
  adc #$10                     ; $8D59
  sta $0533                    ; $8D5B
  ldx #$0C                     ; $8D5E
Loc_B5_8D60:
  lda $0533                    ; $8D60
  and #$20                     ; $8D63
  clc                          ; $8D65
  adc $02F3,x                  ; $8D66
  sta $02F3,x                  ; $8D69
  dex                          ; $8D6C
  dex                          ; $8D6D
  dex                          ; $8D6E
  dex                          ; $8D6F
  bpl Loc_B5_8D60              ; $8D70
  lda $0531                    ; $8D72
  cmp #$20                     ; $8D75
  bcc Loc_B5_8D90              ; $8D77
  cmp #$A0                     ; $8D79
  beq Loc_B5_8D9A              ; $8D7B
  bcs Loc_B5_8D9B              ; $8D7D
  lda z:HwScrollX              ; $8D7F
  cmp $0534                    ; $8D81
  beq Loc_B5_8D90              ; $8D84
  ldx $0535                    ; $8D86
  stx $0534                    ; $8D89
  sta $0535                    ; $8D8C
  rts                          ; $8D8F
Loc_B5_8D90:
  lda $0533                    ; $8D90
  and #$10                     ; $8D93
  beq Loc_B5_8D9A              ; $8D95
  inc $0531                    ; $8D97
Loc_B5_8D9A:
  rts                          ; $8D9A
Loc_B5_8D9B:
  ldx #$3C                     ; $8D9B
Loc_B5_8D9D:
  lda $02C3,x                  ; $8D9D
  bpl Loc_B5_8DA7              ; $8DA0
  lda #$F0                     ; $8DA2
  sta $02C0,x                  ; $8DA4
Loc_B5_8DA7:
  dex                          ; $8DA7
  dex                          ; $8DA8
  dex                          ; $8DA9
  dex                          ; $8DAA
  bpl Loc_B5_8D9D              ; $8DAB
  jmp Loc_B5_8D90              ; $8DAD
Data_B5_8DB0:
  .incbin "prg_bank_5.bin", $0DB0, $1  ; $8DB0
Data_B5_8DB1:
  .incbin "prg_bank_5.bin", $0DB1, $1  ; $8DB1
Data_B5_8DB2:
  .incbin "prg_bank_5.bin", $0DB2, $1  ; $8DB2
Data_B5_8DB3:
  .incbin "prg_bank_5.bin", $0DB3, $3D  ; $8DB3
Data_B5_8DF0:
  .incbin "prg_bank_5.bin", $0DF0, $4B  ; $8DF0
CopyRamStub0513:
  ldx #$0A                     ; $8E3B
Loc_B5_8E3D:
  lda Data_B5_8E47,x           ; $8E3D
  sta $0513,x                  ; $8E40
  dex                          ; $8E43
  bpl Loc_B5_8E3D              ; $8E44
  rts                          ; $8E46
Data_B5_8E47:
  .incbin "prg_bank_5.bin", $0E47, $B  ; $8E47
CopyRamStub05B8:
  ldx #$19                     ; $8E52
Loc_B5_8E54:
  lda Data_B5_870B,x           ; $8E54
  sta $05B8,x                  ; $8E57
  dex                          ; $8E5A
  bpl Loc_B5_8E54              ; $8E5B
  rts                          ; $8E5D
Sub_B5_8E5E:
  inc $0538                    ; $8E5E
  lda $0538                    ; $8E61
  cmp #$78                     ; $8E64
  bcc Loc_B5_8E81              ; $8E66
  cmp #$84                     ; $8E68
  bcc Loc_B5_8E82              ; $8E6A
  cmp #$85                     ; $8E6C
  bcc Loc_B5_8EC3              ; $8E6E
  cmp #$86                     ; $8E70
  bcc Loc_B5_8ED3              ; $8E72
  cmp #$87                     ; $8E74
  bcc Loc_B5_8EE7              ; $8E76
  cmp #$FF                     ; $8E78
  bcc Loc_B5_8E81              ; $8E7A
  lda #$00                     ; $8E7C
  sta $0538                    ; $8E7E
Loc_B5_8E81:
  rts                          ; $8E81
Loc_B5_8E82:
  sec                          ; $8E82
  sbc #$78                     ; $8E83
  tay                          ; $8E85
  lda Data_B5_8EAB,y           ; $8E86
  tax                          ; $8E89
  lda Data_B5_8EB7,y           ; $8E8A
  tay                          ; $8E8D
  lda Data_B5_8EA7,x           ; $8E8E
  sta $0145                    ; $8E91
  lda Data_B5_8EA8,x           ; $8E94
  sta $0146                    ; $8E97
  lda Data_B5_8EA7,y           ; $8E9A
  sta $0149                    ; $8E9D
  lda Data_B5_8EA8,y           ; $8EA0
  sta $014A                    ; $8EA3
  rts                          ; $8EA6
Data_B5_8EA7:
  .incbin "prg_bank_5.bin", $0EA7, $1  ; $8EA7
Data_B5_8EA8:
  .incbin "prg_bank_5.bin", $0EA8, $3  ; $8EA8
Data_B5_8EAB:
  .incbin "prg_bank_5.bin", $0EAB, $C  ; $8EAB
Data_B5_8EB7:
  .incbin "prg_bank_5.bin", $0EB7, $C  ; $8EB7
Loc_B5_8EC3:
  ldx #$03                     ; $8EC3
Loc_B5_8EC5:
  lda Data_B5_8ECF,x           ; $8EC5
  sta OamBuffer,x              ; $8EC8
  dex                          ; $8ECB
  bpl Loc_B5_8EC5              ; $8ECC
  rts                          ; $8ECE
Data_B5_8ECF:
  .incbin "prg_bank_5.bin", $0ECF, $4  ; $8ECF
Loc_B5_8ED3:
  ldx #$07                     ; $8ED3
Loc_B5_8ED5:
  lda Data_B5_8EDF,x           ; $8ED5
  sta OamBuffer,x              ; $8ED8
  dex                          ; $8EDB
  bpl Loc_B5_8ED5              ; $8EDC
  rts                          ; $8EDE
Data_B5_8EDF:
  .incbin "prg_bank_5.bin", $0EDF, $8  ; $8EDF
Loc_B5_8EE7:
  jmp HideAllSpritesB5         ; $8EE7
Loc_B5_8EEA:
  jsr Sub_B5_8150              ; $8EEA
  lda #$1C                     ; $8EED
  ldx #$03                     ; $8EEF
  ldy #$03                     ; $8EF1
  jsr SetMmcControlChr0Chr1    ; $8EF3
  jsr FillPaletteBufferBlack   ; $8EF6
  lda #$FF                     ; $8EF9
  ldx #$20                     ; $8EFB
  jsr FillNametableWithA       ; $8EFD
  jsr CopyRamStub05B8          ; $8F00
  ldy #$00                     ; $8F03
  jsr $05B8                    ; $8F05
  jsr ProcessPpuUpdateList     ; $8F08
  .addr Data_B5_8F33  ; $8F0B inline pointer (data after a JSR)
  ldx #$10                     ; $8F0D
Loc_B5_8F0F:
  lda Data_B5_8F26,x           ; $8F0F
  sta $0145,x                  ; $8F12
  dex                          ; $8F15
  bpl Loc_B5_8F0F              ; $8F16
  lda #$20                     ; $8F18
  sta z:HwScrollX              ; $8F1A
  lda #$A8                     ; $8F1C
  sta z:HwScrollY              ; $8F1E
  lda #$1E                     ; $8F20
  sta SceneTimer               ; $8F22
  rts                          ; $8F25
Data_B5_8F26:
  asl z:AreaGroup,x            ; $8F26  [heuristic code]
  ora ($0F,x)                  ; $8F28
  asl z:AreaGroup,x            ; $8F2A
  ora ($0F,x)                  ; $8F2C
  asl z:$08,x                  ; $8F2E
  ora ($0F,x)                  ; $8F30
  jsr Sub_C623                 ; $8F32
  ora ($9F,x)                  ; $8F35
  .incbin "prg_bank_5.bin", $0F37, $5  ; $8F37
Loc_B5_8F3C:
  lda #$C0                     ; $8F3C
  ldx #$00                     ; $8F3E
  jsr Sub_B5_8F70              ; $8F40
  lda #$A0                     ; $8F43
  ldx #$01                     ; $8F45
  jsr Sub_B5_8F70              ; $8F47
  ldx $0536                    ; $8F4A
  jsr Sub_B5_8F67              ; $8F4D
  tay                          ; $8F50
  lda Data_B5_8F80,y           ; $8F51
  sta $0156                    ; $8F54
  ldx $0537                    ; $8F57
  jsr Sub_B5_8F67              ; $8F5A
  ora #$08                     ; $8F5D
  tay                          ; $8F5F
  lda Data_B5_8F80,y           ; $8F60
  sta $015B                    ; $8F63
  rts                          ; $8F66
Sub_B5_8F67:
  bpl Loc_B5_8F6C              ; $8F67
  lda #$00                     ; $8F69
  rts                          ; $8F6B
Loc_B5_8F6C:
  lda Data_B5_8F90,x           ; $8F6C
  rts                          ; $8F6F
Sub_B5_8F70:
  ldy $0536,x                  ; $8F70
  iny                          ; $8F73
  bmi Loc_B5_8F7B              ; $8F74
  cpy #$19                     ; $8F76
  bcc Loc_B5_8F7B              ; $8F78
  tay                          ; $8F7A
Loc_B5_8F7B:
  tya                          ; $8F7B
  sta $0536,x                  ; $8F7C
  rts                          ; $8F7F
Data_B5_8F80:
  .incbin "prg_bank_5.bin", $0F80, $10  ; $8F80
Data_B5_8F90:
  .incbin "prg_bank_5.bin", $0F90, $19  ; $8F90
CopyRamStub051E:
  ldx #$07                     ; $8FA9
Loc_B5_8FAB:
  lda Data_B5_8FB5,x           ; $8FAB
  sta $051E,x                  ; $8FAE
  dex                          ; $8FB1
  bpl Loc_B5_8FAB              ; $8FB2
  rts                          ; $8FB4
Data_B5_8FB5:
  .incbin "prg_bank_5.bin", $0FB5, $8  ; $8FB5
SetMmcControlChr0Chr1:
  sta z:MmcControlShadow       ; $8FBD
  stx z:MmcChr0Shadow          ; $8FBF
  sty z:MmcChr1Shadow          ; $8FC1
  jsr MmcWriteControl          ; $8FC3
  jsr MmcWriteChr0             ; $8FC6
  jmp MmcWriteChr1             ; $8FC9
Loc_B5_8FCC:
  jsr Sub_B5_8150              ; $8FCC
  lda #$1F                     ; $8FCF
  ldx #$1A                     ; $8FD1
  ldy #$08                     ; $8FD3
  jsr SetMmcControlChr0Chr1    ; $8FD5
  lda #$60                     ; $8FD8
  sta $0600                    ; $8FDA
  lda #$00                     ; $8FDD
  sta z:GameState              ; $8FDF
  lda #$03                     ; $8FE1
  sta $0106                    ; $8FE3
  lda #$01                     ; $8FE6
  sta z:TransitionPending      ; $8FE8
  lda #$2E                     ; $8FEA
  sta z:TransitionTarget       ; $8FEC
  lda #$00                     ; $8FEE
  sta z:$2A                    ; $8FF0
  lda #$64                     ; $8FF2
  sta z:$2B                    ; $8FF4
  lda #$B0                     ; $8FF6
  sta $0541                    ; $8FF8
  lda #$06                     ; $8FFB
  sta $0542                    ; $8FFD
  lda #$40                     ; $9000
  sta $0532                    ; $9002
  lda #$B0                     ; $9005
  sta $0531                    ; $9007
  lda #$C8                     ; $900A
  sta z:PlayerLifeLo           ; $900C
  ldx #$4A                     ; $900E
Loc_B5_9010:
  lda Data_B5_8DF0,x           ; $9010
  sta $0568,x                  ; $9013
  dex                          ; $9016
  bpl Loc_B5_9010              ; $9017
  lda #$15                     ; $9019
  jmp QueueSound               ; $901B
Loc_B5_901E:
  jsr Sub_B5_8150              ; $901E
  lda #$1F                     ; $9021
  ldx #$0F                     ; $9023
  ldy #$0D                     ; $9025
  jsr SetMmcControlChr0Chr1    ; $9027
  jsr FillPaletteBufferBlack   ; $902A
  lda #$FF                     ; $902D
  ldx #$20                     ; $902F
  jsr FillNametableWithA       ; $9031
  ldx #$2C                     ; $9034
  jsr FillNametableWithA       ; $9036
  lda #$20                     ; $9039
  sta $014F                    ; $903B
  lda #$00                     ; $903E
  sta z:HwScrollX              ; $9040
  sta z:HwScrollY              ; $9042
  sta $0543                    ; $9044
  sta $0545                    ; $9047
  sta $0546                    ; $904A
  rts                          ; $904D
  .incbin "prg_bank_5.bin", $104E, $13  ; $904E
RunSoundDriverBank5Timed:
  lda $0528                    ; $9061
  ora $0529                    ; $9064
  beq Loc_B5_9071              ; $9067
  dec $0528                    ; $9069
  bne Loc_B5_9071              ; $906C
  dec $0529                    ; $906E
Loc_B5_9071:
  lda z:MmcPrgShadow           ; $9071
  pha                          ; $9073
  lda #$05                     ; $9074
  sta z:MmcPrgShadow           ; $9076
  jsr RunSoundDriver           ; $9078
  pla                          ; $907B
  sta z:MmcPrgShadow           ; $907C
  rts                          ; $907E
InitDmcAndJoypad2:
  lda #$00                     ; $907F
  sta APU_DMC_FREQ             ; $9081
  sta APU_DMC_RAW              ; $9084
  lda #$0F                     ; $9087
  sta APU_SND_CHN              ; $9089
  lda #$C0                     ; $908C
  sta JOYPAD2                  ; $908E
  rts                          ; $9091
BlankScreenAndInitPpu:
  jsr FillPaletteBufferBlack   ; $9092
  jsr HideAllSpritesB5         ; $9095
InitScenePpuState:
  lda #$30                     ; $9098
  sta z:PpuCtrlShadow          ; $909A
  lda #$06                     ; $909C
  sta z:PpuMaskShadow          ; $909E
  lda #$00                     ; $90A0
  sta z:HwScrollX              ; $90A2
  sta z:HwScrollY              ; $90A4
  rts                          ; $90A6
Sub_B5_90A7:
  jsr Sub_B5_8150              ; $90A7
  lda #$1C                     ; $90AA
  ldx #$0F                     ; $90AC
  ldy #$0E                     ; $90AE
Sub_B5_90B0:
  jsr SetMmcControlChr0Chr1    ; $90B0
  jsr FillPaletteBufferBlack   ; $90B3
  jsr HideAllSpritesB5         ; $90B6
  lda #$FF                     ; $90B9
  ldx #$2C                     ; $90BB
  jsr FillNametableWithA       ; $90BD
  jsr ProcessPpuUpdateList     ; $90C0
  .addr Data_B5_9122  ; $90C3 inline pointer (data after a JSR)
  jsr ProcessPpuUpdateList     ; $90C5
  .addr Data_B5_89AB  ; $90C8 inline pointer (data after a JSR)
  lda $050F                    ; $90CA
  and #$3F                     ; $90CD
  sta z:Tmp03                  ; $90CF
  inc z:Tmp03                  ; $90D1
  lda #$00                     ; $90D3
  sta z:$04                    ; $90D5
  jsr BinToDecimal             ; $90D7
  lda PPU_STATUS               ; $90DA
  lda #$2F                     ; $90DD
  sta PPU_ADDR                 ; $90DF
  lda #$17                     ; $90E2
  sta PPU_ADDR                 ; $90E4
  ldy #$FF                     ; $90E7
  ldx z:Tmp01                  ; $90E9
  beq Loc_B5_90F3              ; $90EB
  lda Data_B5_9118,x           ; $90ED
  sta PPU_DATA                 ; $90F0
Loc_B5_90F3:
  sty PPU_DATA                 ; $90F3
  ldx z:Tmp00                  ; $90F6
  lda Data_B5_9118,x           ; $90F8
  sta PPU_DATA                 ; $90FB
  jsr InitScenePpuState        ; $90FE
  lda #$00                     ; $9101
  sta $0539                    ; $9103
  sta $053A                    ; $9106
  sta $053B                    ; $9109
  sta $053C                    ; $910C
  sta $053D                    ; $910F
  sta $053E                    ; $9112
  jmp Loc_B5_8725              ; $9115
Data_B5_9118:
  .incbin "prg_bank_5.bin", $1118, $A  ; $9118
Data_B5_9122:
  .incbin "prg_bank_5.bin", $1122, $8C  ; $9122
Loc_B5_91AE:
  jsr Sub_B5_8150              ; $91AE
  lda #$1C                     ; $91B1
  ldx #$0F                     ; $91B3
  ldy #$0E                     ; $91B5
  jsr SetMmcControlChr0Chr1    ; $91B7
  jsr FillPaletteBufferBlack   ; $91BA
  jsr HideAllSpritesB5         ; $91BD
  lda #$FF                     ; $91C0
  ldx #$20                     ; $91C2
  jsr FillNametableWithA       ; $91C4
  jsr CopyRamStub05B8          ; $91C7
  ldy #$02                     ; $91CA
  jsr $05B8                    ; $91CC
  jsr FillPaletteBufferBlack   ; $91CF
  lda #$27                     ; $91D2
  sta $0151                    ; $91D4
  lda #$20                     ; $91D7
  sta $0153                    ; $91D9
  jmp InitScenePpuState        ; $91DC
AnimateSkylineWindows:
  lda $0540                    ; $91DF
  asl a                        ; $91E2
  tax                          ; $91E3
  lda Data_B5_9201,x           ; $91E4
  sta $0521                    ; $91E7
  lda Data_B5_9202,x           ; $91EA
  sta $0522                    ; $91ED
  jsr $051E                    ; $91F0
  ldx $0540                    ; $91F3
  inx                          ; $91F6
  cpx #$0C                     ; $91F7
  bcc Loc_B5_91FD              ; $91F9
  ldx #$00                     ; $91FB
Loc_B5_91FD:
  stx $0540                    ; $91FD
  rts                          ; $9200
Data_B5_9201:
  .incbin "prg_bank_5.bin", $1201, $1  ; $9201
Data_B5_9202:
  .incbin "prg_bank_5.bin", $1202, $81  ; $9202
AnimateHelicopterSprite:
  jsr HideAllSpritesB5         ; $9283
  ldx $053F                    ; $9286
  txa                          ; $9289
  inx                          ; $928A
  cpx #$0E                     ; $928B
  bcc Loc_B5_9291              ; $928D
  ldx #$00                     ; $928F
Loc_B5_9291:
  stx $053F                    ; $9291
  and #$FE                     ; $9294
  tax                          ; $9296
  lda Data_B5_92D7,x           ; $9297
  sta z:Tmp00                  ; $929A
  lda Data_B5_92D8,x           ; $929C
  sta z:Tmp01                  ; $929F
  ldx #$00                     ; $92A1
  ldy #$00                     ; $92A3
Loc_B5_92A5:
  lda (Tmp00),y                ; $92A5
  beq Loc_B5_92D6              ; $92A7
  and #$F0                     ; $92A9
  lsr a                        ; $92AB
  adc #$3F                     ; $92AC
  sta OamBuffer,x              ; $92AE
  lda (Tmp00),y                ; $92B1
  and #$0F                     ; $92B3
  asl a                        ; $92B5
  asl a                        ; $92B6
  asl a                        ; $92B7
  adc #$40                     ; $92B8
  sta $0203,x                  ; $92BA
  iny                          ; $92BD
  lda (Tmp00),y                ; $92BE
  and #$3E                     ; $92C0
  clc                          ; $92C2
  adc #$40                     ; $92C3
  sta $0201,x                  ; $92C5
  lda (Tmp00),y                ; $92C8
  and #$C1                     ; $92CA
  sta $0202,x                  ; $92CC
  iny                          ; $92CF
  inx                          ; $92D0
  inx                          ; $92D1
  inx                          ; $92D2
  inx                          ; $92D3
  bne Loc_B5_92A5              ; $92D4
Loc_B5_92D6:
  rts                          ; $92D6
Data_B5_92D7:
  .incbin "prg_bank_5.bin", $12D7, $1  ; $92D7
Data_B5_92D8:
  .incbin "prg_bank_5.bin", $12D8, $108  ; $92D8
MoveSceneSpriteRandomly:
  inc $0503                    ; $93E0
  beq MoveSceneSpriteRandomly  ; $93E3
  jsr GetRandomByte            ; $93E5
  adc $0503                    ; $93E8
  and #$F0                     ; $93EB
  ora JoyHeld1                 ; $93ED
  ldx SceneSpriteY             ; $93F0
  asl a                        ; $93F3
  bcc Loc_B5_93F9              ; $93F4
  dec SceneSpriteX             ; $93F6
Loc_B5_93F9:
  asl a                        ; $93F9
  bcc Loc_B5_93FF              ; $93FA
  inc SceneSpriteX             ; $93FC
Loc_B5_93FF:
  asl a                        ; $93FF
  bcc Loc_B5_9407              ; $9400
  cpx #$48                     ; $9402
  bcc Loc_B5_9407              ; $9404
  dex                          ; $9406
Loc_B5_9407:
  asl a                        ; $9407
  bcc Loc_B5_940F              ; $9408
  cpx #$FF                     ; $940A
  beq Loc_B5_940F              ; $940C
  inx                          ; $940E
Loc_B5_940F:
  stx SceneSpriteY             ; $940F
  lda JoyNew1                  ; $9412
  and #$02                     ; $9415
  bne Loc_B5_941A              ; $9417
  rts                          ; $9419
Loc_B5_941A:
  cpx #$6C                     ; $941A
  bcc Loc_B5_9433              ; $941C
  cpx #$74                     ; $941E
  bcs Loc_B5_9433              ; $9420
  ldy SceneSpriteX             ; $9422
  cpy #$70                     ; $9425
  bcc Loc_B5_9433              ; $9427
  cpy #$78                     ; $9429
  bcs Loc_B5_9433              ; $942B
  sta SceneTimer               ; $942D
  jmp HideAllSpritesB5         ; $9430
Loc_B5_9433:
  rts                          ; $9433
Loc_B5_9434:
  lda #$30                     ; $9434
  sta z:PpuCtrlShadow          ; $9436
  lda #$06                     ; $9438
  jsr SetPpuMask               ; $943A
  lda #$1E                     ; $943D
  ldx #$0F                     ; $943F
  ldy #$0D                     ; $9441
  jsr SetMmcControlChr0Chr1    ; $9443
  lda #$FE                     ; $9446
  ldx #$20                     ; $9448
  jsr FillNametableWithA       ; $944A
  lda #$FF                     ; $944D
  ldx #$2C                     ; $944F
  jsr FillNametableWithA       ; $9451
  jsr ProcessPpuUpdateList     ; $9454
  .addr Data_B5_948F  ; $9457 inline pointer (data after a JSR)
  ldy #$1F                     ; $9459
Loc_B5_945B:
  lda Data_B5_946F,y           ; $945B
  sta PaletteBuffer,y          ; $945E
  dey                          ; $9461
  bpl Loc_B5_945B              ; $9462
  ldy #$00                     ; $9464
  sty SceneSpriteX             ; $9466
  ldy #$D0                     ; $9469
  sty SceneSpriteY             ; $946B
  rts                          ; $946E
Data_B5_946F:
  .incbin "prg_bank_5.bin", $146F, $20  ; $946F
Data_B5_948F:
  .incbin "prg_bank_5.bin", $148F, $179  ; $948F
Sub_B5_9608:
  ldy #$78                     ; $9608
  sty $0511                    ; $960A
  ldy #$4E                     ; $960D
  jsr DrawSpriteListWithOffset ; $960F
  lda $0510                    ; $9612
  and #$3C                     ; $9615
  lsr a                        ; $9617
  lsr a                        ; $9618
  bit $0510                    ; $9619
  bvc Loc_B5_9623              ; $961C
  eor #$0F                     ; $961E
  clc                          ; $9620
  adc #$01                     ; $9621
Loc_B5_9623:
  tay                          ; $9623
  lda Data_B5_96E1,y           ; $9624
  bit $0510                    ; $9627
  bpl Loc_B5_9631              ; $962A
  eor #$FF                     ; $962C
  clc                          ; $962E
  adc #$01                     ; $962F
Loc_B5_9631:
  clc                          ; $9631
  adc #$44                     ; $9632
  sta z:Tmp00                  ; $9634
  ldy #$00                     ; $9636
Loc_B5_9638:
  lda Data_B5_96B3,y           ; $9638
  and #$30                     ; $963B
  clc                          ; $963D
  adc z:Tmp00                  ; $963E
  sta OamBuffer,x              ; $9640
  inx                          ; $9643
  lda Data_B5_96B4,y           ; $9644
  sta OamBuffer,x              ; $9647
  inx                          ; $964A
  lda #$01                     ; $964B
  sta OamBuffer,x              ; $964D
  inx                          ; $9650
  lda Data_B5_96B3,y           ; $9651
  and #$0F                     ; $9654
  asl a                        ; $9656
  asl a                        ; $9657
  asl a                        ; $9658
  sta OamBuffer,x              ; $9659
  inx                          ; $965C
  iny                          ; $965D
  iny                          ; $965E
  cpy #$2E                     ; $965F
  bcc Loc_B5_9638              ; $9661
  lda $0510                    ; $9663
  lsr a                        ; $9666
  lda #$08                     ; $9667
  bcc Loc_B5_966D              ; $9669
  lda #$30                     ; $966B
Loc_B5_966D:
  sta z:Tmp01                  ; $966D
  ldy #$05                     ; $966F
Loc_B5_9671:
  lda z:Tmp00                  ; $9671
  sta OamBuffer,x              ; $9673
  inx                          ; $9676
  lda #$CE                     ; $9677
  sta OamBuffer,x              ; $9679
  inx                          ; $967C
  lda #$01                     ; $967D
  sta OamBuffer,x              ; $967F
  inx                          ; $9682
  lda z:Tmp01                  ; $9683
  sta OamBuffer,x              ; $9685
  clc                          ; $9688
  adc #$08                     ; $9689
  sta z:Tmp01                  ; $968B
  inx                          ; $968D
  dey                          ; $968E
  bne Loc_B5_9671              ; $968F
  lda $0510                    ; $9691
  lsr a                        ; $9694
  lsr a                        ; $9695
  and #$0F                     ; $9696
  tax                          ; $9698
  and #$08                     ; $9699
  beq Loc_B5_96A1              ; $969B
  txa                          ; $969D
  eor #$0F                     ; $969E
  tax                          ; $96A0
Loc_B5_96A1:
  lda Data_B5_96AB,x           ; $96A1
  sta $0143                    ; $96A4
  inc $0510                    ; $96A7
  rts                          ; $96AA
Data_B5_96AB:
  .incbin "prg_bank_5.bin", $16AB, $8  ; $96AB
Data_B5_96B3:
  .incbin "prg_bank_5.bin", $16B3, $1  ; $96B3
Data_B5_96B4:
  .incbin "prg_bank_5.bin", $16B4, $2D  ; $96B4
Data_B5_96E1:
  .incbin "prg_bank_5.bin", $16E1, $11  ; $96E1
AnimateIntroTile:
  inc $0504                    ; $96F2
  lda $0504                    ; $96F5
  lsr a                        ; $96F8
  lsr a                        ; $96F9
  and #$07                     ; $96FA
  tay                          ; $96FC
  lda Data_B5_9704,y           ; $96FD
  sta $0159                    ; $9700
  rts                          ; $9703
Data_B5_9704:
  .incbin "prg_bank_5.bin", $1704, $8  ; $9704
Loc_B5_970C:
  lda #$30                     ; $970C
  sta z:PpuCtrlShadow          ; $970E
  lda #$06                     ; $9710
  jsr SetPpuMask               ; $9712
  lda #$1D                     ; $9715
  ldx #$1A                     ; $9717
  ldy #$0D                     ; $9719
  jsr SetMmcControlChr0Chr1    ; $971B
  lda #$FF                     ; $971E
  ldx #$20                     ; $9720
  jsr FillNametableWithA       ; $9722
  lda #$22                     ; $9725
  jsr FillPaletteBufferWithA   ; $9727
  jsr HideAllSpritesB5         ; $972A
  jsr ProcessPpuUpdateList     ; $972D
  .addr Data_B5_9766  ; $9730 inline pointer (data after a JSR)
  lda #$0F                     ; $9732
  sta $014F                    ; $9734
  ldy #$07                     ; $9737
Loc_B5_9739:
  lda Data_B5_975E,y           ; $9739
  sta $0150,y                  ; $973C
  dey                          ; $973F
  bpl Loc_B5_9739              ; $9740
  lda #$12                     ; $9742
  sta SceneTimer               ; $9744
  lda #$C0                     ; $9747
  sta SceneSpriteY             ; $9749
  lda #$28                     ; $974C
  sta SceneSpriteX             ; $974E
  lda #$00                     ; $9751
  sta $0510                    ; $9753
  jsr Sub_B5_9608              ; $9756
  lda #$00                     ; $9759
  jmp QueueSound               ; $975B
Data_B5_975E:
  .incbin "prg_bank_5.bin", $175E, $8  ; $975E
Data_B5_9766:
  .incbin "prg_bank_5.bin", $1766, $69  ; $9766
DrawOfficeScene:
  lda #$58                     ; $97CF
  sta $0531                    ; $97D1
  lda #$58                     ; $97D4
  sta $0532                    ; $97D6
  jsr HideAllSpritesB5         ; $97D9
  jsr AnimateOfficeSpeaker     ; $97DC
  ldx #$C0                     ; $97DF
  jsr HideSpritesFromX         ; $97E1
  ldy #$06                     ; $97E4
  lda $052E                    ; $97E6
  cmp #$06                     ; $97E9
  bcc Loc_B5_97EE              ; $97EB
  iny                          ; $97ED
Loc_B5_97EE:
  tya                          ; $97EE
  ldx #$C0                     ; $97EF
  jmp DrawSpriteListToOam      ; $97F1
Sub_B5_97F4:
  jsr HideAllSpritesB5         ; $97F4
  lda #$00                     ; $97F7
  tax                          ; $97F9
  jsr DrawSpriteListToOam      ; $97FA
  lda $0505                    ; $97FD
  lsr a                        ; $9800
  lsr a                        ; $9801
  lsr a                        ; $9802
  bne Loc_B5_9807              ; $9803
  lda #$01                     ; $9805
Loc_B5_9807:
  cmp #$04                     ; $9807
  bcc Loc_B5_980D              ; $9809
  lda #$04                     ; $980B
Loc_B5_980D:
  jsr DrawSpriteListToOam      ; $980D
  ldy $0505                    ; $9810
  iny                          ; $9813
  bpl Loc_B5_9818              ; $9814
  ldy #$00                     ; $9816
Loc_B5_9818:
  sty $0505                    ; $9818
  rts                          ; $981B
DrawSpriteListToOam:
  asl a                        ; $981C
  tay                          ; $981D
  lda Data_B5_985C,y           ; $981E
  sta z:Tmp00                  ; $9821
  lda Data_B5_985D,y           ; $9823
  sta z:Tmp01                  ; $9826
  ldy #$00                     ; $9828
Loc_B5_982A:
  lda (Tmp00),y                ; $982A
  beq Loc_B5_985B              ; $982C
  and #$F0                     ; $982E
  lsr a                        ; $9830
  adc #$57                     ; $9831
  sta OamBuffer,x              ; $9833
  lda (Tmp00),y                ; $9836
  and #$0F                     ; $9838
  asl a                        ; $983A
  asl a                        ; $983B
  adc #$60                     ; $983C
  sta $0203,x                  ; $983E
  iny                          ; $9841
  lda (Tmp00),y                ; $9842
  and #$FC                     ; $9844
  sec                          ; $9846
  ror a                        ; $9847
  sta $0201,x                  ; $9848
  lda (Tmp00),y                ; $984B
  and #$03                     ; $984D
  ora #$20                     ; $984F
  sta $0202,x                  ; $9851
  iny                          ; $9854
  inx                          ; $9855
  inx                          ; $9856
  inx                          ; $9857
  inx                          ; $9858
  bne Loc_B5_982A              ; $9859
Loc_B5_985B:
  rts                          ; $985B
Data_B5_985C:
  .incbin "prg_bank_5.bin", $185C, $1  ; $985C
Data_B5_985D:
  .incbin "prg_bank_5.bin", $185D, $9E  ; $985D
Sub_B5_98FB:
  ldy #$84                     ; $98FB
  sty $0511                    ; $98FD
  ldy #$00                     ; $9900
DrawSpriteListWithOffset:
  jsr HideAllSpritesB5         ; $9902
Loc_B5_9905:
  lda Data_B5_9931,y           ; $9905
  clc                          ; $9908
  adc SceneSpriteY             ; $9909
  sta OamBuffer,x              ; $990C
  inx                          ; $990F
  iny                          ; $9910
  lda Data_B5_9931,y           ; $9911
  sta OamBuffer,x              ; $9914
  inx                          ; $9917
  iny                          ; $9918
  lda #$20                     ; $9919
  sta OamBuffer,x              ; $991B
  inx                          ; $991E
  lda Data_B5_9931,y           ; $991F
  clc                          ; $9922
  adc SceneSpriteX             ; $9923
  sta OamBuffer,x              ; $9926
  inx                          ; $9929
  iny                          ; $992A
  cpy $0511                    ; $992B
  bcc Loc_B5_9905              ; $992E
  rts                          ; $9930
Data_B5_9931:
  .incbin "prg_bank_5.bin", $1931, $84  ; $9931
Loc_B5_99B5:
  jsr Sub_B5_8150              ; $99B5
  jsr FillPaletteBufferBlack   ; $99B8
  jsr HideAllSpritesB5         ; $99BB
  jsr CopyRamStub051E          ; $99BE
  lda #$FF                     ; $99C1
  ldx #$20                     ; $99C3
  jsr FillNametableWithA       ; $99C5
  ldx $0512                    ; $99C8
  lda Data_B5_9C3D,x           ; $99CB
  bpl Loc_B5_99D6              ; $99CE
  lda #$00                     ; $99D0
  sta $0512                    ; $99D2
  rts                          ; $99D5
Loc_B5_99D6:
  sta z:PaletteSetIndex        ; $99D6
  jsr LoadPaletteSet           ; $99D8
  lda #$0F                     ; $99DB
  tax                          ; $99DD
  jsr Sub_B5_8934              ; $99DE
  lda #$20                     ; $99E1
  sta $014F                    ; $99E3
  jsr ProcessPpuUpdateList     ; $99E6
  .addr Data_B5_9A7C  ; $99E9 inline pointer (data after a JSR)
  lda $0512                    ; $99EB
  asl a                        ; $99EE
  tax                          ; $99EF
  lda Data_B5_9A82,x           ; $99F0
  sta $0521                    ; $99F3
  lda Data_B5_9A83,x           ; $99F6
  sta $0522                    ; $99F9
  jsr $051E                    ; $99FC
  lda $0512                    ; $99FF
  asl a                        ; $9A02
  tax                          ; $9A03
  lda Data_B5_9C78,x           ; $9A04
  sta z:Tmp01                  ; $9A07
  lda Data_B5_9C77,x           ; $9A09
  sta z:Tmp00                  ; $9A0C
  beq Loc_B5_9A3E              ; $9A0E
  ldx #$38                     ; $9A10
  ldy #$40                     ; $9A12
  lsr a                        ; $9A14
  bcc Loc_B5_9A1B              ; $9A15
  ldx #$35                     ; $9A17
  ldy #$44                     ; $9A19
Loc_B5_9A1B:
  stx z:Tmp02                  ; $9A1B
  sty z:Tmp03                  ; $9A1D
  asl a                        ; $9A1F
  sta z:Tmp00                  ; $9A20
  ldx #$0B                     ; $9A22
Loc_B5_9A24:
  lda Data_B5_9C4B,x           ; $9A24
  sta OamBuffer,x              ; $9A27
  dex                          ; $9A2A
  bpl Loc_B5_9A24              ; $9A2B
  lda z:Tmp02                  ; $9A2D
  sta $0203                    ; $9A2F
  lda z:Tmp03                  ; $9A32
  sta $0207                    ; $9A34
  ldx #$01                     ; $9A37
  ldy #$03                     ; $9A39
  jsr OrSpriteAttributes       ; $9A3B
Loc_B5_9A3E:
  ldx #$2F                     ; $9A3E
  ldy #$1F                     ; $9A40
Loc_B5_9A42:
  lda Data_B5_9C57,y           ; $9A42
  sta OamBuffer,x              ; $9A45
  dex                          ; $9A48
  dey                          ; $9A49
  bpl Loc_B5_9A42              ; $9A4A
  lda z:Tmp01                  ; $9A4C
  and #$F0                     ; $9A4E
  sta z:Tmp00                  ; $9A50
  ldx #$11                     ; $9A52
  ldy #$08                     ; $9A54
  jsr OrSpriteAttributes       ; $9A56
  inc $0512                    ; $9A59
  lda #$3C                     ; $9A5C
  sta SceneTimer               ; $9A5E
  lda z:Tmp01                  ; $9A61
  and #$07                     ; $9A63
  ora #$10                     ; $9A65
  sta z:MmcChr0Shadow          ; $9A67
  jmp MmcWriteChr0             ; $9A69
OrSpriteAttributes:
  lda z:Tmp00                  ; $9A6C
  ora OamBuffer,x              ; $9A6E
  sta OamBuffer,x              ; $9A71
  inx                          ; $9A74
  inx                          ; $9A75
  inx                          ; $9A76
  inx                          ; $9A77
  dey                          ; $9A78
  bne OrSpriteAttributes       ; $9A79
  rts                          ; $9A7B
Data_B5_9A7C:
  and ($EF,x)                  ; $9A7C  [heuristic code]
  .incbin "prg_bank_5.bin", $1A7E, $4  ; $9A7E
Data_B5_9A82:
  .incbin "prg_bank_5.bin", $1A82, $1  ; $9A82
Data_B5_9A83:
  .incbin "prg_bank_5.bin", $1A83, $1BA  ; $9A83
Data_B5_9C3D:
  .incbin "prg_bank_5.bin", $1C3D, $E  ; $9C3D
Data_B5_9C4B:
  .incbin "prg_bank_5.bin", $1C4B, $C  ; $9C4B
Data_B5_9C57:
  .incbin "prg_bank_5.bin", $1C57, $20  ; $9C57
Data_B5_9C77:
  .incbin "prg_bank_5.bin", $1C77, $1  ; $9C77
Data_B5_9C78:
  .incbin "prg_bank_5.bin", $1C78, $19  ; $9C78
Loc_B5_9C91:
  jsr Sub_B5_8150              ; $9C91
  lda #$1C                     ; $9C94
  ldx #$14                     ; $9C96
  ldy #$14                     ; $9C98
  jsr SetMmcControlChr0Chr1    ; $9C9A
  jsr FillPaletteBufferBlack   ; $9C9D
  jsr HideAllSpritesB5         ; $9CA0
  lda #$FF                     ; $9CA3
  ldx #$20                     ; $9CA5
  jsr FillNametableWithA       ; $9CA7
  jsr ProcessPpuUpdateList     ; $9CAA
  .addr Data_B5_9CB2  ; $9CAD inline pointer (data after a JSR)
  jmp InitScenePpuState        ; $9CAF
Data_B5_9CB2:
  .incbin "prg_bank_5.bin", $1CB2, $1D  ; $9CB2
Loc_B5_9CCF:
  jsr Sub_B5_8150              ; $9CCF
  lda #$1C                     ; $9CD2
  ldx #$1F                     ; $9CD4
  ldy #$0D                     ; $9CD6
  jsr SetMmcControlChr0Chr1    ; $9CD8
  jsr FillPaletteBufferBlack   ; $9CDB
  jsr HideAllSpritesB5         ; $9CDE
  lda #$FF                     ; $9CE1
  ldx #$20                     ; $9CE3
  jsr FillNametableWithA       ; $9CE5
  jsr ProcessPpuUpdateList     ; $9CE8
  .addr Data_B5_9CFF  ; $9CEB inline pointer (data after a JSR)
  lda #$20                     ; $9CED
  sta $014F                    ; $9CEF
  lda #$78                     ; $9CF2
  sta SceneTimer               ; $9CF4
  jsr InitScenePpuState        ; $9CF7
  lda #$0A                     ; $9CFA
  jmp QueueSound               ; $9CFC
Data_B5_9CFF:
  .incbin "prg_bank_5.bin", $1CFF, $E  ; $9CFF
Loc_B5_9D0D:
  jsr Sub_B5_8150              ; $9D0D
  lda #$1C                     ; $9D10
  ldx #$1F                     ; $9D12
  ldy #$0D                     ; $9D14
  jsr SetMmcControlChr0Chr1    ; $9D16
  jsr FillPaletteBufferBlack   ; $9D19
  jsr HideAllSpritesB5         ; $9D1C
  lda #$FF                     ; $9D1F
  ldx #$20                     ; $9D21
  jsr FillNametableWithA       ; $9D23
  jsr ProcessPpuUpdateList     ; $9D26
  .addr Data_B5_9D33  ; $9D29 inline pointer (data after a JSR)
  lda #$20                     ; $9D2B
  sta $014F                    ; $9D2D
  jmp InitScenePpuState        ; $9D30
Data_B5_9D33:
  .incbin "prg_bank_5.bin", $1D33, $D  ; $9D33
Loc_B5_9D40:
  jsr Sub_B5_8150              ; $9D40
  lda #$1C                     ; $9D43
  ldx #$1F                     ; $9D45
  ldy #$0D                     ; $9D47
  jsr SetMmcControlChr0Chr1    ; $9D49
  jsr FillPaletteBufferBlack   ; $9D4C
  jsr HideAllSpritesB5         ; $9D4F
  jsr CopyRamStub051E          ; $9D52
  lda #$FF                     ; $9D55
  ldx #$20                     ; $9D57
  jsr FillNametableWithA       ; $9D59
  jsr ProcessPpuUpdateList     ; $9D5C
  .addr Data_B5_9D7D  ; $9D5F inline pointer (data after a JSR)
  lda #$20                     ; $9D61
  sta $014F                    ; $9D63
  lda #$3C                     ; $9D66
  sta SceneTimer               ; $9D68
  lda #$30                     ; $9D6B
  sta $0528                    ; $9D6D
  lda #$02                     ; $9D70
  sta $0529                    ; $9D72
  jsr InitScenePpuState        ; $9D75
  lda #$00                     ; $9D78
  jmp QueueSound               ; $9D7A
Data_B5_9D7D:
  .incbin "prg_bank_5.bin", $1D7D, $37  ; $9D7D
Loc_B5_9DB4:
  jsr Sub_B5_8150              ; $9DB4
  lda #$1C                     ; $9DB7
  ldx #$0B                     ; $9DB9
  ldy #$0B                     ; $9DBB
  jsr SetMmcControlChr0Chr1    ; $9DBD
  jsr FillPaletteBufferBlack   ; $9DC0
  jsr HideAllSpritesB5         ; $9DC3
  lda #$00                     ; $9DC6
  ldx #$20                     ; $9DC8
  jsr FillNametableWithA       ; $9DCA
  ldx #$0B                     ; $9DCD
Loc_B5_9DCF:
  lda Data_B5_9E00,x           ; $9DCF
  sta OamBuffer,x              ; $9DD2
  dex                          ; $9DD5
  bpl Loc_B5_9DCF              ; $9DD6
  lda #$20                     ; $9DD8
  sta $0153                    ; $9DDA
  inc $050F                    ; $9DDD
  lda #$C8                     ; $9DE0
  sta z:PlayerLifeLo           ; $9DE2
  lda #$1E                     ; $9DE4
  sta SceneTimer               ; $9DE6
  lda #$80                     ; $9DE9
  sta $0528                    ; $9DEB
  lda #$02                     ; $9DEE
  sta $0529                    ; $9DF0
  jsr InitScenePpuState        ; $9DF3
  lda #$0B                     ; $9DF6
  jsr QueueSound               ; $9DF8
  lda #$29                     ; $9DFB
  jmp QueueSound               ; $9DFD
Data_B5_9E00:
  .incbin "prg_bank_5.bin", $1E00, $C  ; $9E00
Loc_B5_9E0C:
  jsr Sub_B5_8150              ; $9E0C
  lda #$1C                     ; $9E0F
  ldx #$1F                     ; $9E11
  ldy #$0D                     ; $9E13
  jsr SetMmcControlChr0Chr1    ; $9E15
  jsr FillPaletteBufferBlack   ; $9E18
  jsr HideAllSpritesB5         ; $9E1B
  jsr CopyRamStub051E          ; $9E1E
  lda #$FF                     ; $9E21
  ldx #$20                     ; $9E23
  jsr FillNametableWithA       ; $9E25
  jsr ProcessPpuUpdateList     ; $9E28
  .addr Data_B5_9E86  ; $9E2B inline pointer (data after a JSR)
  lda #$0C                     ; $9E2D
  ldx $050F                    ; $9E2F
  cpx #$33                     ; $9E32
  beq Loc_B5_9E3F              ; $9E34
  lda $050E                    ; $9E36
  cmp #$0C                     ; $9E39
  bcc Loc_B5_9E3F              ; $9E3B
  lda #$0B                     ; $9E3D
Loc_B5_9E3F:
  asl a                        ; $9E3F
  tax                          ; $9E40
  lda Data_B5_9EBA,x           ; $9E41
  sta $0521                    ; $9E44
  lda Data_B5_9EBB,x           ; $9E47
  sta $0522                    ; $9E4A
  jsr $051E                    ; $9E4D
  ldx #$2F                     ; $9E50
Loc_B5_9E52:
  lda Data_B5_9FCF,x           ; $9E52
  sta OamBuffer,x              ; $9E55
  dex                          ; $9E58
  bpl Loc_B5_9E52              ; $9E59
  lda #$20                     ; $9E5B
  sta $014F                    ; $9E5D
  lda #$14                     ; $9E60
  sta $0151                    ; $9E62
  lda #$24                     ; $9E65
  sta $0152                    ; $9E67
  lda #$1E                     ; $9E6A
  sta SceneTimer               ; $9E6C
  lda #$8C                     ; $9E6F
  sta $0528                    ; $9E71
  lda #$0B                     ; $9E74
  sta $0529                    ; $9E76
  jsr InitScenePpuState        ; $9E79
  lda #$02                     ; $9E7C
  jsr QueueSound               ; $9E7E
  lda #$29                     ; $9E81
  jmp QueueSound               ; $9E83
Data_B5_9E86:
  .incbin "prg_bank_5.bin", $1E86, $34  ; $9E86
Data_B5_9EBA:
  .incbin "prg_bank_5.bin", $1EBA, $1  ; $9EBA
Data_B5_9EBB:
  .incbin "prg_bank_5.bin", $1EBB, $114  ; $9EBB
Data_B5_9FCF:
  .incbin "prg_bank_5.bin", $1FCF, $31  ; $9FCF
SoundDriver:
  lda SoundQueue               ; $A000
  beq Loc_B5_A013              ; $A003
  lda #$00                     ; $A005
  sta z:Tmp00                  ; $A007
Loc_B5_A009:
  jsr ClearSoundChannelFlags   ; $A009
  inc z:Tmp00                  ; $A00C
  dec SoundQueue               ; $A00E
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
  sta z:SndPtrLo               ; $A020
  lda Data_B5_A445,x           ; $A022
  sta z:SndPtrHi               ; $A025
  ldy #$00                     ; $A027
  lda (SndPtrLo),y             ; $A029
  lsr a                        ; $A02B
  bcc Loc_B5_A031              ; $A02C
  jsr TickSoundChannel         ; $A02E
Loc_B5_A031:
  ldy #$00                     ; $A031
  lda (SndPtrLo),y             ; $A033
  lsr a                        ; $A035
  ror z:$F5                    ; $A036
  inc z:$F4                    ; $A038
  lda z:$F4                    ; $A03A
  cmp #$08                     ; $A03C
  bne Loc_B5_A019              ; $A03E
  jsr WriteApuFromShadow       ; $A040
  rts                          ; $A043
ClearSoundChannelFlags:
  ldx z:Tmp00                  ; $A044
  lda $06E1,x                  ; $A046
  bne Loc_B5_A065              ; $A049
  ldx #$00                     ; $A04B
Loc_B5_A04D:
  txa                          ; $A04D
  asl a                        ; $A04E
  tay                          ; $A04F
  lda Data_B5_A444,y           ; $A050
  sta z:SndPtrLo               ; $A053
  lda Data_B5_A445,y           ; $A055
  sta z:SndPtrHi               ; $A058
  ldy #$00                     ; $A05A
  tya                          ; $A05C
  sta (SndPtrLo),y             ; $A05D
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
  sta z:SndPtrLo               ; $A089
  lda Data_B5_A445,x           ; $A08B
  sta z:SndPtrHi               ; $A08E
  ldy #$17                     ; $A090
  lda #$00                     ; $A092
Loc_B5_A094:
  sta (SndPtrLo),y             ; $A094
  dey                          ; $A096
  bpl Loc_B5_A094              ; $A097
  lda #$01                     ; $A099
  iny                          ; $A09B
  sta (SndPtrLo),y             ; $A09C
  lda Data_B5_A454,x           ; $A09E
  ldy #$0B                     ; $A0A1
  sta (SndPtrLo),y             ; $A0A3
  iny                          ; $A0A5
  lda Data_B5_A455,x           ; $A0A6
  sta (SndPtrLo),y             ; $A0A9
  inc z:Tmp01                  ; $A0AB
  ldy z:Tmp01                  ; $A0AD
  lda ($F2),y                  ; $A0AF
  pha                          ; $A0B1
  iny                          ; $A0B2
  lda ($F2),y                  ; $A0B3
  sty z:Tmp01                  ; $A0B5
  ldy #$04                     ; $A0B7
  sta (SndPtrLo),y             ; $A0B9
  pla                          ; $A0BB
  dey                          ; $A0BC
  sta (SndPtrLo),y             ; $A0BD
  ldy #$01                     ; $A0BF
  tya                          ; $A0C1
  sta (SndPtrLo),y             ; $A0C2
  inc z:Tmp01                  ; $A0C4
  bne Loc_B5_A07C              ; $A0C6
Loc_B5_A0C8:
  rts                          ; $A0C8
TickSoundChannel:
  lda z:$F4                    ; $A0C9
  and #$03                     ; $A0CB
  asl a                        ; $A0CD
  asl a                        ; $A0CE
  sta $06CF                    ; $A0CF
  jsr TickSoundChannelDelay    ; $A0D2
  ldy #$01                     ; $A0D5
  lda (SndPtrLo),y             ; $A0D7
  sec                          ; $A0D9
  sbc #$01                     ; $A0DA
  beq Loc_B5_A0E1              ; $A0DC
  sta (SndPtrLo),y             ; $A0DE
  rts                          ; $A0E0
Loc_B5_A0E1:
  iny                          ; $A0E1
  lda (SndPtrLo),y             ; $A0E2
  dey                          ; $A0E4
  sta (SndPtrLo),y             ; $A0E5
  ldy #$07                     ; $A0E7
  lda #$00                     ; $A0E9
  sta (SndPtrLo),y             ; $A0EB
  jsr FetchSoundChannelStep    ; $A0ED
  ldy #$10                     ; $A0F0
  lda #$08                     ; $A0F2
  sta (SndPtrLo),y             ; $A0F4
  ldy #$03                     ; $A0F6
  lda (SndPtrLo),y             ; $A0F8
  sta z:Tmp02                  ; $A0FA
  iny                          ; $A0FC
  lda (SndPtrLo),y             ; $A0FD
  sta z:Tmp03                  ; $A0FF
  ldy #$00                     ; $A101
  sty z:Tmp01                  ; $A103
Loc_B5_A105:
  ldy z:Tmp01                  ; $A105
  inc z:Tmp01                  ; $A107
  lda (Tmp02),y                ; $A109
  bpl Loc_B5_A113              ; $A10B
  jsr DispatchSoundCommand     ; $A10D
  jmp Loc_B5_A105              ; $A110
Loc_B5_A113:
  tax                          ; $A113
  ldy #$14                     ; $A114
  lda (SndPtrLo),y             ; $A116
  beq Loc_B5_A140              ; $A118
  sta z:$F6                    ; $A11A
  iny                          ; $A11C
  clc                          ; $A11D
  lda (SndPtrLo),y             ; $A11E
  adc #$01                     ; $A120
  sta (SndPtrLo),y             ; $A122
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
  sta (SndPtrLo),y             ; $A162
  iny                          ; $A164
  lda z:$05                    ; $A165
  ora #$08                     ; $A167
  sta (SndPtrLo),y             ; $A169
  jsr LoadSoundChannelRegistersIfActive ; $A16B
Loc_B5_A16E:
  ldy #$03                     ; $A16E
  lda z:Tmp01                  ; $A170
  clc                          ; $A172
  adc z:Tmp02                  ; $A173
  sta (SndPtrLo),y             ; $A175
  iny                          ; $A177
  lda z:Tmp03                  ; $A178
  adc #$00                     ; $A17A
  sta (SndPtrLo),y             ; $A17C
  rts                          ; $A17E
LoadSoundChannelRegistersIfActive:
  jsr IsSoundChannelActive     ; $A17F
  bne Loc_B5_A1A2              ; $A182
LoadSoundChannelRegisters:
  ldx $06CF                    ; $A184
  lda $06D0,x                  ; $A187
  ora #$20                     ; $A18A
  sta $06D0,x                  ; $A18C
  ldy #$10                     ; $A18F
  lda (SndPtrLo),y             ; $A191
  sta $06D1,x                  ; $A193
  iny                          ; $A196
  lda (SndPtrLo),y             ; $A197
  sta $06D2,x                  ; $A199
  iny                          ; $A19C
  lda (SndPtrLo),y             ; $A19D
  sta $06D3,x                  ; $A19F
Loc_B5_A1A2:
  rts                          ; $A1A2
DispatchSoundCommand:
  sta z:$06                    ; $A1A3
  and #$7F                     ; $A1A5
  lsr a                        ; $A1A7
  lsr a                        ; $A1A8
  lsr a                        ; $A1A9
  lsr a                        ; $A1AA
  jsr InlineJumpTable          ; $A1AB
  .addr SoundCmdA_00, SoundCmdA_00, SoundCmdA_02, SoundCmdA_02, SoundCmdA_04, SoundCmdA_05, SoundCmdA_06, SoundCmdA_07  ; $A1AE pointer table
SoundCmdA_00:
  lda z:$06                    ; $A1BE
  and #$1F                     ; $A1C0
  tax                          ; $A1C2
  lda Data_B5_A496,x           ; $A1C3
  ldy #$01                     ; $A1C6
  sta (SndPtrLo),y             ; $A1C8
  iny                          ; $A1CA
  sta (SndPtrLo),y             ; $A1CB
  rts                          ; $A1CD
SoundCmdA_02:
  lda z:$06                    ; $A1CE
  and #$1F                     ; $A1D0
  asl a                        ; $A1D2
  tax                          ; $A1D3
  ldy #$05                     ; $A1D4
  lda Data_B5_A4B6,x           ; $A1D6
  sta (SndPtrLo),y             ; $A1D9
  iny                          ; $A1DB
  lda Data_B5_A4B7,x           ; $A1DC
  sta (SndPtrLo),y             ; $A1DF
  iny                          ; $A1E1
  lda #$00                     ; $A1E2
  sta (SndPtrLo),y             ; $A1E4
  jsr FetchSoundChannelStep    ; $A1E6
  rts                          ; $A1E9
SoundCmdA_04:
  lda z:$06                    ; $A1EA
  and #$0F                     ; $A1EC
  ldy #$11                     ; $A1EE
  sta (SndPtrLo),y             ; $A1F0
  lda #$08                     ; $A1F2
  iny                          ; $A1F4
  sta (SndPtrLo),y             ; $A1F5
  jsr LoadSoundChannelRegistersIfActive ; $A1F7
  pla                          ; $A1FA
  pla                          ; $A1FB
  jmp Loc_B5_A16E              ; $A1FC
SoundCmdA_05:
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
  lda (SndPtrLo),y             ; $A20E
  and #$3F                     ; $A210
  sta (SndPtrLo),y             ; $A212
  pla                          ; $A214
  ora (SndPtrLo),y             ; $A215
  sta (SndPtrLo),y             ; $A217
  rts                          ; $A219
Loc_B5_A21A:
  and #$03                     ; $A21A
  tax                          ; $A21C
  lda Data_B5_A420,x           ; $A21D
  ldy #$14                     ; $A220
  cmp (SndPtrLo),y             ; $A222
  sta (SndPtrLo),y             ; $A224
  beq Loc_B5_A22D              ; $A226
  lda #$00                     ; $A228
  iny                          ; $A22A
  sta (SndPtrLo),y             ; $A22B
Loc_B5_A22D:
  rts                          ; $A22D
SoundCmdA_06:
  lda z:$06                    ; $A22E
  and #$0F                     ; $A230
  ldy #$0D                     ; $A232
  sta (SndPtrLo),y             ; $A234
  rts                          ; $A236
SoundCmdA_07:
  lda z:$06                    ; $A237
  and #$07                     ; $A239
  jsr InlineJumpTable          ; $A23B
  .addr SoundCmdB_00, SoundCmdB_01, SoundCmdB_02, SoundCmdB_03, SoundCmdB_04, SoundCmdB_05, SoundCmdB_06, SoundCmdB_06  ; $A23E pointer table
SoundCmdB_00:
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
  sta (SndPtrLo),y             ; $A25E
  sta z:Tmp03                  ; $A260
  dey                          ; $A262
  pla                          ; $A263
  sta (SndPtrLo),y             ; $A264
  sta z:Tmp02                  ; $A266
  rts                          ; $A268
SoundCmdB_01:
  ldy z:Tmp01                  ; $A269
  lda (Tmp02),y                ; $A26B
  ldy #$13                     ; $A26D
  sta (SndPtrLo),y             ; $A26F
  inc z:Tmp01                  ; $A271
  lda z:Tmp01                  ; $A273
  clc                          ; $A275
  adc z:Tmp02                  ; $A276
  ldy #$09                     ; $A278
  sta (SndPtrLo),y             ; $A27A
  iny                          ; $A27C
  lda z:Tmp03                  ; $A27D
  adc #$00                     ; $A27F
  sta (SndPtrLo),y             ; $A281
  rts                          ; $A283
SoundCmdB_02:
  ldy #$13                     ; $A284
  lda (SndPtrLo),y             ; $A286
  sec                          ; $A288
  sbc #$01                     ; $A289
  beq Loc_B5_A2A7              ; $A28B
  sta (SndPtrLo),y             ; $A28D
  ldy #$09                     ; $A28F
  lda (SndPtrLo),y             ; $A291
  pha                          ; $A293
  iny                          ; $A294
  lda (SndPtrLo),y             ; $A295
  ldy #$04                     ; $A297
  sta (SndPtrLo),y             ; $A299
  sta z:Tmp03                  ; $A29B
  dey                          ; $A29D
  pla                          ; $A29E
  sta (SndPtrLo),y             ; $A29F
  sta z:Tmp02                  ; $A2A1
  lda #$00                     ; $A2A3
  sta z:Tmp01                  ; $A2A5
Loc_B5_A2A7:
  rts                          ; $A2A7
SoundCmdB_03:
  ldy z:Tmp01                  ; $A2A8
  lda (Tmp02),y                ; $A2AA
  ldy #$03                     ; $A2AC
  sta (SndPtrLo),y             ; $A2AE
  inc z:Tmp01                  ; $A2B0
  ldy z:Tmp01                  ; $A2B2
  lda (Tmp02),y                ; $A2B4
  ldy #$04                     ; $A2B6
  sta (SndPtrLo),y             ; $A2B8
  inc z:Tmp01                  ; $A2BA
  lda z:Tmp01                  ; $A2BC
  clc                          ; $A2BE
  adc z:Tmp02                  ; $A2BF
  pha                          ; $A2C1
  lda z:Tmp03                  ; $A2C2
  adc #$00                     ; $A2C4
  pha                          ; $A2C6
  ldy #$0B                     ; $A2C7
  lda (SndPtrLo),y             ; $A2C9
  sta z:$08                    ; $A2CB
  clc                          ; $A2CD
  adc #$02                     ; $A2CE
  sta (SndPtrLo),y             ; $A2D0
  iny                          ; $A2D2
  lda (SndPtrLo),y             ; $A2D3
  sta z:$09                    ; $A2D5
  adc #$00                     ; $A2D7
  sta (SndPtrLo),y             ; $A2D9
  ldy #$01                     ; $A2DB
  pla                          ; $A2DD
  sta ($08),y                  ; $A2DE
  dey                          ; $A2E0
  pla                          ; $A2E1
  sta ($08),y                  ; $A2E2
  lda #$00                     ; $A2E4
  sta z:Tmp01                  ; $A2E6
  ldy #$03                     ; $A2E8
  lda (SndPtrLo),y             ; $A2EA
  sta z:Tmp02                  ; $A2EC
  iny                          ; $A2EE
  lda (SndPtrLo),y             ; $A2EF
  sta z:Tmp03                  ; $A2F1
  rts                          ; $A2F3
SoundCmdB_04:
  ldy #$0B                     ; $A2F4
  sec                          ; $A2F6
  lda (SndPtrLo),y             ; $A2F7
  sbc #$02                     ; $A2F9
  sta (SndPtrLo),y             ; $A2FB
  sta z:$08                    ; $A2FD
  iny                          ; $A2FF
  lda (SndPtrLo),y             ; $A300
  sbc #$00                     ; $A302
  sta (SndPtrLo),y             ; $A304
  sta z:$09                    ; $A306
  ldy #$00                     ; $A308
  lda ($08),y                  ; $A30A
  pha                          ; $A30C
  iny                          ; $A30D
  lda ($08),y                  ; $A30E
  ldy #$04                     ; $A310
  sta (SndPtrLo),y             ; $A312
  sta z:Tmp03                  ; $A314
  dey                          ; $A316
  pla                          ; $A317
  sta (SndPtrLo),y             ; $A318
  sta z:Tmp02                  ; $A31A
  lda #$00                     ; $A31C
  sta z:Tmp01                  ; $A31E
  rts                          ; $A320
SoundCmdB_05:
  ldy z:Tmp01                  ; $A321
  lda (Tmp02),y                ; $A323
  inc z:Tmp01                  ; $A325
  ldy #$10                     ; $A327
  sta (SndPtrLo),y             ; $A329
  rts                          ; $A32B
SoundCmdB_06:
  lda #$00                     ; $A32C
  ldy #$00                     ; $A32E
  sta (SndPtrLo),y             ; $A330
  lda #$04                     ; $A332
  bit z:$F4                    ; $A334
  beq Loc_B5_A354              ; $A336
  lda z:$F4                    ; $A338
  and #$03                     ; $A33A
  asl a                        ; $A33C
  tax                          ; $A33D
  lda Data_B5_A444,x           ; $A33E
  sta z:SndPtrLo               ; $A341
  lda Data_B5_A445,x           ; $A343
  sta z:SndPtrHi               ; $A346
  jsr LoadSoundChannelRegisters ; $A348
  ldy #$0F                     ; $A34B
  lda (SndPtrLo),y             ; $A34D
  ora #$20                     ; $A34F
  sta $06D0,x                  ; $A351
Loc_B5_A354:
  pla                          ; $A354
  pla                          ; $A355
  rts                          ; $A356
TickSoundChannelDelay:
  ldy #$0E                     ; $A357
  lda (SndPtrLo),y             ; $A359
  beq FetchSoundChannelStep    ; $A35B
  sec                          ; $A35D
  sbc #$01                     ; $A35E
  sta (SndPtrLo),y             ; $A360
  rts                          ; $A362
FetchSoundChannelStep:
  ldy #$05                     ; $A363
  lda (SndPtrLo),y             ; $A365
  sta z:$04                    ; $A367
  iny                          ; $A369
  lda (SndPtrLo),y             ; $A36A
  sta z:$05                    ; $A36C
  iny                          ; $A36E
  lda (SndPtrLo),y             ; $A36F
  tay                          ; $A371
  lda ($04),y                  ; $A372
  pha                          ; $A374
  iny                          ; $A375
  lda ($04),y                  ; $A376
  pha                          ; $A378
  ldy #$07                     ; $A379
  lda (SndPtrLo),y             ; $A37B
  clc                          ; $A37D
  adc #$02                     ; $A37E
  sta (SndPtrLo),y             ; $A380
  ldy #$0E                     ; $A382
  pla                          ; $A384
  sta (SndPtrLo),y             ; $A385
  iny                          ; $A387
  lda (SndPtrLo),y             ; $A388
  and #$C0                     ; $A38A
  sta z:$04                    ; $A38C
  pla                          ; $A38E
  ora z:$04                    ; $A38F
  sta z:$04                    ; $A391
  and #$10                     ; $A393
  beq *+28                     ; $A395
  lda z:$04                    ; $A397
  and #$0F                     ; $A399
  ldy #$0D                     ; $A39B
  sec                          ; $A39D
  sbc (SndPtrLo),y             ; $A39E
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
  bit $04A5                    ; $A3B0
  ldy #$0F                     ; $A3B3
  sta (SndPtrLo),y             ; $A3B5
  jsr IsSoundChannelActive     ; $A3B7
  bne Loc_B5_A3C6              ; $A3BA
  ldy #$0F                     ; $A3BC
  lda (SndPtrLo),y             ; $A3BE
  ldx $06CF                    ; $A3C0
  sta $06D0,x                  ; $A3C3
Loc_B5_A3C6:
  rts                          ; $A3C6
WriteApuFromShadow:
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
IsSoundChannelActive:
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
InlineJumpTable:
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
  .incbin "prg_bank_5.bin", $39A6, $3DA  ; $B9A6
Loc_B5_BD80:
  jsr ProcessPpuUpdateList     ; $BD80
  .addr Data_B5_BD98  ; $BD83 inline pointer (data after a JSR)
  lda PlayerFacing             ; $BD85
  and #$02                     ; $BD88
  bne Loc_B5_BD92              ; $BD8A
  jsr ProcessPpuUpdateList     ; $BD8C
  .addr Data_B5_BDED  ; $BD8F inline pointer (data after a JSR)
  rts                          ; $BD91
Loc_B5_BD92:
  jsr ProcessPpuUpdateList     ; $BD92
  .addr Data_B5_BDE1  ; $BD95 inline pointer (data after a JSR)
  rts                          ; $BD97
Data_B5_BD98:
  .incbin "prg_bank_5.bin", $3D98, $49  ; $BD98
Data_B5_BDE1:
  .incbin "prg_bank_5.bin", $3DE1, $C  ; $BDE1
Data_B5_BDED:
  .incbin "prg_bank_5.bin", $3DED, $C  ; $BDED
Loc_B5_BDF9:
  lda z:PpuCtrlShadow          ; $BDF9
  ora #$02                     ; $BDFB
  sta z:PpuCtrlShadow          ; $BDFD
  ldx z:$81                    ; $BDFF
  dex                          ; $BE01
  beq Loc_B5_BE08              ; $BE02
  dex                          ; $BE04
  beq Loc_B5_BE29              ; $BE05
  rts                          ; $BE07
Loc_B5_BE08:
  ldx #$07                     ; $BE08
Loc_B5_BE0A:
  lda Data_B5_BE42,x           ; $BE0A
  sta $0210,x                  ; $BE0D
  dex                          ; $BE10
  bpl Loc_B5_BE0A              ; $BE11
  lda #$F0                     ; $BE13
  sta $0218                    ; $BE15
  sta $021C                    ; $BE18
  ldx #$57                     ; $BE1B
Loc_B5_BE1D:
  lda Data_B5_BE5A,x           ; $BE1D
  sta $0220,x                  ; $BE20
  dex                          ; $BE23
  bpl Loc_B5_BE1D              ; $BE24
  jmp Loc_B5_BF2A              ; $BE26
Loc_B5_BE29:
  ldx #$0F                     ; $BE29
Loc_B5_BE2B:
  lda Data_B5_BE4A,x           ; $BE2B
  sta $0210,x                  ; $BE2E
  dex                          ; $BE31
  bpl Loc_B5_BE2B              ; $BE32
  ldx #$77                     ; $BE34
Loc_B5_BE36:
  lda Data_B5_BEB2,x           ; $BE36
  sta $0220,x                  ; $BE39
  dex                          ; $BE3C
  bpl Loc_B5_BE36              ; $BE3D
  jmp Loc_B5_BF2A              ; $BE3F
Data_B5_BE42:
  .incbin "prg_bank_5.bin", $3E42, $8  ; $BE42
Data_B5_BE4A:
  .incbin "prg_bank_5.bin", $3E4A, $10  ; $BE4A
Data_B5_BE5A:
  .incbin "prg_bank_5.bin", $3E5A, $58  ; $BE5A
Data_B5_BEB2:
  .incbin "prg_bank_5.bin", $3EB2, $78  ; $BEB2
Loc_B5_BF2A:
  jsr ProcessPpuUpdateList     ; $BF2A
  .addr Data_B5_BF30  ; $BF2D inline pointer (data after a JSR)
  rts                          ; $BF2F
Data_B5_BF30:
  .incbin "prg_bank_5.bin", $3F30, $CD  ; $BF30
Data_B5_BFFD:
  .incbin "prg_bank_5.bin", $3FFD, $3  ; $BFFD
