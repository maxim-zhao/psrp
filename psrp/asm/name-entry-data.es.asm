_NameEntryItems:
.db 12
  NameEntryText  6,  1,    "Introduzca su nombre"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "áéíóúñ 0123456789  .,-!?‘’"
  NameEntryText  3, 17, "Atrás"
  NameEntryText 20, 17,                  "Siguiente"
  NameEntryText  3, 19, "Espacio"
  NameEntryText 22, 19,                    "Guardar"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"

_NameEntryLookup:
.db 4
  NameEntryMask  3, 17, 5, "B" ; X, Y, length, type (Back)
  NameEntryMask 20, 17, 9, "N" ; Next
  NameEntryMask  3, 19, 7, "S" ; Space
  NameEntryMask 22, 19, 7, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 19
