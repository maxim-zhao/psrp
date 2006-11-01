;
; RLE/LZ bitmap decoder
; - support mapper
;
; Written in TASM 3.0.1
;

#define PSG_DECODER $7e84		; $4BE84 in slot 2


; Redirects calls to LoadTiles4BitRLENoDI@$0486 (decompress graphics, interrupt-unsafe version)
; to a ripped decompressor from Phantasy Star Gaiden which is stored at the above address
; Thus the remainder of the old decompressor is orphaned.

.org $0486			; $486-493 inclusive

	ld a,$12		; Remap page 1
	ld ($fffe),a

	call PSG_DECODER

	ld a,$01		; Restore page 1
	ld ($fffe),a

	ret

	.end			; TASM-only

; replaces:
;LoadTiles4BitRLENoDI:  ; $0486
;    ld b,$04
;  -:push bc
;        push de
;            call + ; called 4 times for 4 bitplanes
;        pop de
;        inc de
;    pop bc
;    djnz -
;    ret
;  +:
; --:ld a,(hl)          ; read count byte <----+
;    inc hl             ; increment pointer    |
;    or a               ; return if zero       |
;    ret z              ;                      |
;                       ;                      |
;    ld c,a             ; get low 7 bits in b  |
;    and $7f            ;                      |
;    ld b,a             ;                      |
;    ld a,c             ; set z flag if high   |
;    and $80            ; bit = 0              |
;                       ;                      |
;  -:SetVRAMAddressToDE ; <------------------+ |
;    ld a,(hl)          ; Get data byte in a | |
;    out (VDPData),a    ; Write it to VRAM   | |
;    jp z,+             ; If z flag then  -+ | |
;                       ; skip inc hl      | | |
;    inc hl             ;                  | | |
;                       ;                  | | |
;  +:inc de             ; Add 4 to de <----+ | |
;    inc de             ;                    | |
;    inc de             ;                    | |
;    inc de             ;                    | |
;    djnz -             ; repeat block  -----+ |
;                       ; b times              |
;    jp nz,--           ; If not z flag then --+
;    inc hl             ; inc hl here instead  |
;    jp --              ; repeat forever ------+
;                       ; (zero count byte quits)
