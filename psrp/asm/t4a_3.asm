;
; Narrative formatter
; - Dictionary processing
;
; Written in TASM 3.0.1
;

#include "vars.asm"


.org $7ed0			; $7fed0-7ffaf ($e0)

Check_Autowait:
	; LD A,(FLAG)		; Scan flag
	; OR A			; See if auto-wait occurred
	; JR Z,Lookup		; Not raised

	; XOR A			; Lower flag
	; LD (FLAG),A
	; XOR A			; Reset it to zero
	; LD (LINE_NUM),A
	; LD A,NEWLINE		; Need to emit a newline [NOT NEEDED]
	; RET			; No decoding needed

; ______________________________________________________

Lookup:
	LD A,(LEN)		; Grab length of string
	OR A			; Check for zero-length
	LD A,EOS		; Load 'abort' flag
	RET Z			; Return if NULL

Substring:
	LD A,B			; Save width
	LD (HLIMIT),A

	PUSH HL			; Stack registers
	PUSH BC

	LD BC,(STR)		; Grab raw text location
	LD HL,LEN		; Grab address of length

; ------------------------------------------------------

	PUSH DE			; init

	LD A,(ARTICLE)		; Check for article usage
	OR A
	JR Z,Art_Exit		; article = none

	LD DE,TAB1
	CP $01			; article = a,an,the
	JR Z,Start_Art

	LD DE,TAB2
;	CP $02			; article = A,AN,THE
;	JR Z,Start_Art

Start_Art:
	LD A,(BC)		; Grab index
	SUB $54			; Remap index range
	ADD A,A			; Multiply by two
	ADD A,E			; Add offset
	LD E,A			; (note: be careful we don't byte-wrap)

	LD A,(DE)		; Grab final string offset
	INC DE
	PUSH AF
	LD A,(DE)
	LD D,A
	POP AF
	LD E,A

Add_Art:
	LD A,(DE)		; grab font #
	CP EOS
	JR Z,Art_Done

	DEC BC			; bump dst pointer
	LD (BC),A		; add tile
	INC DE			; bump src
	INC (HL)		; bump length
	JR Add_Art

Art_Done:
	LD (STR),BC		; store new text pointer
	XOR A
	LD (ARTICLE),A		; lower flag
		
Art_Exit:
	POP DE			; now proceed normally
	LD BC,(STR)		; Grab raw text location (again)
	JR Initial_Codes
	

; Articles in 'reverse' order

TAB1		.dw ART_11, ART_12, ART_13
ART_11		.db $00,$25,EOS			; 'a '
ART_12		.db $00,$32,$25,EOS		; 'an '
ART_13		.db $00,$29,$2c,$38,EOS		; 'the '
ART_14		.db $00,$29,$31,$33,$37,EOS	; 'some '

TAB2		.dw ART_21, ART_22, ART_23
ART_21		.db $00,$0b,$ff			; 'A '
ART_22		.db $00,$28,$0b,$ff		; 'An '
ART_23		.db $00,$29,$2c,$1e,$ff		; 'The '
ART_24		.db $00,$29,$31,$33,$1d,EOS	; 'Some '

; TAB3
; ART_31
; ART_32

; ________________________________________________________________

Initial_Codes:
	LD A,(BC)		; Grab character
	; CP EOS		; Check for abort code
	; JR Z,Abort_Initial
	CP $4F			; Skip initial codes
	JR C,Begin_Scan		; Look for first real font tile

	INC BC			; Bump pointer
	LD (STR),BC		; Save pointer
	DEC (HL)		; Shrink length
	JR NZ,Initial_Codes	; Loop if still alive

Abort_Initial:
	LD A,EOS		; Return abort #
	POP BC			; Restore stack registers
	POP HL
	JR Abort		; No text

Begin_Scan:
	PUSH HL			; Save new current length
	PUSH BC			; Save new text pointer

	LD H,(HL)		; Init string counter
	LD L,$00		; Current length is zero

;	CALL Scan_String	; Check for wrapping condition
	CALL One_Font

	LD A,(HLIMIT)		; Remaining width
	SUB L			; Remove characters used

;	LD HL,(LIMIT)		; Grab limit pointer
;	INC HL			; Bump pointer
;	INC HL
;	INC HL
;	CP (HL)			; Compare against horizontal limit

;	LD L,$12+$01		; Screen limit without 2 borders
;	CP L			; Compare against horizontal limit

	JR NC,No_Spill		; No text spillage

; ________________________________________________________________

Text_Spill:
	POP BC			; Restore old text pointer
	POP HL			; Reload length pointer

	LD A,(BC)		; Reload first scanned character
	OR A			; Check for whitespace ($00)
	JR NZ,Text_Spill_Line	; Don't eat non-WS

Text_Spill_WS:
	INC BC			; Bump text pointer
	LD (STR),BC		; Store new location

	DEC (HL)		; Shrink length

Text_Spill_Line:
	LD A,NEWLINE		; newline

	POP BC			; Stack registers
	POP HL
	RET			; exit

; ________________________________________________________________

No_Spill:
	POP BC			; Restore original text pointer
	POP HL			; Restore length pointer

	DEC (HL)		; Shrink text length

	LD A,(BC)		; Read in text character
	INC BC			; Bump text pointer
	LD (STR),BC		; Store new location

	POP BC			; Stack registers
	POP HL
	RET

Exit:
	; OR A			; Check for abort
	; RET NZ		; Return if font character

Abort:
	; XOR A			; Length exhausted
	; LD (LEN),A
	; LD A,EOS		; Load 'abort' flag
	; RET			; Done

; ______________________________________________________
; ______________________________________________________

; Note: Treat first character as a regular tile, regardless of WS

Scan_String:
	INC BC			; Bump text cursor
	DEC H			; Shrink text
	JR Z,Stop		; Length exhausted == 0

	LD A,(BC)		; Grab character
	OR A			; Check for abort
	JR Z,Stop		; If char == 0, stop

	CP $4F			; Control codes
	JR NC,Scan_String	; Ignore special script values

	CP $00			; Whitespace
	JR Z,Break		; Break out of scan

One_Font:
	INC L			; One font drawn
	JR Scan_String

Stop:
	LD BC,POST_LEN		; Load post-hint address
	LD A,(BC)		; Load post-hint value
	ADD A,L			; Tack on length
	LD L,A			; Store for return

	XOR A
	LD (BC),A		; Clear post-hint value

Break:
	RET

	.end			; TASM-only
