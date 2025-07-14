_NameEntryItems:
;
;       Nōmen tuum inscrībe:
;
;  ╭────────────────────────────╮
;  │                            │
;  │                            │
;  │     _                      │
;  │                            │
;  │                            │
;  │                            │
;  │                            │
;  │  ABCDEFGHIKLMNOPQRSTUVXYZ  │
;  │                            │
;  │  abcdefghiklmnopqrstuvxyz  │
;  │                            │
;  │  āēīōū 0123456789.,:-!?‘’  │
;  │                            │
;  │  Retrō  Proximō   Spatium  │
;  │                            │
;  │                   Servāre  │
;  │                            │
;  │                            │
;  │                            │
;  ╰────────────────────────────╯
.db 10
  NameEntryText  6,  1, "Nōmen tuum inscrībe:"
  NameEntryText  4, 11, "ABCDEFGHIKLMNOPQRSTUVXYZ"
  NameEntryText  4, 13, "abcdefghiklmnopqrstuvxyz"
  NameEntryText  4, 15, "āēīōū 0123456789.,:-!?‘’"
  NameEntryText  4, 17, "Retrō  Proximō   Spatium"
  NameEntryText 21, 19,                  "Servāre"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"

_NameEntryLookup:
.db 4
  NameEntryMask  4, 17, 5, "B" ; X, Y, length, type (Back)
  NameEntryMask 11, 17, 7, "N" ; Next
  NameEntryMask 21, 17, 7, "S" ; Space
  NameEntryMask 21, 19, 7, "V" ; saVe

.define NameEntryMinX 4
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 19