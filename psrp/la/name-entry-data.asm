_NameEntryItems:
.db 11
  NameEntryText  6,  1, "Nomen tuum inscribe:"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "0123456789"
  NameEntryText 21, 15,                   ".,:-!?‘’"
  NameEntryText  3, 17, "Retro  Proximo  Spatium"
  NameEntryText 22, 19,                    "Servare"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"

_NameEntryLookup:
.db 4
  NameEntryMask  3, 17, 5, "B" ; X, Y, length, type (Back)
  NameEntryMask 10, 17, 7, "N" ; Next
  NameEntryMask 19, 17, 7, "S" ; Space
  NameEntryMask 22, 19, 7, "V" ; saVe

.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 19