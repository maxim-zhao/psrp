;
; Item window drawer (shop)
; - setup code
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $3a1f			; $3a1f-3a35

	ld a,$2f000/$4000	; jump to page 1
	ld ($fffe),a

	call $7e3e+$28+$06

	ld a,$01		; old page 1
	ld ($fffe),a

	nop
	nop
	nop

	nop
	nop

	nop
	nop
	nop
	nop
	nop

.end				; tasm-only
