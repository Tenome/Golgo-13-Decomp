; Bank 0  ($8000-$BFFF switchable)
; Street-scene level data (maps, tile and object tables). No code of its own: the fixed bank selects it as data (MmcPrgShadow = 0 runs the fixed-bank main code instead of $8010).
.segment "PRG_BANK_0"

  sei                          ; $8000  [heuristic code]
  lda #$80                     ; $8001
  sta Data_B0_BFFD             ; $8003
  jmp Reset                    ; $8006
  .incbin "prg_bank_0.bin", $0009, $400  ; $8009
  .incbin "prg_bank_0.bin", $0409, $400  ; $8409
  .incbin "prg_bank_0.bin", $0809, $400  ; $8809
  .incbin "prg_bank_0.bin", $0C09, $400  ; $8C09
  .incbin "prg_bank_0.bin", $1009, $400  ; $9009
  .incbin "prg_bank_0.bin", $1409, $400  ; $9409
  .incbin "prg_bank_0.bin", $1809, $400  ; $9809
  .incbin "prg_bank_0.bin", $1C09, $400  ; $9C09
  .incbin "prg_bank_0.bin", $2009, $400  ; $A009
  .incbin "prg_bank_0.bin", $2409, $400  ; $A409
  .incbin "prg_bank_0.bin", $2809, $400  ; $A809
  .incbin "prg_bank_0.bin", $2C09, $400  ; $AC09
  .incbin "prg_bank_0.bin", $3009, $400  ; $B009
  .incbin "prg_bank_0.bin", $3409, $400  ; $B409
  .incbin "prg_bank_0.bin", $3809, $400  ; $B809
  .incbin "prg_bank_0.bin", $3C09, $3F4  ; $BC09
Data_B0_BFFD:
  .incbin "prg_bank_0.bin", $3FFD, $3  ; $BFFD
