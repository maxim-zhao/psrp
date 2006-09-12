;
; Enemy window drawer
; - setup code
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $3279			; $3279-328a

	ld a,$2f000/$4000	; jump to page 1
	ld ($fffe),a

	call $7e3e+$71+$06

	ld a,$01		; old page 1
	ld ($fffe),a

	nop
	nop
	nop
	nop
	nop

.end				; tasm-only
