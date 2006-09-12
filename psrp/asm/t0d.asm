;
; BG NT output
;
; Written in TASM 3.0.1
;

.org $34f2			; $34f2-3545

	DI			; Prepare VRAM output
	PUSH BC
	PUSH DE

	PUSH AF
	RST 08H			; Set address
	POP AF

	; LD A,(HL)		; A = decoded byte
	ADD A,A			; 2-byte table

	LD BC,$8000		; index into table
	ADD A,C
	LD C,A

	ADC A,B			; overflow accounting
	SUB C
	LD B,A

	LD A,(BC)		; load low NT-byte
	OUT ($BE),A
	PUSH AF			; VRAM wait
	POP AF

	INC BC			; write out high NT-byte
	LD A,(BC)
	OUT ($BE),A

	POP DE			; Bump VRAM address
	INC DE
	INC DE
	POP BC

	EI			; Wait for VBlank
	LD A,$0A
	CALL $0056

	DEC B			; Shrink window width
	RET
.end
