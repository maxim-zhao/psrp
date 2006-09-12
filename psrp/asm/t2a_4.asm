;
; Equipment window drawer
; - setup code
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $3850			; $3850-385e

	ld a,$2f000/$4000	; jump to page 1
	ld ($fffe),a

	call $7e3e+$9b+$06+$03

	ld a,$01		; old page 1
	ld ($fffe),a

	nop

.end				; tasm-only
