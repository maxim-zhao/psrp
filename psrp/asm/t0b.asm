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


.org $45a4

; replace an in-line font decoding setup with a new one that's reusable,
; because it has a ret after it

  call DECODE_FONT
  jr AFTER

DECODE_FONT:    ; reusable elsewhere now: $45a9
	ld hl,$FFFF		; Load font bank
	ld (hl),$10

	ld de,FONT1		; Decode table 1
	ld hl,VRAM1
	call DECODER

	ld de,FONT2		; Decode table 2
	ld hl,VRAM2
	call DECODER
	ret
	
	nop ; this version is actually 3 bytes smaller now... need to nop out old code
	nop ; to continue correctly
	nop

AFTER:

; was:
; ld hl,$ffff        SetPage TilesFont
; ld (hl),$10
; ld hl,$bad8        ld hl,TilesFont
; ld de,$5800        TileAddressDE $c0
; call $04b3         call LoadTiles4BitRLE
; ld hl,$bebe        ld hl,TilesExtraFont
; ld de,$7e00        TileAddressDE $1f0
; call $04b3         call LoadTiles4BitRLE
; ld hl,$bf5e        ld hl,TilesExtraFont2
; ld de,$5700        TileAddressDE $b8
; call $04b3         call LoadTiles4BitRLE


	.end			; TASM-only
