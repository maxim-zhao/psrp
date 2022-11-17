      ld de,ArticlesLower
      cp $01      ; article = l', le, la, les,
      jr z,_Start_Art

      ld de,ArticlesInitialUpper
      cp $02      ; article = L', Le, La, ,
      jr z,_Start_Art

      ld de,ArticlesPossessive
      jr _Start_Art

; Order is:
; - Masculine single indefinite
; - Feminine single indefinite
; - Masculine single definite
; - Masculine plural definite
; - Feminine plural definite
; - Name without article (use de for possessive)
; Other combinations are not used in the script so we omit them here.
ArticlesLower:       .dw _um, _uma, _o,  _a,   _as,  _blank
ArticlesInitialUpper:.dw _Um, _Uma, _O,  _A,   _As,  _blank
ArticlesPossessive:  .dw _do, _dos, _do, _da,  _das, _de
_um:    Article " mu"
_uma:   Article " amu"
_o:     Article " o"
_a:     Article " a"
_as:    Article " sa"
_blank: Article ""
_Um:    Article " mU"
_Uma:   Article " amU"
_O:     Article " O"
_A:     Article " A"
_As:    Article " sA"
_do:    Article " od"
_dos:   Article " sod"
_da:    Article " ad"
_das:   Article " sad"
_de:    Article " ed"