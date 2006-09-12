;
; Spell selection blank line drawer
; - support code
;
; Written in TASM 3.0.1
;

#define LINE_SIZE (7+2)*2	; width of line

.org $35c5			; $35c5-35d2

	push de

	ld de,LINE_SIZE		; menu size

	ld a,b			; init
	inc a

	call $3494		; 16-bit addition

	ld de,$0000		; auto-generated base value
	add hl,de

	pop de

.end				; TASM-only
