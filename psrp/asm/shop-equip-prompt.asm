; Now we hack the shop to offer to equip items when you buy them.
  ROMPosition $2d7b
.section "Shop equip mod" overwrite size 3
; Original code:
;  call $28fb           ; 002D7B CD FB 28 ; AddItemToInventory
  call ShopEquipMod
.ends

.section "Shop equip mode part 2" free
ShopEquipMod:
  call $28fb ; AddItemToInventory
  ; This leaves hl pointing to the newly-added item. We need this later...
  ld ($c29b),hl ; The game saves the pointer here
  
  ; The original item equip code is at $2824. However we can't use it because it breaks our script state. So we copy/paste/enhance...
  
  ; Check if the item is equippable
  ld hl,PAGING_SLOT_2
  ld (hl),:ItemMetaData
  ld a,(ItemTableIndex)
  ld hl,ItemMetaData
  add a,l
  ld l,a
  adc a,h
  sub l
  ld h,a
  ld a,(hl) ; hl = bfa9
  ; Get upper nybble into d = equippability bits per character
  rrca            
  rrca            
  rrca            
  rrca            
  and $0f         
  ; Zero means not equippable
  ret z
  
  ld d,a ; backup equippability bitmask

  ; Check if any alive characters can equip it
  push bc
    ld b,0 ; character index
    ld c,d
-:  ld a,b
    cp 4 ; valid range is 0..3
    jr z,_noMatches
    ; check equippable bit
    srl c
    jr nc,_invalid
    ; bit was 1, is character alive?
    call $19ea
    jr z,_invalid
    ; Character is alive
    jr + ; continue on then

_invalid:
    inc b ; try next character
    jr -
    
_noMatches:
  pop bc
  ret
    
+:pop bc

  push de     
  push hl
    ld hl,ScriptDoYouWantToEquip
    call TextBox
    ; Save BC so we can get at it below outside a push/pop safe place
    ld (ScriptBCStateBackup),bc
    call DoYesNoMenu
  pop hl
  pop de
  ret nz ; = chose "no"
  
_selectWho:
  push de     
  push hl     
    call $3782 ; show character select
  pop hl      
  pop de      
  
  bit 4,c ; cancel
  jp nz,_done

  call $19ea ; check character is alive
  jp z,_done

  ld (NameIndex),a
  ld c,a
  inc a ; range 1..4
  ld b,a
  ld a,d ; rotate upper nibble right by character number
-:rrca
  djnz -
  jp nc,_cantEquip ; if carry then bit was set -> can equip

  ; point to correct place in character stats
  ld a,c             
  add a,a            
  add a,a            
  add a,a            
  add a,a ; *16 to point to correct character stats
  ld de,$c40a ; Alisa weapon
  add a,e ; point to correct character
  ld e,a 
  adc a,d
  sub e  
  ld d,a 

  ; read metadata again
  ld a,:ItemMetaData
  ld (PAGING_SLOT_2),a
  ld a,(hl)
  ; low 2 bits are item type (0 = weapon, 1 = armour, 2 = shield)
  and %00000011
  add a,e
  ld e,a 
  ; read current equipped item
  ld a,(de)
  ld hl,($c29b) ; Read a pointer?
  ld (hl),a ; Replace item in inventory with de-equipped item
  push af
    ld a,(ItemTableIndex)
    ld (de),a
    ld hl,ScriptPlayerEquippedItem
    ld bc,(ScriptBCStateBackup)
    call TextBox
    ld (ScriptBCStateBackup),bc
    ld a,(NameIndex)       
    call $3824 ; Show player equpped items window
    call MenuWaitForButton           
    call $386a ; Hide it again
  pop af
  or a
  call z, $28d8 ; RemoveSelectedItemfromInventory ; because we swapped something for nothing

_done:
  call $1916 ; CharacterStatsUpdate
  ld bc,(ScriptBCStateBackup)
  jp $37d8 ; Close player select and return

_cantEquip:
  push hl
  push de
    ld hl,ScriptPlayerCantEquipItem
    ld bc,(ScriptBCStateBackup)
    call TextBox
    ld (ScriptBCStateBackup),bc
    call $37d8 ; Close player select
  pop de
  pop hl
  jr _selectWho ; try again!

.ends
