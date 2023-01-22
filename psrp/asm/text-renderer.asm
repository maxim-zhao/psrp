  ROMPosition $34f2
.section "Character drawing" force ; not movable
; Originally t0d.asm
CharacterDrawing:
; Replacing draw-one-character function from $34f2-3545
; drawing 2 tilemap chars, with conditional mirroring, and a scrolling handler,
; with a new one from $3f42-3f66 that draws a single char using a 2-byte lookup
; and leaves the scrolling to be handled by the word-wrapping code elsewhere

  cp SymbolNewLine
  jr nz,+
  xor a ; set to 0 for newlines to avoid drawing junk
+:
  di            ; prepare VRAM output

  push af
    rst $08      ; Set address
  pop af

  call EmitCharacter

  ; Bump VRAM address
  inc de
  inc de
  ld a,(TextDrawingCharacterCounter)
  sub 1 ; dec a doesn't change carry
  ei               
  jp nc,+

  ; Wait for VBlank 
  ld a,10          ; Trigger a name table refresh
  call ExecuteFunctionIndexAInNextVBlank

  ld a,(TextSpeed) ; reset counter
+:ld (TextDrawingCharacterCounter),a

  dec b             ; Shrink window width
  ret
.ends

.section "Font lookup helper" free
EmitCharacter:
  ; We look up the two-byte tile data for character index a,
  ; and emit to the VDP
  push hl
    ld h,>FontLookup ; Aligned table
    add a,a
    ld l,a
    
    ld a,(PAGING_SLOT_2)
    push af
      ld a,:FontLookup
      ld (PAGING_SLOT_2),a
      ld a,(hl)
      out (PORT_VDP_DATA),a
      push af       ; VRAM wait
      pop af
      inc hl
      ld a,(hl)
      out (PORT_VDP_DATA),a
    pop af
    ld (PAGING_SLOT_2),a
  pop hl
  ret
.ends

.bank 0 slot 0 ; Dictionary lookup must be in slot 0 as the others are being mapped.

.section "Dictionary lookup" free
  ; HL = Table offset
  ; A = item index
  ; We skip over the elements sequentially rather than have an index.
DictionaryLookup:
  push af
    ld a,:Lists ; Load normal lists
    ld (PAGING_SLOT_2),a
    jr +

DictionaryLookup_Substring:
  push af
    ld a,:Words ; Load dictionary
    ld (PAGING_SLOT_2),a

+:pop af      ; Restore index #
  ld b,0      ; String lengths are always <256

-:ld c,(hl)   ; Grab string length
  or a        ; Check for zero strings left
  jr z,@Copy  ; _Stop if found

  inc hl      ; Bypass length byte
  add hl,bc   ; Bypass physical string
  dec a       ; One less item to look at
  jr -        ; Keep searching

@Copy:
  ; Apply bracketed parts skipping here.
  ; This code is used for all item lookups.
  ; hl = source
  ld de,TEMP_STR ; destination
  ld (STR),de ; set pointer to it
  ld b,(hl) ; Get byte length in b
  inc hl
_NextByte:
  ; Read a byte
  ld a,(hl)
  inc hl
  cp $62 ; bracket start
  jr z,_bracket
  cp $63 ; bracket end
  jr nz,+
_SkipEndBracket:
  djnz _NextByte
  jr _Done

+:; Copy the byte
  ld (de),a
  inc de
  djnz _NextByte ; Loop until counter reaches zero

_Done:
  ; Compute the actual length
  ld hl,$10000 - TEMP_STR
  add hl,de
  ld a,l
  ld (LEN),a
  ld a,2    ; Normal page
  ld (PAGING_SLOT_2),a
  ret

_bracket:
  ; get the skip type
  ld a,(hl)
  inc hl
  dec b ; Two bytes of the string have been consumed
  dec b
  push hl
    ld hl,SKIP_BITMASK
    and (hl)
  pop hl
  ; if non-zero, carry on consuming the bracket contents
  jr nz,_NextByte
  ; We discard bytes until we see a $63. We assume we won't have unbalanced brackets.
-:ld a,(hl)
  inc hl
  cp $63
  jr z,_SkipEndBracket
  djnz -
  jr _Done
.ends

.enum $5f ; Scripting codes. These correspond to codes used by the original game, plus some extensions.
; If changing the value here, you must also change the symbols range in tools.py
; and values used for articles and name block removal ([...]) in script.<xx>.tbl
; and values in the code below to handle these
  SymbolStart     .db
  SymbolPlayer    db ; $5f, Handled by the original engine
  SymbolMonster   db ; $60,
  SymbolItem      db ; $61,
  SymbolNumber    db ; $62,
  SymbolBlank     db ; $63, ; Unused
  SymbolNewLine   db ; $64,
  SymbolWaitMore  db ; $65,
  SymbolEnd       db ; $66,
  SymbolDelay     db ; $67,
  SymbolWait      db ; $68,
  SymbolPostHint  db ; $69, ; New codes
  SymbolArticle   db ; $6a,
  SymbolSuffix    db ; $6b,
  SymbolPronoun   db ; $6c,
  WordListStart   db ; $6d
.ende

; We patch the usages of these codes so we can relocate them.
; Narrative:
  PatchB $3366+1 SymbolWait
  PatchB $336b+1 SymbolEnd
  PatchB $336e+1 SymbolDelay
  PatchB $3373+1 SymbolWaitMore
  PatchB $337d+1 SymbolBlank
  PatchB $3393+1 SymbolNewLine
  PatchB $33a6+1 SymbolPlayer
  PatchB $33c4+1 SymbolMonster
  PatchB $33d6+1 SymbolItem
  PatchB $33f4+1 SymbolNumber
; Cutscenes:
  ; PatchB $34b5+1 SymbolDelay ; First two are patched over below, see "Cutscene text decoder patch"
  ; PatchB $34b9+1 SymbolWait
  PatchB $34bd+1 SymbolWaitMore
  PatchB $34c1+1 SymbolNewLine


.slot 1
.section "Additional scripting codes" semisuperfree banks 3-31
AdditionalScriptingCodes:
; Originally t4a_2.asm
; Narrative formatter
; - Extra scripting codes

_Start:
  call SubstringFormatter    ; Check substring RAM

  cp SymbolNewLine
  jr z,+

  cp SymbolEnd      ; Look for decode flag
  jp nz,_Done

_Decode:
  call SFGDecoder    ; Regular decode

+:cp SymbolPostHint
  jr nz,+   ; Check next code

  call SFGDecoder    ; Grab length
  ld (POST_LEN),A   ; Cache it
  jr _Decode   ; Immediately grab next code

+:cp $00      ; Whitespace
  jr nz,+   ; Check next code

  push hl
    ld (TEMP_STR),a   ; Store WS, $00
    inc a             ; A = $01
    ld (LEN),a        ; Store length
    ld hl,TEMP_STR    ; Load string location
    ld (STR),hl       ; Store string pointer
  pop hl

  call SubstringFormatter    ; Our new dictionary lookup code will do auto-formatting

  ; Intentional fall-through

+:cp SymbolWaitMore
  jr nz,+

_Reset_Lines:
  push af
    xor a
    ld (LINE_NUM),a   ; Clear # lines used
  pop af

  jp _Done

+:cp SymbolNewLine
  jr nz,+   ; Next code
  push hl     ; Automatic narrative waiting

    ld hl,LINE_NUM    ; Grab # lines drawn
    inc (hl)    ; One more line _Break
    ld l,(hl)   ; Load current value

    ld a,(VLIMIT)   ; Read vertical limit
    cp l      ; Check if limit reached
    jr z,_WAIT

_NO_WAIT:
    ld a,SymbolNewLine  ; Reload newline
    jr ++

_WAIT:
    ld a,SymbolWaitMore ; wait more
    ld (FLAG),a   ; Raise flag
    ld hl,LINE_NUM

_Wait_Clear:
    dec (hl)    ; Keep shrinking # lines drawn
    jr nz,_Wait_Clear  ; to save 1 byte of space

++:
  pop hl      ; Restore stack
  jr _Done

+:cp WordListStart
  jr c,+    ; Control codes, don't interfere

  sub WordListStart     ; Subtract offset

  push hl
  push de
  push bc

    ld hl,Words
    call DictionaryLookup_Substring   ; Relocate substring entry and copy

  pop bc
  pop de
  pop hl

  jp _Start    ; Our new dictionary lookup code

+:cp SymbolArticle
  jr nz,+

  call SFGDecoder    ; Grab #
  ld (ARTICLE),a
.if LANGUAGE == "de"
  ; Set SKIP_BITMASK accordingly
  ; 1 => %01000 (nominative, select «» brackets only)
  ; 2 => %01010 (genitive, select «» and {} brackets)
  ; 3 => %11100 (dative, select «», ‹› and () brackets)
  ; 4 => %01100 (accusative, select «» and () brackets)
  push hl
  push de
    ld d,0
    ld hl,_SkipBitmaskLookup - 1 ; index 0 is unused
    ld e,a
    add hl,de
    ld a,(hl)
    ld (SKIP_BITMASK),a
  pop de
  pop hl
  jp _Decode
_SkipBitmaskLookup: .db %01000, %01010, %11100, %01100 ; see above
.else
  ; Select all bracketed parts
  ld a,$ff
  ld (SKIP_BITMASK),a
  jp _Decode
.endif

+:cp SymbolSuffix
  jr nz,+

  ld a,(SUFFIX)   ; Check flag
  or a
  jp z,_Decode   ; No 's' needed

  ;ld a,LETTER_S   ; add 's'
  .db $3e ; ld a, nn opcode
.include {"{LANGUAGE}/plurals.asm"}
  jr _Done

+:cp SymbolPronoun
  jr z,_Pronoun

_Done:
  cp SymbolWait ; Old code
  ret     ; Go to remaining text handler

_Pronoun:
  call SFGDecoder    ; Grab #
  push hl
  push de
  push bc
    push af
      ; Look up character
      ld a,(NameIndex)
      and 3
      add a,a
      ; Look up in table
      ld hl,_Pronouns
      ld d,0
      ld e,a
      add hl,de
      ld a,(hl)
      inc hl
      ld h,(hl)
      ld l,a
    pop af
    ; Then look up the pronoun index
    add a,a
    ld e,a
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ; Finally we want to emit this text. We call into the dictionary lookup code to copy it to RAM and point to it...
    call DictionaryLookup_Substring@Copy
  pop bc
  pop de
  pop hl
  ; Then we jump to here. This makes the copy above get drawn before continuing.
  jp _Start

_Pronouns: ; Lookup by character index: Alisa, Myau, Tyron, Lutz
.dw _PronounsF, _PronounsM, _PronounsM, _PronounsM
.include {"{LANGUAGE}/pronouns.asm"}

SubstringFormatter:
; Needs to be in the same bank as AdditionalScriptingCodes
; Originally t4a_3.asm
; Narrative formatter
; - Dictionary processing

; substring inserter
; b = space left on line
; (STR)w = pointer to string
; (LEN)b = length
; returns tile index to be drawn in a,
; or a newline if a new line is needed for this insertion

_Lookup:
  ld a,(LEN)    ; Grab length of string
  or a      ; Check for zero-length
  ld a,SymbolEnd    ; Load 'abort' flag
  ret z     ; Return if NULL

_Substring:
  ld a,b      ; Save width
  ld (HLIMIT),a

  push hl     ; Stack registers
  push bc

    ld bc,(STR)   ; Grab raw text location
    ld hl,LEN   ; Grab address of length

    ; ------------------------------------------------------
    ; Article (The, An, A) handler

    push de     ; init

      ld a,(ARTICLE)    ; Check for article usage
      or a
      jp z,_Art_Exit   ; article = none

; Articles are stored backwards
.macro Article
  .stringmap script \1
  .db SymbolEnd
.endm

.include {"{LANGUAGE}/articles.asm"}

_Start_Art:
      ld a,(bc)   ; Grab index
      sub $64     ; Remap index range ($64 is the lowest article index)
      jr c,_Art_Done ; if there is a letter there, it'll be 0..$40ish. So do nothing.
      add a,a     ; Multiply by two
      add a,e     ; Add offset
      ld e,a
      adc a,d
      sub e
      ld d,a

      ld a,(de)   ; Grab final string offset
      inc de
      push af
        ld a,(de)
        ld d,a
      pop af
      ld e,a

_Add_Art:
      ld a,(de)   ; grab font #
      cp SymbolEnd
      jr z,_Art_Done

      dec bc      ; bump dst pointer
      ld (bc),a   ; add tile
      inc de      ; bump src
      inc (hl)    ; bump length
      jr _Add_Art

_Art_Done:
      ld (STR),bc   ; store new text pointer
      xor a
      ld (ARTICLE),a    ; lower flag
      ld (SKIP_BITMASK),a ; and clear this too

_Art_Exit:
    pop de      ; now proceed normally
    ld bc,(STR)   ; Grab raw text location (again)
    jp _Initial_Codes



_Initial_Codes:
    ld a,(bc)   ; Grab character
    cp SymbolStart      ; Skip initial codes
    jr c,_Begin_Scan   ; Look for first real font tile

    ; Initial code skipper:
    inc bc      ; Bump pointer
    ld (STR),bc   ; Save pointer
    dec (hl)    ; Shrink length
    jr nz,_Initial_Codes ; Loop if still alive
    ; terminate if we got to the end
    ld a,SymbolEnd
    jr +

_Begin_Scan:
    push hl     ; Save new current length
    push bc     ; Save new text pointer

      ld h,(hl)   ; Init string counter
      ld l,0      ; Current length is zero

      call _One_Font   ; get length up to next whitespace in l

      ld a,(HLIMIT)   ; Remaining width
      sub l     ; Remove characters used

      jr nc,_No_Spill    ; No text spillage

_Text_Spill:
    pop bc      ; Restore old text pointer
    pop hl      ; Reload length pointer

    ld a,(bc)   ; Reload first scanned character
    or a      ; Check for whitespace ($00)
    jr nz,_Text_Spill_Line ; Don't eat non-WS

_Text_Spill_WS:
    inc bc      ; Bump text pointer
    ld (STR),bc   ; Store new location

    dec (hl)    ; Shrink length

_Text_Spill_Line:
    ld a,SymbolNewLine    ; newline
+:
  pop bc      ; Stack registers
  pop hl
  ret     ; exit

_No_Spill:
    pop bc      ; Restore original text pointer
    pop hl      ; Restore length pointer

    dec (hl)    ; Shrink text length

    ld a,(bc)   ; Read in text character
    inc bc      ; Bump text pointer
    ld (STR),bc   ; Store new location

  pop bc      ; Stack registers
  pop hl
  ret

; Note: Treat first character as a regular tile, regardless of WS

_Scan_String:
  inc bc      ; Bump text cursor
  dec h     ; Shrink text
  jr z,_Stop   ; Length exhausted == 0

  ld a,(bc)   ; Grab character
  or a      ; Check for whitespace
  jr z,_Break    ; If char == 0, _Stop

  cp SymbolStart      ; Control codes
  jr nc,_Scan_String ; Ignore special script values

_One_Font:
  inc l     ; One font drawn
  jr _Scan_String

_Stop:
  ld bc,POST_LEN    ; Load post-hint address
  ld a,(bc)   ; Load post-hint value
  add a,l     ; Tack on length BUG?: two-word substitutions get the extra added to the first word
  ld l,a      ; Store for return

  xor a
  ld (bc),a   ; Clear post-hint value

_Break:
  ret
.ends

  ROMPosition $34aa
.section "Cutscene narrative init patch" overwrite ; not movable
CutsceneNarrativeInit:
  ; This code deliberately fills 6 bytes to patch over the original code:
; ld de,$7c0c
; ld bc,$0000
  ld a,0 ; method selection (0)
  call DecoderInit
  ret
  ; DecoderInit will call this label:
CutsceneNarrativeInitOriginalCode:
.ends

  ROMPosition $34b4
.section "Cutscene text decoder patch" overwrite ; not movable
CutsceneTextDecoder:
  ; This patches later in the same function as above. Original code:
; ld a,(hl)
; cp $57
; jr z,$34ed ; exit after pause
; cp $58
; jr z,$34e8 ; exit after button
  call AdditionalScriptingCodes ; handle extra narrative codes, performs comparison to $58 before returning
  jr z,ExitAfterButton
  cp SymbolDelay
  jr z,ExitAfterPause
.ends

  ROMPosition $34e5
.section "Cutscene $55 clear code patch" overwrite ; not movable
CutsceneClearCode:
  jp CutsceneClear

  ; The rest is the same as the original code, but we want to get the labels for above
ExitAfterButton:
  call MenuWaitForButton
  pop de
  ret

ExitAfterPause:
  call Pause256Frames
  pop de
  ret
.ends

  ROMPosition $333f
.section "In-game narrative init patch" overwrite ; not movable
InGameNarrativeInit:
; Original code:
; ld a,(TextBox20x6Open)
; or a
  ; Patch is identical size
  dec a ; method selection (1) ; a is 2 due to existing code
  jp DecoderInit
  ; DecoderInit will call this label:
InGameNarrativeInitOriginalCode:
.ends

  ROMPosition $3365
.section "In-game text decoder" overwrite ; not movable
InGameTextDecoder:
  call AdditionalScriptingCodes
.ends


; Narrative scripting

  ROMPosition $33da
.section "Item lookup patch" force ; not movable
ItemLookup:
; Originally t1c_1.asm
; Item lookup
; Original code:
; push hl
;   ld a,(ItemIndex)
;   ld l,a
;   ld h,0
;   add hl,hl
;   add hl,hl
;   add hl,hl
;   push bc
;     ld bc,ItemTextTable
;     add hl,bc  ; hl = ItemTextTable
;   pop bc         ;    + ItemIndex * 8
;   ld a,8
;   call _DrawALetters
; pop hl
; inc hl
; jp _ReadData
; 26 bytes

  push hl     ; Save string ptr
  push de     ; Save VRAM ptr
  push bc     ; Save width, temp

    ld a,(ItemIndex)
    ld hl,Items

LookupItem:
    call DictionaryLookup

  pop bc
  pop de
  pop hl
  jp InGameTextDecoder    ; Decode next byte
  ; 18 bytes
.ends

  ROMPosition $33aa
.section "Player lookup patch" force ; not movable
PlayerLookup:
; Originally t1c_2.asm
; Player lookup
; Original code:
; push hl
;   ld a,(TextCharacterNumber)
;   and $03        ; just low 2 bits
;   add a,a        ; multiply by 4
;   add a,a
;   ld hl,_CharacterNames
;   add a,l
;   ld l,a
;   adc a,h
;   sub l          ; hl = _CharacterNames
;   ld h,a         ; + 4*TextCharacterNumber
;   ld a,4
;   call _DrawALetters
; pop hl
; inc hl             ; next data
; jp _ReadData
; 25 bytes

  push hl     ; Save string ptr
  push de     ; Save VRAM ptr
  push bc     ; Save width, temp

    ld a,(NameIndex)
    and 3 ; I guess it uses the other bits for something?
    ld hl,Names
    jp LookupItem
  ; 13 bytes
.ends

  ROMPosition $33c8
.section "Enemy lookup patch" force ; not movable
EnemyLookup:
; Enemy lookup
; Original code:
; push hl
;   ld hl,EnemyName
;   ld a,8
;   call _DrawALetters
; pop hl
; inc hl
; jp _ReadData
; 12 bytes
  push hl     ; Save string ptr
  push de     ; Save VRAM ptr
  push bc     ; Save width, temp
    ld a,(EnemyIndex)
    ld hl,Enemies
    jp LookupItem
  ; 10 bytes
.ends

  ROMPosition $33f6
.section "Number lookup patch" force ; not movable
NumberLookup:
; Originally t1b.asm
; Narrative number BCD creater
; in-line number display
; Old: inline looping (costs space), simple, direct output
; New: renders string to a temp buffer for wrapping,
;      stores a flag to tell if it was singular or plural,
;      pulls digit calculation out to save space
;      105 bytes
  jr z,+ ; draw number if z
  call CharacterDrawing ; else draw a regular letter
  jp InGameTextDecoder         ; and loop
+:call DrawNumberToTempStr
  inc hl      ; Process next script
  jp InGameTextDecoder

DrawNumberToTempStr:
  push hl      ; Save string ptr
  push bc      ; Width, temp
  push ix      ; Temp

    ld hl,(NumberToShowInText)    ; Load 16-bit parameter
    ld ix,TEMP_STR   ; Decode to buffer

    ld bc,10000    ; # 10000's
    call _BCD_Digit
    ld (ix+0),a

    ld bc,1000     ; # 1000's
    call _BCD_Digit
    ld (ix+1),a

    ld bc,100      ; # 100's
    call _BCD_Digit
    ld (ix+2),a

    ld bc,10       ; # 10's
    call _BCD_Digit
    ld (ix+3),a

    ld a,l      ; # 1's (_BCD_Digit has made it only possible to be in the range 0..9)
    inc a       ; add 1 because result = digit+1
    ld (ix+4),a


    ; scan the resultant string to see where the first non-zero digit is
    ; but we want to show the last digit even if it is zero
    ld b,4      ; look at 4 digits max
    ld hl,TEMP_STR    ; scan value

_Scan:
    ld a,(hl)    ; load digit
    cp $01      ; check for '0'
    jr nz,_Done
    xor a       ; blank
    ld (hl),a
    inc hl      ; bump pointer
    djnz _Scan

_Done:
    ld a,b
    inc a         ; 1 <= length <= 5
    ld (STR),hl   ; save ptr to number string
    ld (LEN),a    ; save length

    ; length != 1 -> must be plural
    cp 1
    jr nz,_Plural  ; length must be 1

    ; else check for '1'
    ld a,(hl)
    cp $02      ; last digit = '1'
    jr nz,_Plural

_Singular:
    xor a      ; Clear flag

_Plural:
    ; a is non-zero on jumps to this point
    ; and zero for the singular case
    ld (SUFFIX),a    ; 'x' mesata(s)

  pop ix      ; Restore stack
  pop bc
  pop hl
  ret

_BCD_Digit:
  xor a ; clear carry flag, a = 0

; subtract bc from hl until it overflows, then add it on again
; return a = number of subtractions done until overflow occurred,
;        hl = hl % bc
; so a = hl / bc + 1 (integer division + 1)
; eg. hl =  9999, bc = 10000, a = 1
; eg. hl = 10000, bc = 10000, a = 2
-:sbc hl,bc    ; Divide by subtraction
  inc a        ; Bump place marker
  jr nc,-      ; No underflow

  add hl,bc    ; Restore value from underflowed subtraction
  ret
.ends

.slot 2
.section "Static dictionary" semisuperfree banks 3-31
.block "Words"
; Note that the number of words we add here has a complicated effect on the data size.
; Adding more words costs space here (in a paged bank), but saves space in bank 2.
; If our goal is to maximise script space then we should maximise the word count.
; The limit is 147 ($100 - WordListStart).
; If our goal is to minimise total space used across both the script and word list then the
; best number has to be found by brute force.
Words:
.include {"generated/words.{LANGUAGE}.asm"}
.endb
.ends

.slot 0
.section "Newline patch" free
; Originally tx1.asm
; Text window drawer multi-line handler

newline:
    ld b,NARRATIVE_WIDTH ; reset x counter
    inc hl   ; move pointer to next byte
    ld a,c   ; get line counter
    or a     ; test for c==0
    jr nz,_not_zero
    ; zero: draw on 2nd line
    ld de,NARRATIVE_SCROLL_VRAM + ONE_ROW ; VRAM address
_inc_and_finish:
    inc c
    jp InGameTextDecoder
_not_zero:
    dec a    ; test for c==1
    jr nz,+
    ; one: draw on 3rd
_draw_3rd_line:
    ld de,NARRATIVE_SCROLL_VRAM + ONE_ROW * 2 ; VRAM address
    jr _inc_and_finish
+:  dec a    ; test for c==2
    jr nz,+
    ; two: draw on 4th
_draw_4th_line:
    ld de,NARRATIVE_SCROLL_VRAM + ONE_ROW * 3
    jr _inc_and_finish
+:  ; three: scroll, draw on 4th line
    call $3546 ; _ScrollTextBoxUp2Lines (patch reduces it to one)
    dec c      ; cancel increment
    jr _draw_4th_line
.ends

  ROMPosition $3397
.section "Newline patch trampoline" overwrite
  jp newline
.ends

  ROMPosition $354c
.section "nop out 2nd line scroll" overwrite
.repeat 3
  nop
.endr
.ends

.slot 2

.section "Font lookup" align 256 semisuperfree banks 3-31 ; alignment simplifies code...
FontLookup:
; This is used to convert text from the game's encoding (indexing into this area) to name table entries. More space can be used but check SymbolStart which needs to be one past the end of this table. These must be in the order given in script.<language>.tbl.
.include {"generated/font-lookup.{LANGUAGE}.asm"}
.ends

; We locate the Huffman trees in a different slot to the script so we can access them at the same time
.slot 1
.section "Huffman trees" semisuperfree banks 3-31
.block "Huffman trees"
HuffmanTrees:
.include {"generated/tree.{LANGUAGE}.asm"}
.endb
.ends

; ...but the script still needs to go in slot 2.
.bank 2 slot 2
.section "Script" free
.block "Script"
.include {"generated/script.{LANGUAGE}.asm"}
.endb
.ends

.bank 0 slot 0
.section "Decoder init" free
DecoderInit:
; Semi-adaptive Huffman decoder
; - Init decoder
; This is called from various places where the game wants to draw text. We:
; - page some code into slot 1
; - init the Huffman decoding state
; - determine which place we were called from and implement the patched-over code,
;   plus some context-specific state.
; - call into the code following the patch point, which will call into other text-decoding functions
; - then restore slot 1

  push af     ; Save routine selection

    ld a,:AdditionalScriptingCodes
    ld (PAGING_SLOT_1),a

    ld a,SymbolEnd    ; Starting tree symbol
    ld (TREE),a

    ld a,1<<7    ; Initial tree barrel
    ld (BARREL),a

    ld (SCRIPT),hl    ; Beginning script offset

    xor a     ; A = $00
    ld (POST_LEN),a   ; No post hints
    ld (LINE_NUM),a   ; No lines drawn
    ld (FLAG),a       ; No wait flag
    ld (ARTICLE),a    ; No article usage
    ld (SUFFIX),a     ; No suffix flag
    ld (SKIP_BITMASK),a ; No (){}[] etc

  pop af

  ; Now we detect what we need to do to recover from the patch to get here...
  or a
  jr nz,+

CutsceneClear:
  ; a = 0: Cutscene handler
  ; Patched-over code
  ld de,$7c42   ; VRAM address - modified
  ld bc,$0000
  ; Context-specific state
  ld a,6        ; Line count
  ld (VLIMIT),a
  ; Call back to patch location
  xor a ; unnecessary?
  call CutsceneNarrativeInitOriginalCode
  jr ++

+:; a = 1: in-game dialog
  ; Context-specific state
  ld a,4        ; Line count
  ld (VLIMIT),a
  ; Patched-over code
  ld a,($c2d3)  ; Old code (checking if the text window is already open)
  or a          ; Done second as the flags from this test are what matters
  ; Call back to patch location
  call InGameNarrativeInitOriginalCode

++:
  ld a,1    ; Restore slot 1
  ld (PAGING_SLOT_1),a

  ret

.ends

.bank 0 slot 0
.section "SFG decoder" free
SFGDecoder:
; Originally t4a.asm
; Semi-adaptive Huffman decoder
; - Shining Force Gaiden: Final Conflict

; Start of decoder

; Note:
; The Z80 uses one set of registers for decoding the Huffman input data
; The other context is used to traverse the Huffman tree itself

; Encoded Huffman data is in slot 2
; Huffman tree data is in slot 1
; The symbols for the tree are stored in backwards linear order

  push hl
    ld a,:HuffmanTrees
    ld (PAGING_SLOT_1),a

    ld hl,(SCRIPT)    ; Set Huffman data location
    ld a,(BARREL)   ; Load Huffman barrel

    ex af,af'   ; Context switch to tree mode
    exx
      ld a',(TREE)   ; Load in tree / last symbol

      push af'
        ld bc',HuffmanTrees    ; Set physical address of tree data
        ld h',0      ; 8 -> 16
        ld l',a'
        add hl',hl'   ; 2-byte indices
        add hl',bc'   ; add offset

        ld a',(hl')   ; grab final offset
        inc hl'
        ld h',(hl')
        ld l',a'
      pop af'

      ld a',$80    ; Initialise the tree barrel data
      ld d',h'      ; Point to symbol data
      ld e',l'
      dec de'      ; Symbol data starts one behind the tree

      jr _Tree_Shift1    ; Grab first bit

_Tree_Mode1:
    ex af,af'   ; Context switch to tree mode
    exx

_Tree_Shift1:
      add a',a'     ; Shift out next tree bit to carry flag
      jr nz,+     ; Check for empty tree barrel

      ld a',(hl')   ; Shift out next tree bit to carry flag
      inc hl'      ; Bump tree pointer

      adc a',a'     ; Note: We actually shift in a '1' by doing this! Clever trick to use all 8 bits for tree codes

+:    jr c,_Decode_Done ; 0 -> tree node = continue looking
                        ; 1 -> root node = symbol found

    ex af,af'   ; Switch to Huffman data processing = full context switch
    exx

    add a,a     ; Read in Huffman bit
    jr nz,_Check_Huffman1  ; Check Huffman barrel status

    ld a,(hl)   ; Reload 8-bit Huffman barrel
    inc hl      ; Bump Huffman data pointer
    adc a,a     ; Re-grab bit

_Check_Huffman1:
    jr nc,_Tree_Mode1  ; 0 -> travel left, 1 -> travel right

    ex af,af'   ; Switch back to tree mode
    exx

      ld c',1    ; Start counting how many symbols to skip in the linear list since we are traversing the right sub-tree

_Tree_Shift2:
      add a',a'     ; Check if tree data needs refreshing
      jr nz,_Check_Tree2

      ld a',(hl')   ; Refresh tree barrel again
      inc hl'      ; Bump tree pointer
      adc a',a'     ; Grab new tree bit

_Check_Tree2:
      jr c,_Bump_Symbol  ; 0 -> tree, 1 -> symbol

      inc c'     ; Need to bypass one more node
      jr _Tree_Shift2    ; Keep bypassing symbols

_Bump_Symbol:
      dec de'      ; Bump pointer in symbol list backwards
      dec c'     ; One less node/symbol to skip

      jr nz,_Tree_Shift2 ; Check for full exhaustion of left subtree nodes

      jr _Tree_Shift1    ; Need status of termination

_Decode_Done:
      ld a',(de')   ; Find symbol
      ld (TREE),a'   ; Save decoded byte

    ex af,af'   ; Go to Huffman mode
    exx
    ld (SCRIPT),hl    ; Save script pointer
    ld (BARREL),a   ; Save Huffman barrel
    ld a,:AdditionalScriptingCodes ; restore paging
    ld (PAGING_SLOT_1),a
    ex af,af'   ; Go to Tree mode
    ; no need to exx again

  pop hl      ; Restore stack and exit
  ret
.ends

.include {"generated/script-patches.{LANGUAGE}.asm"}


