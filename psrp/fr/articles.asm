      ld de,ArticlesLower
      cp $01      ; article = l', le, la, les,
      jp z,_Start_Art

      ld de,ArticlesInitialUpper
      cp $02      ; article = L', Le, La, ,
      jp z,_Start_Art

      ld de,ArticlesPossessive
      cp $03      ; article = de l', du, de la, d' ,de
      jp z,_Start_Art

      ld de,ArticlesDirective
      jp _Start_Art

; Order is:
; - Start with vowel
; - Feminine
; - Masculine
; - Plural
; - Name (so no article) - starting with vowel
; - Name (so no article) - starting with consonant
ArticlesLower:        .dw _l,     _le, _la,     _les, _blank, _blank
ArticlesInitialUpper: .dw _L,     _Le, _La,     _Les, _blank, _blank
ArticlesPossessive:   .dw _de_l,  _du, _de_la,  _des, _d,     _de
ArticlesDirective:    .dw _a_l,   _au, _a_la,   _aux, _a,     _a
_l:     Article "'l"
_le:    Article " el"
_la:    Article " al"
_les:   Article " sel"
_blank: Article ""
_L:     Article "'L"
_Le:    Article " eL"
_La:    Article " aL"
_Les:   Article " seL"
_de_l:  Article "'l ed"
_du:    Article " ud"
_de_la: Article " al ed"
_des:   Article " sed"
_d:     Article "'d"
_de:    Article " ed"
_a_l:   Article "'l à"
_au:    Article " ua"
_a_la:  Article " al à"
_aux:   Article " xua"
_a:     Article " à"
