;
; Extra scripting
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $59bd			; $59bd-59c9

	cp $ff			; custom string [1E7]
	jr nz,$59ca

	ld hl,$0000		; dummy string, auto-replace
	jr $59ba

	.end			; TASM-only
