;
; Name entry screen patch for code that writes to the in-RAM name table copy
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $42b5			; $42b5-$42cb inclusive

WriteLetterToTileMapDataAndVRAM: ; $42b5
; Parameters:
; a = tile index (space = 0)
; de = where to write tiles to
; hl = cursor location (from GetCursorLocation)
    call   $429b           ; CD 9B 42 ; WriteLetterIndexAToDE
    ; c,a are the tile indices for the chosen tile
    ld     b,a             ; 47
    ld     a,h             ; 7C       ; get cursor location in TileMapData
    sub    $58             ; D6 58    ; reduce it by $5800 to make it the VRAM address
    ld     h,a             ; 67
    ex     de,hl           ; EB
    rst    08h             ; CF       ; SetVRAMAddressToDE
; Original code:
;    ld     a,b             ; 78       ; write tiles to VRAM
;    out    ($be),a         ; D3 BE
;    ld     hl,-64          ; 21 C0 FF
;    add    hl,de           ; 19
;    ex     de,hl           ; EB
;    rst    08h             ; CF
;    ld     a,c             ; 79
;    out    ($be),a         ; D3 BE
; Patch:
    ld     a,c             ; 79
    out    ($be),a         ; D3 BE
    ld     a,b             ; 78
    out    ($be),a         ; D3 BE
; End patch
    ret                    ; C9

.end				; tasm-only

; 6 bytes smaller
