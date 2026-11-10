; Bank 0  ($8000-$BFFF switchable)
; Street-scene level data (maps, tile and object tables). No code of its own: the fixed bank selects it as data (MmcPrgShadow = 0 runs the fixed-bank main code instead of $8010).
.segment "PRG_BANK_0"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B0_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_0.bin", $0009, $7  ; $8009
  sta ($07,x)                  ; $8010
  brk                          ; $8012
  .incbin "prg_bank_0.bin", $0013, $1  ; $8013
  brk                          ; $8014
  .incbin "prg_bank_0.bin", $0015, $1  ; $8015
  sta ($07,x)                  ; $8016
  brk                          ; $8018
  .incbin "prg_bank_0.bin", $0019, $1  ; $8019
  brk                          ; $801A
  .incbin "prg_bank_0.bin", $001B, $3  ; $801B
  ora (FrameCounter,x)         ; $801E
  .incbin "prg_bank_0.bin", $0020, $4  ; $8020
  rol z:$16,x                  ; $8024
  .incbin "prg_bank_0.bin", $0026, $400  ; $8026
  .incbin "prg_bank_0.bin", $0426, $CB  ; $8426
  ora $1C1C,x                  ; $84F1
  .incbin "prg_bank_0.bin", $04F4, $3  ; $84F4
  jsr $2221                    ; $84F7
  .incbin "prg_bank_0.bin", $04FA, $1  ; $84FA
  bit z:$24                    ; $84FB
  and z:Tmp00                  ; $84FD
  rol z:$27                    ; $84FF
  .incbin "prg_bank_0.bin", $0501, $4  ; $8501
  plp                          ; $8505
  php                          ; $8506
  .incbin "prg_bank_0.bin", $0507, $1  ; $8507
  rol a                        ; $8508
  .incbin "prg_bank_0.bin", $0509, $2  ; $8509
  and $2E2D                    ; $850B
  .incbin "prg_bank_0.bin", $050E, $5  ; $850E
  bmi Loc_B0_8525              ; $8513
  and ($32),y                  ; $8515
  .incbin "prg_bank_0.bin", $0517, $E  ; $8517
Loc_B0_8525:
  bpl Loc_B0_8560              ; $8525
  and $3939,y                  ; $8527
  and $3B3A,y                  ; $852A
  .incbin "prg_bank_0.bin", $052D, $2B  ; $852D
  eor ($51),y                  ; $8558
  .incbin "prg_bank_0.bin", $055A, $1  ; $855A
  brk                          ; $855B
  brk                          ; $855C
  .incbin "prg_bank_0.bin", $055D, $3  ; $855D
Loc_B0_8560:
  .incbin "prg_bank_0.bin", $0560, $3  ; $8560
  lsr z:$57,x                  ; $8563
  cli                          ; $8565
  eor $5A5A,y                  ; $8566
  .incbin "prg_bank_0.bin", $0569, $3  ; $8569
  eor $5F5E,x                  ; $856C
  .incbin "prg_bank_0.bin", $056F, $2  ; $856F
  lsr $295F,x                  ; $8571
  rts                          ; $8574
  .incbin "prg_bank_0.bin", $0575, $6  ; $8575
  adc z:$65                    ; $857B
  .incbin "prg_bank_0.bin", $057D, $1  ; $857D
  adc z:$65                    ; $857E
  .incbin "prg_bank_0.bin", $0580, $1  ; $8580
  adc z:$65                    ; $8581
  adc z:MmcPrgShadow           ; $8583
  cli                          ; $8585
  .incbin "prg_bank_0.bin", $0586, $2  ; $8586
  pla                          ; $8588
  cli                          ; $8589
  rti                          ; $858A
  .incbin "prg_bank_0.bin", $058B, $2  ; $858B
  adc #$6A                     ; $858D
  ror a                        ; $858F
  .incbin "prg_bank_0.bin", $0590, $1  ; $8590
  rti                          ; $8591
  .incbin "prg_bank_0.bin", $0592, $1  ; $8592
  rti                          ; $8593
  .incbin "prg_bank_0.bin", $0594, $2  ; $8594
  asl a                        ; $8596
  asl a                        ; $8597
  asl a                        ; $8598
  asl a                        ; $8599
  asl a                        ; $859A
  asl a                        ; $859B
  asl a                        ; $859C
  clc                          ; $859D
  .incbin "prg_bank_0.bin", $059E, $1  ; $859E
  ora $1110,y                  ; $859F
  .incbin "prg_bank_0.bin", $05A2, $6  ; $85A2
  ror $706F                    ; $85A8
  adc ($72),y                  ; $85AB
  .incbin "prg_bank_0.bin", $05AD, $3  ; $85AD
  ror $7676                    ; $85B0
  .incbin "prg_bank_0.bin", $05B3, $3  ; $85B3
  adc $0879,y                  ; $85B6
  .incbin "prg_bank_0.bin", $05B9, $3  ; $85B9
  php                          ; $85BC
  .incbin "prg_bank_0.bin", $05BD, $135  ; $85BD
  bit z:$25                    ; $86F2
  .incbin "prg_bank_0.bin", $06F4, $3  ; $86F4
  plp                          ; $86F7
  .incbin "prg_bank_0.bin", $06F8, $1  ; $86F8
  rol a                        ; $86F9
  .incbin "prg_bank_0.bin", $06FA, $1  ; $86FA
  bit $2E2D                    ; $86FB
  .incbin "prg_bank_0.bin", $06FE, $400  ; $86FE
  .incbin "prg_bank_0.bin", $0AFE, $400  ; $8AFE
  .incbin "prg_bank_0.bin", $0EFE, $400  ; $8EFE
  .incbin "prg_bank_0.bin", $12FE, $400  ; $92FE
  .incbin "prg_bank_0.bin", $16FE, $400  ; $96FE
  .incbin "prg_bank_0.bin", $1AFE, $400  ; $9AFE
  .incbin "prg_bank_0.bin", $1EFE, $400  ; $9EFE
  .incbin "prg_bank_0.bin", $22FE, $400  ; $A2FE
  .incbin "prg_bank_0.bin", $26FE, $400  ; $A6FE
  .incbin "prg_bank_0.bin", $2AFE, $91  ; $AAFE
  lsr $4E4E                    ; $AB8F
  lsr Data_CD00                ; $AB92
  .incbin "prg_bank_0.bin", $2B95, $5E  ; $AB95
  eor a:Tmp00,x                ; $ABF3
  brk                          ; $ABF6
  .incbin "prg_bank_0.bin", $2BF7, $400  ; $ABF7
  .incbin "prg_bank_0.bin", $2FF7, $400  ; $AFF7
  .incbin "prg_bank_0.bin", $33F7, $400  ; $B3F7
  .incbin "prg_bank_0.bin", $37F7, $400  ; $B7F7
  .incbin "prg_bank_0.bin", $3BF7, $400  ; $BBF7
  .incbin "prg_bank_0.bin", $3FF7, $6  ; $BFF7
Data_B0_BFFD:
  .incbin "prg_bank_0.bin", $3FFD, $3  ; $BFFD
