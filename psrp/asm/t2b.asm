;
; Active player menu selection
;
; Written in TASM 3.0.1
;

.org $3de4			; $3de4-3dec ($08)

	xor a
	inc h

menu_offset:
	dec h			; loop
	ret z

	add a,l			; skip menu
	jr menu_offset

.end				; TASM-only
