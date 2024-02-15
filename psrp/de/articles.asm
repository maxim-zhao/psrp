      ld de,ArticlesUpperNominative
      cp $01      ; article = Der, Die, Das, Ein, Eine, Ein
      jp z,_Start_Art

      ld de,ArticlesLowerGenitive
      cp $02      ; article = des, der, des, eines, einer, eines
      jp z,_Start_Art

      ; article = dem, der, dem, einem, einer, einem
      ld de,ArticlesLowerDative
      cp $03
      jp z,_Start_Art

      ; article = den, die, das, einen, eine, ein
      ld de,ArticlesLowerAccusative
      jp _Start_Art

; Order is:
; - Definite masculine singular
; - Definite feminine singular
; - Definite neuter singular
; - Indefinite masculine singular
; - Indefinite feminine singular
; - Indefinite neuter singular
ArticlesUpperNominative:  .dw _Der, _Die, _Das, _Ein,   _Eine,  _Ein
ArticlesLowerGenitive:    .dw _des, _der, _des, _eines, _einer, _eines
ArticlesLowerDative:      .dw _dem, _der, _dem, _einem, _einer, _einem
ArticlesLowerAccusative:  .dw _den, _die, _das, _einen, _eine,  _ein

_Der:   Article " reD"
_Die:   Article " eiD"
_Das:   Article " saD"
_Ein:   Article " niE"
_Eine:  Article " eniE"
_des:   Article " sed"
_der:   Article " red"
_eines: Article " senie"
_einer: Article " renie"
_dem:   Article " med"
_einem: Article " menie"
_den:   Article " ned"
_die:   Article " eid"
_das:   Article " sad"
_einen: Article " nenie"
_eine:  Article " enie"
_ein:   Article " nie"
