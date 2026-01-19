; Extended inventory item menu

; Patch menu item count
  PatchB $233c 3

; Expanded lookup table
.unbackground $2357 $235c
.bank 0 slot 0
.section "Use/equip/drop/move handlers table" free
UseEquipDropUseHandlers:
.dw $235D $2824 $28AE MoveHandler
.ends

; Point to it
  PatchW $2348+1 UseEquipDropUseHandlers
  
; Add new handler
.define InventorySelectedItemPointer $C29B
.define InventorySelectedItemValue $C2C4
.define HideInventory $3773
.define ShowInventoryAndPickItem $35ef
.bank 0 slot 0
.section "Inventory move handler" free
MoveHandler:
  ; Remember currently selected item
  ld a, (InventorySelectedItemPointer) ; Pointer to selected item, LSB
  ld b, a
  ld a, (InventorySelectedItemValue)
  ld c, a
  push bc ; Remember it
    call HideInventory
    call ShowInventoryAndPickItem
    push bc
      call $3888 ; hide use/equip/drop/move menu
    pop bc
    bit 4,c
    jr z,+
  pop bc
  jr _done ; User cancelled
  
+:pop bc ; Previous item is now in b
  
  ; Get selected item
  ld a, (InventorySelectedItemPointer)
  ; Compare to previous
  cp b
  jr z, _done ; Equal means nothing to do
  jr c, _lower ; Selected is lower
_higher:
  ; Inventory is at $c4xx
  ; User selected
  ; ABCDEFG
  ;  ^   ^- move here in a
  ; item in b
  ; So we move CDEF down by 1, and insert B at the end
  push bc
    ; Source = $c400 + b + 1
    ld h, $c4
    ld l, b
    inc l
    ; Dest = $c400 + b
    ld d, h
    ld e, b
    ; Count = a - b
    sub b
    ld c, a
    ld b, 0
    ; And go
    ldir
  pop bc
  ; Now put c at the end
  ; hl is left pointing one past the right spot
  dec hl
  ld (hl),c
  jr _done

_lower:
  ; Inventory is at $c4xx
  ; User selected
  ; ABCDEFG
  ;  ^   ^- item in b
  ; move here in a
  ; So we move BCDE up by 1, and insert F at the start
  ; To do that we want lddr, which is rarely used...
  push bc
    ; Source = $c400 + b - 1
    ; Dest = $c400 + b
    ; Count = b - a
    ld h, $c4
    ld l, b
    dec l
    ld d, h
    ld e, b
    sub b
    neg
    ld b, 0
    ld c, a
    lddr
  pop bc
  ; Now put c at the start, which is now at hl+1
  inc hl
  ld (hl), c
  ; fall through
  
_done:
  call HideInventory
  call $22c4 ;_LABEL_22C4_Items
  ret
  
.ends