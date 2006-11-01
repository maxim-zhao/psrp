;
; BG NT output
;
; Written in TASM 3.0.1
;

.org $34f2
; Replacing draw-one-character function from $34f2-3545
; drawing 2 tilemap chars, with conditional mirroring, and a scrolling handler,
; with a new one from $3f42-3f66 that draws a single char using a 2-byte lookup
; and leaves the scrolling to be handled by the word-wrapping code elsewhere

  di            ; prepare VRAM output
  push bc
    push de     
                
      push af
        rst 08h      ; Set address
      pop af

      ; ld a,(hl)    ; A = decoded byte
      add a,a        ; 2-byte table

      ld bc,$8000    ; index into table
      add a,c
      ld c,a

      adc a,b       ; overflow accounting
      sub c
      ld b,a

      ld a,(bc)     ; load low NT-byte
      out ($be),a
      push af       ; VRAM wait
      pop af

      inc bc        ; write out high NT-byte
      ld a,(bc)
      out ($be),a

    pop de        ; Bump VRAM address
    inc de
    inc de
  pop bc

  ei               ; Wait for VBlank
  ld a,$0a
  call $0056    
                
  dec b             ; Shrink window width
  ret

; Original:
;_DrawLetter:           ; $34f2
;    di
;    push bc
;      push de
;        SetVRAMAddressToDE
;        ld a,(hl)      ; Get data (upper half of letter)
;        add a,a
;        ld bc,TileNumberLookup
;        add a,c
;        ld c,a
;        adc a,b
;        sub c
;        ld b,a         ; bc = TileNumberLookup + 2*a
;        ld a,(bc)      ; get tile number corresponding to a from there
;        out (VDPData),a
;        push af        ; delay
;        pop af
;        ld a,$10       ; in front of sprites
;        out (VDPData),a
;        ex de,hl
;        ld bc,$40      ; add $40 to de (1 row)
;        add hl,bc
;        ex de,hl
;        SetVRAMAddressToDE
;        ld a,(hl)      ; get data (lower half of letter)
;        add a,a
;        ld bc,TileNumberLookup+1
;        add a,c
;        ld c,a
;        adc a,b
;        sub c
;        ld b,a         ; bc = TileNumberLookup+1 + 2*a
;        ld a,(bc)      ; get tile number corresponding to a from there
;        out (VDPData),a
;        push af        ; delay
;        pop af
;        cp $fe         ; should the lower half be reversed? (tile $fe = . also acts as a dot above a letter the other way round)
;        ld a,$12       ; if so, in front of sprite + horizontal mirror
;        jr z,+
;        ld a,$10       ; else in front of sprites
;      +:out (VDPData),a
;        inc hl         ; move to next data
;      pop de
;      inc de
;      inc de
;    pop bc
;    ei
;    ld a,$0a           ; VBlankFunction_Enemy (I have to fix these labels...)
;    call ExecuteFunctionIndexAInNextVBlank
;    dec b              ; dec b
;    ret nz             ; return if non-zero -> only do next bit when b=1 at start
;
;    ld a,(hl)          ; peek at next data
;    cp $53
;    ret nc             ; if >=$53 (control codes)
;    ld a,c             ; get c
;    or a               ; if non-zero,
;    call nz,_ScrollTextBoxUp2Lines
;    ld de,$7d4e        ; TileMapAddressDE 7,21
;    ld bc,$1201        ; reset b=1, c=$12
;    ret

  .end      ; TASM-only
