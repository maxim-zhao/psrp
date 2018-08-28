;
; Spell selection offset finder
;
; Written in TASM 3.0.1
;

#define MENU_SIZE ((10+2)*2)*11	; top border + text

.org $35a2			; $35a2-35ae

	ld de,MENU_SIZE		; menu size

	inc a			; init
	ld h,$00
	ld l,h

menu_offset:
	dec a			; loop
	jr z,menu_base

	add hl,de		; skip menu
	jr menu_offset

menu_base:
	; $35af

.end				; TASM-only
