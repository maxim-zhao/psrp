.slot 1
.section "Scripting code" semisuperfree banks 3-31
; Originally t2a.asm
; Item window drawer (generic)

inventory:
  ld b,8    ; 8 items total

-:push bc
  push hl

    di
.if LANGUAGE == "de"
      ; Select [] brackets only
      ld a,%0001
.else
      ; Skip all brackets
      xor a
.endif
      ld (SKIP_BITMASK),a

      ld a,(hl)   ; grab item #
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM ; changed address
      pop de
    ei

    ld hl,TEMP_STR    ; start of text

    call _start_write ; write out text
    call _wait_vblank

  pop hl
  pop bc

  inc hl      ; next item
  djnz -

  ret
; ________________________________________________________

shop:
; We extend this to do all the box drawing
  ; First we want to decide how wide it is.
  ; It looks like this:
  ; ┌──────────────────╖
  ; │Item 1       Price║
  ; │Item 2       Price║
  ; │Item 3       Price║
  ; ╘══════════════════╝
  ; Item names are variable length. Price is up to four digits. Item count is 1-3.
  ; We want to make it have two spaces between the names and items so we don't
  ; have it super wide if not needed.
  ; First we need to look up the items for this shop.
  ; This is all copied from the original game:
  ld a,3 ; bank for table at $f717
  ld (PAGING_SLOT_2),a
  ld a,(RoomIndex)
  and $1F
  ; Multiply by 10
  ld l,a
  ld h,0
  add hl,hl
  ld c,l
  ld b,h
  add hl,hl
  add hl,hl
  add hl,bc
  ; Look up (1-based)
  ld bc,$b717 - 10 ; Shop items table at $f717
  add hl,bc
  ; First byte is menu size - 1
  ld a,(hl)
  ld (CursorMax),a
  inc hl
  push hl ; save this pointer for the end
    ; Next are tuples of (item ID, price). We want to find the longest named item.
    push af
    push hl
      inc a
      ld b,a
      ld c,0 ; longest length seen
      di
-:    ld a,3 ; shop data
      ld (PAGING_SLOT_2),a
      ld a,(hl) ; Get item ID
      ; Move to next item
      inc hl
      inc hl
      inc hl
      push hl
      push bc
        call _lookUpShopItem
        call _checkLength
      pop bc
      pop hl
      cp c
      ; If it carries then c is bigger
      jr c,+
      ld c,a
+:    ; check if we have run out of items
      djnz -
      ei
      ; So the max must be C. Let's save it to RAM.
      ld a,c
      add a,6 ; space for numbers
      ld (ShopInventoryWidth),a

      ; Now let's try to draw the top border.
      ; First we compute the VRAM address. This is $3800 + (32 - (width+2)) / 2 * 2
      sub 30
      neg
      and %11111110
      ld e,a
      ld d,0
      ld hl,$7800
      add hl,de
      ex de,hl
      rst $08 ; Set VRAM address
      ; Set de to the next row down
      ld hl,ONE_ROW
      add hl,de
      ex de,hl
      ; Save that as the cursor address
      ld (CursorTileMapAddress),de
      ; Draw top border
      ld a,(ShopInventoryWidth)
      ld c,a
      ld hl,BorderTop
      call _DrawBorder
      call _wait_vblank
    pop hl
    pop af
    ; Now hl points at the first item, a is the row count, de is the write address

    ld a,(CursorMax)
    inc a
    ld b,a ; Only show as many rows as needed
_itemsLoop:
    push bc
    push hl

      di
        ld a,3 ; Shop data bank
        ld (PAGING_SLOT_2),a
        ld a,(hl)   ; grab item #
        push af
          inc hl
          ; and price
          ld a,(hl)
          inc hl
          ld h,(hl)
          ld l,a
          ld (NumberToShowInText),hl
        pop af
        call _lookUpShopItem
      ei

      ; Print item text
      push de
        rst $08
        ld hl,BorderSides
        call _DrawOneTile
        inc de
        inc de
        ; Now for the item name
        ld hl,TEMP_STR
        ld a,(LEN)
        ld b,a
        push bc
          ld c,0 ; counter for chars written
-:        ld a,(hl)
          inc hl
          cp SymbolStart ; don't draw scripting codes
          jr nc,+
          call EmitCharacter
          inc c
          inc de
          inc de
+:        djnz -
          ld a,c ; written character count
        pop bc
        ; Write out blanks
        ld c,a
        ld a,(ShopInventoryWidth)
        sub c
        sub 5 ; for price
        jr z,+
        ld b,a ; we want this many blanks
-:      xor a ; space
        call EmitCharacter
        djnz -
+:
        ; Write out price
        call DrawNumberToTempStr
        ; We called the function used for numbers in the script.
        ; It has rendered the number to TEMP_STR, and also set some other script state that we don't care about.
        ld hl,TEMP_STR
        ld b,5 ; digits
-:      ld a,(hl)
        inc hl
        call EmitCharacter
        djnz -

        ; Write out right border
        ld hl,BorderSides+2
        call _DrawOneTile
      pop de
      call _wait_vblank
      ; Next row
      ld hl,ONE_ROW
      add hl,de
      ex de,hl
      rst $08
    pop hl      ; restore counter, data pointer
    pop bc

    inc hl      ; next item
    inc hl
    inc hl
    djnz _itemsLoop
    ; Clear LEN to stop the item name being drawn later
    xor a
    ld (LEN),a

    ; Bottom border
    ld a,(ShopInventoryWidth)
    ld c,a
    ld hl,BorderBottom
    call _DrawBorder
    call _wait_vblank

    call WaitForMenuSelection
  pop hl
  ; Point hl to the shop table entry selected
  ; compute hl = hl + a * 3 = pointer to data for the selected item
  ld b,a
  add a,a
  add a,b
  add a,l
  ld l,a
  adc a,h
  sub l
  ld h,a
  ld a,3
  ld (PAGING_SLOT_2),a
  ret

_lookUpShopItem:
  ld hl,Items
  push af
.if LANGUAGE == "de"
    ; Select [] brackets only
    ld a,%0001
.else
    ; Skip all brackets
    xor a
.endif
    ld (SKIP_BITMASK),a
  pop af
  push de
    call DictionaryLookup ; puts length in LEN
  pop de
  ret

_checkLength:
  ; When we do an item name lookup, the length includes control characters.
  ; We count the printable ones.
  ld a,(LEN)
  ld hl,TEMP_STR
  ld b,a
  ld c,0
-:ld a,(hl)
  inc hl
  cp SymbolStart
  jr nc,+
  inc c
+:djnz -
  ; now c is the real name length
  ld a,c
  ret


enemy:
  ; Enemy name window drawing
  ; Get enemy name to TEMP_STR
  di
    ld a,:Enemies
    ld (PAGING_SLOT_2),a

.if LANGUAGE == "de"
    ; Select [] brackets only
    ld a,%0001
.else
    ; Skip all brackets
    xor a
.endif
    ld (SKIP_BITMASK),a

    ld a,(EnemyIndex)
    ld hl,Enemies   ; table start

    push de
      call DictionaryLookup    ; copy string to RAM
    pop de
  ei

  ; compute the name length
  call _checkLength

  ; Compute the VRAM address
  ld hl,$7840 - 4 ; right-aligned, minus space for borders
  add a,a
  neg
  ld e,a
  ld d,-1
  add hl,de
  ex de,hl

  call _wait_vblank
  push de
    ; Set VRAM address
    rst $08
    ; Draw top border
    ld hl,BorderTop
    call _DrawBorder
  pop de
  ; Next row
  ld hl,ONE_ROW
  add hl,de
  ex de,hl
  push de
    rst $08
    ld hl,BorderSides
    call _DrawOneTile
    push hl
      ; Now for the enemy name
      ld hl,TEMP_STR
      ld a,(LEN)
      ld b,a
    -:ld a,(hl)
      inc hl
      cp SymbolStart ; don't draw scripting codes
      call c,EmitCharacter
      djnz -
    pop hl
    call _DrawOneTile
  pop de
  call _wait_vblank
  ; Next row
  ld hl,32*2
  add hl,de
  ex de,hl
  rst $08
  ld hl,BorderBottom
  call _DrawBorder

  ; clear LEN
  xor a
  ld (LEN),a

  jp _wait_vblank ; and ret

_DrawBorder:
  ; Emit tile data from (hl) to VRAM, repeating the second word (LEN) times
  call _DrawOneTile
  ld b,c
-:call _DrawOneTile
  dec hl
  dec hl
  djnz -
  inc hl
  inc hl
_DrawOneTile:
  ld a,(hl)
  out (PORT_VDP_DATA),a ; 11
  inc hl                ; 6
  ld a,(hl)             ; 7
  nop                   ; 4 -> total 28 cycles
  out (PORT_VDP_DATA),a
  inc hl
  ret

; Tilemap words for the borders
BorderTop:
.stringmap tilemap "┌─╖"
BorderSides:
.stringmap tilemap "│║"
BorderBottom:
.stringmap tilemap "╘═╝"

equipment:
  ld b,3    ; 3 items total

-:push bc
  push hl

    di
      ld a,:Items    ; data bank
      ld (PAGING_SLOT_2),a

.if LANGUAGE == "de"
      ; Select [] brackets only
      ld a,%0001
.else
      ; Skip all brackets
      xor a
.endif
      ld (SKIP_BITMASK),a

      ld a,(hl)   ; grab item #
      ld hl,Items   ; table start

      push de
        call DictionaryLookup    ; copy string to RAM
      pop de
    ei

    ld hl,TEMP_STR    ; start of text

    call _start_write ; write out name
    call _wait_vblank
  pop hl
  pop bc

  inc hl      ; next item
  djnz -

  ret

.define ITEM_NAME_WIDTH InventoryMenuDimensions_width-2 ; when drawn in menus

_start_write:
  di
    push bc
    push de
      rst $08     ; set vram address

      push af     ; Delay
      pop af
      ld a,$f3    ; border
      out ($be),a

      push af     ; Delay
      pop af
      ld a,$11    ; MSB for left border
      out ($be),a

      ld a,(LEN)    ; string length
      ld c,a
      ld b,ITEM_NAME_WIDTH

_check_length:
      ld a,c      ; check for end of string
      or a
      jr z,_blank_line

_read_byte:
      ld a,(hl)   ; read character
      inc hl      ; bump pointer
      dec c     ; shrink length

      cp SymbolStart      ; normal text is before this
      jr c,_bump_text

_space:
      jr nz,_check_length
      ; else fall through

_blank_line:
      xor a     ; write out WS for rest of the line

_bump_text:
      call EmitCharacter
      djnz _check_length

_right_border:
      ld a,c      ; store length
      ld (LEN),a

      push af     ; right border
      pop af
      ld a,$f3    ; border
      out ($be),a

      push af
      pop af
      ld a,$13    ; hflipped
      out ($be),a

    pop de      ; restore stack
    pop bc

    push hl
      ld hl,ITEM_NAME_WIDTH*2+2    ; left border + width
      add hl,de   ; save VRAM ptr
      ld (VRAM_PTR),hl

      ld hl,32*2  ; VRAM newline
      add hl,de
      ex de,hl
    pop hl

  ei      ; wait for vblank
  ret

_wait_vblank:
      ld a,$08    ; stable value
      call ExecuteFunctionIndexAInNextVBlank
      ret

.ends

.macro TrampolineTo args dest, start, end
  .unbackground start end-1
  ROMPosition start
  .section "Trampoline to \1 @ \2" force
  ld a,:dest
  ld (PAGING_SLOT_1),a
  call dest
  ld a,1
  ld (PAGING_SLOT_1),a
  JR_TO end
.ends
.endm

  TrampolineTo inventory $3671 $3680
  TrampolineTo enemy $326d $3294
  TrampolineTo equipment $3850 $385f
  ; Shop trampoline is now done manually
