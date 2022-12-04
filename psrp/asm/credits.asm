; Changed credits -------------------------
; Point to maybe relocated data
  PatchB $70b4 :CreditsData
  PatchW $70ba CreditsData-4
; Code treats values >64 as
.slot 2
.section "Credits" superfree
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
.section "Credits font" superfree
CreditsFont:
.incbin "generated/font-credits.psgcompr"
.ends

; We hack the credits dungeon data to add more credits at the end...
  ROMPosition $3df6e + $3c * 128 ; Dungeon level $3d
.stringmaptable dungeons "asm/Dungeons.tbl"
.section "Add credits wall text" overwrite
Dungeon3d:
.stringmap dungeons "🧱🧱🧱🧱🧱🌫📄🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱📄🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🔽🌫🌫🌫📄🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🌫🌫🌫🌫🌫🔽🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱📄🌫🧱🧱📄🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱🌫🧱📄🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱📦🧱🧱🌫🌫🌫🌫🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🧱📦🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱🧱🌫🧱🌫🌫📄🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🧱🧱📄🧱🧱🌫🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱📄🌫🌫🌫🌫🌫🌫🌫📄🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱🧱🌫📄🌫🧱🧱🧱🧱🧱🧱🧱🧱"
.stringmap dungeons "🧱🧱🧱🧱📄🌫🧱🌫🧱🧱🧱🧱🧱🧱🧱🧱"
; We have extended the last bit (at the top) to have a new path and 5 new text places
.ends

; Next we need to replace the ending walk data...
.section "Credits movement data" superfree
.define _F %0001
.define _B %0010
.define _L %0100
.define _R %1000
.define _Pause $f
.define _End $ff

CreditsMovementData:
.db _F _F _F _Pause
.db _R _F _F _F _Pause
.db _L _F _F _R _F _Pause
.db _L _L _F _R _F _F _Pause
.db _L _F _F _R _F _Pause
.db _B _B $00 _R _F _F _Pause
.db _L _F _F _F _F _B _L _Pause
.db _B _B _B _R _F _F _F _F _L _Pause
.db _R _R _Pause
.db _R _F _F _R _F _F _F _F _F _F _F _R _B _B _L _Pause
.db _L _F _F $00 _Pause
.db _L _L _F _F _R _F _Pause
.db _B _B _B _B _R _Pause
.db _B _L _L _F _F _F _R _F _F _F _F _Pause
; New stuff added here. We visit the 📄 we added.
.db _Pause _Pause _Pause
.db _L _L _F _F _R _F _L _Pause
.db _R _F _R _Pause
.db _L _F _L _Pause
.db _R _F _R _Pause
.db _L _F _F _L _F _Pause
.db _End
.ends
  PatchB $48a3 :CreditsMovementData
  PatchW $48a0 CreditsMovementData
