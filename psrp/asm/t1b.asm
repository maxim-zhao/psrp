;
; Narrative number BCD creater
;
; Written in TASM 3.0.1
;

#include "vars.asm"

; in-line number display
; Old: inline looping (costs space), simple, direct output
; New: renders string to a temp buffer for wrapping,
;      stores a flag to tell if it was singular or plural,
;      pulls digit calculation out to save space
;      105 bytes
.org $33f6      ; $33f6-3493 ($96)

  jr z,DRAW_NUMBER ; draw number if z
  call $34f2       ; else draw a regular letter
  jp $3365         ; and loop

DRAW_NUMBER:
  push hl      ; Save string ptr
  push bc      ; Width, temp
  push ix      ; Temp

    ld hl,($c2c5)    ; Load 16-bit parameter
    ld ix,TEMP_STR   ; Decode to buffer

    ld bc,10000    ; # 10000's
    call BCD_Digit
    ld (ix+$00),A

    ld bc,1000     ; # 1000's
    call BCD_Digit
    ld (ix+$01),A

    ld bc,100      ; # 100's
    call BCD_Digit
    ld (ix+$02),A

    ld bc,10       ; # 10's
    call BCD_Digit
    ld (ix+$03),A

    ld a,l      ; # 1's (BCD_Digit has made it only possible to be in the range 0..9)
    add a,$01   ; add 1 because result = digit+1
    ld (ix+$04),a


    ; scan the resultant string to see where the first non-zero digit is
    ; but we want to show the last digit even if it is zero
    ld b,$04    ; look at 4 digits max
    ld hl,TEMP_STR    ; scan value

Scan:
    ld a,(hl)    ; load digit
    cp $01      ; check for '0'
    jr nz,Done
    inc hl      ; bump pointer
    djnz Scan

Done:
    ld a,b
    inc a         ; 1 <= length <= 5
    ld (STR),hl   ; save ptr to number string
    ld (LEN),a    ; save length

; ------------------------------------------------------------
    ; length != 1 -> must be plural
    cp $01
    jr nz,Plural  ; length must be 1

    ; else check for '1'
    ld a,(hl)
    cp $02      ; last digit = '1'
    jr nz,Plural

Singular:
    xor a      ; Clear flag

Plural:
    ; a is non-zero on jumps to this point
    ; and zero for the singular case
    ld (SUFFIX),a    ; 'x' mesata(s)

; ------------------------------------------------------------

  pop ix      ; Restore stack
  pop bc
  pop hl

  inc hl      ; Process next script
  jp $3365

; ____________________________________________________________

BCD_Digit:
  ld a,$00     ; Init digit value
               ; Note: $01 = '0', auto-bump
  or a         ; Clear carry flag

; subtract bc from hl until it overflows, then add it on again
; return a = number of subtractions done until overflow occurred,
;        hl = hl % bc
; so a = hl / bc + 1 (integer division + 1)
; eg. hl =  9999, bc = 10000, a = 1
; eg. hl = 10000, bc = 10000, a = 2
BCD_Loop:
  sbc hl,bc    ; Divide by subtraction
  inc a        ; Bump place marker
  jr nc,BCD_Loop ; No underflow

  add hl,bc    ; Restore value from underflowed subtraction
  ret

  .end      ; TASM-only

; Replaces:
