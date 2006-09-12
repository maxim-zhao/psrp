;
; RLE/LZ bitmap decoder
; - Phantasy Star Gaiden
;
; Written in TASM 3.0.1
;

#define VRAM_PTR $DFC0		; VRAM address
#define BUFFER $DFD0		; 32-byte buffer


.org $7e84			; $4BE84-4BF73

	PUSH AF			; Save registers
	PUSH BC
	PUSH DE
	PUSH HL
	PUSH IX
	PUSH IY

	LD (VRAM_PTR),HL	; Cache VRAM offset

	PUSH DE			; New source register
	POP IX

	LD C,(IX)		; Load # tiles to decode
	INC IX
	LD B,(IX)
	INC IX

Tiles_Loop:
	PUSH BC			; Save # runs

	LD C,(IX)		; Decoder method selection
	INC IX

	LD B,$04		; 4 color planes
	LD DE,BUFFER

	; Decoder method
	; - 00 = 8 $00's
	; - 01 = 8 $FF's
	; - 10 = RLE/LZ extended
	; - 11 = 8 raw bytes

Plane_Decode:
	RLC C			; 00/01
	JR NC,All_Bytes

	RLC C			; 11
	JR C,Free_Bytes

; ------------------------------------------------------

	LD A,(IX)		; RLE/LZ selection
	INC IX

	EX DE,HL		; Lower 2 bits = LZ-window
	LD D,A
	AND $03
	ADD A,A
	ADD A,A
	ADD A,A
	LD E,A

	LD A,D			; LZ-window cursor
	LD D,$00
	LD IY,BUFFER
	ADD IY,DE
	EX DE,HL

	CP $03			; Check RLE/LZ pattern
	JR C,LZ_Normal
	CP $10
	JR C,RLE_Mix
	CP $13
	JR C,LZ_Invert
	CP $20
	JR C,RLE_Mix
	CP $23
	JR C,LZ_Mix_Normal
	CP $40
	JR C,RLE_Mix
	CP $43
	JR C,LZ_Mix_Invert

; ------------------------------------------------------

RLE_Mix:
	LD H,A			; Set 8-bit decode pattern
	LD L,(IX)		; Set RLE byte
	INC IX
	JR RLE_Init


Free_Bytes:
	LD H,$00		; 8 raw bytes
	JR RLE_Init


All_Bytes:
	RLC C			; Dummy bit

	SBC A,A			; $00 or $FF is cache byte
	LD L,A

	LD H,$FF		; 8 RLE's pattern mask


RLE_Init:
	PUSH BC			; 8 runs
	LD B,$08

RLE_Loop
	LD A,L			; Load cached (RLE) byte

	RLC H			; Check pattern mask: Free or RLE
	JR C,RLE_Store

RLE_Free:
	LD A,(IX)		; Read raw byte
	INC IX

RLE_Store:
	LD (DE),A		; Store byte, keep decoding
	INC DE
	DJNZ RLE_Loop

	POP BC			; Proceed to next color plane
	JR End_Loop

; ------------------------------------------------------

LZ_Normal:
	LD HL,$FF00		; 8 LZ transactions
	JR LZ_Init


LZ_Invert:
	LD HL,$FFFF		; 8 LZ runs (inversion)
	JR LZ_Init


LZ_Mix_Normal:
	LD H,(IX)		; Load pattern mask
	LD L,$00		; No inversion
	INC IX
	JR LZ_Init


LZ_Mix_Invert:
	LD H,(IX)		; Load pattern mask
	LD L,$FF		; Inversion
	INC IX


LZ_Init:
	PUSH BC			; 8 Runs
	LD B,$08

LZ_Loop:
	LD A,(IY)		; Load byte at LZ window cursor
	INC IY

	XOR L			; Full inversion if needed

	RLC H			; Decode: Free or LZ
	JR C,LZ_Store

	LD A,(IX)		; Load raw
	INC IX

LZ_Store:
	LD (DE),A		; Enter data until exhausted
	INC DE
	DJNZ LZ_Loop

	POP BC

; ------------------------------------------------------

End_Loop:
	DEC B			; One fewer color planes
	JP NZ,Plane_Decode

	LD DE,(VRAM_PTR)	; Set VRAM address
	DI
	RST 08H

	LD DE,$0008		; Color planes grouped in bytes of 8
	LD C,E

	LD HL,BUFFER		; 4-bpp tile address

Write_Loop:
	LD B,$04		; 4 color planes
	PUSH HL

Write_VRAM:
	LD A,(HL)		; Grab byte
	OUT ($BE),A		; Write to VRAM
	ADD HL,DE		; Bump to next plane
	DJNZ Write_VRAM

	POP HL			; Go to next byte in sequence
	INC HL
	DEC C
	JR NZ,Write_Loop

	EI			; Update new VRAM offset
	LD HL,(VRAM_PTR)
	LD BC,$0020
	ADD HL,BC
	LD (VRAM_PTR),HL

	POP BC			; Determine # tiles left to decode
	DEC BC
	LD A,B
	OR C
	JP NZ,Tiles_Loop

	POP IY			; Done
	POP IX
	POP HL
	POP DE
	POP BC
	POP AF
	RET

	.end			; TASM-only
