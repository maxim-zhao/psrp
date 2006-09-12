;
; Item lookup
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $33da			; $33da-33f3

	PUSH HL			; Save string ptr
	PUSH DE			; Save VRAM ptr
	PUSH BC			; Save width, temp

	LD A,($c2c4)		; Grab item #
	LD HL,ITEMS		; Item lookup

; .org $33e3

	CALL DICT

	POP BC
	POP DE
	POP HL
	JP $3365		; Decode next byte

	.end 			; TASM-only
