; Bank 6  ($8000-$BFFF switchable)
; Per-frame scene code at $8010 (scene not identified yet).
.segment "PRG_BANK_6"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B6_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_6.bin", $0009, $7  ; $8009
Bank6Nmi:
  jsr Sub_B6_82F5              ; $8010
  jsr Sub_B6_81E3              ; $8013
  jsr DrawObjects              ; $8016
  jsr Sub_B6_801F              ; $8019
  jmp Loc_C0E0                 ; $801C
Sub_B6_801F:
  lda z:ScrollX                ; $801F
  and #$0F                     ; $8021
  bne Loc_B6_8049              ; $8023
  lda PlayerSpriteX0           ; $8025
  cmp #$78                     ; $8028
  beq Loc_B6_8036              ; $802A
  lda z:GameState              ; $802C
  cmp #$04                     ; $802E
  beq Loc_B6_8045              ; $8030
  cmp #$06                     ; $8032
  beq Loc_B6_8045              ; $8034
Loc_B6_8036:
  lda JoyHeld1                 ; $8036
  and #$C0                     ; $8039
  beq Loc_B6_8054              ; $803B
  cmp #$40                     ; $803D
  bne Loc_B6_8045              ; $803F
  jsr Sub_B6_8055              ; $8041
  rts                          ; $8044
Loc_B6_8045:
  jsr Sub_B6_8080              ; $8045
  rts                          ; $8048
Loc_B6_8049:
  cmp #$03                     ; $8049
  bcc Loc_B6_8051              ; $804B
  cmp #$0E                     ; $804D
  bcc Loc_B6_8054              ; $804F
Loc_B6_8051:
  jsr Sub_B6_80D8              ; $8051
Loc_B6_8054:
  rts                          ; $8054
Sub_B6_8055:
  jsr LoadStageSpawnListPtr    ; $8055
  jsr CalcScrollColumnIndex    ; $8058
  ldy SpawnIndexCurrent        ; $805B
  lda #$00                     ; $805E
Loc_B6_8060:
  sta z:$08                    ; $8060
  iny                          ; $8062
  lda (Tmp00),y                ; $8063
  cmp #$FE                     ; $8065
  bcs Loc_B6_807F              ; $8067
  cmp z:Tmp02                  ; $8069
  bne Loc_B6_807F              ; $806B
  iny                          ; $806D
  iny                          ; $806E
  lda (Tmp00),y                ; $806F
  beq Loc_B6_807C              ; $8071
  sta z:$06                    ; $8073
  jsr FindObjectByType         ; $8075
  cpx #$00                     ; $8078
  bne Loc_B6_807F              ; $807A
Loc_B6_807C:
  jsr Sub_B6_8117              ; $807C
Loc_B6_807F:
  rts                          ; $807F
Sub_B6_8080:
  jsr LoadStageSpawnListPtr    ; $8080
  jsr CalcNextScrollColumnIndex ; $8083
  ldy SpawnIndexNext           ; $8086
  lda #$01                     ; $8089
  jmp Loc_B6_8060              ; $808B
LoadStageSpawnListPtr:
  lda z:PaletteSetIndex        ; $808E
  asl a                        ; $8090
  tax                          ; $8091
  lda Data_B6_B500,x           ; $8092
  sta z:Tmp00                  ; $8095
  lda Data_B6_B501,x           ; $8097
  sta z:Tmp01                  ; $809A
  rts                          ; $809C
CalcScrollColumnIndex:
  lda z:ScrollPage             ; $809D
Loc_B6_809F:
  jsr AslA4                    ; $809F
  sta z:Tmp02                  ; $80A2
  lda z:ScrollX                ; $80A4
  jsr LsrA4                    ; $80A6
  ora z:Tmp02                  ; $80A9
  sta z:Tmp02                  ; $80AB
  rts                          ; $80AD
CalcNextScrollColumnIndex:
  ldx z:ScrollPage             ; $80AE
  inx                          ; $80B0
  txa                          ; $80B1
  jmp Loc_B6_809F              ; $80B2
FindObjectByType:
  ldx ObjectCount              ; $80B5
  beq Loc_B6_80D7              ; $80B8
  lda #$17                     ; $80BA
  sta z:$04                    ; $80BC
  lda #$03                     ; $80BE
  sta z:$05                    ; $80C0
  ldy #$00                     ; $80C2
Loc_B6_80C4:
  lda ($04),y                  ; $80C4
  cmp z:$06                    ; $80C6
  bne Loc_B6_80CD              ; $80C8
  ldx #$01                     ; $80CA
  rts                          ; $80CC
Loc_B6_80CD:
  lda #$10                     ; $80CD
  clc                          ; $80CF
  adc z:$04                    ; $80D0
  sta z:$04                    ; $80D2
  dex                          ; $80D4
  bne Loc_B6_80C4              ; $80D5
Loc_B6_80D7:
  rts                          ; $80D7
Sub_B6_80D8:
  jsr LoadStageSpawnListPtr    ; $80D8
  jsr CalcScrollColumnIndex    ; $80DB
  inc z:Tmp02                  ; $80DE
  ldy #$05                     ; $80E0
Loc_B6_80E2:
  lda (Tmp00),y                ; $80E2
  cmp #$FF                     ; $80E4
  bcs Loc_B6_80F3              ; $80E6
  cmp z:Tmp02                  ; $80E8
  bcs Loc_B6_80F3              ; $80EA
  iny                          ; $80EC
  iny                          ; $80ED
  iny                          ; $80EE
  iny                          ; $80EF
  jmp Loc_B6_80E2              ; $80F0
Loc_B6_80F3:
  tya                          ; $80F3
  sec                          ; $80F4
  sbc #$05                     ; $80F5
  sta SpawnIndexCurrent        ; $80F7
  jsr CalcNextScrollColumnIndex ; $80FA
  ldy #$05                     ; $80FD
Loc_B6_80FF:
  lda (Tmp00),y                ; $80FF
  cmp #$FF                     ; $8101
  beq Loc_B6_8112              ; $8103
  cmp z:Tmp02                  ; $8105
  beq Loc_B6_810B              ; $8107
  bcs Loc_B6_8112              ; $8109
Loc_B6_810B:
  iny                          ; $810B
  iny                          ; $810C
  iny                          ; $810D
  iny                          ; $810E
  jmp Loc_B6_80FF              ; $810F
Loc_B6_8112:
  dey                          ; $8112
  sty SpawnIndexNext           ; $8113
  rts                          ; $8116
Sub_B6_8117:
  lda ObjectCount              ; $8117
  cmp #$09                     ; $811A
  bcs Loc_B6_8157              ; $811C
  inc ObjectCount              ; $811E
  lda ObjectCount              ; $8121
  jsr AslA4                    ; $8124
  sta z:$0A                    ; $8127
  lda #$03                     ; $8129
  sta z:$0B                    ; $812B
  lda z:$08                    ; $812D
  bne Loc_B6_8137              ; $812F
  ldy SpawnIndexCurrent        ; $8131
  jmp Loc_B6_813A              ; $8134
Loc_B6_8137:
  ldy SpawnIndexNext           ; $8137
Loc_B6_813A:
  lda (Tmp00),y                ; $813A
  asl a                        ; $813C
  tax                          ; $813D
  lda Data_B6_8158,x           ; $813E
  sta $0304                    ; $8141
  lda Data_B6_8159,x           ; $8144
  sta $0305                    ; $8147
  lda #$81                     ; $814A
  pha                          ; $814C
  lda #$53                     ; $814D
  pha                          ; $814F
  jmp ($0304)                  ; $8150
  .incbin "prg_bank_6.bin", $0153, $1  ; $8153
  jsr Sub_B6_81AA              ; $8154
Loc_B6_8157:
  rts                          ; $8157
Data_B6_8158:
  .incbin "prg_bank_6.bin", $0158, $1  ; $8158
Data_B6_8159:
  .incbin "prg_bank_6.bin", $0159, $51  ; $8159
Sub_B6_81AA:
  ldy #$00                     ; $81AA
  lda ($0A),y                  ; $81AC
  and #$3F                     ; $81AE
  tax                          ; $81B0
  lda Data_B6_81B9,x           ; $81B1
  ldy #$06                     ; $81B4
  sta ($0A),y                  ; $81B6
  rts                          ; $81B8
Data_B6_81B9:
  .incbin "prg_bank_6.bin", $01B9, $2A  ; $81B9
Sub_B6_81E3:
  ldx #$0F                     ; $81E3
  ldy #$03                     ; $81E5
Loc_B6_81E7:
  lda #$00                     ; $81E7
  sta ObjectTable,y            ; $81E9
  tya                          ; $81EC
  clc                          ; $81ED
  adc #$10                     ; $81EE
  tay                          ; $81F0
  dex                          ; $81F1
  bne Loc_B6_81E7              ; $81F2
  lda #$10                     ; $81F4
  sta z:Tmp00                  ; $81F6
  lda #$03                     ; $81F8
  sta z:Tmp01                  ; $81FA
  lda $0300                    ; $81FC
  asl a                        ; $81FF
  tay                          ; $8200
  lda Data_C347,y              ; $8201
  sta z:Tmp02                  ; $8204
  inc $0303                    ; $8206
  lda $0303                    ; $8209
  cmp ObjectCount              ; $820C
  bcc Loc_B6_8216              ; $820F
  lda #$00                     ; $8211
  sta $0303                    ; $8213
Loc_B6_8216:
  sta z:Tmp03                  ; $8216
  ldx #$00                     ; $8218
Loc_B6_821A:
  lda z:Tmp03                  ; $821A
  jsr AslA4                    ; $821C
  adc #$04                     ; $821F
  tay                          ; $8221
  lda (Tmp00),y                ; $8222
  bne Loc_B6_8229              ; $8224
  jmp Loc_B6_822E              ; $8226
Loc_B6_8229:
  dey                          ; $8229
  lda z:Tmp02                  ; $822A
  sta (Tmp00),y                ; $822C
Loc_B6_822E:
  inc z:Tmp03                  ; $822E
  lda z:Tmp03                  ; $8230
  cmp ObjectCount              ; $8232
  bcc Loc_B6_823B              ; $8235
  lda #$00                     ; $8237
  sta z:Tmp03                  ; $8239
Loc_B6_823B:
  tya                          ; $823B
  and #$F0                     ; $823C
  tay                          ; $823E
  lda (Tmp00),y                ; $823F
  and #$80                     ; $8241
  beq Loc_B6_825E              ; $8243
  iny                          ; $8245
  iny                          ; $8246
  iny                          ; $8247
  iny                          ; $8248
  lda (Tmp00),y                ; $8249
  and #$1F                     ; $824B
  asl a                        ; $824D
  asl a                        ; $824E
  clc                          ; $824F
  adc z:Tmp02                  ; $8250
  sta z:Tmp02                  ; $8252
  bcc Loc_B6_825E              ; $8254
  dey                          ; $8256
  lda #$00                     ; $8257
  sta (Tmp00),y                ; $8259
  jmp Loc_B6_8264              ; $825B
Loc_B6_825E:
  inx                          ; $825E
  cpx ObjectCount              ; $825F
  bcc Loc_B6_821A              ; $8262
Loc_B6_8264:
  lda ObjectCount              ; $8264
  beq Loc_B6_82A2              ; $8267
  lda #$00                     ; $8269
  sta $0302                    ; $826B
Loc_B6_826E:
  ldy #$00                     ; $826E
  lda (Tmp00),y                ; $8270
  and #$3F                     ; $8272
  cmp #$30                     ; $8274
  bcs Loc_B6_8290              ; $8276
  asl a                        ; $8278
  tay                          ; $8279
  lda Data_B6_82A3,y           ; $827A
  sta $0304                    ; $827D
  lda Data_B6_82A4,y           ; $8280
  sta $0305                    ; $8283
  lda #$82                     ; $8286
  pha                          ; $8288
  lda #$8F                     ; $8289
  pha                          ; $828B
  jmp ($0304)                  ; $828C
  .incbin "prg_bank_6.bin", $028F, $1  ; $828F
Loc_B6_8290:
  lda z:Tmp00                  ; $8290
  clc                          ; $8292
  adc #$10                     ; $8293
  sta z:Tmp00                  ; $8295
  inc $0302                    ; $8297
  lda $0302                    ; $829A
  cmp ObjectCount              ; $829D
  bcc Loc_B6_826E              ; $82A0
Loc_B6_82A2:
  rts                          ; $82A2
Data_B6_82A3:
  .incbin "prg_bank_6.bin", $02A3, $1  ; $82A3
Data_B6_82A4:
  .incbin "prg_bank_6.bin", $02A4, $51  ; $82A4
Sub_B6_82F5:
  ldx ObjectCount              ; $82F5
  bne Loc_B6_82FB              ; $82F8
  rts                          ; $82FA
Loc_B6_82FB:
  lda #$10                     ; $82FB
  sta z:Tmp00                  ; $82FD
  lda #$03                     ; $82FF
  sta z:Tmp01                  ; $8301
Loc_B6_8303:
  ldy #$06                     ; $8303
  lda (Tmp00),y                ; $8305
  and #$0F                     ; $8307
  bne Loc_B6_8311              ; $8309
  jsr CollectPickup            ; $830B
  jsr Sub_B6_8703              ; $830E
Loc_B6_8311:
  lda z:Tmp00                  ; $8311
  clc                          ; $8313
  adc #$10                     ; $8314
  sta z:Tmp00                  ; $8316
  dex                          ; $8318
  bne Loc_B6_8303              ; $8319
  rts                          ; $831B
CollectPickup:
  lda z:PlayerLifeLo           ; $831C
  beq Loc_B6_8353              ; $831E
  ldy #$00                     ; $8320
  lda (Tmp00),y                ; $8322
  and #$3F                     ; $8324
  tay                          ; $8326
  lda z:PlayerLifeLo           ; $8327
  clc                          ; $8329
  adc Data_B6_8354,y           ; $832A
  bcs Loc_B6_8333              ; $832D
  cmp #$C8                     ; $832F
  bcc Loc_B6_8335              ; $8331
Loc_B6_8333:
  lda #$C8                     ; $8333
Loc_B6_8335:
  sta z:PlayerLifeLo           ; $8335
  lda z:AmmoLo                 ; $8337
  clc                          ; $8339
  adc Data_B6_837E,y           ; $833A
  sta z:AmmoLo                 ; $833D
  lda z:AmmoHi                 ; $833F
  adc #$00                     ; $8341
  sta z:AmmoHi                 ; $8343
  cmp #$01                     ; $8345
  bcc Loc_B6_8353              ; $8347
  lda z:AmmoLo                 ; $8349
  cmp #$90                     ; $834B
  bcc Loc_B6_8353              ; $834D
  lda #$90                     ; $834F
  sta z:AmmoLo                 ; $8351
Loc_B6_8353:
  rts                          ; $8353
Data_B6_8354:
  .incbin "prg_bank_6.bin", $0354, $2A  ; $8354
Data_B6_837E:
  .incbin "prg_bank_6.bin", $037E, $2A  ; $837E
Sub_B6_83A8:
  jsr Sub_B6_83F4              ; $83A8
  jsr SetRandomSpawnPhase      ; $83AB
  jsr SetSpawnFacingBits       ; $83AE
  ldy #$00                     ; $83B1
  lda #$C0                     ; $83B3
  sta ($0A),y                  ; $83B5
  ldy #$08                     ; $83B7
  lda #$01                     ; $83B9
  sta ($0A),y                  ; $83BB
  rts                          ; $83BD
StoreSpawnStats:
  iny                          ; $83BE
  iny                          ; $83BF
  iny                          ; $83C0
  lda (Tmp00),y                ; $83C1
  pha                          ; $83C3
  dey                          ; $83C4
  lda (Tmp00),y                ; $83C5
  and #$FE                     ; $83C7
  ldy #$0B                     ; $83C9
  sta ($0A),y                  ; $83CB
  pla                          ; $83CD
  ldy #$07                     ; $83CE
  sta ($0A),y                  ; $83D0
  rts                          ; $83D2
SetSpawnXFromScroll:
  lda z:$08                    ; $83D3
  bne Loc_B6_83E3              ; $83D5
  ldy #$09                     ; $83D7
  lda z:ScrollPage             ; $83D9
  sta ($0A),y                  ; $83DB
  iny                          ; $83DD
  lda z:ScrollX                ; $83DE
  sta ($0A),y                  ; $83E0
  rts                          ; $83E2
Loc_B6_83E3:
  ldy #$0A                     ; $83E3
  lda #$FF                     ; $83E5
  clc                          ; $83E7
  adc z:ScrollX                ; $83E8
  sta ($0A),y                  ; $83EA
  dey                          ; $83EC
  lda z:ScrollPage             ; $83ED
  adc #$00                     ; $83EF
  sta ($0A),y                  ; $83F1
  rts                          ; $83F3
Sub_B6_83F4:
  jsr StoreSpawnStats          ; $83F4
  jsr SetSpawnXFromScroll      ; $83F7
  ldy #$0E                     ; $83FA
  lda #$00                     ; $83FC
  sta ($0A),y                  ; $83FE
  rts                          ; $8400
SetSpawnFacingBits:
  lda z:$08                    ; $8401
  jsr AslA6                    ; $8403
  ldy #$09                     ; $8406
  ora ($0A),y                  ; $8408
  sta ($0A),y                  ; $840A
  rts                          ; $840C
SetRandomSpawnPhase:
  jsr GetRandomByte            ; $840D
  and #$03                     ; $8410
  ldy #$0E                     ; $8412
  sta ($0A),y                  ; $8414
  rts                          ; $8416
  jsr Sub_B6_83F4              ; $8417  [heuristic code]
  jsr SetSpawnFacingBits       ; $841A
  ldy #$00                     ; $841D
  lda #$C2                     ; $841F
  sta ($0A),y                  ; $8421
  ldy #$08                     ; $8423
  lda #$30                     ; $8425
  sta ($0A),y                  ; $8427
  rts                          ; $8429
  jsr Sub_B6_83F4              ; $842A  [heuristic code]
  jsr SetSpawnFacingBits       ; $842D
  ldy #$00                     ; $8430
  lda #$C3                     ; $8432
  sta ($0A),y                  ; $8434
  ldy #$08                     ; $8436
  lda #$28                     ; $8438
  sta ($0A),y                  ; $843A
  rts                          ; $843C
  .incbin "prg_bank_6.bin", $043D, $1C0  ; $843D
Sub_B6_85FD:
  jsr Sub_B6_83F4              ; $85FD
  lda z:$08                    ; $8600
  jsr AslA6                    ; $8602
  sta z:$08                    ; $8605
  jsr GetRandomByte            ; $8607
  and #$30                     ; $860A
  ora z:$08                    ; $860C
  ldy #$09                     ; $860E
  ora ($0A),y                  ; $8610
  sta ($0A),y                  ; $8612
  ldy #$00                     ; $8614
  lda #$CB                     ; $8616
  sta ($0A),y                  ; $8618
  ldy #$08                     ; $861A
  lda #$01                     ; $861C
  sta ($0A),y                  ; $861E
  rts                          ; $8620
  jsr SetRandomSpawnYNearPlayer ; $8621  [heuristic code]
  jsr SetSpawnXFromScroll      ; $8624
  jsr Sub_B6_865C              ; $8627
  ldy #$00                     ; $862A
  lda #$CC                     ; $862C
  sta ($0A),y                  ; $862E
  ldy #$08                     ; $8630
  lda #$06                     ; $8632
  sta ($0A),y                  ; $8634
  lda #$16                     ; $8636
  jsr QueueSound               ; $8638
  rts                          ; $863B
SetRandomSpawnYNearPlayer:
  jsr GetRandomByte            ; $863C
  and #$30                     ; $863F
  clc                          ; $8641
  adc #$E8                     ; $8642
  clc                          ; $8644
  adc PlayerSpriteY0           ; $8645
  cmp #$18                     ; $8648
  bcs Loc_B6_8651              ; $864A
  lda #$18                     ; $864C
  jmp Loc_B6_8657              ; $864E
Loc_B6_8651:
  cmp #$C8                     ; $8651
  bcc Loc_B6_8657              ; $8653
  lda #$C8                     ; $8655
Loc_B6_8657:
  ldy #$0B                     ; $8657
  sta ($0A),y                  ; $8659
  rts                          ; $865B
Sub_B6_865C:
  jsr GetRandomByte            ; $865C
  and #$70                     ; $865F
  ldy #$09                     ; $8661
  ora ($0A),y                  ; $8663
  sta ($0A),y                  ; $8665
  rts                          ; $8667
  lda z:FrameCounter           ; $8668  [heuristic code]
  and #$01                     ; $866A
  bne Loc_B6_868B              ; $866C
  jsr SetSpawnXFromScroll      ; $866E
  jsr Sub_B6_86BA              ; $8671
  jsr Sub_B6_869A              ; $8674
  jsr Sub_B6_868C              ; $8677
  ldy #$00                     ; $867A
  lda #$CE                     ; $867C
  sta ($0A),y                  ; $867E
  ldy #$08                     ; $8680
  lda #$02                     ; $8682
  sta ($0A),y                  ; $8684
  lda #$33                     ; $8686
  jsr QueueSound               ; $8688
Loc_B6_868B:
  rts                          ; $868B
Sub_B6_868C:
  stx z:$06                    ; $868C
  jsr GetRandomByte            ; $868E
  and #$30                     ; $8691
  adc z:$06                    ; $8693
  ldy #$0B                     ; $8695
  sta ($0A),y                  ; $8697
  rts                          ; $8699
Sub_B6_869A:
  lda PlayerSpriteY0           ; $869A
  cmp #$70                     ; $869D
  bcs Loc_B6_86A8              ; $869F
  lda #$10                     ; $86A1
  ldx #$28                     ; $86A3
  jmp Loc_B6_86AC              ; $86A5
Loc_B6_86A8:
  lda #$00                     ; $86A8
  ldx #$88                     ; $86AA
Loc_B6_86AC:
  ldy #$09                     ; $86AC
  ora ($0A),y                  ; $86AE
  sta ($0A),y                  ; $86B0
  ldy #$05                     ; $86B2
  jsr LsrA4                    ; $86B4
  sta ($0A),y                  ; $86B7
  rts                          ; $86B9
Sub_B6_86BA:
  ldy #$0A                     ; $86BA
  lda ($0A),y                  ; $86BC
  sec                          ; $86BE
  sbc #$FC                     ; $86BF
  sta ($0A),y                  ; $86C1
  dey                          ; $86C3
  lda ($0A),y                  ; $86C4
  sbc #$00                     ; $86C6
  sta ($0A),y                  ; $86C8
  rts                          ; $86CA
  .incbin "prg_bank_6.bin", $06CB, $2  ; $86CB
Loc_B6_86CD:
  sta z:$04                    ; $86CD
  ldy #$00                     ; $86CF
  lda #$D0                     ; $86D1
  sta (Tmp00),y                ; $86D3
  ldy #$04                     ; $86D5
  lda #$02                     ; $86D7
  sta (Tmp00),y                ; $86D9
  ldy #$08                     ; $86DB
  lda #$02                     ; $86DD
  sta (Tmp00),y                ; $86DF
  iny                          ; $86E1
  lda (Tmp00),y                ; $86E2
  and #$0F                     ; $86E4
  ora z:$04                    ; $86E6
  sta (Tmp00),y                ; $86E8
  ldy #$0E                     ; $86EA
  lda #$00                     ; $86EC
  sta (Tmp00),y                ; $86EE
  ldy #$06                     ; $86F0
  lda #$0F                     ; $86F2
  sta (Tmp00),y                ; $86F4
  iny                          ; $86F6
  lda (Tmp00),y                ; $86F7
  and #$7F                     ; $86F9
  sta (Tmp00),y                ; $86FB
  lda #$10                     ; $86FD
  jsr QueueSound               ; $86FF
  rts                          ; $8702
Sub_B6_8703:
  lda #$10                     ; $8703
  jmp Loc_B6_86CD              ; $8705
  lda z:FrameCounter           ; $8708  [heuristic code]
  and #$01                     ; $870A
  beq Loc_B6_8715              ; $870C
  lda ObjectCount              ; $870E
  cmp #$09                     ; $8711
  bcc Loc_B6_8719              ; $8713
Loc_B6_8715:
  dec ObjectCount              ; $8715
  rts                          ; $8718
Loc_B6_8719:
  jsr SetSpawnXFromScroll      ; $8719
  jsr Sub_B6_8746              ; $871C
  jsr SetSpawnYToPlayerY       ; $871F
  jsr Sub_B6_8756              ; $8722
  inc ObjectCount              ; $8725
  inc ObjectCount              ; $8728
  inc ObjectCount              ; $872B
  inc ObjectCount              ; $872E
  ldy #$00                     ; $8731
  lda #$51                     ; $8733
  sta ($0A),y                  ; $8735
  ldy #$08                     ; $8737
  lda #$3F                     ; $8739
  sta ($0A),y                  ; $873B
  rts                          ; $873D
SetSpawnYToPlayerY:
  ldy #$0B                     ; $873E
  lda PlayerSpriteY0           ; $8740
  sta ($0A),y                  ; $8743
  rts                          ; $8745
Sub_B6_8746:
  ldy #$0A                     ; $8746
  lda ($0A),y                  ; $8748
  adc #$18                     ; $874A
  sta ($0A),y                  ; $874C
  dey                          ; $874E
  lda ($0A),y                  ; $874F
  adc #$00                     ; $8751
  sta ($0A),y                  ; $8753
  rts                          ; $8755
Sub_B6_8756:
  lda #$52                     ; $8756
  ldy #$10                     ; $8758
  sta ($0A),y                  ; $875A
  ldy #$20                     ; $875C
  sta ($0A),y                  ; $875E
  ldy #$30                     ; $8760
  sta ($0A),y                  ; $8762
  ldy #$40                     ; $8764
  sta ($0A),y                  ; $8766
  lda #$0F                     ; $8768
  ldy #$16                     ; $876A
  sta ($0A),y                  ; $876C
  ldy #$26                     ; $876E
  sta ($0A),y                  ; $8770
  ldy #$36                     ; $8772
  sta ($0A),y                  ; $8774
  ldy #$46                     ; $8776
  sta ($0A),y                  ; $8778
  rts                          ; $877A
  lda z:FrameCounter           ; $877B  [heuristic code]
  and #$01                     ; $877D
  bne Loc_B6_8796              ; $877F
  jsr SetSpawnXFromScroll      ; $8781
  ldy #$0B                     ; $8784
  lda #$C8                     ; $8786
  sta ($0A),y                  ; $8788
  ldy #$00                     ; $878A
  lda #$D6                     ; $878C
  sta ($0A),y                  ; $878E
  ldy #$08                     ; $8790
  lda #$3F                     ; $8792
  sta ($0A),y                  ; $8794
Loc_B6_8796:
  rts                          ; $8796
  lda ObjectCount              ; $8797  [heuristic code]
  cmp #$0D                     ; $879A
  bcs Loc_B6_87A5              ; $879C
  lda JoyHeld1                 ; $879E
  and #$C0                     ; $87A1
  bne Loc_B6_87A9              ; $87A3
Loc_B6_87A5:
  dec ObjectCount              ; $87A5
  rts                          ; $87A8
Loc_B6_87A9:
  jsr SetSpawnXFromScroll      ; $87A9
  jsr Sub_B6_87DA              ; $87AC
  jsr Sub_B6_87D3              ; $87AF
  ldy #$00                     ; $87B2
  lda #$D8                     ; $87B4
  sta ($0A),y                  ; $87B6
  ldy #$08                     ; $87B8
  lda #$3F                     ; $87BA
  sta ($0A),y                  ; $87BC
  ldy #$06                     ; $87BE
  lda #$01                     ; $87C0
  sta ($0A),y                  ; $87C2
  inc ObjectCount              ; $87C4
  jsr DuplicateObjectEntry     ; $87C7
  jsr Sub_B6_8822              ; $87CA
  lda #$3D                     ; $87CD
  jsr QueueSound               ; $87CF
  rts                          ; $87D2
Sub_B6_87D3:
  ldy #$0B                     ; $87D3
  lda #$10                     ; $87D5
  sta ($0A),y                  ; $87D7
  rts                          ; $87D9
Sub_B6_87DA:
  ldy #$0A                     ; $87DA
  lda JoyHeld1                 ; $87DC
  and #$C0                     ; $87DF
  cmp #$40                     ; $87E1
  bne Loc_B6_87F4              ; $87E3
  lda ($0A),y                  ; $87E5
  clc                          ; $87E7
  adc #$50                     ; $87E8
  sta ($0A),y                  ; $87EA
  dey                          ; $87EC
  lda ($0A),y                  ; $87ED
  adc #$00                     ; $87EF
  jmp Loc_B6_8800              ; $87F1
Loc_B6_87F4:
  lda ($0A),y                  ; $87F4
  sec                          ; $87F6
  sbc #$60                     ; $87F7
  sta ($0A),y                  ; $87F9
  dey                          ; $87FB
  lda ($0A),y                  ; $87FC
  sbc #$00                     ; $87FE
Loc_B6_8800:
  sta ($0A),y                  ; $8800
  rts                          ; $8802
DuplicateObjectEntry:
  lda z:$0A                    ; $8803
  clc                          ; $8805
  adc #$10                     ; $8806
  sta z:$04                    ; $8808
  lda #$03                     ; $880A
  sta z:$05                    ; $880C
  ldy #$00                     ; $880E
Loc_B6_8810:
  lda ($0A),y                  ; $8810
  sta ($04),y                  ; $8812
  iny                          ; $8814
  cpy #$10                     ; $8815
  bcc Loc_B6_8810              ; $8817
  ldy #$0B                     ; $8819
  lda ($04),y                  ; $881B
  adc #$1C                     ; $881D
  sta ($04),y                  ; $881F
  rts                          ; $8821
Sub_B6_8822:
  ldy #$09                     ; $8822
  jsr GetRandomByte            ; $8824
  and #$70                     ; $8827
  ora ($0A),y                  ; $8829
  sta ($0A),y                  ; $882B
  jsr GetRandomByte            ; $882D
  and #$70                     ; $8830
  ora ($04),y                  ; $8832
  sta ($04),y                  ; $8834
  rts                          ; $8836
  jsr Sub_B6_83F4              ; $8837  [heuristic code]
  ldy #$09                     ; $883A
  lda z:$08                    ; $883C
  bne Loc_B6_8845              ; $883E
  lda #$10                     ; $8840
  jmp Loc_B6_8847              ; $8842
Loc_B6_8845:
  lda #$30                     ; $8845
Loc_B6_8847:
  ora ($0A),y                  ; $8847
  sta ($0A),y                  ; $8849
  ldy #$00                     ; $884B
  lda #$D9                     ; $884D
  sta ($0A),y                  ; $884F
  ldy #$08                     ; $8851
  lda #$0C                     ; $8853
  sta ($0A),y                  ; $8855
  rts                          ; $8857
  jsr Sub_B6_83F4              ; $8858  [heuristic code]
  jsr Sub_B6_886B              ; $885B
  ldy #$00                     ; $885E
  lda #$DB                     ; $8860
  sta ($0A),y                  ; $8862
  ldy #$08                     ; $8864
  lda #$20                     ; $8866
  sta ($0A),y                  ; $8868
  rts                          ; $886A
Sub_B6_886B:
  lda z:$08                    ; $886B
  jsr AslA5                    ; $886D
  sta z:$08                    ; $8870
  jsr GetRandomByte            ; $8872
  and #$10                     ; $8875
  ora z:$08                    ; $8877
  ldy #$09                     ; $8879
  ora ($0A),y                  ; $887B
  sta ($0A),y                  ; $887D
  rts                          ; $887F
  jsr Sub_B6_83F4              ; $8880  [heuristic code]
  ldy #$09                     ; $8883
  lda z:$08                    ; $8885
  jsr AslA4                    ; $8887
  ora ($0A),y                  ; $888A
  sta ($0A),y                  ; $888C
  ldy #$00                     ; $888E
  lda #$DD                     ; $8890
  sta ($0A),y                  ; $8892
  ldy #$08                     ; $8894
  lda #$20                     ; $8896
  sta ($0A),y                  ; $8898
  rts                          ; $889A
  jsr Sub_B6_83F4              ; $889B  [heuristic code]
  ldy #$09                     ; $889E
  lda z:$08                    ; $88A0
  jsr AslA4                    ; $88A2
  ora ($0A),y                  ; $88A5
  sta ($0A),y                  ; $88A7
  ldy #$00                     ; $88A9
  lda #$DF                     ; $88AB
  sta ($0A),y                  ; $88AD
  ldy #$08                     ; $88AF
  lda #$08                     ; $88B1
  sta ($0A),y                  ; $88B3
  lda #$32                     ; $88B5
  jsr QueueSound               ; $88B7
  rts                          ; $88BA
  .incbin "prg_bank_6.bin", $08BB, $54  ; $88BB
Sub_B6_890F:
  jsr Sub_B6_89B2              ; $890F
  ldy #$08                     ; $8912
  lda (Tmp00),y                ; $8914
  bne Loc_B6_8928              ; $8916
  jsr Sub_B6_8A66              ; $8918
  cmp z:$04                    ; $891B
  bcc Loc_B6_8925              ; $891D
  jsr Sub_B6_89DE              ; $891F
  jsr Sub_B6_89B2              ; $8922
Loc_B6_8925:
  jsr Sub_B6_89C0              ; $8925
Loc_B6_8928:
  jsr Sub_B6_8932              ; $8928
  jsr Sub_B6_8A76              ; $892B
  jsr Sub_B6_8B08              ; $892E
  rts                          ; $8931
Sub_B6_8932:
  ldy #$0E                     ; $8932
  lda (Tmp00),y                ; $8934
  asl a                        ; $8936
  asl a                        ; $8937
  sta z:$06                    ; $8938
  inc z:$06                    ; $893A
  tay                          ; $893C
  iny                          ; $893D
  iny                          ; $893E
  lda (Tmp02),y                ; $893F
  and #$E0                     ; $8941
  beq Loc_B6_8948              ; $8943
  jsr Sub_B6_8AD9              ; $8945
Loc_B6_8948:
  ldy z:$06                    ; $8948
  lda (Tmp02),y                ; $894A
  jsr LsrA6                    ; $894C
  beq Loc_B6_8967              ; $894F
  tax                          ; $8951
  lda #$00                     ; $8952
Loc_B6_8954:
  sec                          ; $8954
  rol a                        ; $8955
  dex                          ; $8956
  bne Loc_B6_8954              ; $8957
  sta z:$04                    ; $8959
  lda z:Tmp00                  ; $895B
  jsr LsrA4                    ; $895D
  clc                          ; $8960
  adc z:FrameCounter           ; $8961
  and z:$04                    ; $8963
  bne Loc_B6_89A6              ; $8965
Loc_B6_8967:
  inc z:$06                    ; $8967
  inc z:$06                    ; $8969
  ldy z:$06                    ; $896B
  lda (Tmp02),y                ; $896D
  clc                          ; $896F
  beq Loc_B6_8991              ; $8970
  bpl Loc_B6_8981              ; $8972
  ldy #$0A                     ; $8974
  adc (Tmp00),y                ; $8976
  sta (Tmp00),y                ; $8978
  bcs Loc_B6_8991              ; $897A
  lda #$FF                     ; $897C
  jmp Loc_B6_898B              ; $897E
Loc_B6_8981:
  ldy #$0A                     ; $8981
  adc (Tmp00),y                ; $8983
  sta (Tmp00),y                ; $8985
  bcc Loc_B6_8991              ; $8987
  lda #$01                     ; $8989
Loc_B6_898B:
  dey                          ; $898B
  clc                          ; $898C
  adc (Tmp00),y                ; $898D
  sta (Tmp00),y                ; $898F
Loc_B6_8991:
  ldy z:$06                    ; $8991
  iny                          ; $8993
  lda (Tmp02),y                ; $8994
  clc                          ; $8996
  ldy #$0B                     ; $8997
  adc (Tmp00),y                ; $8999
  sta (Tmp00),y                ; $899B
  ldy #$08                     ; $899D
  lda (Tmp00),y                ; $899F
  sec                          ; $89A1
  sbc #$01                     ; $89A2
  sta (Tmp00),y                ; $89A4
Loc_B6_89A6:
  rts                          ; $89A6
GetObjectBehaviorIndex:
  ldy #$09                     ; $89A7
  lda (Tmp00),y                ; $89A9
  and #$F0                     ; $89AB
  lsr a                        ; $89AD
  lsr a                        ; $89AE
  lsr a                        ; $89AF
  tay                          ; $89B0
  rts                          ; $89B1
Sub_B6_89B2:
  jsr GetObjectBehaviorIndex   ; $89B2
  lda Data_B6_8B14,y           ; $89B5
  sta z:Tmp02                  ; $89B8
  lda Data_B6_8B15,y           ; $89BA
  sta z:Tmp03                  ; $89BD
  rts                          ; $89BF
Sub_B6_89C0:
  ldy #$0E                     ; $89C0
  lda (Tmp00),y                ; $89C2
  asl a                        ; $89C4
  asl a                        ; $89C5
  tay                          ; $89C6
  iny                          ; $89C7
  sty z:$06                    ; $89C8
  lda (Tmp02),y                ; $89CA
  and #$3F                     ; $89CC
  ldy #$08                     ; $89CE
  sta (Tmp00),y                ; $89D0
  ldy z:$06                    ; $89D2
  iny                          ; $89D4
  lda (Tmp02),y                ; $89D5
  and #$1F                     ; $89D7
  ldy #$05                     ; $89D9
  sta (Tmp00),y                ; $89DB
  rts                          ; $89DD
Sub_B6_89DE:
  jsr Sub_B6_8AF4              ; $89DE
  ldy #$0C                     ; $89E1
  lda (Tmp00),y                ; $89E3
  beq Loc_B6_89EB              ; $89E5
  cmp z:$04                    ; $89E7
  bcs Loc_B6_8A0A              ; $89E9
Loc_B6_89EB:
  iny                          ; $89EB
  lda (Tmp00),y                ; $89EC
  beq Loc_B6_89F4              ; $89EE
  cmp z:$04                    ; $89F0
  bcc Loc_B6_8A15              ; $89F2
Loc_B6_89F4:
  jsr GetRandomByte            ; $89F4
  sta z:$08                    ; $89F7
  ldy #$02                     ; $89F9
  lda (Tmp00),y                ; $89FB
  sta z:$05                    ; $89FD
  cmp #$20                     ; $89FF
  bcc Loc_B6_8A0A              ; $8A01
  cmp #$E0                     ; $8A03
  bcs Loc_B6_8A15              ; $8A05
  jmp Loc_B6_8A27              ; $8A07
Loc_B6_8A0A:
  lda z:$08                    ; $8A0A
  and #$07                     ; $8A0C
  cmp #$05                     ; $8A0E
  bcc Loc_B6_8A1D              ; $8A10
  jmp Loc_B6_8A22              ; $8A12
Loc_B6_8A15:
  lda z:$08                    ; $8A15
  and #$07                     ; $8A17
  cmp #$05                     ; $8A19
  bcc Loc_B6_8A22              ; $8A1B
Loc_B6_8A1D:
  lda #$00                     ; $8A1D
  jmp Loc_B6_8A53              ; $8A1F
Loc_B6_8A22:
  lda #$40                     ; $8A22
  jmp Loc_B6_8A53              ; $8A24
Loc_B6_8A27:
  ldy #$09                     ; $8A27
  lda (Tmp00),y                ; $8A29
  and #$40                     ; $8A2B
  sta z:$07                    ; $8A2D
  bne Loc_B6_8A3C              ; $8A2F
  ldy #$02                     ; $8A31
  lda (Tmp00),y                ; $8A33
  cmp #$58                     ; $8A35
  bcc Loc_B6_8A44              ; $8A37
  jmp Loc_B6_8A4F              ; $8A39
Loc_B6_8A3C:
  ldy #$02                     ; $8A3C
  lda (Tmp00),y                ; $8A3E
  cmp #$98                     ; $8A40
  bcc Loc_B6_8A4F              ; $8A42
Loc_B6_8A44:
  lda z:$08                    ; $8A44
  and #$30                     ; $8A46
  bne Loc_B6_8A51              ; $8A48
  lda #$10                     ; $8A4A
  jmp Loc_B6_8A51              ; $8A4C
Loc_B6_8A4F:
  lda #$00                     ; $8A4F
Loc_B6_8A51:
  ora z:$07                    ; $8A51
Loc_B6_8A53:
  sta z:$06                    ; $8A53
  ldy #$09                     ; $8A55
  lda (Tmp00),y                ; $8A57
  and #$0F                     ; $8A59
  ora z:$06                    ; $8A5B
  sta (Tmp00),y                ; $8A5D
  ldy #$0E                     ; $8A5F
  lda #$00                     ; $8A61
  sta (Tmp00),y                ; $8A63
  rts                          ; $8A65
Sub_B6_8A66:
  ldy #$00                     ; $8A66
  lda (Tmp02),y                ; $8A68
  sta z:$04                    ; $8A6A
  ldy #$0E                     ; $8A6C
  lda (Tmp00),y                ; $8A6E
  clc                          ; $8A70
  adc #$01                     ; $8A71
  sta (Tmp00),y                ; $8A73
  rts                          ; $8A75
Sub_B6_8A76:
  ldy #$09                     ; $8A76
  lda (Tmp00),y                ; $8A78
  and #$0F                     ; $8A7A
  sta z:$04                    ; $8A7C
  iny                          ; $8A7E
  lda (Tmp00),y                ; $8A7F
  sec                          ; $8A81
  sbc z:ScrollX                ; $8A82
  sta z:$05                    ; $8A84
  bcs Loc_B6_8A8A              ; $8A86
  dec z:$04                    ; $8A88
Loc_B6_8A8A:
  lda z:$04                    ; $8A8A
  sec                          ; $8A8C
  sbc z:ScrollPage             ; $8A8D
  bne Loc_B6_8AAC              ; $8A8F
  lda z:$05                    ; $8A91
  ldy #$02                     ; $8A93
  sta (Tmp00),y                ; $8A95
  ldy #$0B                     ; $8A97
  lda (Tmp00),y                ; $8A99
  ldy #$01                     ; $8A9B
  sta (Tmp00),y                ; $8A9D
  cmp #$E8                     ; $8A9F
  bcs Loc_B6_8AAC              ; $8AA1
  ldy #$00                     ; $8AA3
  lda (Tmp00),y                ; $8AA5
  ora #$80                     ; $8AA7
  jmp Loc_B6_8AB2              ; $8AA9
Loc_B6_8AAC:
  ldy #$00                     ; $8AAC
  lda (Tmp00),y                ; $8AAE
  and #$7F                     ; $8AB0
Loc_B6_8AB2:
  sta (Tmp00),y                ; $8AB2
  jsr SelectSpriteTable        ; $8AB4
  ldy #$00                     ; $8AB7
  lda (Tmp02),y                ; $8AB9
  and #$1F                     ; $8ABB
  sta z:$06                    ; $8ABD
  ldy #$04                     ; $8ABF
  lda (Tmp00),y                ; $8AC1
  and #$C0                     ; $8AC3
  ora z:$06                    ; $8AC5
  sta (Tmp00),y                ; $8AC7
  asl a                        ; $8AC9
  asl a                        ; $8ACA
  dey                          ; $8ACB
  clc                          ; $8ACC
  adc (Tmp00),y                ; $8ACD
  bcc Loc_B6_8AD8              ; $8ACF
  lda #$00                     ; $8AD1
  sta (Tmp00),y                ; $8AD3
  iny                          ; $8AD5
  sta (Tmp00),y                ; $8AD6
Loc_B6_8AD8:
  rts                          ; $8AD8
Sub_B6_8AD9:
  jsr LsrA5                    ; $8AD9
  tax                          ; $8ADC
  lda #$00                     ; $8ADD
  sec                          ; $8ADF
Loc_B6_8AE0:
  rol a                        ; $8AE0
  dex                          ; $8AE1
  bne Loc_B6_8AE0              ; $8AE2
  and z:FrameCounter           ; $8AE4
  beq Loc_B6_8AEA              ; $8AE6
  lda #$01                     ; $8AE8
Loc_B6_8AEA:
  clc                          ; $8AEA
  adc (Tmp02),y                ; $8AEB
  and #$1F                     ; $8AED
  ldy #$05                     ; $8AEF
  sta (Tmp00),y                ; $8AF1
  rts                          ; $8AF3
Sub_B6_8AF4:
  ldy #$09                     ; $8AF4
  lda (Tmp00),y                ; $8AF6
  jsr AslA4                    ; $8AF8
  sta z:$04                    ; $8AFB
  iny                          ; $8AFD
  lda (Tmp00),y                ; $8AFE
  jsr LsrA4                    ; $8B00
  ora z:$04                    ; $8B03
  sta z:$04                    ; $8B05
  rts                          ; $8B07
Sub_B6_8B08:
  ldy #$00                     ; $8B08
  lda (Tmp00),y                ; $8B0A
  and #$80                     ; $8B0C
  bne Loc_B6_8B13              ; $8B0E
  jsr RemoveObject             ; $8B10
Loc_B6_8B13:
  rts                          ; $8B13
Data_B6_8B14:
  .incbin "prg_bank_6.bin", $0B14, $1  ; $8B14
Data_B6_8B15:
  .incbin "prg_bank_6.bin", $0B15, $87  ; $8B15
Sub_B6_8B9C:
  jsr GetRandomByte            ; $8B9C
  sta z:$08                    ; $8B9F
  ldy #$01                     ; $8BA1
  lda (Tmp00),y                ; $8BA3
  sta z:$04                    ; $8BA5
  iny                          ; $8BA7
  lda (Tmp00),y                ; $8BA8
  sta z:$05                    ; $8BAA
  cmp #$28                     ; $8BAC
  bcs Loc_B6_8BB3              ; $8BAE
  jmp Loc_B6_8A0A              ; $8BB0
Loc_B6_8BB3:
  cmp #$C0                     ; $8BB3
  bcc Loc_B6_8BBA              ; $8BB5
  jmp Loc_B6_8A15              ; $8BB7
Loc_B6_8BBA:
  ldy #$09                     ; $8BBA
  lda (Tmp00),y                ; $8BBC
  and #$40                     ; $8BBE
  sta z:$07                    ; $8BC0
  lda z:$04                    ; $8BC2
  cmp #$24                     ; $8BC4
  bcc Loc_B6_8BDB              ; $8BC6
  cmp #$A8                     ; $8BC8
  bcs Loc_B6_8BD4              ; $8BCA
  lda PlayerSpriteY0           ; $8BCC
  sec                          ; $8BCF
  sbc z:$04                    ; $8BD0
  bcs Loc_B6_8BDB              ; $8BD2
Loc_B6_8BD4:
  lda z:$08                    ; $8BD4
  and #$10                     ; $8BD6
  jmp Loc_B6_8BE1              ; $8BD8
Loc_B6_8BDB:
  lda z:$08                    ; $8BDB
  and #$10                     ; $8BDD
  ora #$20                     ; $8BDF
Loc_B6_8BE1:
  ora z:$07                    ; $8BE1
  jmp Loc_B6_8A53              ; $8BE3
Sub_B6_8BE6:
  ldy #$0B                     ; $8BE6
  lda (Tmp00),y                ; $8BE8
  cmp #$24                     ; $8BEA
  bcs Loc_B6_8BF2              ; $8BEC
  lda #$24                     ; $8BEE
  sta (Tmp00),y                ; $8BF0
Loc_B6_8BF2:
  rts                          ; $8BF2
  .incbin "prg_bank_6.bin", $0BF3, $400  ; $8BF3
  .incbin "prg_bank_6.bin", $0FF3, $400  ; $8FF3
  .incbin "prg_bank_6.bin", $13F3, $67  ; $93F3
Sub_B6_945A:
  jsr Sub_B6_9489              ; $945A
  ldy #$08                     ; $945D
  lda (Tmp00),y                ; $945F
  bne Loc_B6_9479              ; $9461
  jsr Sub_B6_8A66              ; $9463
  cmp z:$04                    ; $9466
  bcc Loc_B6_9473              ; $9468
  jsr Sub_B6_8B9C              ; $946A
  jsr Sub_B6_9497              ; $946D
  jsr Sub_B6_9489              ; $9470
Loc_B6_9473:
  jsr Sub_B6_89C0              ; $9473
  jsr Sub_B6_95EE              ; $9476
Loc_B6_9479:
  jsr Sub_B6_8932              ; $9479
  jsr Sub_B6_8BE6              ; $947C
  jsr Sub_B6_8A76              ; $947F
  jsr Sub_B6_8B08              ; $9482
  jsr Sub_B6_9621              ; $9485
  rts                          ; $9488
Sub_B6_9489:
  jsr GetObjectBehaviorIndex   ; $9489
  lda Data_B6_94BE,y           ; $948C
  sta z:Tmp02                  ; $948F
  lda Data_B6_94BF,y           ; $9491
  sta z:Tmp03                  ; $9494
  rts                          ; $9496
Sub_B6_9497:
  ldy #$02                     ; $9497
  lda (Tmp00),y                ; $9499
  tax                          ; $949B
  ldy #$09                     ; $949C
  lda (Tmp00),y                ; $949E
  and #$40                     ; $94A0
  bne Loc_B6_94AD              ; $94A2
  cpx #$50                     ; $94A4
  bcc Loc_B6_94BD              ; $94A6
  lda #$00                     ; $94A8
  jmp Loc_B6_94B3              ; $94AA
Loc_B6_94AD:
  cpx #$A0                     ; $94AD
  bcs Loc_B6_94BD              ; $94AF
  lda #$40                     ; $94B1
Loc_B6_94B3:
  sta z:$07                    ; $94B3
  lda (Tmp00),y                ; $94B5
  and #$0F                     ; $94B7
  ora z:$07                    ; $94B9
  sta (Tmp00),y                ; $94BB
Loc_B6_94BD:
  rts                          ; $94BD
Data_B6_94BE:
  .incbin "prg_bank_6.bin", $14BE, $1  ; $94BE
Data_B6_94BF:
  .incbin "prg_bank_6.bin", $14BF, $12F  ; $94BF
Sub_B6_95EE:
  ldy #$0E                     ; $95EE
  lda (Tmp00),y                ; $95F0
  cmp #$05                     ; $95F2
  beq Loc_B6_95FA              ; $95F4
  cmp #$07                     ; $95F6
  bne Loc_B6_9620              ; $95F8
Loc_B6_95FA:
  jsr GetRandomByte            ; $95FA
  and #$07                     ; $95FD
  cmp #$03                     ; $95FF
  bcs Loc_B6_9620              ; $9601
  ldy #$02                     ; $9603
  lda (Tmp00),y                ; $9605
  sec                          ; $9607
  sbc PlayerSpriteX0           ; $9608
  bcs Loc_B6_9612              ; $960B
  lda #$00                     ; $960D
  jmp Loc_B6_9614              ; $960F
Loc_B6_9612:
  lda #$40                     ; $9612
Loc_B6_9614:
  sta z:$04                    ; $9614
  ldy #$09                     ; $9616
  lda (Tmp00),y                ; $9618
  and #$3F                     ; $961A
  ora z:$04                    ; $961C
  sta (Tmp00),y                ; $961E
Loc_B6_9620:
  rts                          ; $9620
Sub_B6_9621:
  lda ObjectCount              ; $9621
  cmp #$0D                     ; $9624
  bcs Loc_B6_9655              ; $9626
  ldy #$08                     ; $9628
  lda (Tmp00),y                ; $962A
  cmp #$17                     ; $962C
  bne Loc_B6_9655              ; $962E
  iny                          ; $9630
  lda (Tmp00),y                ; $9631
  and #$F0                     ; $9633
  beq Loc_B6_9655              ; $9635
  cmp #$40                     ; $9637
  beq Loc_B6_9655              ; $9639
  ldy #$0E                     ; $963B
  cmp #$30                     ; $963D
  beq Loc_B6_964F              ; $963F
  cmp #$70                     ; $9641
  beq Loc_B6_964F              ; $9643
  lda (Tmp00),y                ; $9645
  cmp #$08                     ; $9647
  beq Loc_B6_9656              ; $9649
  cmp #$06                     ; $964B
  beq Loc_B6_9656              ; $964D
Loc_B6_964F:
  lda (Tmp00),y                ; $964F
  cmp #$04                     ; $9651
  beq Loc_B6_9656              ; $9653
Loc_B6_9655:
  rts                          ; $9655
Loc_B6_9656:
  inc ObjectCount              ; $9656
  lda ObjectCount              ; $9659
  jsr AslA4                    ; $965C
  sta z:$0A                    ; $965F
  lda #$03                     ; $9661
  sta z:$0B                    ; $9663
  ldy #$0B                     ; $9665
  lda (Tmp00),y                ; $9667
  sta ($0A),y                  ; $9669
  ldy #$09                     ; $966B
  lda (Tmp00),y                ; $966D
  iny                          ; $966F
  and #$40                     ; $9670
  beq Loc_B6_9687              ; $9672
  lda (Tmp00),y                ; $9674
  sec                          ; $9676
  sbc #$08                     ; $9677
  sta ($0A),y                  ; $9679
  dey                          ; $967B
  lda (Tmp00),y                ; $967C
  sbc #$00                     ; $967E
  and #$0F                     ; $9680
  ldx #$00                     ; $9682
  jmp Loc_B6_9699              ; $9684
Loc_B6_9687:
  lda (Tmp00),y                ; $9687
  clc                          ; $9689
  adc #$10                     ; $968A
  sta ($0A),y                  ; $968C
  dey                          ; $968E
  lda (Tmp00),y                ; $968F
  adc #$00                     ; $9691
  and #$0F                     ; $9693
  ora #$10                     ; $9695
  ldx #$01                     ; $9697
Loc_B6_9699:
  sta ($0A),y                  ; $9699
  ldy #$05                     ; $969B
  txa                          ; $969D
  sta ($0A),y                  ; $969E
  ldy #$00                     ; $96A0
  lda #$DC                     ; $96A2
  sta ($0A),y                  ; $96A4
  ldy #$08                     ; $96A6
  lda #$3F                     ; $96A8
  sta ($0A),y                  ; $96AA
  ldy #$06                     ; $96AC
  lda #$01                     ; $96AE
  sta ($0A),y                  ; $96B0
  lda #$0F                     ; $96B2
  jsr QueueSound               ; $96B4
  rts                          ; $96B7
  jsr Sub_B6_96D4              ; $96B8  [heuristic code]
  ldy #$08                     ; $96BB
  lda (Tmp00),y                ; $96BD
  bne Loc_B6_96C7              ; $96BF
  jsr Sub_B6_8A66              ; $96C1
  jsr Sub_B6_89C0              ; $96C4
Loc_B6_96C7:
  jsr Sub_B6_8932              ; $96C7
  jsr Sub_B6_8A76              ; $96CA
  jsr Sub_B6_8B08              ; $96CD
  jsr Sub_B6_975A              ; $96D0
  rts                          ; $96D3
Sub_B6_96D4:
  jsr GetObjectBehaviorIndex   ; $96D4
  lda Data_B6_96E2,y           ; $96D7
  sta z:Tmp02                  ; $96DA
  lda Data_B6_96E3,y           ; $96DC
  sta z:Tmp03                  ; $96DF
  rts                          ; $96E1
Data_B6_96E2:
  .incbin "prg_bank_6.bin", $16E2, $1  ; $96E2
Data_B6_96E3:
  .incbin "prg_bank_6.bin", $16E3, $77  ; $96E3
Sub_B6_975A:
  lda ObjectCount              ; $975A
  cmp #$08                     ; $975D
  bcs Loc_B6_9787              ; $975F
  ldy #$02                     ; $9761
  lda (Tmp00),y                ; $9763
  cmp #$D0                     ; $9765
  bcs Loc_B6_9787              ; $9767
  sec                          ; $9769
  sbc PlayerSpriteX0           ; $976A
  tax                          ; $976D
  lda z:Tmp00                  ; $976E
  and #$10                     ; $9770
  bne Loc_B6_977F              ; $9772
  cpx #$34                     ; $9774
  bcc Loc_B6_9787              ; $9776
  cpx #$3A                     ; $9778
  bcs Loc_B6_9787              ; $977A
  jmp Loc_B6_9788              ; $977C
Loc_B6_977F:
  cpx #$3C                     ; $977F
  bcc Loc_B6_9787              ; $9781
  cpx #$42                     ; $9783
  bcc Loc_B6_9788              ; $9785
Loc_B6_9787:
  rts                          ; $9787
Loc_B6_9788:
  ldy #$09                     ; $9788
  lda (Tmp00),y                ; $978A
  and #$70                     ; $978C
  bne Loc_B6_9795              ; $978E
  lda #$20                     ; $9790
  jmp Loc_B6_97A0              ; $9792
Loc_B6_9795:
  cmp #$40                     ; $9795
  bcs Loc_B6_979E              ; $9797
  lda #$00                     ; $9799
  jmp Loc_B6_97A0              ; $979B
Loc_B6_979E:
  lda #$40                     ; $979E
Loc_B6_97A0:
  sta z:$06                    ; $97A0
  jsr GetRandomByte            ; $97A2
  and #$30                     ; $97A5
  clc                          ; $97A7
  adc z:$06                    ; $97A8
  sta z:$06                    ; $97AA
  lda ObjectCount              ; $97AC
  jsr AslA4                    ; $97AF
  tax                          ; $97B2
  inc ObjectCount              ; $97B3
  inc ObjectCount              ; $97B6
  inc ObjectCount              ; $97B9
  lda #$CD                     ; $97BC
  sta ObjectTable,x            ; $97BE
  sta $0320,x                  ; $97C1
  sta $0330,x                  ; $97C4
  ldy #$0B                     ; $97C7
  lda (Tmp00),y                ; $97C9
  adc #$08                     ; $97CB
  sta $031B,x                  ; $97CD
  sta $032B,x                  ; $97D0
  sta $033B,x                  ; $97D3
  dey                          ; $97D6
  lda (Tmp00),y                ; $97D7
  sta $031A,x                  ; $97D9
  sta $032A,x                  ; $97DC
  sta $033A,x                  ; $97DF
  dey                          ; $97E2
  lda (Tmp00),y                ; $97E3
  and #$0F                     ; $97E5
  ora z:$06                    ; $97E7
  sta $0319,x                  ; $97E9
  clc                          ; $97EC
  adc #$10                     ; $97ED
  sta $0329,x                  ; $97EF
  clc                          ; $97F2
  adc #$10                     ; $97F3
  sta $0339,x                  ; $97F5
  lda #$3F                     ; $97F8
  sta $0318,x                  ; $97FA
  lda #$26                     ; $97FD
  sta $0328,x                  ; $97FF
  lda #$13                     ; $9802
  sta $0338,x                  ; $9804
  lda #$00                     ; $9807
  sta $031E,x                  ; $9809
  sta $032E,x                  ; $980C
  sta $033E,x                  ; $980F
  lda #$01                     ; $9812
  sta $0316,x                  ; $9814
  sta $0326,x                  ; $9817
  sta $0336,x                  ; $981A
  rts                          ; $981D
  .incbin "prg_bank_6.bin", $181E, $1F6  ; $981E
  jsr Sub_B6_9A38              ; $9A14
  ldy #$08                     ; $9A17
  lda (Tmp00),y                ; $9A19
  bne Loc_B6_9A2E              ; $9A1B
  jsr Sub_B6_8A66              ; $9A1D
  cmp z:$04                    ; $9A20
  bcc Loc_B6_9A28              ; $9A22
  jsr RemoveObject             ; $9A24
  rts                          ; $9A27
Loc_B6_9A28:
  jsr Sub_B6_89C0              ; $9A28
  jsr Sub_B6_9A38              ; $9A2B
Loc_B6_9A2E:
  jsr Sub_B6_8932              ; $9A2E
  jsr Sub_B6_8A76              ; $9A31
  jsr Sub_B6_8B08              ; $9A34
  rts                          ; $9A37
Sub_B6_9A38:
  jsr GetObjectBehaviorIndex   ; $9A38
  lda Data_B6_9A46,y           ; $9A3B
  sta z:Tmp02                  ; $9A3E
  lda Data_B6_9A47,y           ; $9A40
  sta z:Tmp03                  ; $9A43
  rts                          ; $9A45
Data_B6_9A46:
  .incbin "prg_bank_6.bin", $1A46, $1  ; $9A46
Data_B6_9A47:
  .incbin "prg_bank_6.bin", $1A47, $400  ; $9A47
  .incbin "prg_bank_6.bin", $1E47, $252  ; $9E47
Sub_B6_A099:
  jsr Sub_B6_A0A6              ; $A099
  jsr Sub_B6_8932              ; $A09C
  jsr Sub_B6_8A76              ; $A09F
  jsr Sub_B6_8B08              ; $A0A2
  rts                          ; $A0A5
Sub_B6_A0A6:
  jsr GetObjectBehaviorIndex   ; $A0A6
  lda Data_B6_A0B4,y           ; $A0A9
  sta z:Tmp02                  ; $A0AC
  lda Data_B6_A0B5,y           ; $A0AE
  sta z:Tmp03                  ; $A0B1
  rts                          ; $A0B3
Data_B6_A0B4:
  .incbin "prg_bank_6.bin", $20B4, $1  ; $A0B4
Data_B6_A0B5:
  .incbin "prg_bank_6.bin", $20B5, $400  ; $A0B5
  .incbin "prg_bank_6.bin", $24B5, $400  ; $A4B5
  .incbin "prg_bank_6.bin", $28B5, $400  ; $A8B5
  .incbin "prg_bank_6.bin", $2CB5, $400  ; $ACB5
  .incbin "prg_bank_6.bin", $30B5, $400  ; $B0B5
  .incbin "prg_bank_6.bin", $34B5, $4B  ; $B4B5
Data_B6_B500:
  .incbin "prg_bank_6.bin", $3500, $1  ; $B500
Data_B6_B501:
  .incbin "prg_bank_6.bin", $3501, $400  ; $B501
  .incbin "prg_bank_6.bin", $3901, $400  ; $B901
  .incbin "prg_bank_6.bin", $3D01, $2FC  ; $BD01
Data_B6_BFFD:
  .incbin "prg_bank_6.bin", $3FFD, $3  ; $BFFD
