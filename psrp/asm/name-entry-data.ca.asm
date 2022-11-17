_NameEntryItems:
.db 14
  NameEntryText  4,  1,  "Introdueixi el seu nom"
  NameEntryText  3, 11, "ABCDEFGHIJ LMNOPQRSTUV"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuv xyz"
  NameEntryText  3, 15, "àçéèíóòú"
  NameEntryText  3, 17, "0123456789"
  NameEntryText 22, 17,                   ".,-!?‘’"
  NameEntryText  3, 19, "Enrera"
  NameEntryText 22, 19,                    "Següent"
  NameEntryText  3, 21, "Espai"
  NameEntryText 22, 21,                    "Guardar"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"

_NameEntryLookup:
.db 4
  NameEntryMask  3, 19, 6, "B" ; X, Y, length, type (Back)
  NameEntryMask 22, 19, 7, "N" ; Next
  NameEntryMask  3, 21, 5, "S" ; Space
  NameEntryMask 22, 21, 6, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 21
