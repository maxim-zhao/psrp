; There is a bug in the Japanese ROM that makes Myau have a low attack stat at level 30.
; This "fix" makes it match the export version, with a sensible value.
  PatchB $fa88 $56


; There is another bug that causes the script engine to lose some state regarding which row the script window is drawing to, when showing certain prompt windows. This is masked in the original because it only causes issues where the script window has not yet reached the bottom row; this is of course only row 2. Now we have a much bigger window, we notice the issue.

; 1. Tool shop buy/sell prompt
  ROMPosition $2dfa
.section "Shop bug fix" overwrite size 12
; Original code:
;    ld     hl,$b1c5        ; 002DF4 21 C5 B1 ; Welcome to the tool shop. May I help you?<end>
;    call TextBox20x6       ; 002DF7 CD 3A 33 ; State in BC for text window
;    call   $3894           ; 002DFA CD 94 38 ; Show Buy or Sell window; returns in  A, C
;    push   af              ; 002DFD F5
;    push   bc              ; 002DFE C5
;      call   $38b4           ; 002DFF CD B4 38 ; restore tilemap
;    pop    bc              ; 002E02 C1
;    pop    af              ; 002E03 F1
;    bit    4,c             ; 002E04 CB 61
; Following code assumes C is still valid
; We can fit a fix into the existing space by moving the BC push/pop around.
  push bc
    call $3894 ; Show Buy or Sell window; returns in A, C
    bit 4,c ; check for button 1
    push af
      call $38b4 ; restore tilemap
    pop af
  pop bc
.ends

; 2. Picking from the inventory when selling.
  ROMPosition $2e13
.section "Shop bug fix 2" overwrite size 5
; Original code:
;    ld     hl,$b1e0        ; 002E0D 21 E0 B1 ; What do you have?
;    call TextBox20x6       ; 002E10 CD 3A 33 ; State in BC for text window
;    call   $35ef           ; 002E13 CD EF 35 ; Inventory select, returns in A, C
;    bit    4,c             ; 002E16 CB 61    ; Button 1 -> nz
; Following code assumes BC is still valid
; We can't fit this one into the original space...
  push bc
    call ShopSellInventoryFixHelper
  pop bc
.ends

.section "Shop bug fix part 2" free
ShopSellInventoryFixHelper:
  call $35ef ; inventory select
  bit 4,c
  ret
.ends

; 3. Selecting an item to drop from your inventory, when getting an item. This seems to always come when the script box is already full, so we don't bother fixing that one.

; 4. Picking who to heal in the hospital.
  ROMPosition $2aff
.section "Hospital bug fix" overwrite size 5
; Original code:
;    ld     hl,$b25c                ; 002AF9 21 5C B2 ; Who will receive treatment?
;    call   nz,TextBox20x6          ; 002AFC C4 3A 33
;    call   ShowCharacterSelectMenu ; 002AFF CD 82 37 ; Returns in A, C
;    bit    4,c                     ; 002B02 CB 61
;    jp     nz,$2bae                ; 002B04 C2 AE 2B
; Following code assumes BC is still valid
  push bc
    call HospitalAndChurchFixHelper
  pop bc
.ends

.section "Hospital bug fix part 2" free
HospitalAndChurchFixHelper:
  call $3782 ; character select
  bit 4,c
  ret
.ends

; 5. Picking who to resurrect in the church.
  ROMPosition $2c01
.section "Church bug fix" overwrite size 5
; Original code:
;    ld     hl,$b31e                ; 002BFB 21 1E B3 ; Who shall be returned?<end>
;    call   TextBox20x6             ; 002BFE CD 3A 33
;    call   ShowCharacterSelectMenu ; 002C01 CD 82 37 ; CharacterSelect
;    bit    4,c                     ; 002C04 CB 61    ; Returns in A, C
;    jp     nz,$2c9f                ; 002C06 C2 9F 2C
; Following code assumes BC is still valid
  push bc
    call HospitalAndChurchFixHelper
  pop bc
.ends

; 6. Selecting the slot to save in
  ROMPosition $1e41
.section "Save game bug fix" overwrite size 3
; Original code:
;    ld     hl,$b39f        ; 001E3B 21 9F B3
;    call   TextBox20x6     ; 001E3E CD 3A 33
;    call   $3acf           ; 001E41 CD CF 3A
; Following code assumes BC is still valid
  call SaveFixHelper
.ends

.section "Save game bug fix part 2" free
SaveFixHelper:
  push bc
    call $3acf ; save slot select
  pop bc
  ret
.ends
