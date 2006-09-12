;
; Name entry screen patch to draw extended characters
;
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $443e			; $443e-$448b inclusive

; So hl = tilemap data (both bytes)
; b = height /tiles
; c = 2*width /tiles
; de = VRAM location
; OutputTilemapRawDataBox: ; $0428
    call $03de  ; the call I stole to get here
    ld bc,$010e ; 14 bytes per row, 1 row
    ld de,$7bec ; Tilemap location 22,15
    ld hl,data
    call $0428  ; output raw tilemap data
    ret

data:
.dw $07f5,$01f4,$01fa,$01fb,$01f6,$01f5,$01f7
;     ,     :     -     !     ?   left' right'

.end				; tasm-only

