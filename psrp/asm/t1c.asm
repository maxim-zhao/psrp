;
; Dictionary lookup
;
; Written in TASM 3.0.1
;

#include "vars.asm"

;.org $7d8d			; $7fd8d-7fdbf ($33)
.org $3eca ; fix: avoid paging in slot 0 (see t2a.asm)

	; HL = Table offset
	; PUSH DE
	; PUSH BC

Normal:
	PUSH AF
	LD A,$77000/$4000	; Load normal lists
	LD ($FFFF),A
	JR Search_Init

Substring:
	PUSH AF
	LD A,$43c00/$4000	; Load dictionary
	LD ($FFFF),A

; ----------------------------------------------------

Search_Init:
	POP AF			; Restore index #
	LD B,$00		; 0-255 indices

Search:
	LD C,(HL)		; Grab string length
	OR A			; Check for zero strings left
	JR Z,Copy		; Stop if found

	INC HL			; Bypass length byte
	ADD HL,BC		; Bypass physical string
	DEC A			; One less item to look at
	JR Search		; Keep searching

Copy:
	LD A,C			; Transfer length
	LD (LEN),A		; Save length
	INC HL			; Skip length byte

	LD DE,TEMP_STR		; Copy to work RAM
	LD (STR),DE		; Save pointer location
	LDIR

; ---------------------------------------------------

	DEC HL			; Check last character
	LD A,(HL)

	CP LETTER_S		; <name>'s attack
	JR NZ,Store_Suffix

	XOR A			; Clear flag

Store_Suffix:
	LD (SUFFIX),A

; ---------------------------------------------------

	LD A,$02		; Normal page
	LD ($FFFF),A

;	POP BC			; Restore registers and exit
;	POP DE

	RET

	.end 			; TASM-only
