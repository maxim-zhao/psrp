_NameEntryItems:
.db 14
  NameEntryText  8,  1,      "Digite seu nome"
  NameEntryText  3, 11, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  NameEntryText  3, 13, "abcdefghijklmnopqrstuvwxyz"
  NameEntryText  3, 15, "áâãçéêíóôõú"
  NameEntryText  3, 17, "0123456789"
  NameEntryText 22, 17,                   ".,-!?‘’"
  NameEntryText  3, 19, "Voltar"
  NameEntryText 22, 19,                    "Próximo"
  NameEntryText  3, 21, "Espaço"
  NameEntryText 23, 21,                     "Salvar"
  NameEntryText  1,  3, "┌─" ; Leave these ones alone...
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"
_NameEntryLookup:
.db 4
  NameEntryMask  3, 19, 6, "B" ; X, Y, length, type (Back)
  NameEntryMask 22, 19, 7, "N" ; Next
  NameEntryMask  3, 21, 6, "S" ; Space
  NameEntryMask 23, 21, 6, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 21
