;
; Text window drawer multi-line handler
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $000f			; $000f-$0032

newline:
    ld b,$12 ; reset x counter                              ; 06 xx
    inc hl   ; move pointer to next byte                    ; 23
    ld a,c   ; get line counter                             ; 79
    or a     ; test for c==0                                ; b7
    jr nz,not_zero                                          ; xx xx
    ; zero: draw on 2nd line
    ld de,$7d0e                                             ; xx xx xx
inc_and_finish:
    inc c                                                   ; xx
    jp $3365                                                ; xx xx xx
not_zero:
    dec a    ; test for c==1                                ; 3d
    jr nz,not_one                                           ; xx xx
    ; one: draw on 3rd
draw_3rd_line:
    ld de,$7d4e                                             ; xx xx xx
    jr inc_and_finish                                       ; xx xx
not_one:
    dec a    ; test for c==2                                ; 3d
    jr nz,not_two                                           ; xx xx
    ; two: draw on 4th
draw_4th_line:
    ld de,$7d8e                                             ; xx xx xx
    jr inc_and_finish                                       ; xx xx
not_two:
    ; three: scroll, draw on 4th line
    call $3546 ; scroll                                     ; xx xx xx
    dec c      ; cancel increment                           ; xx
    jr draw_4th_line                                        ; xx xx

.end				; tasm-only
