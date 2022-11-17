; Soft locks are places where you can get stuck in the game and you cannot progress (other than deliberately dying). We fix some of these; each has a comment explaining the issue.



; If you kill Lassic, but Myau is dead, Alisa is either dead or doesn't have enough MP to cast Troop, Lutz is either dead or doesn't have enough MP to revive anyone, and you didn't buy a TranCarpet. You then have no way of getting off the Aerocastle.

  ROMPosition $5361
.section "Aerocastle soft lock fix part 1" overwrite
  jp AerocastleSoftLockFix
.ends

.section "Aerocastle soft lock fix part 2" free
AerocastleSoftLockFix:
  ; We define some helpful addresses/values...
  .define HaveBeatenLaShiec $c516
  .define AlisaIsAlive $c400
  .define AlisaMP $c402
  .define AlisaMagicCount $c40e
  .define MyauIsAlive $c410
  .define LutzIsAlive $c430
  .define LutzMP $c432
  .define LutzMagicCount $c43e
  .define Item_TranCarpet $29 ; item index
  .define HaveItem $298a ; functions in original game
  .define AddItemToInventory $28fb
  ; Is Lassic dead?
  ld a,(HaveBeatenLaShiec)
  or a
  jr z,_no
  ; Is Myau dead?
  ld a,(MyauIsAlive)
  or a
  jr nz,_no
  ; Then he can't fly us down. Can Alisa cast Troop?
  ld a,(AlisaIsAlive)
  or a
  jr z,+
  ld a,(AlisaMagicCount)
  cp 2 ; Troop is magic #2
  jr c,+
  ld a,(AlisaMP)
  cp 8 ; MP cost of Troop. We hard-code the value rather than look it up (MagicMPCosts+$12)
  jr nc,_no
+:; Alisa can't do it, can Lutz revive Myau?
  ld a,(LutzIsAlive)
  or a
  jr z,+
  ld a,(LutzMagicCount)
  cp 5 ; Rebirth is magic #2
  jr c,+
  ld a,(LutzMP)
  cp $c ; MP cost of Rebirth (MagicMPCosts+$0f)
  jr nc,_no
+:; Do we have a TranCarpet?
  ld a,Item_TranCarpet
  ld (ItemIndex),a
  call HaveItem
  jr z,_no
  ; Then let's give one
  ld hl,ScriptAerocastleFreeTranCarpet
  call TextBox
  jp AddItemToInventory
  
_no:
  ; Original code equivalent
  ld hl, ScriptAerocastleDots
  jp TextBox
.ends



; If you use a Trancarpet or the Troop spell after obtaining the Luveno, and the last church you visited was in Paseo, you can't go back to Palma because the spaceports are closed, and you can't leave the area around Paseo because you haven't gotten any other vehicles yet.

  ROMPosition $50f9
.section "Luveno troop soft lock fix part 1" overwrite
  ; This is where Dr. Luveno gives you the "Luveno"
  ; ld a,7
  ; ld (LuvenoState),a ; Final state
  ; ld hl,$0294 ; Now then, you can use the Luveno to fly through space. Go outside the village and take a look. It’s a brilliant piece of work.
  ; jp DrawText20x6 ; and ret
  ; We overwrite the final jp above
  jp LuvenoTroopFix
.ends

.section "Luveno troop soft lock fix part 2" free
LuvenoTroopFix:
  ; Church index is in $c317
  ; Check the value
  ld a,($c317)
  cp 4 ; Paseo church
  jr nz,+
  ld a,1 ; Camineet church
+:; Code we replaced to get here
  jp TextBox
.ends
