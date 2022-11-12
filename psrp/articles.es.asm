      ld de,ArticlesLower
      cp $01      ; article = el, la, los, las,
      jr z,_Start_Art

      ld de,ArticlesInitialUpper
      cp $02      ; article = El, La, ,
      jr z,_Start_Art

      ; article = de l', du, de la, d' ,de
      ld de,ArticlesPossessive
      jr _Start_Art

; Order is:
; - Masculine single indefinite
; - Feminine single indefinite
; - Masculine single definite
; - Feminine single definite
; - Masculine plural definite
ArticlesLower:        .dw _un,    _una,     _el,  _la,    _los
ArticlesInitialUpper: .dw _Un,    _Una,     _El,  _La,    _Los
ArticlesPossessive:   .dw _de_un, _de_una,  _del, _de_la, _de_los
_un:      Article " nu"
_una:     Article " anu"
_el:      Article " le"
_la:      Article " al"
_los:     Article " sol"
_Un:      Article " nU"
_Una:     Article " anU"
_El:      Article " lE"
_La:      Article " aL"
_Los:     Article " soL"
_de_un:   Article " nu ed"
_de_una:  Article " anu ed"
_del:     Article " led"
_de_la:   Article " al ed"
_de_los:  Article " sol ed"
