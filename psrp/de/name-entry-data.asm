_NameEntryItems:
.db 10
  NameEntryText  6,  1,    "Gib einen Namen ein"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "äöüß  0123456789  .,-!?’„“"
  NameEntryText  3, 17, "Links  Rechts  Leerzeichen"
  NameEntryText 23, 19,                     "Fertig"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"

_NameEntryLookup:
.db 4
  NameEntryMask  3, 17,  5, "B" ; X, Y, length, type (Back)
  NameEntryMask 10, 17,  6, "N" ; Next
  NameEntryMask 18, 17, 11, "S" ; Space
  NameEntryMask 23, 19,  6, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 19
