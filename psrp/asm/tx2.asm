;
; Name entry screen patch for code that writes to the in-RAM name table copy
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $429b			; $429b-$42b4 inclusive

WriteLetterIndexAToDE: ; $429b
; parameters:
; de = where to write tile data (pointing to lower tile of pair)
; a = char number (space = 0)
; returns:
; c = low byte of name table value
; a = high byte
    push   hl
    ex     de,hl
    ld     hl,$ffff
    ld     (hl),$02
    ld     hl,$8000
    ld     c,a
    ld     b,$00
    add    hl,bc
    add    hl,bc
; Original code:
;    ld     c,(hl)          ; 4E       ; get value in c,a
;    inc    hl              ; 23
;    ld     a,(hl)          ; 7E
;    ld     (de),a          ; 12       ; write to address passed in in de
;    ld     hl,-64          ; 21 C0 FF
;    add    hl,de           ; 19       ; and 1 row above it
;    ld     (hl),c          ; 71
; Patch:
    ld a,(hl)              ; 7E
    ld (de),a              ; 12
    ld c,a                 ; 4F
    inc hl                 ; 23
    inc de                 ; 13
    ld a,(hl)              ; 7E
    ld (de),a              ; 12
; End patch
    pop    hl
    ret

; 2 bytes smaller

.end				; tasm-only
