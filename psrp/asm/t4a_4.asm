;
; Narrative formatter
; - Interrupt paging
;
; Written in TASM 3.0.1
;

#include "vars.asm"


.org $494			; $494-4a5

	LD A,($FFFE)		; Save page 1
	PUSH AF

	LD A,$01		; Regular page 1
	LD ($FFFE),A

	CALL $127		; Resume old code

	POP AF
	LD ($FFFE),A		; Put back page 1

	POP AF			; Leave ISR manually
	EI
	RET

	.end			; TASM-only
