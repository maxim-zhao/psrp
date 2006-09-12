;
; Enemy lookup
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $33c8			; $33c8-33d5

	PUSH HL			; Save string ptr
	PUSH DE			; Save VRAM ptr
	PUSH BC			; Save width, temp

	LD A,($c2e6)		; Grab enemy #

	LD HL,ENEMY
	JP $33e3

	.end 			; TASM-only
