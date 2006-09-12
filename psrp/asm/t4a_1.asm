;
; Semi-adaptive Huffman decoder
; - Init decoder
;
; Written in TASM 3.0.1
;

#include "vars.asm"

#define CODE $7fd8c/$4000	; bank with 'backup' code


.org $bf50			; $bf50-bf9b

	PUSH AF			; Save routine selection

	LD A,CODE		; Map in new page 1
	LD ($FFFE),A

	LD A,EOS		; Starting tree symbol
	LD (TREE),A

	LD A,$80		; Initial tree barrel
	LD (BARREL),A

	LD (SCRIPT),HL		; Beginning script offset

	XOR A			; A = $00
	LD (POST_LEN),A		; No post hints
	LD (LINE_NUM),A		; No lines drawn
	LD (FLAG),A		; No wait flag
;	LD (PLAYER),A		; Do not reset (assume proper usage)
	LD (ARTICLE),A		; No article usage
	LD (SUFFIX),A		; No suffix flag

	POP AF			; Choose code reloading method
	OR A
	JR NZ,Path2

Path1:				; Cutscene handler
	LD DE,$7c42		; Old code
	LD BC,$0000
	LD A,$06		; Set internal wrapping limit
	LD (VLIMIT),A

	XOR A
	CALL $34b0		; Allow remapping of page 1 upon exit
	JR Restore

Path2:				; In-game scripter
	LD A,$04		; Set internal wrapping limit
	LD (VLIMIT),A

	LD A,($c2d3)		; Old code
	OR A
	CALL $3343		; Allow remapping of page 1 upon exit

Restore:
	LD A,$01		; Put back old 'page 1'
	LD ($FFFE),A

	RET

	.end			; TASM-only
