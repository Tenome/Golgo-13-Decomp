; Bank 3  ($8000-$BFFF switchable)
; Dialogue and briefing scenes (portrait text boxes).
.segment "PRG_BANK_3"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B3_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_3.bin", $0009, $7  ; $8009
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
  jsr Sub_B3_92B7              ; $802C
Loc_B3_802F:
  jmp Loc_B3_8074              ; $802F
Loc_B3_8032:
  lda $0410                    ; $8032
  bne Loc_B3_803D              ; $8035
  jsr Sub_B3_91B1              ; $8037
  jmp Loc_B3_8074              ; $803A
Loc_B3_803D:
  cmp #$01                     ; $803D
  bne Loc_B3_8047              ; $803F
  jsr Sub_B3_91FF              ; $8041
  jmp Loc_B3_8071              ; $8044
Loc_B3_8047:
  cmp #$02                     ; $8047
  bne Loc_B3_8051              ; $8049
  jsr Sub_B3_9094              ; $804B
  jmp Loc_B3_8071              ; $804E
Loc_B3_8051:
  jsr DoOamDma                 ; $8051
  lda $0410                    ; $8054
  cmp #$03                     ; $8057
  bne Loc_B3_8061              ; $8059
  jsr Sub_B3_8EE9              ; $805B
  jmp Loc_B3_8071              ; $805E
Loc_B3_8061:
  cmp #$04                     ; $8061
  bne Loc_B3_8074              ; $8063
  jsr Sub_B3_87BA              ; $8065
  jsr ApplyScroll              ; $8068
  jsr ReadJoypads              ; $806B
  jsr Sub_B3_8866              ; $806E
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
  lda Data_B3_82C8,y           ; $8086
  sta z:Tmp00                  ; $8089
  iny                          ; $808B
  lda Data_B3_82C8,y           ; $808C
  sta z:Tmp01                  ; $808F
  jmp ($0000)                  ; $8091
  jsr Sub_B3_8261              ; $8094
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
  jmp Loc_B3_8260              ; $8103
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
  jsr Sub_B3_827C              ; $8161
  inc $0422                    ; $8164
  jmp Loc_B3_8260              ; $8167
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
  jmp Loc_B3_8260              ; $81A1
Loc_B3_81A4:
  lda #$00                     ; $81A4
  sta $041F                    ; $81A6
  lda PPU_STATUS               ; $81A9
  lda #$20                     ; $81AC
  sta PPU_ADDR                 ; $81AE
  lda $0425                    ; $81B1
  sta PPU_ADDR                 ; $81B4
  lda $0423                    ; $81B7
  sta PPU_DATA                 ; $81BA
  lda $0425                    ; $81BD
  and #$1F                     ; $81C0
  cmp #$1F                     ; $81C2
  bne Loc_B3_81D1              ; $81C4
  lda $0425                    ; $81C6
  and #$E0                     ; $81C9
  sta $0425                    ; $81CB
  jmp Loc_B3_81D4              ; $81CE
Loc_B3_81D1:
  inc $0425                    ; $81D1
Loc_B3_81D4:
  lda #$00                     ; $81D4
  sta $0427                    ; $81D6
  lda #$FF                     ; $81D9
  sta $0423                    ; $81DB
  jmp Loc_B3_8260              ; $81DE
  inc $041F                    ; $81E1
  lda $041F                    ; $81E4
  cmp #$0E                     ; $81E7
  bcs Loc_B3_81EE              ; $81E9
  jmp Loc_B3_8260              ; $81EB
Loc_B3_81EE:
  lda #$00                     ; $81EE
  sta $041F                    ; $81F0
  sta $0422                    ; $81F3
  inc $0421                    ; $81F6
  jmp Loc_B3_8260              ; $81F9
  lda #$00                     ; $81FC
  jmp Loc_B3_820D              ; $81FE
  lda #$20                     ; $8201
  jmp Loc_B3_820D              ; $8203
  lda #$40                     ; $8206
  jmp Loc_B3_820D              ; $8208
  lda #$60                     ; $820B
Loc_B3_820D:
  sta z:Tmp00                  ; $820D
  lda #$FF                     ; $820F
  sta z:$05                    ; $8211
  jsr Sub_B3_827C              ; $8213
  inc $0421                    ; $8216
  jmp Loc_B3_8260              ; $8219
  lda z:PpuCtrlShadow          ; $821C
  and #$FB                     ; $821E
  sta z:PpuCtrlShadow          ; $8220
  sta PPU_CTRL                 ; $8222
  lda $042E                    ; $8225
  sta z:Tmp00                  ; $8228
  lda #$04                     ; $822A
  sta z:Tmp01                  ; $822C
Loc_B3_822E:
  lda PPU_STATUS               ; $822E
  lda #$23                     ; $8231
  sta PPU_ADDR                 ; $8233
  lda #$C8                     ; $8236
  clc                          ; $8238
  adc z:Tmp00                  ; $8239
  sta PPU_ADDR                 ; $823B
Loc_B3_823E:
  ldy z:Tmp00                  ; $823E
  lda $0480,y                  ; $8240
  sta PPU_DATA                 ; $8243
  dec z:Tmp01                  ; $8246
  beq Loc_B3_8257              ; $8248
  inc z:Tmp00                  ; $824A
  lda #$07                     ; $824C
  and z:Tmp00                  ; $824E
  sta z:Tmp00                  ; $8250
  beq Loc_B3_822E              ; $8252
  jmp Loc_B3_823E              ; $8254
Loc_B3_8257:
  inc $0421                    ; $8257
  jmp Loc_B3_8260              ; $825A
  jsr Sub_B3_9362              ; $825D
Loc_B3_8260:
  rts                          ; $8260
Sub_B3_8261:
  lda z:ScrollX                ; $8261
  and #$E0                     ; $8263
  lsr a                        ; $8265
  lsr a                        ; $8266
  lsr a                        ; $8267
  clc                          ; $8268
  adc #$88                     ; $8269
  and #$DF                     ; $826B
  clc                          ; $826D
  sta $042D                    ; $826E
  sta $0425                    ; $8271
  and #$1F                     ; $8274
  lsr a                        ; $8276
  lsr a                        ; $8277
  sta $042E                    ; $8278
  rts                          ; $827B
Sub_B3_827C:
  lda z:PpuCtrlShadow          ; $827C
  and #$FB                     ; $827E
  sta z:PpuCtrlShadow          ; $8280
  sta PPU_CTRL                 ; $8282
  lda z:Tmp00                  ; $8285
  clc                          ; $8287
  adc $042D                    ; $8288
  sta z:Tmp01                  ; $828B
  and #$1F                     ; $828D
  sta z:Tmp02                  ; $828F
  lda #$10                     ; $8291
  sta z:Tmp03                  ; $8293
  lda #$20                     ; $8295
  sta PPU_ADDR                 ; $8297
  lda z:Tmp01                  ; $829A
  sta PPU_ADDR                 ; $829C
Loc_B3_829F:
  lda z:$05                    ; $829F
  bmi Loc_B3_82A9              ; $82A1
  lda Data_B3_82DE,y           ; $82A3
  jmp Loc_B3_82AB              ; $82A6
Loc_B3_82A9:
  lda #$FF                     ; $82A9
Loc_B3_82AB:
  sta PPU_DATA                 ; $82AB
  iny                          ; $82AE
  inc z:Tmp02                  ; $82AF
  lda z:Tmp02                  ; $82B1
  cmp #$20                     ; $82B3
  bne Loc_B3_82C3              ; $82B5
  lda #$20                     ; $82B7
  sta PPU_ADDR                 ; $82B9
  lda #$E0                     ; $82BC
  and z:Tmp01                  ; $82BE
  sta PPU_ADDR                 ; $82C0
Loc_B3_82C3:
  dec z:Tmp03                  ; $82C3
  bne Loc_B3_829F              ; $82C5
  rts                          ; $82C7
Data_B3_82C8:
  .incbin "prg_bank_3.bin", $02C8, $16  ; $82C8
Data_B3_82DE:
  .incbin "prg_bank_3.bin", $02DE, $400  ; $82DE
  .incbin "prg_bank_3.bin", $06DE, $DC  ; $86DE
Sub_B3_87BA:
  lda $0412                    ; $87BA
  bne Loc_B3_87CA              ; $87BD
  lda $041C                    ; $87BF
  beq Loc_B3_87C7              ; $87C2
  jsr Bank3Dispatch_041C       ; $87C4
Loc_B3_87C7:
  jmp Loc_B3_87FE              ; $87C7
Loc_B3_87CA:
  lda #$CB                     ; $87CA
  sta z:Tmp00                  ; $87CC
  lda #$28                     ; $87CE
  sta z:Tmp01                  ; $87D0
  lda z:$72                    ; $87D2
  clc                          ; $87D4
  adc z:Tmp00                  ; $87D5
  sta z:Tmp00                  ; $87D7
  lda #$00                     ; $87D9
  adc z:Tmp01                  ; $87DB
  sta z:Tmp01                  ; $87DD
  lda PPU_STATUS               ; $87DF
  lda z:Tmp01                  ; $87E2
  sta PPU_ADDR                 ; $87E4
  lda z:Tmp00                  ; $87E7
  sta PPU_ADDR                 ; $87E9
  lda $0419                    ; $87EC
  sta PPU_DATA                 ; $87EF
  lda #$00                     ; $87F2
  sta $0412                    ; $87F4
  lda #$FF                     ; $87F7
  sta $0419                    ; $87F9
  inc z:$72                    ; $87FC
Loc_B3_87FE:
  rts                          ; $87FE
Bank3Dispatch_041C:
  dec $041C                    ; $87FF
  lda $041C                    ; $8802
  asl a                        ; $8805
  asl a                        ; $8806
  asl a                        ; $8807
  sta z:Tmp00                  ; $8808
  inc $041C                    ; $880A
  lda #$1D                     ; $880D
  clc                          ; $880F
  adc z:Tmp00                  ; $8810
  sta z:Tmp00                  ; $8812
  lda #$00                     ; $8814
  adc #$88                     ; $8816
  sta z:Tmp01                  ; $8818
  jmp ($0000)                  ; $881A
  jsr ProcessPpuUpdateList     ; $881D
  .incbin "prg_bank_3.bin", $0820, $2  ; $8820
  jmp Loc_B3_8832              ; $8822
  jsr ProcessPpuUpdateList     ; $8825
  .incbin "prg_bank_3.bin", $0828, $2  ; $8828
  jmp Loc_B3_8832              ; $882A
  jsr ProcessPpuUpdateList     ; $882D
  .incbin "prg_bank_3.bin", $0830, $2  ; $8830
Loc_B3_8832:
  ldy #$2D                     ; $8832
  lda #$FF                     ; $8834
  sta ($5C),y                  ; $8836
  inc $041C                    ; $8838
  lda $041C                    ; $883B
  cmp #$04                     ; $883E
  bne Loc_B3_884A              ; $8840
  lda #$00                     ; $8842
  sta $041C                    ; $8844
  sta $0418                    ; $8847
Loc_B3_884A:
  rts                          ; $884A
  .incbin "prg_bank_3.bin", $084B, $1B  ; $884B
Sub_B3_8866:
  lda $0411                    ; $8866
  beq Loc_B3_88B5              ; $8869
  lda $041C                    ; $886B
  beq Loc_B3_8873              ; $886E
  jmp Loc_B3_8A3A              ; $8870
Loc_B3_8873:
  jsr Sub_B3_8BB9              ; $8873
  lda $0411                    ; $8876
  cmp #$02                     ; $8879
  beq Loc_B3_88D4              ; $887B
  lda $0418                    ; $887D
  bne Loc_B3_8885              ; $8880
  jmp Loc_B3_88F9              ; $8882
Loc_B3_8885:
  and #$0F                     ; $8885
  cmp #$03                     ; $8887
  bcs Loc_B3_88A6              ; $8889
  sta z:Tmp00                  ; $888B
  lda JoyHeld1                 ; $888D
  and #$02                     ; $8890
  beq Loc_B3_88A4              ; $8892
  ldx $0400                    ; $8894
  lda Data_B3_8CCD,x           ; $8897
  and #$3F                     ; $889A
  bne Loc_B3_88A4              ; $889C
  jsr Sub_B3_8CA1              ; $889E
  jmp Loc_B3_8A3A              ; $88A1
Loc_B3_88A4:
  lda z:Tmp00                  ; $88A4
Loc_B3_88A6:
  asl a                        ; $88A6
  tay                          ; $88A7
  lda Data_B3_8CFE,y           ; $88A8
  sta z:Tmp00                  ; $88AB
  lda Data_B3_8CFF,y           ; $88AD
  sta z:Tmp01                  ; $88B0
  jmp ($0000)                  ; $88B2
Loc_B3_88B5:
  lda $0400                    ; $88B5
  asl a                        ; $88B8
  tay                          ; $88B9
  lda Data_B3_95C4,y           ; $88BA
  sta z:$6C                    ; $88BD
  sta z:$6A                    ; $88BF
  lda Data_B3_95C5,y           ; $88C1
  sta z:$6D                    ; $88C4
  sta z:$6B                    ; $88C6
  lda #$FF                     ; $88C8
  sta z:$70                    ; $88CA
  sta z:$71                    ; $88CC
  jsr Sub_B3_8A3B              ; $88CE
  jsr Sub_B3_8B1A              ; $88D1
Loc_B3_88D4:
  ldy #$00                     ; $88D4
  lda ($6C),y                  ; $88D6
  sta z:$6E                    ; $88D8
  iny                          ; $88DA
  lda ($6C),y                  ; $88DB
  sta z:$6F                    ; $88DD
  jsr Sub_B3_8A69              ; $88DF
  lda #$00                     ; $88E2
  sta z:$72                    ; $88E4
  sta $0418                    ; $88E6
  sta $041C                    ; $88E9
  sta $041E                    ; $88EC
  lda #$01                     ; $88EF
  sta $0411                    ; $88F1
  lda #$FF                     ; $88F4
  sta $0419                    ; $88F6
Loc_B3_88F9:
  lda $041D                    ; $88F9
  cmp #$02                     ; $88FC
  bcs Loc_B3_8906              ; $88FE
  inc $041D                    ; $8900
  jmp Loc_B3_8A3A              ; $8903
Loc_B3_8906:
  lda #$00                     ; $8906
  sta $041D                    ; $8908
Loc_B3_890B:
  ldy $041B                    ; $890B
  lda ($6E),y                  ; $890E
  bpl Loc_B3_8920              ; $8910
  sta $0419                    ; $8912
  lda #$01                     ; $8915
  sta $0412                    ; $8917
  inc $041B                    ; $891A
  jmp Loc_B3_8A3A              ; $891D
Loc_B3_8920:
  sta z:Tmp00                  ; $8920
  and #$40                     ; $8922
  bne Loc_B3_893D              ; $8924
  lda z:Tmp00                  ; $8926
  cmp #$2E                     ; $8928
  beq Loc_B3_8932              ; $892A
  cmp #$2F                     ; $892C
  beq Loc_B3_8932              ; $892E
  ora #$40                     ; $8930
Loc_B3_8932:
  ora #$80                     ; $8932
  sta $0419                    ; $8934
  inc $041B                    ; $8937
  jmp Loc_B3_890B              ; $893A
Loc_B3_893D:
  lda z:Tmp00                  ; $893D
  cmp #$40                     ; $893F
  beq Loc_B3_8952              ; $8941
  cmp #$41                     ; $8943
  beq Loc_B3_8961              ; $8945
  cmp #$42                     ; $8947
  beq Loc_B3_8985              ; $8949
  cmp #$43                     ; $894B
  beq Loc_B3_8998              ; $894D
  jmp Loc_B3_8D0C              ; $894F
Loc_B3_8952:
  inc $041B                    ; $8952
  lda z:$72                    ; $8955
  and #$F0                     ; $8957
  clc                          ; $8959
  adc #$20                     ; $895A
  sta z:$72                    ; $895C
  jmp Loc_B3_890B              ; $895E
Loc_B3_8961:
  jsr Sub_B3_8A54              ; $8961
  lda #$01                     ; $8964
  sta $0418                    ; $8966
  lda JoyHeld1                 ; $8969
  and #$01                     ; $896C
  bne Loc_B3_8976              ; $896E
  jsr Sub_B3_8B77              ; $8970
  jmp Loc_B3_8A3A              ; $8973
Loc_B3_8976:
  inc $041B                    ; $8976
  lda #$01                     ; $8979
  sta $041C                    ; $897B
  lda #$00                     ; $897E
  sta z:$72                    ; $8980
  jmp Loc_B3_8A3A              ; $8982
Loc_B3_8985:
  inc $041B                    ; $8985
  ldy $041B                    ; $8988
  lda ($6E),y                  ; $898B
  ldy #$01                     ; $898D
  sta ($5C),y                  ; $898F
  clc                          ; $8991
  adc #$02                     ; $8992
  ldy #$05                     ; $8994
  sta ($5C),y                  ; $8996
Loc_B3_8998:
  lda #$05                     ; $8998
  clc                          ; $899A
  adc z:$6C                    ; $899B
  sta z:$6C                    ; $899D
  lda #$00                     ; $899F
  adc z:$6D                    ; $89A1
  sta z:$6D                    ; $89A3
  ldy #$00                     ; $89A5
  lda ($6C),y                  ; $89A7
  sta z:$6E                    ; $89A9
  iny                          ; $89AB
  lda ($6C),y                  ; $89AC
  sta z:$6F                    ; $89AE
  cmp #$FF                     ; $89B0
  bne Loc_B3_8A19              ; $89B2
  lda z:$6E                    ; $89B4
  cmp #$FF                     ; $89B6
  bne Loc_B3_8A19              ; $89B8
  ldx $0400                    ; $89BA
  lda Data_B3_8CCD,x           ; $89BD
  bpl Loc_B3_89D9              ; $89C0
  and #$40                     ; $89C2
  bne Loc_B3_89CC              ; $89C4
  jsr Sub_B3_8CA1              ; $89C6
  jmp Loc_B3_8A3A              ; $89C9
Loc_B3_89CC:
  lda #$04                     ; $89CC
  sta $0418                    ; $89CE
  lda #$00                     ; $89D1
  sta $041D                    ; $89D3
  jmp Loc_B3_8A3A              ; $89D6
Loc_B3_89D9:
  lda #$03                     ; $89D9
  sta $0418                    ; $89DB
  lda JoyNew1                  ; $89DE
  and #$03                     ; $89E1
  bne Loc_B3_89EB              ; $89E3
  jsr Sub_B3_8B77              ; $89E5
  jmp Loc_B3_8A3A              ; $89E8
Loc_B3_89EB:
  cmp #$01                     ; $89EB
  beq Loc_B3_89F5              ; $89ED
  jsr Sub_B3_8CA1              ; $89EF
  jmp Loc_B3_8A3A              ; $89F2
Loc_B3_89F5:
  inc $040C                    ; $89F5
  lda $040C                    ; $89F8
  cmp #$04                     ; $89FB
  bcc Loc_B3_8A3A              ; $89FD
  lda #$00                     ; $89FF
  sta $040C                    ; $8A01
  lda z:$6A                    ; $8A04
  sta z:$6C                    ; $8A06
  lda z:$6B                    ; $8A08
  sta z:$6D                    ; $8A0A
  lda #$01                     ; $8A0C
  sta $041C                    ; $8A0E
  lda #$02                     ; $8A11
  sta $0411                    ; $8A13
  jmp Loc_B3_8A3A              ; $8A16
Loc_B3_8A19:
  lda #$02                     ; $8A19
  sta $0418                    ; $8A1B
  jsr Sub_B3_8A54              ; $8A1E
  lda JoyHeld1                 ; $8A21
  and #$01                     ; $8A24
  bne Loc_B3_8A2E              ; $8A26
  jsr Sub_B3_8B77              ; $8A28
  jmp Loc_B3_8A3A              ; $8A2B
Loc_B3_8A2E:
  lda #$00                     ; $8A2E
  sta z:$72                    ; $8A30
  lda #$01                     ; $8A32
  sta $041C                    ; $8A34
  jsr Sub_B3_8A69              ; $8A37
Loc_B3_8A3A:
  rts                          ; $8A3A
Sub_B3_8A3B:
  ldy #$2C                     ; $8A3B
  lda #$5E                     ; $8A3D
  sta ($5C),y                  ; $8A3F
  iny                          ; $8A41
  lda #$FF                     ; $8A42
  sta ($5C),y                  ; $8A44
  iny                          ; $8A46
  lda #$00                     ; $8A47
  sta ($5C),y                  ; $8A49
  iny                          ; $8A4B
  lda #$C0                     ; $8A4C
  sec                          ; $8A4E
  sbc z:HwScrollX              ; $8A4F
  sta ($5C),y                  ; $8A51
  rts                          ; $8A53
Sub_B3_8A54:
  ldy #$2D                     ; $8A54
  lda #$FF                     ; $8A56
  sta ($5C),y                  ; $8A58
  ldy #$2F                     ; $8A5A
  lda #$C0                     ; $8A5C
  sec                          ; $8A5E
  sbc z:HwScrollX              ; $8A5F
  sta ($5C),y                  ; $8A61
  lda #$00                     ; $8A63
  sta $041E                    ; $8A65
  rts                          ; $8A68
Sub_B3_8A69:
  ldy #$02                     ; $8A69
  lda ($6C),y                  ; $8A6B
  sta z:Tmp00                  ; $8A6D
  iny                          ; $8A6F
  lda ($6C),y                  ; $8A70
  sta z:Tmp01                  ; $8A72
  ldy #$0C                     ; $8A74
Loc_B3_8A76:
  iny                          ; $8A76
  lda z:Tmp00                  ; $8A77
  sta ($5C),y                  ; $8A79
  iny                          ; $8A7B
  lda z:Tmp01                  ; $8A7C
  sta ($5C),y                  ; $8A7E
  iny                          ; $8A80
  iny                          ; $8A81
  inc z:Tmp00                  ; $8A82
  inc z:Tmp00                  ; $8A84
  cpy #$2C                     ; $8A86
  bcc Loc_B3_8A76              ; $8A88
  ldy #$04                     ; $8A8A
  lda ($6C),y                  ; $8A8C
  asl a                        ; $8A8E
  asl a                        ; $8A8F
  sta z:Tmp00                  ; $8A90
  asl a                        ; $8A92
  clc                          ; $8A93
  adc z:Tmp00                  ; $8A94
  sta z:Tmp00                  ; $8A96
  lda #$2A                     ; $8A98
  clc                          ; $8A9A
  adc z:Tmp00                  ; $8A9B
  sta z:Tmp00                  ; $8A9D
  lda #$9A                     ; $8A9F
  adc #$00                     ; $8AA1
  sta z:Tmp01                  ; $8AA3
  lda z:Tmp00                  ; $8AA5
  cmp z:$70                    ; $8AA7
  bne Loc_B3_8AB1              ; $8AA9
  lda z:Tmp01                  ; $8AAB
  cmp z:$71                    ; $8AAD
  beq Loc_B3_8AEE              ; $8AAF
Loc_B3_8AB1:
  lda z:Tmp00                  ; $8AB1
  sta z:$70                    ; $8AB3
  lda z:Tmp01                  ; $8AB5
  sta z:$71                    ; $8AB7
  ldy #$00                     ; $8AB9
  jsr Sub_B3_8AF4              ; $8ABB
  ldy #$01                     ; $8ABE
  jsr Sub_B3_8B08              ; $8AC0
  lda z:Tmp03                  ; $8AC3
  sta z:Tmp02                  ; $8AC5
  lda z:Tmp00                  ; $8AC7
  cmp #$FF                     ; $8AC9
  beq Loc_B3_8AD1              ; $8ACB
  inc z:Tmp00                  ; $8ACD
  inc z:Tmp00                  ; $8ACF
Loc_B3_8AD1:
  ldy #$05                     ; $8AD1
  jsr Sub_B3_8B08              ; $8AD3
  ldy #$04                     ; $8AD6
  jsr Sub_B3_8AF4              ; $8AD8
  ldy #$09                     ; $8ADB
  jsr Sub_B3_8B08              ; $8ADD
  lda #$00                     ; $8AE0
  sta $0408                    ; $8AE2
  sta $0409                    ; $8AE5
  sta $040A                    ; $8AE8
  sta $040B                    ; $8AEB
Loc_B3_8AEE:
  lda #$00                     ; $8AEE
  sta $041B                    ; $8AF0
  rts                          ; $8AF3
Sub_B3_8AF4:
  lda ($70),y                  ; $8AF4
  sta z:Tmp00                  ; $8AF6
  iny                          ; $8AF8
  lda ($70),y                  ; $8AF9
  sta z:Tmp01                  ; $8AFB
  iny                          ; $8AFD
  lda ($70),y                  ; $8AFE
  sta z:Tmp02                  ; $8B00
  iny                          ; $8B02
  lda ($70),y                  ; $8B03
  sta z:Tmp03                  ; $8B05
  rts                          ; $8B07
Sub_B3_8B08:
  lda z:Tmp00                  ; $8B08
  sta ($5C),y                  ; $8B0A
  iny                          ; $8B0C
  lda z:Tmp01                  ; $8B0D
  sta ($5C),y                  ; $8B0F
  iny                          ; $8B11
  lda z:Tmp02                  ; $8B12
  sec                          ; $8B14
  sbc z:HwScrollX              ; $8B15
  sta ($5C),y                  ; $8B17
  rts                          ; $8B19
Sub_B3_8B1A:
  lda #$38                     ; $8B1A
  sta z:Tmp00                  ; $8B1C
  lda #$30                     ; $8B1E
  sta z:Tmp02                  ; $8B20
  lda z:Tmp02                  ; $8B22
  sec                          ; $8B24
  sbc z:HwScrollX              ; $8B25
  sta z:Tmp02                  ; $8B27
  lda #$08                     ; $8B29
  sta z:Tmp03                  ; $8B2B
  ldy #$0C                     ; $8B2D
Loc_B3_8B2F:
  lda z:Tmp00                  ; $8B2F
  sta ($5C),y                  ; $8B31
  iny                          ; $8B33
  lda #$FF                     ; $8B34
  sta ($5C),y                  ; $8B36
  iny                          ; $8B38
  iny                          ; $8B39
  lda z:Tmp02                  ; $8B3A
  sta ($5C),y                  ; $8B3C
  iny                          ; $8B3E
  lda #$08                     ; $8B3F
  clc                          ; $8B41
  adc z:Tmp02                  ; $8B42
  sta z:Tmp02                  ; $8B44
  inc z:Tmp01                  ; $8B46
  inc z:Tmp01                  ; $8B48
  dec z:Tmp03                  ; $8B4A
  beq Loc_B3_8B65              ; $8B4C
  lda z:Tmp03                  ; $8B4E
  cmp #$04                     ; $8B50
  bne Loc_B3_8B2F              ; $8B52
  lda #$10                     ; $8B54
  clc                          ; $8B56
  adc z:Tmp00                  ; $8B57
  sta z:Tmp00                  ; $8B59
  lda #$E0                     ; $8B5B
  clc                          ; $8B5D
  adc z:Tmp02                  ; $8B5E
  sta z:Tmp02                  ; $8B60
  jmp Loc_B3_8B2F              ; $8B62
Loc_B3_8B65:
  ldy #$08                     ; $8B65
  lda z:Tmp00                  ; $8B67
  sta ($5C),y                  ; $8B69
  sec                          ; $8B6B
  sbc #$10                     ; $8B6C
  ldy #$00                     ; $8B6E
  sta ($5C),y                  ; $8B70
  ldy #$04                     ; $8B72
  sta ($5C),y                  ; $8B74
  rts                          ; $8B76
Sub_B3_8B77:
  lda $041E                    ; $8B77
  cmp #$14                     ; $8B7A
  bcs Loc_B3_8B84              ; $8B7C
  inc $041E                    ; $8B7E
  jmp Loc_B3_8BB8              ; $8B81
Loc_B3_8B84:
  lda #$00                     ; $8B84
  sta $041E                    ; $8B86
  ldy #$2D                     ; $8B89
  lda ($5C),y                  ; $8B8B
  cmp #$FF                     ; $8B8D
  beq Loc_B3_8B98              ; $8B8F
  lda #$FF                     ; $8B91
  sta ($5C),y                  ; $8B93
  jmp Loc_B3_8BB8              ; $8B95
Loc_B3_8B98:
  lda $0418                    ; $8B98
  and #$0F                     ; $8B9B
  cmp #$03                     ; $8B9D
  bcc Loc_B3_8BA9              ; $8B9F
  lda #$A8                     ; $8BA1
  pha                          ; $8BA3
  lda #$5E                     ; $8BA4
  jmp Loc_B3_8BAE              ; $8BA6
Loc_B3_8BA9:
  lda #$C0                     ; $8BA9
  pha                          ; $8BAB
  lda #$FD                     ; $8BAC
Loc_B3_8BAE:
  sta ($5C),y                  ; $8BAE
  pla                          ; $8BB0
  sec                          ; $8BB1
  sbc z:HwScrollX              ; $8BB2
  ldy #$2F                     ; $8BB4
  sta ($5C),y                  ; $8BB6
Loc_B3_8BB8:
  rts                          ; $8BB8
Sub_B3_8BB9:
  lda z:FrameCounter           ; $8BB9
  and #$01                     ; $8BBB
  beq Loc_B3_8BC2              ; $8BBD
  jmp Loc_B3_8C7D              ; $8BBF
Loc_B3_8BC2:
  lda $0418                    ; $8BC2
  and #$0F                     ; $8BC5
  cmp #$05                     ; $8BC7
  bcc Loc_B3_8BCE              ; $8BC9
  jmp Loc_B3_8C7D              ; $8BCB
Loc_B3_8BCE:
  ldy #$00                     ; $8BCE
  lda ($70),y                  ; $8BD0
  cmp #$FF                     ; $8BD2
  beq Loc_B3_8C2C              ; $8BD4
  inc $0408                    ; $8BD6
  lda #$07                     ; $8BD9
  clc                          ; $8BDB
  adc $0409                    ; $8BDC
  tay                          ; $8BDF
  lda ($70),y                  ; $8BE0
  cmp #$FF                     ; $8BE2
  beq Loc_B3_8BEB              ; $8BE4
  cmp $0408                    ; $8BE6
  beq Loc_B3_8BEE              ; $8BE9
Loc_B3_8BEB:
  jmp Loc_B3_8C2C              ; $8BEB
Loc_B3_8BEE:
  lda #$00                     ; $8BEE
  sta $0408                    ; $8BF0
  inc $0409                    ; $8BF3
  lda $0409                    ; $8BF6
  cmp #$03                     ; $8BF9
  bne Loc_B3_8C02              ; $8BFB
  lda #$00                     ; $8BFD
  sta $0409                    ; $8BFF
Loc_B3_8C02:
  clc                          ; $8C02
  adc #$07                     ; $8C03
  tay                          ; $8C05
  lda ($70),y                  ; $8C06
  beq Loc_B3_8BEE              ; $8C08
  cmp #$FF                     ; $8C0A
  beq Loc_B3_8C2C              ; $8C0C
  lda $0409                    ; $8C0E
  asl a                        ; $8C11
  asl a                        ; $8C12
  sta z:Tmp00                  ; $8C13
  ldy #$00                     ; $8C15
  lda ($70),y                  ; $8C17
  clc                          ; $8C19
  adc z:Tmp00                  ; $8C1A
  sta z:Tmp00                  ; $8C1C
  ldy #$01                     ; $8C1E
  sta ($5C),y                  ; $8C20
  inc z:Tmp00                  ; $8C22
  inc z:Tmp00                  ; $8C24
  lda z:Tmp00                  ; $8C26
  ldy #$05                     ; $8C28
  sta ($5C),y                  ; $8C2A
Loc_B3_8C2C:
  ldy #$04                     ; $8C2C
  lda ($70),y                  ; $8C2E
  cmp #$FF                     ; $8C30
  beq Loc_B3_8C7D              ; $8C32
  lda $0418                    ; $8C34
  beq Loc_B3_8C40              ; $8C37
  lda $040B                    ; $8C39
  cmp #$00                     ; $8C3C
  beq Loc_B3_8C7D              ; $8C3E
Loc_B3_8C40:
  inc $040A                    ; $8C40
  lda #$0A                     ; $8C43
  clc                          ; $8C45
  adc $040B                    ; $8C46
  tay                          ; $8C49
  lda ($70),y                  ; $8C4A
  cmp $040A                    ; $8C4C
  beq Loc_B3_8C54              ; $8C4F
  jmp Loc_B3_8C7D              ; $8C51
Loc_B3_8C54:
  lda #$00                     ; $8C54
  sta $040A                    ; $8C56
  inc $040B                    ; $8C59
  lda $040B                    ; $8C5C
  and #$01                     ; $8C5F
  sta $040B                    ; $8C61
  clc                          ; $8C64
  adc #$0A                     ; $8C65
  tay                          ; $8C67
  lda ($70),y                  ; $8C68
  beq Loc_B3_8C54              ; $8C6A
  lda $040B                    ; $8C6C
  asl a                        ; $8C6F
  sta z:Tmp00                  ; $8C70
  ldy #$04                     ; $8C72
  lda ($70),y                  ; $8C74
  clc                          ; $8C76
  adc z:Tmp00                  ; $8C77
  ldy #$09                     ; $8C79
  sta ($5C),y                  ; $8C7B
Loc_B3_8C7D:
  rts                          ; $8C7D
  inc $041D                    ; $8C7E  [heuristic code]
  lda $041D                    ; $8C81
  cmp #$B4                     ; $8C84
  bcs Loc_B3_8C96              ; $8C86
  lda JoyHeld1                 ; $8C88
  and #$02                     ; $8C8B
  bne Loc_B3_8C92              ; $8C8D
  jmp Loc_B3_8A3A              ; $8C8F
Loc_B3_8C92:
  lda #$08                     ; $8C92
  sta z:$30                    ; $8C94
Loc_B3_8C96:
  lda #$00                     ; $8C96
  sta $041D                    ; $8C98
  jsr Sub_B3_8CA1              ; $8C9B
  jmp Loc_B3_8A3A              ; $8C9E
Sub_B3_8CA1:
  ldy #$00                     ; $8CA1
  lda #$F0                     ; $8CA3
Loc_B3_8CA5:
  sta ($5C),y                  ; $8CA5
  iny                          ; $8CA7
  cpy #$30                     ; $8CA8
  bcc Loc_B3_8CA5              ; $8CAA
  lda z:PpuCtrlShadow          ; $8CAC
  and #$FD                     ; $8CAE
  sta z:PpuCtrlShadow          ; $8CB0
  sta PPU_CTRL                 ; $8CB2
  lda $0414                    ; $8CB5
  sta z:HwScrollX              ; $8CB8
  jsr ApplyScroll              ; $8CBA
  lda #$00                     ; $8CBD
  sta JoyNew1                  ; $8CBF
  lda #$00                     ; $8CC2
  sta $0402                    ; $8CC4
  lda $0403                    ; $8CC7
  sta z:MmcPrgShadow           ; $8CCA
  rts                          ; $8CCC
Data_B3_8CCD:
  .incbin "prg_bank_3.bin", $0CCD, $31  ; $8CCD
Data_B3_8CFE:
  .incbin "prg_bank_3.bin", $0CFE, $1  ; $8CFE
Data_B3_8CFF:
  .incbin "prg_bank_3.bin", $0CFF, $D  ; $8CFF
Loc_B3_8D0C:
  ldy $041B                    ; $8D0C
  iny                          ; $8D0F
  lda ($6E),y                  ; $8D10
  sta z:$56                    ; $8D12
  iny                          ; $8D14
  lda ($6E),y                  ; $8D15
  sta z:$58                    ; $8D17
  lda z:Tmp00                  ; $8D19
  cmp #$48                     ; $8D1B
  bne Loc_B3_8D24              ; $8D1D
  lda #$05                     ; $8D1F
  jmp Loc_B3_8D26              ; $8D21
Loc_B3_8D24:
  lda #$05                     ; $8D24
Loc_B3_8D26:
  sta $0418                    ; $8D26
  ldy #$2D                     ; $8D29
  lda #$FF                     ; $8D2B
  sta ($5C),y                  ; $8D2D
  lda #$00                     ; $8D2F
  sta $0409                    ; $8D31
  sta $040B                    ; $8D34
  lda z:$56                    ; $8D37
  asl a                        ; $8D39
  tay                          ; $8D3A
  lda Data_B3_8EBD,y           ; $8D3B
  sta z:$56                    ; $8D3E
  lda Data_B3_8EBE,y           ; $8D40
  sta z:$57                    ; $8D43
  lda z:$58                    ; $8D45
  asl a                        ; $8D47
  tay                          ; $8D48
  lda Data_B3_8EC1,y           ; $8D49
  sta z:$58                    ; $8D4C
  lda Data_B3_8EC2,y           ; $8D4E
  sta z:$59                    ; $8D51
  jsr Sub_B3_8E90              ; $8D53
  jsr Sub_B3_8EAB              ; $8D56
  jmp Loc_B3_8A3A              ; $8D59
  lda $0418                    ; $8D5C  [heuristic code]
  and #$10                     ; $8D5F
  bne Loc_B3_8D8B              ; $8D61
  inc $0408                    ; $8D63
  lda $0409                    ; $8D66
  asl a                        ; $8D69
  tay                          ; $8D6A
  lda ($56),y                  ; $8D6B
  cmp $0408                    ; $8D6D
  bcs Loc_B3_8D8B              ; $8D70
  inc $0409                    ; $8D72
  iny                          ; $8D75
  iny                          ; $8D76
  lda ($56),y                  ; $8D77
  cmp #$FF                     ; $8D79
  bne Loc_B3_8D88              ; $8D7B
  lda #$10                     ; $8D7D
  ora $0418                    ; $8D7F
  sta $0418                    ; $8D82
  jmp Loc_B3_8DBD              ; $8D85
Loc_B3_8D88:
  jsr Sub_B3_8E90              ; $8D88
Loc_B3_8D8B:
  lda $0418                    ; $8D8B
  and #$20                     ; $8D8E
  bne Loc_B3_8DF0              ; $8D90
  inc $040A                    ; $8D92
  lda $040B                    ; $8D95
  asl a                        ; $8D98
  tay                          ; $8D99
  lda ($58),y                  ; $8D9A
  cmp $040A                    ; $8D9C
  bcs Loc_B3_8DF0              ; $8D9F
  inc $040B                    ; $8DA1
  iny                          ; $8DA4
  iny                          ; $8DA5
  lda ($58),y                  ; $8DA6
  cmp #$FF                     ; $8DA8
  bne Loc_B3_8DB7              ; $8DAA
  lda #$20                     ; $8DAC
  ora $0418                    ; $8DAE
  sta $0418                    ; $8DB1
  jmp Loc_B3_8DBD              ; $8DB4
Loc_B3_8DB7:
  jsr Sub_B3_8EAB              ; $8DB7
  jmp Loc_B3_8A3A              ; $8DBA
Loc_B3_8DBD:
  lda $0418                    ; $8DBD
  and #$30                     ; $8DC0
  cmp #$30                     ; $8DC2
  bne Loc_B3_8DF0              ; $8DC4
  lda $0418                    ; $8DC6
  and #$CF                     ; $8DC9
  sta $0418                    ; $8DCB
  bmi Loc_B3_8DD6              ; $8DCE
  jsr Sub_B3_8CA1              ; $8DD0
  jmp Loc_B3_8A3A              ; $8DD3
Loc_B3_8DD6:
  inc $0418                    ; $8DD6
  lda #$00                     ; $8DD9
  sta $0409                    ; $8DDB
  lda #$30                     ; $8DDE
  sta $040B                    ; $8DE0
  ldx #$00                     ; $8DE3
Loc_B3_8DE5:
  lda PaletteBuffer,x          ; $8DE5
  sta $0440,x                  ; $8DE8
  inx                          ; $8DEB
  cpx #$20                     ; $8DEC
  bcc Loc_B3_8DE5              ; $8DEE
Loc_B3_8DF0:
  jmp Loc_B3_8A3A              ; $8DF0
  lda z:PpuCtrlShadow          ; $8DF3  [heuristic code]
  and #$FB                     ; $8DF5
  jsr SetPpuCtrl               ; $8DF7
  ldy #$04                     ; $8DFA
  lda $0409                    ; $8DFC
  tax                          ; $8DFF
  lda $040B                    ; $8E00
  cmp #$F0                     ; $8E03
  beq Loc_B3_8E7A              ; $8E05
  cmp #$00                     ; $8E07
  bne Loc_B3_8E1C              ; $8E09
  lda #$0F                     ; $8E0B
  sta $0440,x                  ; $8E0D
  sta $0441,x                  ; $8E10
  sta $0442,x                  ; $8E13
  sta $0443,x                  ; $8E16
  jmp Loc_B3_8E33              ; $8E19
Loc_B3_8E1C:
  lda $0440,x                  ; $8E1C
  and #$F0                     ; $8E1F
  cmp $040B                    ; $8E21
  bne Loc_B3_8E2F              ; $8E24
  lda $0440,x                  ; $8E26
  sec                          ; $8E29
  sbc #$10                     ; $8E2A
  sta $0440,x                  ; $8E2C
Loc_B3_8E2F:
  inx                          ; $8E2F
  dey                          ; $8E30
  bne Loc_B3_8E1C              ; $8E31
Loc_B3_8E33:
  lda PPU_STATUS               ; $8E33
  lda #$3F                     ; $8E36
  sta PPU_ADDR                 ; $8E38
  lda $0409                    ; $8E3B
  and #$10                     ; $8E3E
  sta PPU_ADDR                 ; $8E40
  tax                          ; $8E43
  ldy #$10                     ; $8E44
Loc_B3_8E46:
  lda $0440,x                  ; $8E46
  sta PPU_DATA                 ; $8E49
  inx                          ; $8E4C
  dey                          ; $8E4D
  bne Loc_B3_8E46              ; $8E4E
  lda #$3F                     ; $8E50
  sta PPU_ADDR                 ; $8E52
  lda #$00                     ; $8E55
  sta PPU_ADDR                 ; $8E57
  sta PPU_ADDR                 ; $8E5A
  sta PPU_ADDR                 ; $8E5D
  lda $0409                    ; $8E60
  clc                          ; $8E63
  adc #$04                     ; $8E64
  and #$1F                     ; $8E66
  sta $0409                    ; $8E68
  bne Loc_B3_8E8D              ; $8E6B
  lda $040B                    ; $8E6D
  sec                          ; $8E70
  sbc #$10                     ; $8E71
  sta $040B                    ; $8E73
  cmp #$F0                     ; $8E76
  bne Loc_B3_8E8D              ; $8E78
Loc_B3_8E7A:
  lda z:FrameInSecond          ; $8E7A
  cmp #$3B                     ; $8E7C
  bcc Loc_B3_8E8D              ; $8E7E
  inc $0409                    ; $8E80
  lda $0409                    ; $8E83
  cmp #$03                     ; $8E86
  bcc Loc_B3_8E8D              ; $8E88
  jsr Sub_B3_8CA1              ; $8E8A
Loc_B3_8E8D:
  jmp Loc_B3_8A3A              ; $8E8D
Sub_B3_8E90:
  lda #$00                     ; $8E90
  sta $0408                    ; $8E92
  lda $0409                    ; $8E95
  asl a                        ; $8E98
  tay                          ; $8E99
  iny                          ; $8E9A
  lda ($56),y                  ; $8E9B
  pha                          ; $8E9D
  ldy #$01                     ; $8E9E
  sta ($5C),y                  ; $8EA0
  pla                          ; $8EA2
  clc                          ; $8EA3
  adc #$02                     ; $8EA4
  ldy #$05                     ; $8EA6
  sta ($5C),y                  ; $8EA8
  rts                          ; $8EAA
Sub_B3_8EAB:
  lda #$00                     ; $8EAB
  sta $040A                    ; $8EAD
  lda $040B                    ; $8EB0
  asl a                        ; $8EB3
  tay                          ; $8EB4
  iny                          ; $8EB5
  lda ($58),y                  ; $8EB6
  ldy #$09                     ; $8EB8
  sta ($5C),y                  ; $8EBA
  rts                          ; $8EBC
Data_B3_8EBD:
  .incbin "prg_bank_3.bin", $0EBD, $1  ; $8EBD
Data_B3_8EBE:
  .incbin "prg_bank_3.bin", $0EBE, $3  ; $8EBE
Data_B3_8EC1:
  .incbin "prg_bank_3.bin", $0EC1, $1  ; $8EC1
Data_B3_8EC2:
  .incbin "prg_bank_3.bin", $0EC2, $27  ; $8EC2
Sub_B3_8EE9:
  lda $0411                    ; $8EE9
  and #$7F                     ; $8EEC
  cmp #$01                     ; $8EEE
  bne Loc_B3_8EF5              ; $8EF0
  jmp Loc_B3_8F25              ; $8EF2
Loc_B3_8EF5:
  cmp #$0B                     ; $8EF5
  bne Loc_B3_8F0D              ; $8EF7
  lda #$86                     ; $8EF9
  sta z:$60                    ; $8EFB
  lda #$90                     ; $8EFD
  sta z:$61                    ; $8EFF
  ldy #$00                     ; $8F01
Loc_B3_8F03:
  lda ($60),y                  ; $8F03
  sta a:$64,y                  ; $8F05
  iny                          ; $8F08
  cpy #$05                     ; $8F09
  bne Loc_B3_8F03              ; $8F0B
Loc_B3_8F0D:
  lda #$20                     ; $8F0D
  clc                          ; $8F0F
  adc z:$65                    ; $8F10
  sta z:$65                    ; $8F12
  lda #$00                     ; $8F14
  adc z:$64                    ; $8F16
  sta z:$64                    ; $8F18
  jsr ProcessPpuUpdateList     ; $8F1A
  .incbin "prg_bank_3.bin", $0F1D, $2  ; $8F1D
  dec $0411                    ; $8F1F
  jmp Loc_B3_905F              ; $8F22
Loc_B3_8F25:
  lda $0411                    ; $8F25
  bmi Loc_B3_8F73              ; $8F28
  ora #$80                     ; $8F2A
  sta $0411                    ; $8F2C
  lda #$D9                     ; $8F2F
  sta z:Tmp00                  ; $8F31
  lda #$2B                     ; $8F33
  sta z:Tmp01                  ; $8F35
  jsr Sub_B3_9060              ; $8F37
  jsr ProcessPpuUpdateList     ; $8F3A
  .incbin "prg_bank_3.bin", $0F3D, $2  ; $8F3D
  lda #$84                     ; $8F3F
  sta z:$60                    ; $8F41
  lda #$28                     ; $8F43
  sta z:$61                    ; $8F45
  lda #$A4                     ; $8F47
  sta z:$62                    ; $8F49
  lda #$28                     ; $8F4B
  sta z:$63                    ; $8F4D
  lda #$0F                     ; $8F4F
  sta $0416                    ; $8F51
  sta $0417                    ; $8F54
  lda #$F0                     ; $8F57
  sta z:$64                    ; $8F59
  lda #$F2                     ; $8F5B
  sta z:$65                    ; $8F5D
  lda PPU_STATUS               ; $8F5F
  lda z:$61                    ; $8F62
  sta PPU_ADDR                 ; $8F64
  lda z:$60                    ; $8F67
  inc z:$60                    ; $8F69
  sta PPU_ADDR                 ; $8F6B
  lda #$EC                     ; $8F6E
  sta PPU_DATA                 ; $8F70
Loc_B3_8F73:
  lda $0416                    ; $8F73
  cmp #$05                     ; $8F76
  bcc Loc_B3_8F86              ; $8F78
  lda z:PpuCtrlShadow          ; $8F7A
  and #$FB                     ; $8F7C
  sta z:PpuCtrlShadow          ; $8F7E
  sta PPU_CTRL                 ; $8F80
  jmp Loc_B3_8F8F              ; $8F83
Loc_B3_8F86:
  lda z:PpuCtrlShadow          ; $8F86
  ora #$04                     ; $8F88
  sta z:PpuCtrlShadow          ; $8F8A
  sta PPU_CTRL                 ; $8F8C
Loc_B3_8F8F:
  lda PPU_STATUS               ; $8F8F
  lda z:$61                    ; $8F92
  sta PPU_ADDR                 ; $8F94
  lda z:$60                    ; $8F97
  sta PPU_ADDR                 ; $8F99
  lda z:$64                    ; $8F9C
  sta PPU_DATA                 ; $8F9E
  sta PPU_DATA                 ; $8FA1
  dec $0416                    ; $8FA4
  lda $0416                    ; $8FA7
  cmp #$05                     ; $8FAA
  bcc Loc_B3_8FB5              ; $8FAC
  inc z:$60                    ; $8FAE
  inc z:$60                    ; $8FB0
  jmp Loc_B3_8FD9              ; $8FB2
Loc_B3_8FB5:
  cmp #$04                     ; $8FB5
  bne Loc_B3_8FCC              ; $8FB7
  lda #$ED                     ; $8FB9
  sta PPU_DATA                 ; $8FBB
  lda #$F3                     ; $8FBE
  sta z:$64                    ; $8FC0
  lda #$22                     ; $8FC2
  clc                          ; $8FC4
  adc z:$60                    ; $8FC5
  sta z:$60                    ; $8FC7
  jmp Loc_B3_8FD9              ; $8FC9
Loc_B3_8FCC:
  lda #$40                     ; $8FCC
  clc                          ; $8FCE
  adc z:$60                    ; $8FCF
  sta z:$60                    ; $8FD1
  lda #$00                     ; $8FD3
  adc z:$61                    ; $8FD5
  sta z:$61                    ; $8FD7
Loc_B3_8FD9:
  lda $0417                    ; $8FD9
  cmp #$0C                     ; $8FDC
  bcc Loc_B3_8FEC              ; $8FDE
  lda z:PpuCtrlShadow          ; $8FE0
  ora #$04                     ; $8FE2
  sta z:PpuCtrlShadow          ; $8FE4
  sta PPU_CTRL                 ; $8FE6
  jmp Loc_B3_8FF5              ; $8FE9
Loc_B3_8FEC:
  lda z:PpuCtrlShadow          ; $8FEC
  and #$FB                     ; $8FEE
  sta z:PpuCtrlShadow          ; $8FF0
  sta PPU_CTRL                 ; $8FF2
Loc_B3_8FF5:
  lda PPU_STATUS               ; $8FF5
  lda z:$63                    ; $8FF8
  sta PPU_ADDR                 ; $8FFA
  lda z:$62                    ; $8FFD
  sta PPU_ADDR                 ; $8FFF
  lda z:$65                    ; $9002
  sta PPU_DATA                 ; $9004
  sta PPU_DATA                 ; $9007
  dec $0417                    ; $900A
  bne Loc_B3_9012              ; $900D
  jmp Loc_B3_904A              ; $900F
Loc_B3_9012:
  lda $0417                    ; $9012
  cmp #$0C                     ; $9015
  bcc Loc_B3_9029              ; $9017
  lda #$40                     ; $9019
  clc                          ; $901B
  adc z:$62                    ; $901C
  sta z:$62                    ; $901E
  lda #$00                     ; $9020
  adc z:$63                    ; $9022
  sta z:$63                    ; $9024
  jmp Loc_B3_905F              ; $9026
Loc_B3_9029:
  cmp #$0B                     ; $9029
  bne Loc_B3_9043              ; $902B
  lda #$EE                     ; $902D
  sta PPU_DATA                 ; $902F
  lda #$F1                     ; $9032
  sta z:$65                    ; $9034
  lda #$3F                     ; $9036
  clc                          ; $9038
  adc z:$62                    ; $9039
  sta z:$62                    ; $903B
  lda #$00                     ; $903D
  adc z:$63                    ; $903F
  sta z:$63                    ; $9041
Loc_B3_9043:
  inc z:$62                    ; $9043
  inc z:$62                    ; $9045
  jmp Loc_B3_905F              ; $9047
Loc_B3_904A:
  lda #$EF                     ; $904A
  sta PPU_DATA                 ; $904C
  lda #$00                     ; $904F
  sta $0412                    ; $9051
  sta $041C                    ; $9054
  sta $0411                    ; $9057
  lda #$04                     ; $905A
  sta $0410                    ; $905C
Loc_B3_905F:
  rts                          ; $905F
Sub_B3_9060:
  lda z:PpuCtrlShadow          ; $9060
  and #$FB                     ; $9062
  sta z:PpuCtrlShadow          ; $9064
  sta PPU_CTRL                 ; $9066
  lda PPU_STATUS               ; $9069
  lda z:Tmp01                  ; $906C
  sta PPU_ADDR                 ; $906E
  lda z:Tmp00                  ; $9071
  sta PPU_ADDR                 ; $9073
  ldy #$00                     ; $9076
Loc_B3_9078:
  lda a:$50,y                  ; $9078
  ora #$0F                     ; $907B
  sta PPU_DATA                 ; $907D
  iny                          ; $9080
  cpy #$06                     ; $9081
  bne Loc_B3_9078              ; $9083
  rts                          ; $9085
  .incbin "prg_bank_3.bin", $1086, $E  ; $9086
Sub_B3_9094:
  lda $0411                    ; $9094
  beq Loc_B3_909C              ; $9097
  jmp Loc_B3_9142              ; $9099
Loc_B3_909C:
  lda $0414                    ; $909C
  lsr a                        ; $909F
  lsr a                        ; $90A0
  tay                          ; $90A1
  lda #$60                     ; $90A2
  sta z:Tmp02                  ; $90A4
  lda #$00                     ; $90A6
  sta z:Tmp03                  ; $90A8
  ldx #$00                     ; $90AA
  lda #$08                     ; $90AC
  sta z:Tmp01                  ; $90AE
Loc_B3_90B0:
  lda #$08                     ; $90B0
  sta z:Tmp00                  ; $90B2
Loc_B3_90B4:
  lda (Tmp02),y                ; $90B4
  sta z:$A0,x                  ; $90B6
  iny                          ; $90B8
  tya                          ; $90B9
  and #$07                     ; $90BA
  tay                          ; $90BC
  inx                          ; $90BD
  dec z:Tmp00                  ; $90BE
  bne Loc_B3_90B4              ; $90C0
  lda #$08                     ; $90C2
  clc                          ; $90C4
  adc z:Tmp02                  ; $90C5
  sta z:Tmp02                  ; $90C7
  lda #$00                     ; $90C9
  adc z:Tmp03                  ; $90CB
  sta z:Tmp03                  ; $90CD
  dec z:Tmp01                  ; $90CF
  bne Loc_B3_90B0              ; $90D1
  lda $0414                    ; $90D3
  and #$02                     ; $90D6
  bne Loc_B3_90DD              ; $90D8
  jmp Loc_B3_913C              ; $90DA
Loc_B3_90DD:
  lda #$A0                     ; $90DD
  sta z:Tmp02                  ; $90DF
  lda #$00                     ; $90E1
  sta z:Tmp03                  ; $90E3
  lda #$60                     ; $90E5
  sta z:$04                    ; $90E7
  lda #$00                     ; $90E9
  sta z:$05                    ; $90EB
  lda #$08                     ; $90ED
  sta z:Tmp01                  ; $90EF
Loc_B3_90F1:
  lda #$08                     ; $90F1
  sta z:Tmp00                  ; $90F3
  ldy #$00                     ; $90F5
Loc_B3_90F7:
  lda (Tmp02),y                ; $90F7
  lsr a                        ; $90F9
  lsr a                        ; $90FA
  and #$33                     ; $90FB
  sta ($04),y                  ; $90FD
  iny                          ; $90FF
  tya                          ; $9100
  and #$07                     ; $9101
  tay                          ; $9103
  lda (Tmp02),y                ; $9104
  asl a                        ; $9106
  asl a                        ; $9107
  and #$CC                     ; $9108
  pha                          ; $910A
  dey                          ; $910B
  tya                          ; $910C
  and #$07                     ; $910D
  tay                          ; $910F
  pla                          ; $9110
  ora ($04),y                  ; $9111
  sta ($04),y                  ; $9113
  iny                          ; $9115
  tya                          ; $9116
  and #$07                     ; $9117
  tay                          ; $9119
  dec z:Tmp00                  ; $911A
  bne Loc_B3_90F7              ; $911C
  lda #$08                     ; $911E
  clc                          ; $9120
  adc z:Tmp02                  ; $9121
  sta z:Tmp02                  ; $9123
  lda #$00                     ; $9125
  adc z:Tmp03                  ; $9127
  sta z:Tmp03                  ; $9129
  lda #$08                     ; $912B
  clc                          ; $912D
  adc z:$04                    ; $912E
  sta z:$04                    ; $9130
  lda #$00                     ; $9132
  adc z:$05                    ; $9134
  sta z:$05                    ; $9136
  dec z:Tmp01                  ; $9138
  bne Loc_B3_90F1              ; $913A
Loc_B3_913C:
  inc $0411                    ; $913C
  jmp Loc_B3_91B0              ; $913F
Loc_B3_9142:
  lda $0414                    ; $9142
  and #$02                     ; $9145
  beq Loc_B3_9154              ; $9147
  lda #$60                     ; $9149
  sta z:Tmp02                  ; $914B
  lda #$00                     ; $914D
  sta z:Tmp03                  ; $914F
  jmp Loc_B3_915C              ; $9151
Loc_B3_9154:
  lda #$A0                     ; $9154
  sta z:Tmp02                  ; $9156
  lda #$00                     ; $9158
  sta z:Tmp03                  ; $915A
Loc_B3_915C:
  lda #$40                     ; $915C
  sta z:Tmp00                  ; $915E
  lda PPU_STATUS               ; $9160
  lda #$2B                     ; $9163
  sta PPU_ADDR                 ; $9165
  lda #$C0                     ; $9168
  sta PPU_ADDR                 ; $916A
  ldy #$00                     ; $916D
Loc_B3_916F:
  lda (Tmp02),y                ; $916F
  sta PPU_DATA                 ; $9171
  iny                          ; $9174
  dec z:Tmp00                  ; $9175
  bne Loc_B3_916F              ; $9177
  lda z:HwScrollX              ; $9179
  sta $0414                    ; $917B
  and #$08                     ; $917E
  beq Loc_B3_9189              ; $9180
  lda #$F0                     ; $9182
  ora z:HwScrollX              ; $9184
  jmp Loc_B3_918D              ; $9186
Loc_B3_9189:
  lda #$0F                     ; $9189
  and z:HwScrollX              ; $918B
Loc_B3_918D:
  sta z:HwScrollX              ; $918D
  ldy #$19                     ; $918F
  ldx #$00                     ; $9191
Loc_B3_9193:
  lda (Tmp02),y                ; $9193
  sta z:$50,x                  ; $9195
  iny                          ; $9197
  inx                          ; $9198
  cpx #$06                     ; $9199
  bne Loc_B3_9193              ; $919B
  lda z:PpuCtrlShadow          ; $919D
  ora #$02                     ; $919F
  sta PPU_CTRL                 ; $91A1
  sta z:PpuCtrlShadow          ; $91A4
  lda #$0B                     ; $91A6
  sta $0411                    ; $91A8
  lda #$03                     ; $91AB
  sta $0410                    ; $91AD
Loc_B3_91B0:
  rts                          ; $91B0
Sub_B3_91B1:
  lda #$00                     ; $91B1
  sta z:$58                    ; $91B3
  sta z:$5A                    ; $91B5
  lda #$20                     ; $91B7
  sta z:$59                    ; $91B9
  lda #$28                     ; $91BB
  sta z:$5B                    ; $91BD
  lda z:PpuCtrlShadow          ; $91BF
  and #$FB                     ; $91C1
  sta PPU_CTRL                 ; $91C3
  sta z:PpuCtrlShadow          ; $91C6
  lda z:HwScrollX              ; $91C8
  and #$08                     ; $91CA
  beq Loc_B3_91D6              ; $91CC
  lda #$10                     ; $91CE
  clc                          ; $91D0
  adc z:HwScrollX              ; $91D1
  jmp Loc_B3_91D8              ; $91D3
Loc_B3_91D6:
  lda z:HwScrollX              ; $91D6
Loc_B3_91D8:
  lsr a                        ; $91D8
  lsr a                        ; $91D9
  lsr a                        ; $91DA
  and #$FE                     ; $91DB
  sta $0414                    ; $91DD
  sta $0413                    ; $91E0
  lda #$20                     ; $91E3
  sec                          ; $91E5
  sbc $0413                    ; $91E6
  and #$1E                     ; $91E9
  sta $0413                    ; $91EB
  lda #$00                     ; $91EE
  sta $040C                    ; $91F0
  sta $0415                    ; $91F3
  lda #$10                     ; $91F6
  sta $0411                    ; $91F8
  inc $0410                    ; $91FB
  rts                          ; $91FE
Sub_B3_91FF:
  lda $0415                    ; $91FF
  bne Loc_B3_9254              ; $9202
  lda #$60                     ; $9204
  sta z:$56                    ; $9206
  lda #$00                     ; $9208
  sta z:$57                    ; $920A
  ldy $0413                    ; $920C
  lda #$02                     ; $920F
  sta z:Tmp01                  ; $9211
  lda PPU_STATUS               ; $9213
  lda z:$59                    ; $9216
  sta PPU_ADDR                 ; $9218
  lda z:$58                    ; $921B
  sta PPU_ADDR                 ; $921D
  lda PPU_DATA                 ; $9220
  lda #$20                     ; $9223
  sta z:Tmp00                  ; $9225
Loc_B3_9227:
  lda PPU_DATA                 ; $9227
  sta ($56),y                  ; $922A
  iny                          ; $922C
  tya                          ; $922D
  and #$1F                     ; $922E
  tay                          ; $9230
  dec z:Tmp00                  ; $9231
  bne Loc_B3_9227              ; $9233
  lda #$20                     ; $9235
  clc                          ; $9237
  adc z:$56                    ; $9238
  sta z:$56                    ; $923A
  lda #$20                     ; $923C
  sta z:Tmp00                  ; $923E
Loc_B3_9240:
  lda PPU_DATA                 ; $9240
  sta ($56),y                  ; $9243
  iny                          ; $9245
  tya                          ; $9246
  and #$1F                     ; $9247
  tay                          ; $9249
  dec z:Tmp00                  ; $924A
  bne Loc_B3_9240              ; $924C
  inc $0415                    ; $924E
  jmp Loc_B3_92B6              ; $9251
Loc_B3_9254:
  jsr DoOamDma                 ; $9254
  lda $0411                    ; $9257
  cmp #$01                     ; $925A
  beq Loc_B3_92AC              ; $925C
  ldx #$40                     ; $925E
  ldy #$00                     ; $9260
  lda PPU_STATUS               ; $9262
  lda z:$5B                    ; $9265
  sta PPU_ADDR                 ; $9267
  lda z:$5A                    ; $926A
  sta PPU_ADDR                 ; $926C
Loc_B3_926F:
  lda a:$60,y                  ; $926F
  sta PPU_DATA                 ; $9272
  iny                          ; $9275
  dex                          ; $9276
  bne Loc_B3_926F              ; $9277
  lda z:$58                    ; $9279
  clc                          ; $927B
  adc #$40                     ; $927C
  sta z:$58                    ; $927E
  lda #$00                     ; $9280
  adc z:$59                    ; $9282
  sta z:$59                    ; $9284
  lda z:$5A                    ; $9286
  clc                          ; $9288
  adc #$40                     ; $9289
  sta z:$5A                    ; $928B
  lda #$00                     ; $928D
  adc z:$5B                    ; $928F
  sta z:$5B                    ; $9291
  dec $0411                    ; $9293
  beq Loc_B3_92AC              ; $9296
  lda #$00                     ; $9298
  sta $0415                    ; $929A
  lda $0411                    ; $929D
  cmp #$01                     ; $92A0
  bne Loc_B3_92B6              ; $92A2
  lda #$00                     ; $92A4
  sta $0413                    ; $92A6
  jmp Loc_B3_92B6              ; $92A9
Loc_B3_92AC:
  lda #$00                     ; $92AC
  sta $0411                    ; $92AE
  lda #$02                     ; $92B1
  sta $0410                    ; $92B3
Loc_B3_92B6:
  rts                          ; $92B6
Sub_B3_92B7:
  lda $0422                    ; $92B7
  bne Loc_B3_92DE              ; $92BA
  lda $0404                    ; $92BC
  asl a                        ; $92BF
  tay                          ; $92C0
  lda Data_B3_9427,y           ; $92C1
  sta z:$56                    ; $92C4
  lda Data_B3_9428,y           ; $92C6
  sta z:$57                    ; $92C9
  lda $042D                    ; $92CB
  clc                          ; $92CE
  adc #$21                     ; $92CF
  sta $0425                    ; $92D1
  lda #$20                     ; $92D4
  sta $0426                    ; $92D6
  lda #$FF                     ; $92D9
  sta $0423                    ; $92DB
Loc_B3_92DE:
  inc $041F                    ; $92DE
  lda $041F                    ; $92E1
  cmp #$05                     ; $92E4
  bcs Loc_B3_92EB              ; $92E6
  jmp Loc_B3_9361              ; $92E8
Loc_B3_92EB:
  lda #$00                     ; $92EB
  sta $041F                    ; $92ED
  ldy $0422                    ; $92F0
Loc_B3_92F3:
  lda ($56),y                  ; $92F3
  cmp #$FF                     ; $92F5
  bne Loc_B3_9314              ; $92F7
  lda $0425                    ; $92F9
  and #$1F                     ; $92FC
  cmp #$1F                     ; $92FE
  bne Loc_B3_930D              ; $9300
  lda $0425                    ; $9302
  and #$E0                     ; $9305
  sta $0425                    ; $9307
  jmp Loc_B3_9310              ; $930A
Loc_B3_930D:
  inc $0425                    ; $930D
Loc_B3_9310:
  iny                          ; $9310
  jmp Loc_B3_92F3              ; $9311
Loc_B3_9314:
  cmp #$40                     ; $9314
  bne Loc_B3_9325              ; $9316
  lda $042D                    ; $9318
  clc                          ; $931B
  adc #$41                     ; $931C
  sta $0425                    ; $931E
  iny                          ; $9321
  jmp Loc_B3_92F3              ; $9322
Loc_B3_9325:
  cmp #$43                     ; $9325
  bne Loc_B3_9342              ; $9327
  lda #$00                     ; $9329
  sta $041F                    ; $932B
  sta $0422                    ; $932E
  sta $0402                    ; $9331
  sta JoyHeld1                 ; $9334
  lda $0403                    ; $9337
  sta z:MmcPrgShadow           ; $933A
  inc $0421                    ; $933C
  jmp Loc_B3_9361              ; $933F
Loc_B3_9342:
  lda ($56),y                  ; $9342
  bmi Loc_B3_9355              ; $9344
  cmp #$2E                     ; $9346
  beq Loc_B3_9350              ; $9348
  cmp #$2F                     ; $934A
  beq Loc_B3_9350              ; $934C
  ora #$40                     ; $934E
Loc_B3_9350:
  ora #$80                     ; $9350
  iny                          ; $9352
  lda ($56),y                  ; $9353
Loc_B3_9355:
  sta $0423                    ; $9355
  iny                          ; $9358
  sty $0422                    ; $9359
  lda #$01                     ; $935C
  sta $0427                    ; $935E
Loc_B3_9361:
  rts                          ; $9361
Sub_B3_9362:
  lda $0422                    ; $9362
  beq Loc_B3_936A              ; $9365
  jmp Loc_B3_938C              ; $9367
Loc_B3_936A:
  lda #$00                     ; $936A
  sta $0429                    ; $936C
  sta $0428                    ; $936F
  ldy #$00                     ; $9372
  lda Data_B3_9411,y           ; $9374
  sta $042C                    ; $9377
  iny                          ; $937A
  lda Data_B3_9411,y           ; $937B
  sta $042A                    ; $937E
  iny                          ; $9381
  lda Data_B3_9411,y           ; $9382
  sta $042B                    ; $9385
  iny                          ; $9388
  sty $0422                    ; $9389
Loc_B3_938C:
  lda #$02                     ; $938C
  sta z:Tmp00                  ; $938E
Loc_B3_9390:
  lda $042D                    ; $9390
  sta z:Tmp02                  ; $9393
  and #$1F                     ; $9395
  sta z:Tmp01                  ; $9397
  lda $0428                    ; $9399
  and #$0F                     ; $939C
  clc                          ; $939E
  adc z:Tmp01                  ; $939F
  cmp #$20                     ; $93A1
  bcc Loc_B3_93AC              ; $93A3
  lda z:Tmp02                  ; $93A5
  sec                          ; $93A7
  sbc #$20                     ; $93A8
  sta z:Tmp02                  ; $93AA
Loc_B3_93AC:
  lda PPU_STATUS               ; $93AC
  lda #$20                     ; $93AF
  sta PPU_ADDR                 ; $93B1
  lda $0428                    ; $93B4
  clc                          ; $93B7
  adc z:Tmp02                  ; $93B8
  sta PPU_ADDR                 ; $93BA
  ldy $0429                    ; $93BD
  lda $0440,y                  ; $93C0
  sta PPU_DATA                 ; $93C3
  dec $042C                    ; $93C6
  beq Loc_B3_93E6              ; $93C9
Loc_B3_93CB:
  lda $042A                    ; $93CB
  clc                          ; $93CE
  adc $0428                    ; $93CF
  sta $0428                    ; $93D2
  lda $042B                    ; $93D5
  clc                          ; $93D8
  adc $0429                    ; $93D9
  sta $0429                    ; $93DC
  dec z:Tmp00                  ; $93DF
  bne Loc_B3_9390              ; $93E1
  jmp Loc_B3_9410              ; $93E3
Loc_B3_93E6:
  ldy $0422                    ; $93E6
  lda Data_B3_9411,y           ; $93E9
  cmp #$FF                     ; $93EC
  beq Loc_B3_9408              ; $93EE
  sta $042C                    ; $93F0
  iny                          ; $93F3
  lda Data_B3_9411,y           ; $93F4
  sta $042A                    ; $93F7
  iny                          ; $93FA
  lda Data_B3_9411,y           ; $93FB
  sta $042B                    ; $93FE
  iny                          ; $9401
  sty $0422                    ; $9402
  jmp Loc_B3_93CB              ; $9405
Loc_B3_9408:
  lda #$00                     ; $9408
  sta $0402                    ; $940A
  sta $0421                    ; $940D
Loc_B3_9410:
  rts                          ; $9410
Data_B3_9411:
  .incbin "prg_bank_3.bin", $1411, $16  ; $9411
Data_B3_9427:
  .incbin "prg_bank_3.bin", $1427, $1  ; $9427
Data_B3_9428:
  .incbin "prg_bank_3.bin", $1428, $19C  ; $9428
Data_B3_95C4:
  .incbin "prg_bank_3.bin", $15C4, $1  ; $95C4
Data_B3_95C5:
  .incbin "prg_bank_3.bin", $15C5, $400  ; $95C5
  .incbin "prg_bank_3.bin", $19C5, $400  ; $99C5
  .incbin "prg_bank_3.bin", $1DC5, $400  ; $9DC5
  .incbin "prg_bank_3.bin", $21C5, $400  ; $A1C5
  .incbin "prg_bank_3.bin", $25C5, $400  ; $A5C5
  .incbin "prg_bank_3.bin", $29C5, $400  ; $A9C5
  .incbin "prg_bank_3.bin", $2DC5, $400  ; $ADC5
  .incbin "prg_bank_3.bin", $31C5, $400  ; $B1C5
  .incbin "prg_bank_3.bin", $35C5, $400  ; $B5C5
  .incbin "prg_bank_3.bin", $39C5, $400  ; $B9C5
  .incbin "prg_bank_3.bin", $3DC5, $238  ; $BDC5
Data_B3_BFFD:
  .incbin "prg_bank_3.bin", $3FFD, $3  ; $BFFD
