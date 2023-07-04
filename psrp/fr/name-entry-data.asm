_NameEntryItems:
.db 14 ; count of following lines
  NameEntryText  8,  1,      "Entrez votre nom"
  NameEntryText  3, 11, "ABCDEFGHIJ LMNOPQRSTUVW Y"
  NameEntryText  7, 13,     "aàâbcçdeéèêfghiîjk"
  NameEntryText  7, 15,     "lmnoôpqrstuùûv xyz"
  NameEntryText  3, 17, "0123456789"
  NameEntryText 22, 17,                    ".,-!?‘’"
  NameEntryText  3, 19, "Précédent"
  NameEntryText 22, 19,                    "Suivant"
  NameEntryText  3, 21, "Espace"
  NameEntryText 23, 21,                     "Sauver"
  NameEntryText  1,  3, "┌─"
  NameEntryText  1, 23, "╘═"
  NameEntryText 30,  3, "╖"
  NameEntryText 30, 23, "╝"

_NameEntryLookup:
.db 4
  NameEntryMask  3, 19, 9, "B" ; X, Y, length, type (Back)
  NameEntryMask 22, 19, 7, "N" ; Next
  NameEntryMask  3, 21, 6, "S" ; Space
  NameEntryMask 23, 21, 6, "V" ; saVe
.define NameEntryMinX 3
.define NameEntryMaxX 28
.define NameEntryMinY 11
.define NameEntryMaxY 21
