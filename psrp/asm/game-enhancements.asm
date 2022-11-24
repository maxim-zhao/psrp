; We add a few enhancements to the game:
; * We make load/delete save games a menu instead of the black screen script setup of the original
; * We add a sound test which also allows you to switch between FM and PSG if FM is available
; * We add an options menu to the title screen:
;    ┌───────────────────╖
;    │Walk speed       x2║
;    │Experience       x2║
;    │Mesetas          x2║
;    │Battles        Half║
;    │Alisa's hair  Brown║
;    │Font        Polaris║
;    │Fades          Fast║
;    ╘═══════════════════╝
;   Selections in here are saved to SRAM so they persist across games
; * We also redraw the whole title screen...

; Code to handle the title screen menus:
  ROMPosition $073f
.section "Title screen extension part 1" force
;    TileMapAddressHL 9,16
;    ld (CursorTileMapAddress),hl
;    ld     a,$01           ; 000745 3E 01
;    ld     (CursorMax),a       ; 000747 32 6E C2
;    call   WaitForMenuSelection           ; 00074A CD B9 2E
;    or     a               ; 00074D B7
;    jp     nz,$079e        ; 00074E C2 9E 07
.define TitleScreenCursorBase TileMapWriteAddress(9,15)
  ld hl,TitleScreenCursorBase
  ld (CursorTileMapAddress),hl
  ld a,3 ; 4 options
  ld (CursorMax),a ; CursorMax
  ld a,:TitleScreenMod
  jp TitleScreenModTrampoline ; Out of space here (want 5B, have 4)
.ends
.slot 0
.section "Title screen extension part 2" free
TitleScreenModTrampoline:
  ld (PAGING_SLOT_2),a
  jp TitleScreenMod
.ends
.slot 2
.section "Title screen modification" superfree
TitleScreenMod:
  call WaitForMenuSelection
  or a
  jp z,$0751
  dec a
  jp z,Continue
  dec a
  jp z,SoundTest
  ; else fall through

_OptionsMenu:
  ld hl,FunctionLookupIndex
  ld (hl),8 ; LoadScene (also changes cursor tile)

  ; Save tilemap
  ld hl,OptionsWindow
  ld de,OptionsWindow_VRAM
  ld bc,OptionsWindow_dims
  call InputTilemapRect

  ; Draw window
  ld hl,OptionsMenu
  ld de,OptionsWindow_VRAM
  ld bc,OptionsWindow_dims
  call DrawTilemap

  ; Start selection
  ld hl,OptionsWindow_VRAM + ONE_ROW
  ld (CursorTileMapAddress),hl
  ld hl,$0000
  ld (CursorPos),hl  ; 0 -> CursorPos, OldCursorPos

_OptionsSelect:
  ; We draw in the numbers here
  ld de,OptionsWindow_VRAM + ONE_ROW * 1 + 2 * (OptionsMenu_width - 2)
  rst $8
  ld a,(MovementSpeedUp)
  inc a
  call OutputDigit

  ld de,OptionsWindow_VRAM + ONE_ROW * 2 + 2 * (OptionsMenu_width - 2)
  rst $8
  ld a,(ExpMultiplier)
  call OutputDigit

  ld de,OptionsWindow_VRAM + ONE_ROW * 3 + 2 * (OptionsMenu_width - 2)
  rst $8
  ld a,(MoneyMultiplier)
  call OutputDigit

  ld de,OptionsWindow_VRAM + ONE_ROW * 4 + 2 * OptionsMenu_width  - _sizeof__BattlesAll - 2
  rst $8
  ld a,(FewerBattles)
  or a
  ld hl,_BattlesAll
  jr z,+
  ld hl,_BattlesHalf
+:ld b,_sizeof__BattlesAll
  ld c,PORT_VDP_DATA
  otir

  ld de,OptionsWindow_VRAM + ONE_ROW * 5 + 2 * OptionsMenu_width - _sizeof__Black - 2
  rst $8
  ld a,(BrunetteAlisa)
  or a
  ld hl,_Black
  jr z,+
  ld hl,_Brown
+:ld b,_sizeof__Black
  ld c,PORT_VDP_DATA
  otir

  ld de,OptionsWindow_VRAM + ONE_ROW * 6 + 2 * OptionsMenu_width - _sizeof__Font1 - 2
  rst $8
  ld a,(Font)
  or a
  ld hl,_Font1
  jr z,+
  ld hl,_Font2
+:ld b,_sizeof__Font1
  ld c,PORT_VDP_DATA
  otir

  ld de,OptionsWindow_VRAM + ONE_ROW * 7 + 2 * OptionsMenu_width - _sizeof__Normal - 2
  rst $8
  ld a,(FadeSpeed)
  or a
  ld hl,_Normal
  jr z,+
  ld hl,_Fast
+:ld b,_sizeof__Normal
  ld c,PORT_VDP_DATA
  otir

  ld de,OptionsWindow_VRAM + ONE_ROW * 8 + 2 * (OptionsMenu_width - 2)
  rst $8
  ld a,(TextSpeed)
  inc a
  call OutputDigit

  ld a,$ff
  ld (CursorEnabled),a ; CursorEnabled
  ld a,OptionsMenu_height - 3 ; Max option is menu size - 3
  ld (CursorMax),a ; CursorMax
  call $2ec8 ; no cursor position reset

  ; If button 1, return
  ld b,a
  ld a,%00010000 ; Button 1
  cp c
  jr nz,+

_optionsReturn:
  ; Copy setting to save RAM
  ; We are in slot 2 here so we need to put this in low ROM
  call SettingsToSRAM

  ld hl,OptionsWindow
  ld de,OptionsWindow_VRAM
  ld bc,OptionsWindow_dims
  call DrawTilemap
  ld de,TitleScreenCursorBase + ONE_ROW * 3
  ; fall through

BackToTitle:
  ; We need to hide the cursor as it resets to the top...
  rst $08
  xor a
  out ($be),a

  ; Continue the title screen VBlank handler
  ld hl,FunctionLookupIndex
  ld (hl),3 ; TitleScreen
  ret

+:ld a,b

  ; Then adjust the right thing
  or a
  jr nz,+

_movement:
  ; Toggle bit
  ld a,(MovementSpeedUp)
  xor 1
  ld (MovementSpeedUp),a
  jp _OptionsSelect

  cp 3
  jr nz,+
  ld hl,OptionsWindow
  ld de,OptionsWindow_VRAM
  ld bc,OptionsWindow_dims
  call DrawTilemap
  ld de,TitleScreenCursorBase + ONE_ROW * 3
  jp BackToTitle

+:dec a
  jr nz,++

_experience:
  ld hl,ExpMultiplier
-:ld a,(hl)
  inc a
  cp 5
  jr nz,+
  ld a,1
+:ld (hl),a
  jp _OptionsSelect ; loop

++:dec a
  jr nz,+

_money:
  ld hl,MoneyMultiplier
  jr -

+:dec a
  jr nz,+

_battles:
  ld a,(FewerBattles)
  xor 1
  ld (FewerBattles),a
  jp _OptionsSelect

+:dec a
  jr nz,+

_hair:
  ld a,(BrunetteAlisa)
  xor 1
  ld (BrunetteAlisa),a
  jp _OptionsSelect

+:dec a
  jr nz,+

_font:
  ld a,(Font)
  xor 1
  ld (Font),a
  ; We reload the font here
  call LoadFonts
  ; Then we need to wait for VBlank
  halt
  jp _OptionsSelect

+:dec a
  jr nz,+
  
_fade:
  ld a,(FadeSpeed)
  ; We want to swap between 1 and 0
  xor 1
  ld (FadeSpeed),a
  jp _OptionsSelect

+:dec a
  jr nz,+
  
_textSpeed:
  ; We want to range 0..3 for 1..4 displayed. 4x is really fast, no need for more.
  ld hl,TextSpeed
-:ld a,(hl)
  inc a
  cp 4
  jr c,+
  xor a
+:ld (hl),a
  jp _OptionsSelect

+:; should not get here
  jp _OptionsSelect

.include {"{LANGUAGE}/options-menu.asm"}

Continue:
  ld hl,FunctionLookupIndex
  ld (hl),8 ; LoadScene (also changes cursor tile)

  ld hl,ContinueWindow
  ld de,ContinueWindow_VRAM
  ld bc,ContinueWindow_dims
  call InputTilemapRect

  ld hl,ContinueMenu
  ld de,ContinueWindow_VRAM
  ld bc,ContinueWindow_dims
  call DrawTilemap

_SelectAction:
  ld hl,ContinueWindow_VRAM + ONE_ROW
  ld (CursorTileMapAddress),hl

  ld a,$ff
  ld (CursorEnabled),a ; CursorEnabled
  ld a,1 ; 2 options
  ld (CursorMax),a ; CursorMax
  call WaitForMenuSelection

  ; If button 1, return
  bit 4,c ; Button 1
  jr z,+

_continueReturn:
  ; return to title screen
  ld hl,ContinueWindow
  ld de,ContinueWindow_VRAM
  ld bc,ContinueWindow_dims
  call DrawTilemap
  ld de,TitleScreenCursorBase + ONE_ROW * 1
  jp BackToTitle

+:; remember the selection while we show the slot selection menu
  push af
    ; First check if there are any...
_checkForSaves:
    ld b,SAVE_SLOT_COUNT
    ld c,1
  -:ld a,b
    ld (NumberToShowInText),a
    call IsSlotUsed
    jp nz,+
    djnz -
    ; Nope
    call NoSavedGames
  pop af
  jr _continueDone

    ; Save tilemap
+:  ld hl,SAVE
    ld de,SAVE_VRAM
    ld bc,SAVE_dims
    call InputTilemapRect
    ; Select a savegame
-:  call GetSavegameSelection ; leaves value in NumberToShowInText
    ; check for button 1 or 2
    bit 4,c
    jr nz,_button1 ; cancel on 1 regardless of selection
    call IsSlotUsed
    jr z,- ; repeat selection until a valid one is chosen
  pop af


  ; now check what action
  or a
  jp z,ContinueSavedGame

_delete:
  call DeleteSavedGame

_closeSaveGameWindow:
  ; Restore tilemap
  ld hl,SAVE
  ld de,SAVE_VRAM
  ld bc,SAVE_dims
  call DrawTilemap

_continueDone:
  ; Clear cursor tile next to "delete"
  ld de,ContinueWindow_VRAM + ONE_ROW * 2
  rst $08
  ld a,$f3
  out ($be),a
  jr _SelectAction

_button1:
  pop af
  jr _closeSaveGameWindow

SoundTest:
  ld hl,FunctionLookupIndex
  ld (hl),8 ; LoadScene (also changes cursor tile)

  ld hl,SoundTestWindow
  ld de,SoundTestWindow_VRAM
  ld bc,SoundTestWindow_dims
  call InputTilemapRect

  ld hl,SoundTestMenuTop
  ld de,SoundTestWindow_VRAM
  ld bc,SoundTestMenuTop_dims ; (1<<8)|(15*2) ; top border
  call DrawTilemap
  call _chip
  ld hl,SoundTestMenu
  ld bc,SoundTestWindow_dims - $200 ; remove 2 rows
  call DrawTilemap
  ld hl,SoundTestWindow_VRAM + ONE_ROW
  ld (CursorTileMapAddress),hl

  ; We need to retain the selected music in order to restart it when the chip is changed.
  ; We start with the title screen music already playing
  ld a,$81
  ld (MusicSelection),a

  ; We hack the menu selection to retain the cursor position...
  ld hl,$0000
  ld (CursorPos),hl  ; 0 -> CursorPos, OldCursorPos

-:ld a,$ff
  ld (CursorEnabled),a ; CursorEnabled
  ld a,20 ; 21 options
  ld (CursorMax),a ; CursorMax
  call $2ec8 ; WaitForMenuSelection skipping the bit where it reset the cursor position

  ; If button 1, return
  ld b,a
  ld a,%00010000 ; Button 1
  cp c
  jr nz,+

_musicReturn:
  ; Return to title screen
  ; Hide the menu
  ld hl,SoundTestWindow
  ld de,SoundTestWindow_VRAM
  ld bc,SoundTestWindow_dims
  call DrawTilemap

  ; We need to hide the cursor as it resets to the top...
  ld de,TitleScreenCursorBase + ONE_ROW * 2
  jp BackToTitle

+:ld a,b

  or a
  jr nz,+
  ; Toggle FM - if allowed
  ld a,(HasFM)
  or a
  jr z,-
  ; Enable the right chip
  ld a,(Port3EValue)
  or $04 ; Disable IO chip
  out (PORT_MEMORY_CONTROL),a
  ld a,(UseFM)
  xor 1 ; happens to be the right value for the port this way
  ld (UseFM),a
  out (PORT_FM_CONTROL),a
  ld a,(Port3EValue)
  out (PORT_MEMORY_CONTROL),a  ; Turn IO chip back on
  ; Restart music
  ld a,(MusicSelection)
  ld (NewMusic),a
  ; Update menu
  call _chip
  jr -

+:sub 2 ; top 2 entries are not music
  jr c,-

  ; Look up ID
  ld hl,_ids
  add a,l
  ld l,a
  adc a,h
  sub l
  ld h,a
  ld a,(hl)

  ; Remember it
  ld (MusicSelection),a
  ; Play it
  ld (NewMusic),a

  ; Back to selection mode
  jr -

_ids:
; Music IDs matching the order in the menu
.db $81 ; Title Screen
.db $8C ; Intro
.db $87 ; Town
.db $86 ; Dungeon
.db $8E ; Shop
.db $8D ; Church
.db $82 ; Palma
.db $89 ; Battle
.db $8A ; Story
.db $88 ; Village
.db $8F ; Vehicle
.db $83 ; Motavia
.db $84 ; Dezoris
.db $90 ; Tower
.db $85 ; Final Dungeon
.db $92 ; LaShiec
.db $93 ; Dark Force
.db $8B ; Ending
.db $94 ; Game Over

_chip:
  ld de,SoundTestWindow_VRAM + ONE_ROW
  ld bc,SoundTestMenuChipPSG_dims ; (1<<8)|(15*2) ; one row
  ld hl,SoundTestMenuChipPSG
  ld a,(UseFM)
  or a
  jr z,+
  ld hl,SoundTestMenuChipYM2413
+:jp DrawTilemap ; and ret
.ends

.bank 0 slot 0
.section "No saved games message" free
NoSavedGames:
  ld a,(PAGING_SLOT_2)
  push af
    ld hl,ScriptNoSavedGames
    call TextBox
    call TextBoxEnd
    jp RestoreSlot2AndRet
.ends

.section "Save game deletion" free
DeleteSavedGame:
  ; We want to jump back to slot 2 when we are done
  ld hl,ScriptConfirmSlot ; Slot <n>, are you sure?
  call TextBox
  call DoYesNoMenu
  jr nz,_no

  ld hl,ScriptDeletingFromSlotN ; Deleting game from slot <n>.
  call TextBox

  ld a,SRAMPagingOn
  ld (PAGING_SRAM),a

  ; We need to blank $8200 + n
  ld h,$82
  ld a,(NumberToShowInText)
  ld l,a
  xor a
  ld (hl),0

  ; compute where to write to
  ; a = 1-based index
  ; we want de = SaveTilemap + (a * (SAVE_NAME_WIDTH+4) + 2) * 2
  ld d,0
  ld e,l
  ld hl,0
  ld b,SAVE_NAME_WIDTH+4
-:add hl,de
  djnz -
  inc hl
  inc hl
  add hl,hl
  ld de,SaveTilemap
  add hl,de
  ld e,l
  ld d,h
  ; We then want to copy the blank we are pointing at to the right
  inc de
  inc de
  ld bc,SAVE_NAME_WIDTH*2
  ldir

  ld a,SRAMPagingOff
  ld (PAGING_SRAM),a

_no:
  call TextBoxEnd

  ld a,:Continue
  ld (PAGING_SLOT_2),a
  ret
.ends

.section "Continue a saved game" free
ContinueSavedGame:
  ld a,SRAMPagingOn  ; Load game
  ld (PAGING_SRAM),a
  ld a,(NumberToShowInText) ; 1-based
  ld h,a
  ld l,0
  add hl,hl
  add hl,hl
  set 7,h            ; hl = $8000 + $400*a = slot a game data ($400 bytes)
  ld de,$c300
  ld bc,1024 ; bytes
  ldir               ; Copy
  ld a,SRAMPagingOff
  ld (PAGING_SRAM),a

  ; This is important, not sure what it does :)
  ld a,($c316)       ; Check xc316
  cp 11
  ret nz             ; if == 11

  ld hl,FunctionLookupIndex
  ld (hl),$0a        ; Start game
  ret
.ends

; We want to access the tilemap drawing code from high banks, so we make a low trampoline here that preserves the slot
.slot 0
.section "Menu drawing trampoline" free
DrawTilemap:
  ld a,(PAGING_SLOT_2)
  push af
    call OutputTilemapBoxWipePaging
    jp RestoreSlot2AndRet
.ends

; SRAM helpers need to be in bank 0 or 1
.bank 1 slot 1
.section "Setting SRAM helpers" free
SettingsToSRAM:
  ld hl,SettingsStart
  ld de,$8210 ; SRAM location
CopySettings:
  ld bc,SettingsEnd-SettingsStart
  ld a,SRAMPagingOn
  ld (PAGING_SRAM),a
  ldir
  ld a,SRAMPagingOff
  ld (PAGING_SRAM),a
  ret

SettingsFromSRAM:
  ; We first check if SRAM is working
  ld hl,$8000 ; SRAM marker
  ld de,$0962 ; Expected value
  ld bc,$0040 ; length
  ld a,SRAMPagingOn
  ld (PAGING_SRAM),a
-:ld a,(de)
  inc de
  cpi
  jr nz,+ ; Skip copying if SRAM is bad
  jp pe,- ; parity odd indicates underflow of bc

  ld hl,$8210
  ld de,SettingsStart
  call CopySettings

  ; If they are not valid, we need to initialise the multipliers to non-zero. Other options have 0 = original behaviour.
  ld a,(ExpMultiplier)
  or a
  jr nz,++
+:
  ld a,1
  ld (ExpMultiplier),a
  ld (MoneyMultiplier),a
  
++:
  ret
.ends

; We hook the FM detection so we can cache the result
  PatchW $00cf FMDetectionHook

.slot 0
.section "FM detection hook" free
FMDetectionHook:
  call $03a4 ; do FM detection
  ld a,(UseFM)
  ld (HasFM),a
  ret
.ends



; Walking speedup
; The game moves by 1px for 16 frames, or 2px for 8 frames, depending on whether you are in a vehicle or walking.
; We patch that to 2x8 or 4x4.

  ROMPosition $7409
.section "Walking speed patch trampoline" overwrite
  ; Max 13 bytes, using 11
  ld hl,WalkingFramesPerStep
  call GetMovementSpeedLookup
  ld (MovementFrameCounter),a
  JR_TO $7416
.ends

  ROMPosition $7416
.section "Walking speed patch trampoline 2" overwrite
  ; Max 10 bytes
  call WalkingSpeedPatch
  JR_TO $7420
.ends

.section "Walking speed patch data" free
WalkingFramesPerStep:
  .db 8-1, 16-1, 4-1, 8-1
WalkingPixelsPerFrame:
  .db 2, 1, 4, 2
.ends

.section "Walking speed patch helper" free
GetMovementSpeedLookup:
  ld a,(VehicleType) ; zero or non-zero
  sub 1 ; will carry if zero
  ld a,(MovementSpeedUp) ; 1 or 0
  adc a,a ; now it's 0-3
  ; %00 = vehicle x1
  ; %01 = walking x1
  ; $10 = vehicle x2
  ; $11 = walking x2
  ; Look up in table
  add a,l
  ld l,a
  adc a,h
  sub l
  ld h,a
  ld a,(hl)
  ret
.ends

.section "Walking speed patch part 2" free
WalkingSpeedPatch:
  ld hl,WalkingPixelsPerFrame
  call GetMovementSpeedLookup
  ld d,0
  ld e,a
  ret
.ends

; Animation and character following is driven by a particular frame number in the sequence...
  ROMPosition $5d20
.section "Walking speed patch part 3 trampoline" overwrite
;    cp     $0f             ; 005D20 FE 0F
;    jp     nz,$5dac        ; 005D22 C2 AC 5D
  jp WalkingSpeedPatch3
.ends

.section "WalkingSpeedPatch3" free
WalkingSpeedPatch3:
  push bc
  ld b,a ; save counter value

  ; Walking mode, we want $f or $7
  ld a,(MovementSpeedUp)
  or a
  jr nz,+
  ld a,$f
  jr ++
+:ld a,$7
++:
  cp b
  pop bc
  jp nz,$5dac
  jp $5d25
.ends

; In the handler we then want to set an animation counter for the walking sequence
  ROMPosition $5dbb
.section "Walking speed patch part 4 trampoline" overwrite
;    ld     (iy+$0e),$07    ; 005DBB FD 36 0E 07
  jp WalkingSpeedPatch4
.ends

.section "WalkingSpeedPatch4" free
WalkingSpeedPatch4:
  ld a,(MovementSpeedUp)
  or a
  jr nz,+
  ld (iy+$e),7
  jp $5dbf
+:ld (iy+$e),3
  jp $5dbf
.ends

  ROMPosition $5de9
.section "Sprite movement for followers hook" force
;    jp     nc,$5df7        ; 005DE9 D2 F7 5D ; horizontal
;    or     a               ; 005DEC B7
;    jr     nz,$5df0        ; 005DED 20 01 ; up => add 1 to iy+2
;    dec    a               ; 005DEF 3D ; down => add -1 to iy+2
;    add    a,(iy+$02)      ; 005DF0 FD 86 02
;    ld     (iy+$02),a      ; 005DF3 FD 77 02
;    ret                    ; 005DF6 C9
;
;    ; now 0 = left, 1 = right
;    sub    $02             ; 005DF7 D6 02
;    jr     nz,$5dfc        ; 005DF9 20 01
;    dec    a               ; 005DFB 3D ; -1 or +1 to iy+4
;    add    a,(iy+$04)      ; 005DFC FD 86 04
;    ld     (iy+$04),a      ; 005DFF FD 77 04
;    ret                    ; 005E02 C9
  ; We want to change those +/-1 to +/-2...
  jp SpriteMovementPatch
.ends

.bank 0 slot 0
.section "Sprite movement for followers" free
SpriteMovementPatch:
  jr nc,_vertical
_horizontal:
  call _getDelta
  add a,(iy+2)
  ld (iy+2),a
  ret
_vertical:
  call _getDelta
  add a,(iy+4)
  ld (iy+4),a
  ret

_getDelta:
  push hl
    push af
      ; Check which table to use
      ld a,(MovementSpeedUp)
      or a
      jr z,+
      ld hl,_table
      jr ++
+:    ld hl,_table2
++: pop af
    add a,l
    ld l,a
    adc a,h
    sub l
    ld h,a
    ld a,(hl)
  pop hl
  ret
_table:
.db -2, +2, -2, +2
_table2:
.db -1, +1, -1, +1
.ends



; Experience is increased proportionally to the number of enemies. We intercept the multiplication to add another one.
  ROMPosition $634c
.section "Experience multiplier trampoline" overwrite
  call ExperienceHack
.ends

.bank 1 slot 1
.section "Experience multiplier" free
ExperienceHack:
  call Multiply16 ; What we stole to get here
  ; We want to multiply this again
  ex de,hl
  ld a,(ExpMultiplier)
  ld c,a ; b is already 0
  jp Multiply16 ; and ret
.ends



; Money is already multiplied by the enemy count, we can easily chain an extra multiplication on. This is very similar to ExperienceHack above.
  ROMPosition $6335
.section "Money multiplier trampoline" overwrite
  call MoneyHack
.ends

.bank 1 slot 1
.section "Money multiplier" free
MoneyHack:
  call Multiply16 ; What we stole to get here
  ; We want to multiply this again
  ex de,hl
  ld a,(MoneyMultiplier)
  ld c,a ; b is already 0
  jp Multiply16 ; and ret
.ends



; Enemy encounters are when a random number is less than some threshold... which is in b here:
  ROMPosition $10b4
.section "Battle reducer trampoline" overwrite
;    call GetRandomNumber           ; 0010B4 CD 6A 06
  call BattleReducer
.ends

.section "BattleReducer" free
BattleReducer:
  ld a,(FewerBattles)
  or a
  jr z,+
  ; if non-zero, we halve b
  srl b
+:jp GetRandomNumber ; and return
.ends



; Alisa's hair is brown in the portrait art but brown in the in-game sprite.
; Inspired by the "brunette Alisa" hack, we make that an option.
; Sprites are streamed in for animation, so they are stored uncompressed in the ROM.
; We therefore need to swap out the address for Alisa based on the option.
.unbackground $64a5 $64c1
  ROMPosition $64a5
.section "Brunette Alisa hook" force
  jp BrunetteAlisaCheck
.ends

.bank 0 slot 0
.section "Brunette Alisa check" free
BrunetteAlisaCheck:
  ; We copy some of the code from the place we patched...
  ld e,0
  srl d
  rr e
  ld l,e
  ld h,d
  srl d
  rr e
  add hl,de
  ld de,$8000 ; source address

  ; Now we need the flag to replace this address...
  ld a,(BrunetteAlisa)
  or a
  jr z,+

  ld a,:BrunetteAlisaTiles
  ld (PAGING_SLOT_2),a
  ld de,BrunetteAlisaTiles

+:; Back to the original code
  add hl,de
  ld de, $7540 ; VRAM address
  rst $8
  ld c,PORT_VDP_DATA
  call $5b1a ; outi128
  call $5b9a ; outi64 ; Changed from a jp to a call
  ; Restore paging for other characters
  ld a,$1c
  ld (PAGING_SLOT_2),a
  ret
.ends

; and the data can be anywhere...
.slot 2
.section "Brunette Alisa tiles" superfree
BrunetteAlisaTiles:
.incbin "generated/alisa-sprite.bin"
.ends



; The font is part of the recompressed assets anyway, so we needed to replace the loaders no matter what. We add a switch based on the option.
; First we put the font data and loader functions in a high bank. This is about 1.2KB, so fairly large but not huge. The font is in two parts due to VRAM layout, and we need a way to load just the upper part for dungeon pitfalls.
.slot 2
.section "Font part 1" superfree
FONT1: .incbin {"generated/{LANGUAGE}/font-polaris-part1.psgcompr"}
FONT2: .incbin {"generated/{LANGUAGE}/font-polaris-part2.psgcompr"}
FONT1a: .incbin {"generated/{LANGUAGE}/font-aw2284-part1.psgcompr"}
FONT2a: .incbin {"generated/{LANGUAGE}/font-aw2284-part2.psgcompr"}
.define Font1VRAMAddress $5800
.define Font2VRAMAddress $7e00
LoadFontsImpl:
    ld hl,Font1VRAMAddress
    ld de,FONT1
    ld a,(Font)
    or a
    jr z,+
    ld de,FONT1a
+:  call LoadTiles
    ; then fall through into the following

LoadUpperFontImpl:
    ld hl,Font2VRAMAddress
    ld de,FONT2
    ld a,(Font)
    or a
    jr z,+
    ld de,FONT2a
+:  jp LoadTiles ; and ret
.ends

; Then we have trampolines in low ROM...
.bank 0 slot 0
.section "Load font to VRAM" free
LoadFonts:
  ld a,(PAGING_SLOT_2)
  push af
    ld a,:LoadFontsImpl
    ld (PAGING_SLOT_2),a
    call LoadFontsImpl
RestoreSlot2AndRet: ; Common pattern so we reuse it to save 2-3 bytes each time
  pop af
  ld (PAGING_SLOT_2),a
  ret

LoadUpperFont:
  ld a,(PAGING_SLOT_2)
  push af
    ld a,:LoadUpperFontImpl
    ld (PAGING_SLOT_2),a
    call LoadUpperFontImpl
    jr RestoreSlot2AndRet
.ends

; We use a macro to patch out all the places the font is laoded...
.macro PatchFontLoader args function, start, end
  .unbackground start end-1
  ROMPosition start
  .section "Font patch \@" force
    call function
    JR_TO end
  .ends
.endm

  PatchFontLoader LoadFonts $45a4 $45c4 ; Intro
  PatchFontLoader LoadFonts $10e3 $10fa ; Dungeon
  PatchFontLoader LoadFonts $3dde $3df5 ; Overworld
  PatchFontLoader LoadFonts $48da $48f1 ; Cutscene
  PatchFontLoader LoadUpperFont $6971 $697f ; After dungeon pitfall - scrolling overwrites the "font2" section but we need to not load the "main" font because during the ending it's non-standard



; The game fades out over 9 steps, each held for 4 frames, for a total of over half a second at 60Hz. We tweak that down to 1 frame for a speedier, yet still nicely fading, experience.
  ROMPosition $7de7
.section "Fade speed hack" overwrite
; Original code
;    ld     hl,$c21d        ; 007DE3 21 1D C2 Get counter
;    dec    (hl)            ; 007DE6 35       Decrement it
;    ret    p               ; 007DE7 F0 
;    ld     (hl),$03        ; 007DE8 36 03    Reset -> run every 4 frames
  jp SpeedHack
SpeedHackEnd:
.ends

.section "Fade speed hack part 2" free
SpeedHack:
  ; Code we replaced to get here
  ret p
  ; And then replace the 3 with a value from RAM
  ld a,(FadeSpeed)
  or a
  ld a,3 ; "normal" frame counter for 4 frames per step
  jr z,+
  xor a ; "fast" frame counter for 1 frame per step
+:ld (hl),a
  jp SpeedHackEnd
.ends


; For linguistic reasons, we want to use a slightly different script line
; for when the number of mesetas in a chest is one.
  ROMPosition $2a8c
.section "Chest mesetas plural enhancement part 1" overwrite
; Original code:
; hl = count, may be 0
;    ld     a,h             ; 002A8A 7C 
;    or     l               ; 002A8B B5 
;    ld     hl,$afda        ; 002A8C 21 DA AF ; There were <n> mesetas inside.
;    call   nz,$333a        ; 002A8F C4 3A 33 
  nop
  nop
  nop
  call ChestMesetas
.ends

.section "Chest mesetas plural enhancement part 2" free
ChestMesetas:
  ; We check hl again
  ld a,h
  or a
  jr nz,_plural; More than 255
  ld a,l
  or a
  ret z ; Zero
  dec a
  jr nz,_plural ; More than 1
  ; Must be 1
  ld hl,ChestMesetasSingular
  jp TextBox ; and ret
_plural:
  ld hl,ChestMesetasPlural
  jp TextBox ; and ret
.ends