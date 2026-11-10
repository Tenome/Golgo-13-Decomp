; Bank 3  ($8000-$BFFF switchable)
; Dialogue and briefing scenes (portrait text boxes).
.segment "PRG_BANK_3"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B3_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_3.bin", $0009, $7  ; $8009
Bank3Nmi:
  pha                          ; $8010
  txa                          ; $8011
  pha                          ; $8012
  tya                          ; $8013
  pha                          ; $8014
  jsr TickClock                ; $8015
  lda $0402                    ; $8018
  cmp #$01                     ; $801B
  bne Loc_B3_8032              ; $801D
  jsr Bank3Dispatch_0421       ; $801F
  jsr ApplyScroll              ; $8022
  lda $0421                    ; $8025
  cmp #$03                     ; $8028
  bne Loc_B3_802F              ; $802A
  jsr Sub_B3_8E29              ; $802C
Loc_B3_802F:
  jmp Loc_B3_8074              ; $802F
Loc_B3_8032:
  lda $0410                    ; $8032
  bne Loc_B3_803D              ; $8035
  jsr Sub_B3_8D23              ; $8037
  jmp Loc_B3_8074              ; $803A
Loc_B3_803D:
  cmp #$01                     ; $803D
  bne Loc_B3_8047              ; $803F
  jsr Sub_B3_8D71              ; $8041
  jmp Loc_B3_8071              ; $8044
Loc_B3_8047:
  cmp #$02                     ; $8047
  bne Loc_B3_8051              ; $8049
  jsr Sub_B3_8C06              ; $804B
  jmp Loc_B3_8071              ; $804E
Loc_B3_8051:
  jsr DoOamDma                 ; $8051
  lda $0410                    ; $8054
  cmp #$03                     ; $8057
  bne Loc_B3_8061              ; $8059
  jsr Sub_B3_8A5B              ; $805B
  jmp Loc_B3_8071              ; $805E
Loc_B3_8061:
  cmp #$04                     ; $8061
  bne Loc_B3_8074              ; $8063
  jsr Sub_B3_831D              ; $8065
  jsr ApplyScroll              ; $8068
  jsr ReadJoypads              ; $806B
  jsr Sub_B3_83D8              ; $806E
Loc_B3_8071:
  jsr ApplyScroll              ; $8071
Loc_B3_8074:
  lda z:MmcPrgShadow           ; $8074
  beq Loc_B3_807B              ; $8076
  jsr CallBank5_A000           ; $8078
Loc_B3_807B:
  pla                          ; $807B
  tay                          ; $807C
  pla                          ; $807D
  tax                          ; $807E
  pla                          ; $807F
  rti                          ; $8080
Bank3Dispatch_0421:
  lda $0421                    ; $8081
  asl a                        ; $8084
  tay                          ; $8085
  lda Data_B3_82D7,y           ; $8086
  sta z:Tmp00                  ; $8089
  iny                          ; $808B
  lda Data_B3_82D7,y           ; $808C
  sta z:Tmp01                  ; $808F
  jmp ($0000)                  ; $8091
  jsr Sub_B3_8270              ; $8094
  lda #$00                     ; $8097
  sta $0422                    ; $8099
  inc $0421                    ; $809C
  lda z:PpuCtrlShadow          ; $809F
  and #$FB                     ; $80A1
  sta z:PpuCtrlShadow          ; $80A3
  sta PPU_CTRL                 ; $80A5
  lda #$10                     ; $80A8
  sta z:Tmp00                  ; $80AA
  ldy $0422                    ; $80AC
  lda PPU_STATUS               ; $80AF
  lda #$20                     ; $80B2
  sta PPU_ADDR                 ; $80B4
  lda $0425                    ; $80B7
  sta PPU_ADDR                 ; $80BA
  and #$1F                     ; $80BD
  sta z:Tmp02                  ; $80BF
  lda PPU_DATA                 ; $80C1
Loc_B3_80C4:
  lda PPU_DATA                 ; $80C4
  sta $0440,y                  ; $80C7
  iny                          ; $80CA
  inc z:Tmp02                  ; $80CB
  lda z:Tmp02                  ; $80CD
  cmp #$20                     ; $80CF
  bne Loc_B3_80E7              ; $80D1
  lda #$00                     ; $80D3
  sta z:Tmp02                  ; $80D5
  lda #$20                     ; $80D7
  sta PPU_ADDR                 ; $80D9
  lda #$E0                     ; $80DC
  and $0425                    ; $80DE
  sta PPU_ADDR                 ; $80E1
  lda PPU_DATA                 ; $80E4
Loc_B3_80E7:
  dec z:Tmp00                  ; $80E7
  bne Loc_B3_80C4              ; $80E9
  lda #$20                     ; $80EB
  clc                          ; $80ED
  adc $0425                    ; $80EE
  sta $0425                    ; $80F1
  lda #$00                     ; $80F4
  adc $0426                    ; $80F6
  sta $0426                    ; $80F9
  sty $0422                    ; $80FC
  cpy #$40                     ; $80FF
  beq Loc_B3_8106              ; $8101
  jmp Loc_B3_826F              ; $8103
Loc_B3_8106:
  lda PPU_STATUS               ; $8106
  lda #$23                     ; $8109
  sta PPU_ADDR                 ; $810B
  lda #$C8                     ; $810E
  sta PPU_ADDR                 ; $8110
  lda PPU_DATA                 ; $8113
  ldy #$00                     ; $8116
Loc_B3_8118:
  lda PPU_DATA                 ; $8118
  sta $0480,y                  ; $811B
  iny                          ; $811E
  cpy #$08                     ; $811F
  bne Loc_B3_8118              ; $8121
  inc $0421                    ; $8123
  lda #$00                     ; $8126
  sta $0422                    ; $8128
  lda $0422                    ; $812B
  bne Loc_B3_8139              ; $812E
  lda #$00                     ; $8130
  sta z:Tmp00                  ; $8132
  ldy #$00                     ; $8134
  jmp Loc_B3_815D              ; $8136
Loc_B3_8139:
  cmp #$01                     ; $8139
  bne Loc_B3_8146              ; $813B
  lda #$20                     ; $813D
  sta z:Tmp00                  ; $813F
  ldy #$10                     ; $8141
  jmp Loc_B3_815D              ; $8143
Loc_B3_8146:
  cmp #$02                     ; $8146
  bne Loc_B3_8153              ; $8148
  lda #$40                     ; $814A
  sta z:Tmp00                  ; $814C
  ldy #$10                     ; $814E
  jmp Loc_B3_815D              ; $8150
Loc_B3_8153:
  cmp #$03                     ; $8153
  bne Loc_B3_816A              ; $8155
  lda #$60                     ; $8157
  sta z:Tmp00                  ; $8159
  ldy #$20                     ; $815B
Loc_B3_815D:
  lda #$00                     ; $815D
  sta z:$05                    ; $815F
  jsr Sub_B3_828B              ; $8161
  inc $0422                    ; $8164
  jmp Loc_B3_826F              ; $8167
Loc_B3_816A:
  lda $042E                    ; $816A
  sta z:Tmp00                  ; $816D
  lda #$04                     ; $816F
  sta z:Tmp01                  ; $8171
Loc_B3_8173:
  lda PPU_STATUS               ; $8173
  lda #$23                     ; $8176
  sta PPU_ADDR                 ; $8178
  lda #$C8                     ; $817B
  clc                          ; $817D
  adc z:Tmp00                  ; $817E
  sta PPU_ADDR                 ; $8180
  lda #$FF                     ; $8183
  sta PPU_DATA                 ; $8185
  inc z:Tmp00                  ; $8188
  lda #$07                     ; $818A
  and z:Tmp00                  ; $818C
  sta z:Tmp00                  ; $818E
  dec z:Tmp01                  ; $8190
  bne Loc_B3_8173              ; $8192
  inc $0421                    ; $8194
  lda #$00                     ; $8197
  sta $0422                    ; $8199
  lda $0427                    ; $819C
  bne Loc_B3_81A4              ; $819F
  jmp Loc_B3_826F              ; $81A1
Loc_B3_81A4:
  lda #$00                     ; $81A4
  sta $041F                    ; $81A6
  lda z:PpuCtrlShadow          ; $81A9
  ora #$04                     ; $81AB
  sta z:PpuCtrlShadow          ; $81AD
  sta PPU_CTRL                 ; $81AF
  lda PPU_STATUS               ; $81B2
  lda #$20                     ; $81B5
  sta PPU_ADDR                 ; $81B7
  lda $0425                    ; $81BA
  sta PPU_ADDR                 ; $81BD
  lda $0423                    ; $81C0
  sta PPU_DATA                 ; $81C3
  lda $0424                    ; $81C6
  sta PPU_DATA                 ; $81C9
  lda $0425                    ; $81CC
  and #$1F                     ; $81CF
  cmp #$1F                     ; $81D1
  bne Loc_B3_81E0              ; $81D3
  lda $0425                    ; $81D5
  and #$E0                     ; $81D8
  sta $0425                    ; $81DA
  jmp Loc_B3_81E3              ; $81DD
Loc_B3_81E0:
  inc $0425                    ; $81E0
Loc_B3_81E3:
  lda #$00                     ; $81E3
  sta $0427                    ; $81E5
  lda #$FF                     ; $81E8
  sta $0423                    ; $81EA
  jmp Loc_B3_826F              ; $81ED
  inc $041F                    ; $81F0
  lda $041F                    ; $81F3
  cmp #$0E                     ; $81F6
  bcs Loc_B3_81FD              ; $81F8
  jmp Loc_B3_826F              ; $81FA
Loc_B3_81FD:
  lda #$00                     ; $81FD
  sta $041F                    ; $81FF
  sta $0422                    ; $8202
  inc $0421                    ; $8205
  jmp Loc_B3_826F              ; $8208
  lda #$00                     ; $820B
  jmp Loc_B3_821C              ; $820D
  lda #$20                     ; $8210
  jmp Loc_B3_821C              ; $8212
  lda #$40                     ; $8215
  jmp Loc_B3_821C              ; $8217
  lda #$60                     ; $821A
Loc_B3_821C:
  sta z:Tmp00                  ; $821C
  lda #$FF                     ; $821E
  sta z:$05                    ; $8220
  jsr Sub_B3_828B              ; $8222
  inc $0421                    ; $8225
  jmp Loc_B3_826F              ; $8228
  lda z:PpuCtrlShadow          ; $822B
  and #$FB                     ; $822D
  sta z:PpuCtrlShadow          ; $822F
  sta PPU_CTRL                 ; $8231
  lda $042E                    ; $8234
  sta z:Tmp00                  ; $8237
  lda #$04                     ; $8239
  sta z:Tmp01                  ; $823B
Loc_B3_823D:
  lda PPU_STATUS               ; $823D
  lda #$23                     ; $8240
  sta PPU_ADDR                 ; $8242
  lda #$C8                     ; $8245
  clc                          ; $8247
  adc z:Tmp00                  ; $8248
  sta PPU_ADDR                 ; $824A
Loc_B3_824D:
  ldy z:Tmp00                  ; $824D
  lda $0480,y                  ; $824F
  sta PPU_DATA                 ; $8252
  dec z:Tmp01                  ; $8255
  beq Loc_B3_8266              ; $8257
  inc z:Tmp00                  ; $8259
  lda #$07                     ; $825B
  and z:Tmp00                  ; $825D
  sta z:Tmp00                  ; $825F
  beq Loc_B3_823D              ; $8261
  jmp Loc_B3_824D              ; $8263
Loc_B3_8266:
  inc $0421                    ; $8266
  jmp Loc_B3_826F              ; $8269
  jsr Sub_B3_8EC6              ; $826C
Loc_B3_826F:
  rts                          ; $826F
Sub_B3_8270:
  lda z:ScrollX                ; $8270
  and #$E0                     ; $8272
  lsr a                        ; $8274
  lsr a                        ; $8275
  lsr a                        ; $8276
  clc                          ; $8277
  adc #$88                     ; $8278
  and #$DF                     ; $827A
  clc                          ; $827C
  sta $042D                    ; $827D
  sta $0425                    ; $8280
  and #$1F                     ; $8283
  lsr a                        ; $8285
  lsr a                        ; $8286
  sta $042E                    ; $8287
  rts                          ; $828A
Sub_B3_828B:
  lda z:PpuCtrlShadow          ; $828B
  and #$FB                     ; $828D
  sta z:PpuCtrlShadow          ; $828F
  sta PPU_CTRL                 ; $8291
  lda z:Tmp00                  ; $8294
  clc                          ; $8296
  adc $042D                    ; $8297
  sta z:Tmp01                  ; $829A
  and #$1F                     ; $829C
  sta z:Tmp02                  ; $829E
  lda #$10                     ; $82A0
  sta z:Tmp03                  ; $82A2
  lda #$20                     ; $82A4
  sta PPU_ADDR                 ; $82A6
  lda z:Tmp01                  ; $82A9
  sta PPU_ADDR                 ; $82AB
Loc_B3_82AE:
  lda z:$05                    ; $82AE
  bmi Loc_B3_82B8              ; $82B0
  lda Data_B3_82ED,y           ; $82B2
  jmp Loc_B3_82BA              ; $82B5
Loc_B3_82B8:
  lda #$FF                     ; $82B8
Loc_B3_82BA:
  sta PPU_DATA                 ; $82BA
  iny                          ; $82BD
  inc z:Tmp02                  ; $82BE
  lda z:Tmp02                  ; $82C0
  cmp #$20                     ; $82C2
  bne Loc_B3_82D2              ; $82C4
  lda #$20                     ; $82C6
  sta PPU_ADDR                 ; $82C8
  lda #$E0                     ; $82CB
  and z:Tmp01                  ; $82CD
  sta PPU_ADDR                 ; $82CF
Loc_B3_82D2:
  dec z:Tmp03                  ; $82D2
  bne Loc_B3_82AE              ; $82D4
  rts                          ; $82D6
Data_B3_82D7:
  .incbin "prg_bank_3.bin", $02D7, $16  ; $82D7
Data_B3_82ED:
  .incbin "prg_bank_3.bin", $02ED, $30  ; $82ED
Sub_B3_831D:
  lda $0412                    ; $831D
  bne Loc_B3_832D              ; $8320
  lda $041C                    ; $8322
  beq Loc_B3_832A              ; $8325
  jsr Bank3Dispatch_041C       ; $8327
Loc_B3_832A:
  jmp Loc_B3_8370              ; $832A
Loc_B3_832D:
  lda z:PpuCtrlShadow          ; $832D
  ora #$04                     ; $832F
  sta z:PpuCtrlShadow          ; $8331
  sta PPU_CTRL                 ; $8333
  lda #$CB                     ; $8336
  sta z:Tmp00                  ; $8338
  lda #$28                     ; $833A
  sta z:Tmp01                  ; $833C
  lda z:$72                    ; $833E
  clc                          ; $8340
  adc z:Tmp00                  ; $8341
  sta z:Tmp00                  ; $8343
  lda #$00                     ; $8345
  adc z:Tmp01                  ; $8347
  sta z:Tmp01                  ; $8349
  lda PPU_STATUS               ; $834B
  lda z:Tmp01                  ; $834E
  sta PPU_ADDR                 ; $8350
  lda z:Tmp00                  ; $8353
  sta PPU_ADDR                 ; $8355
  lda $0419                    ; $8358
  sta PPU_DATA                 ; $835B
  lda $041A                    ; $835E
  sta PPU_DATA                 ; $8361
  lda #$00                     ; $8364
  sta $0412                    ; $8366
  lda #$FF                     ; $8369
  sta $0419                    ; $836B
  inc z:$72                    ; $836E
Loc_B3_8370:
  rts                          ; $8370
Bank3Dispatch_041C:
  dec $041C                    ; $8371
  lda $041C                    ; $8374
  asl a                        ; $8377
  asl a                        ; $8378
  asl a                        ; $8379
  sta z:Tmp00                  ; $837A
  inc $041C                    ; $837C
  lda #$8F                     ; $837F
  clc                          ; $8381
  adc z:Tmp00                  ; $8382
  sta z:Tmp00                  ; $8384
  lda #$00                     ; $8386
  adc #$83                     ; $8388
  sta z:Tmp01                  ; $838A
  jmp ($0000)                  ; $838C
  jsr ProcessPpuUpdateList     ; $838F
  .addr Data_B3_83BD  ; $8392 inline pointer (data after a JSR)
  jmp Loc_B3_83A4              ; $8394
  jsr ProcessPpuUpdateList     ; $8397
  .addr Data_B3_83C6  ; $839A inline pointer (data after a JSR)
  jmp Loc_B3_83A4              ; $839C
  jsr ProcessPpuUpdateList     ; $839F
  .addr Data_B3_83CF  ; $83A2 inline pointer (data after a JSR)
Loc_B3_83A4:
  ldy #$2D                     ; $83A4
  lda #$FF                     ; $83A6
  sta ($5C),y                  ; $83A8
  inc $041C                    ; $83AA
  lda $041C                    ; $83AD
  cmp #$04                     ; $83B0
  bne Loc_B3_83BC              ; $83B2
  lda #$00                     ; $83B4
  sta $041C                    ; $83B6
  sta $0418                    ; $83B9
Loc_B3_83BC:
  rts                          ; $83BC
Data_B3_83BD:
  .incbin "prg_bank_3.bin", $03BD, $9  ; $83BD
Data_B3_83C6:
  .incbin "prg_bank_3.bin", $03C6, $9  ; $83C6
Data_B3_83CF:
  .incbin "prg_bank_3.bin", $03CF, $9  ; $83CF
Sub_B3_83D8:
  lda $0411                    ; $83D8
  beq Loc_B3_8427              ; $83DB
  lda $041C                    ; $83DD
  beq Loc_B3_83E5              ; $83E0
  jmp Loc_B3_85AC              ; $83E2
Loc_B3_83E5:
  jsr Sub_B3_872B              ; $83E5
  lda $0411                    ; $83E8
  cmp #$02                     ; $83EB
  beq Loc_B3_8446              ; $83ED
  lda $0418                    ; $83EF
  bne Loc_B3_83F7              ; $83F2
  jmp Loc_B3_846B              ; $83F4
Loc_B3_83F7:
  and #$0F                     ; $83F7
  cmp #$03                     ; $83F9
  bcs Loc_B3_8418              ; $83FB
  sta z:Tmp00                  ; $83FD
  lda JoyHeld1                 ; $83FF
  and #$02                     ; $8402
  beq Loc_B3_8416              ; $8404
  ldx $0400                    ; $8406
  lda Data_B3_883F,x           ; $8409
  and #$3F                     ; $840C
  bne Loc_B3_8416              ; $840E
  jsr Sub_B3_8813              ; $8410
  jmp Loc_B3_85AC              ; $8413
Loc_B3_8416:
  lda z:Tmp00                  ; $8416
Loc_B3_8418:
  asl a                        ; $8418
  tay                          ; $8419
  lda Data_B3_8870,y           ; $841A
  sta z:Tmp00                  ; $841D
  lda Data_B3_8871,y           ; $841F
  sta z:Tmp01                  ; $8422
  jmp ($0000)                  ; $8424
Loc_B3_8427:
  lda $0400                    ; $8427
  asl a                        ; $842A
  tay                          ; $842B
  lda Data_B3_90CB,y           ; $842C
  sta z:$6C                    ; $842F
  sta z:$6A                    ; $8431
  lda Data_B3_90CC,y           ; $8433
  sta z:$6D                    ; $8436
  sta z:$6B                    ; $8438
  lda #$FF                     ; $843A
  sta z:$70                    ; $843C
  sta z:$71                    ; $843E
  jsr Sub_B3_85AD              ; $8440
  jsr Sub_B3_868C              ; $8443
Loc_B3_8446:
  ldy #$00                     ; $8446
  lda ($6C),y                  ; $8448
  sta z:$6E                    ; $844A
  iny                          ; $844C
  lda ($6C),y                  ; $844D
  sta z:$6F                    ; $844F
  jsr Sub_B3_85DB              ; $8451
  lda #$00                     ; $8454
  sta z:$72                    ; $8456
  sta $0418                    ; $8458
  sta $041C                    ; $845B
  sta $041E                    ; $845E
  lda #$01                     ; $8461
  sta $0411                    ; $8463
  lda #$FF                     ; $8466
  sta $0419                    ; $8468
Loc_B3_846B:
  lda $041D                    ; $846B
  cmp #$03                     ; $846E
  bcs Loc_B3_8478              ; $8470
  inc $041D                    ; $8472
  jmp Loc_B3_85AC              ; $8475
Loc_B3_8478:
  lda #$00                     ; $8478
  sta $041D                    ; $847A
Loc_B3_847D:
  ldy $041B                    ; $847D
  lda ($6E),y                  ; $8480
  bpl Loc_B3_8492              ; $8482
  sta $041A                    ; $8484
  lda #$01                     ; $8487
  sta $0412                    ; $8489
  inc $041B                    ; $848C
  jmp Loc_B3_85AC              ; $848F
Loc_B3_8492:
  sta z:Tmp00                  ; $8492
  and #$40                     ; $8494
  bne Loc_B3_84AF              ; $8496
  lda z:Tmp00                  ; $8498
  cmp #$2E                     ; $849A
  beq Loc_B3_84A4              ; $849C
  cmp #$2F                     ; $849E
  beq Loc_B3_84A4              ; $84A0
  ora #$40                     ; $84A2
Loc_B3_84A4:
  ora #$80                     ; $84A4
  sta $0419                    ; $84A6
  inc $041B                    ; $84A9
  jmp Loc_B3_847D              ; $84AC
Loc_B3_84AF:
  lda z:Tmp00                  ; $84AF
  cmp #$40                     ; $84B1
  beq Loc_B3_84C4              ; $84B3
  cmp #$41                     ; $84B5
  beq Loc_B3_84D3              ; $84B7
  cmp #$42                     ; $84B9
  beq Loc_B3_84F7              ; $84BB
  cmp #$43                     ; $84BD
  beq Loc_B3_850A              ; $84BF
  jmp Loc_B3_887E              ; $84C1
Loc_B3_84C4:
  inc $041B                    ; $84C4
  lda z:$72                    ; $84C7
  and #$F0                     ; $84C9
  clc                          ; $84CB
  adc #$40                     ; $84CC
  sta z:$72                    ; $84CE
  jmp Loc_B3_847D              ; $84D0
Loc_B3_84D3:
  jsr Sub_B3_85C6              ; $84D3
  lda #$01                     ; $84D6
  sta $0418                    ; $84D8
  lda JoyHeld1                 ; $84DB
  and #$01                     ; $84DE
  bne Loc_B3_84E8              ; $84E0
  jsr Sub_B3_86E9              ; $84E2
  jmp Loc_B3_85AC              ; $84E5
Loc_B3_84E8:
  inc $041B                    ; $84E8
  lda #$01                     ; $84EB
  sta $041C                    ; $84ED
  lda #$00                     ; $84F0
  sta z:$72                    ; $84F2
  jmp Loc_B3_85AC              ; $84F4
Loc_B3_84F7:
  inc $041B                    ; $84F7
  ldy $041B                    ; $84FA
  lda ($6E),y                  ; $84FD
  ldy #$01                     ; $84FF
  sta ($5C),y                  ; $8501
  clc                          ; $8503
  adc #$02                     ; $8504
  ldy #$05                     ; $8506
  sta ($5C),y                  ; $8508
Loc_B3_850A:
  lda #$05                     ; $850A
  clc                          ; $850C
  adc z:$6C                    ; $850D
  sta z:$6C                    ; $850F
  lda #$00                     ; $8511
  adc z:$6D                    ; $8513
  sta z:$6D                    ; $8515
  ldy #$00                     ; $8517
  lda ($6C),y                  ; $8519
  sta z:$6E                    ; $851B
  iny                          ; $851D
  lda ($6C),y                  ; $851E
  sta z:$6F                    ; $8520
  cmp #$FF                     ; $8522
  bne Loc_B3_858B              ; $8524
  lda z:$6E                    ; $8526
  cmp #$FF                     ; $8528
  bne Loc_B3_858B              ; $852A
  ldx $0400                    ; $852C
  lda Data_B3_883F,x           ; $852F
  bpl Loc_B3_854B              ; $8532
  and #$40                     ; $8534
  bne Loc_B3_853E              ; $8536
  jsr Sub_B3_8813              ; $8538
  jmp Loc_B3_85AC              ; $853B
Loc_B3_853E:
  lda #$04                     ; $853E
  sta $0418                    ; $8540
  lda #$00                     ; $8543
  sta $041D                    ; $8545
  jmp Loc_B3_85AC              ; $8548
Loc_B3_854B:
  lda #$03                     ; $854B
  sta $0418                    ; $854D
  lda JoyNew1                  ; $8550
  and #$03                     ; $8553
  bne Loc_B3_855D              ; $8555
  jsr Sub_B3_86E9              ; $8557
  jmp Loc_B3_85AC              ; $855A
Loc_B3_855D:
  cmp #$01                     ; $855D
  beq Loc_B3_8567              ; $855F
  jsr Sub_B3_8813              ; $8561
  jmp Loc_B3_85AC              ; $8564
Loc_B3_8567:
  inc $040C                    ; $8567
  lda $040C                    ; $856A
  cmp #$04                     ; $856D
  bcc Loc_B3_85AC              ; $856F
  lda #$00                     ; $8571
  sta $040C                    ; $8573
  lda z:$6A                    ; $8576
  sta z:$6C                    ; $8578
  lda z:$6B                    ; $857A
  sta z:$6D                    ; $857C
  lda #$01                     ; $857E
  sta $041C                    ; $8580
  lda #$02                     ; $8583
  sta $0411                    ; $8585
  jmp Loc_B3_85AC              ; $8588
Loc_B3_858B:
  lda #$02                     ; $858B
  sta $0418                    ; $858D
  jsr Sub_B3_85C6              ; $8590
  lda JoyHeld1                 ; $8593
  and #$01                     ; $8596
  bne Loc_B3_85A0              ; $8598
  jsr Sub_B3_86E9              ; $859A
  jmp Loc_B3_85AC              ; $859D
Loc_B3_85A0:
  lda #$00                     ; $85A0
  sta z:$72                    ; $85A2
  lda #$01                     ; $85A4
  sta $041C                    ; $85A6
  jsr Sub_B3_85DB              ; $85A9
Loc_B3_85AC:
  rts                          ; $85AC
Sub_B3_85AD:
  ldy #$2C                     ; $85AD
  lda #$5E                     ; $85AF
  sta ($5C),y                  ; $85B1
  iny                          ; $85B3
  lda #$FF                     ; $85B4
  sta ($5C),y                  ; $85B6
  iny                          ; $85B8
  lda #$00                     ; $85B9
  sta ($5C),y                  ; $85BB
  iny                          ; $85BD
  lda #$C0                     ; $85BE
  sec                          ; $85C0
  sbc z:HwScrollX              ; $85C1
  sta ($5C),y                  ; $85C3
  rts                          ; $85C5
Sub_B3_85C6:
  ldy #$2D                     ; $85C6
  lda #$FF                     ; $85C8
  sta ($5C),y                  ; $85CA
  ldy #$2F                     ; $85CC
  lda #$C0                     ; $85CE
  sec                          ; $85D0
  sbc z:HwScrollX              ; $85D1
  sta ($5C),y                  ; $85D3
  lda #$00                     ; $85D5
  sta $041E                    ; $85D7
  rts                          ; $85DA
Sub_B3_85DB:
  ldy #$02                     ; $85DB
  lda ($6C),y                  ; $85DD
  sta z:Tmp00                  ; $85DF
  iny                          ; $85E1
  lda ($6C),y                  ; $85E2
  sta z:Tmp01                  ; $85E4
  ldy #$0C                     ; $85E6
Loc_B3_85E8:
  iny                          ; $85E8
  lda z:Tmp00                  ; $85E9
  sta ($5C),y                  ; $85EB
  iny                          ; $85ED
  lda z:Tmp01                  ; $85EE
  sta ($5C),y                  ; $85F0
  iny                          ; $85F2
  iny                          ; $85F3
  inc z:Tmp00                  ; $85F4
  inc z:Tmp00                  ; $85F6
  cpy #$2C                     ; $85F8
  bcc Loc_B3_85E8              ; $85FA
  ldy #$04                     ; $85FC
  lda ($6C),y                  ; $85FE
  asl a                        ; $8600
  asl a                        ; $8601
  sta z:Tmp00                  ; $8602
  asl a                        ; $8604
  clc                          ; $8605
  adc z:Tmp00                  ; $8606
  sta z:Tmp00                  ; $8608
  lda #$2C                     ; $860A
  clc                          ; $860C
  adc z:Tmp00                  ; $860D
  sta z:Tmp00                  ; $860F
  lda #$95                     ; $8611
  adc #$00                     ; $8613
  sta z:Tmp01                  ; $8615
  lda z:Tmp00                  ; $8617
  cmp z:$70                    ; $8619
  bne Loc_B3_8623              ; $861B
  lda z:Tmp01                  ; $861D
  cmp z:$71                    ; $861F
  beq Loc_B3_8660              ; $8621
Loc_B3_8623:
  lda z:Tmp00                  ; $8623
  sta z:$70                    ; $8625
  lda z:Tmp01                  ; $8627
  sta z:$71                    ; $8629
  ldy #$00                     ; $862B
  jsr Sub_B3_8666              ; $862D
  ldy #$01                     ; $8630
  jsr Sub_B3_867A              ; $8632
  lda z:Tmp03                  ; $8635
  sta z:Tmp02                  ; $8637
  lda z:Tmp00                  ; $8639
  cmp #$FF                     ; $863B
  beq Loc_B3_8643              ; $863D
  inc z:Tmp00                  ; $863F
  inc z:Tmp00                  ; $8641
Loc_B3_8643:
  ldy #$05                     ; $8643
  jsr Sub_B3_867A              ; $8645
  ldy #$04                     ; $8648
  jsr Sub_B3_8666              ; $864A
  ldy #$09                     ; $864D
  jsr Sub_B3_867A              ; $864F
  lda #$00                     ; $8652
  sta $0408                    ; $8654
  sta $0409                    ; $8657
  sta $040A                    ; $865A
  sta $040B                    ; $865D
Loc_B3_8660:
  lda #$00                     ; $8660
  sta $041B                    ; $8662
  rts                          ; $8665
Sub_B3_8666:
  lda ($70),y                  ; $8666
  sta z:Tmp00                  ; $8668
  iny                          ; $866A
  lda ($70),y                  ; $866B
  sta z:Tmp01                  ; $866D
  iny                          ; $866F
  lda ($70),y                  ; $8670
  sta z:Tmp02                  ; $8672
  iny                          ; $8674
  lda ($70),y                  ; $8675
  sta z:Tmp03                  ; $8677
  rts                          ; $8679
Sub_B3_867A:
  lda z:Tmp00                  ; $867A
  sta ($5C),y                  ; $867C
  iny                          ; $867E
  lda z:Tmp01                  ; $867F
  sta ($5C),y                  ; $8681
  iny                          ; $8683
  lda z:Tmp02                  ; $8684
  sec                          ; $8686
  sbc z:HwScrollX              ; $8687
  sta ($5C),y                  ; $8689
  rts                          ; $868B
Sub_B3_868C:
  lda #$38                     ; $868C
  sta z:Tmp00                  ; $868E
  lda #$30                     ; $8690
  sta z:Tmp02                  ; $8692
  lda z:Tmp02                  ; $8694
  sec                          ; $8696
  sbc z:HwScrollX              ; $8697
  sta z:Tmp02                  ; $8699
  lda #$08                     ; $869B
  sta z:Tmp03                  ; $869D
  ldy #$0C                     ; $869F
Loc_B3_86A1:
  lda z:Tmp00                  ; $86A1
  sta ($5C),y                  ; $86A3
  iny                          ; $86A5
  lda #$FF                     ; $86A6
  sta ($5C),y                  ; $86A8
  iny                          ; $86AA
  iny                          ; $86AB
  lda z:Tmp02                  ; $86AC
  sta ($5C),y                  ; $86AE
  iny                          ; $86B0
  lda #$08                     ; $86B1
  clc                          ; $86B3
  adc z:Tmp02                  ; $86B4
  sta z:Tmp02                  ; $86B6
  inc z:Tmp01                  ; $86B8
  inc z:Tmp01                  ; $86BA
  dec z:Tmp03                  ; $86BC
  beq Loc_B3_86D7              ; $86BE
  lda z:Tmp03                  ; $86C0
  cmp #$04                     ; $86C2
  bne Loc_B3_86A1              ; $86C4
  lda #$10                     ; $86C6
  clc                          ; $86C8
  adc z:Tmp00                  ; $86C9
  sta z:Tmp00                  ; $86CB
  lda #$E0                     ; $86CD
  clc                          ; $86CF
  adc z:Tmp02                  ; $86D0
  sta z:Tmp02                  ; $86D2
  jmp Loc_B3_86A1              ; $86D4
Loc_B3_86D7:
  ldy #$08                     ; $86D7
  lda z:Tmp00                  ; $86D9
  sta ($5C),y                  ; $86DB
  sec                          ; $86DD
  sbc #$10                     ; $86DE
  ldy #$00                     ; $86E0
  sta ($5C),y                  ; $86E2
  ldy #$04                     ; $86E4
  sta ($5C),y                  ; $86E6
  rts                          ; $86E8
Sub_B3_86E9:
  lda $041E                    ; $86E9
  cmp #$14                     ; $86EC
  bcs Loc_B3_86F6              ; $86EE
  inc $041E                    ; $86F0
  jmp Loc_B3_872A              ; $86F3
Loc_B3_86F6:
  lda #$00                     ; $86F6
  sta $041E                    ; $86F8
  ldy #$2D                     ; $86FB
  lda ($5C),y                  ; $86FD
  cmp #$FF                     ; $86FF
  beq Loc_B3_870A              ; $8701
  lda #$FF                     ; $8703
  sta ($5C),y                  ; $8705
  jmp Loc_B3_872A              ; $8707
Loc_B3_870A:
  lda $0418                    ; $870A
  and #$0F                     ; $870D
  cmp #$03                     ; $870F
  bcc Loc_B3_871B              ; $8711
  lda #$A8                     ; $8713
  pha                          ; $8715
  lda #$5E                     ; $8716
  jmp Loc_B3_8720              ; $8718
Loc_B3_871B:
  lda #$C0                     ; $871B
  pha                          ; $871D
  lda #$FD                     ; $871E
Loc_B3_8720:
  sta ($5C),y                  ; $8720
  pla                          ; $8722
  sec                          ; $8723
  sbc z:HwScrollX              ; $8724
  ldy #$2F                     ; $8726
  sta ($5C),y                  ; $8728
Loc_B3_872A:
  rts                          ; $872A
Sub_B3_872B:
  lda z:FrameCounter           ; $872B
  and #$01                     ; $872D
  beq Loc_B3_8734              ; $872F
  jmp Loc_B3_87EF              ; $8731
Loc_B3_8734:
  lda $0418                    ; $8734
  and #$0F                     ; $8737
  cmp #$05                     ; $8739
  bcc Loc_B3_8740              ; $873B
  jmp Loc_B3_87EF              ; $873D
Loc_B3_8740:
  ldy #$00                     ; $8740
  lda ($70),y                  ; $8742
  cmp #$FF                     ; $8744
  beq Loc_B3_879E              ; $8746
  inc $0408                    ; $8748
  lda #$07                     ; $874B
  clc                          ; $874D
  adc $0409                    ; $874E
  tay                          ; $8751
  lda ($70),y                  ; $8752
  cmp #$FF                     ; $8754
  beq Loc_B3_875D              ; $8756
  cmp $0408                    ; $8758
  beq Loc_B3_8760              ; $875B
Loc_B3_875D:
  jmp Loc_B3_879E              ; $875D
Loc_B3_8760:
  lda #$00                     ; $8760
  sta $0408                    ; $8762
  inc $0409                    ; $8765
  lda $0409                    ; $8768
  cmp #$03                     ; $876B
  bne Loc_B3_8774              ; $876D
  lda #$00                     ; $876F
  sta $0409                    ; $8771
Loc_B3_8774:
  clc                          ; $8774
  adc #$07                     ; $8775
  tay                          ; $8777
  lda ($70),y                  ; $8778
  beq Loc_B3_8760              ; $877A
  cmp #$FF                     ; $877C
  beq Loc_B3_879E              ; $877E
  lda $0409                    ; $8780
  asl a                        ; $8783
  asl a                        ; $8784
  sta z:Tmp00                  ; $8785
  ldy #$00                     ; $8787
  lda ($70),y                  ; $8789
  clc                          ; $878B
  adc z:Tmp00                  ; $878C
  sta z:Tmp00                  ; $878E
  ldy #$01                     ; $8790
  sta ($5C),y                  ; $8792
  inc z:Tmp00                  ; $8794
  inc z:Tmp00                  ; $8796
  lda z:Tmp00                  ; $8798
  ldy #$05                     ; $879A
  sta ($5C),y                  ; $879C
Loc_B3_879E:
  ldy #$04                     ; $879E
  lda ($70),y                  ; $87A0
  cmp #$FF                     ; $87A2
  beq Loc_B3_87EF              ; $87A4
  lda $0418                    ; $87A6
  beq Loc_B3_87B2              ; $87A9
  lda $040B                    ; $87AB
  cmp #$00                     ; $87AE
  beq Loc_B3_87EF              ; $87B0
Loc_B3_87B2:
  inc $040A                    ; $87B2
  lda #$0A                     ; $87B5
  clc                          ; $87B7
  adc $040B                    ; $87B8
  tay                          ; $87BB
  lda ($70),y                  ; $87BC
  cmp $040A                    ; $87BE
  beq Loc_B3_87C6              ; $87C1
  jmp Loc_B3_87EF              ; $87C3
Loc_B3_87C6:
  lda #$00                     ; $87C6
  sta $040A                    ; $87C8
  inc $040B                    ; $87CB
  lda $040B                    ; $87CE
  and #$01                     ; $87D1
  sta $040B                    ; $87D3
  clc                          ; $87D6
  adc #$0A                     ; $87D7
  tay                          ; $87D9
  lda ($70),y                  ; $87DA
  beq Loc_B3_87C6              ; $87DC
  lda $040B                    ; $87DE
  asl a                        ; $87E1
  sta z:Tmp00                  ; $87E2
  ldy #$04                     ; $87E4
  lda ($70),y                  ; $87E6
  clc                          ; $87E8
  adc z:Tmp00                  ; $87E9
  ldy #$09                     ; $87EB
  sta ($5C),y                  ; $87ED
Loc_B3_87EF:
  rts                          ; $87EF
  .incbin "prg_bank_3.bin", $07F0, $23  ; $87F0
Sub_B3_8813:
  ldy #$00                     ; $8813
  lda #$F0                     ; $8815
Loc_B3_8817:
  sta ($5C),y                  ; $8817
  iny                          ; $8819
  cpy #$30                     ; $881A
  bcc Loc_B3_8817              ; $881C
  lda z:PpuCtrlShadow          ; $881E
  and #$FD                     ; $8820
  sta z:PpuCtrlShadow          ; $8822
  sta PPU_CTRL                 ; $8824
  lda $0414                    ; $8827
  sta z:HwScrollX              ; $882A
  jsr ApplyScroll              ; $882C
  lda #$00                     ; $882F
  sta JoyNew1                  ; $8831
  lda #$00                     ; $8834
  sta $0402                    ; $8836
  lda $0403                    ; $8839
  sta z:MmcPrgShadow           ; $883C
  rts                          ; $883E
Data_B3_883F:
  .incbin "prg_bank_3.bin", $083F, $31  ; $883F
Data_B3_8870:
  .incbin "prg_bank_3.bin", $0870, $1  ; $8870
Data_B3_8871:
  .incbin "prg_bank_3.bin", $0871, $D  ; $8871
Loc_B3_887E:
  ldy $041B                    ; $887E
  iny                          ; $8881
  lda ($6E),y                  ; $8882
  sta z:$56                    ; $8884
  iny                          ; $8886
  lda ($6E),y                  ; $8887
  sta z:$58                    ; $8889
  lda z:Tmp00                  ; $888B
  cmp #$48                     ; $888D
  bne Loc_B3_8896              ; $888F
  lda #$05                     ; $8891
  jmp Loc_B3_8898              ; $8893
Loc_B3_8896:
  lda #$05                     ; $8896
Loc_B3_8898:
  sta $0418                    ; $8898
  ldy #$2D                     ; $889B
  lda #$FF                     ; $889D
  sta ($5C),y                  ; $889F
  lda #$00                     ; $88A1
  sta $0409                    ; $88A3
  sta $040B                    ; $88A6
  lda z:$56                    ; $88A9
  asl a                        ; $88AB
  tay                          ; $88AC
  lda Data_B3_8A2F,y           ; $88AD
  sta z:$56                    ; $88B0
  lda Data_B3_8A30,y           ; $88B2
  sta z:$57                    ; $88B5
  lda z:$58                    ; $88B7
  asl a                        ; $88B9
  tay                          ; $88BA
  lda Data_B3_8A33,y           ; $88BB
  sta z:$58                    ; $88BE
  lda Data_B3_8A34,y           ; $88C0
  sta z:$59                    ; $88C3
  jsr Sub_B3_8A02              ; $88C5
  jsr Sub_B3_8A1D              ; $88C8
  jmp Loc_B3_85AC              ; $88CB
  lda $0418                    ; $88CE  [heuristic code]
  and #$10                     ; $88D1
  bne Loc_B3_88FD              ; $88D3
  inc $0408                    ; $88D5
  lda $0409                    ; $88D8
  asl a                        ; $88DB
  tay                          ; $88DC
  lda ($56),y                  ; $88DD
  cmp $0408                    ; $88DF
  bcs Loc_B3_88FD              ; $88E2
  inc $0409                    ; $88E4
  iny                          ; $88E7
  iny                          ; $88E8
  lda ($56),y                  ; $88E9
  cmp #$FF                     ; $88EB
  bne Loc_B3_88FA              ; $88ED
  lda #$10                     ; $88EF
  ora $0418                    ; $88F1
  sta $0418                    ; $88F4
  jmp Loc_B3_892F              ; $88F7
Loc_B3_88FA:
  jsr Sub_B3_8A02              ; $88FA
Loc_B3_88FD:
  lda $0418                    ; $88FD
  and #$20                     ; $8900
  bne Loc_B3_8962              ; $8902
  inc $040A                    ; $8904
  lda $040B                    ; $8907
  asl a                        ; $890A
  tay                          ; $890B
  lda ($58),y                  ; $890C
  cmp $040A                    ; $890E
  bcs Loc_B3_8962              ; $8911
  inc $040B                    ; $8913
  iny                          ; $8916
  iny                          ; $8917
  lda ($58),y                  ; $8918
  cmp #$FF                     ; $891A
  bne Loc_B3_8929              ; $891C
  lda #$20                     ; $891E
  ora $0418                    ; $8920
  sta $0418                    ; $8923
  jmp Loc_B3_892F              ; $8926
Loc_B3_8929:
  jsr Sub_B3_8A1D              ; $8929
  jmp Loc_B3_85AC              ; $892C
Loc_B3_892F:
  lda $0418                    ; $892F
  and #$30                     ; $8932
  cmp #$30                     ; $8934
  bne Loc_B3_8962              ; $8936
  lda $0418                    ; $8938
  and #$CF                     ; $893B
  sta $0418                    ; $893D
  bmi Loc_B3_8948              ; $8940
  jsr Sub_B3_8813              ; $8942
  jmp Loc_B3_85AC              ; $8945
Loc_B3_8948:
  inc $0418                    ; $8948
  lda #$00                     ; $894B
  sta $0409                    ; $894D
  lda #$30                     ; $8950
  sta $040B                    ; $8952
  ldx #$00                     ; $8955
Loc_B3_8957:
  lda PaletteBuffer,x          ; $8957
  sta $0440,x                  ; $895A
  inx                          ; $895D
  cpx #$20                     ; $895E
  bcc Loc_B3_8957              ; $8960
Loc_B3_8962:
  jmp Loc_B3_85AC              ; $8962
  .incbin "prg_bank_3.bin", $0965, $9D  ; $8965
Sub_B3_8A02:
  lda #$00                     ; $8A02
  sta $0408                    ; $8A04
  lda $0409                    ; $8A07
  asl a                        ; $8A0A
  tay                          ; $8A0B
  iny                          ; $8A0C
  lda ($56),y                  ; $8A0D
  pha                          ; $8A0F
  ldy #$01                     ; $8A10
  sta ($5C),y                  ; $8A12
  pla                          ; $8A14
  clc                          ; $8A15
  adc #$02                     ; $8A16
  ldy #$05                     ; $8A18
  sta ($5C),y                  ; $8A1A
  rts                          ; $8A1C
Sub_B3_8A1D:
  lda #$00                     ; $8A1D
  sta $040A                    ; $8A1F
  lda $040B                    ; $8A22
  asl a                        ; $8A25
  tay                          ; $8A26
  iny                          ; $8A27
  lda ($58),y                  ; $8A28
  ldy #$09                     ; $8A2A
  sta ($5C),y                  ; $8A2C
  rts                          ; $8A2E
Data_B3_8A2F:
  .incbin "prg_bank_3.bin", $0A2F, $1  ; $8A2F
Data_B3_8A30:
  .incbin "prg_bank_3.bin", $0A30, $3  ; $8A30
Data_B3_8A33:
  .incbin "prg_bank_3.bin", $0A33, $1  ; $8A33
Data_B3_8A34:
  .incbin "prg_bank_3.bin", $0A34, $27  ; $8A34
Sub_B3_8A5B:
  lda $0411                    ; $8A5B
  and #$7F                     ; $8A5E
  cmp #$01                     ; $8A60
  bne Loc_B3_8A67              ; $8A62
  jmp Loc_B3_8A97              ; $8A64
Loc_B3_8A67:
  cmp #$0B                     ; $8A67
  bne Loc_B3_8A7F              ; $8A69
  lda #$F8                     ; $8A6B
  sta z:$60                    ; $8A6D
  lda #$8B                     ; $8A6F
  sta z:$61                    ; $8A71
  ldy #$00                     ; $8A73
Loc_B3_8A75:
  lda ($60),y                  ; $8A75
  sta a:$64,y                  ; $8A77
  iny                          ; $8A7A
  cpy #$05                     ; $8A7B
  bne Loc_B3_8A75              ; $8A7D
Loc_B3_8A7F:
  lda #$20                     ; $8A7F
  clc                          ; $8A81
  adc z:$65                    ; $8A82
  sta z:$65                    ; $8A84
  lda #$00                     ; $8A86
  adc z:$64                    ; $8A88
  sta z:$64                    ; $8A8A
  jsr ProcessPpuUpdateList     ; $8A8C
  .incbin "prg_bank_3.bin", $0A8F, $2  ; $8A8F
  dec $0411                    ; $8A91
  jmp Loc_B3_8BD1              ; $8A94
Loc_B3_8A97:
  lda $0411                    ; $8A97
  bmi Loc_B3_8AE5              ; $8A9A
  ora #$80                     ; $8A9C
  sta $0411                    ; $8A9E
  lda #$D9                     ; $8AA1
  sta z:Tmp00                  ; $8AA3
  lda #$2B                     ; $8AA5
  sta z:Tmp01                  ; $8AA7
  jsr Sub_B3_8BD2              ; $8AA9
  jsr ProcessPpuUpdateList     ; $8AAC
  .addr Data_B3_8BFD  ; $8AAF inline pointer (data after a JSR)
  lda #$84                     ; $8AB1
  sta z:$60                    ; $8AB3
  lda #$28                     ; $8AB5
  sta z:$61                    ; $8AB7
  lda #$A4                     ; $8AB9
  sta z:$62                    ; $8ABB
  lda #$28                     ; $8ABD
  sta z:$63                    ; $8ABF
  lda #$0F                     ; $8AC1
  sta $0416                    ; $8AC3
  sta $0417                    ; $8AC6
  lda #$F0                     ; $8AC9
  sta z:$64                    ; $8ACB
  lda #$F2                     ; $8ACD
  sta z:$65                    ; $8ACF
  lda PPU_STATUS               ; $8AD1
  lda z:$61                    ; $8AD4
  sta PPU_ADDR                 ; $8AD6
  lda z:$60                    ; $8AD9
  inc z:$60                    ; $8ADB
  sta PPU_ADDR                 ; $8ADD
  lda #$EC                     ; $8AE0
  sta PPU_DATA                 ; $8AE2
Loc_B3_8AE5:
  lda $0416                    ; $8AE5
  cmp #$05                     ; $8AE8
  bcc Loc_B3_8AF8              ; $8AEA
  lda z:PpuCtrlShadow          ; $8AEC
  and #$FB                     ; $8AEE
  sta z:PpuCtrlShadow          ; $8AF0
  sta PPU_CTRL                 ; $8AF2
  jmp Loc_B3_8B01              ; $8AF5
Loc_B3_8AF8:
  lda z:PpuCtrlShadow          ; $8AF8
  ora #$04                     ; $8AFA
  sta z:PpuCtrlShadow          ; $8AFC
  sta PPU_CTRL                 ; $8AFE
Loc_B3_8B01:
  lda PPU_STATUS               ; $8B01
  lda z:$61                    ; $8B04
  sta PPU_ADDR                 ; $8B06
  lda z:$60                    ; $8B09
  sta PPU_ADDR                 ; $8B0B
  lda z:$64                    ; $8B0E
  sta PPU_DATA                 ; $8B10
  sta PPU_DATA                 ; $8B13
  dec $0416                    ; $8B16
  lda $0416                    ; $8B19
  cmp #$05                     ; $8B1C
  bcc Loc_B3_8B27              ; $8B1E
  inc z:$60                    ; $8B20
  inc z:$60                    ; $8B22
  jmp Loc_B3_8B4B              ; $8B24
Loc_B3_8B27:
  cmp #$04                     ; $8B27
  bne Loc_B3_8B3E              ; $8B29
  lda #$ED                     ; $8B2B
  sta PPU_DATA                 ; $8B2D
  lda #$F3                     ; $8B30
  sta z:$64                    ; $8B32
  lda #$22                     ; $8B34
  clc                          ; $8B36
  adc z:$60                    ; $8B37
  sta z:$60                    ; $8B39
  jmp Loc_B3_8B4B              ; $8B3B
Loc_B3_8B3E:
  lda #$40                     ; $8B3E
  clc                          ; $8B40
  adc z:$60                    ; $8B41
  sta z:$60                    ; $8B43
  lda #$00                     ; $8B45
  adc z:$61                    ; $8B47
  sta z:$61                    ; $8B49
Loc_B3_8B4B:
  lda $0417                    ; $8B4B
  cmp #$0C                     ; $8B4E
  bcc Loc_B3_8B5E              ; $8B50
  lda z:PpuCtrlShadow          ; $8B52
  ora #$04                     ; $8B54
  sta z:PpuCtrlShadow          ; $8B56
  sta PPU_CTRL                 ; $8B58
  jmp Loc_B3_8B67              ; $8B5B
Loc_B3_8B5E:
  lda z:PpuCtrlShadow          ; $8B5E
  and #$FB                     ; $8B60
  sta z:PpuCtrlShadow          ; $8B62
  sta PPU_CTRL                 ; $8B64
Loc_B3_8B67:
  lda PPU_STATUS               ; $8B67
  lda z:$63                    ; $8B6A
  sta PPU_ADDR                 ; $8B6C
  lda z:$62                    ; $8B6F
  sta PPU_ADDR                 ; $8B71
  lda z:$65                    ; $8B74
  sta PPU_DATA                 ; $8B76
  sta PPU_DATA                 ; $8B79
  dec $0417                    ; $8B7C
  bne Loc_B3_8B84              ; $8B7F
  jmp Loc_B3_8BBC              ; $8B81
Loc_B3_8B84:
  lda $0417                    ; $8B84
  cmp #$0C                     ; $8B87
  bcc Loc_B3_8B9B              ; $8B89
  lda #$40                     ; $8B8B
  clc                          ; $8B8D
  adc z:$62                    ; $8B8E
  sta z:$62                    ; $8B90
  lda #$00                     ; $8B92
  adc z:$63                    ; $8B94
  sta z:$63                    ; $8B96
  jmp Loc_B3_8BD1              ; $8B98
Loc_B3_8B9B:
  cmp #$0B                     ; $8B9B
  bne Loc_B3_8BB5              ; $8B9D
  lda #$EE                     ; $8B9F
  sta PPU_DATA                 ; $8BA1
  lda #$F1                     ; $8BA4
  sta z:$65                    ; $8BA6
  lda #$3F                     ; $8BA8
  clc                          ; $8BAA
  adc z:$62                    ; $8BAB
  sta z:$62                    ; $8BAD
  lda #$00                     ; $8BAF
  adc z:$63                    ; $8BB1
  sta z:$63                    ; $8BB3
Loc_B3_8BB5:
  inc z:$62                    ; $8BB5
  inc z:$62                    ; $8BB7
  jmp Loc_B3_8BD1              ; $8BB9
Loc_B3_8BBC:
  lda #$EF                     ; $8BBC
  sta PPU_DATA                 ; $8BBE
  lda #$00                     ; $8BC1
  sta $0412                    ; $8BC3
  sta $041C                    ; $8BC6
  sta $0411                    ; $8BC9
  lda #$04                     ; $8BCC
  sta $0410                    ; $8BCE
Loc_B3_8BD1:
  rts                          ; $8BD1
Sub_B3_8BD2:
  lda z:PpuCtrlShadow          ; $8BD2
  and #$FB                     ; $8BD4
  sta z:PpuCtrlShadow          ; $8BD6
  sta PPU_CTRL                 ; $8BD8
  lda PPU_STATUS               ; $8BDB
  lda z:Tmp01                  ; $8BDE
  sta PPU_ADDR                 ; $8BE0
  lda z:Tmp00                  ; $8BE3
  sta PPU_ADDR                 ; $8BE5
  ldy #$00                     ; $8BE8
Loc_B3_8BEA:
  lda a:$50,y                  ; $8BEA
  ora #$0F                     ; $8BED
  sta PPU_DATA                 ; $8BEF
  iny                          ; $8BF2
  cpy #$06                     ; $8BF3
  bne Loc_B3_8BEA              ; $8BF5
  rts                          ; $8BF7
  .incbin "prg_bank_3.bin", $0BF8, $5  ; $8BF8
Data_B3_8BFD:
  .incbin "prg_bank_3.bin", $0BFD, $9  ; $8BFD
Sub_B3_8C06:
  lda $0411                    ; $8C06
  beq Loc_B3_8C0E              ; $8C09
  jmp Loc_B3_8CB4              ; $8C0B
Loc_B3_8C0E:
  lda $0414                    ; $8C0E
  lsr a                        ; $8C11
  lsr a                        ; $8C12
  tay                          ; $8C13
  lda #$60                     ; $8C14
  sta z:Tmp02                  ; $8C16
  lda #$00                     ; $8C18
  sta z:Tmp03                  ; $8C1A
  ldx #$00                     ; $8C1C
  lda #$08                     ; $8C1E
  sta z:Tmp01                  ; $8C20
Loc_B3_8C22:
  lda #$08                     ; $8C22
  sta z:Tmp00                  ; $8C24
Loc_B3_8C26:
  lda (Tmp02),y                ; $8C26
  sta z:$A0,x                  ; $8C28
  iny                          ; $8C2A
  tya                          ; $8C2B
  and #$07                     ; $8C2C
  tay                          ; $8C2E
  inx                          ; $8C2F
  dec z:Tmp00                  ; $8C30
  bne Loc_B3_8C26              ; $8C32
  lda #$08                     ; $8C34
  clc                          ; $8C36
  adc z:Tmp02                  ; $8C37
  sta z:Tmp02                  ; $8C39
  lda #$00                     ; $8C3B
  adc z:Tmp03                  ; $8C3D
  sta z:Tmp03                  ; $8C3F
  dec z:Tmp01                  ; $8C41
  bne Loc_B3_8C22              ; $8C43
  lda $0414                    ; $8C45
  and #$02                     ; $8C48
  bne Loc_B3_8C4F              ; $8C4A
  jmp Loc_B3_8CAE              ; $8C4C
Loc_B3_8C4F:
  lda #$A0                     ; $8C4F
  sta z:Tmp02                  ; $8C51
  lda #$00                     ; $8C53
  sta z:Tmp03                  ; $8C55
  lda #$60                     ; $8C57
  sta z:$04                    ; $8C59
  lda #$00                     ; $8C5B
  sta z:$05                    ; $8C5D
  lda #$08                     ; $8C5F
  sta z:Tmp01                  ; $8C61
Loc_B3_8C63:
  lda #$08                     ; $8C63
  sta z:Tmp00                  ; $8C65
  ldy #$00                     ; $8C67
Loc_B3_8C69:
  lda (Tmp02),y                ; $8C69
  lsr a                        ; $8C6B
  lsr a                        ; $8C6C
  and #$33                     ; $8C6D
  sta ($04),y                  ; $8C6F
  iny                          ; $8C71
  tya                          ; $8C72
  and #$07                     ; $8C73
  tay                          ; $8C75
  lda (Tmp02),y                ; $8C76
  asl a                        ; $8C78
  asl a                        ; $8C79
  and #$CC                     ; $8C7A
  pha                          ; $8C7C
  dey                          ; $8C7D
  tya                          ; $8C7E
  and #$07                     ; $8C7F
  tay                          ; $8C81
  pla                          ; $8C82
  ora ($04),y                  ; $8C83
  sta ($04),y                  ; $8C85
  iny                          ; $8C87
  tya                          ; $8C88
  and #$07                     ; $8C89
  tay                          ; $8C8B
  dec z:Tmp00                  ; $8C8C
  bne Loc_B3_8C69              ; $8C8E
  lda #$08                     ; $8C90
  clc                          ; $8C92
  adc z:Tmp02                  ; $8C93
  sta z:Tmp02                  ; $8C95
  lda #$00                     ; $8C97
  adc z:Tmp03                  ; $8C99
  sta z:Tmp03                  ; $8C9B
  lda #$08                     ; $8C9D
  clc                          ; $8C9F
  adc z:$04                    ; $8CA0
  sta z:$04                    ; $8CA2
  lda #$00                     ; $8CA4
  adc z:$05                    ; $8CA6
  sta z:$05                    ; $8CA8
  dec z:Tmp01                  ; $8CAA
  bne Loc_B3_8C63              ; $8CAC
Loc_B3_8CAE:
  inc $0411                    ; $8CAE
  jmp Loc_B3_8D22              ; $8CB1
Loc_B3_8CB4:
  lda $0414                    ; $8CB4
  and #$02                     ; $8CB7
  beq Loc_B3_8CC6              ; $8CB9
  lda #$60                     ; $8CBB
  sta z:Tmp02                  ; $8CBD
  lda #$00                     ; $8CBF
  sta z:Tmp03                  ; $8CC1
  jmp Loc_B3_8CCE              ; $8CC3
Loc_B3_8CC6:
  lda #$A0                     ; $8CC6
  sta z:Tmp02                  ; $8CC8
  lda #$00                     ; $8CCA
  sta z:Tmp03                  ; $8CCC
Loc_B3_8CCE:
  lda #$40                     ; $8CCE
  sta z:Tmp00                  ; $8CD0
  lda PPU_STATUS               ; $8CD2
  lda #$2B                     ; $8CD5
  sta PPU_ADDR                 ; $8CD7
  lda #$C0                     ; $8CDA
  sta PPU_ADDR                 ; $8CDC
  ldy #$00                     ; $8CDF
Loc_B3_8CE1:
  lda (Tmp02),y                ; $8CE1
  sta PPU_DATA                 ; $8CE3
  iny                          ; $8CE6
  dec z:Tmp00                  ; $8CE7
  bne Loc_B3_8CE1              ; $8CE9
  lda z:HwScrollX              ; $8CEB
  sta $0414                    ; $8CED
  and #$08                     ; $8CF0
  beq Loc_B3_8CFB              ; $8CF2
  lda #$F0                     ; $8CF4
  ora z:HwScrollX              ; $8CF6
  jmp Loc_B3_8CFF              ; $8CF8
Loc_B3_8CFB:
  lda #$0F                     ; $8CFB
  and z:HwScrollX              ; $8CFD
Loc_B3_8CFF:
  sta z:HwScrollX              ; $8CFF
  ldy #$19                     ; $8D01
  ldx #$00                     ; $8D03
Loc_B3_8D05:
  lda (Tmp02),y                ; $8D05
  sta z:$50,x                  ; $8D07
  iny                          ; $8D09
  inx                          ; $8D0A
  cpx #$06                     ; $8D0B
  bne Loc_B3_8D05              ; $8D0D
  lda z:PpuCtrlShadow          ; $8D0F
  ora #$02                     ; $8D11
  sta PPU_CTRL                 ; $8D13
  sta z:PpuCtrlShadow          ; $8D16
  lda #$0B                     ; $8D18
  sta $0411                    ; $8D1A
  lda #$03                     ; $8D1D
  sta $0410                    ; $8D1F
Loc_B3_8D22:
  rts                          ; $8D22
Sub_B3_8D23:
  lda #$00                     ; $8D23
  sta z:$58                    ; $8D25
  sta z:$5A                    ; $8D27
  lda #$20                     ; $8D29
  sta z:$59                    ; $8D2B
  lda #$28                     ; $8D2D
  sta z:$5B                    ; $8D2F
  lda z:PpuCtrlShadow          ; $8D31
  and #$FB                     ; $8D33
  sta PPU_CTRL                 ; $8D35
  sta z:PpuCtrlShadow          ; $8D38
  lda z:HwScrollX              ; $8D3A
  and #$08                     ; $8D3C
  beq Loc_B3_8D48              ; $8D3E
  lda #$10                     ; $8D40
  clc                          ; $8D42
  adc z:HwScrollX              ; $8D43
  jmp Loc_B3_8D4A              ; $8D45
Loc_B3_8D48:
  lda z:HwScrollX              ; $8D48
Loc_B3_8D4A:
  lsr a                        ; $8D4A
  lsr a                        ; $8D4B
  lsr a                        ; $8D4C
  and #$FE                     ; $8D4D
  sta $0414                    ; $8D4F
  sta $0413                    ; $8D52
  lda #$20                     ; $8D55
  sec                          ; $8D57
  sbc $0413                    ; $8D58
  and #$1E                     ; $8D5B
  sta $0413                    ; $8D5D
  lda #$00                     ; $8D60
  sta $040C                    ; $8D62
  sta $0415                    ; $8D65
  lda #$10                     ; $8D68
  sta $0411                    ; $8D6A
  inc $0410                    ; $8D6D
  rts                          ; $8D70
Sub_B3_8D71:
  lda $0415                    ; $8D71
  bne Loc_B3_8DC6              ; $8D74
  lda #$60                     ; $8D76
  sta z:$56                    ; $8D78
  lda #$00                     ; $8D7A
  sta z:$57                    ; $8D7C
  ldy $0413                    ; $8D7E
  lda #$02                     ; $8D81
  sta z:Tmp01                  ; $8D83
  lda PPU_STATUS               ; $8D85
  lda z:$59                    ; $8D88
  sta PPU_ADDR                 ; $8D8A
  lda z:$58                    ; $8D8D
  sta PPU_ADDR                 ; $8D8F
  lda PPU_DATA                 ; $8D92
  lda #$20                     ; $8D95
  sta z:Tmp00                  ; $8D97
Loc_B3_8D99:
  lda PPU_DATA                 ; $8D99
  sta ($56),y                  ; $8D9C
  iny                          ; $8D9E
  tya                          ; $8D9F
  and #$1F                     ; $8DA0
  tay                          ; $8DA2
  dec z:Tmp00                  ; $8DA3
  bne Loc_B3_8D99              ; $8DA5
  lda #$20                     ; $8DA7
  clc                          ; $8DA9
  adc z:$56                    ; $8DAA
  sta z:$56                    ; $8DAC
  lda #$20                     ; $8DAE
  sta z:Tmp00                  ; $8DB0
Loc_B3_8DB2:
  lda PPU_DATA                 ; $8DB2
  sta ($56),y                  ; $8DB5
  iny                          ; $8DB7
  tya                          ; $8DB8
  and #$1F                     ; $8DB9
  tay                          ; $8DBB
  dec z:Tmp00                  ; $8DBC
  bne Loc_B3_8DB2              ; $8DBE
  inc $0415                    ; $8DC0
  jmp Loc_B3_8E28              ; $8DC3
Loc_B3_8DC6:
  jsr DoOamDma                 ; $8DC6
  lda $0411                    ; $8DC9
  cmp #$01                     ; $8DCC
  beq Loc_B3_8E1E              ; $8DCE
  ldx #$40                     ; $8DD0
  ldy #$00                     ; $8DD2
  lda PPU_STATUS               ; $8DD4
  lda z:$5B                    ; $8DD7
  sta PPU_ADDR                 ; $8DD9
  lda z:$5A                    ; $8DDC
  sta PPU_ADDR                 ; $8DDE
Loc_B3_8DE1:
  lda a:$60,y                  ; $8DE1
  sta PPU_DATA                 ; $8DE4
  iny                          ; $8DE7
  dex                          ; $8DE8
  bne Loc_B3_8DE1              ; $8DE9
  lda z:$58                    ; $8DEB
  clc                          ; $8DED
  adc #$40                     ; $8DEE
  sta z:$58                    ; $8DF0
  lda #$00                     ; $8DF2
  adc z:$59                    ; $8DF4
  sta z:$59                    ; $8DF6
  lda z:$5A                    ; $8DF8
  clc                          ; $8DFA
  adc #$40                     ; $8DFB
  sta z:$5A                    ; $8DFD
  lda #$00                     ; $8DFF
  adc z:$5B                    ; $8E01
  sta z:$5B                    ; $8E03
  dec $0411                    ; $8E05
  beq Loc_B3_8E1E              ; $8E08
  lda #$00                     ; $8E0A
  sta $0415                    ; $8E0C
  lda $0411                    ; $8E0F
  cmp #$01                     ; $8E12
  bne Loc_B3_8E28              ; $8E14
  lda #$00                     ; $8E16
  sta $0413                    ; $8E18
  jmp Loc_B3_8E28              ; $8E1B
Loc_B3_8E1E:
  lda #$00                     ; $8E1E
  sta $0411                    ; $8E20
  lda #$02                     ; $8E23
  sta $0410                    ; $8E25
Loc_B3_8E28:
  rts                          ; $8E28
Sub_B3_8E29:
  lda $0422                    ; $8E29
  bne Loc_B3_8E50              ; $8E2C
  lda $0404                    ; $8E2E
  asl a                        ; $8E31
  tay                          ; $8E32
  lda Data_B3_8F8B,y           ; $8E33
  sta z:$56                    ; $8E36
  lda Data_B3_8F8C,y           ; $8E38
  sta z:$57                    ; $8E3B
  lda $042D                    ; $8E3D
  clc                          ; $8E40
  adc #$21                     ; $8E41
  sta $0425                    ; $8E43
  lda #$20                     ; $8E46
  sta $0426                    ; $8E48
  lda #$FF                     ; $8E4B
  sta $0423                    ; $8E4D
Loc_B3_8E50:
  inc $041F                    ; $8E50
  lda $041F                    ; $8E53
  cmp #$05                     ; $8E56
  bcs Loc_B3_8E5D              ; $8E58
  jmp Loc_B3_8EC5              ; $8E5A
Loc_B3_8E5D:
  lda #$00                     ; $8E5D
  sta $041F                    ; $8E5F
  ldy $0422                    ; $8E62
Loc_B3_8E65:
  lda ($56),y                  ; $8E65
  cmp #$FF                     ; $8E67
  bne Loc_B3_8E86              ; $8E69
  lda $0425                    ; $8E6B
  and #$1F                     ; $8E6E
  cmp #$1F                     ; $8E70
  bne Loc_B3_8E7F              ; $8E72
  lda $0425                    ; $8E74
  and #$E0                     ; $8E77
  sta $0425                    ; $8E79
  jmp Loc_B3_8E82              ; $8E7C
Loc_B3_8E7F:
  inc $0425                    ; $8E7F
Loc_B3_8E82:
  iny                          ; $8E82
  jmp Loc_B3_8E65              ; $8E83
Loc_B3_8E86:
  cmp #$43                     ; $8E86
  bne Loc_B3_8EA3              ; $8E88
  lda #$00                     ; $8E8A
  sta $041F                    ; $8E8C
  sta $0422                    ; $8E8F
  sta $0402                    ; $8E92
  sta JoyHeld1                 ; $8E95
  lda $0403                    ; $8E98
  sta z:MmcPrgShadow           ; $8E9B
  inc $0421                    ; $8E9D
  jmp Loc_B3_8EC5              ; $8EA0
Loc_B3_8EA3:
  lda ($56),y                  ; $8EA3
  bmi Loc_B3_8EB9              ; $8EA5
  cmp #$2E                     ; $8EA7
  beq Loc_B3_8EB1              ; $8EA9
  cmp #$2F                     ; $8EAB
  beq Loc_B3_8EB1              ; $8EAD
  ora #$40                     ; $8EAF
Loc_B3_8EB1:
  ora #$80                     ; $8EB1
  sta $0423                    ; $8EB3
  iny                          ; $8EB6
  lda ($56),y                  ; $8EB7
Loc_B3_8EB9:
  sta $0424                    ; $8EB9
  iny                          ; $8EBC
  sty $0422                    ; $8EBD
  lda #$01                     ; $8EC0
  sta $0427                    ; $8EC2
Loc_B3_8EC5:
  rts                          ; $8EC5
Sub_B3_8EC6:
  lda $0422                    ; $8EC6
  beq Loc_B3_8ECE              ; $8EC9
  jmp Loc_B3_8EF0              ; $8ECB
Loc_B3_8ECE:
  lda #$00                     ; $8ECE
  sta $0429                    ; $8ED0
  sta $0428                    ; $8ED3
  ldy #$00                     ; $8ED6
  lda Data_B3_8F75,y           ; $8ED8
  sta $042C                    ; $8EDB
  iny                          ; $8EDE
  lda Data_B3_8F75,y           ; $8EDF
  sta $042A                    ; $8EE2
  iny                          ; $8EE5
  lda Data_B3_8F75,y           ; $8EE6
  sta $042B                    ; $8EE9
  iny                          ; $8EEC
  sty $0422                    ; $8EED
Loc_B3_8EF0:
  lda #$02                     ; $8EF0
  sta z:Tmp00                  ; $8EF2
Loc_B3_8EF4:
  lda $042D                    ; $8EF4
  sta z:Tmp02                  ; $8EF7
  and #$1F                     ; $8EF9
  sta z:Tmp01                  ; $8EFB
  lda $0428                    ; $8EFD
  and #$0F                     ; $8F00
  clc                          ; $8F02
  adc z:Tmp01                  ; $8F03
  cmp #$20                     ; $8F05
  bcc Loc_B3_8F10              ; $8F07
  lda z:Tmp02                  ; $8F09
  sec                          ; $8F0B
  sbc #$20                     ; $8F0C
  sta z:Tmp02                  ; $8F0E
Loc_B3_8F10:
  lda PPU_STATUS               ; $8F10
  lda #$20                     ; $8F13
  sta PPU_ADDR                 ; $8F15
  lda $0428                    ; $8F18
  clc                          ; $8F1B
  adc z:Tmp02                  ; $8F1C
  sta PPU_ADDR                 ; $8F1E
  ldy $0429                    ; $8F21
  lda $0440,y                  ; $8F24
  sta PPU_DATA                 ; $8F27
  dec $042C                    ; $8F2A
  beq Loc_B3_8F4A              ; $8F2D
Loc_B3_8F2F:
  lda $042A                    ; $8F2F
  clc                          ; $8F32
  adc $0428                    ; $8F33
  sta $0428                    ; $8F36
  lda $042B                    ; $8F39
  clc                          ; $8F3C
  adc $0429                    ; $8F3D
  sta $0429                    ; $8F40
  dec z:Tmp00                  ; $8F43
  bne Loc_B3_8EF4              ; $8F45
  jmp Loc_B3_8F74              ; $8F47
Loc_B3_8F4A:
  ldy $0422                    ; $8F4A
  lda Data_B3_8F75,y           ; $8F4D
  cmp #$FF                     ; $8F50
  beq Loc_B3_8F6C              ; $8F52
  sta $042C                    ; $8F54
  iny                          ; $8F57
  lda Data_B3_8F75,y           ; $8F58
  sta $042A                    ; $8F5B
  iny                          ; $8F5E
  lda Data_B3_8F75,y           ; $8F5F
  sta $042B                    ; $8F62
  iny                          ; $8F65
  sty $0422                    ; $8F66
  jmp Loc_B3_8F2F              ; $8F69
Loc_B3_8F6C:
  lda #$00                     ; $8F6C
  sta $0402                    ; $8F6E
  sta $0421                    ; $8F71
Loc_B3_8F74:
  rts                          ; $8F74
Data_B3_8F75:
  .incbin "prg_bank_3.bin", $0F75, $16  ; $8F75
Data_B3_8F8B:
  .incbin "prg_bank_3.bin", $0F8B, $1  ; $8F8B
Data_B3_8F8C:
  .incbin "prg_bank_3.bin", $0F8C, $13F  ; $8F8C
Data_B3_90CB:
  .incbin "prg_bank_3.bin", $10CB, $1  ; $90CB
Data_B3_90CC:
  .incbin "prg_bank_3.bin", $10CC, $400  ; $90CC
  .incbin "prg_bank_3.bin", $14CC, $400  ; $94CC
  .incbin "prg_bank_3.bin", $18CC, $400  ; $98CC
  .incbin "prg_bank_3.bin", $1CCC, $400  ; $9CCC
  .incbin "prg_bank_3.bin", $20CC, $400  ; $A0CC
  .incbin "prg_bank_3.bin", $24CC, $400  ; $A4CC
  .incbin "prg_bank_3.bin", $28CC, $400  ; $A8CC
  .incbin "prg_bank_3.bin", $2CCC, $400  ; $ACCC
  .incbin "prg_bank_3.bin", $30CC, $400  ; $B0CC
  .incbin "prg_bank_3.bin", $34CC, $400  ; $B4CC
  .incbin "prg_bank_3.bin", $38CC, $400  ; $B8CC
  .incbin "prg_bank_3.bin", $3CCC, $331  ; $BCCC
Data_B3_BFFD:
  .incbin "prg_bank_3.bin", $3FFD, $3  ; $BFFD
