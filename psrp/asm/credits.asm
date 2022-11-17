; Changed credits -------------------------
; Point to maybe relocated data
  PatchB $70b4 :CreditsData
  PatchW $70ba CreditsData-4
; Code treats values >64 as
.slot 2
.section "Credits" superfree
CreditsData:
.dw CreditsScreen1, CreditsScreen2, CreditsScreen3, CreditsScreen4, CreditsScreen5, CreditsScreen6, CreditsScreen7, CreditsScreen8, CreditsScreen9, CreditsScreen10, CreditsScreen11, CreditsScreen12, CreditsScreen13, CreditsScreen14

.stringmaptable credits "credits.tbl"

.macro CreditsEntry args x, y, text
.dw TileMapCacheAddress(x, y)
.db _credits_\@_end - _credits_\@
_credits_\@:
.stringmap credits text
_credits_\@_end:
.endm

.include {"credits.{LANGUAGE}.asm"}
.ends

  ROMPosition $488a
.section "Credits hack" overwrite ; not movable
  ld (hl),:CreditsFont
  ld hl,TileWriteAddress($c1) ; VRAM address
  ld de,CreditsFont
  call LoadTiles
.ends

.slot 2
.section "Credits font" superfree
CreditsFont:
.incbin "generated/font-credits.psgcompr"
.ends
