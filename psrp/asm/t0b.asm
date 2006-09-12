;
; Font decoder support
;
; Written in TASM 3.0.1
;

#define FONT1 $b871
#define FONT2 $ba87

#define VRAM1 $5800
#define VRAM2 $7e00

#define DECODER $486		; New PSG bitmap decoder


.org $45a9			; $45a9-45c3

	LD HL,$FFFF		; Load font bank
	LD (HL),$10

	LD DE,FONT1		; Decode table 1
	LD HL,VRAM1
	CALL DECODER

	LD DE,FONT2		; Decode table 2
	LD HL,VRAM2
	CALL DECODER

	RET

	.end			; TASM-only
