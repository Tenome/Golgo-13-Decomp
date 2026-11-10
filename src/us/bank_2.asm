; Bank 2  ($8000-$BFFF switchable)
; Sniper-scope scenes and palette tables (LoadPaletteSet reads them here).
.segment "PRG_BANK_2"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B2_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_2.bin", $0009, $7  ; $8009
Bank2Nmi:
  lda z:PpuCtrlShadow          ; $8010
  and #$7F                     ; $8012
  jsr SetPpuCtrl               ; $8014
  lda z:GameState              ; $8017
  cmp #$13                     ; $8019
  beq Loc_B2_8094              ; $801B
  cmp #$10                     ; $801D
  bne Loc_B2_807D              ; $801F
  lda #$02                     ; $8021
  sta $0300                    ; $8023
  lda #$1F                     ; $8026
  sta z:MmcControlShadow       ; $8028
  jsr MmcWriteControl          ; $802A
  lda #$80                     ; $802D
  sta $0119                    ; $802F
  lda #$33                     ; $8032
  sta $011C                    ; $8034
  lda #$00                     ; $8037
  sta $049A                    ; $8039
  sta $049B                    ; $803C
  sta $049C                    ; $803F
  sta $0497                    ; $8042
  sta $0495                    ; $8045
  sta $04AD                    ; $8048
  sta $04A9                    ; $804B
  sta $04A8                    ; $804E
  lda #$A7                     ; $8051
  sta $049E                    ; $8053
  lda z:AmmoLo                 ; $8056
  sta $04AE                    ; $8058
  lda z:AmmoHi                 ; $805B
  sta $04AF                    ; $805D
  lda #$03                     ; $8060
  sta $049D                    ; $8062
  lda #$01                     ; $8065
  sta $04AA                    ; $8067
  jsr Sub_B2_8211              ; $806A
  jsr Sub_B2_89E2              ; $806D
  jsr Sub_B2_8609              ; $8070
  lda #$00                     ; $8073
  jsr EnqueueByte              ; $8075
  inc z:GameState              ; $8078
  jmp Loc_B2_815C              ; $807A
Loc_B2_807D:
  cmp #$11                     ; $807D
  bne Loc_B2_8087              ; $807F
Sub_B2_8081:
  jsr Sub_B2_837A              ; $8081
  jmp Loc_B2_815C              ; $8084
Loc_B2_8087:
  lda #$18                     ; $8087
  jsr SetPpuMask               ; $8089
  inc z:GameState              ; $808C
  jsr Sub_B2_8167              ; $808E
  jmp Loc_B2_811B              ; $8091
Loc_B2_8094:
  jsr DoOamDma                 ; $8094
  jsr MmcWriteChr1             ; $8097
  jsr Sub_C5AC                 ; $809A
  jsr ApplyScroll              ; $809D
  jsr DrawHud                  ; $80A0
  jsr Sub_B2_83C7              ; $80A3
  jsr Sub_C0C0                 ; $80A6
  lda z:PaletteSetIndex        ; $80A9
  cmp #$69                     ; $80AB
  bne Loc_B2_80B5              ; $80AD
  jsr Sub_B2_8488              ; $80AF
  jsr Sub_B2_8938              ; $80B2
Loc_B2_80B5:
  jsr Sub_B2_87AC              ; $80B5
  jsr Sub_B2_8882              ; $80B8
  jsr Sub_B2_88AA              ; $80BB
  lda $0497                    ; $80BE
  bmi Loc_B2_810C              ; $80C1
  jsr ReadJoypads              ; $80C3
  lda ObjectCount              ; $80C6
  bne Loc_B2_811B              ; $80C9
  lda $0497                    ; $80CB
  bne Loc_B2_811B              ; $80CE
  lda $0495                    ; $80D0
  bne Loc_B2_80E0              ; $80D3
  lda #$00                     ; $80D5
  sta $0496                    ; $80D7
  jsr EnqueueByte              ; $80DA
  inc $0495                    ; $80DD
Loc_B2_80E0:
  inc $0496                    ; $80E0
  lda $0496                    ; $80E3
  cmp #$4B                     ; $80E6
  bne Loc_B2_80F7              ; $80E8
  lda #$0F                     ; $80EA
  ldx #$20                     ; $80EC
Loc_B2_80EE:
  sta $013F,x                  ; $80EE
  dex                          ; $80F1
  bne Loc_B2_80EE              ; $80F2
  jmp Loc_B2_811B              ; $80F4
Loc_B2_80F7:
  cmp #$50                     ; $80F7
  bcc Loc_B2_811B              ; $80F9
  lda #$00                     ; $80FB
  sta $0495                    ; $80FD
  jsr EnqueueByte              ; $8100
  jsr CallBank5_A000           ; $8103
  jsr Sub_B2_818E              ; $8106
  jmp Loc_B2_815F              ; $8109
Loc_B2_810C:
  lda #$00                     ; $810C
  sta $0497                    ; $810E
  lda z:PpuMaskShadow          ; $8111
  and #$E7                     ; $8113
  jsr SetPpuMask               ; $8115
  jmp Loc_B2_815F              ; $8118
Loc_B2_811B:
  lda PPU_STATUS               ; $811B
  jsr WaitSprite0              ; $811E
  lda PPU_STATUS               ; $8121
  lda #$2A                     ; $8124
  sta PPU_ADDR                 ; $8126
  lda #$80                     ; $8129
  sta PPU_ADDR                 ; $812B
  lda PPU_STATUS               ; $812E
  lda #$00                     ; $8131
  sta PPU_SCROLL               ; $8133
  sta PPU_SCROLL               ; $8136
  lda z:PpuCtrlShadow          ; $8139
  ora #$02                     ; $813B
  sta z:PpuCtrlShadow          ; $813D
  ldy #$0A                     ; $813F
Loc_B2_8141:
  dey                          ; $8141
  bne Loc_B2_8141              ; $8142
  lda #$05                     ; $8144
  sta MMC1_CHR1                ; $8146
  lsr a                        ; $8149
  sta MMC1_CHR1                ; $814A
  lsr a                        ; $814D
  sta MMC1_CHR1                ; $814E
  lsr a                        ; $8151
  sta MMC1_CHR1                ; $8152
  lsr a                        ; $8155
  sta MMC1_CHR1                ; $8156
  jsr TickClock                ; $8159
Loc_B2_815C:
  jsr CallBank5_A000           ; $815C
Loc_B2_815F:
  lda z:PpuCtrlShadow          ; $815F
  ora #$80                     ; $8161
  jsr SetPpuCtrl               ; $8163
  rti                          ; $8166
Sub_B2_8167:
  lda z:PaletteSetIndex        ; $8167
  sec                          ; $8169
  sbc #$50                     ; $816A
  tay                          ; $816C
  lda Data_B2_8174,y           ; $816D
  jsr EnqueueByte              ; $8170
  rts                          ; $8173
Data_B2_8174:
  .incbin "prg_bank_2.bin", $0174, $1A  ; $8174
Sub_B2_818E:
  lda z:PaletteSetIndex        ; $818E
  cmp #$69                     ; $8190
  bne Loc_B2_8199              ; $8192
  lda #$0C                     ; $8194
  jmp Loc_B2_819B              ; $8196
Loc_B2_8199:
  lda #$00                     ; $8199
Loc_B2_819B:
  sta z:GameState              ; $819B
  lda #$00                     ; $819D
  sta z:MmcPrgShadow           ; $819F
  sta z:PaletteDirty           ; $81A1
  lda z:PaletteSetIndex        ; $81A3
  sec                          ; $81A5
  sbc #$50                     ; $81A6
  sta z:Tmp00                  ; $81A8
  asl a                        ; $81AA
  clc                          ; $81AB
  adc z:Tmp00                  ; $81AC
  tay                          ; $81AE
  lda #$01                     ; $81AF
  sta z:$28                    ; $81B1
  lda Data_B2_81C3,y           ; $81B3
  sta z:$29                    ; $81B6
  lda Data_B2_81C4,y           ; $81B8
  sta z:$2A                    ; $81BB
  lda Data_B2_81C5,y           ; $81BD
  sta z:$2B                    ; $81C0
  rts                          ; $81C2
Data_B2_81C3:
  .incbin "prg_bank_2.bin", $01C3, $1  ; $81C3
Data_B2_81C4:
  .incbin "prg_bank_2.bin", $01C4, $1  ; $81C4
Data_B2_81C5:
  .incbin "prg_bank_2.bin", $01C5, $4C  ; $81C5
Sub_B2_8211:
  lda z:PpuMaskShadow          ; $8211
  and #$E7                     ; $8213
  jsr SetPpuMask               ; $8215
  lda z:PpuCtrlShadow          ; $8218
  and #$FC                     ; $821A
  sta z:PpuCtrlShadow          ; $821C
  lda #$4E                     ; $821E
  sta z:ScrollY                ; $8220
  lda #$F8                     ; $8222
  sta z:ScrollX                ; $8224
  ldx #$00                     ; $8226
  stx z:$15                    ; $8228
  stx $0101                    ; $822A
  jsr Sub_B2_827E              ; $822D
  lda #$01                     ; $8230
  sta z:ScrollPage             ; $8232
  jsr LoadPaletteSet           ; $8234
  jsr UploadPalette            ; $8237
  jsr ApplyScroll              ; $823A
  lda #$F0                     ; $823D
  ldx #$00                     ; $823F
Loc_B2_8241:
  sta OamBuffer,x              ; $8241
  inx                          ; $8244
  bne Loc_B2_8241              ; $8245
  ldx #$00                     ; $8247
  ldy #$38                     ; $8249
Loc_B2_824B:
  lda Data_B2_82BB,x           ; $824B
  sta OamBuffer,x              ; $824E
  inx                          ; $8251
  cpx #$2C                     ; $8252
  bcc Loc_B2_824B              ; $8254
Loc_B2_8256:
  lda Data_B2_82BB,x           ; $8256
  sta OamBuffer,y              ; $8259
  iny                          ; $825C
  inx                          ; $825D
  cpx #$44                     ; $825E
  bcc Loc_B2_8256              ; $8260
  lda #$A8                     ; $8262
  sta $022C                    ; $8264
  sta $0230                    ; $8267
  sta $0234                    ; $826A
  lda #$00                     ; $826D
  sta $022E                    ; $826F
  sta $0232                    ; $8272
  sta $0236                    ; $8275
  jsr ProcessPpuUpdateList     ; $8278
  .addr Data_B2_82FF  ; $827B inline pointer (data after a JSR)
  rts                          ; $827D
Sub_B2_827E:
  lda z:PaletteSetIndex        ; $827E
  sec                          ; $8280
  sbc #$50                     ; $8281
  asl a                        ; $8283
  asl a                        ; $8284
  tax                          ; $8285
  lda Data_B2_9150,x           ; $8286
  sta z:$2C                    ; $8289
  lda Data_B2_9151,x           ; $828B
  sta z:$2D                    ; $828E
  lda Data_B2_9152,x           ; $8290
  jsr LsrA4                    ; $8293
  sta $0111                    ; $8296
  lda Data_B2_9152,x           ; $8299
  and #$0F                     ; $829C
  sta $0112                    ; $829E
  lda Data_B2_9153,x           ; $82A1
  and #$70                     ; $82A4
  jsr LsrA4                    ; $82A6
  ora #$18                     ; $82A9
  sta z:MmcChr0Shadow          ; $82AB
  jsr MmcWriteChr0             ; $82AD
  lda Data_B2_9153,x           ; $82B0
  and #$0F                     ; $82B3
  sta z:MmcChr1Shadow          ; $82B5
  jsr MmcWriteChr1             ; $82B7
  rts                          ; $82BA
Data_B2_82BB:
  .incbin "prg_bank_2.bin", $02BB, $44  ; $82BB
Data_B2_82FF:
  .incbin "prg_bank_2.bin", $02FF, $7B  ; $82FF
Sub_B2_837A:
  lda z:ScrollPage             ; $837A
  cmp #$02                     ; $837C
  bne Loc_B2_83A9              ; $837E
  lda z:ScrollX                ; $8380
  cmp #$F8                     ; $8382
  bne Loc_B2_83A9              ; $8384
  lda #$03                     ; $8386
  sta z:ScrollPage             ; $8388
  lda #$00                     ; $838A
  sta z:ScrollX                ; $838C
  sta JoyHeld1                 ; $838E
  inc z:GameState              ; $8391
  lda z:PaletteSetIndex        ; $8393
  sec                          ; $8395
  sbc #$50                     ; $8396
  asl a                        ; $8398
  asl a                        ; $8399
  tax                          ; $839A
  inx                          ; $839B
  inx                          ; $839C
  inx                          ; $839D
  lda Data_B2_9150,x           ; $839E
  and #$80                     ; $83A1
  sta $0101                    ; $83A3
  jmp Loc_B2_83C6              ; $83A6
Loc_B2_83A9:
  lda z:ScrollX                ; $83A9
  clc                          ; $83AB
  adc #$10                     ; $83AC
  sta z:ScrollX                ; $83AE
  bcc Loc_B2_83B4              ; $83B0
  inc z:ScrollPage             ; $83B2
Loc_B2_83B4:
  lda #$80                     ; $83B4
  sta JoyHeld1                 ; $83B6
  jsr DoOamDma                 ; $83B9
  jsr Sub_C5AC                 ; $83BC
  jsr ApplyScroll              ; $83BF
  dec z:ScrollX                ; $83C2
  dec z:ScrollX                ; $83C4
Loc_B2_83C6:
  rts                          ; $83C6
Sub_B2_83C7:
  lda ObjectCount              ; $83C7
  beq Loc_B2_8439              ; $83CA
  sta z:Tmp02                  ; $83CC
  lda #$10                     ; $83CE
  sta z:Tmp00                  ; $83D0
  lda #$03                     ; $83D2
  sta z:Tmp01                  ; $83D4
Loc_B2_83D6:
  ldy #$00                     ; $83D6
  lda (Tmp00),y                ; $83D8
  cmp #$C1                     ; $83DA
  bne Loc_B2_842E              ; $83DC
  ldy #$07                     ; $83DE
  lda (Tmp00),y                ; $83E0
  and #$20                     ; $83E2
  bne Loc_B2_842E              ; $83E4
  ldy #$0E                     ; $83E6
  lda (Tmp00),y                ; $83E8
  bpl Loc_B2_83F1              ; $83EA
  lda #$02                     ; $83EC
  jmp Loc_B2_8404              ; $83EE
Loc_B2_83F1:
  ldy #$02                     ; $83F1
  lda (Tmp00),y                ; $83F3
  cmp #$60                     ; $83F5
  bcc Loc_B2_8402              ; $83F7
  cmp #$A0                     ; $83F9
  bcs Loc_B2_8402              ; $83FB
  lda #$00                     ; $83FD
  jmp Loc_B2_8404              ; $83FF
Loc_B2_8402:
  lda #$01                     ; $8402
Loc_B2_8404:
  sta z:Tmp03                  ; $8404
  lda z:PaletteSetIndex        ; $8406
  sec                          ; $8408
  sbc #$50                     ; $8409
  sta z:$04                    ; $840B
  asl a                        ; $840D
  clc                          ; $840E
  adc z:$04                    ; $840F
  adc z:Tmp03                  ; $8411
  tax                          ; $8413
  lda Data_B2_843A,x           ; $8414
  sta z:Tmp03                  ; $8417
  lda z:PlayerLifeLo           ; $8419
  sec                          ; $841B
  sbc z:Tmp03                  ; $841C
  sta z:PlayerLifeLo           ; $841E
  bcs Loc_B2_8426              ; $8420
  lda #$00                     ; $8422
  sta z:PlayerLifeLo           ; $8424
Loc_B2_8426:
  ldy #$07                     ; $8426
  lda (Tmp00),y                ; $8428
  ora #$20                     ; $842A
  sta (Tmp00),y                ; $842C
Loc_B2_842E:
  lda #$10                     ; $842E
  clc                          ; $8430
  adc z:Tmp00                  ; $8431
  sta z:Tmp00                  ; $8433
  dec z:Tmp02                  ; $8435
  bne Loc_B2_83D6              ; $8437
Loc_B2_8439:
  rts                          ; $8439
Data_B2_843A:
  .incbin "prg_bank_2.bin", $043A, $4E  ; $843A
Sub_B2_8488:
  lda $04AA                    ; $8488
  and #$7F                     ; $848B
  cmp #$06                     ; $848D
  bne Loc_B2_8494              ; $848F
  jmp Loc_B2_851C              ; $8491
Loc_B2_8494:
  lda ObjectCount              ; $8494
  cmp #$01                     ; $8497
  bne Loc_B2_84A0              ; $8499
  lda $04AB                    ; $849B
  beq Loc_B2_84A3              ; $849E
Loc_B2_84A0:
  jmp Loc_B2_8570              ; $84A0
Loc_B2_84A3:
  lda #$00                     ; $84A3
  sta $04AC                    ; $84A5
  inc $04AA                    ; $84A8
  lda $04AA                    ; $84AB
  and #$7F                     ; $84AE
  sta $04AA                    ; $84B0
  ldx $04AA                    ; $84B3
  dex                          ; $84B6
  dex                          ; $84B7
  txa                          ; $84B8
  asl a                        ; $84B9
  tax                          ; $84BA
  lda Data_B2_8571,x           ; $84BB
  sta z:Tmp00                  ; $84BE
  lda Data_B2_8572,x           ; $84C0
  sta z:Tmp01                  ; $84C3
  lda #$20                     ; $84C5
  sta z:Tmp02                  ; $84C7
  lda #$03                     ; $84C9
  sta z:Tmp03                  ; $84CB
  jsr Sub_B2_8A0F              ; $84CD
  inc ObjectCount              ; $84D0
  lda $04AA                    ; $84D3
  cmp #$03                     ; $84D6
  bne Loc_B2_8510              ; $84D8
  lda $032A                    ; $84DA
  ora #$04                     ; $84DD
  sta $032A                    ; $84DF
  lda $033A                    ; $84E2
  ora #$04                     ; $84E5
  sta $033A                    ; $84E7
  lda $034A                    ; $84EA
  ora #$04                     ; $84ED
  sta $034A                    ; $84EF
  lda z:FrameCounter           ; $84F2
  lsr a                        ; $84F4
  and #$01                     ; $84F5
  bne Loc_B2_84FE              ; $84F7
  ldy #$58                     ; $84F9
  jmp Loc_B2_8500              ; $84FB
Loc_B2_84FE:
  ldy #$68                     ; $84FE
Loc_B2_8500:
  jsr GetRandomByte            ; $8500
  ora #$40                     ; $8503
  sta ObjectTable,y            ; $8505
  lda #$07                     ; $8508
  sta $04AB                    ; $850A
  jmp Loc_B2_8570              ; $850D
Loc_B2_8510:
  cmp #$05                     ; $8510
  bne Loc_B2_8570              ; $8512
  lda #$78                     ; $8514
  sta $032A                    ; $8516
  jmp Loc_B2_8570              ; $8519
Loc_B2_851C:
  lda $04AA                    ; $851C
  bmi Loc_B2_853A              ; $851F
  lda ObjectCount              ; $8521
  cmp #$01                     ; $8524
  bne Loc_B2_8570              ; $8526
  lda #$80                     ; $8528
  ora $04AA                    ; $852A
  sta $04AA                    ; $852D
  lda #$00                     ; $8530
  jsr EnqueueByte              ; $8532
  lda #$1D                     ; $8535
  jsr EnqueueByte              ; $8537
Loc_B2_853A:
  lda z:FrameCounter           ; $853A
  and #$03                     ; $853C
  bne Loc_B2_8570              ; $853E
  lda $031B                    ; $8540
  cmp #$50                     ; $8543
  bcc Loc_B2_8550              ; $8545
  sec                          ; $8547
  sbc #$01                     ; $8548
  sta $031B                    ; $854A
  jmp Loc_B2_8570              ; $854D
Loc_B2_8550:
  lda $0495                    ; $8550
  bne Loc_B2_8570              ; $8553
  ldx #$00                     ; $8555
  txa                          ; $8557
Loc_B2_8558:
  sta ObjectTable,x            ; $8558
  inx                          ; $855B
  cpx #$10                     ; $855C
  bcc Loc_B2_8558              ; $855E
  lda #$00                     ; $8560
  sta ObjectCount              ; $8562
  sta $0495                    ; $8565
  inc $0495                    ; $8568
  lda #$3C                     ; $856B
  sta $0496                    ; $856D
Loc_B2_8570:
  rts                          ; $8570
Data_B2_8571:
  .incbin "prg_bank_2.bin", $0571, $1  ; $8571
Data_B2_8572:
  .incbin "prg_bank_2.bin", $0572, $97  ; $8572
Sub_B2_8609:
  lda z:PaletteSetIndex        ; $8609
  cmp #$69                     ; $860B
  bne Loc_B2_8612              ; $860D
  jmp Loc_B2_86AB              ; $860F
Loc_B2_8612:
  ldx #$00                     ; $8612
Loc_B2_8614:
  lda Data_B2_877C,x           ; $8614
  sta $04B0,x                  ; $8617
  inx                          ; $861A
  cpx #$30                     ; $861B
  bcc Loc_B2_8614              ; $861D
  lda z:PaletteSetIndex        ; $861F
  sec                          ; $8621
  sbc #$50                     ; $8622
  asl a                        ; $8624
  asl a                        ; $8625
  asl a                        ; $8626
  tay                          ; $8627
  ldx #$00                     ; $8628
Loc_B2_862A:
  lda Data_B2_86AC,y           ; $862A
  sta $04A0,x                  ; $862D
  iny                          ; $8630
  inx                          ; $8631
  cpx #$08                     ; $8632
  bcc Loc_B2_862A              ; $8634
  ldx #$00                     ; $8636
  ldy #$00                     ; $8638
Loc_B2_863A:
  lda $04A0,y                  ; $863A
  cmp #$FF                     ; $863D
  bne Loc_B2_8652              ; $863F
  lda #$43                     ; $8641
  sta $04B0,x                  ; $8643
  sta $04B1,x                  ; $8646
  sta $04C0,x                  ; $8649
  sta $04C1,x                  ; $864C
  jmp Loc_B2_8658              ; $864F
Loc_B2_8652:
  clc                          ; $8652
  adc #$EB                     ; $8653
  sta $04D1,x                  ; $8655
Loc_B2_8658:
  inx                          ; $8658
  inx                          ; $8659
  iny                          ; $865A
  cpy #$08                     ; $865B
  bcc Loc_B2_863A              ; $865D
  lda z:PaletteSetIndex        ; $865F
  cmp #$52                     ; $8661
  bne Loc_B2_8676              ; $8663
  ldy #$60                     ; $8665
  sty $04BE                    ; $8667
  iny                          ; $866A
  sty $04BF                    ; $866B
  iny                          ; $866E
  sty $04CE                    ; $866F
  iny                          ; $8672
  sty $04CF                    ; $8673
Loc_B2_8676:
  lda #$28                     ; $8676
  sta z:Tmp00                  ; $8678
  lda z:PpuCtrlShadow          ; $867A
  and #$FB                     ; $867C
  jsr SetPpuCtrl               ; $867E
  ldx #$00                     ; $8681
Loc_B2_8683:
  lda PPU_STATUS               ; $8683
  lda #$2B                     ; $8686
  sta PPU_ADDR                 ; $8688
  lda z:Tmp00                  ; $868B
  sta PPU_ADDR                 ; $868D
  ldy #$00                     ; $8690
Loc_B2_8692:
  lda $04B0,x                  ; $8692
  sta PPU_DATA                 ; $8695
  inx                          ; $8698
  iny                          ; $8699
  cpy #$10                     ; $869A
  bcc Loc_B2_8692              ; $869C
  lda #$20                     ; $869E
  clc                          ; $86A0
  adc z:Tmp00                  ; $86A1
  sta z:Tmp00                  ; $86A3
  ldy #$00                     ; $86A5
  cpx #$30                     ; $86A7
  bcc Loc_B2_8683              ; $86A9
Loc_B2_86AB:
  rts                          ; $86AB
Data_B2_86AC:
  .incbin "prg_bank_2.bin", $06AC, $D0  ; $86AC
Data_B2_877C:
  .incbin "prg_bank_2.bin", $077C, $30  ; $877C
Sub_B2_87AC:
  lda z:PaletteSetIndex        ; $87AC
  cmp #$69                     ; $87AE
  bne Loc_B2_87B5              ; $87B0
  jmp Loc_B2_8869              ; $87B2
Loc_B2_87B5:
  ldy #$00                     ; $87B5
  sty z:Tmp00                  ; $87B7
Loc_B2_87B9:
  lda $04A0,y                  ; $87B9
  bmi Loc_B2_87C3              ; $87BC
  clc                          ; $87BE
  adc z:Tmp00                  ; $87BF
  sta z:Tmp00                  ; $87C1
Loc_B2_87C3:
  iny                          ; $87C3
  cpy #$08                     ; $87C4
  bcc Loc_B2_87B9              ; $87C6
  lda z:Tmp00                  ; $87C8
  cmp #$01                     ; $87CA
  beq Loc_B2_87D1              ; $87CC
  jmp Loc_B2_8869              ; $87CE
Loc_B2_87D1:
  lda ObjectTable              ; $87D1
  bpl Loc_B2_87D9              ; $87D4
  jmp Loc_B2_8869              ; $87D6
Loc_B2_87D9:
  lda #$F8                     ; $87D9
  sta z:$04                    ; $87DB
  jsr Sub_B2_886A              ; $87DD
  lda $0319                    ; $87E0
  cmp z:ScrollPage             ; $87E3
  beq Loc_B2_87F5              ; $87E5
  cmp z:$05                    ; $87E7
  bne Loc_B2_87FF              ; $87E9
  lda $031A                    ; $87EB
  cmp z:$06                    ; $87EE
  bcs Loc_B2_87FF              ; $87F0
  jmp Loc_B2_8869              ; $87F2
Loc_B2_87F5:
  lda $031A                    ; $87F5
  cmp z:ScrollX                ; $87F8
  bcc Loc_B2_87FF              ; $87FA
  jmp Loc_B2_8869              ; $87FC
Loc_B2_87FF:
  lda z:ScrollX                ; $87FF
  clc                          ; $8801
  adc #$80                     ; $8802
  sta z:Tmp01                  ; $8804
  lda z:ScrollPage             ; $8806
  adc #$00                     ; $8808
  and #$03                     ; $880A
  sta z:Tmp00                  ; $880C
  lda $0319                    ; $880E
  cmp z:Tmp00                  ; $8811
  bne Loc_B2_881F              ; $8813
  lda $031A                    ; $8815
  cmp z:Tmp01                  ; $8818
  bcc Loc_B2_8844              ; $881A
  jmp Loc_B2_8849              ; $881C
Loc_B2_881F:
  inc z:Tmp00                  ; $881F
  lda z:Tmp00                  ; $8821
  and #$03                     ; $8823
  dec z:Tmp00                  ; $8825
  cmp $0319                    ; $8827
  bne Loc_B2_882F              ; $882A
  jmp Loc_B2_8849              ; $882C
Loc_B2_882F:
  dec z:Tmp00                  ; $882F
  lda z:Tmp00                  ; $8831
  and #$03                     ; $8833
  cmp $0319                    ; $8835
  bne Loc_B2_883D              ; $8838
  jmp Loc_B2_8844              ; $883A
Loc_B2_883D:
  lda $031A                    ; $883D
  cmp z:Tmp01                  ; $8840
  bcc Loc_B2_8849              ; $8842
Loc_B2_8844:
  ldy #$00                     ; $8844
  jmp Loc_B2_884B              ; $8846
Loc_B2_8849:
  ldy #$04                     ; $8849
Loc_B2_884B:
  lda z:FrameCounter           ; $884B
  and #$08                     ; $884D
  beq Loc_B2_8869              ; $884F
  lda Data_B2_887A,y           ; $8851
  sta $02DC                    ; $8854
  lda Data_B2_887B,y           ; $8857
  sta $02DD                    ; $885A
  lda Data_B2_887C,y           ; $885D
  sta $02DE                    ; $8860
  lda Data_B2_887D,y           ; $8863
  sta $02DF                    ; $8866
Loc_B2_8869:
  rts                          ; $8869
Sub_B2_886A:
  lda z:$04                    ; $886A
  clc                          ; $886C
  adc z:ScrollX                ; $886D
  sta z:$06                    ; $886F
  lda z:ScrollPage             ; $8871
  adc #$00                     ; $8873
  and #$03                     ; $8875
  sta z:$05                    ; $8877
  rts                          ; $8879
Data_B2_887A:
  .incbin "prg_bank_2.bin", $087A, $1  ; $887A
Data_B2_887B:
  .incbin "prg_bank_2.bin", $087B, $1  ; $887B
Data_B2_887C:
  .incbin "prg_bank_2.bin", $087C, $1  ; $887C
Data_B2_887D:
  .incbin "prg_bank_2.bin", $087D, $5  ; $887D
Sub_B2_8882:
  lda z:PlayerLifeHi           ; $8882
  bne Loc_B2_889C              ; $8884
  lda z:PlayerLifeLo           ; $8886
  cmp #$32                     ; $8888
  bcs Loc_B2_889C              ; $888A
  lda $04A9                    ; $888C
  bne Loc_B2_88A9              ; $888F
  lda #$42                     ; $8891
  jsr EnqueueByte              ; $8893
  inc $04A9                    ; $8896
  jmp Loc_B2_88A9              ; $8899
Loc_B2_889C:
  lda $04A9                    ; $889C
  beq Loc_B2_88A9              ; $889F
  lda #$44                     ; $88A1
  jsr EnqueueByte              ; $88A3
  dec $04A9                    ; $88A6
Loc_B2_88A9:
  rts                          ; $88A9
Sub_B2_88AA:
  lda $0497                    ; $88AA
  bne Loc_B2_88DF              ; $88AD
  lda z:PaletteSetIndex        ; $88AF
  cmp #$69                     ; $88B1
  bne Loc_B2_88C1              ; $88B3
  lda $049E                    ; $88B5
  bne Loc_B2_88C1              ; $88B8
  lda $04AA                    ; $88BA
  cmp #$06                     ; $88BD
  bne Loc_B2_88D4              ; $88BF
Loc_B2_88C1:
  lda z:PlayerLifeHi           ; $88C1
  beq Loc_B2_88D0              ; $88C3
  lda #$00                     ; $88C5
  sta z:PlayerLifeHi           ; $88C7
  lda #$C8                     ; $88C9
  sta z:PlayerLifeLo           ; $88CB
  jmp Loc_B2_8937              ; $88CD
Loc_B2_88D0:
  lda z:PlayerLifeLo           ; $88D0
  bne Loc_B2_8937              ; $88D2
Loc_B2_88D4:
  lda #$00                     ; $88D4
  sta $0498                    ; $88D6
  sta $0499                    ; $88D9
  inc $0497                    ; $88DC
Loc_B2_88DF:
  jsr DrawHud                  ; $88DF
  lda z:PaletteSetIndex        ; $88E2
  cmp #$69                     ; $88E4
  bne Loc_B2_88EB              ; $88E6
  jsr Sub_B2_8938              ; $88E8
Loc_B2_88EB:
  inc $0498                    ; $88EB
  lda $0498                    ; $88EE
  cmp #$50                     ; $88F1
  bne Loc_B2_88FD              ; $88F3
  lda #$00                     ; $88F5
  jsr EnqueueByte              ; $88F7
  jmp Loc_B2_8901              ; $88FA
Loc_B2_88FD:
  cmp #$78                     ; $88FD
  bcs Loc_B2_8911              ; $88FF
Loc_B2_8901:
  jsr MmcWriteChr1             ; $8901
  lda z:PpuCtrlShadow          ; $8904
  and #$FC                     ; $8906
  jsr SetPpuCtrl               ; $8908
  jsr ApplyScroll              ; $890B
  jmp Loc_B2_8937              ; $890E
Loc_B2_8911:
  lda #$80                     ; $8911
  sta $0497                    ; $8913
  lda #$05                     ; $8916
  sta z:MmcPrgShadow           ; $8918
  lda #$03                     ; $891A
  sta SceneState               ; $891C
  lda #$00                     ; $891F
  sta $013D                    ; $8921
  lda z:PaletteSetIndex        ; $8924
  sta $013F                    ; $8926
  cmp #$69                     ; $8929
  bne Loc_B2_8937              ; $892B
  lda $04AE                    ; $892D
  sta z:AmmoLo                 ; $8930
  lda $04AF                    ; $8932
  sta z:AmmoHi                 ; $8935
Loc_B2_8937:
  rts                          ; $8937
Sub_B2_8938:
  lda $0497                    ; $8938
  bne Loc_B2_899A              ; $893B
  lda $049E                    ; $893D
  beq Loc_B2_899A              ; $8940
  lda $04AA                    ; $8942
  and #$7F                     ; $8945
  cmp #$06                     ; $8947
  beq Loc_B2_899A              ; $8949
  inc $049A                    ; $894B
  lda $049A                    ; $894E
  cmp #$3C                     ; $8951
  bcc Loc_B2_8993              ; $8953
  dec $049E                    ; $8955
  lda #$00                     ; $8958
  sta $049A                    ; $895A
  lda $049B                    ; $895D
  beq Loc_B2_8968              ; $8960
  dec $049B                    ; $8962
  jmp Loc_B2_8993              ; $8965
Loc_B2_8968:
  lda #$09                     ; $8968
  sta $049B                    ; $896A
  lda $049C                    ; $896D
  beq Loc_B2_8978              ; $8970
  dec $049C                    ; $8972
  jmp Loc_B2_8993              ; $8975
Loc_B2_8978:
  lda $049D                    ; $8978
  beq Loc_B2_8988              ; $897B
  lda #$05                     ; $897D
  sta $049C                    ; $897F
  dec $049D                    ; $8982
  jmp Loc_B2_8993              ; $8985
Loc_B2_8988:
  lda #$00                     ; $8988
  sta $049B                    ; $898A
  sta $049C                    ; $898D
  sta $049D                    ; $8990
Loc_B2_8993:
  lda $049A                    ; $8993
  cmp #$23                     ; $8996
  bcs Loc_B2_89C3              ; $8998
Loc_B2_899A:
  ldx #$00                     ; $899A
Loc_B2_899C:
  lda Data_B2_89D2,x           ; $899C
  sta $02F0,x                  ; $899F
  inx                          ; $89A2
  cpx #$10                     ; $89A3
  bcc Loc_B2_899C              ; $89A5
  lda $049B                    ; $89A7
  asl a                        ; $89AA
  adc #$E4                     ; $89AB
  sta $02F1                    ; $89AD
  lda $049C                    ; $89B0
  asl a                        ; $89B3
  adc #$E4                     ; $89B4
  sta $02F5                    ; $89B6
  lda $049D                    ; $89B9
  asl a                        ; $89BC
  adc #$E4                     ; $89BD
  sta $02F9                    ; $89BF
  rts                          ; $89C2
Loc_B2_89C3:
  lda #$F0                     ; $89C3
  sta $02F0                    ; $89C5
  sta $02F4                    ; $89C8
  sta $02F8                    ; $89CB
  sta $02FC                    ; $89CE
  rts                          ; $89D1
Data_B2_89D2:
  .incbin "prg_bank_2.bin", $09D2, $10  ; $89D2
Sub_B2_89E2:
  lda #$00                     ; $89E2
  ldy #$00                     ; $89E4
Loc_B2_89E6:
  sta ObjectTable,y            ; $89E6
  iny                          ; $89E9
  cpy #$F0                     ; $89EA
  bne Loc_B2_89E6              ; $89EC
  lda #$00                     ; $89EE
  sta $0303                    ; $89F0
  sta $0495                    ; $89F3
  lda z:PaletteSetIndex        ; $89F6
  sec                          ; $89F8
  sbc #$50                     ; $89F9
  asl a                        ; $89FB
  tax                          ; $89FC
  lda Data_B2_8B16,x           ; $89FD
  sta z:Tmp00                  ; $8A00
  lda Data_B2_8B17,x           ; $8A02
  sta z:Tmp01                  ; $8A05
  lda #$10                     ; $8A07
  sta z:Tmp02                  ; $8A09
  lda #$03                     ; $8A0B
  sta z:Tmp03                  ; $8A0D
Sub_B2_8A0F:
  ldy #$00                     ; $8A0F
  lda (Tmp00),y                ; $8A11
  sta ObjectCount              ; $8A13
  bne Loc_B2_8A1B              ; $8A16
  jmp Loc_B2_8AAF              ; $8A18
Loc_B2_8A1B:
  sta z:$04                    ; $8A1B
  ldx #$00                     ; $8A1D
  dec z:Tmp02                  ; $8A1F
Loc_B2_8A21:
  iny                          ; $8A21
  lda (Tmp00),y                ; $8A22
  cmp #$44                     ; $8A24
  bne Loc_B2_8A33              ; $8A26
  lda #$0E                     ; $8A28
  sta z:$06                    ; $8A2A
  lda #$8B                     ; $8A2C
  sta z:$07                    ; $8A2E
  jmp Loc_B2_8ACB              ; $8A30
Loc_B2_8A33:
  cmp #$45                     ; $8A33
  bne Loc_B2_8A42              ; $8A35
  lda #$12                     ; $8A37
  sta z:$06                    ; $8A39
  lda #$8B                     ; $8A3B
  sta z:$07                    ; $8A3D
  jmp Loc_B2_8ACB              ; $8A3F
Loc_B2_8A42:
  dey                          ; $8A42
  jsr Sub_B2_8AB0              ; $8A43
  inc z:Tmp02                  ; $8A46
  inc z:Tmp02                  ; $8A48
  inc z:Tmp02                  ; $8A4A
  jsr Sub_B2_8AB0              ; $8A4C
  jsr Sub_B2_8AB0              ; $8A4F
  jsr Sub_B2_8AB0              ; $8A52
  jsr Sub_B2_8AB0              ; $8A55
  jsr Sub_B2_8AB0              ; $8A58
  iny                          ; $8A5B
  inc z:Tmp02                  ; $8A5C
  jsr Sub_B2_8AB8              ; $8A5E
  jsr Sub_B2_8AB0              ; $8A61
  jsr Sub_B2_8AB0              ; $8A64
  jsr Sub_B2_8AB0              ; $8A67
Loc_B2_8A6A:
  inc z:Tmp02                  ; $8A6A
  inc z:Tmp02                  ; $8A6C
  dec z:$04                    ; $8A6E
  bne Loc_B2_8A21              ; $8A70
  lda z:PaletteSetIndex        ; $8A72
  cmp #$69                     ; $8A74
  bne Loc_B2_8AAF              ; $8A76
  lda $04AA                    ; $8A78
  cmp #$03                     ; $8A7B
  bcs Loc_B2_8AAF              ; $8A7D
  jsr GetRandomByte            ; $8A7F
  and #$01                     ; $8A82
  bne Loc_B2_8A8B              ; $8A84
  ldy #$48                     ; $8A86
  jmp Loc_B2_8A8D              ; $8A88
Loc_B2_8A8B:
  ldy #$38                     ; $8A8B
Loc_B2_8A8D:
  jsr GetRandomByte            ; $8A8D
  ora #$C0                     ; $8A90
  sta ObjectTable,y            ; $8A92
  lda $032A                    ; $8A95
  ora #$04                     ; $8A98
  sta $032A                    ; $8A9A
  lda $033A                    ; $8A9D
  ora #$04                     ; $8AA0
  sta $033A                    ; $8AA2
  lda #$00                     ; $8AA5
  sta $04AC                    ; $8AA7
  lda #$03                     ; $8AAA
  sta $04AB                    ; $8AAC
Loc_B2_8AAF:
  rts                          ; $8AAF
Sub_B2_8AB0:
  iny                          ; $8AB0
  inc z:Tmp02                  ; $8AB1
  lda (Tmp00),y                ; $8AB3
  sta (Tmp02,x)                ; $8AB5
  rts                          ; $8AB7
Sub_B2_8AB8:
  lda (Tmp00),y                ; $8AB8
  sta z:$05                    ; $8ABA
  jsr LsrA4                    ; $8ABC
  sta (Tmp02,x)                ; $8ABF
  lda z:$05                    ; $8AC1
  jsr AslA4                    ; $8AC3
  inc z:Tmp02                  ; $8AC6
  sta (Tmp02,x)                ; $8AC8
  rts                          ; $8ACA
Loc_B2_8ACB:
  tya                          ; $8ACB
  pha                          ; $8ACC
  inc z:Tmp02                  ; $8ACD
  lda (Tmp00),y                ; $8ACF
  sta (Tmp02,x)                ; $8AD1
  lda z:Tmp02                  ; $8AD3
  clc                          ; $8AD5
  adc #$03                     ; $8AD6
  sta z:Tmp02                  ; $8AD8
  ldy #$FF                     ; $8ADA
  jsr Sub_B2_8B06              ; $8ADC
  jsr Sub_B2_8B06              ; $8ADF
  inc z:Tmp02                  ; $8AE2
  pla                          ; $8AE4
  tay                          ; $8AE5
  iny                          ; $8AE6
  tya                          ; $8AE7
  pha                          ; $8AE8
  lda (Tmp00),y                ; $8AE9
  sta (Tmp02,x)                ; $8AEB
  ldy #$01                     ; $8AED
  jsr Sub_B2_8B06              ; $8AEF
  jsr Sub_B2_8B06              ; $8AF2
  pla                          ; $8AF5
  tay                          ; $8AF6
  iny                          ; $8AF7
  inc z:Tmp02                  ; $8AF8
  jsr Sub_B2_8AB8              ; $8AFA
  inc z:Tmp02                  ; $8AFD
  inc z:Tmp02                  ; $8AFF
  inc z:Tmp02                  ; $8B01
  jmp Loc_B2_8A6A              ; $8B03
Sub_B2_8B06:
  iny                          ; $8B06
  inc z:Tmp02                  ; $8B07
  lda ($06),y                  ; $8B09
  sta (Tmp02,x)                ; $8B0B
  rts                          ; $8B0D
  .incbin "prg_bank_2.bin", $0B0E, $8  ; $8B0E
Data_B2_8B16:
  .incbin "prg_bank_2.bin", $0B16, $1  ; $8B16
Data_B2_8B17:
  .incbin "prg_bank_2.bin", $0B17, $400  ; $8B17
  .incbin "prg_bank_2.bin", $0F17, $199  ; $8F17
Sub_B2_90B0:
  lda $04A8                    ; $90B0
  bne Loc_B2_90B8              ; $90B3
  jmp Loc_B2_912A              ; $90B5
Loc_B2_90B8:
  lda $04A8                    ; $90B8
  and #$0F                     ; $90BB
  tax                          ; $90BD
  lda PPU_STATUS               ; $90BE
  lda #$2B                     ; $90C1
  sta PPU_ADDR                 ; $90C3
  lda Data_B2_912B,x           ; $90C6
  sta PPU_ADDR                 ; $90C9
  lda $04A0,x                  ; $90CC
  beq Loc_B2_90DA              ; $90CF
  clc                          ; $90D1
  adc #$EB                     ; $90D2
  sta PPU_DATA                 ; $90D4
  jmp Loc_B2_911B              ; $90D7
Loc_B2_90DA:
  lda #$FF                     ; $90DA
  sta PPU_DATA                 ; $90DC
  sta $04A0,x                  ; $90DF
  lda z:PpuCtrlShadow          ; $90E2
  and #$FB                     ; $90E4
  jsr SetPpuCtrl               ; $90E6
  lda PPU_STATUS               ; $90E9
  lda #$2B                     ; $90EC
  sta PPU_ADDR                 ; $90EE
  lda Data_B2_912B,x           ; $90F1
  sec                          ; $90F4
  sbc #$21                     ; $90F5
  sta z:Tmp00                  ; $90F7
  sbc #$20                     ; $90F9
  sta PPU_ADDR                 ; $90FB
  lda #$43                     ; $90FE
  sta PPU_DATA                 ; $9100
  sta PPU_DATA                 ; $9103
  lda PPU_STATUS               ; $9106
  lda #$2B                     ; $9109
  sta PPU_ADDR                 ; $910B
  lda z:Tmp00                  ; $910E
  sta PPU_ADDR                 ; $9110
  lda #$43                     ; $9113
  sta PPU_DATA                 ; $9115
  sta PPU_DATA                 ; $9118
Loc_B2_911B:
  lda $04A8                    ; $911B
  bpl Loc_B2_9125              ; $911E
  lda #$01                     ; $9120
  sta $031C                    ; $9122
Loc_B2_9125:
  lda #$00                     ; $9125
  sta $04A8                    ; $9127
Loc_B2_912A:
  rts                          ; $912A
Data_B2_912B:
  .incbin "prg_bank_2.bin", $112B, $25  ; $912B
Data_B2_9150:
  .incbin "prg_bank_2.bin", $1150, $1  ; $9150
Data_B2_9151:
  .incbin "prg_bank_2.bin", $1151, $1  ; $9151
Data_B2_9152:
  .incbin "prg_bank_2.bin", $1152, $1  ; $9152
Data_B2_9153:
  .incbin "prg_bank_2.bin", $1153, $400  ; $9153
  .incbin "prg_bank_2.bin", $1553, $400  ; $9553
  .incbin "prg_bank_2.bin", $1953, $400  ; $9953
  .incbin "prg_bank_2.bin", $1D53, $2AD  ; $9D53
Sub_B2_A000:
  .incbin "prg_bank_2.bin", $2000, $400  ; $A000
  .incbin "prg_bank_2.bin", $2400, $400  ; $A400
  .incbin "prg_bank_2.bin", $2800, $400  ; $A800
  .incbin "prg_bank_2.bin", $2C00, $400  ; $AC00
  .incbin "prg_bank_2.bin", $3000, $400  ; $B000
  .incbin "prg_bank_2.bin", $3400, $400  ; $B400
  .incbin "prg_bank_2.bin", $3800, $400  ; $B800
  .incbin "prg_bank_2.bin", $3C00, $3FD  ; $BC00
Data_B2_BFFD:
  .incbin "prg_bank_2.bin", $3FFD, $3  ; $BFFD
