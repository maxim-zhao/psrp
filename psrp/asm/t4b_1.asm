;
; RLE/LZ bitmap decoder
; - support mapper
;
; Written in TASM 3.0.1
;

#define DECODER $7e84		; $4BE84


.org $0486			; $486-4b0, * free

	LD A,$12		; Remap page 1
	LD ($FFFE),A

	CALL DECODER

	LD A,$01		; Restore page 1
	LD ($FFFE),A

	RET

	.end			; TASM-only
