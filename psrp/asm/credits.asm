; Changed credits -------------------------
; Point to maybe relocated data
  PatchB $70b4 :CreditsData
  PatchW $70ba CreditsData-4
; Code treats values >64 as
.slot 2
.section "Credits" semisuperfree banks 3-31
CreditsData:
.dw CreditsScreen1, CreditsScreen2, CreditsScreen3, CreditsScreen4, CreditsScreen5, CreditsScreen6, CreditsScreen7, CreditsScreen8, CreditsScreen9, CreditsScreen10, CreditsScreen11, CreditsScreen12, CreditsScreen13, CreditsScreen14, CreditsScreen15, CreditsScreen16, CreditsScreen17, CreditsScreen18, CreditsScreen19
; Note that the original only goes up to 14. 15-19 are the retranslation credits.
.stringmaptable credits "asm/credits.tbl"

.macro CreditsEntry args x, y, text
.dw TileMapCacheAddress(x, y)
.db _credits_\@_end - _credits_\@
_credits_\@:
.stringmap credits text
_credits_\@_end:
.endm

.include {"{LANGUAGE}/credits.asm"}
.ends

  ROMPosition $488a
.section "Credits hack" overwrite ; not movable
  ld (hl),:CreditsFont
  ld hl,CreditsFont
  ld de,TileWriteAddress($c1) ; VRAM address
  call LoadTiles
.ends

.slot 2
.section "Credits font" semisuperfree banks 3-31
CreditsFont:
.incbin "generated/font-credits.psgcompr"
.ends

; We hack the credits dungeon data to add more credits at the end...
  ROMPosition $3df6e + $3b * 128 ; Dungeon level $3c
.stringmaptable dungeons "asm/Dungeons.tbl"
.section "Add credits wall text" overwrite
Dungeon3c:
.stringmap dungeons "🧱🧱🧱🧱🌫📄🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱" ; 15 RETRANSLATION
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫📄🧱🧱🧱🧱" ; 16 TRANSLATION
.stringmap dungeons "🧱🌫🌫🌫🔼🧱🧱🧱🧱🧱🧱🧱📄🌫📄🧱" ; 8, 9
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🧱🧱🧱🔼🌫🌫🌫🌫🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱"
.stringmap dungeons "🧱🧱🌫🌫🌫🌫🌫📄🧱📄🌫🌫🌫🌫🧱🧱" ; 11, 7
.stringmap dungeons "🧱🧱📄🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱" ; 13
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫📄🧱🧱🌫🌫🌫📄🧱🧱🧱🧱" ; 12, 6
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🌫📄🧱🌫🧱🧱🧱🧱🧱" ; 17 LOCALIZATION
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱📄🌫🌫🌫🌫🌫🌫🧱🧱🧱🧱🧱🧱🧱🧱" ; 18 CODE
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🌫🌫🌫🔼🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🌫🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
Dungeon3d:
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱📦🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🔽🌫🌫🌫📄🧱🧱🧱🧱🧱🧱🧱" ; 14 PRESENTED BY SEGA
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🔽🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱📄🌫🧱🧱📄🧱🧱🧱🧱🧱🧱🧱" ; 10, 5
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱📄🧱🧱🧱🧱🧱" ; 4
.stringmap dungeons "🧱🧱🧱🧱🧱📦🧱🧱🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱📦🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🌫📄🧱🧱🧱" ; 3
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱📄🧱🧱🌫🧱🧱🧱🧱🧱" ; 1 STAFF
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🌫🌫🌫🌫🌫📄🧱🧱🧱🧱" ; 2 
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🔽🌫🌫🌫📄🧱" ; PRESENTED BY SMS POWER!
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
; We have extended the last bit (at the top) to add the new pitfall
.ends

; Next we need to replace the ending walk data...
.section "Credits movement data" semisuperfree banks 3-31
.define ⬆️ %0001
.define ⬇️ %0010
.define ⬅️ %0100
.define ➡️ %1000
.define ⏸️ $f
.define _End $ff
.define _Pitfall $00

CreditsMovementData:
.db ⬆️ ⬆️ ⬆️ ⏸️
.db ➡️ ⬆️ ⬆️ ⬆️ ⏸️
.db ⬅️ ⬆️ ⬆️ ➡️ ⬆️ ⏸️
.db ⬅️ ⬅️ ⬆️ ➡️ ⬆️ ⬆️ ⏸️
.db ⬅️ ⬆️ ⬆️ ➡️ ⬆️ ⏸️
.db ⬇️ ⬇️ _Pitfall ➡️ ⬆️ ⬆️ ⏸️
.db ⬅️ ⬆️ ⬆️ ⬆️ ⬆️ ⬇️ ⬅️ ⏸️
.db ⬇️ ⬇️ ⬇️ ➡️ ⬆️ ⬆️ ⬆️ ⬆️ ⬅️ ⏸️
.db ➡️ ➡️ ⏸️
.db ➡️ ⬆️ ⬆️ ➡️ ⬆️ ⬆️ ⬆️ ⬆️ ⬆️ ⬆️ ⬆️ ➡️ ⬇️ ⬇️ ⬅️ ⏸️
.db ⬅️ ⬆️ ⬆️ _Pitfall ⏸️
.db ⬅️ ⬅️ ⬆️ ⬆️ ➡️ ⬆️ ⏸️
.db ⬇️ ⬇️ ⬇️ ⬇️ ➡️ ⏸️
.db ⬇️ ⬅️ ⬅️ ⬆️ ⬆️ ⬆️ ➡️ ⬆️ ⬆️ ⬆️ ⬆️ ⏸️
; New stuff added here. We visit the 📄 we added.
.db ⏸️ ; for music timing
.db ⬅️ ⬅️ ⬆️ ⬆️ ➡️ ⬆️ _Pitfall ⏸️ ; RETRANSLATION
.db ⬅️ ⬅️ ⬅️ ⬆️ ⬆️ ⬆️ ⬆️ ⬆️ ⏸️ ; TRANSLATION
.db ⬇️ ⬇️ ⬇️ ⬅️ ⬆️ ⬆️ ⬆️ ⬆️ ⬆️ ⬆️ ➡️ ⏸️ ; LOCALIZATION
.db ⬅️ ⬇️ ⬇️ ⬅️ ⬆️ ⬆️ ⬆️ ⬆️ ⬆️ ⏸️ ; CODE
.db ➡️ ➡️ ⬆️ ⬆️ ⬆️ ⬆️ ⬆️ ➡️ ⬆️ ⬅️ ⬆️ ⬆️ ⬆️ ⬆️ ⬆️ ⏸️ ⏸️ ; PRESENTED BY SMS POWER!
.db _End

.undefine ⬆️
.undefine ⬇️
.undefine ⬅️
.undefine ➡️
.undefine ⏸️
.undefine _End
.undefine _Pitfall
.ends
  PatchB $48a3 :CreditsMovementData
  PatchW $48a0 CreditsMovementData
