;
; Narrative number BCD creater
;
; Written in TASM 3.0.1
;

#include "vars.asm"


.org $33FE			; $33FE-3493 ($96)

	PUSH HL			; Save string ptr
	PUSH BC			; Width, temp
	; PUSH DE		; Save VRAM ptr
	PUSH IX			; Temp

	LD HL,($C2C5)		; Load 16-bit parameter
	LD IX,TEMP_STR		; Decode to buffer

	LD BC,$2710		; # 10000's
	CALL BCD_Digit
	LD (IX+$00),A

	LD BC,$03E8		; # 1000's
	CALL BCD_Digit
	LD (IX+$01),A

	LD BC,$0064		; # 100's
	CALL BCD_Digit
	LD (IX+$02),A

	LD BC,$000A		; # 10's
	CALL BCD_Digit
	LD (IX+$03),A

	LD A,L			; # 1's
	ADD A,$01
	LD (IX+$04),A

	LD B,$04		; look at 4 digits max
	LD HL,TEMP_STR		; scan value

Scan:
	LD A,(HL)		; load digit
	CP $01			; check for '0'
	JR NZ,Done
	INC HL			; bump pointer
	DJNZ Scan

Done:
	LD A,B
	INC A			; 1 <= length <= 5
	LD (STR),HL		; save ptr
	LD (LEN),A		; save length

; ------------------------------------------------------------

	CP $01
	JR NZ,Store_Suffix	; length must be 1

	LD A,(HL)
	CP $02			; last digit = '1'
	JR NZ,Store_Suffix

No_Suffix:
	XOR A			; Clear flag

Store_Suffix:
	LD (SUFFIX),A		; 'x' mesata(s)

; ------------------------------------------------------------

	POP IX			; Restore stack
	POP BC
	POP HL

	INC HL			; Process next script
	JP $3365

; ____________________________________________________________

BCD_Digit:
	LD A,$00		; Init digit value
				; Note: $01 = '0', auto-bump
	OR A			; Clear carry flag

BCD_Loop:
	SBC HL,BC		; Divide by subtraction
	INC A			; Bump place marker
	JR NC,BCD_Loop		; No underflow

	ADD HL,BC		; Restore value
	RET

	.end			; TASM-only
