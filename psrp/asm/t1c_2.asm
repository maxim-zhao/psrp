;
; Player lookup
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $33aa			; $33aa-33c3

	PUSH HL			; Save string ptr
	PUSH DE			; Save VRAM ptr
	PUSH BC			; Save width, temp

	LD A,($C2C2)		; Grab item #
	AND $03

	LD HL,NAMES
	JP $33e3

	.end 			; TASM-only
