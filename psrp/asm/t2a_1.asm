;
; Item window drawer (inventory)
; - setup code
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $3671			; $3671-367f

	ld a,$2f000/$4000	; jump to page 1
	ld ($fffe),a

	call $7e3e

	ld a,$01		; old page 1
	ld ($fffe),a

	nop
	nop

	; 0 bytes left

.end				; tasm-only
