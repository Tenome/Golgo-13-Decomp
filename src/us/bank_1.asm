; Bank 1  ($8000-$BFFF switchable)
; Street-scene object and enemy routines (object table at $0310, 16 bytes each) and the game-over screen ('The man with the custom M-16').
.segment "PRG_BANK_1"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B1_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_1.bin", $0009, $7  ; $8009
Bank1Nmi:
  lda PPU_STATUS               ; $8010
  lda #$10                     ; $8013
  jsr SetPpuCtrl               ; $8015
  jsr DoOamDma                 ; $8018
  jsr Bank1Dispatch_SceneState ; $801B
  jsr Sub_B1_80DC              ; $801E
  ldy #$00                     ; $8021
Loc_B1_8023:
  dey                          ; $8023
  bne Loc_B1_8023              ; $8024
  lda PPU_STATUS               ; $8026
  lda #$B0                     ; $8029
  jsr SetPpuCtrl               ; $802B
  rti                          ; $802E
Bank1Dispatch_SceneState:
  lda SceneState               ; $802F
  asl a                        ; $8032
  tax                          ; $8033
  lda Data_B1_8041,x           ; $8034
  sta z:Tmp00                  ; $8037
  lda Data_B1_8042,x           ; $8039
  sta z:Tmp01                  ; $803C
  jmp ($0000)                  ; $803E
Data_B1_8041:
  .addr Sub_B1_8049, Sub_B1_8054, Sub_B1_805D, Sub_B1_80A5  ; $8041 pointer table
Sub_B1_8049:
  inc SceneState               ; $8049
  jsr Sub_B1_85A0              ; $804C
Sub_B1_804F:
  lda #$00                     ; $804F
  jmp SetPpuMask               ; $8051
Sub_B1_8054:
  inc SceneState               ; $8054
  jsr Sub_B1_83D5              ; $8057
  jmp ReadJoypads              ; $805A
Sub_B1_805D:
  jsr Sub_B1_8146              ; $805D
  lda #$1E                     ; $8060
  jsr SetPpuMask               ; $8062
  ldy #$03                     ; $8065
  sty z:MmcChr1Shadow          ; $8067
  jsr MmcWriteChr1             ; $8069
  jsr Sub_B1_80D1              ; $806C
  jsr ReadJoypads              ; $806F
  jsr Sub_B1_80FD              ; $8072
  lda $0551                    ; $8075
  bne Loc_B1_8083              ; $8078
  ldx $0550                    ; $807A
  dex                          ; $807D
  bne Loc_B1_8083              ; $807E
  jsr Sub_B1_85B8              ; $8080
Loc_B1_8083:
  bit PPU_STATUS               ; $8083
  bvs Loc_B1_8083              ; $8086
Loc_B1_8088:
  bit PPU_STATUS               ; $8088
  bvc Loc_B1_8088              ; $808B
  ldy #$0E                     ; $808D
  sty z:MmcChr1Shadow          ; $808F
  jsr MmcWriteChr1             ; $8091
  ldx #$0A                     ; $8094
  ldy #$25                     ; $8096
Loc_B1_8098:
  dey                          ; $8098
  bne Loc_B1_8098              ; $8099
  dex                          ; $809B
  bne Loc_B1_8098              ; $809C
  ldy #$0D                     ; $809E
  sty z:MmcChr1Shadow          ; $80A0
  jmp MmcWriteChr1             ; $80A2
Sub_B1_80A5:
  jsr Sub_B1_804F              ; $80A5
  jsr FillPaletteBlack         ; $80A8
  jsr Sub_B1_812B              ; $80AB
  jsr Sub_B1_85AC              ; $80AE
  jsr ApplyScroll              ; $80B1
  jsr MmcWriteControl          ; $80B4
  jsr MmcWriteChr0             ; $80B7
  jsr MmcWriteChr1             ; $80BA
  lda #$00                     ; $80BD
  sta z:MmcPrgShadow           ; $80BF
  lda #$08                     ; $80C1
  sta JoyHeld1                 ; $80C3
  sta JoyHeld2                 ; $80C6
  sta JoyNew1                  ; $80C9
  lda #$00                     ; $80CC
  jmp EnqueueByte              ; $80CE
Sub_B1_80D1:
  lda JoyNew1                  ; $80D1
  and #$08                     ; $80D4
  beq Loc_B1_80DB              ; $80D6
  inc SceneState               ; $80D8
Loc_B1_80DB:
  rts                          ; $80DB
Sub_B1_80DC:
  lda $0550                    ; $80DC
  ora $0551                    ; $80DF
  beq Loc_B1_80EF              ; $80E2
  lda $0550                    ; $80E4
  bne Loc_B1_80EC              ; $80E7
  dec $0551                    ; $80E9
Loc_B1_80EC:
  dec $0550                    ; $80EC
Loc_B1_80EF:
  lda z:MmcPrgShadow           ; $80EF
  pha                          ; $80F1
  lda #$01                     ; $80F2
  sta z:MmcPrgShadow           ; $80F4
  jsr CallBank5_A000           ; $80F6
  pla                          ; $80F9
  sta z:MmcPrgShadow           ; $80FA
  rts                          ; $80FC
Sub_B1_80FD:
  lda $0552                    ; $80FD
  cmp #$C8                     ; $8100
  bcs Loc_B1_812A              ; $8102
  lda $0550                    ; $8104
  and #$01                     ; $8107
  bne Loc_B1_812A              ; $8109
  ldy $0553                    ; $810B
  ldx #$01                     ; $810E
  stx JOYPAD1                  ; $8110
  dex                          ; $8113
  stx JOYPAD1                  ; $8114
  lda JOYPAD1                  ; $8117
  sta $0553                    ; $811A
  tya                          ; $811D
  eor #$FF                     ; $811E
  and $0553                    ; $8120
  and #$04                     ; $8123
  beq Loc_B1_812A              ; $8125
  inc $0552                    ; $8127
Loc_B1_812A:
  rts                          ; $812A
Sub_B1_812B:
  ldy PPU_STATUS               ; $812B
  ldy #$20                     ; $812E
  sty PPU_ADDR                 ; $8130
  ldy #$00                     ; $8133
  sty PPU_ADDR                 ; $8135
  lda #$FF                     ; $8138
  ldx #$04                     ; $813A
Loc_B1_813C:
  sta PPU_DATA                 ; $813C
  dey                          ; $813F
  bne Loc_B1_813C              ; $8140
  dex                          ; $8142
  bne Loc_B1_813C              ; $8143
  rts                          ; $8145
Sub_B1_8146:
  rts                          ; $8146
  ldy $0556                    ; $8147  [heuristic code]
  beq Loc_B1_816D              ; $814A
  ldy PPU_STATUS               ; $814C
  ldy #$23                     ; $814F
  sty PPU_ADDR                 ; $8151
  ldy #$08                     ; $8154
  sty PPU_ADDR                 ; $8156
  ldx #$00                     ; $8159
  ldy #$30                     ; $815B
Loc_B1_815D:
  lda $0520,x                  ; $815D
  sta PPU_DATA                 ; $8160
  inx                          ; $8163
  dey                          ; $8164
  bne Loc_B1_815D              ; $8165
  sty $0556                    ; $8167
  jmp ApplyScroll              ; $816A
Loc_B1_816D:
  lda $0554                    ; $816D
  ora $0555                    ; $8170
  beq Loc_B1_8182              ; $8173
  ldy $0554                    ; $8175
  bne Loc_B1_817D              ; $8178
  dec $0555                    ; $817A
Loc_B1_817D:
  dey                          ; $817D
  sty $0554                    ; $817E
  rts                          ; $8181
Loc_B1_8182:
  lda #$FF                     ; $8182
  ldy #$2F                     ; $8184
Loc_B1_8186:
  sta $0520,y                  ; $8186
  dey                          ; $8189
  bpl Loc_B1_8186              ; $818A
  ldy $0557                    ; $818C
  lda Data_B1_8209,y           ; $818F
  bpl Loc_B1_8195              ; $8192
  rts                          ; $8194
Loc_B1_8195:
  asl a                        ; $8195
  tay                          ; $8196
  lda Data_B1_81D7,y           ; $8197
  sta z:Tmp00                  ; $819A
  lda Data_B1_81D8,y           ; $819C
  sta z:Tmp01                  ; $819F
  ldy #$00                     ; $81A1
  lda (Tmp00),y                ; $81A3
  sta $0554                    ; $81A5
  iny                          ; $81A8
  lda (Tmp00),y                ; $81A9
  sta $0555                    ; $81AB
  iny                          ; $81AE
Loc_B1_81AF:
  lda (Tmp00),y                ; $81AF
  bmi Loc_B1_81BD              ; $81B1
  tax                          ; $81B3
  lda #$AE                     ; $81B4
  sta $0520,x                  ; $81B6
  iny                          ; $81B9
  jmp Loc_B1_81AF              ; $81BA
Loc_B1_81BD:
  iny                          ; $81BD
  lda (Tmp00),y                ; $81BE
  iny                          ; $81C0
  ora #$20                     ; $81C1
  tax                          ; $81C3
Loc_B1_81C4:
  lda (Tmp00),y                ; $81C4
  beq Loc_B1_81D0              ; $81C6
  sta $0520,x                  ; $81C8
  inx                          ; $81CB
  iny                          ; $81CC
  jmp Loc_B1_81C4              ; $81CD
Loc_B1_81D0:
  inc $0556                    ; $81D0
  inc $0557                    ; $81D3
  rts                          ; $81D6
Data_B1_81D7:
  .incbin "prg_bank_1.bin", $01D7, $1  ; $81D7
Data_B1_81D8:
  .incbin "prg_bank_1.bin", $01D8, $31  ; $81D8
Data_B1_8209:
  .incbin "prg_bank_1.bin", $0209, $1CC  ; $8209
Sub_B1_83D5:
  jsr ProcessPpuUpdateList     ; $83D5
  .addr Data_B1_8448  ; $83D8 inline pointer (data after a JSR)
  ldy #$08                     ; $83DA
  sty z:HwScrollX              ; $83DC
  ldy #$00                     ; $83DE
  sty z:HwScrollY              ; $83E0
  sty $0554                    ; $83E2
  sty $0555                    ; $83E5
  sty $0552                    ; $83E8
  sty $0556                    ; $83EB
  sty $0557                    ; $83EE
  ldy #$1D                     ; $83F1
  sty z:MmcControlShadow       ; $83F3
  ldy #$0C                     ; $83F5
  sty z:MmcChr0Shadow          ; $83F7
  jsr MmcWriteControl          ; $83F9
  jsr MmcWriteChr0             ; $83FC
  jsr Sub_B1_812B              ; $83FF
  jsr ProcessPpuUpdateList     ; $8402
  .addr Data_B1_8460  ; $8405 inline pointer (data after a JSR)
  jsr ProcessPpuUpdateList     ; $8407
  .addr Data_B1_84D2  ; $840A inline pointer (data after a JSR)
  ldy #$03                     ; $840C
Loc_B1_840E:
  lda Data_B1_859C,y           ; $840E
  sta OamBuffer,y              ; $8411
  dey                          ; $8414
  bpl Loc_B1_840E              ; $8415
  lda #$F0                     ; $8417
  ldy #$38                     ; $8419
Loc_B1_841B:
  sta OamBuffer,y              ; $841B
  iny                          ; $841E
  bne Loc_B1_841B              ; $841F
  jsr ApplyScroll              ; $8421
  lda #$34                     ; $8424
  sta $0550                    ; $8426
  sta $0551                    ; $8429
  lda #$00                     ; $842C
  sta APU_DMC_FREQ             ; $842E
  sta APU_DMC_RAW              ; $8431
  lda #$0F                     ; $8434
  sta APU_SND_CHN              ; $8436
  lda #$C0                     ; $8439
  sta JOYPAD2                  ; $843B
  lda #$00                     ; $843E
  jsr EnqueueByte              ; $8440
  lda #$01                     ; $8443
  jmp EnqueueByte              ; $8445
Data_B1_8448:
  .incbin "prg_bank_1.bin", $0448, $18  ; $8448
Data_B1_8460:
  .incbin "prg_bank_1.bin", $0460, $72  ; $8460
Data_B1_84D2:
  .incbin "prg_bank_1.bin", $04D2, $CA  ; $84D2
Data_B1_859C:
  .incbin "prg_bank_1.bin", $059C, $4  ; $859C
Sub_B1_85A0:
  ldy #$07                     ; $85A0
Loc_B1_85A2:
  lda a:MmcControlShadow,y     ; $85A2
  sta $0510,y                  ; $85A5
  dey                          ; $85A8
  bpl Loc_B1_85A2              ; $85A9
  rts                          ; $85AB
Sub_B1_85AC:
  ldy #$07                     ; $85AC
Loc_B1_85AE:
  lda $0510,y                  ; $85AE
  sta a:MmcControlShadow,y     ; $85B1
  dey                          ; $85B4
  bpl Loc_B1_85AE              ; $85B5
  rts                          ; $85B7
Sub_B1_85B8:
  rts                          ; $85B8
  lda $0552                    ; $85B9  [heuristic code]
  lsr a                        ; $85BC
  cmp #$0A                     ; $85BD
  bcc Loc_B1_85F1              ; $85BF
  sta z:Tmp03                  ; $85C1
  lda #$00                     ; $85C3
  sta z:$04                    ; $85C5
  jsr BinToDecimal             ; $85C7
  ldy z:Tmp02                  ; $85CA
  beq Loc_B1_85D4              ; $85CC
  lda Data_B1_85F2,y           ; $85CE
  sta $0543                    ; $85D1
Loc_B1_85D4:
  ldy z:Tmp01                  ; $85D4
  lda Data_B1_85F2,y           ; $85D6
  sta $0545                    ; $85D9
  ldy z:Tmp00                  ; $85DC
  lda Data_B1_85F2,y           ; $85DE
  sta $0547                    ; $85E1
  lda #$92                     ; $85E4
  sta $0549                    ; $85E6
  lda #$AB                     ; $85E9
  sta $054B                    ; $85EB
  inc $0556                    ; $85EE
Loc_B1_85F1:
  rts                          ; $85F1
Data_B1_85F2:
  .incbin "prg_bank_1.bin", $05F2, $E  ; $85F2
  lda $0546                    ; $8600
  beq Loc_B1_861B              ; $8603
  jsr SetPpuAddrFromBuf        ; $8605
  ldx #$00                     ; $8608
  stx $0546                    ; $860A
Loc_B1_860D:
  lda $0548,x                  ; $860D
  sta PPU_DATA                 ; $8610
  inx                          ; $8613
  cpx #$20                     ; $8614
  bcc Loc_B1_860D              ; $8616
  jsr ApplyScroll              ; $8618
Loc_B1_861B:
  dec $0547                    ; $861B
  beq Loc_B1_8621              ; $861E
  rts                          ; $8620
Loc_B1_8621:
  lda #$03                     ; $8621
  sta $0547                    ; $8623
  ldx z:HwScrollY              ; $8626
  inx                          ; $8628
  cpx #$F0                     ; $8629
  bcc Loc_B1_8635              ; $862B
  lda z:PpuCtrlShadow          ; $862D
  eor #$02                     ; $862F
  sta z:PpuCtrlShadow          ; $8631
  ldx #$00                     ; $8633
Loc_B1_8635:
  stx z:HwScrollY              ; $8635
  txa                          ; $8637
  and #$07                     ; $8638
  beq Loc_B1_863D              ; $863A
  rts                          ; $863C
Loc_B1_863D:
  sta PpuAddrBufHi             ; $863D
  txa                          ; $8640
  asl a                        ; $8641
  rol PpuAddrBufHi             ; $8642
  asl a                        ; $8645
  rol PpuAddrBufHi             ; $8646
  sta PpuAddrBufLo             ; $8649
  lda z:PpuCtrlShadow          ; $864C
  and #$02                     ; $864E
  eor #$02                     ; $8650
  sta z:Tmp00                  ; $8652
  asl a                        ; $8654
  ora z:Tmp00                  ; $8655
  asl a                        ; $8657
  ora #$20                     ; $8658
  ora PpuAddrBufHi             ; $865A
  sta PpuAddrBufHi             ; $865D
  lda #$FF                     ; $8660
  ldx #$1F                     ; $8662
Loc_B1_8664:
  sta $0548,x                  ; $8664
  dex                          ; $8667
  bpl Loc_B1_8664              ; $8668
  lda $0545                    ; $866A
  asl a                        ; $866D
  tay                          ; $866E
  lda Data_B1_86B7,y           ; $866F
  sta z:Tmp00                  ; $8672
  lda Data_B1_86B8,y           ; $8674
  clc                          ; $8677
  adc $0544                    ; $8678
  sta z:Tmp01                  ; $867B
  ldy $0543                    ; $867D
  lda (Tmp00),y                ; $8680
  beq Loc_B1_86B1              ; $8682
  asl a                        ; $8684
  tay                          ; $8685
  lda Data_B1_88EB,y           ; $8686
  sta z:Tmp00                  ; $8689
  lda Data_B1_88EC,y           ; $868B
  sta z:Tmp01                  ; $868E
  ldy #$00                     ; $8690
  lda (Tmp00),y                ; $8692
  iny                          ; $8694
  tax                          ; $8695
Loc_B1_8696:
  lda (Tmp00),y                ; $8696
  cmp #$FE                     ; $8698
  beq Loc_B1_86A5              ; $869A
  sta $0548,x                  ; $869C
  iny                          ; $869F
  inx                          ; $86A0
  cpx #$20                     ; $86A1
  bcc Loc_B1_8696              ; $86A3
Loc_B1_86A5:
  inc $0543                    ; $86A5
  bne Loc_B1_86AD              ; $86A8
  inc $0544                    ; $86AA
Loc_B1_86AD:
  inc $0546                    ; $86AD
  rts                          ; $86B0
Loc_B1_86B1:
  lda #$00                     ; $86B1
  sta $0547                    ; $86B3
  rts                          ; $86B6
Data_B1_86B7:
  .incbin "prg_bank_1.bin", $06B7, $1  ; $86B7
Data_B1_86B8:
  .incbin "prg_bank_1.bin", $06B8, $233  ; $86B8
Data_B1_88EB:
  .incbin "prg_bank_1.bin", $08EB, $1  ; $88EB
Data_B1_88EC:
  .incbin "prg_bank_1.bin", $08EC, $400  ; $88EC
  .incbin "prg_bank_1.bin", $0CEC, $14  ; $8CEC
  ldx #$0F                     ; $8D00
  ldy #$03                     ; $8D02
Loc_B1_8D04:
  lda #$00                     ; $8D04
  sta ObjectTable,y            ; $8D06
  tya                          ; $8D09
  clc                          ; $8D0A
  adc #$10                     ; $8D0B
  tay                          ; $8D0D
  dex                          ; $8D0E
  bne Loc_B1_8D04              ; $8D0F
  lda #$10                     ; $8D11
  sta z:Tmp00                  ; $8D13
  lda #$03                     ; $8D15
  sta z:Tmp01                  ; $8D17
  lda $0300                    ; $8D19
  asl a                        ; $8D1C
  tay                          ; $8D1D
  lda Data_C347,y              ; $8D1E
  sta z:Tmp02                  ; $8D21
  inc $0303                    ; $8D23
  lda $0303                    ; $8D26
  cmp ObjectCount              ; $8D29
  bcc Loc_B1_8D33              ; $8D2C
  lda #$00                     ; $8D2E
  sta $0303                    ; $8D30
Loc_B1_8D33:
  sta z:Tmp03                  ; $8D33
  ldx #$00                     ; $8D35
Loc_B1_8D37:
  lda z:Tmp03                  ; $8D37
  jsr AslA4                    ; $8D39
  adc #$04                     ; $8D3C
  tay                          ; $8D3E
  lda (Tmp00),y                ; $8D3F
  bne Loc_B1_8D46              ; $8D41
  jmp Loc_B1_8D4B              ; $8D43
Loc_B1_8D46:
  dey                          ; $8D46
  lda z:Tmp02                  ; $8D47
  sta (Tmp00),y                ; $8D49
Loc_B1_8D4B:
  inc z:Tmp03                  ; $8D4B
  lda z:Tmp03                  ; $8D4D
  cmp ObjectCount              ; $8D4F
  bcc Loc_B1_8D58              ; $8D52
  lda #$00                     ; $8D54
  sta z:Tmp03                  ; $8D56
Loc_B1_8D58:
  tya                          ; $8D58
  and #$F0                     ; $8D59
  tay                          ; $8D5B
  lda (Tmp00),y                ; $8D5C
  and #$80                     ; $8D5E
  beq Loc_B1_8D7B              ; $8D60
  iny                          ; $8D62
  iny                          ; $8D63
  iny                          ; $8D64
  iny                          ; $8D65
  lda (Tmp00),y                ; $8D66
  and #$0F                     ; $8D68
  asl a                        ; $8D6A
  asl a                        ; $8D6B
  clc                          ; $8D6C
  adc z:Tmp02                  ; $8D6D
  sta z:Tmp02                  ; $8D6F
  bcc Loc_B1_8D7B              ; $8D71
  dey                          ; $8D73
  lda #$00                     ; $8D74
  sta (Tmp00),y                ; $8D76
  jmp Loc_B1_8D81              ; $8D78
Loc_B1_8D7B:
  inx                          ; $8D7B
  cpx ObjectCount              ; $8D7C
  bcc Loc_B1_8D37              ; $8D7F
Loc_B1_8D81:
  lda ObjectCount              ; $8D81
  beq Loc_B1_8DBB              ; $8D84
  lda #$00                     ; $8D86
  sta $0302                    ; $8D88
Loc_B1_8D8B:
  ldy #$00                     ; $8D8B
  lda (Tmp00),y                ; $8D8D
  and #$3F                     ; $8D8F
  asl a                        ; $8D91
  tay                          ; $8D92
  lda Data_B1_8DCF,y           ; $8D93
  sta $0304                    ; $8D96
  lda Data_B1_8DD0,y           ; $8D99
  sta $0305                    ; $8D9C
  lda #$8D                     ; $8D9F
  pha                          ; $8DA1
  lda #$A8                     ; $8DA2
  pha                          ; $8DA4
  jmp ($0304)                  ; $8DA5
  .incbin "prg_bank_1.bin", $0DA8, $1  ; $8DA8
  lda z:Tmp00                  ; $8DA9
  clc                          ; $8DAB
  adc #$10                     ; $8DAC
  sta z:Tmp00                  ; $8DAE
  inc $0302                    ; $8DB0
  lda $0302                    ; $8DB3
  cmp ObjectCount              ; $8DB6
  bcc Loc_B1_8D8B              ; $8DB9
Loc_B1_8DBB:
  lda z:AmmoLo                 ; $8DBB
  ora z:AmmoHi                 ; $8DBD
  bne Loc_B1_8DCE              ; $8DBF
  lda z:PaletteSetIndex        ; $8DC1
  cmp #$69                     ; $8DC3
  beq Loc_B1_8DCE              ; $8DC5
  lda z:FrameCounter           ; $8DC7
  bne Loc_B1_8DCE              ; $8DC9
  jsr Sub_B1_AAD5              ; $8DCB
Loc_B1_8DCE:
  rts                          ; $8DCE
Data_B1_8DCF:
  .addr Sub_B1_9231, Sub_B1_8DFF, Sub_B1_8F59, Sub_B1_90A6, Sub_B1_9360, Sub_B1_9583, Sub_B1_97B7, Sub_B1_99E0, Sub_B1_9C47, Sub_B1_9DB9, Sub_B1_9DB9  ; $8DCF pointer table
  .incbin "prg_bank_1.bin", $0DE5, $1A  ; $8DE5
Sub_B1_8DFF:
  ldy #$0C                     ; $8DFF
  lda (Tmp00),y                ; $8E01
  beq Loc_B1_8E0D              ; $8E03
  sec                          ; $8E05
  sbc #$01                     ; $8E06
  sta (Tmp00),y                ; $8E08
  jmp Loc_B1_8E7E              ; $8E0A
Loc_B1_8E0D:
  iny                          ; $8E0D
  lda (Tmp00),y                ; $8E0E
  clc                          ; $8E10
  adc #$01                     ; $8E11
  sta (Tmp00),y                ; $8E13
  cmp Data_B1_8E7F             ; $8E15
  bcs Loc_B1_8E5C              ; $8E18
  asl a                        ; $8E1A
  tax                          ; $8E1B
  lda Data_B1_8E80,x           ; $8E1C
  dey                          ; $8E1F
  sta (Tmp00),y                ; $8E20
  lda Data_B1_8E81,x           ; $8E22
  pha                          ; $8E25
  ldy #$0E                     ; $8E26
  lda (Tmp00),y                ; $8E28
  and #$01                     ; $8E2A
  beq Loc_B1_8E35              ; $8E2C
  pla                          ; $8E2E
  clc                          ; $8E2F
  adc #$08                     ; $8E30
  jmp Loc_B1_8E36              ; $8E32
Loc_B1_8E35:
  pla                          ; $8E35
Loc_B1_8E36:
  tax                          ; $8E36
  ldy #$00                     ; $8E37
Loc_B1_8E39:
  lda Data_B1_8E92,x           ; $8E39
  sta PaletteBuffer,y          ; $8E3C
  lda Data_B1_8E93,x           ; $8E3F
  sta $0141,y                  ; $8E42
  lda Data_B1_8E94,x           ; $8E45
  sta $0142,y                  ; $8E48
  lda Data_B1_8E95,x           ; $8E4B
  sta $0143,y                  ; $8E4E
  iny                          ; $8E51
  iny                          ; $8E52
  iny                          ; $8E53
  iny                          ; $8E54
  cpy #$10                     ; $8E55
  bcc Loc_B1_8E39              ; $8E57
  jmp Loc_B1_8E7E              ; $8E59
Loc_B1_8E5C:
  lda z:Tmp00                  ; $8E5C
  pha                          ; $8E5E
  lda z:Tmp01                  ; $8E5F
  pha                          ; $8E61
  lda z:Tmp02                  ; $8E62
  pha                          ; $8E64
  lda z:Tmp03                  ; $8E65
  pha                          ; $8E67
  jsr LoadPaletteSet           ; $8E68
  pla                          ; $8E6B
  sta z:Tmp03                  ; $8E6C
  pla                          ; $8E6E
  sta z:Tmp02                  ; $8E6F
  pla                          ; $8E71
  sta z:Tmp01                  ; $8E72
  pla                          ; $8E74
  sta z:Tmp00                  ; $8E75
  lda #$00                     ; $8E77
  sta z:PaletteDirty           ; $8E79
  jsr Sub_C43D                 ; $8E7B
Loc_B1_8E7E:
  rts                          ; $8E7E
Data_B1_8E7F:
  .incbin "prg_bank_1.bin", $0E7F, $1  ; $8E7F
Data_B1_8E80:
  .incbin "prg_bank_1.bin", $0E80, $1  ; $8E80
Data_B1_8E81:
  .incbin "prg_bank_1.bin", $0E81, $11  ; $8E81
Data_B1_8E92:
  .incbin "prg_bank_1.bin", $0E92, $1  ; $8E92
Data_B1_8E93:
  .incbin "prg_bank_1.bin", $0E93, $1  ; $8E93
Data_B1_8E94:
  .incbin "prg_bank_1.bin", $0E94, $1  ; $8E94
Data_B1_8E95:
  .incbin "prg_bank_1.bin", $0E95, $D  ; $8E95
Sub_B1_8EA2:
  lda z:PaletteDirty           ; $8EA2
  beq Loc_B1_8ECF              ; $8EA4
  lda z:Tmp00                  ; $8EA6
  sta z:$06                    ; $8EA8
  lda z:Tmp01                  ; $8EAA
  pha                          ; $8EAC
  lda z:Tmp02                  ; $8EAD
  pha                          ; $8EAF
  lda z:Tmp03                  ; $8EB0
  pha                          ; $8EB2
  lda z:$04                    ; $8EB3
  pha                          ; $8EB5
  lda z:$05                    ; $8EB6
  pha                          ; $8EB8
  jsr Sub_B1_8F1E              ; $8EB9
  pla                          ; $8EBC
  sta z:$05                    ; $8EBD
  pla                          ; $8EBF
  sta z:$04                    ; $8EC0
  pla                          ; $8EC2
  sta z:Tmp03                  ; $8EC3
  pla                          ; $8EC5
  sta z:Tmp02                  ; $8EC6
  pla                          ; $8EC8
  sta z:Tmp01                  ; $8EC9
  lda z:$06                    ; $8ECB
  sta z:Tmp00                  ; $8ECD
Loc_B1_8ECF:
  ldy z:Tmp00                  ; $8ECF
  lda $0300,y                  ; $8ED1
  and #$80                     ; $8ED4
  beq Loc_B1_8F1A              ; $8ED6
  lda #$40                     ; $8ED8
  sta $0307,y                  ; $8EDA
  lda #$01                     ; $8EDD
  sta z:PaletteDirty           ; $8EDF
  lda #$C1                     ; $8EE1
  sta $0300,y                  ; $8EE3
  lda #$01                     ; $8EE6
  sta $0304,y                  ; $8EE8
  lda #$00                     ; $8EEB
  sta $0305,y                  ; $8EED
  lda #$01                     ; $8EF0
  sta $030C,y                  ; $8EF2
  lda #$FF                     ; $8EF5
  sta $030D,y                  ; $8EF7
  lda #$41                     ; $8EFA
  jsr EnqueueByte              ; $8EFC
  lda $0302,y                  ; $8EFF
  cmp #$60                     ; $8F02
  bcc Loc_B1_8F0F              ; $8F04
  cmp #$A0                     ; $8F06
  bcs Loc_B1_8F0F              ; $8F08
  lda #$00                     ; $8F0A
  jmp Loc_B1_8F11              ; $8F0C
Loc_B1_8F0F:
  lda #$01                     ; $8F0F
Loc_B1_8F11:
  ora $030E,y                  ; $8F11
  sta $030E,y                  ; $8F14
  jmp Loc_B1_8F1D              ; $8F17
Loc_B1_8F1A:
  jsr Sub_C43D                 ; $8F1A
Loc_B1_8F1D:
  rts                          ; $8F1D
Sub_B1_8F1E:
  ldy #$00                     ; $8F1E
  lda #$10                     ; $8F20
  sta z:Tmp00                  ; $8F22
  lda #$03                     ; $8F24
  sta z:Tmp01                  ; $8F26
Loc_B1_8F28:
  lda (Tmp00),y                ; $8F28
  and #$3F                     ; $8F2A
  cmp #$01                     ; $8F2C
  beq Loc_B1_8F41              ; $8F2E
  lda z:Tmp00                  ; $8F30
  clc                          ; $8F32
  adc #$10                     ; $8F33
  cmp #$00                     ; $8F35
  bne Loc_B1_8F3C              ; $8F37
  jmp Loc_B1_8F51              ; $8F39
Loc_B1_8F3C:
  sta z:Tmp00                  ; $8F3C
  jmp Loc_B1_8F28              ; $8F3E
Loc_B1_8F41:
  lda z:Tmp00                  ; $8F41
  cmp z:$06                    ; $8F43
  bcs Loc_B1_8F4E              ; $8F45
  lda z:$06                    ; $8F47
  sec                          ; $8F49
  sbc #$10                     ; $8F4A
  sta z:$06                    ; $8F4C
Loc_B1_8F4E:
  jsr Sub_C43D                 ; $8F4E
Loc_B1_8F51:
  jsr LoadPaletteSet           ; $8F51
  lda #$00                     ; $8F54
  sta z:PaletteDirty           ; $8F56
  rts                          ; $8F58
Sub_B1_8F59:
  jsr Sub_B1_8F8C              ; $8F59  [heuristic code]
  ldy #$08                     ; $8F5C
  lda (Tmp00),y                ; $8F5E
  and #$3F                     ; $8F60
  bne Loc_B1_8F72              ; $8F62
  jsr Sub_B1_AAC3              ; $8F64
  bcc Loc_B1_8F6F              ; $8F67
  jsr Sub_B1_8F9F              ; $8F69
  jsr Sub_B1_8F8C              ; $8F6C
Loc_B1_8F6F:
  jsr Sub_B1_AA64              ; $8F6F
Loc_B1_8F72:
  jsr Sub_B1_8F79              ; $8F72
  jsr Sub_B1_AA03              ; $8F75
  rts                          ; $8F78
Sub_B1_8F79:
  jsr Sub_B1_A957              ; $8F79
  lda z:$04                    ; $8F7C
  beq Loc_B1_8F8B              ; $8F7E
  ldy #$08                     ; $8F80
  lda (Tmp00),y                ; $8F82
  and #$3F                     ; $8F84
  sec                          ; $8F86
  sbc #$01                     ; $8F87
  sta (Tmp00),y                ; $8F89
Loc_B1_8F8B:
  rts                          ; $8F8B
Sub_B1_8F8C:
  ldy #$07                     ; $8F8C
  lda (Tmp00),y                ; $8F8E
  and #$0F                     ; $8F90
  asl a                        ; $8F92
  tay                          ; $8F93
  lda Data_B1_900A,y           ; $8F94
  sta z:Tmp02                  ; $8F97
  lda Data_B1_900B,y           ; $8F99
  sta z:Tmp03                  ; $8F9C
  rts                          ; $8F9E
Sub_B1_8F9F:
  ldy #$07                     ; $8F9F
  lda (Tmp00),y                ; $8FA1
  cmp #$02                     ; $8FA3
  bcs Loc_B1_8FB5              ; $8FA5
  jsr GetRandomByte            ; $8FA7
  and #$0F                     ; $8FAA
  cmp #$04                     ; $8FAC
  bcs Loc_B1_8FB5              ; $8FAE
  and #$01                     ; $8FB0
  jmp Loc_B1_8FBC              ; $8FB2
Loc_B1_8FB5:
  lda (Tmp00),y                ; $8FB5
  clc                          ; $8FB7
  adc #$01                     ; $8FB8
  and #$07                     ; $8FBA
Loc_B1_8FBC:
  sta (Tmp00),y                ; $8FBC
  cmp #$04                     ; $8FBE
  bne Loc_B1_8FD7              ; $8FC0
  ldy #$00                     ; $8FC2
  lda (Tmp00),y                ; $8FC4
  bmi Loc_B1_8FD4              ; $8FC6
  ldy #$0C                     ; $8FC8
  lda (Tmp00),y                ; $8FCA
  bpl Loc_B1_8FD4              ; $8FCC
  jsr Sub_B1_AAD5              ; $8FCE
  jmp Loc_B1_8FD7              ; $8FD1
Loc_B1_8FD4:
  jsr Sub_B1_8FDE              ; $8FD4
Loc_B1_8FD7:
  ldy #$0E                     ; $8FD7
  lda #$00                     ; $8FD9
  sta (Tmp00),y                ; $8FDB
  rts                          ; $8FDD
Sub_B1_8FDE:
  lda #$00                     ; $8FDE
  sta z:$06                    ; $8FE0
  sta z:$07                    ; $8FE2
  jsr Sub_B1_AA84              ; $8FE4
  lda z:$05                    ; $8FE7
  beq Loc_B1_9009              ; $8FE9
  ldy #$07                     ; $8FEB
  lda z:$06                    ; $8FED
  and #$03                     ; $8FEF
  cmp #$02                     ; $8FF1
  bcs Loc_B1_8FFC              ; $8FF3
  sta ($04),y                  ; $8FF5
  lda #$58                     ; $8FF7
  jmp Loc_B1_9000              ; $8FF9
Loc_B1_8FFC:
  sta ($04),y                  ; $8FFC
  lda #$41                     ; $8FFE
Loc_B1_9000:
  iny                          ; $9000
  sta ($04),y                  ; $9001
  ldy #$05                     ; $9003
  lda #$00                     ; $9005
  sta ($04),y                  ; $9007
Loc_B1_9009:
  rts                          ; $9009
Data_B1_900A:
  .incbin "prg_bank_1.bin", $100A, $1  ; $900A
Data_B1_900B:
  .incbin "prg_bank_1.bin", $100B, $9B  ; $900B
Sub_B1_90A6:
  jsr Sub_B1_90C6              ; $90A6
  ldy #$08                     ; $90A9
  lda (Tmp00),y                ; $90AB
  and #$3F                     ; $90AD
  bne Loc_B1_90BF              ; $90AF
  jsr Sub_B1_AAC3              ; $90B1
  bcc Loc_B1_90BC              ; $90B4
  jsr Sub_B1_8EA2              ; $90B6
  jmp Loc_B1_90C5              ; $90B9
Loc_B1_90BC:
  jsr Sub_B1_AA64              ; $90BC
Loc_B1_90BF:
  jsr Sub_B1_8F79              ; $90BF
  jsr Sub_B1_AA03              ; $90C2
Loc_B1_90C5:
  rts                          ; $90C5
Sub_B1_90C6:
  ldy #$07                     ; $90C6
  lda (Tmp00),y                ; $90C8
  and #$0F                     ; $90CA
  asl a                        ; $90CC
  tay                          ; $90CD
  lda Data_B1_90D9,y           ; $90CE
  sta z:Tmp02                  ; $90D1
  lda Data_B1_90DA,y           ; $90D3
  sta z:Tmp03                  ; $90D6
  rts                          ; $90D8
Data_B1_90D9:
  .incbin "prg_bank_1.bin", $10D9, $1  ; $90D9
Data_B1_90DA:
  .incbin "prg_bank_1.bin", $10DA, $157  ; $90DA
Sub_B1_9231:
  jsr Sub_B1_9260              ; $9231
  ldy #$08                     ; $9234
  lda (Tmp00),y                ; $9236
  bne Loc_B1_9259              ; $9238
  ldy #$00                     ; $923A
  lda (Tmp02),y                ; $923C
  sta z:$04                    ; $923E
  ldy #$0E                     ; $9240
  lda (Tmp00),y                ; $9242
  clc                          ; $9244
  adc #$01                     ; $9245
  sta (Tmp00),y                ; $9247
  cmp z:$04                    ; $9249
  bcc Loc_B1_9253              ; $924B
  jsr Sub_B1_926E              ; $924D
  jsr Sub_B1_9260              ; $9250
Loc_B1_9253:
  jsr Sub_B1_AA64              ; $9253
  jsr Sub_B1_929F              ; $9256
Loc_B1_9259:
  jsr Sub_B1_9ABA              ; $9259
  jsr Sub_B1_AA03              ; $925C
  rts                          ; $925F
Sub_B1_9260:
  jsr Sub_B1_AB1E              ; $9260
  lda Data_B1_9307,y           ; $9263
  sta z:Tmp02                  ; $9266
  lda Data_B1_9308,y           ; $9268
  sta z:Tmp03                  ; $926B
  rts                          ; $926D
Sub_B1_926E:
  ldy #$07                     ; $926E
  lda (Tmp00),y                ; $9270
  clc                          ; $9272
  adc #$01                     ; $9273
  cmp #$03                     ; $9275
  bne Loc_B1_9296              ; $9277
  lda z:PaletteSetIndex        ; $9279
  cmp #$5F                     ; $927B
  bne Loc_B1_9292              ; $927D
  ldy #$09                     ; $927F
  lda (Tmp00),y                ; $9281
  cmp #$03                     ; $9283
  bne Loc_B1_9292              ; $9285
  iny                          ; $9287
  lda (Tmp00),y                ; $9288
  cmp #$D0                     ; $928A
  bcs Loc_B1_9292              ; $928C
  lda #$10                     ; $928E
  sta (Tmp00),y                ; $9290
Loc_B1_9292:
  ldy #$07                     ; $9292
  lda #$00                     ; $9294
Loc_B1_9296:
  sta (Tmp00),y                ; $9296
  ldy #$0E                     ; $9298
  lda #$00                     ; $929A
  sta (Tmp00),y                ; $929C
  rts                          ; $929E
Sub_B1_929F:
  ldy #$00                     ; $929F
  lda (Tmp00),y                ; $92A1
  and #$80                     ; $92A3
  bne Loc_B1_92C3              ; $92A5
  ldy #$0C                     ; $92A7
  lda (Tmp00),y                ; $92A9
  bpl Loc_B1_92FE              ; $92AB
  ldy #$07                     ; $92AD
  lda (Tmp00),y                ; $92AF
  cmp #$01                     ; $92B1
  bne Loc_B1_92FE              ; $92B3
  ldy #$0E                     ; $92B5
  lda (Tmp00),y                ; $92B7
  cmp #$04                     ; $92B9
  bne Loc_B1_92FE              ; $92BB
  jsr Sub_B1_AAD5              ; $92BD
  jmp Loc_B1_92FE              ; $92C0
Loc_B1_92C3:
  ldy #$07                     ; $92C3
  lda (Tmp00),y                ; $92C5
  cmp #$01                     ; $92C7
  bne Loc_B1_92FE              ; $92C9
  ldy #$0E                     ; $92CB
  lda (Tmp00),y                ; $92CD
  cmp #$04                     ; $92CF
  beq Loc_B1_92D7              ; $92D1
  cmp #$05                     ; $92D3
  bne Loc_B1_92FE              ; $92D5
Loc_B1_92D7:
  jsr GetRandomByte            ; $92D7
  and #$01                     ; $92DA
  bne Loc_B1_92E3              ; $92DC
  lda #$08                     ; $92DE
  jmp Loc_B1_92E5              ; $92E0
Loc_B1_92E3:
  lda #$10                     ; $92E3
Loc_B1_92E5:
  sta z:$06                    ; $92E5
  lda #$00                     ; $92E7
  sta z:$07                    ; $92E9
  jsr Sub_B1_96F0              ; $92EB
  lda z:$05                    ; $92EE
  beq Loc_B1_92FE              ; $92F0
  lda z:$06                    ; $92F2
  and #$07                     ; $92F4
  tay                          ; $92F6
  lda Data_B1_92FF,y           ; $92F7
  ldy #$07                     ; $92FA
  sta ($04),y                  ; $92FC
Loc_B1_92FE:
  rts                          ; $92FE
Data_B1_92FF:
  .incbin "prg_bank_1.bin", $12FF, $8  ; $92FF
Data_B1_9307:
  .incbin "prg_bank_1.bin", $1307, $1  ; $9307
Data_B1_9308:
  .incbin "prg_bank_1.bin", $1308, $58  ; $9308
Sub_B1_9360:
  jsr Sub_B1_93B8              ; $9360
  ldy #$07                     ; $9363
  lda (Tmp00),y                ; $9365
  cmp #$04                     ; $9367
  bne Loc_B1_9373              ; $9369
  jsr Sub_B1_93C6              ; $936B
  beq Loc_B1_9381              ; $936E
  jmp Loc_B1_93B4              ; $9370
Loc_B1_9373:
  ldy #$08                     ; $9373
  lda (Tmp00),y                ; $9375
  bne Loc_B1_938A              ; $9377
  jsr Sub_B1_AAC3              ; $9379
  bcc Loc_B1_9384              ; $937C
  jsr Sub_B1_93FA              ; $937E
Loc_B1_9381:
  jsr Sub_B1_93B8              ; $9381
Loc_B1_9384:
  jsr Sub_B1_AA64              ; $9384
  jsr Sub_B1_942E              ; $9387
Loc_B1_938A:
  jsr Sub_B1_94BD              ; $938A
  ldy #$07                     ; $938D
  lda (Tmp00),y                ; $938F
  cmp #$03                     ; $9391
  bne Loc_B1_93B4              ; $9393
  ldy #$0B                     ; $9395
  lda (Tmp00),y                ; $9397
  cmp #$0C                     ; $9399
  bcs Loc_B1_93B4              ; $939B
  ldy #$09                     ; $939D
  lda (Tmp00),y                ; $939F
  clc                          ; $93A1
  adc #$02                     ; $93A2
  and #$03                     ; $93A4
  sta (Tmp00),y                ; $93A6
  ldy #$07                     ; $93A8
  lda #$04                     ; $93AA
  sta (Tmp00),y                ; $93AC
  ldy #$05                     ; $93AE
  lda #$00                     ; $93B0
  sta (Tmp00),y                ; $93B2
Loc_B1_93B4:
  jsr Sub_B1_AA03              ; $93B4
  rts                          ; $93B7
Sub_B1_93B8:
  jsr Sub_B1_AB1E              ; $93B8
  lda Data_B1_94E8,y           ; $93BB
  sta z:Tmp02                  ; $93BE
  lda Data_B1_94E9,y           ; $93C0
  sta z:Tmp03                  ; $93C3
  rts                          ; $93C5
Sub_B1_93C6:
  lda #$C0                     ; $93C6
  sta z:$04                    ; $93C8
  jsr Sub_B1_9694              ; $93CA
  lda z:$05                    ; $93CD
  sta z:$07                    ; $93CF
  lda z:$06                    ; $93D1
  sta z:$08                    ; $93D3
  lda #$80                     ; $93D5
  sta z:$04                    ; $93D7
  jsr Sub_B1_9694              ; $93D9
  jsr Sub_B1_960A              ; $93DC
  bne Loc_B1_93F9              ; $93DF
  jsr GetRandomByte            ; $93E1
  and #$3F                     ; $93E4
  ora #$80                     ; $93E6
  adc z:ScrollX                ; $93E8
  ldy #$0A                     ; $93EA
  sta (Tmp00),y                ; $93EC
  dey                          ; $93EE
  lda z:ScrollPage             ; $93EF
  adc #$00                     ; $93F1
  and #$03                     ; $93F3
  sta (Tmp00),y                ; $93F5
  lda #$00                     ; $93F7
Loc_B1_93F9:
  rts                          ; $93F9
Sub_B1_93FA:
  ldy #$07                     ; $93FA
  lda (Tmp00),y                ; $93FC
  bne Loc_B1_9413              ; $93FE
  lda z:FrameCounter           ; $9400
  and #$1F                     ; $9402
  ora #$10                     ; $9404
  adc z:ScrollY                ; $9406
  and #$3F                     ; $9408
  ldy #$0B                     ; $940A
  sta (Tmp00),y                ; $940C
  lda #$01                     ; $940E
  jmp Loc_B1_9423              ; $9410
Loc_B1_9413:
  cmp #$01                     ; $9413
  bne Loc_B1_9421              ; $9415
  jsr GetRandomByte            ; $9417
  and #$03                     ; $941A
  ora #$02                     ; $941C
  jmp Loc_B1_9423              ; $941E
Loc_B1_9421:
  lda #$03                     ; $9421
Loc_B1_9423:
  ldy #$07                     ; $9423
  sta (Tmp00),y                ; $9425
  ldy #$0E                     ; $9427
  lda #$00                     ; $9429
  sta (Tmp00),y                ; $942B
  rts                          ; $942D
Sub_B1_942E:
  ldy #$07                     ; $942E
  lda (Tmp00),y                ; $9430
  bne Loc_B1_943F              ; $9432
  ldy #$0E                     ; $9434
  lda (Tmp00),y                ; $9436
  cmp #$01                     ; $9438
  beq Loc_B1_945E              ; $943A
  jmp Loc_B1_94BC              ; $943C
Loc_B1_943F:
  ldy #$0E                     ; $943F
  cmp #$01                     ; $9441
  bne Loc_B1_944E              ; $9443
  lda (Tmp00),y                ; $9445
  cmp #$07                     ; $9447
  beq Loc_B1_9458              ; $9449
  jmp Loc_B1_94BC              ; $944B
Loc_B1_944E:
  cmp #$03                     ; $944E
  bne Loc_B1_94BC              ; $9450
  lda (Tmp00),y                ; $9452
  cmp #$03                     ; $9454
  bne Loc_B1_94BC              ; $9456
Loc_B1_9458:
  jsr Sub_B1_96E8              ; $9458
  jmp Loc_B1_94BC              ; $945B
Loc_B1_945E:
  ldy #$00                     ; $945E
  lda (Tmp00),y                ; $9460
  and #$80                     ; $9462
  beq Loc_B1_94BC              ; $9464
  jsr Sub_B1_AAD5              ; $9466
  jmp Loc_B1_94BC              ; $9469
Sub_B1_946C:
  lda ObjectCount              ; $946C
  cmp #$0F                     ; $946F
  bcs Loc_B1_94BC              ; $9471
  lda z:Tmp00                  ; $9473
  sta z:$04                    ; $9475
  lda z:Tmp01                  ; $9477
  sta z:$05                    ; $9479
  inc ObjectCount              ; $947B
  lda ObjectCount              ; $947E
  jsr AslA4                    ; $9481
  sta z:Tmp00                  ; $9484
  ldx z:$04                    ; $9486
  ldy z:Tmp00                  ; $9488
  lda $0309,x                  ; $948A
  sta $0309,y                  ; $948D
  lda $030A,x                  ; $9490
  sta $030A,y                  ; $9493
  lda $030B,x                  ; $9496
  sta $030B,y                  ; $9499
  lda #$C1                     ; $949C
  sta $0300,y                  ; $949E
  lda ObjectCount,x            ; $94A1
  sta ObjectCount,y            ; $94A4
  lda $0302,x                  ; $94A7
  sta $0302,y                  ; $94AA
  lda z:$04                    ; $94AD
  pha                          ; $94AF
  lda z:$05                    ; $94B0
  pha                          ; $94B2
  jsr Sub_B1_8EA2              ; $94B3
  pla                          ; $94B6
  sta z:Tmp01                  ; $94B7
  pla                          ; $94B9
  sta z:Tmp00                  ; $94BA
Loc_B1_94BC:
  rts                          ; $94BC
Sub_B1_94BD:
  jsr Sub_B1_A957              ; $94BD  [heuristic code]
  lda z:$04                    ; $94C0
  beq Loc_B1_94E7              ; $94C2
  ldy #$07                     ; $94C4
  lda (Tmp00),y                ; $94C6
  bne Loc_B1_94DE              ; $94C8
  ldy #$0B                     ; $94CA
  lda (Tmp00),y                ; $94CC
  cmp #$10                     ; $94CE
  bcs Loc_B1_94DE              ; $94D0
  lda #$07                     ; $94D2
  ldy #$0E                     ; $94D4
  sta (Tmp00),y                ; $94D6
  ldy #$08                     ; $94D8
  lda #$01                     ; $94DA
  sta (Tmp00),y                ; $94DC
Loc_B1_94DE:
  ldy #$08                     ; $94DE
  lda (Tmp00),y                ; $94E0
  sec                          ; $94E2
  sbc #$01                     ; $94E3
  sta (Tmp00),y                ; $94E5
Loc_B1_94E7:
  rts                          ; $94E7
Data_B1_94E8:
  .incbin "prg_bank_1.bin", $14E8, $1  ; $94E8
Data_B1_94E9:
  .incbin "prg_bank_1.bin", $14E9, $9A  ; $94E9
Sub_B1_9583:
  jsr Sub_B1_95E6              ; $9583
  ldy #$07                     ; $9586
  lda (Tmp00),y                ; $9588
  cmp #$08                     ; $958A
  bne Loc_B1_9596              ; $958C
  jsr Sub_B1_95F4              ; $958E
  beq Loc_B1_95A4              ; $9591
  jmp Loc_B1_95E2              ; $9593
Loc_B1_9596:
  ldy #$08                     ; $9596
  lda (Tmp00),y                ; $9598
  bne Loc_B1_95C0              ; $959A
  jsr Sub_B1_AAC3              ; $959C
  bcc Loc_B1_95A7              ; $959F
  jsr Sub_B1_96BE              ; $95A1
Loc_B1_95A4:
  jsr Sub_B1_95E6              ; $95A4
Loc_B1_95A7:
  jsr Sub_B1_AA64              ; $95A7
  ldy #$07                     ; $95AA
  lda (Tmp00),y                ; $95AC
  bne Loc_B1_95BD              ; $95AE
  ldy #$0E                     ; $95B0
  lda (Tmp00),y                ; $95B2
  cmp #$02                     ; $95B4
  bne Loc_B1_95BD              ; $95B6
  lda #$16                     ; $95B8
  jsr EnqueueByte              ; $95BA
Loc_B1_95BD:
  jsr Sub_B1_96A4              ; $95BD
Loc_B1_95C0:
  jsr Sub_B1_9ABA              ; $95C0
  ldy #$0B                     ; $95C3
  lda (Tmp00),y                ; $95C5
  cmp #$10                     ; $95C7
  bcs Loc_B1_95E2              ; $95C9
  ldy #$09                     ; $95CB
  lda (Tmp00),y                ; $95CD
  clc                          ; $95CF
  adc #$02                     ; $95D0
  and #$03                     ; $95D2
  sta (Tmp00),y                ; $95D4
  ldy #$07                     ; $95D6
  lda #$08                     ; $95D8
  sta (Tmp00),y                ; $95DA
  ldy #$05                     ; $95DC
  lda #$09                     ; $95DE
  sta (Tmp00),y                ; $95E0
Loc_B1_95E2:
  jsr Sub_B1_AA03              ; $95E2
  rts                          ; $95E5
Sub_B1_95E6:
  jsr Sub_B1_AB1E              ; $95E6
  lda Data_B1_970C,y           ; $95E9
  sta z:Tmp02                  ; $95EC
  lda Data_B1_970D,y           ; $95EE
  sta z:Tmp03                  ; $95F1
  rts                          ; $95F3
Sub_B1_95F4:
  lda #$C0                     ; $95F4
  sta z:$04                    ; $95F6
  jsr Sub_B1_9694              ; $95F8
  lda z:$05                    ; $95FB
  sta z:$07                    ; $95FD
  lda z:$06                    ; $95FF
  sta z:$08                    ; $9601
  lda #$30                     ; $9603
  sta z:$04                    ; $9605
  jsr Sub_B1_9694              ; $9607
Sub_B1_960A:
  lda z:$05                    ; $960A
  cmp z:$07                    ; $960C
  bne Loc_B1_9626              ; $960E
  ldy #$09                     ; $9610
  lda (Tmp00),y                ; $9612
  cmp z:$05                    ; $9614
  bne Loc_B1_9691              ; $9616
  iny                          ; $9618
  lda (Tmp00),y                ; $9619
  cmp z:$06                    ; $961B
  bcc Loc_B1_9691              ; $961D
  cmp z:$08                    ; $961F
  bcs Loc_B1_9691              ; $9621
  jmp Loc_B1_9643              ; $9623
Loc_B1_9626:
  ldy #$09                     ; $9626
  lda (Tmp00),y                ; $9628
  cmp z:$05                    ; $962A
  bne Loc_B1_9638              ; $962C
  iny                          ; $962E
  lda (Tmp00),y                ; $962F
  cmp z:$06                    ; $9631
  bcc Loc_B1_9691              ; $9633
  jmp Loc_B1_9643              ; $9635
Loc_B1_9638:
  cmp z:$07                    ; $9638
  bne Loc_B1_9691              ; $963A
  iny                          ; $963C
  lda (Tmp00),y                ; $963D
  cmp z:$08                    ; $963F
  bcs Loc_B1_9691              ; $9641
Loc_B1_9643:
  ldy #$02                     ; $9643
  lda (Tmp00),y                ; $9645
  bmi Loc_B1_9661              ; $9647
  jsr GetRandomByte            ; $9649
  and #$3F                     ; $964C
  sta z:$04                    ; $964E
  ldy #$0A                     ; $9650
  lda (Tmp00),y                ; $9652
  adc z:$04                    ; $9654
  sta (Tmp00),y                ; $9656
  dey                          ; $9658
  lda (Tmp00),y                ; $9659
  adc #$00                     ; $965B
  and #$03                     ; $965D
  sta (Tmp00),y                ; $965F
Loc_B1_9661:
  lda z:ScrollY                ; $9661
  clc                          ; $9663
  adc #$14                     ; $9664
  pha                          ; $9666
  ldy #$00                     ; $9667
  lda (Tmp00),y                ; $9669
  and #$1F                     ; $966B
  cmp #$04                     ; $966D
  beq Loc_B1_9679              ; $966F
  cmp #$05                     ; $9671
  beq Loc_B1_9679              ; $9673
  pla                          ; $9675
  jmp Loc_B1_967E              ; $9676
Loc_B1_9679:
  pla                          ; $9679
  and #$3F                     ; $967A
  ora #$10                     ; $967C
Loc_B1_967E:
  ldy #$0B                     ; $967E
  sta (Tmp00),y                ; $9680
  ldy #$07                     ; $9682
  lda #$00                     ; $9684
  sta (Tmp00),y                ; $9686
  ldy #$0E                     ; $9688
  lda #$00                     ; $968A
  sta (Tmp00),y                ; $968C
  jmp Loc_B1_9693              ; $968E
Loc_B1_9691:
  lda #$FF                     ; $9691
Loc_B1_9693:
  rts                          ; $9693
Sub_B1_9694:
  lda z:$04                    ; $9694
  clc                          ; $9696
  adc z:ScrollX                ; $9697
  sta z:$06                    ; $9699
  lda z:ScrollPage             ; $969B
  adc #$00                     ; $969D
  and #$03                     ; $969F
  sta z:$05                    ; $96A1
  rts                          ; $96A3
Sub_B1_96A4:
  ldy #$07                     ; $96A4
  lda (Tmp00),y                ; $96A6
  beq Loc_B1_96BD              ; $96A8
  ldy #$0E                     ; $96AA
  lda (Tmp00),y                ; $96AC
  cmp #$01                     ; $96AE
  bne Loc_B1_96BD              ; $96B0
  ldy #$00                     ; $96B2
  lda (Tmp00),y                ; $96B4
  and #$80                     ; $96B6
  beq Loc_B1_96BD              ; $96B8
  jsr Sub_B1_96E8              ; $96BA
Loc_B1_96BD:
  rts                          ; $96BD
Sub_B1_96BE:
  ldy #$07                     ; $96BE
  lda (Tmp00),y                ; $96C0
  beq Loc_B1_96D0              ; $96C2
  ldy #$0E                     ; $96C4
  lda (Tmp00),y                ; $96C6
  sec                          ; $96C8
  sbc #$01                     ; $96C9
  sta (Tmp00),y                ; $96CB
  jmp Loc_B1_96E1              ; $96CD
Loc_B1_96D0:
  jsr GetRandomByte            ; $96D0
  and #$07                     ; $96D3
  bne Loc_B1_96DD              ; $96D5
  lda z:FrameCounter           ; $96D7
  ora #$01                     ; $96D9
  and #$07                     ; $96DB
Loc_B1_96DD:
  ldy #$07                     ; $96DD
  sta (Tmp00),y                ; $96DF
Loc_B1_96E1:
  ldy #$0E                     ; $96E1
  lda #$00                     ; $96E3
  sta (Tmp00),y                ; $96E5
  rts                          ; $96E7
Sub_B1_96E8:
  lda #$00                     ; $96E8
  sta z:$06                    ; $96EA
  lda #$04                     ; $96EC
  sta z:$07                    ; $96EE
Sub_B1_96F0:
  jsr Sub_B1_AA84              ; $96F0
  lda z:$05                    ; $96F3
  beq Loc_B1_970B              ; $96F5
  lda z:$06                    ; $96F7
  and #$01                     ; $96F9
  clc                          ; $96FB
  adc #$04                     ; $96FC
  ldy #$07                     ; $96FE
  sta ($04),y                  ; $9700
  iny                          ; $9702
  lda #$01                     ; $9703
  sta ($04),y                  ; $9705
  ldy #$05                     ; $9707
  sta ($04),y                  ; $9709
Loc_B1_970B:
  rts                          ; $970B
Data_B1_970C:
  .incbin "prg_bank_1.bin", $170C, $1  ; $970C
Data_B1_970D:
  .incbin "prg_bank_1.bin", $170D, $AA  ; $970D
Sub_B1_97B7:
  jsr Sub_B1_9816              ; $97B7
  ldy #$07                     ; $97BA
  lda (Tmp00),y                ; $97BC
  and #$1F                     ; $97BE
  cmp #$10                     ; $97C0
  bne Loc_B1_97CC              ; $97C2
  jsr Sub_B1_9824              ; $97C4
  beq Loc_B1_97DA              ; $97C7
  jmp Loc_B1_9812              ; $97C9
Loc_B1_97CC:
  ldy #$08                     ; $97CC
  lda (Tmp00),y                ; $97CE
  bne Loc_B1_97E3              ; $97D0
  jsr Sub_B1_AAC3              ; $97D2
  bcc Loc_B1_97DD              ; $97D5
  jsr Sub_B1_98A3              ; $97D7
Loc_B1_97DA:
  jsr Sub_B1_9816              ; $97DA
Loc_B1_97DD:
  jsr Sub_B1_AA64              ; $97DD
  jsr Sub_B1_98E7              ; $97E0
Loc_B1_97E3:
  jsr Sub_B1_9ABA              ; $97E3
  ldy z:Tmp00                  ; $97E6
  lda $030B,y                  ; $97E8
  cmp #$0C                     ; $97EB
  bcs Loc_B1_9812              ; $97ED
  lda $0307,y                  ; $97EF
  and #$80                     ; $97F2
  ora #$10                     ; $97F4
  sta $0307,y                  ; $97F6
  lda #$14                     ; $97F9
  sta $0305,y                  ; $97FB
  lda #$50                     ; $97FE
  sta $030D,y                  ; $9800
  lda $030C,y                  ; $9803
  pha                          ; $9806
  and #$0F                     ; $9807
  sta $0309,y                  ; $9809
  pla                          ; $980C
  and #$F0                     ; $980D
  sta $030A,y                  ; $980F
Loc_B1_9812:
  jsr Sub_B1_AA03              ; $9812
  rts                          ; $9815
Sub_B1_9816:
  jsr Sub_B1_AB1E              ; $9816
  lda Data_B1_990A,y           ; $9819
  sta z:Tmp02                  ; $981C
  lda Data_B1_990B,y           ; $981E
  sta z:Tmp03                  ; $9821
  rts                          ; $9823
Sub_B1_9824:
  ldy #$0D                     ; $9824
  lda (Tmp00),y                ; $9826
  beq Loc_B1_9832              ; $9828
  sec                          ; $982A
  sbc #$01                     ; $982B
  sta (Tmp00),y                ; $982D
  jmp Loc_B1_98A0              ; $982F
Loc_B1_9832:
  ldy #$0C                     ; $9832
  lda (Tmp00),y                ; $9834
  sta z:$04                    ; $9836
  and #$0F                     ; $9838
  cmp z:ScrollPage             ; $983A
  bne Loc_B1_98A0              ; $983C
  lda z:$04                    ; $983E
  and #$F0                     ; $9840
  cmp z:ScrollX                ; $9842
  bcc Loc_B1_98A0              ; $9844
  sta z:$04                    ; $9846
  lda z:ScrollX                ; $9848
  and #$F0                     ; $984A
  adc #$20                     ; $984C
  cmp z:$04                    ; $984E
  bcc Loc_B1_98A0              ; $9850
  ldy #$07                     ; $9852
  lda (Tmp00),y                ; $9854
  bmi Loc_B1_9865              ; $9856
  jsr GetRandomByte            ; $9858
  and #$1F                     ; $985B
  clc                          ; $985D
  adc #$B0                     ; $985E
  sta z:$04                    ; $9860
  jmp Loc_B1_986D              ; $9862
Loc_B1_9865:
  lda z:FrameCounter           ; $9865
  and #$1F                     ; $9867
  adc #$20                     ; $9869
  sta z:$04                    ; $986B
Loc_B1_986D:
  ldy #$0A                     ; $986D
  lda z:ScrollX                ; $986F
  clc                          ; $9871
  adc z:$04                    ; $9872
  sta (Tmp00),y                ; $9874
  dey                          ; $9876
  lda z:ScrollPage             ; $9877
  adc #$00                     ; $9879
  and #$03                     ; $987B
  sta (Tmp00),y                ; $987D
  jsr GetRandomByte            ; $987F
  and #$1F                     ; $9882
  adc #$10                     ; $9884
  clc                          ; $9886
  adc z:ScrollY                ; $9887
  ldy #$0B                     ; $9889
  sta (Tmp00),y                ; $988B
  ldy #$07                     ; $988D
  lda (Tmp00),y                ; $988F
  and #$80                     ; $9891
  beq Loc_B1_9897              ; $9893
  ora #$08                     ; $9895
Loc_B1_9897:
  sta (Tmp00),y                ; $9897
  ldy #$0E                     ; $9899
  lda #$00                     ; $989B
  sta (Tmp00),y                ; $989D
  rts                          ; $989F
Loc_B1_98A0:
  lda #$FF                     ; $98A0
  rts                          ; $98A2
Sub_B1_98A3:
  ldy #$07                     ; $98A3
  lda (Tmp00),y                ; $98A5
  and #$07                     ; $98A7
  bne Loc_B1_98B7              ; $98A9
  jsr GetRandomByte            ; $98AB
  and #$03                     ; $98AE
  bne Loc_B1_98B4              ; $98B0
  lda #$01                     ; $98B2
Loc_B1_98B4:
  jmp Loc_B1_98D0              ; $98B4
Loc_B1_98B7:
  cmp #$04                     ; $98B7
  bcs Loc_B1_98C0              ; $98B9
  lda #$04                     ; $98BB
  jmp Loc_B1_98D0              ; $98BD
Loc_B1_98C0:
  jsr GetRandomByte            ; $98C0
  and #$03                     ; $98C3
  cmp #$03                     ; $98C5
  bne Loc_B1_98CD              ; $98C7
  lda z:FrameCounter           ; $98C9
  and #$01                     ; $98CB
Loc_B1_98CD:
  clc                          ; $98CD
  adc #$05                     ; $98CE
Loc_B1_98D0:
  sta z:$04                    ; $98D0
  ldy #$07                     ; $98D2
  lda (Tmp00),y                ; $98D4
  and #$80                     ; $98D6
  beq Loc_B1_98DC              ; $98D8
  ora #$08                     ; $98DA
Loc_B1_98DC:
  ora z:$04                    ; $98DC
  sta (Tmp00),y                ; $98DE
  ldy #$0E                     ; $98E0
  lda #$00                     ; $98E2
  sta (Tmp00),y                ; $98E4
  rts                          ; $98E6
Sub_B1_98E7:
  ldy #$07                     ; $98E7
  lda (Tmp00),y                ; $98E9
  and #$07                     ; $98EB
  cmp #$04                     ; $98ED
  bne Loc_B1_9909              ; $98EF
  ldy #$0E                     ; $98F1
  lda (Tmp00),y                ; $98F3
  cmp #$04                     ; $98F5
  bne Loc_B1_9909              ; $98F7
  jsr Sub_B1_96E8              ; $98F9
  lda z:$05                    ; $98FC
  beq Loc_B1_9909              ; $98FE
  ldy #$07                     ; $9900
  lda ($04),y                  ; $9902
  clc                          ; $9904
  adc #$02                     ; $9905
  sta ($04),y                  ; $9907
Loc_B1_9909:
  rts                          ; $9909
Data_B1_990A:
  .incbin "prg_bank_1.bin", $190A, $1  ; $990A
Data_B1_990B:
  .incbin "prg_bank_1.bin", $190B, $D5  ; $990B
Sub_B1_99E0:
  ldy #$07                     ; $99E0
  lda (Tmp00),y                ; $99E2
  bmi Loc_B1_99F4              ; $99E4
  ldy #$0D                     ; $99E6
  lda (Tmp00),y                ; $99E8
  beq Loc_B1_99F4              ; $99EA
  sec                          ; $99EC
  sbc #$01                     ; $99ED
  sta (Tmp00),y                ; $99EF
  jmp Loc_B1_9A29              ; $99F1
Loc_B1_99F4:
  ldy #$07                     ; $99F4
  lda (Tmp00),y                ; $99F6
  cmp #$10                     ; $99F8
  beq Loc_B1_9A0E              ; $99FA
  cmp #$90                     ; $99FC
  beq Loc_B1_9A0E              ; $99FE
  jsr Sub_B1_9A2D              ; $9A00
  ldy #$08                     ; $9A03
  lda (Tmp00),y                ; $9A05
  bne Loc_B1_9A26              ; $9A07
  jsr Sub_B1_AAC3              ; $9A09
  bcc Loc_B1_9A20              ; $9A0C
Loc_B1_9A0E:
  ldy #$07                     ; $9A0E
  lda (Tmp00),y                ; $9A10
  bmi Loc_B1_9A1A              ; $9A12
  jsr Sub_B1_9A3B              ; $9A14
  jmp Loc_B1_9A1D              ; $9A17
Loc_B1_9A1A:
  jsr Sub_B1_9B20              ; $9A1A
Loc_B1_9A1D:
  jsr Sub_B1_9A2D              ; $9A1D
Loc_B1_9A20:
  jsr Sub_B1_AA64              ; $9A20
  jsr Sub_B1_9ACB              ; $9A23
Loc_B1_9A26:
  jsr Sub_B1_9ABA              ; $9A26
Loc_B1_9A29:
  jsr Sub_B1_AA03              ; $9A29
  rts                          ; $9A2C
Sub_B1_9A2D:
  jsr Sub_B1_AB1E              ; $9A2D
  lda Data_B1_9B81,y           ; $9A30
  sta z:Tmp02                  ; $9A33
  lda Data_B1_9B82,y           ; $9A35
  sta z:Tmp03                  ; $9A38
  rts                          ; $9A3A
Sub_B1_9A3B:
  ldy #$07                     ; $9A3B
  lda (Tmp00),y                ; $9A3D
  and #$7E                     ; $9A3F
  cmp #$02                     ; $9A41
  beq Loc_B1_9A49              ; $9A43
  cmp #$0A                     ; $9A45
  bne Loc_B1_9A56              ; $9A47
Loc_B1_9A49:
  lda #$10                     ; $9A49
  sta (Tmp00),y                ; $9A4B
  ldy #$0D                     ; $9A4D
  lda #$50                     ; $9A4F
  sta (Tmp00),y                ; $9A51
  jmp Loc_B1_9AB3              ; $9A53
Loc_B1_9A56:
  lda (Tmp00),y                ; $9A56
  cmp #$10                     ; $9A58
  bne Loc_B1_9A77              ; $9A5A
  lda z:FrameCounter           ; $9A5C
  pha                          ; $9A5E
  and #$30                     ; $9A5F
  sec                          ; $9A61
  sbc #$10                     ; $9A62
  sta z:$04                    ; $9A64
  ldy #$0C                     ; $9A66
  lda (Tmp00),y                ; $9A68
  clc                          ; $9A6A
  adc z:$04                    ; $9A6B
  ldy #$0A                     ; $9A6D
  sta (Tmp00),y                ; $9A6F
  pla                          ; $9A71
  and #$01                     ; $9A72
  jmp Loc_B1_9A9F              ; $9A74
Loc_B1_9A77:
  jsr GetRandomByte            ; $9A77
  and #$03                     ; $9A7A
  beq Loc_B1_9A97              ; $9A7C
  lda (Tmp00),y                ; $9A7E
  and #$07                     ; $9A80
  cmp #$05                     ; $9A82
  beq Loc_B1_9A8D              ; $9A84
  jsr GetRandomByte            ; $9A86
  and #$02                     ; $9A89
  bne Loc_B1_9A92              ; $9A8B
Loc_B1_9A8D:
  lda #$04                     ; $9A8D
  jmp Loc_B1_9A9F              ; $9A8F
Loc_B1_9A92:
  lda #$05                     ; $9A92
  jmp Loc_B1_9A9F              ; $9A94
Loc_B1_9A97:
  jsr GetRandomByte            ; $9A97
  and #$01                     ; $9A9A
  clc                          ; $9A9C
  adc #$02                     ; $9A9D
Loc_B1_9A9F:
  sta z:$04                    ; $9A9F
  ldy #$02                     ; $9AA1
  lda (Tmp00),y                ; $9AA3
  bmi Loc_B1_9AAD              ; $9AA5
  lda z:$04                    ; $9AA7
  ora #$08                     ; $9AA9
  sta z:$04                    ; $9AAB
Loc_B1_9AAD:
  lda z:$04                    ; $9AAD
  ldy #$07                     ; $9AAF
  sta (Tmp00),y                ; $9AB1
Loc_B1_9AB3:
  ldy #$0E                     ; $9AB3
  lda #$00                     ; $9AB5
  sta (Tmp00),y                ; $9AB7
  rts                          ; $9AB9
Sub_B1_9ABA:
  jsr Sub_B1_A957              ; $9ABA
  lda z:$04                    ; $9ABD
  beq Loc_B1_9ACA              ; $9ABF
  ldy #$08                     ; $9AC1
  lda (Tmp00),y                ; $9AC3
  sec                          ; $9AC5
  sbc #$01                     ; $9AC6
  sta (Tmp00),y                ; $9AC8
Loc_B1_9ACA:
  rts                          ; $9ACA
Sub_B1_9ACB:
  ldy #$07                     ; $9ACB  [heuristic code]
  lda (Tmp00),y                ; $9ACD
  and #$07                     ; $9ACF
  cmp #$05                     ; $9AD1
  beq Loc_B1_9ADB              ; $9AD3
  lda (Tmp00),y                ; $9AD5
  cmp #$87                     ; $9AD7
  bne Loc_B1_9B1F              ; $9AD9
Loc_B1_9ADB:
  ldy #$00                     ; $9ADB
  lda (Tmp00),y                ; $9ADD
  and #$80                     ; $9ADF
  bne Loc_B1_9AEF              ; $9AE1
  ldy #$07                     ; $9AE3
  lda (Tmp00),y                ; $9AE5
  bmi Loc_B1_9B1F              ; $9AE7
  jsr Sub_B1_AAD5              ; $9AE9
  jmp Loc_B1_9B1F              ; $9AEC
Loc_B1_9AEF:
  ldy #$0E                     ; $9AEF
  lda (Tmp00),y                ; $9AF1
  bne Loc_B1_9B1F              ; $9AF3
  ldy #$07                     ; $9AF5
  lda (Tmp00),y                ; $9AF7
  bmi Loc_B1_9B00              ; $9AF9
  lda #$E8                     ; $9AFB
  jmp Loc_B1_9B02              ; $9AFD
Loc_B1_9B00:
  lda #$F8                     ; $9B00
Loc_B1_9B02:
  sta z:$07                    ; $9B02
  lda #$00                     ; $9B04
  sta z:$06                    ; $9B06
  jsr Sub_B1_96F0              ; $9B08
  lda z:$05                    ; $9B0B
  beq Loc_B1_9B1F              ; $9B0D
  lda z:$06                    ; $9B0F
  and #$01                     ; $9B11
  clc                          ; $9B13
  adc #$0C                     ; $9B14
  ldy #$07                     ; $9B16
  sta ($04),y                  ; $9B18
  lda #$18                     ; $9B1A
  jsr EnqueueByte              ; $9B1C
Loc_B1_9B1F:
  rts                          ; $9B1F
Sub_B1_9B20:
  ldy #$07                     ; $9B20
  lda (Tmp00),y                ; $9B22
  and #$7F                     ; $9B24
  cmp #$10                     ; $9B26
  bne Loc_B1_9B4B              ; $9B28
  ldy #$00                     ; $9B2A
  lda (Tmp00),y                ; $9B2C
  bpl Loc_B1_9B80              ; $9B2E
  ldy #$02                     ; $9B30
  lda (Tmp00),y                ; $9B32
  cmp #$30                     ; $9B34
  bcc Loc_B1_9B80              ; $9B36
  cmp #$D0                     ; $9B38
  bcs Loc_B1_9B80              ; $9B3A
  lda z:HwScrollY              ; $9B3C
  cmp #$38                     ; $9B3E
  bcc Loc_B1_9B80              ; $9B40
  ldy #$07                     ; $9B42
  lda #$86                     ; $9B44
  sta (Tmp00),y                ; $9B46
  jmp Loc_B1_9B7A              ; $9B48
Loc_B1_9B4B:
  cmp #$06                     ; $9B4B
  bne Loc_B1_9B56              ; $9B4D
  lda #$87                     ; $9B4F
  sta (Tmp00),y                ; $9B51
  jmp Loc_B1_9B7A              ; $9B53
Loc_B1_9B56:
  ldy #$00                     ; $9B56
  lda (Tmp00),y                ; $9B58
  bmi Loc_B1_9B7A              ; $9B5A
  ldy #$07                     ; $9B5C
  lda #$90                     ; $9B5E
  sta (Tmp00),y                ; $9B60
  ldy #$0C                     ; $9B62
  lda (Tmp00),y                ; $9B64
  sta z:$04                    ; $9B66
  lda z:FrameCounter           ; $9B68
  and #$10                     ; $9B6A
  adc z:$04                    ; $9B6C
  ldy #$0A                     ; $9B6E
  sta (Tmp00),y                ; $9B70
  ldy #$0D                     ; $9B72
  lda (Tmp00),y                ; $9B74
  ldy #$0B                     ; $9B76
  sta (Tmp00),y                ; $9B78
Loc_B1_9B7A:
  ldy #$0E                     ; $9B7A
  lda #$00                     ; $9B7C
  sta (Tmp00),y                ; $9B7E
Loc_B1_9B80:
  rts                          ; $9B80
Data_B1_9B81:
  .incbin "prg_bank_1.bin", $1B81, $1  ; $9B81
Data_B1_9B82:
  .incbin "prg_bank_1.bin", $1B82, $C5  ; $9B82
Sub_B1_9C47:
  jsr Sub_B1_9C68              ; $9C47
  ldy #$08                     ; $9C4A
  lda (Tmp00),y                ; $9C4C
  bne Loc_B1_9C61              ; $9C4E
  jsr Sub_B1_AAC3              ; $9C50
  bcc Loc_B1_9C5B              ; $9C53
  jsr Sub_B1_9C76              ; $9C55
  jsr Sub_B1_9C68              ; $9C58
Loc_B1_9C5B:
  jsr Sub_B1_AA64              ; $9C5B
  jsr Sub_B1_9C92              ; $9C5E
Loc_B1_9C61:
  jsr Sub_B1_9ABA              ; $9C61
  jsr Sub_B1_AA03              ; $9C64
  rts                          ; $9C67
Sub_B1_9C68:
  jsr Sub_B1_AB1E              ; $9C68
  lda Data_B1_9CD4,y           ; $9C6B
  sta z:Tmp02                  ; $9C6E
  lda Data_B1_9CD5,y           ; $9C70
  sta z:Tmp03                  ; $9C73
  rts                          ; $9C75
Sub_B1_9C76:
  ldy #$07                     ; $9C76
  lda (Tmp00),y                ; $9C78
  bne Loc_B1_9C87              ; $9C7A
  jsr GetRandomByte            ; $9C7C
  and #$01                     ; $9C7F
  clc                          ; $9C81
  adc #$01                     ; $9C82
  jmp Loc_B1_9C89              ; $9C84
Loc_B1_9C87:
  lda #$00                     ; $9C87
Loc_B1_9C89:
  sta (Tmp00),y                ; $9C89
  ldy #$0E                     ; $9C8B
  lda #$00                     ; $9C8D
  sta (Tmp00),y                ; $9C8F
  rts                          ; $9C91
Sub_B1_9C92:
  ldy #$07                     ; $9C92
  lda (Tmp00),y                ; $9C94
  bne Loc_B1_9CA3              ; $9C96
  ldy #$0E                     ; $9C98
  lda (Tmp00),y                ; $9C9A
  cmp #$01                     ; $9C9C
  bne Loc_B1_9CD3              ; $9C9E
  jmp Loc_B1_9CBC              ; $9CA0
Loc_B1_9CA3:
  ldy #$0E                     ; $9CA3
  cmp #$01                     ; $9CA5
  bne Loc_B1_9CB4              ; $9CA7
  lda (Tmp00),y                ; $9CA9
  beq Loc_B1_9CBC              ; $9CAB
  cmp #$14                     ; $9CAD
  beq Loc_B1_9CBC              ; $9CAF
  jmp Loc_B1_9CD3              ; $9CB1
Loc_B1_9CB4:
  lda (Tmp00),y                ; $9CB4
  beq Loc_B1_9CBC              ; $9CB6
  cmp #$16                     ; $9CB8
  bne Loc_B1_9CD3              ; $9CBA
Loc_B1_9CBC:
  ldy #$00                     ; $9CBC
  lda (Tmp00),y                ; $9CBE
  and #$80                     ; $9CC0
  bne Loc_B1_9CD0              ; $9CC2
  ldy #$0C                     ; $9CC4
  lda (Tmp00),y                ; $9CC6
  bpl Loc_B1_9CD3              ; $9CC8
  jsr Sub_B1_AAD5              ; $9CCA
  jmp Loc_B1_9CD3              ; $9CCD
Loc_B1_9CD0:
  jsr Sub_B1_946C              ; $9CD0
Loc_B1_9CD3:
  rts                          ; $9CD3
Data_B1_9CD4:
  .incbin "prg_bank_1.bin", $1CD4, $1  ; $9CD4
Data_B1_9CD5:
  .incbin "prg_bank_1.bin", $1CD5, $E4  ; $9CD5
Sub_B1_9DB9:
  jsr Sub_B1_9DEE              ; $9DB9
  ldy #$00                     ; $9DBC
  lda (Tmp00),y                ; $9DBE
  and #$1F                     ; $9DC0
  cmp #$0A                     ; $9DC2
  beq Loc_B1_9DE8              ; $9DC4
  ldy #$08                     ; $9DC6
  lda (Tmp00),y                ; $9DC8
  bne Loc_B1_9DDA              ; $9DCA
  jsr Sub_B1_AAC3              ; $9DCC
  bcc Loc_B1_9DD7              ; $9DCF
  jsr Sub_B1_9DFC              ; $9DD1
  jsr Sub_B1_9DEE              ; $9DD4
Loc_B1_9DD7:
  jsr Sub_B1_AA64              ; $9DD7
Loc_B1_9DDA:
  jsr Sub_B1_9ABA              ; $9DDA
  lda z:$04                    ; $9DDD
  beq Loc_B1_9DE4              ; $9DDF
  jsr Sub_B1_9E20              ; $9DE1
Loc_B1_9DE4:
  jsr Sub_B1_AA03              ; $9DE4
  rts                          ; $9DE7
Loc_B1_9DE8:
  jsr Sub_B1_A957              ; $9DE8
  jmp Loc_B1_9DE4              ; $9DEB
Sub_B1_9DEE:
  jsr Sub_B1_AB1E              ; $9DEE
  lda Data_B1_9E74,y           ; $9DF1
  sta z:Tmp02                  ; $9DF4
  lda Data_B1_9E75,y           ; $9DF6
  sta z:Tmp03                  ; $9DF9
  rts                          ; $9DFB
Sub_B1_9DFC:
  ldy #$07                     ; $9DFC
  lda (Tmp00),y                ; $9DFE
  bne Loc_B1_9E07              ; $9E00
  lda #$01                     ; $9E02
  jmp Loc_B1_9E15              ; $9E04
Loc_B1_9E07:
  cmp #$03                     ; $9E07
  beq Loc_B1_9E19              ; $9E09
  ldy #$00                     ; $9E0B
  lda (Tmp00),y                ; $9E0D
  and #$80                     ; $9E0F
  bne Loc_B1_9E19              ; $9E11
  lda #$00                     ; $9E13
Loc_B1_9E15:
  ldy #$07                     ; $9E15
  sta (Tmp00),y                ; $9E17
Loc_B1_9E19:
  ldy #$0E                     ; $9E19
  lda #$00                     ; $9E1B
  sta (Tmp00),y                ; $9E1D
  rts                          ; $9E1F
Sub_B1_9E20:
  ldy #$07                     ; $9E20
  lda (Tmp00),y                ; $9E22
  beq Loc_B1_9E73              ; $9E24
  iny                          ; $9E26
  lda (Tmp00),y                ; $9E27
  cmp #$10                     ; $9E29
  beq Loc_B1_9E3A              ; $9E2B
  lda (Tmp00),y                ; $9E2D
  cmp #$20                     ; $9E2F
  bne Loc_B1_9E73              ; $9E31
  jsr GetRandomByte            ; $9E33
  and #$01                     ; $9E36
  beq Loc_B1_9E73              ; $9E38
Loc_B1_9E3A:
  ldy #$00                     ; $9E3A
  lda (Tmp00),y                ; $9E3C
  bmi Loc_B1_9E4C              ; $9E3E
  ldy #$0C                     ; $9E40
  lda (Tmp00),y                ; $9E42
  bpl Loc_B1_9E73              ; $9E44
  jsr Sub_B1_AAD5              ; $9E46
  jmp Loc_B1_9E73              ; $9E49
Loc_B1_9E4C:
  lda #$08                     ; $9E4C
  sta z:$06                    ; $9E4E
  ldy #$07                     ; $9E50
  lda (Tmp00),y                ; $9E52
  cmp #$03                     ; $9E54
  beq Loc_B1_9E5D              ; $9E56
  lda #$FC                     ; $9E58
  jmp Loc_B1_9E5F              ; $9E5A
Loc_B1_9E5D:
  lda #$04                     ; $9E5D
Loc_B1_9E5F:
  sta z:$07                    ; $9E5F
  jsr Sub_B1_96F0              ; $9E61
  lda z:$05                    ; $9E64
  beq Loc_B1_9E73              ; $9E66
  lda z:$06                    ; $9E68
  and #$01                     ; $9E6A
  clc                          ; $9E6C
  adc #$0A                     ; $9E6D
  ldy #$07                     ; $9E6F
  sta ($04),y                  ; $9E71
Loc_B1_9E73:
  rts                          ; $9E73
Data_B1_9E74:
  .incbin "prg_bank_1.bin", $1E74, $1  ; $9E74
Data_B1_9E75:
  .incbin "prg_bank_1.bin", $1E75, $192  ; $9E75
  jsr Sub_B1_A032              ; $A007
  ldy #$08                     ; $A00A
  lda (Tmp00),y                ; $A00C
  bne Loc_B1_A02B              ; $A00E
  jsr Sub_B1_AAC3              ; $A010
  bcc Loc_B1_A01B              ; $A013
  jsr Sub_C43D                 ; $A015
  jmp Loc_B1_A031              ; $A018
Loc_B1_A01B:
  jsr Sub_B1_AA64              ; $A01B
  ldy #$0E                     ; $A01E
  lda (Tmp00),y                ; $A020
  cmp #$04                     ; $A022
  bne Loc_B1_A02B              ; $A024
  lda #$11                     ; $A026
  jsr EnqueueByte              ; $A028
Loc_B1_A02B:
  jsr Sub_B1_9ABA              ; $A02B
  jsr Sub_B1_AA03              ; $A02E
Loc_B1_A031:
  rts                          ; $A031
Sub_B1_A032:
  lda #$3B                     ; $A032
  sta z:Tmp02                  ; $A034
  lda #$A0                     ; $A036
  sta z:Tmp03                  ; $A038
  rts                          ; $A03A
  .incbin "prg_bank_1.bin", $203B, $400  ; $A03B
  .incbin "prg_bank_1.bin", $243B, $400  ; $A43B
  .incbin "prg_bank_1.bin", $283B, $11C  ; $A83B
Sub_B1_A957:
  ldy #$0E                     ; $A957
  lda (Tmp00),y                ; $A959
  asl a                        ; $A95B
  asl a                        ; $A95C
  adc #$03                     ; $A95D
  pha                          ; $A95F
  tay                          ; $A960
  dey                          ; $A961
  lda (Tmp02),y                ; $A962
  and #$E0                     ; $A964
  beq Loc_B1_A96B              ; $A966
  jsr Sub_B1_A9BD              ; $A968
Loc_B1_A96B:
  pla                          ; $A96B
  pha                          ; $A96C
  tay                          ; $A96D
  dey                          ; $A96E
  dey                          ; $A96F
  lda (Tmp02),y                ; $A970
  and #$C0                     ; $A972
  beq Loc_B1_A983              ; $A974
  jsr Sub_B1_A9E2              ; $A976
  beq Loc_B1_A983              ; $A979
  lda #$00                     ; $A97B
  sta z:$04                    ; $A97D
  pla                          ; $A97F
  jmp Loc_B1_A9BC              ; $A980
Loc_B1_A983:
  lda #$01                     ; $A983
  sta z:$04                    ; $A985
  pla                          ; $A987
  pha                          ; $A988
  tay                          ; $A989
  lda (Tmp02),y                ; $A98A
  clc                          ; $A98C
  beq Loc_B1_A9B0              ; $A98D
  bpl Loc_B1_A99E              ; $A98F
  ldy #$0A                     ; $A991
  adc (Tmp00),y                ; $A993
  sta (Tmp00),y                ; $A995
  bcs Loc_B1_A9B0              ; $A997
  lda #$FF                     ; $A999
  jmp Loc_B1_A9A9              ; $A99B
Loc_B1_A99E:
  ldy #$0A                     ; $A99E
  adc (Tmp00),y                ; $A9A0
  sta (Tmp00),y                ; $A9A2
  bcc Loc_B1_A9B0              ; $A9A4
  clc                          ; $A9A6
  lda #$01                     ; $A9A7
Loc_B1_A9A9:
  dey                          ; $A9A9
  adc (Tmp00),y                ; $A9AA
  and #$03                     ; $A9AC
  sta (Tmp00),y                ; $A9AE
Loc_B1_A9B0:
  pla                          ; $A9B0
  tay                          ; $A9B1
  iny                          ; $A9B2
  lda (Tmp02),y                ; $A9B3
  ldy #$0B                     ; $A9B5
  clc                          ; $A9B7
  adc (Tmp00),y                ; $A9B8
  sta (Tmp00),y                ; $A9BA
Loc_B1_A9BC:
  rts                          ; $A9BC
Sub_B1_A9BD:
  jsr LsrA4                    ; $A9BD
  lsr a                        ; $A9C0
  tax                          ; $A9C1
  lda #$01                     ; $A9C2
  sta z:$04                    ; $A9C4
Loc_B1_A9C6:
  asl z:$04                    ; $A9C6
  dex                          ; $A9C8
  bne Loc_B1_A9C6              ; $A9C9
  lda z:$04                    ; $A9CB
  and z:FrameCounter           ; $A9CD
  bne Loc_B1_A9D6              ; $A9CF
  lda (Tmp02),y                ; $A9D1
  jmp Loc_B1_A9DB              ; $A9D3
Loc_B1_A9D6:
  lda (Tmp02),y                ; $A9D6
  clc                          ; $A9D8
  adc #$01                     ; $A9D9
Loc_B1_A9DB:
  and #$1F                     ; $A9DB
  ldy #$05                     ; $A9DD
  sta (Tmp00),y                ; $A9DF
  rts                          ; $A9E1
Sub_B1_A9E2:
  cmp #$40                     ; $A9E2
  bne Loc_B1_A9EB              ; $A9E4
  lda #$01                     ; $A9E6
  jmp Loc_B1_A9F6              ; $A9E8
Loc_B1_A9EB:
  cmp #$80                     ; $A9EB
  bne Loc_B1_A9F4              ; $A9ED
  lda #$03                     ; $A9EF
  jmp Loc_B1_A9F6              ; $A9F1
Loc_B1_A9F4:
  lda #$07                     ; $A9F4
Loc_B1_A9F6:
  sta z:$04                    ; $A9F6
  lda z:Tmp00                  ; $A9F8
  jsr LsrA4                    ; $A9FA
  clc                          ; $A9FD
  adc z:FrameCounter           ; $A9FE
  and z:$04                    ; $AA00
  rts                          ; $AA02
Sub_B1_AA03:
  ldy #$09                     ; $AA03
  lda (Tmp00),y                ; $AA05
  and #$03                     ; $AA07
  sta z:$04                    ; $AA09
  iny                          ; $AA0B
  lda (Tmp00),y                ; $AA0C
  sec                          ; $AA0E
  sbc z:ScrollX                ; $AA0F
  sta z:$05                    ; $AA11
  bcs Loc_B1_AA17              ; $AA13
  dec z:$04                    ; $AA15
Loc_B1_AA17:
  lda z:$04                    ; $AA17
  and #$03                     ; $AA19
  sec                          ; $AA1B
  sbc z:ScrollPage             ; $AA1C
  bne Loc_B1_AA41              ; $AA1E
  lda z:$05                    ; $AA20
  ldy #$02                     ; $AA22
  sta (Tmp00),y                ; $AA24
  ldy #$0B                     ; $AA26
  lda (Tmp00),y                ; $AA28
  sec                          ; $AA2A
  sbc z:ScrollY                ; $AA2B
  cmp #$08                     ; $AA2D
  bcc Loc_B1_AA41              ; $AA2F
  cmp #$90                     ; $AA31
  bcs Loc_B1_AA41              ; $AA33
  ldy #$01                     ; $AA35
  sta (Tmp00),y                ; $AA37
  dey                          ; $AA39
  lda (Tmp00),y                ; $AA3A
  ora #$80                     ; $AA3C
  jmp Loc_B1_AA47              ; $AA3E
Loc_B1_AA41:
  ldy #$00                     ; $AA41
  lda (Tmp00),y                ; $AA43
  and #$7F                     ; $AA45
Loc_B1_AA47:
  sta (Tmp00),y                ; $AA47
  jsr Sub_C3FC                 ; $AA49
  ldy #$00                     ; $AA4C
  lda (Tmp02),y                ; $AA4E
  ldy #$04                     ; $AA50
  sta (Tmp00),y                ; $AA52
  asl a                        ; $AA54
  asl a                        ; $AA55
  dey                          ; $AA56
  clc                          ; $AA57
  adc (Tmp00),y                ; $AA58
  bcc Loc_B1_AA63              ; $AA5A
  lda #$00                     ; $AA5C
  sta (Tmp00),y                ; $AA5E
  iny                          ; $AA60
  sta (Tmp00),y                ; $AA61
Loc_B1_AA63:
  rts                          ; $AA63
Sub_B1_AA64:
  ldy #$0E                     ; $AA64
  lda (Tmp00),y                ; $AA66
  asl a                        ; $AA68
  asl a                        ; $AA69
  pha                          ; $AA6A
  tay                          ; $AA6B
  iny                          ; $AA6C
  lda (Tmp02),y                ; $AA6D
  and #$3F                     ; $AA6F
  ldy #$08                     ; $AA71
  sta (Tmp00),y                ; $AA73
  pla                          ; $AA75
  jsr Sub_B1_AA7A              ; $AA76
  rts                          ; $AA79
Sub_B1_AA7A:
  tay                          ; $AA7A
  iny                          ; $AA7B
  iny                          ; $AA7C
  lda (Tmp02),y                ; $AA7D
  ldy #$05                     ; $AA7F
  sta (Tmp00),y                ; $AA81
  rts                          ; $AA83
Sub_B1_AA84:
  lda ObjectCount              ; $AA84  [heuristic code]
  cmp #$0F                     ; $AA87
  bcc Loc_B1_AA92              ; $AA89
  lda #$00                     ; $AA8B
  sta z:$05                    ; $AA8D
  jmp Loc_B1_AAC2              ; $AA8F
Loc_B1_AA92:
  inc ObjectCount              ; $AA92
  lda ObjectCount              ; $AA95
  jsr AslA4                    ; $AA98
  sta z:$04                    ; $AA9B
  lda #$03                     ; $AA9D
  sta z:$05                    ; $AA9F
  lda #$43                     ; $AAA1
  ldy #$00                     ; $AAA3
  sta ($04),y                  ; $AAA5
  ldy #$09                     ; $AAA7
  lda (Tmp00),y                ; $AAA9
  sta ($04),y                  ; $AAAB
  iny                          ; $AAAD
  lda (Tmp00),y                ; $AAAE
  clc                          ; $AAB0
  adc z:$06                    ; $AAB1
  sta ($04),y                  ; $AAB3
  iny                          ; $AAB5
  lda (Tmp00),y                ; $AAB6
  clc                          ; $AAB8
  adc z:$07                    ; $AAB9
  sta ($04),y                  ; $AABB
  jsr GetRandomByte            ; $AABD
  sta z:$06                    ; $AAC0
Loc_B1_AAC2:
  rts                          ; $AAC2
Sub_B1_AAC3:
  ldy #$00                     ; $AAC3
  lda (Tmp02),y                ; $AAC5
  sta z:$04                    ; $AAC7
  ldy #$0E                     ; $AAC9
  lda (Tmp00),y                ; $AACB
  clc                          ; $AACD
  adc #$01                     ; $AACE
  sta (Tmp00),y                ; $AAD0
  cmp z:$04                    ; $AAD2
  rts                          ; $AAD4
Sub_B1_AAD5:
  lda ObjectCount              ; $AAD5
  cmp #$0F                     ; $AAD8
  bcs Loc_B1_AB1D              ; $AADA
  lda z:Tmp00                  ; $AADC
  pha                          ; $AADE
  inc ObjectCount              ; $AADF
  lda ObjectCount              ; $AAE2
  jsr AslA4                    ; $AAE5
  tay                          ; $AAE8
  sta z:Tmp00                  ; $AAE9
  lda z:ScrollX                ; $AAEB
  clc                          ; $AAED
  adc #$B0                     ; $AAEE
  sta $030A,y                  ; $AAF0
  lda z:ScrollPage             ; $AAF3
  adc #$00                     ; $AAF5
  and #$03                     ; $AAF7
  sta $0309,y                  ; $AAF9
  lda z:ScrollY                ; $AAFC
  adc #$18                     ; $AAFE
  sta $030B,y                  ; $AB00
  lda #$C1                     ; $AB03
  sta $0300,y                  ; $AB05
  lda #$18                     ; $AB08
  sta ObjectCount,y            ; $AB0A
  lda #$B0                     ; $AB0D
  sta $0302,y                  ; $AB0F
  lda #$80                     ; $AB12
  sta $030E,y                  ; $AB14
  jsr Sub_B1_8EA2              ; $AB17
  pla                          ; $AB1A
  sta z:Tmp00                  ; $AB1B
Loc_B1_AB1D:
  rts                          ; $AB1D
Sub_B1_AB1E:
  ldy #$07                     ; $AB1E
  lda (Tmp00),y                ; $AB20
  and #$1F                     ; $AB22
  asl a                        ; $AB24
  tay                          ; $AB25
  rts                          ; $AB26
Sub_B1_AB27:
  lda ObjectCount              ; $AB27
  beq Loc_B1_AB9C              ; $AB2A
  sta z:Tmp02                  ; $AB2C
  lda #$10                     ; $AB2E
  sta z:Tmp00                  ; $AB30
  lda #$03                     ; $AB32
  sta z:Tmp01                  ; $AB34
Loc_B1_AB36:
  ldy #$04                     ; $AB36
  lda (Tmp00),y                ; $AB38
  and #$80                     ; $AB3A
  beq Loc_B1_AB91              ; $AB3C
  ldy #$00                     ; $AB3E
  lda (Tmp00),y                ; $AB40
  and #$1F                     ; $AB42
  cmp #$11                     ; $AB44
  bne Loc_B1_AB50              ; $AB46
  lda $04AA                    ; $AB48
  bmi Loc_B1_AB5C              ; $AB4B
  jmp Loc_B1_AB9C              ; $AB4D
Loc_B1_AB50:
  cmp #$12                     ; $AB50
  bne Loc_B1_AB5C              ; $AB52
  ldy #$07                     ; $AB54
  lda (Tmp00),y                ; $AB56
  cmp #$04                     ; $AB58
  bne Loc_B1_AB9C              ; $AB5A
Loc_B1_AB5C:
  ldy #$06                     ; $AB5C
  lda (Tmp00),y                ; $AB5E
  sec                          ; $AB60
  sbc #$01                     ; $AB61
  sta (Tmp00),y                ; $AB63
  beq Loc_B1_AB6A              ; $AB65
  jmp Loc_B1_AB9C              ; $AB67
Loc_B1_AB6A:
  ldy #$00                     ; $AB6A
  lda (Tmp00),y                ; $AB6C
  and #$1F                     ; $AB6E
  sec                          ; $AB70
  sbc #$11                     ; $AB71
  bcc Loc_B1_AB9C              ; $AB73
  cmp #$07                     ; $AB75
  bcs Loc_B1_AB9C              ; $AB77
  pha                          ; $AB79
  lda (Tmp00),y                ; $AB7A
  and #$1F                     ; $AB7C
  jsr Sub_B1_AE43              ; $AB7E
  pla                          ; $AB81
  asl a                        ; $AB82
  tay                          ; $AB83
  lda Data_B1_AB9D,y           ; $AB84
  sta z:Tmp03                  ; $AB87
  lda Data_B1_AB9E,y           ; $AB89
  sta z:$04                    ; $AB8C
  jmp ($0003)                  ; $AB8E
Loc_B1_AB91:
  lda #$10                     ; $AB91
  clc                          ; $AB93
  adc z:Tmp00                  ; $AB94
  sta z:Tmp00                  ; $AB96
  dec z:Tmp02                  ; $AB98
  bne Loc_B1_AB36              ; $AB9A
Loc_B1_AB9C:
  rts                          ; $AB9C
Data_B1_AB9D:
  .addr Sub_B1_ABAB, Sub_B1_ABB9, Sub_B1_ABBD, Sub_B1_ABC1, Sub_B1_ABCD  ; $AB9D pointer table
  .incbin "prg_bank_1.bin", $2BA7, $4  ; $ABA7
Sub_B1_ABAB:
  ldy #$0D                     ; $ABAB
  lda (Tmp00),y                ; $ABAD
  and $04AB                    ; $ABAF
  sta $04AB                    ; $ABB2
  jsr Sub_B1_AFC6              ; $ABB5
  rts                          ; $ABB8
Sub_B1_ABB9:
  jsr Sub_B1_ABE0              ; $ABB9
  rts                          ; $ABBC
Sub_B1_ABBD:
  jsr Sub_B1_AC5B              ; $ABBD
  rts                          ; $ABC0
Sub_B1_ABC1:
  jsr Sub_B1_AFC6              ; $ABC1
  lda $04AB                    ; $ABC4
  beq Loc_B1_ABCC              ; $ABC7
  jsr Sub_B1_AC8A              ; $ABC9
Loc_B1_ABCC:
  rts                          ; $ABCC
Sub_B1_ABCD:
  jsr Sub_B1_AFC6              ; $ABCD
  rts                          ; $ABD0
  ldy #$07                     ; $ABD1  [heuristic code]
  lda (Tmp00),y                ; $ABD3
  beq Loc_B1_ABDF              ; $ABD5
  jsr Sub_B1_AFC6              ; $ABD7
  lda #$06                     ; $ABDA
  sta $04AA                    ; $ABDC
Loc_B1_ABDF:
  rts                          ; $ABDF
Sub_B1_ABE0:
  inc ObjectCount              ; $ABE0
  lda ObjectCount              ; $ABE3
  inc ObjectCount              ; $ABE6
  jsr AslA4                    ; $ABE9
  sta z:Tmp03                  ; $ABEC
  lda #$03                     ; $ABEE
  sta z:$04                    ; $ABF0
  ldy #$00                     ; $ABF2
Loc_B1_ABF4:
  lda Data_B1_AC49,y           ; $ABF4
  sta (Tmp03),y                ; $ABF7
  iny                          ; $ABF9
  cpy #$09                     ; $ABFA
  bne Loc_B1_ABF4              ; $ABFC
  iny                          ; $ABFE
  lda (Tmp00),y                ; $ABFF
  sec                          ; $AC01
  sbc #$08                     ; $AC02
  sta (Tmp03),y                ; $AC04
  dey                          ; $AC06
  lda (Tmp00),y                ; $AC07
  sbc #$00                     ; $AC09
  and #$03                     ; $AC0B
  sta (Tmp03),y                ; $AC0D
  iny                          ; $AC0F
  iny                          ; $AC10
  lda (Tmp00),y                ; $AC11
  sec                          ; $AC13
  sbc #$10                     ; $AC14
  sta (Tmp03),y                ; $AC16
  ldy #$0E                     ; $AC18
  lda #$00                     ; $AC1A
  sta (Tmp03),y                ; $AC1C
  ldy #$00                     ; $AC1E
  lda #$10                     ; $AC20
  clc                          ; $AC22
  adc z:Tmp03                  ; $AC23
  sta z:Tmp03                  ; $AC25
Loc_B1_AC27:
  lda Data_B1_AC52,y           ; $AC27
  sta (Tmp03),y                ; $AC2A
  iny                          ; $AC2C
  cpy #$09                     ; $AC2D
  bne Loc_B1_AC27              ; $AC2F
  lda (Tmp00),y                ; $AC31
  sta (Tmp03),y                ; $AC33
  iny                          ; $AC35
  lda (Tmp00),y                ; $AC36
  sta (Tmp03),y                ; $AC38
  iny                          ; $AC3A
  lda (Tmp00),y                ; $AC3B
  sta (Tmp03),y                ; $AC3D
  ldy #$0E                     ; $AC3F
  lda #$00                     ; $AC41
  sta (Tmp03),y                ; $AC43
  jsr Sub_C43D                 ; $AC45
  rts                          ; $AC48
Data_B1_AC49:
  .incbin "prg_bank_1.bin", $2C49, $9  ; $AC49
Data_B1_AC52:
  .incbin "prg_bank_1.bin", $2C52, $9  ; $AC52
Sub_B1_AC5B:
  ldy #$00                     ; $AC5B
Loc_B1_AC5D:
  lda Data_B1_AC81,y           ; $AC5D
  sta (Tmp00),y                ; $AC60
  iny                          ; $AC62
  cpy #$09                     ; $AC63
  bne Loc_B1_AC5D              ; $AC65
  ldy #$0E                     ; $AC67
  lda #$00                     ; $AC69
  sta (Tmp00),y                ; $AC6B
  ldy #$10                     ; $AC6D
  lda (Tmp00),y                ; $AC6F
  and #$1F                     ; $AC71
  cmp #$13                     ; $AC73
  bne Loc_B1_AC80              ; $AC75
  jsr Sub_B1_AFE3              ; $AC77
  ldy #$18                     ; $AC7A
  lda #$04                     ; $AC7C
  sta (Tmp00),y                ; $AC7E
Loc_B1_AC80:
  rts                          ; $AC80
Data_B1_AC81:
  .incbin "prg_bank_1.bin", $2C81, $9  ; $AC81
Sub_B1_AC8A:
  lda $04AA                    ; $AC8A
  and #$7F                     ; $AC8D
  cmp #$03                     ; $AC8F
  bne Loc_B1_AC96              ; $AC91
  jmp Loc_B1_ACAE              ; $AC93
Loc_B1_AC96:
  lda $04AB                    ; $AC96
  cmp #$03                     ; $AC99
  beq Loc_B1_ACA4              ; $AC9B
  tay                          ; $AC9D
  dey                          ; $AC9E
  sty z:Tmp03                  ; $AC9F
  jmp Loc_B1_ACE6              ; $ACA1
Loc_B1_ACA4:
  lda z:FrameCounter           ; $ACA4
  lsr a                        ; $ACA6
  and #$01                     ; $ACA7
  sta z:Tmp03                  ; $ACA9
  jmp Loc_B1_ACE6              ; $ACAB
Loc_B1_ACAE:
  lda $04AB                    ; $ACAE
  cmp #$07                     ; $ACB1
  beq Loc_B1_ACD2              ; $ACB3
  tay                          ; $ACB5
  lda Data_B1_AD23,y           ; $ACB6
  sta z:Tmp03                  ; $ACB9
  bpl Loc_B1_ACDD              ; $ACBB
  and #$03                     ; $ACBD
  sta z:Tmp03                  ; $ACBF
  jsr GetRandomByte            ; $ACC1
  and #$01                     ; $ACC4
  clc                          ; $ACC6
  adc z:Tmp03                  ; $ACC7
  tay                          ; $ACC9
  lda Data_B1_AD2A,y           ; $ACCA
  sta z:Tmp03                  ; $ACCD
  jmp Loc_B1_ACDD              ; $ACCF
Loc_B1_ACD2:
  jsr GetRandomByte            ; $ACD2
  and #$03                     ; $ACD5
  tay                          ; $ACD7
  lda Data_B1_AD2A,y           ; $ACD8
  sta z:Tmp03                  ; $ACDB
Loc_B1_ACDD:
  jsr Sub_B1_AD18              ; $ACDD
  adc #$30                     ; $ACE0
  tax                          ; $ACE2
  jmp Loc_B1_ACFB              ; $ACE3
Loc_B1_ACE6:
  jsr Sub_B1_AD18              ; $ACE6
  sta z:Tmp03                  ; $ACE9
  tax                          ; $ACEB
  lda $04AA                    ; $ACEC
  and #$7F                     ; $ACEF
  cmp #$02                     ; $ACF1
  bne Loc_B1_ACFB              ; $ACF3
  lda #$18                     ; $ACF5
  clc                          ; $ACF7
  adc z:Tmp03                  ; $ACF8
  tax                          ; $ACFA
Loc_B1_ACFB:
  inc ObjectCount              ; $ACFB
  lda ObjectCount              ; $ACFE
  jsr AslA4                    ; $AD01
  sta z:$04                    ; $AD04
  lda #$03                     ; $AD06
  sta z:$05                    ; $AD08
  ldy #$00                     ; $AD0A
Loc_B1_AD0C:
  lda Data_B1_AD2E,x           ; $AD0C
  sta ($04),y                  ; $AD0F
  inx                          ; $AD11
  iny                          ; $AD12
  cpy #$0C                     ; $AD13
  bne Loc_B1_AD0C              ; $AD15
  rts                          ; $AD17
Sub_B1_AD18:
  lda z:Tmp03                  ; $AD18
  asl a                        ; $AD1A
  asl a                        ; $AD1B
  sta z:Tmp03                  ; $AD1C
  asl a                        ; $AD1E
  clc                          ; $AD1F
  adc z:Tmp03                  ; $AD20
  rts                          ; $AD22
Data_B1_AD23:
  .incbin "prg_bank_1.bin", $2D23, $7  ; $AD23
Data_B1_AD2A:
  .incbin "prg_bank_1.bin", $2D2A, $4  ; $AD2A
Data_B1_AD2E:
  .incbin "prg_bank_1.bin", $2D2E, $54  ; $AD2E
Sub_B1_AD82:
  lda $011C                    ; $AD82
  and #$F0                     ; $AD85
  lsr a                        ; $AD87
  lsr a                        ; $AD88
  clc                          ; $AD89
  adc $011A                    ; $AD8A
  sta z:$08                    ; $AD8D
  lda $011C                    ; $AD8F
  and #$0F                     ; $AD92
  asl a                        ; $AD94
  asl a                        ; $AD95
  clc                          ; $AD96
  adc $011B                    ; $AD97
  sta z:$09                    ; $AD9A
  ldx ObjectCount              ; $AD9C
  lda #$10                     ; $AD9F
  sta z:Tmp00                  ; $ADA1
  lda #$03                     ; $ADA3
  sta z:Tmp01                  ; $ADA5
Loc_B1_ADA7:
  ldy #$00                     ; $ADA7
  lda (Tmp00),y                ; $ADA9
  and #$C0                     ; $ADAB
  cmp #$C0                     ; $ADAD
  beq Loc_B1_ADB4              ; $ADAF
  jmp Loc_B1_AE27              ; $ADB1
Loc_B1_ADB4:
  ldy #$0F                     ; $ADB4
  lda (Tmp00),y                ; $ADB6
  bne Loc_B1_ADBD              ; $ADB8
  jmp Loc_B1_AE27              ; $ADBA
Loc_B1_ADBD:
  ldy #$01                     ; $ADBD
  lda (Tmp00),y                ; $ADBF
  sta z:Tmp02                  ; $ADC1
  iny                          ; $ADC3
  lda (Tmp00),y                ; $ADC4
  sta z:Tmp03                  ; $ADC6
  ldy #$0F                     ; $ADC8
  lda (Tmp00),y                ; $ADCA
  and #$F0                     ; $ADCC
  lsr a                        ; $ADCE
  lsr a                        ; $ADCF
  clc                          ; $ADD0
  adc z:Tmp02                  ; $ADD1
  sta z:$04                    ; $ADD3
  bcc Loc_B1_ADDA              ; $ADD5
  jmp Loc_B1_AE27              ; $ADD7
Loc_B1_ADDA:
  lda (Tmp00),y                ; $ADDA
  and #$0F                     ; $ADDC
  asl a                        ; $ADDE
  asl a                        ; $ADDF
  clc                          ; $ADE0
  adc z:Tmp03                  ; $ADE1
  sta z:$05                    ; $ADE3
  bcc Loc_B1_ADEA              ; $ADE5
  jmp Loc_B1_AE27              ; $ADE7
Loc_B1_ADEA:
  lda $011C                    ; $ADEA
  beq Loc_B1_AE27              ; $ADED
  lda $011A                    ; $ADEF
  sec                          ; $ADF2
  sbc z:$04                    ; $ADF3
  bcs Loc_B1_AE01              ; $ADF5
  lda z:$08                    ; $ADF7
  sec                          ; $ADF9
  sbc z:Tmp02                  ; $ADFA
  bcc Loc_B1_AE27              ; $ADFC
  jmp Loc_B1_AE08              ; $ADFE
Loc_B1_AE01:
  lda z:$08                    ; $AE01
  sec                          ; $AE03
  sbc z:Tmp02                  ; $AE04
  bcs Loc_B1_AE27              ; $AE06
Loc_B1_AE08:
  lda $011B                    ; $AE08
  sec                          ; $AE0B
  sbc z:$05                    ; $AE0C
  bcs Loc_B1_AE1A              ; $AE0E
  lda z:$09                    ; $AE10
  sec                          ; $AE12
  sbc z:Tmp03                  ; $AE13
  bcc Loc_B1_AE27              ; $AE15
  jmp Loc_B1_AE21              ; $AE17
Loc_B1_AE1A:
  lda z:$09                    ; $AE1A
  sec                          ; $AE1C
  sbc z:Tmp03                  ; $AE1D
  bcs Loc_B1_AE27              ; $AE1F
Loc_B1_AE21:
  lda $0119                    ; $AE21
  jmp Loc_B1_AE29              ; $AE24
Loc_B1_AE27:
  lda #$00                     ; $AE27
Loc_B1_AE29:
  sta z:$06                    ; $AE29
  ldy #$04                     ; $AE2B
  lda (Tmp00),y                ; $AE2D
  and #$1F                     ; $AE2F
  ora z:$06                    ; $AE31
  sta (Tmp00),y                ; $AE33
  lda z:Tmp00                  ; $AE35
  clc                          ; $AE37
  adc #$10                     ; $AE38
  sta z:Tmp00                  ; $AE3A
  dex                          ; $AE3C
  beq Loc_B1_AE42              ; $AE3D
  jmp Loc_B1_ADA7              ; $AE3F
Loc_B1_AE42:
  rts                          ; $AE42
Sub_B1_AE43:
  asl a                        ; $AE43
  tax                          ; $AE44
  lda Data_B1_AE76,x           ; $AE45
  beq Loc_B1_AE59              ; $AE48
  clc                          ; $AE4A
  adc z:PlayerLifeLo           ; $AE4B
  bcs Loc_B1_AE55              ; $AE4D
  sta z:PlayerLifeLo           ; $AE4F
  cmp #$C9                     ; $AE51
  bcc Loc_B1_AE59              ; $AE53
Loc_B1_AE55:
  lda #$C8                     ; $AE55
  sta z:PlayerLifeLo           ; $AE57
Loc_B1_AE59:
  lda Data_B1_AE77,x           ; $AE59
  beq Loc_B1_AE75              ; $AE5C
  clc                          ; $AE5E
  adc z:AmmoLo                 ; $AE5F
  sta z:AmmoLo                 ; $AE61
  lda #$00                     ; $AE63
  adc z:AmmoHi                 ; $AE65
  sta z:AmmoHi                 ; $AE67
  beq Loc_B1_AE75              ; $AE69
  lda z:AmmoLo                 ; $AE6B
  cmp #$91                     ; $AE6D
  bcc Loc_B1_AE75              ; $AE6F
  lda #$90                     ; $AE71
  sta z:AmmoLo                 ; $AE73
Loc_B1_AE75:
  rts                          ; $AE75
Data_B1_AE76:
  .incbin "prg_bank_1.bin", $2E76, $1  ; $AE76
Data_B1_AE77:
  .incbin "prg_bank_1.bin", $2E77, $89  ; $AE77
  jsr Sub_B1_B013              ; $AF00
  lda z:PaletteSetIndex        ; $AF03
  cmp #$69                     ; $AF05
  beq Loc_B1_AF0F              ; $AF07
  lda z:AmmoLo                 ; $AF09
  ora z:AmmoHi                 ; $AF0B
  beq Loc_B1_AF4E              ; $AF0D
Loc_B1_AF0F:
  lda $0497                    ; $AF0F
  bne Loc_B1_AF4E              ; $AF12
  lda JoyNew1                  ; $AF14
  and #$01                     ; $AF17
  beq Loc_B1_AF4E              ; $AF19
  lda $0490                    ; $AF1B
  cmp #$01                     ; $AF1E
  bne Loc_B1_AF4E              ; $AF20
  inc $0490                    ; $AF22
  lda ObjectCount              ; $AF25
  beq Loc_B1_AF4E              ; $AF28
  lda $0238                    ; $AF2A
  clc                          ; $AF2D
  adc #$02                     ; $AF2E
  sta $011A                    ; $AF30
  lda $023B                    ; $AF33
  clc                          ; $AF36
  adc #$02                     ; $AF37
  sta $011B                    ; $AF39
  jsr Sub_B1_AD82              ; $AF3C
  lda z:PaletteSetIndex        ; $AF3F
  cmp #$69                     ; $AF41
  bne Loc_B1_AF4B              ; $AF43
  jsr Sub_B1_AB27              ; $AF45
  jmp Loc_B1_AF6D              ; $AF48
Loc_B1_AF4B:
  jsr Sub_B1_AF6E              ; $AF4B
Loc_B1_AF4E:
  lda $04A8                    ; $AF4E
  bne Loc_B1_AF6D              ; $AF51
  lda ObjectTable              ; $AF53
  and #$1F                     ; $AF56
  cmp #$0C                     ; $AF58
  bne Loc_B1_AF6D              ; $AF5A
  lda $031E                    ; $AF5C
  cmp #$04                     ; $AF5F
  bne Loc_B1_AF6D              ; $AF61
  lda #$A7                     ; $AF63
  sta $04A8                    ; $AF65
  lda #$00                     ; $AF68
  sta $04A7                    ; $AF6A
Loc_B1_AF6D:
  rts                          ; $AF6D
Sub_B1_AF6E:
  lda ObjectCount              ; $AF6E
  beq Loc_B1_AFC5              ; $AF71
  sta z:Tmp02                  ; $AF73
  lda #$10                     ; $AF75
  sta z:Tmp00                  ; $AF77
  lda #$03                     ; $AF79
  sta z:Tmp01                  ; $AF7B
Loc_B1_AF7D:
  ldy #$04                     ; $AF7D
  lda (Tmp00),y                ; $AF7F
  and #$80                     ; $AF81
  beq Loc_B1_AFBA              ; $AF83
  ldy #$00                     ; $AF85
  lda (Tmp00),y                ; $AF87
  and #$1F                     ; $AF89
  cmp #$03                     ; $AF8B
  beq Loc_B1_AF9A              ; $AF8D
  ldy #$06                     ; $AF8F
  lda (Tmp00),y                ; $AF91
  sec                          ; $AF93
  sbc #$01                     ; $AF94
  sta (Tmp00),y                ; $AF96
  bne Loc_B1_AFBA              ; $AF98
Loc_B1_AF9A:
  ldy #$00                     ; $AF9A
  lda (Tmp00),y                ; $AF9C
  and #$1F                     ; $AF9E
  jsr Sub_B1_AE43              ; $AFA0
  lda (Tmp00),y                ; $AFA3
  and #$1F                     ; $AFA5
  sta $04A8                    ; $AFA7
  cmp #$09                     ; $AFAA
  bne Loc_B1_AFB1              ; $AFAC
  jsr Sub_B1_AFE3              ; $AFAE
Loc_B1_AFB1:
  jsr Sub_B1_AFC6              ; $AFB1
  jsr Sub_B1_B0EF              ; $AFB4
  jmp Loc_B1_AFC5              ; $AFB7
Loc_B1_AFBA:
  lda #$10                     ; $AFBA
  clc                          ; $AFBC
  adc z:Tmp00                  ; $AFBD
  sta z:Tmp00                  ; $AFBF
  dec z:Tmp02                  ; $AFC1
  bne Loc_B1_AF7D              ; $AFC3
Loc_B1_AFC5:
  rts                          ; $AFC5
Sub_B1_AFC6:
  ldy z:Tmp00                  ; $AFC6
  lda #$D0                     ; $AFC8
  sta $0300,y                  ; $AFCA
  lda #$02                     ; $AFCD
  sta $0304,y                  ; $AFCF
  lda #$00                     ; $AFD2
  sta $0305,y                  ; $AFD4
  sta $0307,y                  ; $AFD7
  sta $030E,y                  ; $AFDA
  lda #$04                     ; $AFDD
  sta $0308,y                  ; $AFDF
  rts                          ; $AFE2
Sub_B1_AFE3:
  ldy z:Tmp00                  ; $AFE3
  lda #$D0                     ; $AFE5
  sta ObjectTable,y            ; $AFE7
  lda #$02                     ; $AFEA
  sta $0314,y                  ; $AFEC
  lda #$00                     ; $AFEF
  sta $0315,y                  ; $AFF1
  sta $0317,y                  ; $AFF4
  sta $031E,y                  ; $AFF7
  lda #$18                     ; $AFFA
  sta $0318,y                  ; $AFFC
  lda $031A,y                  ; $AFFF
  clc                          ; $B002
  adc #$04                     ; $B003
  sta $031A,y                  ; $B005
  lda $0319,y                  ; $B008
  adc #$00                     ; $B00B
  and #$03                     ; $B00D
  sta $0319,y                  ; $B00F
  rts                          ; $B012
Sub_B1_B013:
  lda $0490                    ; $B013
  bne Loc_B1_B070              ; $B016
  lda z:PaletteSetIndex        ; $B018
  cmp #$69                     ; $B01A
  bne Loc_B1_B02A              ; $B01C
  lda $04AA                    ; $B01E
  and #$7F                     ; $B021
  cmp #$06                     ; $B023
  beq Loc_B1_B09B              ; $B025
  jmp Loc_B1_B030              ; $B027
Loc_B1_B02A:
  lda z:AmmoLo                 ; $B02A
  ora z:AmmoHi                 ; $B02C
  beq Loc_B1_B09B              ; $B02E
Loc_B1_B030:
  lda $0497                    ; $B030
  bne Loc_B1_B09B              ; $B033
  lda JoyNew1                  ; $B035
  and #$01                     ; $B038
  beq Loc_B1_B09B              ; $B03A
  lda z:PaletteSetIndex        ; $B03C
  sec                          ; $B03E
  sbc #$50                     ; $B03F
  tay                          ; $B041
  lda Data_B1_B11F,y           ; $B042
  jsr EnqueueByte              ; $B045
  lda z:AmmoLo                 ; $B048
  bne Loc_B1_B052              ; $B04A
  lda z:AmmoHi                 ; $B04C
  beq Loc_B1_B054              ; $B04E
  dec z:AmmoHi                 ; $B050
Loc_B1_B052:
  dec z:AmmoLo                 ; $B052
Loc_B1_B054:
  lda #$01                     ; $B054
  sta $0490                    ; $B056
  lda $0238                    ; $B059
  sta $0493                    ; $B05C
  lda $023B                    ; $B05F
  sta $0494                    ; $B062
  lda #$00                     ; $B065
  sta $0491                    ; $B067
  jsr Sub_B1_B09C              ; $B06A
  jmp Loc_B1_B09B              ; $B06D
Loc_B1_B070:
  dec $0492                    ; $B070
  bne Loc_B1_B09B              ; $B073
  inc $0491                    ; $B075
  lda $0491                    ; $B078
  cmp #$04                     ; $B07B
  bne Loc_B1_B098              ; $B07D
  lda #$00                     ; $B07F
  sta $0490                    ; $B081
  lda #$F0                     ; $B084
  sta $0250                    ; $B086
  sta $0254                    ; $B089
  sta $0258                    ; $B08C
  sta $025C                    ; $B08F
  sta $0260                    ; $B092
  jmp Loc_B1_B09B              ; $B095
Loc_B1_B098:
  jsr Sub_B1_B09C              ; $B098
Loc_B1_B09B:
  rts                          ; $B09B
Sub_B1_B09C:
  lda $0491                    ; $B09C
  asl a                        ; $B09F
  tax                          ; $B0A0
  lda Data_B1_B14A,x           ; $B0A1
  sta z:Tmp00                  ; $B0A4
  lda Data_B1_B14B,x           ; $B0A6
  sta z:Tmp01                  ; $B0A9
  ldy #$00                     ; $B0AB
  lda (Tmp00),y                ; $B0AD
  sta z:Tmp02                  ; $B0AF
  iny                          ; $B0B1
  lda (Tmp00),y                ; $B0B2
  sta $0492                    ; $B0B4
  iny                          ; $B0B7
  ldx #$50                     ; $B0B8
Loc_B1_B0BA:
  lda (Tmp00),y                ; $B0BA
  clc                          ; $B0BC
  adc $0493                    ; $B0BD
  sta OamBuffer,x              ; $B0C0
  inx                          ; $B0C3
  iny                          ; $B0C4
  lda (Tmp00),y                ; $B0C5
  sta OamBuffer,x              ; $B0C7
  inx                          ; $B0CA
  iny                          ; $B0CB
  lda (Tmp00),y                ; $B0CC
  sta OamBuffer,x              ; $B0CE
  inx                          ; $B0D1
  iny                          ; $B0D2
  lda (Tmp00),y                ; $B0D3
  clc                          ; $B0D5
  adc $0494                    ; $B0D6
  sta OamBuffer,x              ; $B0D9
  inx                          ; $B0DC
  iny                          ; $B0DD
  dec z:Tmp02                  ; $B0DE
  bne Loc_B1_B0BA              ; $B0E0
  lda $0491                    ; $B0E2
  cmp #$03                     ; $B0E5
  bne Loc_B1_B0EE              ; $B0E7
  lda #$F0                     ; $B0E9
  sta $0260                    ; $B0EB
Loc_B1_B0EE:
  rts                          ; $B0EE
Sub_B1_B0EF:
  lda $04A8                    ; $B0EF
  tax                          ; $B0F2
  lda Data_B1_B139,x           ; $B0F3
  cmp #$FF                     ; $B0F6
  bne Loc_B1_B102              ; $B0F8
Loc_B1_B0FA:
  lda #$00                     ; $B0FA
  sta $04A8                    ; $B0FC
  jmp Loc_B1_B11E              ; $B0FF
Loc_B1_B102:
  tax                          ; $B102
  lda $04A0,x                  ; $B103
  cmp #$FF                     ; $B106
  beq Loc_B1_B0FA              ; $B108
  dec $04A0,x                  ; $B10A
  beq Loc_B1_B118              ; $B10D
  txa                          ; $B10F
  ora #$10                     ; $B110
  sta $04A8                    ; $B112
  jmp Loc_B1_B11E              ; $B115
Loc_B1_B118:
  txa                          ; $B118
  ora #$20                     ; $B119
  sta $04A8                    ; $B11B
Loc_B1_B11E:
  rts                          ; $B11E
Data_B1_B11F:
  .incbin "prg_bank_1.bin", $311F, $1A  ; $B11F
Data_B1_B139:
  .incbin "prg_bank_1.bin", $3139, $11  ; $B139
Data_B1_B14A:
  .incbin "prg_bank_1.bin", $314A, $1  ; $B14A
Data_B1_B14B:
  .incbin "prg_bank_1.bin", $314B, $400  ; $B14B
  .incbin "prg_bank_1.bin", $354B, $400  ; $B54B
  .incbin "prg_bank_1.bin", $394B, $400  ; $B94B
  .incbin "prg_bank_1.bin", $3D4B, $2B2  ; $BD4B
Data_B1_BFFD:
  .incbin "prg_bank_1.bin", $3FFD, $3  ; $BFFD
