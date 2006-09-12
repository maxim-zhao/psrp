;
; Item window drawer (generic)
;
; Written in TASM 3.0.1
;

#include "vars.asm"

.org $7e3e			; $2fe3e-2ffff

inventory:
	ld b,$08		; 8 items total

next_item:
	push bc
	push hl

	di
	ld a,$7f000/$4000	; move to page 0
	ld ($fffd),a

	ld a,(hl)		; grab item #
	ld hl,ITEMS		; table start

	push de
	call $3d8d		; copy string to RAM
	pop de

	ld a,$00		; reload page 0
	ld ($fffd),a
	ei

	ld hl,TEMP_STR		; start of text

	call start_write	; write out 2 lines of text
	call wait_vblank

	call start_write
	call wait_vblank

	pop hl
	pop bc

	inc hl			; next item
	djnz next_item

	ret
; ________________________________________________________

shop:
	ld b,$03		; 3 items total

next_shop:
	push bc
	push hl

	di
	ld a,$7f000/$4000	; move to page 0
	ld ($fffd),a

	ld a,$03		; shop bank
	ld ($ffff),a

	ld a,(hl)		; grab item #
	ld (FULL_STR),hl	; save current shop ptr
	ld hl,ITEMS		; table start

	push de
	call $3d8d		; copy string to RAM
	pop de

	ld a,$00		; reload page 0
	ld ($fffd),a
	ei

	ld hl,TEMP_STR		; start of text

	call start_write	; write out 2 lines of text

	push hl			; hacky workaround
	push de
	ld c,$01		; write out price
	call shop_price
	pop de
	pop hl
	ld a,$02		; restore page 2
	ld ($ffff),a

	call start_write

	push hl			; hacky workaround
	push de
	ld c,$00		; do not write price
	call shop_price
	pop de
	pop hl

	pop hl			; restore old parameters
	pop bc

	inc hl			; next item
	inc hl
	inc hl
	djnz next_shop

	ret
; ________________________________________________________

enemy:
	di
	ld a,$7f000/$4000	; move to page 0
	ld ($fffd),a

	ld a,$03		; shop bank
	ld ($ffff),a

	ld a,($c2e6)		; grab enemy #
	ld hl,ENEMY		; table start

	push de
	call $3d8d		; copy string to RAM
	pop de

	ld a,$00		; reload page 0
	ld ($fffd),a
	ei

	ld hl,TEMP_STR		; start of text

	call start_write	; write out line of text

	ld a,(LEN)		; optionally write next line
	or a
	call nz,start_write

	call wait_vblank

	ret
; ________________________________________________________

equipment:
	ld b,$03		; 3 items total

next_equipment:
	push bc
	push hl

	di
	ld a,$7f000/$4000	; move to page 0
	ld ($fffd),a

	ld a,$03		; shop bank
	ld ($ffff),a

	ld a,(hl)		; grab item #
	ld hl,ITEMS		; table start

	push de
	call $3d8d		; copy string to RAM
	pop de

	ld a,$00		; reload page 0
	ld ($fffd),a
	ei

	ld hl,TEMP_STR		; start of text

	call start_write	; write out 2 lines of text
	call wait_vblank

	call start_write
	call wait_vblank

	pop hl
	pop bc

	inc hl			; next item
	djnz next_equipment

	ret
; ________________________________________________________

start_write:
	di
	push bc
	push de
	rst 08h			; set vram address

	push af
	pop af
	ld a,$f3		; left border
	out ($be),a

	push af
	pop af
	ld a,$11
	out ($be),a

	ld a,(LEN)		; string length
	ld c,a
	ld b,$0a		; 10-width

; ---------------------------------------------

check_length:
	ld a,c			; check for zero string
	or a
	jr z,blank_line

read_byte:
	ld a,(hl)		; read character
	inc hl			; bump pointer
	dec c			; shrink length

	cp $4f			; normal text
	jr c,bump_text

space:
	jr z,blank_line		; non-narrative WS

newline:
	cp $50			; pad rest of line with WS
	jr nz,hyphen

newline_flush:
	xor a
	call write_nt
	djnz newline_flush

	jr right_border

hyphen:
	cp $51			; add '-'
	jr nz,skip_htext
	ld a,$46
	jr bump_text

skip_htext:
	cp $52			; ignore other codes
	jr nz,check_length

loop_hskip:
	ld a,(hl)		; eat character
	inc hl
	dec c

	cp $53			; check for 'end' or length done
	jr nz,loop_hskip
	jr check_length


blank_line:
	xor a			; write out WS for rest of the line

bump_text:
	call write_nt
	djnz check_length

; ---------------------------------------------

right_border:
	ld a,c			; store length
	ld (LEN),a

	push af			; right border
	pop af
	ld a,$f3
	out ($be),a

	push af
	pop af
	ld a,$13
	out ($be),a

	pop de			; restore stack
	pop bc

; ---------------------------------------------------

	push hl
	ld hl,10*2+2		; left border + 10-char width
	add hl,de		; save VRAM ptr
	ld (FULL_STR+2),hl

	ld hl,$0040		; VRAM newline
	add hl,de
	ex de,hl
	pop hl

	ei			; wait for vblank
	ret

; ----------------------------------------------------------

write_nt:
	add a,a			; lookup NT
	ld de,$8000
	add a,e
	ld e,a
	adc a,d
	sub e
	ld d,a

	ld a,(de)		; write NT + VDP delay
	out ($be),a
	push af
	pop af
	inc de
	ld a,(de)
	out ($be),a

	ret

; __________________________________________________________

wait_vblank:
	ld a,$08		; stable value
	call $0056
	ret

; __________________________________________________________

shop_price:
	di
	ld de,(FULL_STR+2)	; restore VRAM ptr
	rst 08H

	ld a,$03		; shop bank
	ld ($ffff),a

	ld hl,(FULL_STR)	; shop ptr

	ld a,(hl)		; check for blank item
	or a
	jr nz,write_price
	ld c,$00		; no price

write_price:
	push de			; parameter
	push hl			; parameter
	jp $3a9a		; write price

.end				; tasm-only
