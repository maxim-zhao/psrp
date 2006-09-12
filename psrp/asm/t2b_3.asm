;
; Spell selection blank line drawer
; - addition
;
; Written in TASM 3.0.1
;


.org $3494			; $3494-34a4

	ld h,$00
	ld l,h

menu_offset:
	dec a			; loop
	jr z,menu_base

	add hl,de		; skip menu
	jr menu_offset

menu_base:
	ret

.end				; TASM-only
