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
  jsr DispatchPpuOpRequest     ; $8028
  lda z:PpuMaskShadow          ; $802B
  sta PPU_MASK                 ; $802D
  jsr ApplyScroll              ; $8030
  jsr DispatchSceneStateBank4  ; $8033
  jsr CheckLowLifeSound        ; $8036
  inc z:FrameCounter           ; $8039
  jsr DrawHud                  ; $803B
  jsr HideSpritesWithTileFE    ; $803E
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
DispatchSceneStateBank4:
  lda SceneState               ; $80B3
  asl a                        ; $80B6
  tax                          ; $80B7
  lda Data_B4_80C5,x           ; $80B8
  sta z:$6D                    ; $80BB
  lda Data_B4_80C6,x           ; $80BD
  sta z:$6E                    ; $80C0
  jmp ($006D)                  ; $80C2
Data_B4_80C5:
  .addr Bank4State_00, Bank4State_01, Bank4State_02, Bank4State_03, Bank4State_04, Bank4State_05, Bank4State_06, Bank4State_07, Bank4State_08, Bank4State_09, Bank4State_0A, Bank4State_0B, Bank4State_0C, Bank4State_0D, Bank4State_0E, Bank4State_0F, Bank4State_10, Bank4State_11, Bank4State_12, Bank4State_13, Bank4State_14, Bank4State_15, Bank4State_16, Bank4State_17, Bank4State_18, Bank4State_19, Bank4State_1A, Bank4State_1B, Bank4State_1C, Bank4State_1D, Bank4State_1E, Bank4State_1F, Bank4State_20  ; $80C5 pointer table
Bank4State_00:
  lda #$00                     ; $8107
  sta $050A                    ; $8109
  sta $050B                    ; $810C
  sta $050C                    ; $810F
Bank4State_03:
  lda #$04                     ; $8112
  sta SceneState               ; $8114
  jsr ClearSceneStateTail      ; $8117
  jmp Loc_B4_8496              ; $811A
Bank4State_01:
  lda #$1C                     ; $811D
  sta SceneState               ; $811F
  jsr ClearWorkVars60          ; $8122
  jmp Loc_B4_8496              ; $8125
Bank4State_02:
  lda #$1E                     ; $8128
  sta SceneState               ; $812A
  jsr ClearWorkVars60          ; $812D
  jmp Loc_B4_8496              ; $8130
Bank4State_04:
  inc SceneState               ; $8133
  jmp DisableSpriteBgRendering ; $8136
Bank4State_05:
  inc SceneState               ; $8139
  jsr FillPaletteBlack         ; $813C
  jsr HideSpritesFromStart     ; $813F
  lda #$03                     ; $8142
  sta CollectedCount           ; $8144
  jsr CopyPpuListStubToRam     ; $8147
  jsr InitMazePosition         ; $814A
  jsr DrawCompassSprites       ; $814D
  jsr DrawCorridorView         ; $8150
  jsr DrawMazeScreen           ; $8153
  jsr DrawCollectedCountIcons  ; $8156
  jsr DrawCollectedItemIcons   ; $8159
  jsr SpawnDoorObjectsIfAhead  ; $815C
  jsr ClearNametable2Rows      ; $815F
  jmp ApplyScroll              ; $8162
Bank4State_06:
  inc SceneState               ; $8165
  jsr UpdateAllObjectHandlers  ; $8168
  jsr UpdateAllObjectHandlers  ; $816B
  jsr DrawObjects              ; $816E
  jsr DispatchPpuOpRequest     ; $8171
  jmp ApplyScroll              ; $8174
Bank4State_07:
  inc SceneState               ; $8177
  jsr RequestPaletteUpdate     ; $817A
  lda #$00                     ; $817D
  sta z:$7C                    ; $817F
  lda #$11                     ; $8181
  sta z:$8A                    ; $8183
  jmp EnableSpriteBgRendering  ; $8185
Bank4State_08:
  lda PPU_STATUS               ; $8188
  jsr ReadJoypads              ; $818B
  jsr HandleActionButtonInMaze ; $818E
  jsr UpdateAllObjectHandlers  ; $8191
  jsr DrawObjects              ; $8194
  jsr ReadMazeInput            ; $8197
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
Bank4State_09:
  lda #$45                     ; $81C1
  jsr QueueSound               ; $81C3
  jsr ResetDamageFlash         ; $81C6
  jmp Loc_B4_8509              ; $81C9
Bank4State_0A:
  inc SceneState               ; $81CC
  jsr DisableSpriteBgRendering ; $81CF
  lda MazeIndex                ; $81D2
  cmp #$0C                     ; $81D5
  bne Loc_B4_81E7              ; $81D7
  lda PlayerCellY              ; $81D9
  cmp #$02                     ; $81DC
  bne Loc_B4_81E7              ; $81DE
  lda PlayerFacing             ; $81E0
  cmp #$01                     ; $81E3
  beq Loc_B4_81EA              ; $81E5
Loc_B4_81E7:
  jmp Loc_B4_8D1B              ; $81E7
Loc_B4_81EA:
  lda #$00                     ; $81EA
  ldx #$14                     ; $81EC
  tay                          ; $81EE
  jsr RequestTransitionFromTable ; $81EF
  jmp Loc_B4_82FE              ; $81F2
Bank4State_0B:
  lda #$06                     ; $81F5
  sta SceneState               ; $81F7
  jsr FillPaletteBlack         ; $81FA
  jsr HideSpritesFromStart     ; $81FD
  jsr InitMazePalette          ; $8200
  lda z:PpuCtrlShadow          ; $8203
  and #$FC                     ; $8205
  sta z:PpuCtrlShadow          ; $8207
  lda #$00                     ; $8209
  sta z:$7C                    ; $820B
  sta z:HwScrollX              ; $820D
  sta z:HwScrollY              ; $820F
  sta z:$88                    ; $8211
  sta z:$89                    ; $8213
  jsr InitAllObjectAnims       ; $8215
  jsr DrawCompassSprites       ; $8218
  jsr DrawCorridorView         ; $821B
  jsr DrawMazeScreen           ; $821E
  jsr DrawCollectedCountIcons  ; $8221
  jsr DrawCollectedItemIcons   ; $8224
  jsr SpawnDoorObjectsIfAhead  ; $8227
  jsr ClearNametable2Rows      ; $822A
  jsr ApplyScroll              ; $822D
  jmp LoadMazeObjectTables     ; $8230
Bank4State_0C:
  inc SceneState               ; $8233
  jmp DisableSpriteBgRendering ; $8236
Bank4State_0D:
  inc SceneState               ; $8239
  jsr FillPaletteBlack         ; $823C
  jsr HideSpritesFromStart     ; $823F
  jsr DrawCompassSprites       ; $8242
  jsr CopyThunkToRamAndCall800A ; $8245
  lda #$00                     ; $8248
  sta z:HwScrollX              ; $824A
  sta z:HwScrollY              ; $824C
  jsr ApplyScroll              ; $824E
  lda z:PpuCtrlShadow          ; $8251
  ora #$02                     ; $8253
  sta z:PpuCtrlShadow          ; $8255
  jsr ClearObjectTable         ; $8257
  jsr InitMazePalette          ; $825A
  jmp DrawObjects              ; $825D
Bank4State_0E:
  inc SceneState               ; $8260
  rts                          ; $8263
Bank4State_0F:
  inc SceneState               ; $8264
  jsr RequestPaletteUpdate     ; $8267
  jmp EnableSpriteBgRendering  ; $826A
Bank4State_10:
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
Bank4State_11:
  inc SceneState               ; $8284
  jmp DisableSpriteBgRendering ; $8287
Bank4State_12:
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
  .incbin "prg_bank_4.bin", $02A2, $12  ; $82A2
ReloadMazeAfterMove:
  lda #$06                     ; $82B4
  sta SceneState               ; $82B6
  jsr FillPaletteBlack         ; $82B9
  jsr HideSpritesFromStart     ; $82BC
  lda PlayerCellX              ; $82BF
  clc                          ; $82C2
  adc z:$7E                    ; $82C3
  sta PlayerCellX              ; $82C5
  lda PlayerCellY              ; $82C8
  clc                          ; $82CB
  adc z:$7F                    ; $82CC
  sta PlayerCellY              ; $82CE
  jsr DrawCompassSprites       ; $82D1
  jsr DrawCorridorView         ; $82D4
  jsr DrawMazeScreen           ; $82D7
  jsr DrawCollectedCountIcons  ; $82DA
  jsr DrawCollectedItemIcons   ; $82DD
  jsr SpawnDoorObjectsIfAhead  ; $82E0
  jsr ClearNametable2Rows      ; $82E3
  jsr LoadMazeObjectTables     ; $82E6
  lda #$1C                     ; $82E9
  jmp QueueSound               ; $82EB
  .incbin "prg_bank_4.bin", $02EE, $10  ; $82EE
Loc_B4_82FE:
  lda #$00                     ; $82FE
  sta z:MmcPrgShadow           ; $8300
  sta z:GameState              ; $8302
  rts                          ; $8304
  .incbin "prg_bank_4.bin", $0305, $9  ; $8305
Bank4State_13:
  inc SceneState               ; $830E
  jmp DisableSpriteBgRendering ; $8311
Bank4State_14:
  inc SceneState               ; $8314
  jsr FillPaletteBlack         ; $8317
  jsr HideSpritesFromStart     ; $831A
  jsr CopyThunkToRamAndCall800D ; $831D
  jsr ApplyScroll              ; $8320
  jmp ClearObjectTable         ; $8323
Bank4State_15:
  inc SceneState               ; $8326
  lda $052E                    ; $8329
  ldx z:$81                    ; $832C
  cpx #$01                     ; $832E
  bne Loc_B4_8334              ; $8330
  and #$0F                     ; $8332
Loc_B4_8334:
  sta $052A                    ; $8334
  jsr RequestPaletteUpdate     ; $8337
  jmp EnableSpriteBgRendering  ; $833A
Bank4State_16:
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
Bank4State_17:
  inc SceneState               ; $8361
  jmp DisableSpriteBgRendering ; $8364
Bank4State_18:
  lda #$06                     ; $8367
  sta SceneState               ; $8369
  jsr FillPaletteBlack         ; $836C
  jsr HideSpritesFromStart     ; $836F
  jsr ChangeMazeSection        ; $8372
  jsr DrawCompassSprites       ; $8375
  jsr DrawCorridorView         ; $8378
  jsr DrawMazeScreen           ; $837B
  jsr DrawCollectedCountIcons  ; $837E
  jsr DrawCollectedItemIcons   ; $8381
  jsr SpawnDoorObjectsIfAhead  ; $8384
  jsr ClearNametable2Rows      ; $8387
  jmp ApplyScroll              ; $838A
Bank4State_19:
  inc SceneState               ; $838D
  jmp DisableSpriteBgRendering ; $8390
Bank4State_1A:
  jsr ChangeMazeSection        ; $8393
  jmp Loc_B4_82FE              ; $8396
Bank4State_1B:
  lda #$06                     ; $8399
  sta SceneState               ; $839B
  jsr DisableSpriteBgRendering ; $839E
  lda #$0F                     ; $83A1
  sta $052A                    ; $83A3
  jsr HideSpritesFromStart     ; $83A6
  jsr DrawCompassSprites       ; $83A9
  jsr SpawnDoorObjectsIfAhead  ; $83AC
  lda z:PpuCtrlShadow          ; $83AF
  and #$FD                     ; $83B1
  sta z:PpuCtrlShadow          ; $83B3
  rts                          ; $83B5
Bank4State_1C:
  inc SceneState               ; $83B6
  jmp DisableSpriteBgRendering ; $83B9
Bank4State_1D:
  lda #$06                     ; $83BC
  sta SceneState               ; $83BE
  jsr FillPaletteBlack         ; $83C1
  jsr HideSpritesFromStart     ; $83C4
  jsr DrawCompassSprites       ; $83C7
  jsr DrawCorridorView         ; $83CA
  jsr DrawMazeScreen           ; $83CD
  jsr DrawCollectedCountIcons  ; $83D0
  jsr DrawCollectedItemIcons   ; $83D3
  jsr SpawnDoorObjectsIfAhead  ; $83D6
  jsr ClearNametable2Rows      ; $83D9
  jmp ApplyScroll              ; $83DC
Bank4State_1E:
  lda #$06                     ; $83DF
  sta SceneState               ; $83E1
  jsr FillPaletteBlack         ; $83E4
  jsr HideSpritesFromStart     ; $83E7
  jsr DrawCompassSprites       ; $83EA
  lda $0510                    ; $83ED
  sta MazeIndex                ; $83F0
  lda $0511                    ; $83F3
  sta PlayerCellX              ; $83F6
  lda $0512                    ; $83F9
  sta PlayerCellY              ; $83FC
  lda $0513                    ; $83FF
  sta PlayerFacing             ; $8402
  jsr LoadMazeData             ; $8405
  jsr DrawCorridorView         ; $8408
  jsr DrawMazeScreen           ; $840B
  jsr DrawCollectedCountIcons  ; $840E
  jsr DrawCollectedItemIcons   ; $8411
  jsr SpawnDoorObjectsIfAhead  ; $8414
  jsr ClearNametable2Rows      ; $8417
  jmp ApplyScroll              ; $841A
Bank4State_1F:
  inc SceneState               ; $841D
  lda #$78                     ; $8420
  sta $058F                    ; $8422
  lda #$05                     ; $8425
  sta PpuOpRequest             ; $8427
  ldx #$06                     ; $842A
Loc_B4_842C:
  lda Data_B4_843A,x           ; $842C
  sta $052A,x                  ; $842F
  dex                          ; $8432
  bpl Loc_B4_842C              ; $8433
  lda #$45                     ; $8435
  jmp QueueSound               ; $8437
Data_B4_843A:
  .incbin "prg_bank_4.bin", $043A, $7  ; $843A
Bank4State_20:
  dec $058F                    ; $8441
  bne Loc_B4_845B              ; $8444
  lda #$05                     ; $8446
  sta z:MmcPrgShadow           ; $8448
  lda #$03                     ; $844A
  sta SceneState               ; $844C
  ldy MazeIndex                ; $844F
  lda Data_B4_845C,y           ; $8452
  sta $013F                    ; $8455
  jmp DisableSpriteBgRendering ; $8458
Loc_B4_845B:
  rts                          ; $845B
Data_B4_845C:
  .incbin "prg_bank_4.bin", $045C, $12  ; $845C
HideSpritesFromStart:
  ldx Data_C34D                ; $846E
  bne Loc_B4_8475              ; $8471
HideAllSprites:
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
SetSprite0Marker:
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
  jsr QueueSound               ; $84C3
  lda #$08                     ; $84C6
  jsr QueueSound               ; $84C8
  jsr ClearObjectTable         ; $84CB
  jsr HideAllSprites           ; $84CE
  jsr SetSprite0Marker         ; $84D1
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
ClearSceneStateTail:
  lda #$00                     ; $84F5
  ldx #$10                     ; $84F7
Loc_B4_84F9:
  sta SceneState,x             ; $84F9
  inx                          ; $84FC
  bne Loc_B4_84F9              ; $84FD
ClearWorkVars60:
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
  jsr UpdateCompassMarkers     ; $8532
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
DrawCompassSprites:
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
  ldx PlayerFacing             ; $8568
  lda Data_B4_85A4,x           ; $856B
  sta $0213                    ; $856E
  lda Data_B4_85A3,x           ; $8571
  sta $0217                    ; $8574
  lda Data_B4_85A2,x           ; $8577
  sta $021B                    ; $857A
  lda Data_B4_85A1,x           ; $857D
  sta $021F                    ; $8580
UpdateCompassMarkers:
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
  .addr Bank4StateB_00, Bank4StateB_01, Bank4StateB_02, Bank4StateB_03, Bank4StateB_04, Bank4StateB_05, Bank4StateB_06, Bank4StateB_07, Bank4StateB_08, Bank4StateB_09, Bank4StateB_0A, Bank4StateB_0B, Bank4StateB_0C, Bank4StateB_0D  ; $85B7 pointer table
Bank4StateB_00:
  lda #$00                     ; $85D3
  sta z:$7C                    ; $85D5
  rts                          ; $85D7
Bank4StateB_01:
  dec z:$7F                    ; $85D8
  lda #$02                     ; $85DA
  sta z:$7C                    ; $85DC
  rts                          ; $85DE
Bank4StateB_02:
  inc z:$7E                    ; $85DF
  lda #$02                     ; $85E1
  sta z:$7C                    ; $85E3
  rts                          ; $85E5
Bank4StateB_03:
  inc z:$7F                    ; $85E6
  lda #$02                     ; $85E8
  sta z:$7C                    ; $85EA
  rts                          ; $85EC
Bank4StateB_04:
  dec z:$7E                    ; $85ED
  lda #$02                     ; $85EF
  sta z:$7C                    ; $85F1
  rts                          ; $85F3
Bank4StateB_05:
  lda MazeItemFullRestore      ; $85F4  [heuristic code]
  ora $050B                    ; $85F7
  bne Loc_B4_8604              ; $85FA
  ldy #$EA                     ; $85FC
  jsr AddObjectOfType          ; $85FE
  jmp Bank4StateB_00           ; $8601
Loc_B4_8604:
  lda #$00                     ; $8604
  ldx #$08                     ; $8606
  ldy #$03                     ; $8608
  jmp RequestTransitionFromTable ; $860A
Bank4StateB_06:
  lda MazeItemFullRestore      ; $860D
  ora $050C                    ; $8610
  bne Bank4StateB_04           ; $8613
  ldy #$E9                     ; $8615
  jsr AddObjectOfType          ; $8617
  jmp Bank4StateB_00           ; $861A
Bank4StateB_07:
  lda #$01                     ; $861D
  sta $050C                    ; $861F
  ldx #$05                     ; $8622
  ldy #$04                     ; $8624
  jmp RequestTransitionFromTable ; $8626
Bank4StateB_08:
  lda MazeItemFullRestore      ; $8629
  ora $050C                    ; $862C
  bne Loc_B4_8639              ; $862F
  ldy #$E9                     ; $8631
  jsr AddObjectOfType          ; $8633
  jmp Bank4StateB_00           ; $8636
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
Bank4StateB_09:
  lda MazeItemFullRestore      ; $8657
  ora $050C                    ; $865A
  beq Loc_B4_8662              ; $865D
  jmp Bank4StateB_04           ; $865F
Loc_B4_8662:
  ldy #$E9                     ; $8662
  jsr AddObjectOfType          ; $8664
  jmp Bank4StateB_00           ; $8667
Bank4StateB_0A:
  lda MazeItemFullRestore      ; $866A
  bne Loc_B4_8677              ; $866D
  ldy #$EB                     ; $866F
  jsr AddObjectOfType          ; $8671
  jmp Bank4StateB_00           ; $8674
Loc_B4_8677:
  lda #$00                     ; $8677
  ldx #$0B                     ; $8679
  ldy #$03                     ; $867B
  jmp RequestTransitionFromTable ; $867D
Bank4StateB_0B:
  lda MazeItemFullRestore      ; $8680
  ora $050C                    ; $8683
  bne Loc_B4_8690              ; $8686
  ldy #$E9                     ; $8688
  jsr AddObjectOfType          ; $868A
  jmp Bank4StateB_00           ; $868D
Loc_B4_8690:
  lda #$04                     ; $8690
  sta $0510                    ; $8692
  lda PlayerCellX              ; $8695
  clc                          ; $8698
  adc #$03                     ; $8699
  sta $0511                    ; $869B
  lda #$00                     ; $869E
  sta $0512                    ; $86A0
  lda #$02                     ; $86A3
  sta $0513                    ; $86A5
  jmp Loc_B4_864D              ; $86A8
Bank4StateB_0C:
  lda #$00                     ; $86AB
  ldx #$11                     ; $86AD
  ldy #$03                     ; $86AF
  jmp RequestTransitionFromTable ; $86B1
Bank4StateB_0D:
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
  jmp RequestTransitionFromTable ; $86CE
ClearObjectTable:
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
LoadMazeObjectTables:
  lda ObjectCount              ; $8AD3
  beq Loc_B4_8AD9              ; $8AD6
  rts                          ; $8AD8
Loc_B4_8AD9:
  lda MazeIndex                ; $8AD9
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
  lda PlayerCellX              ; $8AFC
  jsr AslA4                    ; $8AFF
  ora PlayerCellY              ; $8B02
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
  cmp PlayerFacing             ; $8B1A
  beq Loc_B4_8B23              ; $8B1D
  iny                          ; $8B1F
  jmp Loc_B4_8B09              ; $8B20
Loc_B4_8B23:
  jsr AllocObjectSlot          ; $8B23
  lda ($64),y                  ; $8B26
  ldy #$00                     ; $8B28
  sta (Tmp00),y                ; $8B2A
  rts                          ; $8B2C
InitAllObjectAnims:
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
  jmp RemoveObject             ; $8B57
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
RequestTransitionFromTable:
  sta $0503                    ; $8BC9
  sty z:$7C                    ; $8BCC
  ldy #$03                     ; $8BCE
Loc_B4_8BD0:
  lda Data_B4_8BE0,x           ; $8BD0
  sta a:TransitionPending,y    ; $8BD3
  dex                          ; $8BD6
  dey                          ; $8BD7
  bne Loc_B4_8BD0              ; $8BD8
  sty z:PaletteDirty           ; $8BDA
  iny                          ; $8BDC
  sty z:TransitionPending      ; $8BDD
  rts                          ; $8BDF
Data_B4_8BE0:
  .incbin "prg_bank_4.bin", $0BE0, $1B  ; $8BE0
CheckLowLifeSound:
  lda z:PlayerLifeLo           ; $8BFB
  cmp #$32                     ; $8BFD
  ldx z:$8B                    ; $8BFF
  bcs Loc_B4_8C0C              ; $8C01
  bne Loc_B4_8C17              ; $8C03
  lda #$42                     ; $8C05
  sta z:$8B                    ; $8C07
  jmp QueueSound               ; $8C09
Loc_B4_8C0C:
  beq Loc_B4_8C17              ; $8C0C
  lda #$00                     ; $8C0E
  sta z:$8B                    ; $8C10
  lda #$44                     ; $8C12
  jmp QueueSound               ; $8C14
Loc_B4_8C17:
  rts                          ; $8C17
ChangeMazeSection:
  jsr DispatchMazeExit         ; $8C18
  jmp LoadMazeData             ; $8C1B
DispatchMazeExit:
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
  .incbin "prg_bank_4.bin", $0C30, $2C  ; $8C30
MazeExit1:
  lda #$05                     ; $8C5C
  sta PlayerCellX              ; $8C5E
  lda #$00                     ; $8C61
  sta PlayerCellY              ; $8C63
  lda #$02                     ; $8C66
  jmp Loc_B4_8D0C              ; $8C68
MazeExit2:
  lda #$04                     ; $8C6B
  sta PlayerCellX              ; $8C6D
  sta PlayerCellY              ; $8C70
  lda #$00                     ; $8C73
  jmp Loc_B4_8D0C              ; $8C75
  .incbin "prg_bank_4.bin", $0C78, $E  ; $8C78
MazeExit3:
  lda #$04                     ; $8C86
  jmp Loc_B4_8D0C              ; $8C88
  .incbin "prg_bank_4.bin", $0C8B, $5  ; $8C8B
MazeExit4:
  lda #$01                     ; $8C90
  jmp Loc_B4_8D0C              ; $8C92
MazeExit5:
  lda #$07                     ; $8C95
  jmp Loc_B4_8D0C              ; $8C97
MazeExit6:
  lda #$06                     ; $8C9A
  jmp Loc_B4_8D0C              ; $8C9C
MazeExit7:
  lda #$08                     ; $8C9F
  jmp Loc_B4_8D0C              ; $8CA1
  .incbin "prg_bank_4.bin", $0CA4, $1E  ; $8CA4
MazeExitToStreetA:
  lda #$00                     ; $8CC2
  ldx #$17                     ; $8CC4
  ldy #$00                     ; $8CC6
  jmp RequestTransitionFromTable ; $8CC8
MazeExit8:
  lda #$00                     ; $8CCB
  sta PlayerCellX              ; $8CCD
  dec PlayerCellY              ; $8CD0
  lda #$0F                     ; $8CD3
  jmp Loc_B4_8D0C              ; $8CD5
MazeExitToStreetB:
  lda #$00                     ; $8CD8
  ldx #$1A                     ; $8CDA
  ldy #$00                     ; $8CDC
  jmp RequestTransitionFromTable ; $8CDE
MazeExit9:
  lda #$02                     ; $8CE1
  sta PlayerCellX              ; $8CE3
  inc PlayerCellY              ; $8CE6
  lda #$0D                     ; $8CE9
  jmp Loc_B4_8D0C              ; $8CEB
  lda #$02                     ; $8CEE  [heuristic code]
  sta PlayerCellX              ; $8CF0
  lda #$03                     ; $8CF3
  sta PlayerCellY              ; $8CF5
  lda #$11                     ; $8CF8
  jmp Loc_B4_8D0C              ; $8CFA
  lda #$03                     ; $8CFD  [heuristic code]
  sta PlayerCellX              ; $8CFF
  lda #$05                     ; $8D02
  sta PlayerCellY              ; $8D04
  lda #$0F                     ; $8D07
  jmp Loc_B4_8D0C              ; $8D09
Loc_B4_8D0C:
  sta MazeIndex                ; $8D0C
  lda PlayerFacing             ; $8D0F
  clc                          ; $8D12
  adc #$02                     ; $8D13
  and #$03                     ; $8D15
  sta PlayerFacing             ; $8D17
  rts                          ; $8D1A
Loc_B4_8D1B:
  ldx #$08                     ; $8D1B
Loc_B4_8D1D:
  lda z:$72,x                  ; $8D1D
  sta z:$73,x                  ; $8D1F
  dex                          ; $8D21
  bpl Loc_B4_8D1D              ; $8D22
  rts                          ; $8D24
HandleActionButtonInMaze:
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
  lda CollectedCount           ; $8D8E
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
  dec CollectedCount           ; $8DAF
  jmp Loc_B4_9FF7              ; $8DB2
Loc_B4_8DB5:
  lda JoyNew1                  ; $8DB5
  lsr a                        ; $8DB8
  bcs Loc_B4_8DC1              ; $8DB9
  lsr a                        ; $8DBB
  bcc Loc_B4_8DDF              ; $8DBC
  jmp HideCursorSprites        ; $8DBE
Loc_B4_8DC1:
  lda #$0E                     ; $8DC1
  jsr QueueSound               ; $8DC3
  jsr HideCursorSprites        ; $8DC6
  ldy ObjectCount              ; $8DC9
  beq Loc_B4_8DD6              ; $8DCC
Loc_B4_8DCE:
  jsr DispatchPickupHandler    ; $8DCE
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
HideCursorSprites:
  lda #$00                     ; $8E06
  sta z:$6F                    ; $8E08
  lda #$F0                     ; $8E0A
  sta $0204                    ; $8E0C
  sta $0208                    ; $8E0F
  rts                          ; $8E12
DispatchPickupHandler:
  tya                          ; $8E13
  beq Bank4StateC_00           ; $8E14
  jsr AslA4                    ; $8E16
  tax                          ; $8E19
  stx z:$6B                    ; $8E1A
  lda $0309,x                  ; $8E1C
  asl a                        ; $8E1F
  bpl Bank4StateC_00           ; $8E20
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
  .addr Bank4StateC_00, Bank4StateC_01, Bank4StateC_02, Bank4StateC_02, Bank4StateC_02, Bank4StateC_00, Bank4StateC_06, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_0A, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_11, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00, Bank4StateC_00  ; $8E36 pointer table
Bank4StateC_00:
  clc                          ; $8E90
  rts                          ; $8E91
Bank4StateC_01:
  ldx z:$6B                    ; $8E92
  lda ObjectLoopIndex,x        ; $8E94
  cmp $0207                    ; $8E97
  bne Bank4StateC_00           ; $8E9A
Bank4StateC_02:
  ldx z:$6B                    ; $8E9C
  lda $0309,x                  ; $8E9E
  ora #$80                     ; $8EA1
  sta $0309,x                  ; $8EA3
  sec                          ; $8EA6
  rts                          ; $8EA7
Bank4StateC_06:
  ldx z:$6B                    ; $8EA8
  lda ObjectCount,x            ; $8EAA
  cmp #$44                     ; $8EAD
  bcc Bank4StateC_00           ; $8EAF
  jmp Bank4StateC_01           ; $8EB1
Bank4StateC_0A:
  ldx z:$6B                    ; $8EB4
  lda $0305,x                  ; $8EB6
  beq Bank4StateC_01           ; $8EB9
  jmp Bank4StateC_00           ; $8EBB
Bank4StateC_11:
  ldx z:$6B                    ; $8EBE
  lda ObjectLoopIndex,x        ; $8EC0
  cmp $0207                    ; $8EC3
  bne Bank4StateC_00           ; $8EC6
  jmp Bank4StateC_02           ; $8EC8
StartPaletteFade:
  sta z:$60                    ; $8ECB
  asl a                        ; $8ECD
  adc z:$60                    ; $8ECE
  tax                          ; $8ED0
  ldy #$14                     ; $8ED1
  jsr CopyPaletteEntryFromTable ; $8ED3
  ldy z:$60                    ; $8ED6
  ldx Data_B4_8F53,y           ; $8ED8
  ldy #$18                     ; $8EDB
CopyPaletteEntryFromTable:
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
  .incbin "prg_bank_4.bin", $0F53, $1E  ; $8F53
SetObjectFrame:
  ldy #$05                     ; $8F71
  sta (Tmp00),y                ; $8F73
  asl a                        ; $8F75
  tax                          ; $8F76
  ldy #$00                     ; $8F77
  lda (Tmp00),y                ; $8F79
  and #$3F                     ; $8F7B
  asl a                        ; $8F7D
  tay                          ; $8F7E
  lda Data_B4_B580,y           ; $8F7F
  sta z:$60                    ; $8F82
  lda Data_B4_B581,y           ; $8F84
  sta z:$61                    ; $8F87
  txa                          ; $8F89
  tay                          ; $8F8A
  lda ($60),y                  ; $8F8B
  sta z:$62                    ; $8F8D
  iny                          ; $8F8F
  lda ($60),y                  ; $8F90
  sta z:$63                    ; $8F92
  ldy #$00                     ; $8F94
  lda ($62),y                  ; $8F96
  ldy #$04                     ; $8F98
  sta (Tmp00),y                ; $8F9A
  asl a                        ; $8F9C
  asl a                        ; $8F9D
  dey                          ; $8F9E
  clc                          ; $8F9F
  adc (Tmp00),y                ; $8FA0
  bcc Loc_B4_8FAA              ; $8FA2
  lda #$00                     ; $8FA4
  sta (Tmp00),y                ; $8FA6
  ldx #$10                     ; $8FA8
Loc_B4_8FAA:
  rts                          ; $8FAA
AllocObjectSlot:
  inc ObjectCount              ; $8FAB
  lda ObjectCount              ; $8FAE
  jsr AslA4                    ; $8FB1
  sta z:Tmp00                  ; $8FB4
  lda #$03                     ; $8FB6
  sta z:Tmp01                  ; $8FB8
  rts                          ; $8FBA
AdvanceObjectState:
  ldy #$08                     ; $8FBB
IncObjectField:
  lda (Tmp00),y                ; $8FBD
  clc                          ; $8FBF
  adc #$01                     ; $8FC0
  sta (Tmp00),y                ; $8FC2
  rts                          ; $8FC4
DecObjectField:
  lda (Tmp00),y                ; $8FC5
  sec                          ; $8FC7
  sbc #$01                     ; $8FC8
  sta (Tmp00),y                ; $8FCA
  rts                          ; $8FCC
ClearNametableRowAt054A:
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
  lda PpuBufAddrHi             ; $8FE3
  and #$23                     ; $8FE6
  sta PPU_ADDR                 ; $8FE8
  lda PpuBufAddrLo             ; $8FEB
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
ClearNametable2Rows:
  lda z:PpuCtrlShadow          ; $9006
  and #$FD                     ; $9008
  jsr SetPpuCtrl               ; $900A
  lda #$28                     ; $900D
  sta PpuBufAddrHi             ; $900F
  lda #$10                     ; $9012
  sta $058E                    ; $9014
  lda #$00                     ; $9017
  sta PpuBufAddrLo             ; $9019
  sta $054C                    ; $901C
Loc_B4_901F:
  ldy #$40                     ; $901F
  jsr ClearNametableRowAt054A  ; $9021
  jsr ProcessPpuUpdateList     ; $9024
  .incbin "prg_bank_4.bin", $1027, $2  ; $9027
  lda PpuBufAddrLo             ; $9029
  clc                          ; $902C
  adc #$40                     ; $902D
  sta PpuBufAddrLo             ; $902F
  lda PpuBufAddrHi             ; $9032
  adc #$00                     ; $9035
  sta PpuBufAddrHi             ; $9037
  dec $058E                    ; $903A
  bne Loc_B4_901F              ; $903D
  rts                          ; $903F
  .incbin "prg_bank_4.bin", $1040, $9  ; $9040
DispatchPpuOpRequest:
  lda PpuOpRequest             ; $9049
  ldx #$00                     ; $904C
  stx PpuOpRequest             ; $904E
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
PpuOpNone:
  rts                          ; $9070
PpuOpClearRow:
  jsr ClearNametableRowAt054A  ; $9071
PpuListThunkSource:
  jsr ProcessPpuUpdateList     ; $9074
  .incbin "prg_bank_4.bin", $1077, $2  ; $9077
  rts                          ; $9079
  .incbin "prg_bank_4.bin", $107A, $24  ; $907A
CopyPpuListStubToRam:
  ldx #$05                     ; $909E
Loc_B4_90A0:
  lda PpuListThunkSource,x     ; $90A0
  sta $0520,x                  ; $90A3
  dex                          ; $90A6
  bpl Loc_B4_90A0              ; $90A7
  rts                          ; $90A9
PpuOpRunList:
  jsr ProcessPpuUpdateList     ; $90AA
  .incbin "prg_bank_4.bin", $10AD, $2  ; $90AD
  rts                          ; $90AF
  .incbin "prg_bank_4.bin", $10B0, $7  ; $90B0
EnableSpriteBgRendering:
  lda z:PpuMaskShadow          ; $90B7
  ora #$18                     ; $90B9
  jmp SetPpuMask               ; $90BB
DisableSpriteBgRendering:
  lda z:PpuMaskShadow          ; $90BE
  and #$E7                     ; $90C0
  jmp SetPpuMask               ; $90C2
RandomByteMixed:
  inc z:$85                    ; $90C5
  beq RandomByteMixed          ; $90C7
  jsr GetRandomByte            ; $90C9
  adc z:$85                    ; $90CC
  rts                          ; $90CE
Sub_B4_90CF:
  stx z:$86                    ; $90CF
  jsr RandomByteMixed          ; $90D1
  ldx z:$86                    ; $90D4
  adc z:$0A                    ; $90D6
  rts                          ; $90D8
HideSpritesWithTileFE:
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
LoadObjectSpeedFromType:
  ldy #$00                     ; $90EE
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
InitMazePosition:
  ldx MazeIndex                ; $915B
  cpx #$12                     ; $915E
  bcc Loc_B4_916C              ; $9160
  lda #$00                     ; $9162
  sta z:MmcPrgShadow           ; $9164
  sta z:GameState              ; $9166
  sta $0503                    ; $9168
  rts                          ; $916B
Loc_B4_916C:
  lda Data_B4_9195,x           ; $916C
  sta PlayerCellX              ; $916F
  lda Data_B4_91A7,x           ; $9172
  sta PlayerCellY              ; $9175
  lda Data_B4_91B9,x           ; $9178
  sta PlayerFacing             ; $917B
LoadMazeData:
  lda MazeIndex                ; $917E
  asl a                        ; $9181
  asl a                        ; $9182
  tax                          ; $9183
  ldy #$00                     ; $9184
Loc_B4_9186:
  lda Data_B4_91CB,x           ; $9186
  sta MazeMapPtrLo,y           ; $9189
  inx                          ; $918C
  iny                          ; $918D
  cpy #$04                     ; $918E
  bne Loc_B4_9186              ; $9190
  jmp InitMazePalette          ; $9192
Data_B4_9195:
  .incbin "prg_bank_4.bin", $1195, $12  ; $9195
Data_B4_91A7:
  .incbin "prg_bank_4.bin", $11A7, $12  ; $91A7
Data_B4_91B9:
  .incbin "prg_bank_4.bin", $11B9, $12  ; $91B9
Data_B4_91CB:
  .incbin "prg_bank_4.bin", $11CB, $3A0  ; $91CB
InitPaletteBuffer:
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
InitMazePalette:
  jsr InitPaletteBuffer        ; $9589
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
  ldy MazeIndex                ; $95A3
  ldx Data_B4_95E0,y           ; $95A6
  stx z:$87                    ; $95A9
  jsr SetFadeParamsFromTable   ; $95AB
  lda MazeItemFullRestore      ; $95AE
  beq RequestPaletteUpdate     ; $95B1
  lda #$0F                     ; $95B3
  sta $0532                    ; $95B5
  lda #$00                     ; $95B8
  sta $0533                    ; $95BA
  lda #$10                     ; $95BD
  sta $0534                    ; $95BF
RequestPaletteUpdate:
  lda #$05                     ; $95C2
  sta PpuOpRequest             ; $95C4
  rts                          ; $95C7
SetFadeParamsFromTable:
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
ReadMazeInput:
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
  lda PlayerFacing             ; $9633
  clc                          ; $9636
  adc #$01                     ; $9637
  and #$03                     ; $9639
  sta PlayerFacing             ; $963B
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
  lda PlayerFacing             ; $964E
  sec                          ; $9651
  sbc #$01                     ; $9652
  and #$03                     ; $9654
  sta PlayerFacing             ; $9656
  ldx #$01                     ; $9659
  stx z:$7C                    ; $965B
  stx z:$72                    ; $965D
Loc_B4_965F:
  rts                          ; $965F
Loc_B4_9660:
  lda z:$71                    ; $9660
  and #$20                     ; $9662
  bne Loc_B4_9679              ; $9664
  lda PlayerFacing             ; $9666
  clc                          ; $9669
  adc #$02                     ; $966A
  and #$03                     ; $966C
  sta PlayerFacing             ; $966E
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
  jmp LookupMazeCellInfo       ; $968C
Loc_B4_968F:
  ldx PlayerFacing             ; $968F
  beq Loc_B4_96A8              ; $9692
  dex                          ; $9694
  beq Loc_B4_96B6              ; $9695
  dex                          ; $9697
  beq Loc_B4_96C7              ; $9698
  lda PlayerCellX              ; $969A
  beq Loc_B4_96DE              ; $969D
  sec                          ; $969F
  sbc #$01                     ; $96A0
  sta PlayerCellX              ; $96A2
  jmp Loc_B4_96D5              ; $96A5
Loc_B4_96A8:
  lda PlayerCellY              ; $96A8
  beq Loc_B4_96DE              ; $96AB
  sec                          ; $96AD
  sbc #$01                     ; $96AE
  sta PlayerCellY              ; $96B0
  jmp Loc_B4_96D5              ; $96B3
Loc_B4_96B6:
  lda PlayerCellX              ; $96B6
  clc                          ; $96B9
  adc #$01                     ; $96BA
  cmp MazeWidth                ; $96BC
  beq Loc_B4_96DE              ; $96BF
  sta PlayerCellX              ; $96C1
  jmp Loc_B4_96D5              ; $96C4
Loc_B4_96C7:
  lda PlayerCellY              ; $96C7
  clc                          ; $96CA
  adc #$01                     ; $96CB
  cmp $0517                    ; $96CD
  beq Loc_B4_96DE              ; $96D0
  sta PlayerCellY              ; $96D2
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
LookupMazeCellInfo:
  lda MazeIndex                ; $96EA
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
  lda PlayerCellX              ; $970D
  jsr AslA4                    ; $9710
  ora PlayerCellY              ; $9713
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
  ldy PlayerFacing             ; $9726
  iny                          ; $9729
  jmp Loc_B4_973B              ; $972A
Loc_B4_972D:
  lda ($62),y                  ; $972D
  cmp PlayerFacing             ; $972F
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
DrawCorridorView:
  jsr CalcPlayerCellIndex      ; $9868
  jsr CalcFacingCellOffsets    ; $986B
  lda z:$8F                    ; $986E
  ldx #$00                     ; $9870
  jsr StoreCellRow             ; $9872
  lda z:$8F                    ; $9875
  clc                          ; $9877
  adc z:Tmp01                  ; $9878
  jsr StoreCellRow             ; $987A
  lda z:$8F                    ; $987D
  sec                          ; $987F
  sbc z:Tmp01                  ; $9880
  jsr StoreCellRow             ; $9882
  jsr LoadCellWalls            ; $9885
  jsr UnpackWallBits           ; $9888
  jmp Loc_B4_9954              ; $988B
CalcPlayerCellIndex:
  lda #$00                     ; $988E
  ldx PlayerCellY              ; $9890
  beq Loc_B4_989C              ; $9893
Loc_B4_9895:
  clc                          ; $9895
  adc MazeWidth                ; $9896
  dex                          ; $9899
  bne Loc_B4_9895              ; $989A
Loc_B4_989C:
  clc                          ; $989C
  adc PlayerCellX              ; $989D
  sta z:$8F                    ; $98A0
  rts                          ; $98A2
CalcFacingCellOffsets:
  lda MazeWidth                ; $98A3
  ldx PlayerFacing             ; $98A6
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
StoreCellRow:
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
LoadCellWalls:
  ldx #$0B                     ; $990C
  lda MazeMapPtrLo             ; $990E
  sta z:$60                    ; $9911
  lda MazeMapPtrHi             ; $9913
  sta z:$61                    ; $9916
Loc_B4_9918:
  ldy z:$8F,x                  ; $9918
  lda ($60),y                  ; $991A
  sta z:$8F,x                  ; $991C
  dex                          ; $991E
  bpl Loc_B4_9918              ; $991F
  rts                          ; $9921
UnpackWallBits:
  ldx #$03                     ; $9922
Loc_B4_9924:
  lda z:$8F,x                  ; $9924
  ldy z:$8D                    ; $9926
  jsr ExtractBitPair           ; $9928
  sta z:$9B,x                  ; $992B
  lda z:$8F,x                  ; $992D
  ldy z:$8C                    ; $992F
  jsr ExtractBitPair           ; $9931
  sta z:$9F,x                  ; $9934
  lda z:$8F,x                  ; $9936
  ldy z:$8E                    ; $9938
  jsr ExtractBitPair           ; $993A
  sta z:$A3,x                  ; $993D
  dex                          ; $993F
  bpl Loc_B4_9924              ; $9940
  rts                          ; $9942
ExtractBitPair:
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
  jsr ExtractBitPair           ; $995A
  sta z:$A7,x                  ; $995D
  dex                          ; $995F
  bpl Loc_B4_9956              ; $9960
  rts                          ; $9962
DrawMazeScreen:
  jsr DrawRleScreen            ; $9963
  jsr DrawMazeWallsList        ; $9966
  jsr DrawWallSegments         ; $9969
  jsr Sub_B4_9F2F              ; $996C
  jsr RunSoundDriver           ; $996F
  jmp RunSoundDriver           ; $9972
DrawRleScreen:
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
DrawMazeWallsList:
  jsr ProcessPpuUpdateList     ; $9A2C
  .addr Data_B4_9A32  ; $9A2F inline pointer (data after a JSR)
  rts                          ; $9A31
Data_B4_9A32:
  .incbin "prg_bank_4.bin", $1A32, $41  ; $9A32
DrawWallSegments:
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
  sta PpuStubTargetLo          ; $9A88
  lda Data_B4_9B0E,x           ; $9A8B
  sta PpuStubTargetHi          ; $9A8E
  jsr $0520                    ; $9A91
  lda z:$6A                    ; $9A94
  cmp #$03                     ; $9A96
  bne Loc_B4_9ACE              ; $9A98
  lda z:$6C                    ; $9A9A
  asl a                        ; $9A9C
  tax                          ; $9A9D
  lda Data_B4_9B35,x           ; $9A9E
  sta PpuStubTargetLo          ; $9AA1
  lda Data_B4_9B36,x           ; $9AA4
  sta PpuStubTargetHi          ; $9AA7
  jsr $0520                    ; $9AAA
  ldy z:$6C                    ; $9AAD
  lda Data_B4_9B5D,y           ; $9AAF
  bmi Loc_B4_9ACE              ; $9AB2
  sta z:$60                    ; $9AB4
  lda PlayerFacing             ; $9AB6
  and #$02                     ; $9AB9
  clc                          ; $9ABB
  adc z:$60                    ; $9ABC
  tax                          ; $9ABE
  lda Data_B4_9B71,x           ; $9ABF
  sta PpuStubTargetLo          ; $9AC2
  lda Data_B4_9B72,x           ; $9AC5
  sta PpuStubTargetHi          ; $9AC8
  jsr $0520                    ; $9ACB
Loc_B4_9ACE:
  inc z:$6C                    ; $9ACE
  ldy z:$6C                    ; $9AD0
  cpy #$14                     ; $9AD2
  bcc Loc_B4_9A77              ; $9AD4
  lda z:$9B                    ; $9AD6
  cmp #$03                     ; $9AD8
  bne Loc_B4_9AE8              ; $9ADA
  lda PlayerFacing             ; $9ADC
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
CopyThunkToRamAndCall800A:
  ldx #$0A                     ; $9F7C
Loc_B4_9F7E:
  lda Data_B4_9F89,x           ; $9F7E
  sta z:Tmp00,x                ; $9F81
  dex                          ; $9F83
  bpl Loc_B4_9F7E              ; $9F84
  jmp a:Tmp00                  ; $9F86
Data_B4_9F89:
  .incbin "prg_bank_4.bin", $1F89, $B  ; $9F89
DrawCollectedCountIcons:
  lda CollectedCount           ; $9F94
  and #$03                     ; $9F97
  sta CollectedCount           ; $9F99
  bne Loc_B4_9F9F              ; $9F9C
  rts                          ; $9F9E
Loc_B4_9F9F:
  tax                          ; $9F9F
  dex                          ; $9FA0
  beq Loc_B4_9FB6              ; $9FA1
  dex                          ; $9FA3
  beq Loc_B4_9FAE              ; $9FA4
  ldy #$46                     ; $9FA6
  jsr SetupIconPpuBuffer       ; $9FA8
  jsr PpuListThunkSource       ; $9FAB
Loc_B4_9FAE:
  ldy #$44                     ; $9FAE
  jsr SetupIconPpuBuffer       ; $9FB0
  jsr PpuListThunkSource       ; $9FB3
Loc_B4_9FB6:
  ldy #$42                     ; $9FB6
  jsr SetupIconPpuBuffer       ; $9FB8
  jmp PpuListThunkSource       ; $9FBB
AddCollectedCountIcon:
  lda CollectedCount           ; $9FBE
  and #$03                     ; $9FC1
  beq Loc_B4_9FD2              ; $9FC3
  tax                          ; $9FC5
  dex                          ; $9FC6
  ldy Data_B4_9FE9,x           ; $9FC7
  jsr SetupIconPpuBuffer       ; $9FCA
  lda #$01                     ; $9FCD
  sta PpuOpRequest             ; $9FCF
Loc_B4_9FD2:
  rts                          ; $9FD2
SetupIconPpuBuffer:
  ldx #$0A                     ; $9FD3
Loc_B4_9FD5:
  lda Data_B4_9FEC,x           ; $9FD5
  sta PpuBufAddrHi,x           ; $9FD8
  dex                          ; $9FDB
  bpl Loc_B4_9FD5              ; $9FDC
  tya                          ; $9FDE
  sta PpuBufAddrLo             ; $9FDF
  clc                          ; $9FE2
  adc #$20                     ; $9FE3
  sta $0550                    ; $9FE5
  rts                          ; $9FE8
Data_B4_9FE9:
  .incbin "prg_bank_4.bin", $1FE9, $3  ; $9FE9
Data_B4_9FEC:
  .incbin "prg_bank_4.bin", $1FEC, $B  ; $9FEC
Loc_B4_9FF7:
  lda CollectedCount           ; $9FF7
  and #$03                     ; $9FFA
  cmp #$03                     ; $9FFC
  beq Loc_B4_A01A              ; $9FFE
SetupIconPpuBufferForIndex:
  tax                          ; $A000
  ldy Data_B4_9FE9,x           ; $A001
  jsr SetupIconPpuBuffer       ; $A004
  lda #$01                     ; $A007
  sta PpuOpRequest             ; $A009
  lda #$00                     ; $A00C
  sta $054D                    ; $A00E
  sta $054E                    ; $A011
  sta $0552                    ; $A014
  sta $0553                    ; $A017
Loc_B4_A01A:
  rts                          ; $A01A
DrawCollectedItemIcons:
  lda $050C                    ; $A01B
  beq Loc_B4_A026              ; $A01E
  jsr SelectPpuListA           ; $A020
  jsr $0520                    ; $A023
Loc_B4_A026:
  lda $050B                    ; $A026
  beq Loc_B4_A031              ; $A029
  jsr SelectPpuListB           ; $A02B
  jsr $0520                    ; $A02E
Loc_B4_A031:
  lda $050A                    ; $A031
  beq Loc_B4_A03C              ; $A034
  jsr SelectPpuListC           ; $A036
  jsr $0520                    ; $A039
Loc_B4_A03C:
  lda MazeItemFullRestore      ; $A03C
  beq Loc_B4_A047              ; $A03F
  jsr SelectPpuListD           ; $A041
  jsr $0520                    ; $A044
Loc_B4_A047:
  rts                          ; $A047
RequestPpuListA:
  lda #$04                     ; $A048
  sta PpuOpRequest             ; $A04A
SelectPpuListA:
  lda #$58                     ; $A04D
  sta PpuStubTargetLo          ; $A04F
  lda #$A0                     ; $A052
  sta PpuStubTargetHi          ; $A054
  rts                          ; $A057
  .incbin "prg_bank_4.bin", $2058, $B  ; $A058
RequestPpuListB:
  lda #$04                     ; $A063
  sta PpuOpRequest             ; $A065
SelectPpuListB:
  lda #$73                     ; $A068
  sta PpuStubTargetLo          ; $A06A
  lda #$A0                     ; $A06D
  sta PpuStubTargetHi          ; $A06F
  rts                          ; $A072
  .incbin "prg_bank_4.bin", $2073, $B  ; $A073
RequestPpuListC:
  lda #$04                     ; $A07E
  sta PpuOpRequest             ; $A080
SelectPpuListC:
  lda #$8E                     ; $A083
  sta PpuStubTargetLo          ; $A085
  lda #$A0                     ; $A088
  sta PpuStubTargetHi          ; $A08A
  rts                          ; $A08D
  .incbin "prg_bank_4.bin", $208E, $B  ; $A08E
RequestPpuListD:
  lda #$04                     ; $A099
  sta PpuOpRequest             ; $A09B
SelectPpuListD:
  lda #$A9                     ; $A09E
  sta PpuStubTargetLo          ; $A0A0
  lda #$A0                     ; $A0A3
  sta PpuStubTargetHi          ; $A0A5
  rts                          ; $A0A8
  .incbin "prg_bank_4.bin", $20A9, $17  ; $A0A9
RequestPpuListE:
  lda #$04                     ; $A0C0
  sta PpuOpRequest             ; $A0C2
  lda #$D0                     ; $A0C5
  sta PpuStubTargetLo          ; $A0C7
  lda #$A0                     ; $A0CA
  sta PpuStubTargetHi          ; $A0CC
  rts                          ; $A0CF
  .incbin "prg_bank_4.bin", $20D0, $9  ; $A0D0
SpawnDoorObjectsIfAhead:
  lda z:$9B                    ; $A0D9
  cmp #$02                     ; $A0DB
  beq Loc_B4_A0E4              ; $A0DD
  lda #$00                     ; $A0DF
  sta z:$83                    ; $A0E1
  rts                          ; $A0E3
Loc_B4_A0E4:
  jsr LookupMazeCellInfo       ; $A0E4
  ldx z:$82                    ; $A0E7
  lda Data_B4_A0FE,x           ; $A0E9
  sta z:$83                    ; $A0EC
  lsr a                        ; $A0EE
  bcc Loc_B4_A0F4              ; $A0EF
  jsr SpawnDoorObjectLeft      ; $A0F1
Loc_B4_A0F4:
  lda z:$83                    ; $A0F4
  and #$02                     ; $A0F6
  beq Loc_B4_A0FD              ; $A0F8
  jmp Loc_B4_A144              ; $A0FA
Loc_B4_A0FD:
  rts                          ; $A0FD
Data_B4_A0FE:
  .incbin "prg_bank_4.bin", $20FE, $16  ; $A0FE
SpawnDoorObjectLeft:
  jsr ProcessPpuUpdateList     ; $A114
  .addr Data_B4_A123  ; $A117 inline pointer (data after a JSR)
  jsr AllocObjectSlot          ; $A119
  lda #$D4                     ; $A11C
  ldy #$00                     ; $A11E
  sta (Tmp00),y                ; $A120
  rts                          ; $A122
Data_B4_A123:
  .incbin "prg_bank_4.bin", $2123, $21  ; $A123
Loc_B4_A144:
  jsr ProcessPpuUpdateList     ; $A144
  .addr Data_B4_A153  ; $A147 inline pointer (data after a JSR)
  jsr AllocObjectSlot          ; $A149
  lda #$D5                     ; $A14C
  ldy #$00                     ; $A14E
  sta (Tmp00),y                ; $A150
  rts                          ; $A152
Data_B4_A153:
  .incbin "prg_bank_4.bin", $2153, $C  ; $A153
CopyThunkToRamAndCall800D:
  ldx #$0A                     ; $A15F
Loc_B4_A161:
  lda Data_B4_A16C,x           ; $A161
  sta z:Tmp00,x                ; $A164
  dex                          ; $A166
  bpl Loc_B4_A161              ; $A167
  jmp a:Tmp00                  ; $A169
Data_B4_A16C:
  .incbin "prg_bank_4.bin", $216C, $9E  ; $A16C
MazeObjType11State7:
  jsr Sub_B4_B3C7              ; $A20A
  ldy #$0B                     ; $A20D
  jsr IncObjectField           ; $A20F
  cmp #$10                     ; $A212
  beq Loc_B4_A21B              ; $A214
  cmp #$1F                     ; $A216
  beq Loc_B4_A223              ; $A218
  rts                          ; $A21A
Loc_B4_A21B:
  ldy #$05                     ; $A21B
  jsr IncObjectField           ; $A21D
  jmp SetObjectFrame           ; $A220
Loc_B4_A223:
  jmp RemoveObject             ; $A223
  .incbin "prg_bank_4.bin", $2226, $1C  ; $A226
MazeObjType02:
  ldy #$08                     ; $A242
  lda (Tmp00),y                ; $A244
  bne Loc_B4_A258              ; $A246
  lda #$19                     ; $A248
  jsr QueueSound               ; $A24A
  lda #$78                     ; $A24D
  jsr Sub_B4_B3C2              ; $A24F
  jsr Sub_B4_B415              ; $A252
  jmp Loc_B4_B38C              ; $A255
Loc_B4_A258:
  jsr AddObjectXVelocity       ; $A258
  dey                          ; $A25B
  jsr IncObjectField           ; $A25C
  cmp #$90                     ; $A25F
  bcc Loc_B4_A26B              ; $A261
  beq Loc_B4_A26C              ; $A263
  lda #$53                     ; $A265
  ldy #$00                     ; $A267
  sta (Tmp00),y                ; $A269
Loc_B4_A26B:
  rts                          ; $A26B
Loc_B4_A26C:
  lda #$1E                     ; $A26C
  jmp DamagePlayer             ; $A26E
UpdateDoorObject:
  ldy #$08                     ; $A271
  lda (Tmp00),y                ; $A273
  asl a                        ; $A275
  tax                          ; $A276
  lda Data_B4_A284,x           ; $A277
  sta z:$6D                    ; $A27A
  lda Data_B4_A285,x           ; $A27C
  sta z:$6E                    ; $A27F
  jmp ($006D)                  ; $A281
Data_B4_A284:
  .addr DoorState0, DoorState1, DoorState2, DoorState3, DoorState4, DoorState5, DoorState6  ; $A284 pointer table
  .incbin "prg_bank_4.bin", $2292, $2  ; $A292
DoorState0:
  lda z:PpuCtrlShadow          ; $A294
  and #$FB                     ; $A296
  ora #$02                     ; $A298
  sta z:PpuCtrlShadow          ; $A29A
  lda Data_B4_A373             ; $A29C
  ldx #$C0                     ; $A29F
  jsr Sub_B4_B3BC              ; $A2A1
  lda #$0F                     ; $A2A4
  ldy #$0B                     ; $A2A6
  sta (Tmp00),y                ; $A2A8
  lda z:$87                    ; $A2AA
  jmp Loc_B4_B389              ; $A2AC
DoorState1:
  ldy #$0B                     ; $A2AF
  jsr DecObjectField           ; $A2B1
  beq Loc_B4_A2B7              ; $A2B4
  rts                          ; $A2B6
Loc_B4_A2B7:
  lda #$18                     ; $A2B7
  jsr QueueSound               ; $A2B9
  jmp AdvanceObjectState       ; $A2BC
DoorState2:
  ldy #$0B                     ; $A2BF
  jsr IncObjectField           ; $A2C1
  cmp #$11                     ; $A2C4
  bcs Loc_B4_A2FA              ; $A2C6
  ldx #$00                     ; $A2C8
  stx PpuBufAddrHi             ; $A2CA
  jsr AslA4                    ; $A2CD
  rol PpuBufAddrHi             ; $A2D0
  asl a                        ; $A2D3
  rol PpuBufAddrHi             ; $A2D4
  clc                          ; $A2D7
  adc #$A4                     ; $A2D8
  sta PpuBufAddrLo             ; $A2DA
  lda PpuBufAddrHi             ; $A2DD
  adc #$28                     ; $A2E0
  sta PpuBufAddrHi             ; $A2E2
  lda #$58                     ; $A2E5
  sta $054C                    ; $A2E7
  lda #$03                     ; $A2EA
  sta $054D                    ; $A2EC
  lda #$FF                     ; $A2EF
  sta $054E                    ; $A2F1
  lda #$01                     ; $A2F4
  sta PpuOpRequest             ; $A2F6
  rts                          ; $A2F9
Loc_B4_A2FA:
  lda #$00                     ; $A2FA
  sta (Tmp00),y                ; $A2FC
  ldy #$0A                     ; $A2FE
  lda (Tmp00),y                ; $A300
  and #$9F                     ; $A302
  sta (Tmp00),y                ; $A304
  ldy #$09                     ; $A306
  lda (Tmp00),y                ; $A308
  ora #$20                     ; $A30A
  sta (Tmp00),y                ; $A30C
  jmp AdvanceObjectState       ; $A30E
DoorState3:
  ldy #$09                     ; $A311
  lda (Tmp00),y                ; $A313
  bpl Loc_B4_A327              ; $A315
  jsr Sub_B4_B3EE              ; $A317
  ldy #$00                     ; $A31A
  jsr SetObjectFlagsC0         ; $A31C
  lda #$24                     ; $A31F
  jsr QueueSound               ; $A321
  jmp AdvanceObjectState       ; $A324
Loc_B4_A327:
  rts                          ; $A327
DoorState4:
  ldy #$0B                     ; $A328
  jsr IncObjectField           ; $A32A
  cmp #$50                     ; $A32D
  bcs Loc_B4_A358              ; $A32F
  tax                          ; $A331
  lsr a                        ; $A332
  bcc Loc_B4_A339              ; $A333
  cmp #$18                     ; $A335
  bcs Loc_B4_A33E              ; $A337
Loc_B4_A339:
  ldy #$02                     ; $A339
  jsr DecObjectField           ; $A33B
Loc_B4_A33E:
  txa                          ; $A33E
  lsr a                        ; $A33F
  tax                          ; $A340
  lda Data_B4_A373,x           ; $A341
  bcc Loc_B4_A34A              ; $A344
  adc Data_B4_A374,x           ; $A346
  ror a                        ; $A349
Loc_B4_A34A:
  ldy #$01                     ; $A34A
  sta (Tmp00),y                ; $A34C
  txa                          ; $A34E
  lsr a                        ; $A34F
  lsr a                        ; $A350
  tax                          ; $A351
  lda Data_B4_A369,x           ; $A352
  jmp SetObjectFrame           ; $A355
Loc_B4_A358:
  lda #$40                     ; $A358
  sta (Tmp00),y                ; $A35A
  lda #$00                     ; $A35C
  sta $054C                    ; $A35E
  lda #$45                     ; $A361
  jsr QueueSound               ; $A363
  jmp AdvanceObjectState       ; $A366
Data_B4_A369:
  .incbin "prg_bank_4.bin", $2369, $A  ; $A369
Data_B4_A373:
  .incbin "prg_bank_4.bin", $2373, $1  ; $A373
Data_B4_A374:
  .incbin "prg_bank_4.bin", $2374, $28  ; $A374
DoorState5:
  ldy #$0B                     ; $A39C
  jsr DecObjectField           ; $A39E
  bne Loc_B4_A3B7              ; $A3A1
  lda #$2F                     ; $A3A3
  ldx #$40                     ; $A3A5
  jsr Sub_B4_B3BC              ; $A3A7
  lda #$03                     ; $A3AA
  jsr SetObjectFrame           ; $A3AC
  lda #$25                     ; $A3AF
  jsr QueueSound               ; $A3B1
  jmp AdvanceObjectState       ; $A3B4
Loc_B4_A3B7:
  rts                          ; $A3B7
DoorState6:
  ldy #$0B                     ; $A3B8
  lda (Tmp00),y                ; $A3BA
  cmp #$FF                     ; $A3BC
  bne Loc_B4_A3D0              ; $A3BE
  ldy #$0A                     ; $A3C0
  lda (Tmp00),y                ; $A3C2
  and #$1F                     ; $A3C4
  sta (Tmp00),y                ; $A3C6
  lda #$0B                     ; $A3C8
  jsr SetObjectFrame           ; $A3CA
  jmp AdvanceObjectState       ; $A3CD
Loc_B4_A3D0:
  asl a                        ; $A3D0
  asl a                        ; $A3D1
  tax                          ; $A3D2
  lda Data_B4_A40F,x           ; $A3D3
  sta PpuBufAddrLo             ; $A3D6
  lda Data_B4_A410,x           ; $A3D9
  sta PpuBufAddrHi             ; $A3DC
  lda Data_B4_A411,x           ; $A3DF
  sta $054C                    ; $A3E2
  lda Data_B4_A412,x           ; $A3E5
  sta (Tmp00),y                ; $A3E8
  lda #$02                     ; $A3EA
  sta PpuOpRequest             ; $A3EC
  ldy #$0C                     ; $A3EF
  jsr IncObjectField           ; $A3F1
  tay                          ; $A3F4
  lda Data_B4_A3FB,y           ; $A3F5
  jmp SetObjectFrame           ; $A3F8
Data_B4_A3FB:
  .incbin "prg_bank_4.bin", $23FB, $13  ; $A3FB
Sub_B4_A40E:
  rts                          ; $A40E
Data_B4_A40F:
  .incbin "prg_bank_4.bin", $240F, $1  ; $A40F
Data_B4_A410:
  .incbin "prg_bank_4.bin", $2410, $1  ; $A410
Data_B4_A411:
  .incbin "prg_bank_4.bin", $2411, $1  ; $A411
Data_B4_A412:
  .incbin "prg_bank_4.bin", $2412, $45  ; $A412
MazeObjType04:
  ldy #$08                     ; $A457
  lda (Tmp00),y                ; $A459
  asl a                        ; $A45B
  tax                          ; $A45C
  lda Data_B4_A46A,x           ; $A45D
  sta z:$6D                    ; $A460
  lda Data_B4_A46B,x           ; $A462
  sta z:$6E                    ; $A465
  jmp ($006D)                  ; $A467
Data_B4_A46A:
  .addr MazeObjType04State0, WaitObjectTimer, CollectAmmoItem  ; $A46A pointer table
MazeObjType04State0:
  jsr Sub_B4_B3B2              ; $A470
  lda #$06                     ; $A473
  jmp Loc_B4_B389              ; $A475
WaitObjectTimer:
  ldy #$0B                     ; $A478
  jsr DecObjectField           ; $A47A
  beq Loc_B4_A480              ; $A47D
  rts                          ; $A47F
Loc_B4_A480:
  jmp AdvanceObjectState       ; $A480
CollectAmmoItem:
  lda JoyNew1                  ; $A483  [heuristic code]
  and #$01                     ; $A486
  beq Loc_B4_A49F              ; $A488
  ldy #$0C                     ; $A48A
  lda (Tmp00),y                ; $A48C
  ora $051B                    ; $A48E
  sta $051B                    ; $A491
  jsr RemoveObject             ; $A494
  lda #$90                     ; $A497
  sta z:AmmoLo                 ; $A499
  lda #$01                     ; $A49B
  sta z:AmmoHi                 ; $A49D
Loc_B4_A49F:
  rts                          ; $A49F
MazeObjType1C:
  lda #$01                     ; $A4A0
  bne Loc_B4_A4B1              ; $A4A2
MazeObjType1D:
  lda #$02                     ; $A4A4
  bne Loc_B4_A4B1              ; $A4A6
MazeObjType1E:
  lda #$04                     ; $A4A8
  bne Loc_B4_A4B1              ; $A4AA
MazeObjType1F:
  lda #$08                     ; $A4AC
  .incbin "prg_bank_4.bin", $24AE, $1  ; $A4AE
MazeObjType20:
  lda #$10                     ; $A4AF
Loc_B4_A4B1:
  bit $051B                    ; $A4B1
  beq Loc_B4_A4B9              ; $A4B4
  jmp RemoveObject             ; $A4B6
Loc_B4_A4B9:
  ldy #$0C                     ; $A4B9
  sta (Tmp00),y                ; $A4BB
  lda #$C4                     ; $A4BD
  ldy #$00                     ; $A4BF
  sta (Tmp00),y                ; $A4C1
  jmp MazeObjType04            ; $A4C3
MazeObjType0E:
  ldy #$08                     ; $A4C6
  lda (Tmp00),y                ; $A4C8
  asl a                        ; $A4CA
  tax                          ; $A4CB
  lda Data_B4_A4D9,x           ; $A4CC
  sta z:$6D                    ; $A4CF
  lda Data_B4_A4DA,x           ; $A4D1
  sta z:$6E                    ; $A4D4
  jmp ($006D)                  ; $A4D6
Data_B4_A4D9:
  .addr Sub_B4_A4DF, WaitObjectTimer, CollectLifeItem  ; $A4D9 pointer table
Sub_B4_A4DF:
  jsr Sub_B4_B3B2              ; $A4DF
  lda #$00                     ; $A4E2
  jmp Loc_B4_B389              ; $A4E4
CollectLifeItem:
  lda JoyNew1                  ; $A4E7  [heuristic code]
  and #$01                     ; $A4EA
  beq Loc_B4_A4FF              ; $A4EC
  ldy #$0C                     ; $A4EE
  lda (Tmp00),y                ; $A4F0
  ora $051D                    ; $A4F2
  sta $051D                    ; $A4F5
  jsr RemoveObject             ; $A4F8
  lda #$C8                     ; $A4FB
  sta z:PlayerLifeLo           ; $A4FD
Loc_B4_A4FF:
  rts                          ; $A4FF
MazeObjType21:
  lda #$01                     ; $A500
  bne Loc_B4_A511              ; $A502
MazeObjType22:
  lda #$02                     ; $A504
  bne Loc_B4_A511              ; $A506
MazeObjType23:
  lda #$04                     ; $A508
  bne Loc_B4_A511              ; $A50A
MazeObjType24:
  lda #$08                     ; $A50C
  .incbin "prg_bank_4.bin", $250E, $1  ; $A50E
MazeObjType25:
  lda #$10                     ; $A50F
Loc_B4_A511:
  bit $051D                    ; $A511
  beq Loc_B4_A519              ; $A514
  jmp RemoveObject             ; $A516
Loc_B4_A519:
  ldy #$0C                     ; $A519
  sta (Tmp00),y                ; $A51B
  lda #$CE                     ; $A51D
  ldy #$00                     ; $A51F
  sta (Tmp00),y                ; $A521
  jmp MazeObjType0E            ; $A523
MazeObjType05:
  ldy #$08                     ; $A526
  lda (Tmp00),y                ; $A528
  asl a                        ; $A52A
  tax                          ; $A52B
  lda Data_B4_A539,x           ; $A52C
  sta z:$6D                    ; $A52F
  lda Data_B4_A53A,x           ; $A531
  sta z:$6E                    ; $A534
  jmp ($006D)                  ; $A536
Data_B4_A539:
  .incbin "prg_bank_4.bin", $2539, $1  ; $A539
Data_B4_A53A:
  .incbin "prg_bank_4.bin", $253A, $17  ; $A53A
MazeObjType05State0:
  lda #$2B                     ; $A551
  sta z:$80                    ; $A553
  lda #$1B                     ; $A555
  jsr QueueSound               ; $A557
  jsr LoadObjectSpeedFromType  ; $A55A
MazeObjType05State1:
  jmp AdvanceObjectState       ; $A55D
MazeObjType05State2:
  ldy #$0B                     ; $A560
  lda (Tmp00),y                ; $A562
  cmp #$08                     ; $A564
  beq Loc_B4_A57F              ; $A566
  asl a                        ; $A568
  tax                          ; $A569
  jsr IncObjectField           ; $A56A
  lda Data_B4_A586,x           ; $A56D
  sta PpuStubTargetLo          ; $A570
  lda Data_B4_A587,x           ; $A573
  sta PpuStubTargetHi          ; $A576
  lda #$04                     ; $A579
  sta PpuOpRequest             ; $A57B
  rts                          ; $A57E
Loc_B4_A57F:
  lda #$00                     ; $A57F
  sta (Tmp00),y                ; $A581
  jmp AdvanceObjectState       ; $A583
Data_B4_A586:
  .incbin "prg_bank_4.bin", $2586, $1  ; $A586
Data_B4_A587:
  .incbin "prg_bank_4.bin", $2587, $37  ; $A587
MazeObjType05State3:
  lda #$28                     ; $A5BE
  sta PpuBufAddrHi             ; $A5C0
  lda #$00                     ; $A5C3
  sta PpuBufAddrLo             ; $A5C5
  lda #$60                     ; $A5C8
  sta $054C                    ; $A5CA
  lda #$01                     ; $A5CD
  sta $054D                    ; $A5CF
  lda #$FF                     ; $A5D2
  sta $054E                    ; $A5D4
  lda #$01                     ; $A5D7
  sta PpuOpRequest             ; $A5D9
  jmp AdvanceObjectState       ; $A5DC
MazeObjType05State4:
  ldy #$0B                     ; $A5DF
  jsr IncObjectField           ; $A5E1
  cmp #$18                     ; $A5E4
  bcs Loc_B4_A5FF              ; $A5E6
  lda PpuBufAddrLo             ; $A5E8
  clc                          ; $A5EB
  adc #$20                     ; $A5EC
  sta PpuBufAddrLo             ; $A5EE
  lda PpuBufAddrHi             ; $A5F1
  adc #$00                     ; $A5F4
  sta PpuBufAddrHi             ; $A5F6
  lda #$01                     ; $A5F9
  sta PpuOpRequest             ; $A5FB
  rts                          ; $A5FE
Loc_B4_A5FF:
  lda #$00                     ; $A5FF
  sta (Tmp00),y                ; $A601
  jmp AdvanceObjectState       ; $A603
MazeObjType05State5:
  ldy #$0B                     ; $A606
  jsr IncObjectField           ; $A608
  cmp #$09                     ; $A60B
  beq Loc_B4_A626              ; $A60D
  sec                          ; $A60F
  sbc #$01                     ; $A610
  asl a                        ; $A612
  tax                          ; $A613
  lda Data_B4_A633,x           ; $A614
  sta PpuStubTargetLo          ; $A617
  lda Data_B4_A634,x           ; $A61A
  sta PpuStubTargetHi          ; $A61D
  lda #$04                     ; $A620
  sta PpuOpRequest             ; $A622
  rts                          ; $A625
Loc_B4_A626:
  lda #$00                     ; $A626
  sta (Tmp00),y                ; $A628
  lda z:PpuCtrlShadow          ; $A62A
  and #$FB                     ; $A62C
  sta z:PpuCtrlShadow          ; $A62E
  jmp AdvanceObjectState       ; $A630
Data_B4_A633:
  .incbin "prg_bank_4.bin", $2633, $1  ; $A633
Data_B4_A634:
  .incbin "prg_bank_4.bin", $2634, $64  ; $A634
MazeObjType05State6:
  ldy #$0E                     ; $A698
  lda (Tmp00),y                ; $A69A
  clc                          ; $A69C
  adc z:HwScrollY              ; $A69D
  sta z:HwScrollY              ; $A69F
  cmp #$F0                     ; $A6A1
  bcs Loc_B4_A6BC              ; $A6A3
  ldy #$0D                     ; $A6A5
  lda (Tmp00),y                ; $A6A7
  adc #$40                     ; $A6A9
  sta (Tmp00),y                ; $A6AB
  ldy #$0E                     ; $A6AD
  lda (Tmp00),y                ; $A6AF
  adc #$00                     ; $A6B1
  cmp #$08                     ; $A6B3
  bcc Loc_B4_A6B9              ; $A6B5
  lda #$07                     ; $A6B7
Loc_B4_A6B9:
  sta (Tmp00),y                ; $A6B9
  rts                          ; $A6BB
Loc_B4_A6BC:
  lda z:PpuCtrlShadow          ; $A6BC
  ora #$02                     ; $A6BE
  sta z:PpuCtrlShadow          ; $A6C0
  lda #$23                     ; $A6C2
  sta z:$80                    ; $A6C4
  lda #$00                     ; $A6C6
  sta z:HwScrollY              ; $A6C8
  lda #$00                     ; $A6CA
  ldy #$0B                     ; $A6CC
  sta (Tmp00),y                ; $A6CE
  jmp AdvanceObjectState       ; $A6D0
MazeObjType05State7:
  jsr DisableSpriteBgRendering ; $A6D3
  lda #$05                     ; $A6D6
  sta PpuOpRequest             ; $A6D8
  jsr InitPaletteBuffer        ; $A6DB
  jsr DrawCompassSprites       ; $A6DE
  jmp AdvanceObjectState       ; $A6E1
MazeObjType05State8:
  jsr AdvanceObjectState       ; $A6E4
  jsr DispatchMazeSpecificEvent ; $A6E7
  jsr DrawCorridorView         ; $A6EA
  jsr DrawMazeScreen           ; $A6ED
  jsr DrawCollectedCountIcons  ; $A6F0
  jsr DrawCollectedItemIcons   ; $A6F3
  jsr ProcessPpuUpdateList     ; $A6F6
  .addr Data_B4_A6FE  ; $A6F9 inline pointer (data after a JSR)
  jmp ApplyScroll              ; $A6FB
Data_B4_A6FE:
  .incbin "prg_bank_4.bin", $26FE, $11  ; $A6FE
DispatchMazeSpecificEvent:
  lda MazeIndex                ; $A70F
  asl a                        ; $A712
  tax                          ; $A713
  lda Data_B4_A721,x           ; $A714
  sta z:$6D                    ; $A717
  lda Data_B4_A722,x           ; $A719
  sta z:$6E                    ; $A71C
  jmp ($006D)                  ; $A71E
Data_B4_A721:
  .incbin "prg_bank_4.bin", $2721, $1  ; $A721
Data_B4_A722:
  .incbin "prg_bank_4.bin", $2722, $23  ; $A722
WarpToMaze2:
  lda #$02                     ; $A745
  sta MazeIndex                ; $A747
  inc PlayerCellX              ; $A74A
  lda PlayerCellY              ; $A74D
  sec                          ; $A750
  sbc #$04                     ; $A751
  sta PlayerCellY              ; $A753
  jmp LoadMazeData             ; $A756
  .incbin "prg_bank_4.bin", $2759, $9  ; $A759
WarpToNextMaze:
  inc MazeIndex                ; $A762
  jmp LoadMazeData             ; $A765
  inc MazeIndex                ; $A768  [heuristic code]
  inc MazeIndex                ; $A76B
  lda #$01                     ; $A76E
  sta PlayerCellX              ; $A770
  dec PlayerCellY              ; $A773
  jmp LoadMazeData             ; $A776
  lda #$11                     ; $A779  [heuristic code]
  sta MazeIndex                ; $A77B
  ldx #$01                     ; $A77E
  stx PlayerCellX              ; $A780
  dex                          ; $A783
  stx PlayerCellY              ; $A784
  jmp LoadMazeData             ; $A787
MazeObjType05State9:
  lda #$06                     ; $A78A
  sta PpuOpRequest             ; $A78C
  jmp AdvanceObjectState       ; $A78F
MazeObjType05StateA:
  lda z:HwScrollY              ; $A792
  clc                          ; $A794
  adc #$08                     ; $A795
  sta z:HwScrollY              ; $A797
  cmp #$F0                     ; $A799
  bcs Loc_B4_A79E              ; $A79B
  rts                          ; $A79D
Loc_B4_A79E:
  lda #$EF                     ; $A79E
  sta z:HwScrollY              ; $A7A0
  jmp AdvanceObjectState       ; $A7A2
MazeObjType05StateB:
  ldy #$0B                     ; $A7A5
  jsr IncObjectField           ; $A7A7
  cmp #$17                     ; $A7AA
  beq Loc_B4_A7B6              ; $A7AC
  tax                          ; $A7AE
  dex                          ; $A7AF
  lda Data_B4_A7C3,x           ; $A7B0
  sta z:HwScrollY              ; $A7B3
  rts                          ; $A7B5
Loc_B4_A7B6:
  lda z:PpuCtrlShadow          ; $A7B6
  and #$FD                     ; $A7B8
  sta z:PpuCtrlShadow          ; $A7BA
  lda #$00                     ; $A7BC
  sta z:HwScrollY              ; $A7BE
  jmp RemoveObject             ; $A7C0
Data_B4_A7C3:
  .incbin "prg_bank_4.bin", $27C3, $16  ; $A7C3
MazeObjType1A:
  ldy #$08                     ; $A7D9
  lda (Tmp00),y                ; $A7DB
  asl a                        ; $A7DD
  tax                          ; $A7DE
  lda Data_B4_A7EC,x           ; $A7DF
  sta z:$6D                    ; $A7E2
  lda Data_B4_A7ED,x           ; $A7E4
  sta z:$6E                    ; $A7E7
  jmp ($006D)                  ; $A7E9
Data_B4_A7EC:
  .incbin "prg_bank_4.bin", $27EC, $1  ; $A7EC
Data_B4_A7ED:
  .incbin "prg_bank_4.bin", $27ED, $A1  ; $A7ED
MazeObjType06:
  jsr Sub_B4_A894              ; $A88E
  jmp Loc_B4_A984              ; $A891
Sub_B4_A894:
  ldy #$08                     ; $A894
  lda (Tmp00),y                ; $A896
  asl a                        ; $A898
  tax                          ; $A899
  lda Data_B4_A8A7,x           ; $A89A
  sta z:$6D                    ; $A89D
  lda Data_B4_A8A8,x           ; $A89F
  sta z:$6E                    ; $A8A2
  jmp ($006D)                  ; $A8A4
Data_B4_A8A7:
  .addr Sub_B4_A8B7, Sub_B4_A8E4, Sub_B4_A905, Sub_B4_A918, Sub_B4_A924, Sub_B4_A930, Sub_B4_A949, MazeObjType11State7  ; $A8A7 pointer table
Sub_B4_A8B7:
  ldy #$02                     ; $A8B7
  lda (Tmp00),y                ; $A8B9
  bne Loc_B4_A8C4              ; $A8BB
  lda z:$84                    ; $A8BD
  beq Loc_B4_A8C4              ; $A8BF
  jmp RemoveObject             ; $A8C1
Loc_B4_A8C4:
  jsr Sub_B4_A963              ; $A8C4
  jsr Sub_B4_B39F              ; $A8C7
  ldx MazeIndex                ; $A8CA
  lda Data_B4_A8D3,x           ; $A8CD
  jmp Loc_B4_B389              ; $A8D0
Data_B4_A8D3:
  .incbin "prg_bank_4.bin", $28D3, $11  ; $A8D3
Sub_B4_A8E4:
  ldy #$0B                     ; $A8E4
  jsr DecObjectField           ; $A8E6
  bne Loc_B4_A904              ; $A8E9
  jsr SetObjectFlagsE0         ; $A8EB
  ldy #$0B                     ; $A8EE
Loc_B4_A8F0:
  lda #$09                     ; $A8F0
  sta (Tmp00),y                ; $A8F2
  ldy #$05                     ; $A8F4
  jsr IncObjectField           ; $A8F6
  jsr SetObjectFrame           ; $A8F9
  jsr AdvanceObjectState       ; $A8FC
  lda #$0D                     ; $A8FF
  jmp QueueSound               ; $A901
Loc_B4_A904:
  rts                          ; $A904
Sub_B4_A905:
  ldy #$0B                     ; $A905
  jsr DecObjectField           ; $A907
  beq Sub_B4_A911              ; $A90A
  lda #$F9                     ; $A90C
  jmp Loc_B4_A9A3              ; $A90E
Sub_B4_A911:
  lda #$09                     ; $A911
  sta (Tmp00),y                ; $A913
  jmp AdvanceObjectState       ; $A915
Sub_B4_A918:
  ldy #$0B                     ; $A918
  jsr DecObjectField           ; $A91A
  beq Loc_B4_A8F0              ; $A91D
  lda #$FC                     ; $A91F
  jmp Loc_B4_A9A3              ; $A921
Sub_B4_A924:
  ldy #$0B                     ; $A924
  jsr DecObjectField           ; $A926
  beq Loc_B4_A8F0              ; $A929
  lda #$FE                     ; $A92B
  jmp Loc_B4_A9A3              ; $A92D
Sub_B4_A930:
  ldy #$0B                     ; $A930
  jsr DecObjectField           ; $A932
  beq Loc_B4_A93C              ; $A935
  lda #$02                     ; $A937
  jmp Loc_B4_A9A3              ; $A939
Loc_B4_A93C:
  jsr Sub_B4_A911              ; $A93C
  lda #$1E                     ; $A93F
  jsr DamagePlayer             ; $A941
  lda #$34                     ; $A944
  jmp QueueSound               ; $A946
Sub_B4_A949:
  ldy #$0B                     ; $A949
  jsr DecObjectField           ; $A94B
  beq Loc_B4_A955              ; $A94E
  lda #$02                     ; $A950
  jmp Loc_B4_A9A3              ; $A952
Loc_B4_A955:
  ldy #$08                     ; $A955
  sta (Tmp00),y                ; $A957
  tay                          ; $A959
  lda #$47                     ; $A95A
  sta (Tmp00),y                ; $A95C
  ldy #$53                     ; $A95E
  jmp AddObjectOfType          ; $A960
Sub_B4_A963:
  jsr RandomByteMixed          ; $A963
  and #$0F                     ; $A966
  ldx MazeIndex                ; $A968
  adc Data_B4_A973,x           ; $A96B
  ldy #$0B                     ; $A96E
  sta (Tmp00),y                ; $A970
  rts                          ; $A972
Data_B4_A973:
  .incbin "prg_bank_4.bin", $2973, $11  ; $A973
Loc_B4_A984:
  ldy #$09                     ; $A984
  lda (Tmp00),y                ; $A986
  bpl Loc_B4_A9A2              ; $A988
  jsr Sub_B4_B3EE              ; $A98A
  jsr ResetScrollAndObjectFlags ; $A98D
  lda #$07                     ; $A990
  ldy #$08                     ; $A992
  sta (Tmp00),y                ; $A994
  lda #$14                     ; $A996
  ldx #$05                     ; $A998
  jsr AddLifeAndAmmo           ; $A99A
  lda #$04                     ; $A99D
  jmp SetObjectFrame           ; $A99F
Loc_B4_A9A2:
  rts                          ; $A9A2
Loc_B4_A9A3:
  ldy #$01                     ; $A9A3
  clc                          ; $A9A5
  adc (Tmp00),y                ; $A9A6
  sta (Tmp00),y                ; $A9A8
  rts                          ; $A9AA
MazeObjType07:
  ldy #$08                     ; $A9AB
  lda (Tmp00),y                ; $A9AD
  bne Loc_B4_A9C3              ; $A9AF
  lda #$3C                     ; $A9B1
  ldy #$0B                     ; $A9B3
  sta (Tmp00),y                ; $A9B5
  jsr LoadObjectSpeedFromType  ; $A9B7
  lda z:$72                    ; $A9BA
  cmp #$03                     ; $A9BC
  bne Loc_B4_A9C0              ; $A9BE
Loc_B4_A9C0:
  jmp AdvanceObjectState       ; $A9C0
Loc_B4_A9C3:
  ldy #$0B                     ; $A9C3
  jsr IncObjectField           ; $A9C5
  bne Loc_B4_A9D8              ; $A9C8
  lda #$80                     ; $A9CA
  sta (Tmp00),y                ; $A9CC
  lda #$0F                     ; $A9CE
  jsr DamagePlayer             ; $A9D0
  ldy #$53                     ; $A9D3
  jmp AddObjectOfType          ; $A9D5
Loc_B4_A9D8:
  rts                          ; $A9D8
MazeObjType08:
  ldy #$08                     ; $A9D9
  lda (Tmp00),y                ; $A9DB
  bne Loc_B4_A9C3              ; $A9DD
  lda #$02                     ; $A9DF
Loc_B4_A9E1:
  cmp z:$72                    ; $A9E1
  beq Loc_B4_A9EC              ; $A9E3
  lda #$0A                     ; $A9E5
  jsr DamagePlayer             ; $A9E7
  lda #$FF                     ; $A9EA
Loc_B4_A9EC:
  ldy #$0B                     ; $A9EC
  sta (Tmp00),y                ; $A9EE
  jsr LoadObjectSpeedFromType  ; $A9F0
  jmp AdvanceObjectState       ; $A9F3
MazeObjType09:
  ldy #$08                     ; $A9F6
  lda (Tmp00),y                ; $A9F8
  bne Loc_B4_A9C3              ; $A9FA
  lda #$01                     ; $A9FC
  jmp Loc_B4_A9E1              ; $A9FE
MazeObjType0A:
  jsr UpdateEnemyObject        ; $AA01
  jmp Loc_B4_ABE1              ; $AA04
UpdateEnemyObject:
  ldy #$08                     ; $AA07
  lda (Tmp00),y                ; $AA09
  asl a                        ; $AA0B
  tax                          ; $AA0C
  lda Data_B4_AA1A,x           ; $AA0D
  sta z:$6D                    ; $AA10
  lda Data_B4_AA1B,x           ; $AA12
  sta z:$6E                    ; $AA15
  jmp ($006D)                  ; $AA17
Data_B4_AA1A:
  .addr MazeObjEnemy0AState0, MazeObjEnemy0AState1, MazeObjEnemy0AState2, MazeObjEnemy0AState3, MazeObjEnemy0AState4, MazeObjEnemy0AState5, MazeObjEnemy0AState6, MazeObjEnemy0AState1, MazeObjEnemy0AState2, MazeObjEnemy0AState3, MazeObjEnemy0AState4, MazeObjEnemy0AState5, MazeObjEnemy0AStateC, MazeObjEnemy0AStateD, MazeObjEnemy0AState1, MazeObjEnemy0AState2, MazeObjEnemy0AState3, Sub_B4_AB5E, ObjectMoveUpStep, MazeObjEnemy0AState6, CollectBonusItem, MazeObjType11State7, Sub_B4_ABBA  ; $AA1A pointer table
MazeObjEnemy0AState0:
  ldy #$02                     ; $AA48
  lda (Tmp00),y                ; $AA4A
  bne Loc_B4_AA5D              ; $AA4C
  ldy #$07                     ; $AA4E
  lda (Tmp00),y                ; $AA50
  ldy #$0B                     ; $AA52
  sta (Tmp00),y                ; $AA54
  jsr AdvanceObjectState       ; $AA56
  lda #$00                     ; $AA59
  beq Loc_B4_AA6B              ; $AA5B
Loc_B4_AA5D:
  lda #$01                     ; $AA5D
  ldy #$0B                     ; $AA5F
  sta (Tmp00),y                ; $AA61
  lda #$07                     ; $AA63
  ldy #$08                     ; $AA65
  sta (Tmp00),y                ; $AA67
  lda #$01                     ; $AA69
Loc_B4_AA6B:
  jsr SetObjectFrame           ; $AA6B
  ldx #$07                     ; $AA6E
  lda $051C                    ; $AA70
  beq Loc_B4_AA76              ; $AA73
  inx                          ; $AA75
Loc_B4_AA76:
  txa                          ; $AA76
  jsr StartPaletteFade         ; $AA77
  lda #$68                     ; $AA7A
  ldx #$40                     ; $AA7C
  jsr Sub_B4_B3BC              ; $AA7E
  jmp LoadObjectSpeedFromType  ; $AA81
MazeObjEnemy0AState1:
  ldx #$40                     ; $AA84
  bne Loc_B4_AA8A              ; $AA86
MazeObjEnemy0AState3:
  ldx #$0D                     ; $AA88
Loc_B4_AA8A:
  ldy #$0B                     ; $AA8A
  jsr DecObjectField           ; $AA8C
  beq Loc_B4_AA92              ; $AA8F
  rts                          ; $AA91
Loc_B4_AA92:
  jsr AdvanceObjectState       ; $AA92
  txa                          ; $AA95
  jmp QueueSound               ; $AA96
MazeObjEnemy0AState2:
  ldy #$0B                     ; $AA99
  jsr IncObjectField           ; $AA9B
  bmi Loc_B4_AABE              ; $AA9E
  lsr a                        ; $AAA0
  and #$03                     ; $AAA1
  tax                          ; $AAA3
  lda Data_B4_AAD7,x           ; $AAA4
  jsr SetObjectFrame           ; $AAA7
  jsr DamageFlashStep          ; $AAAA
  jsr ShakeScreenStep          ; $AAAD
  ldy #$0B                     ; $AAB0
  lda (Tmp00),y                ; $AAB2
  and #$0F                     ; $AAB4
  bne Loc_B4_AABD              ; $AAB6
  lda #$02                     ; $AAB8
  jsr DamagePlayer             ; $AABA
Loc_B4_AABD:
  rts                          ; $AABD
Loc_B4_AABE:
  ldy #$07                     ; $AABE
  lda (Tmp00),y                ; $AAC0
  ldy #$0B                     ; $AAC2
  sta (Tmp00),y                ; $AAC4
  lda #$00                     ; $AAC6
  sta z:HwScrollX              ; $AAC8
  sta z:HwScrollX              ; $AACA
  jsr ResetDamageFlash         ; $AACC
  jsr AdvanceObjectState       ; $AACF
  lda #$45                     ; $AAD2
  jmp QueueSound               ; $AAD4
Data_B4_AAD7:
  .incbin "prg_bank_4.bin", $2AD7, $4  ; $AAD7
MazeObjEnemy0AState4:
  ldx #$FB                     ; $AADB
  lda #$02                     ; $AADD
  jsr MoveObjectXY             ; $AADF
  ldy #$0B                     ; $AAE2
  jsr IncObjectField           ; $AAE4
  cmp #$10                     ; $AAE7
  beq Loc_B4_AAF0              ; $AAE9
  lda #$04                     ; $AAEB
  jmp SetObjectFrame           ; $AAED
Loc_B4_AAF0:
  lda #$00                     ; $AAF0
  sta (Tmp00),y                ; $AAF2
  lda #$05                     ; $AAF4
  jsr SetObjectFrame           ; $AAF6
  jmp AdvanceObjectState       ; $AAF9
MazeObjEnemy0AState5:
  ldx #$FF                     ; $AAFC
  lda #$02                     ; $AAFE
  jsr MoveObjectXY             ; $AB00
  ldy #$0B                     ; $AB03
  jsr IncObjectField           ; $AB05
  cmp #$0C                     ; $AB08
  beq Loc_B4_AB0D              ; $AB0A
  rts                          ; $AB0C
Loc_B4_AB0D:
  lda #$00                     ; $AB0D
  sta (Tmp00),y                ; $AB0F
  jmp AdvanceObjectState       ; $AB11
MazeObjEnemy0AState6:
  lda #$4B                     ; $AB14  [heuristic code]
  ldy #$00                     ; $AB16
  sta (Tmp00),y                ; $AB18
  tya                          ; $AB1A
  ldy #$08                     ; $AB1B
  sta (Tmp00),y                ; $AB1D
  rts                          ; $AB1F
MazeObjEnemy0AStateC:
  ldx #$01                     ; $AB20
  lda #$02                     ; $AB22
  jsr MoveObjectXY             ; $AB24
  ldy #$0B                     ; $AB27
  jsr IncObjectField           ; $AB29
  cmp #$0C                     ; $AB2C
  beq Loc_B4_AB35              ; $AB2E
  lda #$05                     ; $AB30
  jmp SetObjectFrame           ; $AB32
Loc_B4_AB35:
  lda #$00                     ; $AB35
  sta (Tmp00),y                ; $AB37
  lda #$04                     ; $AB39
  jsr SetObjectFrame           ; $AB3B
  jmp AdvanceObjectState       ; $AB3E
MazeObjEnemy0AStateD:
  ldx #$05                     ; $AB41  [heuristic code]
  lda #$02                     ; $AB43
  jsr MoveObjectXY             ; $AB45
  ldy #$0B                     ; $AB48
  jsr IncObjectField           ; $AB4A
  cmp #$10                     ; $AB4D
  beq Loc_B4_AB52              ; $AB4F
  rts                          ; $AB51
Loc_B4_AB52:
  lda #$09                     ; $AB52
  sta (Tmp00),y                ; $AB54
  lda #$00                     ; $AB56
  jsr SetObjectFrame           ; $AB58
  jmp AdvanceObjectState       ; $AB5B
Sub_B4_AB5E:
  lda #$FA                     ; $AB5E
  jsr AddToObjectY             ; $AB60
  ldy #$0B                     ; $AB63
  jsr IncObjectField           ; $AB65
  cmp #$10                     ; $AB68
  beq Loc_B4_AB71              ; $AB6A
  lda #$04                     ; $AB6C
  jmp SetObjectFrame           ; $AB6E
Loc_B4_AB71:
  lda #$00                     ; $AB71
  sta (Tmp00),y                ; $AB73
  lda #$05                     ; $AB75
  jsr SetObjectFrame           ; $AB77
  jmp AdvanceObjectState       ; $AB7A
ObjectMoveUpStep:
  lda #$FF                     ; $AB7D
  jsr AddToObjectY             ; $AB7F
  ldy #$0B                     ; $AB82
  jsr IncObjectField           ; $AB84
  cmp #$0C                     ; $AB87
  beq Loc_B4_AB8C              ; $AB89
  rts                          ; $AB8B
Loc_B4_AB8C:
  lda #$00                     ; $AB8C
  sta (Tmp00),y                ; $AB8E
  jmp AdvanceObjectState       ; $AB90
CollectBonusItem:
  lda $051C                    ; $AB93
  sta $0509                    ; $AB96
  lda $051E                    ; $AB99
  sta $050D                    ; $AB9C
  lda #$32                     ; $AB9F
  ldx #$0A                     ; $ABA1
  ldy $051E                    ; $ABA3
  bne Loc_B4_ABB4              ; $ABA6
  lda #$01                     ; $ABA8
  sta MazeItemFullRestore      ; $ABAA
  jsr QueueSound               ; $ABAD
  lda #$32                     ; $ABB0
  ldx #$0A                     ; $ABB2
Loc_B4_ABB4:
  jsr AddLifeAndAmmo           ; $ABB4
  jmp AdvanceObjectState       ; $ABB7
Sub_B4_ABBA:
  ldy #$0B                     ; $ABBA
  jsr DecObjectField           ; $ABBC
  bne Loc_B4_ABCC              ; $ABBF
  lda #$11                     ; $ABC1
  ldy #$08                     ; $ABC3
  sta (Tmp00),y                ; $ABC5
  lda #$0D                     ; $ABC7
  jmp QueueSound               ; $ABC9
Loc_B4_ABCC:
  ldx #$05                     ; $ABCC
  stx PpuOpRequest             ; $ABCE
  lsr a                        ; $ABD1
  tay                          ; $ABD2
  lda Data_B4_ABD9,y           ; $ABD3
  jmp StartPaletteFade         ; $ABD6
Data_B4_ABD9:
  .incbin "prg_bank_4.bin", $2BD9, $8  ; $ABD9
Loc_B4_ABE1:
  ldy #$09                     ; $ABE1
  lda (Tmp00),y                ; $ABE3
  bmi Loc_B4_ABE8              ; $ABE5
  rts                          ; $ABE7
Loc_B4_ABE8:
  and #$7F                     ; $ABE8
  sta (Tmp00),y                ; $ABEA
  ldy #$0E                     ; $ABEC
  jsr DecObjectField           ; $ABEE
  beq Loc_B4_AC04              ; $ABF1
  lda #$16                     ; $ABF3
  ldy #$08                     ; $ABF5
  sta (Tmp00),y                ; $ABF7
  lda #$0F                     ; $ABF9
  ldy #$0B                     ; $ABFB
  sta (Tmp00),y                ; $ABFD
  lda #$01                     ; $ABFF
  jmp SetObjectFrame           ; $AC01
Loc_B4_AC04:
  ldy #$0B                     ; $AC04
  sta (Tmp00),y                ; $AC06
  lda #$14                     ; $AC08
  ldy #$08                     ; $AC0A
  sta (Tmp00),y                ; $AC0C
  jsr SetObjectFlagsE0         ; $AC0E
  lda #$FF                     ; $AC11
  ldy #$0D                     ; $AC13
  sta (Tmp00),y                ; $AC15
  lda #$00                     ; $AC17
  sta z:HwScrollY              ; $AC19
  sta z:HwScrollX              ; $AC1B
  jsr ResetDamageFlash         ; $AC1D
  lda #$06                     ; $AC20
  jmp SetObjectFrame           ; $AC22
MoveObjectXY:
  ldy #$02                     ; $AC25
  jsr AddToObjectField         ; $AC27
  txa                          ; $AC2A
AddToObjectY:
  ldy #$01                     ; $AC2B
AddToObjectField:
  clc                          ; $AC2D
  adc (Tmp00),y                ; $AC2E
  sta (Tmp00),y                ; $AC30
  rts                          ; $AC32
MazeObjType27:
  ldx $050D                    ; $AC33
  bne Loc_B4_AC52              ; $AC36
  inx                          ; $AC38
  stx $051E                    ; $AC39
  lda #$01                     ; $AC3C
  ldx #$1E                     ; $AC3E
Loc_B4_AC40:
  ldy #$0E                     ; $AC40
  sta (Tmp00),y                ; $AC42
  txa                          ; $AC44
  ldy #$07                     ; $AC45
  sta (Tmp00),y                ; $AC47
  lda #$CA                     ; $AC49
  ldy #$00                     ; $AC4B
  sta (Tmp00),y                ; $AC4D
  jmp MazeObjType0A            ; $AC4F
Loc_B4_AC52:
  jmp RemoveObject             ; $AC52
MazeObjType28:
  ldx $0509                    ; $AC55
  bne Loc_B4_AC52              ; $AC58
  inx                          ; $AC5A
  stx $051C                    ; $AC5B
  lda #$08                     ; $AC5E
  jsr StartPaletteFade         ; $AC60
  lda #$03                     ; $AC63
  ldx #$09                     ; $AC65
  jmp Loc_B4_AC40              ; $AC67
MazeObjType0F:
  ldy #$08                     ; $AC6A  [heuristic code]
  lda (Tmp00),y                ; $AC6C
  beq Loc_B4_AC76              ; $AC6E
  lsr a                        ; $AC70
  bne Loc_B4_AC84              ; $AC71
  jmp WaitObjectTimer          ; $AC73
Loc_B4_AC76:
  lda MazeItemFullRestore      ; $AC76
  ora $050A                    ; $AC79
  bne Loc_B4_AC90              ; $AC7C
  jsr Sub_B4_B3B2              ; $AC7E
  jmp Loc_B4_B38C              ; $AC81
Loc_B4_AC84:
  lda JoyNew1                  ; $AC84
  lsr a                        ; $AC87
  bcc Loc_B4_AC93              ; $AC88
  inc $050A                    ; $AC8A
  jsr RequestPpuListC          ; $AC8D
Loc_B4_AC90:
  jmp RemoveObject             ; $AC90
Loc_B4_AC93:
  rts                          ; $AC93
MazeObjType10:
  ldy #$08                     ; $AC94
  lda (Tmp00),y                ; $AC96
  beq Loc_B4_ACA0              ; $AC98
  lsr a                        ; $AC9A
  bne Loc_B4_ACAE              ; $AC9B
  jmp WaitObjectTimer          ; $AC9D
Loc_B4_ACA0:
  lda MazeItemFullRestore      ; $ACA0
  ora $050C                    ; $ACA3
  bne Loc_B4_ACBA              ; $ACA6
  jsr Sub_B4_B3B2              ; $ACA8
  jmp Loc_B4_B38C              ; $ACAB
Loc_B4_ACAE:
  lda JoyNew1                  ; $ACAE
  lsr a                        ; $ACB1
  bcc Loc_B4_ACBD              ; $ACB2
  inc $050C                    ; $ACB4
  jsr RequestPpuListA          ; $ACB7
Loc_B4_ACBA:
  jmp RemoveObject             ; $ACBA
Loc_B4_ACBD:
  rts                          ; $ACBD
MazeObjType26:
  ldy #$08                     ; $ACBE
  lda (Tmp00),y                ; $ACC0
  asl a                        ; $ACC2
  tax                          ; $ACC3
  lda Data_B4_ACD1,x           ; $ACC4
  sta z:$6D                    ; $ACC7
  lda Data_B4_ACD2,x           ; $ACC9
  sta z:$6E                    ; $ACCC
  jmp ($006D)                  ; $ACCE
Data_B4_ACD1:
  .addr Sub_B4_ACDF, WaitObjectTimer, ConfirmWithAButton, ShowFullScreenMessage, FullScreenMessageWait, ReturnFromFullScreenMessage, RequestPpuOp6AndRemove  ; $ACD1 pointer table
Sub_B4_ACDF:
  lda $050B                    ; $ACDF
  bne Loc_B4_ACEA              ; $ACE2
  jsr Sub_B4_B3B2              ; $ACE4
  jmp Loc_B4_B38C              ; $ACE7
Loc_B4_ACEA:
  jmp RemoveObject             ; $ACEA
ConfirmWithAButton:
  lda JoyNew1                  ; $ACED  [heuristic code]
  lsr a                        ; $ACF0
  bcc Loc_B4_AD04              ; $ACF1
  ldy #$00                     ; $ACF3
  lda (Tmp00),y                ; $ACF5
  and #$7F                     ; $ACF7
  sta (Tmp00),y                ; $ACF9
  jsr SetObjectFlagsE0         ; $ACFB
  jsr DisableSpriteBgRendering ; $ACFE
  jmp AdvanceObjectState       ; $AD01
Loc_B4_AD04:
  rts                          ; $AD04
ShowFullScreenMessage:
  jsr DisableSpriteBgRendering ; $AD05
  lda #$33                     ; $AD08
  sta z:PpuCtrlShadow          ; $AD0A
  lda #$0D                     ; $AD0C
  jsr MmcWriteChr1A            ; $AD0E
  lda #$07                     ; $AD11
  sta PpuOpRequest             ; $AD13
  jsr AdvanceObjectState       ; $AD16
  lda PPU_STATUS               ; $AD19
  lda #$28                     ; $AD1C
  sta PPU_ADDR                 ; $AD1E
  ldx #$00                     ; $AD21
  stx PPU_ADDR                 ; $AD23
  ldy #$04                     ; $AD26
  lda #$FF                     ; $AD28
Loc_B4_AD2A:
  sta PPU_DATA                 ; $AD2A
  dex                          ; $AD2D
  bne Loc_B4_AD2A              ; $AD2E
  dey                          ; $AD30
  bne Loc_B4_AD2A              ; $AD31
  jsr ProcessPpuUpdateList     ; $AD33
  .addr Data_B4_AD39  ; $AD36 inline pointer (data after a JSR)
  rts                          ; $AD38
Data_B4_AD39:
  .incbin "prg_bank_4.bin", $2D39, $EC  ; $AD39
FullScreenMessageWait:
  lda JoyNew1                  ; $AE25
  and #$02                     ; $AE28
  beq Loc_B4_AE32              ; $AE2A
  jsr DisableSpriteBgRendering ; $AE2C
  jmp AdvanceObjectState       ; $AE2F
Loc_B4_AE32:
  ldx #$04                     ; $AE32
Loc_B4_AE34:
  lda Data_B4_AE50,x           ; $AE34
  sta PpuBufAddrHi,x           ; $AE37
  dex                          ; $AE3A
  bpl Loc_B4_AE34              ; $AE3B
  ldy #$0B                     ; $AE3D
  jsr IncObjectField           ; $AE3F
  asl a                        ; $AE42
  bpl Loc_B4_AE4A              ; $AE43
  lda #$81                     ; $AE45
  sta $054D                    ; $AE47
Loc_B4_AE4A:
  lda #$01                     ; $AE4A
  sta PpuOpRequest             ; $AE4C
  rts                          ; $AE4F
Data_B4_AE50:
  .incbin "prg_bank_4.bin", $2E50, $5  ; $AE50
ReturnFromFullScreenMessage:
  jsr DisableSpriteBgRendering ; $AE55
  lda z:PpuCtrlShadow          ; $AE58
  and #$FC                     ; $AE5A
  sta z:PpuCtrlShadow          ; $AE5C
  jsr MmcWriteChr1             ; $AE5E
  inc $050B                    ; $AE61
  jsr RequestPpuListB          ; $AE64
  jmp AdvanceObjectState       ; $AE67
RequestPpuOp6AndRemove:
  lda #$06                     ; $AE6A
  sta PpuOpRequest             ; $AE6C
  jmp RemoveObject             ; $AE6F
MazeObjType29:
  ldy #$08                     ; $AE72
  lda (Tmp00),y                ; $AE74
  bne Loc_B4_AE86              ; $AE76
  lda #$C0                     ; $AE78
Loc_B4_AE7A:
  ldy #$02                     ; $AE7A
  sta (Tmp00),y                ; $AE7C
  lda #$C7                     ; $AE7E
  dey                          ; $AE80
  sta (Tmp00),y                ; $AE81
  jmp Loc_B4_B38C              ; $AE83
Loc_B4_AE86:
  ldy #$0B                     ; $AE86
  jsr IncObjectField           ; $AE88
  and #$10                     ; $AE8B
  beq *+5                      ; $AE8D
  lda #$F0                     ; $AE8F
  bit Data_C7A9                ; $AE91
  ldy #$01                     ; $AE94
  sta (Tmp00),y                ; $AE96
  rts                          ; $AE98
MazeObjType2A:
  ldy #$08                     ; $AE99
  lda (Tmp00),y                ; $AE9B
  bne Loc_B4_AE86              ; $AE9D
  lda #$D0                     ; $AE9F
  jmp Loc_B4_AE7A              ; $AEA1
MazeObjType2B:
  ldy #$08                     ; $AEA4  [heuristic code]
  lda (Tmp00),y                ; $AEA6
  bne Loc_B4_AE86              ; $AEA8
  lda PpuOpRequest             ; $AEAA
  beq Loc_B4_AEB0              ; $AEAD
  rts                          ; $AEAF
Loc_B4_AEB0:
  lda #$05                     ; $AEB0
  sta PpuOpRequest             ; $AEB2
  lda #$D0                     ; $AEB5
  ldy #$02                     ; $AEB7
  sta (Tmp00),y                ; $AEB9
  lda #$C7                     ; $AEBB
  dey                          ; $AEBD
  sta (Tmp00),y                ; $AEBE
  lda #$0E                     ; $AEC0
  jmp Loc_B4_B389              ; $AEC2
MazeObjType11:
  jsr UpdateMazeObjType11      ; $AEC5
  jmp Loc_B4_B012              ; $AEC8
UpdateMazeObjType11:
  ldy #$08                     ; $AECB
  lda (Tmp00),y                ; $AECD
  asl a                        ; $AECF
  tax                          ; $AED0
  lda Data_B4_AEDE,x           ; $AED1
  sta z:$6D                    ; $AED4
  lda Data_B4_AEDF,x           ; $AED6
  sta z:$6E                    ; $AED9
  jmp ($006D)                  ; $AEDB
Data_B4_AEDE:
  .addr MazeObjType11State0, MazeObjType11State1, MazeObjType11State2, MazeObjType11State3, MazeObjType11State4, MazeObjType11State5, MazeObjType11State6, MazeObjType11State7  ; $AEDE pointer table
MazeObjType11State0:
  lda z:$84                    ; $AEEE
  beq Loc_B4_AEF5              ; $AEF0
  jmp RemoveObject             ; $AEF2
Loc_B4_AEF5:
  jsr SetObjectTimerFromLife   ; $AEF5
  jsr Sub_B4_B39F              ; $AEF8
  ldx MazeIndex                ; $AEFB
  lda Data_B4_AF04,x           ; $AEFE
  jmp Loc_B4_B389              ; $AF01
Data_B4_AF04:
  .incbin "prg_bank_4.bin", $2F04, $11  ; $AF04
MazeObjType11State1:
  ldy #$0B                     ; $AF15
  jsr DecObjectField           ; $AF17
  beq Loc_B4_AF1D              ; $AF1A
  rts                          ; $AF1C
Loc_B4_AF1D:
  jsr SetObjectTimerFromLife   ; $AF1D
  lda #$01                     ; $AF20
  jsr SetObjectFrame           ; $AF22
  jmp AdvanceObjectState       ; $AF25
MazeObjType11State2:
  ldy #$0B                     ; $AF28
  jsr DecObjectField           ; $AF2A
  beq Loc_B4_AF30              ; $AF2D
  rts                          ; $AF2F
Loc_B4_AF30:
  lda #$40                     ; $AF30
  jsr QueueSound               ; $AF32
  jmp AdvanceObjectState       ; $AF35
MazeObjType11State3:
  ldy #$0B                     ; $AF38
  jsr IncObjectField           ; $AF3A
  bpl Loc_B4_AF53              ; $AF3D
  lda #$45                     ; $AF3F
  jsr QueueSound               ; $AF41
  lda #$01                     ; $AF44
  ldy #$08                     ; $AF46
  sta (Tmp00),y                ; $AF48
  lda #$00                     ; $AF4A
  sta z:HwScrollY              ; $AF4C
  sta z:HwScrollX              ; $AF4E
  jmp ResetDamageFlash         ; $AF50
Loc_B4_AF53:
  and #$07                     ; $AF53
  beq Loc_B4_AF67              ; $AF55
  lsr a                        ; $AF57
  bcs Loc_B4_AF61              ; $AF58
  tax                          ; $AF5A
Loc_B4_AF5B:
  lda Data_B4_AF7A,x           ; $AF5B
  jsr SetObjectFrame           ; $AF5E
Loc_B4_AF61:
  jsr DamageFlashStep          ; $AF61
  jmp ShakeScreenStep          ; $AF64
Loc_B4_AF67:
  ldy #$D2                     ; $AF67
  jsr AddObjectOfType          ; $AF69
  bcs Loc_B4_AF75              ; $AF6C
  ldy #$02                     ; $AF6E
  lda (Tmp00),y                ; $AF70
  sta $0312,x                  ; $AF72
Loc_B4_AF75:
  ldx #$03                     ; $AF75
  jmp Loc_B4_AF5B              ; $AF77
Data_B4_AF7A:
  .incbin "prg_bank_4.bin", $2F7A, $4  ; $AF7A
MazeObjType11State4:
  ldx CollectedCount           ; $AF7E
  cpx #$03                     ; $AF81
  bcs Loc_B4_AF8C              ; $AF83
  inx                          ; $AF85
  stx CollectedCount           ; $AF86
  jsr AddCollectedCountIcon    ; $AF89
Loc_B4_AF8C:
  jmp AdvanceObjectState       ; $AF8C
MazeObjType11State5:
  jsr ResetScrollAndObjectFlags ; $AF8F
  jsr ResetDamageFlash         ; $AF92
  lda #$45                     ; $AF95
  jsr QueueSound               ; $AF97
  jmp AdvanceObjectState       ; $AF9A
MazeObjType11State6:
  lda #$05                     ; $AF9D
  ldx #$05                     ; $AF9F
  jsr AddLifeAndAmmo           ; $AFA1
  lda #$04                     ; $AFA4
  jsr SetObjectFrame           ; $AFA6
  lda #$0E                     ; $AFA9
  jsr QueueSound               ; $AFAB
  jmp AdvanceObjectState       ; $AFAE
DamageFlashStep:
  inc z:$88                    ; $AFB1
  lda z:$88                    ; $AFB3
  lsr a                        ; $AFB5
  bcc Loc_B4_AFE7              ; $AFB6
  lsr a                        ; $AFB8
  bcs Loc_B4_AFE7              ; $AFB9
  and #$03                     ; $AFBB
  cmp #$03                     ; $AFBD
  beq ResetDamageFlash         ; $AFBF
  ldx #$05                     ; $AFC1
  stx PpuOpRequest             ; $AFC3
  asl a                        ; $AFC6
  asl a                        ; $AFC7
  tax                          ; $AFC8
  lda Data_B4_AFF7,x           ; $AFC9
  sta $052A                    ; $AFCC
  lda Data_B4_AFF8,x           ; $AFCF
  sta $052E                    ; $AFD2
  lda Data_B4_AFF9,x           ; $AFD5
  sta $052B                    ; $AFD8
  sta $052F                    ; $AFDB
  lda Data_B4_AFFA,x           ; $AFDE
  sta AnimCounter              ; $AFE1
  sta $0530                    ; $AFE4
Loc_B4_AFE7:
  rts                          ; $AFE7
ResetDamageFlash:
  ldx #$05                     ; $AFE8
  stx PpuOpRequest             ; $AFEA
  ldx #$0F                     ; $AFED
  stx $052A                    ; $AFEF
  ldx z:$87                    ; $AFF2
  jmp SetFadeParamsFromTable   ; $AFF4
Data_B4_AFF7:
  .incbin "prg_bank_4.bin", $2FF7, $1  ; $AFF7
Data_B4_AFF8:
  .incbin "prg_bank_4.bin", $2FF8, $1  ; $AFF8
Data_B4_AFF9:
  .incbin "prg_bank_4.bin", $2FF9, $1  ; $AFF9
Data_B4_AFFA:
  .incbin "prg_bank_4.bin", $2FFA, $9  ; $AFFA
SetObjectTimerFromLife:
  lda z:PlayerLifeLo           ; $B003
  and #$C0                     ; $B005
  eor #$F0                     ; $B007
  lsr a                        ; $B009
  lsr a                        ; $B00A
  adc #$01                     ; $B00B
  ldy #$0B                     ; $B00D
  sta (Tmp00),y                ; $B00F
  rts                          ; $B011
Loc_B4_B012:
  ldy #$09                     ; $B012
  lda (Tmp00),y                ; $B014
  bpl Loc_B4_B021              ; $B016
  jsr Sub_B4_B3EE              ; $B018
  lda #$04                     ; $B01B
  ldy #$08                     ; $B01D
  sta (Tmp00),y                ; $B01F
Loc_B4_B021:
  rts                          ; $B021
ShakeScreenStep:
  inc z:$89                    ; $B022
  lda z:$89                    ; $B024
  lsr a                        ; $B026
  bcc Loc_B4_B036              ; $B027
  and #$03                     ; $B029
  tax                          ; $B02B
  lda Data_B4_B037,x           ; $B02C
  sta z:HwScrollX              ; $B02F
  lda Data_B4_B03B,x           ; $B031
  sta z:HwScrollY              ; $B034
Loc_B4_B036:
  rts                          ; $B036
Data_B4_B037:
  .incbin "prg_bank_4.bin", $3037, $4  ; $B037
Data_B4_B03B:
  .incbin "prg_bank_4.bin", $303B, $4  ; $B03B
MazeObjType12:
  ldy #$08                     ; $B03F
  lda (Tmp00),y                ; $B041
  bne Loc_B4_B05E              ; $B043
  lda #$08                     ; $B045
  jsr DamagePlayer             ; $B047
  lda #$68                     ; $B04A
  jsr Sub_B4_B3C2              ; $B04C
  lda #$FE                     ; $B04F
  ldy #$0D                     ; $B051
  sta (Tmp00),y                ; $B053
  lda #$FF                     ; $B055
  ldy #$0C                     ; $B057
  sta (Tmp00),y                ; $B059
  jmp Loc_B4_B38C              ; $B05B
Loc_B4_B05E:
  jsr Sub_B4_B3C7              ; $B05E
  cmp #$90                     ; $B061
  bcc Loc_B4_B068              ; $B063
  jmp RemoveObject             ; $B065
Loc_B4_B068:
  jsr AddObjectXVelocity       ; $B068
  cmp #$28                     ; $B06B
  bcs Loc_B4_B075              ; $B06D
  lda #$01                     ; $B06F
  ldy #$0C                     ; $B071
  sta (Tmp00),y                ; $B073
Loc_B4_B075:
  ldy #$0B                     ; $B075
  jsr IncObjectField           ; $B077
  and #$0F                     ; $B07A
  bne Loc_B4_B081              ; $B07C
  jsr IncObjectField           ; $B07E
Loc_B4_B081:
  lsr a                        ; $B081
  bcc Loc_B4_B08C              ; $B082
  lsr a                        ; $B084
  bcc Loc_B4_B08C              ; $B085
  and #$03                     ; $B087
  jmp SetObjectFrame           ; $B089
Loc_B4_B08C:
  rts                          ; $B08C
MazeObjType13:
  ldy #$08                     ; $B08D
  lda (Tmp00),y                ; $B08F
  asl a                        ; $B091
  tax                          ; $B092
  lda Data_B4_B0A0,x           ; $B093
  sta z:$6D                    ; $B096
  lda Data_B4_B0A1,x           ; $B098
  sta z:$6E                    ; $B09B
  jmp ($006D)                  ; $B09D
Data_B4_B0A0:
  .incbin "prg_bank_4.bin", $30A0, $1  ; $B0A0
Data_B4_B0A1:
  .incbin "prg_bank_4.bin", $30A1, $5  ; $B0A1
MazeObjType13State0:
  jsr LoadObjectSpeedFromType  ; $B0A6
  lda #$00                     ; $B0A9
  ldy #$0B                     ; $B0AB
  sta (Tmp00),y                ; $B0AD
MazeObjType13State1:
  jmp AdvanceObjectState       ; $B0AF
MazeObjType13State2:
  ldy #$0B                     ; $B0B2
  jsr IncObjectField           ; $B0B4
  cmp #$40                     ; $B0B7
  beq Loc_B4_B0BE              ; $B0B9
  jmp DamageFlashStep          ; $B0BB
Loc_B4_B0BE:
  lda #$04                     ; $B0BE
  jsr DamagePlayer             ; $B0C0
  jsr ResetDamageFlash         ; $B0C3
  jmp RemoveObject             ; $B0C6
MazeObjType14:
  ldy #$08                     ; $B0C9
  lda (Tmp00),y                ; $B0CB
  beq Loc_B4_B0D0              ; $B0CD
  rts                          ; $B0CF
Loc_B4_B0D0:
  lda #$80                     ; $B0D0
  tax                          ; $B0D2
  jsr Sub_B4_B3BC              ; $B0D3
  jmp Loc_B4_B38C              ; $B0D6
MazeObjType16:
  ldy #$08                     ; $B0D9
  lda (Tmp00),y                ; $B0DB
  asl a                        ; $B0DD
  tax                          ; $B0DE
  lda Data_B4_B0EC,x           ; $B0DF
  sta z:$6D                    ; $B0E2
  lda Data_B4_B0ED,x           ; $B0E4
  sta z:$6E                    ; $B0E7
  jmp ($006D)                  ; $B0E9
Data_B4_B0EC:
  .addr MazeObjType16State0, MazeObjType16State1, MazeObjType16State2  ; $B0EC pointer table
MazeObjType16State0:
  lda #$14                     ; $B0F2
  ldy #$0B                     ; $B0F4
  sta (Tmp00),y                ; $B0F6
  lda #$12                     ; $B0F8
  sta PpuStubTargetLo          ; $B0FA
  lda #$B1                     ; $B0FD
  sta PpuStubTargetHi          ; $B0FF
  lda #$04                     ; $B102
  sta PpuOpRequest             ; $B104
  lda z:$87                    ; $B107
  jsr StartPaletteFade         ; $B109
  jsr LoadObjectSpeedFromType  ; $B10C
  jmp AdvanceObjectState       ; $B10F
  .incbin "prg_bank_4.bin", $3112, $1C  ; $B112
MazeObjType16State1:
  ldy #$0B                     ; $B12E
  jsr DecObjectField           ; $B130
  beq Loc_B4_B138              ; $B133
  jmp MazeObjType16State2      ; $B135
Loc_B4_B138:
  ldy #$0A                     ; $B138
  lda (Tmp00),y                ; $B13A
  and #$1F                     ; $B13C
  sta (Tmp00),y                ; $B13E
  jsr AdvanceObjectState       ; $B140
MazeObjType16State2:
  jsr RandomByteMixed          ; $B143
  cmp #$20                     ; $B146
  bcs Loc_B4_B1AD              ; $B148
  lda ObjectCount              ; $B14A
  cmp #$02                     ; $B14D
  bcs Loc_B4_B1AD              ; $B14F
  jsr RandomByteMixed          ; $B151
  and #$07                     ; $B154
  cmp #$03                     ; $B156
  bcc Loc_B4_B15E              ; $B158
  cmp #$06                     ; $B15A
  bcc Loc_B4_B160              ; $B15C
Loc_B4_B15E:
  lda #$04                     ; $B15E
Loc_B4_B160:
  sta z:$60                    ; $B160
  lda #$01                     ; $B162
  sta z:$61                    ; $B164
  lda MazeItemFullRestore      ; $B166
  ora $050A                    ; $B169
  beq Loc_B4_B175              ; $B16C
  jsr RandomByteMixed          ; $B16E
  and #$2A                     ; $B171
  adc #$01                     ; $B173
Loc_B4_B175:
  sta z:$62                    ; $B175
Loc_B4_B177:
  inc ObjectCount              ; $B177
  lda ObjectCount              ; $B17A
  jsr AslA4                    ; $B17D
  tax                          ; $B180
  lda #$D7                     ; $B181
  sta $0300,x                  ; $B183
Loc_B4_B186:
  jsr Sub_B4_90CF              ; $B186
  cmp #$20                     ; $B189
  bcc Loc_B4_B186              ; $B18B
  cmp #$E0                     ; $B18D
  bcs Loc_B4_B186              ; $B18F
  and #$F0                     ; $B191
  ora #$04                     ; $B193
  sta ObjectLoopIndex,x        ; $B195
  lda z:$61                    ; $B198
  sta $030B,x                  ; $B19A
  inc z:$61                    ; $B19D
  lda z:$62                    ; $B19F
  sta $030C,x                  ; $B1A1
  dec z:$60                    ; $B1A4
  bne Loc_B4_B177              ; $B1A6
  lda #$26                     ; $B1A8
  jmp QueueSound               ; $B1AA
Loc_B4_B1AD:
  rts                          ; $B1AD
  .incbin "prg_bank_4.bin", $31AE, $4  ; $B1AE
MazeObjType17:
  ldy #$08                     ; $B1B2
  lda (Tmp00),y                ; $B1B4
  asl a                        ; $B1B6
  tax                          ; $B1B7
  lda Data_B4_B1C5,x           ; $B1B8
  sta z:$6D                    ; $B1BB
  lda Data_B4_B1C6,x           ; $B1BD
  sta z:$6E                    ; $B1C0
  jmp ($006D)                  ; $B1C2
Data_B4_B1C5:
  .addr MazeObjType17State0, MazeObjType17State1, MazeObjType17State2, MazeObjType17State3  ; $B1C5 pointer table
MazeObjType17State0:
  ldy #$0B                     ; $B1CD
  jsr DecObjectField           ; $B1CF
  beq Loc_B4_B1D5              ; $B1D2
  rts                          ; $B1D4
Loc_B4_B1D5:
  lda MazeItemFullRestore      ; $B1D5
  ora $050A                    ; $B1D8
  bne Loc_B4_B1E5              ; $B1DB
  ldy #$00                     ; $B1DD
  lda (Tmp00),y                ; $B1DF
  and #$7F                     ; $B1E1
  sta (Tmp00),y                ; $B1E3
Loc_B4_B1E5:
  lda #$30                     ; $B1E5
  jsr Sub_B4_B3C2              ; $B1E7
  jmp Loc_B4_B38C              ; $B1EA
MazeObjType17State1:
  ldy #$0B                     ; $B1ED
  jsr IncObjectField           ; $B1EF
  cmp #$08                     ; $B1F2
  bcs Loc_B4_B1F9              ; $B1F4
  jmp SetObjectFrame           ; $B1F6
Loc_B4_B1F9:
  ldy #$0C                     ; $B1F9
  lda (Tmp00),y                ; $B1FB
  ldy #$0B                     ; $B1FD
  sta (Tmp00),y                ; $B1FF
  lda ObjectCount              ; $B201
  cmp #$0F                     ; $B204
  bcs Loc_B4_B222              ; $B206
  inc ObjectCount              ; $B208
  jsr AslA4                    ; $B20B
  tax                          ; $B20E
  lda #$D9                     ; $B20F
  sta ObjectTable,x            ; $B211
  lda (Tmp00),y                ; $B214
  adc #$08                     ; $B216
  sta $031B,x                  ; $B218
  ldy #$02                     ; $B21B
  lda (Tmp00),y                ; $B21D
  sta $0312,x                  ; $B21F
Loc_B4_B222:
  jmp AdvanceObjectState       ; $B222
MazeObjType17State2:
  ldy #$00                     ; $B225
  lda (Tmp00),y                ; $B227
  bmi Loc_B4_B22C              ; $B229
  rts                          ; $B22B
Loc_B4_B22C:
  ldy #$0B                     ; $B22C
  jsr DecObjectField           ; $B22E
  beq Loc_B4_B244              ; $B231
  ldx #$07                     ; $B233
  ldy #$05                     ; $B235
  lda (Tmp00),y                ; $B237
  cmp #$08                     ; $B239
  beq Loc_B4_B23E              ; $B23B
  inx                          ; $B23D
Loc_B4_B23E:
  txa                          ; $B23E
  sta (Tmp00),y                ; $B23F
  jmp SetObjectFrame           ; $B241
Loc_B4_B244:
  lda #$08                     ; $B244
  sta (Tmp00),y                ; $B246
  jsr AdvanceObjectState       ; $B248
  lda #$27                     ; $B24B
  jmp QueueSound               ; $B24D
MazeObjType17State3:
  ldy #$0B                     ; $B250  [heuristic code]
  jsr DecObjectField           ; $B252
  tax                          ; $B255
  lda Data_B4_B266,x           ; $B256
  ldy #$01                     ; $B259
  sta (Tmp00),y                ; $B25B
  txa                          ; $B25D
  beq Loc_B4_B263              ; $B25E
  jmp SetObjectFrame           ; $B260
Loc_B4_B263:
  jmp RemoveObject             ; $B263
Data_B4_B266:
  .incbin "prg_bank_4.bin", $3266, $8  ; $B266
MazeObjType18:
  ldy #$08                     ; $B26E
  lda (Tmp00),y                ; $B270
  asl a                        ; $B272
  tax                          ; $B273
  lda Data_B4_B281,x           ; $B274
  sta z:$6D                    ; $B277
  lda Data_B4_B282,x           ; $B279
  sta z:$6E                    ; $B27C
  jmp ($006D)                  ; $B27E
Data_B4_B281:
  .addr MazeObjType18State0, MazeObjType18State1, MazeObjType18State2  ; $B281 pointer table
MazeObjType18State0:
  lda #$FF                     ; $B287
  ldy #$0B                     ; $B289
  sta (Tmp00),y                ; $B28B
  lda #$0D                     ; $B28D
  jsr DamagePlayer             ; $B28F
  jsr LoadObjectSpeedFromType  ; $B292
  jmp AdvanceObjectState       ; $B295
MazeObjType18State1:
  ldy #$0B                     ; $B298
  jsr IncObjectField           ; $B29A
  bne Loc_B4_B2A0              ; $B29D
  rts                          ; $B29F
Loc_B4_B2A0:
  cmp #$0A                     ; $B2A0
  bcc MazeObjType18State2      ; $B2A2
  lda #$00                     ; $B2A4
  ldy #$0A                     ; $B2A6
  sta (Tmp00),y                ; $B2A8
  jsr AdvanceObjectState       ; $B2AA
MazeObjType18State2:
  ldy #$0B                     ; $B2AD
  jsr IncObjectField           ; $B2AF
  and #$0F                     ; $B2B2
  bne Loc_B4_B2BB              ; $B2B4
  lda #$07                     ; $B2B6
  jsr DamagePlayer             ; $B2B8
Loc_B4_B2BB:
  jmp DamageFlashStep          ; $B2BB
MazeObjType19:
  ldy #$08                     ; $B2BE
  lda (Tmp00),y                ; $B2C0
  bne Loc_B4_B2E3              ; $B2C2
  lda #$01                     ; $B2C4
  sta (Tmp00),y                ; $B2C6
  lda MazeItemFullRestore      ; $B2C8
  ora $050A                    ; $B2CB
  bne Loc_B4_B2D8              ; $B2CE
  ldy #$00                     ; $B2D0
  lda (Tmp00),y                ; $B2D2
  and #$7F                     ; $B2D4
  sta (Tmp00),y                ; $B2D6
Loc_B4_B2D8:
  lda #$A3                     ; $B2D8
  ldy #$01                     ; $B2DA
  sta (Tmp00),y                ; $B2DC
  lda #$01                     ; $B2DE
  jmp SetObjectFrame           ; $B2E0
Loc_B4_B2E3:
  ldy #$0B                     ; $B2E3
  jsr DecObjectField           ; $B2E5
  beq Loc_B4_B2EF              ; $B2E8
  and #$01                     ; $B2EA
  jmp SetObjectFrame           ; $B2EC
Loc_B4_B2EF:
  jmp RemoveObject             ; $B2EF
MazeObjType1B:
  ldy #$08                     ; $B2F2
  lda (Tmp00),y                ; $B2F4
  asl a                        ; $B2F6
  tax                          ; $B2F7
  lda Data_B4_B305,x           ; $B2F8
  sta z:$6D                    ; $B2FB
  lda Data_B4_B306,x           ; $B2FD
  sta z:$6E                    ; $B300
  jmp ($006D)                  ; $B302
Data_B4_B305:
  .addr Sub_B4_B315, WaitObjectTimer, CollectFullRestoreItem, Sub_B4_B34D, MazeObjType11State4, MazeObjType11State4, MazeObjType11State4, RemoveObjectWithPpuListD  ; $B305 pointer table
Sub_B4_B315:
  lda MazeItemFullRestore      ; $B315
  beq Loc_B4_B31D              ; $B318
  jmp RemoveObject             ; $B31A
Loc_B4_B31D:
  jsr Sub_B4_B3B2              ; $B31D
  lda #$05                     ; $B320
  jmp Loc_B4_B389              ; $B322
CollectFullRestoreItem:
  lda JoyNew1                  ; $B325  [heuristic code]
  and #$01                     ; $B328
  beq Loc_B4_B34C              ; $B32A
  lda #$01                     ; $B32C
  sta MazeItemFullRestore      ; $B32E
  sta z:AmmoHi                 ; $B331
  jsr QueueSound               ; $B333
  lda #$90                     ; $B336
  sta z:AmmoLo                 ; $B338
  lda #$C8                     ; $B33A
  sta z:PlayerLifeLo           ; $B33C
  ldy #$00                     ; $B33E
  lda (Tmp00),y                ; $B340
  and #$7F                     ; $B342
  sta (Tmp00),y                ; $B344
  jsr RequestPpuListE          ; $B346
  jmp AdvanceObjectState       ; $B349
Loc_B4_B34C:
  rts                          ; $B34C
Sub_B4_B34D:
  lda #$0F                     ; $B34D
  sta $0532                    ; $B34F
  lda #$00                     ; $B352
  sta $0533                    ; $B354
  lda #$10                     ; $B357
  sta $0534                    ; $B359
  lda #$05                     ; $B35C
  sta PpuOpRequest             ; $B35E
  jmp AdvanceObjectState       ; $B361
RemoveObjectWithPpuListD:
  jsr RequestPpuListD          ; $B364
  jmp RemoveObject             ; $B367
MazeObjType2C:
  ldx #$06                     ; $B36A
Loc_B4_B36C:
  lda z:$73,x                  ; $B36C
  cmp Data_B4_B382,x           ; $B36E
  bne Loc_B4_B37F              ; $B371
  dex                          ; $B373
  bpl Loc_B4_B36C              ; $B374
  lda #$45                     ; $B376
  ldy #$00                     ; $B378
  sta (Tmp00),y                ; $B37A
  jmp MazeObjType05            ; $B37C
Loc_B4_B37F:
  jmp RemoveObject             ; $B37F
Data_B4_B382:
  .incbin "prg_bank_4.bin", $3382, $7  ; $B382
Loc_B4_B389:
  jsr StartPaletteFade         ; $B389
Loc_B4_B38C:
  lda #$00                     ; $B38C
  jsr SetObjectFrame           ; $B38E
  jsr LoadObjectSpeedFromType  ; $B391
  jmp AdvanceObjectState       ; $B394
Data_B4_B397:
  .incbin "prg_bank_4.bin", $3397, $8  ; $B397
Sub_B4_B39F:
  jsr RandomByteMixed          ; $B39F
  and #$07                     ; $B3A2
  tay                          ; $B3A4
  sty z:$60                    ; $B3A5
  ldx Data_B4_B397,y           ; $B3A7
  lda #$68                     ; $B3AA
  jsr Sub_B4_B3BC              ; $B3AC
  ldx z:$60                    ; $B3AF
  rts                          ; $B3B1
Sub_B4_B3B2:
  lda #$0A                     ; $B3B2
  ldy #$0B                     ; $B3B4
  sta (Tmp00),y                ; $B3B6
  lda #$AE                     ; $B3B8
  ldx #$80                     ; $B3BA
Sub_B4_B3BC:
  jsr Sub_B4_B3C2              ; $B3BC
  txa                          ; $B3BF
  iny                          ; $B3C0
  bit $01A0                    ; $B3C1
  sta (Tmp00),y                ; $B3C4
  rts                          ; $B3C6
Sub_B4_B3C7:
  ldy #$0E                     ; $B3C7
  lda (Tmp00),y                ; $B3C9
  adc #$1C                     ; $B3CB
  sta (Tmp00),y                ; $B3CD
  dey                          ; $B3CF
  lda (Tmp00),y                ; $B3D0
  adc #$00                     ; $B3D2
  sta (Tmp00),y                ; $B3D4
  ldy #$01                     ; $B3D6
  bne Loc_B4_B3E0              ; $B3D8
AddObjectXVelocity:
  ldy #$0C                     ; $B3DA
  lda (Tmp00),y                ; $B3DC
  ldy #$02                     ; $B3DE
Loc_B4_B3E0:
  clc                          ; $B3E0
  adc (Tmp00),y                ; $B3E1
  sta (Tmp00),y                ; $B3E3
  rts                          ; $B3E5
  .incbin "prg_bank_4.bin", $33E6, $8  ; $B3E6
Sub_B4_B3EE:
  and #$1F                     ; $B3EE
  sta (Tmp00),y                ; $B3F0
SetObjectFlagsE0:
  ldy #$0A                     ; $B3F2
  lda (Tmp00),y                ; $B3F4
  ora #$E0                     ; $B3F6
  sta (Tmp00),y                ; $B3F8
  rts                          ; $B3FA
SetObjectFlagsC0:
  lda (Tmp00),y                ; $B3FB
  ora #$C0                     ; $B3FD
  sta (Tmp00),y                ; $B3FF
  rts                          ; $B401
AddObjectOfType:
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
Sub_B4_B415:
  ldx #$02                     ; $B415
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
ResetScrollAndObjectFlags:
  lda #$00                     ; $B42A
  sta z:HwScrollX              ; $B42C
  sta z:HwScrollY              ; $B42E
  ldy #$0B                     ; $B430
  sta (Tmp00),y                ; $B432
  lda #$FF                     ; $B434
  ldy #$0D                     ; $B436
  sta (Tmp00),y                ; $B438
  inc z:$84                    ; $B43A
  rts                          ; $B43C
DamagePlayer:
  sta z:$6A                    ; $B43D
  lda z:PlayerLifeLo           ; $B43F
  sec                          ; $B441
  sbc z:$6A                    ; $B442
  sta z:PlayerLifeLo           ; $B444
  bcs Loc_B4_B44A              ; $B446
  dec z:PlayerLifeHi           ; $B448
Loc_B4_B44A:
  rts                          ; $B44A
AddLifeAndAmmo:
  clc                          ; $B44B
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
UpdateAllObjectHandlers:
  jsr LoadObjectCountIndex     ; $B474
  beq Loc_B4_B4B1              ; $B477
Loc_B4_B479:
  jsr DispatchObjectHandler    ; $B479
  dec ObjectLoopIndex          ; $B47C
  bne Loc_B4_B479              ; $B47F
  ldy #$06                     ; $B481
  lda Data_C347,y              ; $B483
  sta z:Tmp02                  ; $B486
  jsr LoadObjectCountIndex     ; $B488
  beq Loc_B4_B4B1              ; $B48B
Loc_B4_B48D:
  ldx #$00                     ; $B48D
  lda ObjectLoopIndex          ; $B48F
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
  dec ObjectLoopIndex          ; $B4AC
  bne Loc_B4_B48D              ; $B4AF
Loc_B4_B4B1:
  rts                          ; $B4B1
LoadObjectCountIndex:
  lda ObjectCount              ; $B4B2
  and #$0F                     ; $B4B5
  sta ObjectLoopIndex          ; $B4B7
  rts                          ; $B4BA
DispatchObjectHandler:
  lda ObjectLoopIndex          ; $B4BB
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
  .incbin "prg_bank_4.bin", $34DD, $59  ; $B4DD
MazeObjType00:
  rts                          ; $B536
  .incbin "prg_bank_4.bin", $3537, $49  ; $B537
Data_B4_B580:
  .incbin "prg_bank_4.bin", $3580, $1  ; $B580
Data_B4_B581:
  .incbin "prg_bank_4.bin", $3581, $400  ; $B581
  .incbin "prg_bank_4.bin", $3981, $400  ; $B981
  .incbin "prg_bank_4.bin", $3D81, $27C  ; $BD81
Data_B4_BFFD:
  .incbin "prg_bank_4.bin", $3FFD, $3  ; $BFFD
