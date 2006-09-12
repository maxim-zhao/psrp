;
; Narrative formatter
; - Extra scripting codes
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $7e00			; $7fe00-7fecf

Start:
	CALL CACHE		; Check substring RAM

	CP NEWLINE
	JR Z,No_decode

	CP EOS			; Look for decode flag
	JP NZ,Done

Decode:
	CALL DECODER 		; Regular decode

No_decode:

; ______________________________________________________

Code1:
	CP $59			; Post-length hints
	JR NZ,Code2		; Check next code

	CALL DECODER 		; Grab length
	LD (POST_LEN),A		; Cache it
	JR Decode		; Immediately grab next code

; ______________________________________________________

Code2:
	CP $00			; Whitespace
	JR NZ,Code3		; Check next code

	PUSH HL
	LD (TEMP_STR),A		; Store WS, $00
	INC A			; A = $01
	LD (LEN),A		; Store length
	LD HL,TEMP_STR		; Load string location
	LD (STR),HL		; Store string pointer
	POP HL

	CALL CACHE		; Our new dictionary lookup code
				; will do auto-formatting

	; Intentional fall-through

; ______________________________________________________

Code3:
	CP $55			; - wait more
	JR NZ,Code4

Reset_Lines:
	PUSH AF
	XOR A

Set_Lines:
	LD (LINE_NUM),A		; Clear # lines used
	POP AF

	JP Done

; _________________________________________________________

Code4:
	CP $54			; Newline check
	JR NZ,Code5		; Next code

	PUSH HL			; Automatic narrative waiting

	LD HL,LINE_NUM		; Grab # lines drawn
	INC (HL)		; One more line break
	LD L,(HL)		; Load current value

	LD A,(VLIMIT)		; Read vertical limit
	CP L			; Check if limit reached
	JR Z,WAIT

NO_WAIT:
	LD A,NEWLINE		; Reload newline
	JR Code4_End

WAIT:
	LD A,$55		; wait more
	LD (FLAG),A		; Raise flag
	LD HL,LINE_NUM

Wait_Clear:
	DEC (HL)		; Keep shrinking # lines drawn
	JR NZ,Wait_Clear	; to save 1 byte of space

Code4_End:
	POP HL			; Restore stack
	JR Done

; ______________________________________________________

Code5:
	CP $60
	JR C,Code6		; Control codes, don't interfere

	SUB $60			; Relocate dictionary entry #

	PUSH HL
	PUSH DE
	PUSH BC

	LD HL,WORDS
	CALL DICT_2		; Relocate substring entry and copy

	POP BC
	POP DE
	POP HL

	JP Start		; Our new dictionary lookup code

	; JR Code4		; Go back for formatting concerns

; ______________________________________________________

Code6:
	CP $5A			; Use article
	JR NZ,Code7

	CALL DECODER		; Grab #
	LD (ARTICLE),A
	JP Decode

; ______________________________________________________

Code7:
	CP $5B			; Use suffix
	JR NZ,Code8

	LD A,(SUFFIX)		; Check flag
	OR A
	JP Z,Decode		; No 's' needed

	LD A,LETTER_S		; add 's'

; ______________________________________________________

Code8:
	; ---

Done:
	CP $58			; Old code
	RET			; Go to remaining text handler

	.end			; TASM-only
