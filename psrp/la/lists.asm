.slot 2
.section "Enemy, name, item lists" superfree
Lists:

; Order is important!
Items:
  ; Max width 21. Names can contain text for different cases as so:
  ; [nom]{gen}(dat)«acc»‹abl›
  ; If no corresponding <nom> etc tag is prefixed in the script then none are used.
  String " " ; empty item (blank). Must be at least one space.
  ;        Retranslation name                                               Sega translation              Romaji              Japanese
; weapons: 01-0f
  String "Bacul[um]{ī}(ō)«um»‹ō› Ligne[um]{ī}(ō)«um»‹ō›"                  ; WOODCANE  Wood Cane           uddokein            ウッドケイン
  String "Glad[ius]{iī}(iō)«ium»‹iō› Brev[is]{is}(ī)«em»‹ī›"              ; SHT. SWD  Short Sword         shōtosōdo           ショートソード
  String "Glad[ius]{iī}(iō)«ium»‹iō› Ferre[us]{ī}(ō)«um»‹ō›"              ; IRN. SWD  Iron Sword          aiansōdo            アイアンソード
  String "Bacul[um]{ī}(ō)«um»‹ō› Psychic[um]{ī}(ō)«um»‹ō›"                ; WAND      Wand                saikowondo          サイコウォンド
  String "Den[s]{tis}(tī)«tem»‹te› Argente[us]{ī}(ō)«um»‹ō›"              ; IRN.FANG  Iron Fang           shirubātasuku       シルバータスク   <-- Note, Silver fang/tusk reversed in Sega translation
  String "Secur[is]{is}(ī)«em»‹ī› Ferre[a]{ae}(ae)«am»‹ā›"                ; IRN. AXE  Iron Axe            aianakusu           アイアンアクス
  String "Glad[ius]{iī}(iō)«ium»‹iō› Titanic[us]{ī}(ō)«um»‹ō›"            ; TIT. SWD  Titanium Sword      chitaniumusōdo      チタニウムソード
  String "Glad[ius]{iī}(iō)«ium»‹iō› Ceramic[us]{ī}(ō)«um»‹ō›"            ; CRC. SWD  Ceramic Sword       seramikkusōdo       セラミックソード
  String "Sclopet[um]{ī}(ō)«um»‹ō› Acule[um]{ī}(ō)«um»‹ō›"                ; NEEDLGUN  Needle Gun          nīdorugan           ニードルガン
  String "Ungu[is]{is}(ī)«em»‹ī› Sabul[um]{ī}(ō)«um»‹ō›"                  ; SIL.FANG  Silver Fang         sāberukurō          サーベルクロー   <--
  String "Sclopet[um]{ī}(ō)«um»‹ō› Calōr[is]{is}(ī)«em»‹ī›"               ; HEAT.GUN  Heat Gun            ītogan              ヒートガン
  String "Glad[ius]{iī}(iō)«ium»‹iō› Lūmin[is]{is}(ī)«em»‹ī›"             ; LGT.SABR  Light Saber         raitoseibā          ライトセイバー
  String "Sclopet[um]{ī}(ō)«um»‹ō› Las[er]{eris}(erī)«er»‹ere›"           ; LASR.GUN  Laser Gun           rēzāgan             レーザーガン
  String "Glad[ius]{iī}(iō)«ium»‹iō› Laconic[us]{ī}(ō)«um»‹ō›"            ; LAC. SWD  Laconian Sword      rakoniansōdo        ラコニアンソード
  String "Secur[is]{is}(ī)«em»‹ī› Laconic[a]{ae}(ae)«am»‹ā›"              ; LAC. AXE  Laconian Axe        rakonianakusu       ラコニアンアクス
; armour: 10-18
  String "Vest[is]{is}(ī)«em»‹ī› Coriace[a]{ae}(ae)«am»‹ā›"               ; LTH.ARMR  Leather Armor       rezākurosu          レザークロス
  String "Mantell[um]{ī}(ō)«um»‹ō› Alb[um]{ī}(ō)«um»‹ō›"                  ; WHT.MANT  White Mantle        howaitomanto        ホワイトマント
  String "Lōric[a]{ae}(ae)«am»‹ā› Lev[is]{is}(ī)«em»‹ī›"                  ; LGT.SUIT  Light Suit          raitosūtsu          ライトスーツ
  String "Armātūr[a]{ae}(ae)«am»‹ā› Ferre[a]{ae}(ae)«am»‹ā›"              ; IRN.ARMR  Iron Armor          aianāma             アイアンアーマ
  String "Pelli[um]{ī}(ō)«um»‹ō› Spiculōs[um]{ī}(ō)«um»‹ō›"               ; THCK.FUR  Thick Fur           togerisunokegawa    トゲリスノケガワ       棘栗鼠の毛皮
  String "Armātūr[a]{ae}(ae)«am»‹ā› Zirconic[a]{ae}(ae)«am»‹ā›"           ; ZIR.ARMR  Zirconian Armour    jirukoniameiru      ジルコニアメイル
  String "Armātūr[a]{ae}(ae)«am»‹ā› Diamantīn[a]{ae}(ae)«am»‹ā›"          ; DMD.ARMR  Diamond Armor       daiyanoyoroi        ダイヤノヨロイ        ダイヤの鎧
  String "Armātūr[a]{ae}(ae)«am»‹ā› Laconic[a]{ae}(ae)«am»‹ā›"            ; LAC.ARMR  Laconian Armor      rakoniāama          ラコニアアーマ
  String "Mantell[um]{ī}(ō)«um»‹ō› Frad[ī]{ī}(ō)«um»‹ō›"                  ; FRD.MANT  Frad Mantle         furādomanto         フラードマント
; shields: 19-20
  String "Scūt[um]{ī}(ō)«um»‹ō› Coriace[um]{ī}(ō)«um»‹ō›"                 ; LTH. SLD  Leather Shield      rezāshīrudo         レザーシールド
  String "Scūt[um]{ī}(ō)«um»‹ō› Ferre[um]{ī}(ō)«um»‹ō›"                   ; BRNZ.SLD  Bronze Shield       aianshīrudo         アイアンシールド  <-- Note, order reversed in Sega translation
  String "Scūt[um]{ī}(ō)«um»‹ō› Aene[um]{ī}(ō)«um»‹ō›"                    ; IRN. SLD  Iron Shield         boronshīrudo        ボロンシールド   <--
  String "Scūt[um]{ī}(ō)«um»‹ō› Ceramic[um]{ī}(ō)«um»‹ō›"                 ; CRC. SLD  Ceramic Shield      seramikkunotate     セラミックノタテ       セラミックの盾
  String "Chīrothēc[a]{ae}(ae)«am»‹ā› Animāl[is]{is}(ī)«em»‹ī›"           ; GLOVE     Glove               animarugurabu       アニマルグラブ
  String "Scūt[um]{ī}(ō)«um»‹ō› Las[er]{eris}(erī)«er»‹ere›"              ; LASR.SLD  Laser Shield        rēzābaria           レーザーバリア
  String "Scūt[um]{ī}(ō)«um»‹ō› Perse[ī]{ī}(ō)«um»‹ō›"                    ; MIRR.SLD  Mirror Shield       peruseusunotate     ペルセウスノタテ      ペルセウスの盾
  String "Scūt[um]{ī}(ō)«um»‹ō› Laconic[um]{ī}(ō)«um»‹ō›"                 ; LAC. SLD  Laconian Shield     rakoniashīrudo      ラコニアシールド
; vehicles: 21-23
  String "Terradomināt[or]{ōris}(ōrī)«ōrem»‹ōre›"                         ; LANDROVR  Land Rover          randomasutā         ランドマスター
  String "Fluxumōt[or]{ōris}(ōrī)«ōrem»‹ōre›"                             ; HOVRCRFT  Hovercraft          furōmūbā            フロームーバー
  String "Glaciēsfoss[or]{ōris}(ōrī)«ōrem»‹ōre›"                          ; ICE DIGR  Ice Digger          aisudekkā           アイスデッカー
; items: 24+
  String "Enerpastill[um]{ī}(ō)«um»‹ō›"                                   ; COLA      Cola                perorīmeito         ペロリーメイト
  String "Argipoti[ō]{ōnis}(ōnī)«ōnem»‹ōne›"                              ; BURGER    Burger              ruoginin            ルオギニン
  String "Tībi[a]{ae}(ae)«am»‹ā› Sooth[is]{is}(ī)«em»‹ī›"                 ; FLUTE     Flute               sūzufurūto          スーズフルート
  String "Lūcern[a]{ae}(ae)«am»‹ā›"                                       ; FLASH     Flash               sāchiraito          サーチライト
  String "Fugapann[us]{ī}(ō)«um»‹ō›"                                      ; ESCAPER   Escaper             esukēpukurosu       エスケープクロス
  String "Tapētrānsitōr[ium]{iī}(iō)«ium»‹iō›"                            ; TRANSER   Transer             torankāpetto        トランカーペット
  String "Pil[eum]{eī}(eō)«eum»‹eō› Magic[um]{ī}(ō)«um»‹ō›"               ; MAGC HAT  Magic Hat           majikkuhatto        マジックハット
  String "Alsulīn[um]{ī}(ō)«um»‹ō›"                                       ; ALSULIN   Alsulin             arushurin           アルシュリン
  String "Polymēter[um]{ī}(ō)«um»‹ō›"                                     ; POLYMTRL  Polymeteral         porimeterāru        ポリメテラール
  String "Clāv[is]{is}(ī)«em»‹ī› Spec[us]{ūs}(ui)«um»‹u›"                 ; DUGN KEY  Dungeon Key         danjonkī            ダンジョンキー
  String "Psychoglob[us]{ī}(ō)«um»‹ō›"                                    ; SPHERE    Sphere              terepashībōru       テレパシーボール
  String "Fax Eclīps[is]{is}(ī)«em»‹ī›"                                   ; TORCH     Torch               ikuripusutōchi      イクリプストーチ
  String "Aeroprism[a]{atis}(atī)«a»‹ate›"                                ; PRISM     Prism               earopurizumu        エアロプリズム
  String "Bacc[ae]{ārum}(īs)«ās»‹īs› Laerm[a]{ae}(ae)«am»‹ā›"             ; NUTS      Nuts                raerumaberī         ラエルマベリー
  String "Hapsb[ius]{iī}(iō)«ium»‹iō›"                                    ; HAPSBY    Hapsby              hapusubī            ハプスビー
  String "Viapass[us]{ūs}(uī)«um»‹ū›"                                     ; ROADPASS  Roadpass            rōdopasu            ロードパス
  String "Passpor[tus]{tūs}(tuī)«tum»‹tū›"                                ; PASSPORT  Passport            pasupōto            パスポート
  String "Circinācul[um]{ī}(ō)«um»‹ō›"                                    ; COMPASS   Compass             konpasu             コンパス
  String "Breviplacent[a]{ae}(ae)«am»‹ā›"                                 ; CAKE      Cake                shōtokēki           ショートケーキ
  String "Epistol[a]{ae}(ae)«am»‹ā› Gubernātōr[is]{is}(ī)«em»‹ī›"         ; LETTER    Letter              soutokunotegami     ソウトクノテガミ      総督の手紙
  String "Oll[a]{ae}(ae)«am»‹ā› Laconic[a]{ae}(ae)«am»‹ā›"                ; LAC. POT  Laconian Pot        rakonianpotto       ラコニアンポット
  String "Pendant[um]{ī}(ō)«um»‹ō› Lūc[is]{is}(ī)«em»‹ī›"                 ; MAG.LAMP  Magic Lamp          raitopendanto       ライトペンダント
  String "Ocul[us]{ī}(ō)«um»‹ō› Carbuncul[ī]{ī}(ō)«um»‹ō›"                ; AMBR EYE  Amber Eye           kābankuruai         カーバンクルアイ
  String "Vēl[um]{ī}(ō)«um»‹ō› Gas[ī]{ī}(ō)«um»‹ō›"                       ; GAS. SLD  Gas Shield          gasukuria           ガスクリア
  String "Crystall[um]{ī}(ō)«um»‹ō› Damo[ae]{ae}(ae)«am»‹ā›"              ; CRYSTAL   Crystal             damoakurisutaru     ダモアクリスタル
  String "Sistem[a]{tis}(ī)«a»‹e› Magistral[e]{lis}(ī)«e»‹ī›"             ; M SYSTEM  Master System       masutāshisutemu     マスターシステム
  String "Clāv[is]{is}(ī)«em»‹ī› Mīrācul[a]{ōrum}(īs)«a»‹īs›"             ; MRCL KEY  Miracle Key         mirakurukī          ミラクルキー
  String "Zillio[n]{nis}(nī)«nem»‹ne›"                                    ; ZILLION   Zillion             jirion              ジリオン
  String "R[ēs]{eī}(eī)«em»‹ē› Secrēt[a]{ae}(ae)«am»‹ā›"                  ; SECRET    Secret              himitsunomono       ヒミツノモノ        秘密の物

Names:
  String "Alīs[a]{ae}(ae)«am»‹ā›"                                         ; ALIS      Alis                arisa               アリサ
  String "Mya[u]{ī}(ō)«um»‹ō›"                                            ; MYAU      Myau                myau                ミャウ
  String "Tyr[ōn]{ōnī}(ōnō)«ōnem»‹ōnō›"                                   ; ODIN      Odin                tairon              タイロン
  String "Lūt[z]{is}(ī)«z»‹e›"                                            ; LUTZ      Lutz                rutsu               ルツ

Enemies:
  String " " ; Empty
  String "Musc[a]{ae}(ae)«am»‹ā› Monstruōs[a]{ae}(ae)«am»‹ā›"             ; SWORM     Sworm               monsutāfurai        モンスターフライ
  String "Līm[ax]{ācis}(ācī)«ācem»‹āce› Virid[is]{is}(ī)«em»‹ī›"          ; GR.SLIME  Green Slime         gurīnsuraimu        グリーンスライム
  String "Ocul[us]{ī}(ō)«um»‹ō› Alāt[us]{ī}(ō)«um»‹ō›"                    ; WING EYE  Wing Eye            uinguai             ウイングアイ
  String "Hominivor[us]{ī}(ō)«um»‹ō›"                                     ; MANEATER  Man Eater           manītā              マンイーター
  String "Scorpi[ō]{ōnis}(ōnī)«ōnem»‹ōne›"                                ; SCORPION  Scorpion            sukōpirasu          スコーピラス
  String "Naiad Magn[a]{ae}(ae)«am»‹ā›"                                   ; G.SCORPI  Gold Scorpion       rājiyāgo            ラージヤーゴ       ラージ水蠆
  String "Līm[ax]{ācis}(ācī)«ācem»‹āce› Caerule[us]{ī}(ō)«um»‹ō›"         ; BL.SLIME  Blue Slime          burūsuraimu         ブルースライム
  String "Rustic[us]{ī}(ō)«um»‹ō› Motaviān[us]{ī}(ō)«um»‹ō›"              ; N.FARMER  N.Farmer            motabiannōfu        モタビアンノーフ
  String "Vesperdiabol[us]{ī}(ō)«um»‹ō›"                                  ; OWL BEAR  Owl Bear            debirubatto         デビルバット
  String "Plant[a]{ae}(ae)«am»‹ā› Necātr[īx]{īcis}(īcī)«īcem»‹īce›"       ; DEADTREE  Dead Tree           kirāpuranto         キラープラント
  String "Here[x]{gis}(gī)«gem»‹ge›"                                      ; SCORPION  Scorpius            baitāfurai          バイターフライ      <-- Note that the sprite is a winged scorpion, see Herex below
  String "Mal[us]{ī}(ō)«um»‹ō› Motaviān[us]{ī}(ō)«um»‹ō›"                 ; E.FARMER  E.Farmer            motabianibiru       モタビアンイビル    モタビアン農夫
  String "Musc[a]{ae}(ae)«am»‹ā› Mord[ax]{ācis}(ācī)«ācem»‹āce›"          ; GIANTFLY  Giant Fly           herekkusu           ヘレックス        <-- Note that the sprite is a fly, see Biting Fly above. The US translation seemingly transfers the fly name here.
  String "Verm[is]{is}(ī)«em»‹ī› Aren[ae]{ae}(ae)«am»‹ā›"                 ; CRAWLER   Crawler             sandofūmu           サンドフーム
  String "Maniac[us]{ī}(ō)«um»‹ō› Motaviān[us]{ī}(ō)«um»‹ō›"              ; BARBRIAN  Barbarian           motabianmania       モタビアンマニア
  String "Len[s]{tis}(tī)«tem»‹te› Aure[a]{ae}(ae)«am»‹ā›"                ; GOLDLENS  Goldlens            gōrudorenzu         ゴールドレンズ
  String "Līm[ax]{ācis}(ācī)«ācem»‹āce› Rub[er]{ris}(rī)«rem»‹re›"        ; RD.SLIME  Red Slime           reddosuraimu        レッドスライム
  String "Homō Vespertili[ō]{ōnis}(ōnī)«ōnem»‹ōne›"                       ; WERE BAT  Werebat             battoman            バットマン
  String "Canc[er]{rī}(rī)«rum»‹rō› Equ[us]{ī}(ō)«um»‹ō›"                 ; BIG CLUB  Big Club            kabutogani          カブトガニ
  String "R[ex]{ēgis}(ēgī)«ēgem»‹ēge› Pisc[is]{is}(ī)«em»‹ī›"             ; FISHMAN   Fishman             shākin              シャーキン
  String "Mortif[ex]{icis}(icī)«icem»‹ice›"                               ; EVILDEAD  Evil Dead           ritchi              リッチ
  String "Tarantul[a]{ae}(ae)«am»‹ā›"                                     ; TARANTUL  Tarantula           taranuchura         タランチュラ
  String "Manticor[a]{ae}(ae)«am»‹ā›"                                     ; MANTICOR  Manticore           manchikoa           マンチコア
  String "Scelet[us]{ī}(ō)«um»‹ō›"                                        ; SKELETON  Skeleton            sukeruton           スケルトン
  String "Formīc[a]{ae}(ae)«am»‹ā› Le[ō]{ōnis}(ōnī)«ōnem»‹ōne›"           ; ANT LION  Ant Lion            arijigoku           アリジゴク
  String "V[ir]{irī}(irō)«irum»‹irō› Marīn[us]{ī}(ō)«um»‹ō›"              ; MARMAN    Marshman            māshīzu             マーシーズ
  String "Dezoriān[us]{ī}(ō)«um»‹ō›"                                      ; DEZORIAN  Dezorian            dezorian            デゾリアン
  String "Hirūd[ō]{inis}(inī)«ōnem»‹ine› Desert[um]{ī}(ō)«um»‹ō›"         ; LEECH     Leech               dezātorīchi         デザートリーチ
  String "Vampyr[us]{ī}(ō)«um»‹ō›"                                        ; VAMPIRE   Vampire             kuraion             クライオン
  String "Nās[us]{ī}(ō)«um»‹ō› Magn[us]{ī}(ō)«um»‹ō›"                     ; ELEPHANT  Elephant            biggunōzu           ビッグノーズ
  String "Cadaverūg[ō]{ōnis}(ōnī)«ōnem»‹ōne›"                             ; GHOUL     Ghoul               gūru                グール
  String "Ammonīt[ēs]{is}(ī)«em»‹ē›"                                      ; SHELFISH  Shellfish           anmonaito           アンモナイト
  String "Execūt[or]{ōris}(ōrī)«ōrem»‹ōre›"                               ; EXECUTER  Executer            eguzekyūto          エグゼキュート
  String "Mortiviv[us]{ī}(ō)«um»‹ō›"                                      ; WIGHT     Wight               waito               ワイト
  String "Mil[es]{itis}(itī)«item»‹ite› Calvāri[a]{ae}(ae)«am»‹ā›"        ; SKULL-EN  Skull-En            sukarusorujā        スカルソルジャー
  String "Cochle[a]{ae}(ae)«am»‹ā›"                                       ; AMMONITE  Ammonite            maimai              マイマイ
  String "Manticor[t]{tis}(tī)«tem»‹te›"                                  ; SPHINX    Sphinx              manchikōto          マンチコート
  String "Serp[ēns]{entis}(entī)«entem»‹ente›"                            ; SERPENT   Serpent             sāpento             サーペント
  String "Verm[is]{is}(ī)«em»‹ī› Arenāri[us]{ī}(ō)«um»‹ō›"                ; SANDWORM  Sandworm            ribaiasan           リバイアサン
  String "Drū[x]{gis}(gī)«gem»‹ge›"                                       ; LICH      Lich                dorūju              ドルージュ
  String "Octōp[us]{odis}(odī)«um»‹ō›"                                    ; OCTOPUS   Octopus             atualização         オクトパス
  String "Insidiātor Insān[us]{ī}(ō)«um»‹ō›"                              ; STALKER   Stalker             maddosutōkā         マッドストーカー
  String "Cap[ut]{itis}(itī)«ut»‹ite› Dezoriān[um]{ī}(ō)«um»‹ō›"          ; EVILHEAD  Evil Head           dezorianheddo       デゾリアンヘッド
  String "Zomb[us]{ī}(ō)«um»‹ō›"                                          ; ZOMBIE    Zombie              zonbi               ゾンビ
  String "Mortu[us]{ī}(ō)«um»‹ō› Viv[ēns]{entis}(entī)«entem»‹ente›"      ; BATALION  Battalion           byūto               ビュート
  String "Robovig[il]{ilis}(ilī)«ilem»‹ile›"                              ; ROBOTCOP  Robotcop            robottoporisu       ロボットポリス
  String "Mag[us]{ī}(ō)«um»‹ō› Cyborg"                                    ; SORCERER  Sorcerer            saibōgumeiji        サイボーグメイジ
  String "Lacert[a]{ae}(ae)«am»‹ā› Flamm[ae]{ae}(ae)«am»‹ā›"              ; NESSIE    Nessie              furēmurizādo        フレームリザード
  String "Taxim[us]{ī}(ō)«um»‹ō›"                                         ; TARZIMAL  Tarzimal            tajimu              タジム
  String "Gai[a]{ae}(ae)«am»‹ā›"                                          ; GOLEM     Golem               gaia                ガイア
  String "Cust[ōs]{ōdis}(ōdī)«ōdem»‹ōde› Machin[a]{ae}(ae)«am»‹ā›"        ; ANDROCOP  Androcop            mashīngādā          マシーンガーダー
  String "Eātor Magn[us]{ī}(ō)«um»‹ō›"                                    ; TENTACLE  Tentacle            bigguītā            ビッグイーター
  String "Tal[os]{ō}(ō)«um»‹ō›"                                           ; GIANT     Giant               tarosu              タロス
  String "Domin[a]{ae}(ae)«am»‹ā› Serp[ēns]{entis}(entī)«entem»‹ente›"    ; WYVERN    Wyvern              sunēkurōdo          スネークロード
  String "Portātor Mort[is]{is}(ī)«em»‹ī›"                                ; REAPER    Reaper              desubearā           デスベアラー
  String "Mag[us]{ī}(ō)«um»‹ō› Chaōs[is]{is}(ī)«em»‹ī›"                   ; MAGICIAN  Magician            kaosusōsarā         カオスソーサラー
  String "Centaur[us]{ī}(ō)«um»‹ō›"                                       ; HORSEMAN  Horseman            sentōru             セントール
  String "Hom[ō]{inis}(inī)«ōnem»‹ine› Glaci[ei]{ēī}(ēī)«em»‹ē›"          ; FROSTMAN  Frostman            aisuman             アイスマン
  String "Vulcān[us]{ī}(ō)«um»‹ō›"                                        ; AMUNDSEN  Amundsen            barukan             バルカン
  String "Drac[ō]{ōnis}(ōnī)«ōnem»‹ōne› Rub[er]{ris}(rī)«rem»‹re›"        ; RD.DRAGN  Red Dragon          reddodoragon        レッドドラゴン
  String "Drac[ō]{ōnis}(ōnī)«ōnem»‹ōne› Virid[is]{is}(ī)«em»‹ī›"          ; GR.DRAGN  Green Dragon        gurīndoragon        グリーンドラゴン
  String "LaShi[ec]{ēcis}(ēcī)«ēcem»‹ēce›"                                ; SHADOW    Shadow              rashīku             ラシーク
  String "Mammūth[us]{ī}(ō)«um»‹ō›"                                       ; MAMMOTH   Mammoth             manmosu             マンモス
  String "R[ex]{ēgis}(ēgī)«ēgem»‹ēge› Sabul[um]{ī}(ō)«um»‹ō›"             ; CENTAUR   Centaur             kinguseibā          キングセイバー
  String "Praed[ō]{ōnis}(ōnī)«ōnem»‹ōne› Tenebrōs[us]{ī}(ō)«um»‹ō›"       ; MARAUDER  Marauder            dākumarōdā          ダークマローダー
  String "Golem[us]{ī}(ō)«um»‹ō›"                                         ; TITAN     Titan               gōremu              ゴーレム
  String "Medūs[a]{ae}(ae)«am»‹ā›"                                        ; MEDUSA    Medusa              medyūsa             メデューサ
  String "Drac[ō]{ōnis}(ōnī)«ōnem»‹ōne› Gelid[us]{ī}(ō)«um»‹ō›"           ; WT.DRAGN  White Dragon        furosutodoragon     フロストドラゴン
  String "Drac[ō]{ōnis}(ōnī)«ōnem»‹ōne› Sapi[ēns]{entis}(entī)«entem»‹ente›" ; BL.DRAGN  Blue Dragon         doragonwaizu        ドラゴンワイズ
  String "Drac[ō]{ōnis}(ōnī)«ōnem»‹ōne› Aure[us]{ī}(ō)«um»‹ō›"            ; GD.DRAGN  Gold Dragon         gōrudodoreiku       ゴールドドレイク
  String "Doctor Insān[us]{ī}(ō)«um»‹ō›"                                  ; DR.MAD    Dr. Mad             maddodokutā         マッドドクター
  String "LaShi[ec]{ēcis}(ēcī)«ēcem»‹ēce›"                                ; LASSIC    Lassic              rashīku             ラシーク
  String "Dark Fal[z]{is}(ī)«z»‹e›"                                       ; DARKFALZ  Dark Falz           dākufarusu          ダークファルス
  String "Incub[us]{ī}(ō)«um»‹ō›"                                         ; SACCUBUS  Saccubus            naitomea            ナイトメア
.ends