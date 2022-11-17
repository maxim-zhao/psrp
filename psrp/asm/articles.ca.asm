      ld de,ArticlesLower
      cp $01      ; article = l', el, la, els, les,
      jp z,_Start_Art

      ld de,ArticlesInitialUpper
      cp $02      ; article = L', El, La, ,
      jp z,_Start_Art

      ; article = de l', du, de la, d' ,de
      ld de,ArticlesPossessive
      jp _Start_Art

; Order is:
; - Masculine single indefinite
; - Feminine single indefinite
; - Start with vowel
; - Masculine single definite
; - Feminine single definite
; - Masculine plural definite
; - Masculine name
; - Feminine name
ArticlesLower:        .dw _un,    _una,     _l,     _el,  _la,    _els,   _en,    _na
ArticlesInitialUpper: .dw _Un,    _Una,     _L,     _El,  _La,    _Els,   _En,    _Na
ArticlesPossessive:   .dw _de_un, _de_una,  _de_l,  _del, _de_la, _dels,  _d_en,  _de_na
_un:      Article " nu"
_una:     Article " anu"
_l:       Article "’l"
_el:      Article " le"
_la:      Article " al"
_els:     Article " sle"
_en:      Article " ne"
_na:      Article " an"
_Un:      Article " nU"
_Una:     Article " anU"
_L:       Article "’L"
_El:      Article " lE"
_La:      Article " aL"
_Els:     Article " slE"
_En:      Article " nE"
_Na:      Article " aN"
_de_un:   Article " nu ed"
_de_una:  Article " anu ed"
_de_l:    Article "’l ed"
_del:     Article " led"
_de_la:   Article " al ed"
_dels:    Article " sled"
_d_en:    Article " ne'd"
_de_na:   Article " an ed"
