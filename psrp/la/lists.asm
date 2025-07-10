.slot 2
.section "Enemy, name, item lists" superfree
Lists:

; Order is important!
Items:
  ; Max width 18 excluding <...> prefix (with space)
  ; TODO: check what happens with the longer names
  String " " ; empty item (blank). Must be at least one space.
  ;        Retranslation name                 Sega translation              Romaji              Japanese
; weapons: 01-0f
  String "Baculum Ligneum"                  ; WOODCANE  Wood Cane           uddokein            ウッドケイン
  String "Gladius Brevis"                   ; SHT. SWD  Short Sword         shōtosōdo           ショートソード
  String "Gladius Ferreus"                  ; IRN. SWD  Iron Sword          aiansōdo            アイアンソード
  String "Baculum Psychicum"                ; WAND      Wand                saikowondo          サイコウォンド
  String "Dens Argenteus"                   ; IRN.FANG  Iron Fang           shirubātasuku       シルバータスク   <-- Note, Silver fang/tusk reversed in Sega translation
  String "Securis Ferrea"                   ; IRN. AXE  Iron Axe            aianakusu           アイアンアクス
  String "Gladius Titanicus"                ; TIT. SWD  Titanium Sword      chitaniumusōdo      チタニウムソード
  String "Gladius Ceramicus"                ; CRC. SWD  Ceramic Sword       seramikkusōdo       セラミックソード
  String "Sclopetum Aculeum"                ; NEEDLGUN  Needle Gun          nīdorugan           ニードルガン
  String "Unguis Sabulum"                   ; SIL.FANG  Silver Fang         sāberukurō          サーベルクロー   <--
  String "Sclopetum Caloris"                ; HEAT.GUN  Heat Gun            ītogan              ヒートガン
  String "Gladius Luminis"                  ; LGT.SABR  Light Saber         raitoseibā          ライトセイバー
  String "Sclopetum Laser"                  ; LASR.GUN  Laser Gun           rēzāgan             レーザーガン
  String "Gladius Laconicus"                ; LAC. SWD  Laconian Sword      rakoniansōdo        ラコニアンソード
  String "Securis Laconica"                 ; LAC. AXE  Laconian Axe        rakonianakusu       ラコニアンアクス
; armour: 10-18
  String "Vestis Coriacea"                  ; LTH.ARMR  Leather Armor       rezākurosu          レザークロス
  String "Mantellum Album"                  ; WHT.MANT  White Mantle        howaitomanto        ホワイトマント
  String "Lorica Levis"                     ; LGT.SUIT  Light Suit          raitosūtsu          ライトスーツ
  String "Armatura Ferrea"                  ; IRN.ARMR  Iron Armor          aianāma             アイアンアーマ
  String "Pellium Spiculosum"               ; THCK.FUR  Thick Fur           togerisunokegawa    トゲリスノケガワ       棘栗鼠の毛皮
  String "Armatura Zirconica"               ; ZIR.ARMR  Zirconian Armour    jirukoniameiru      ジルコニアメイル
  String "Armatura Diamantina"              ; DMD.ARMR  Diamond Armor       daiyanoyoroi        ダイヤノヨロイ        ダイヤの鎧
  String "Armatura Laconica"                ; LAC.ARMR  Laconian Armor      rakoniāama          ラコニアアーマ
  String "Mantellum Fradi"                  ; FRD.MANT  Frad Mantle         furādomanto         フラードマント
; shields: 19-20
  String "Scutum Coriaceum"                 ; LTH. SLD  Leather Shield      rezāshīrudo         レザーシールド
  String "Scutum Ferreum"                   ; BRNZ.SLD  Bronze Shield       aianshīrudo         アイアンシールド  <-- Note, order reversed in Sega translation
  String "Scutum Aeneum"                    ; IRN. SLD  Iron Shield         boronshīrudo        ボロンシールド   <--
  String "Scutum Ceramicum"                 ; CRC. SLD  Ceramic Shield      seramikkunotate     セラミックノタテ       セラミックの盾
  String "Chirotheca Animalis"              ; GLOVE     Glove               animarugurabu       アニマルグラブ
  String "Scutum Laser"                     ; LASR.SLD  Laser Shield        rēzābaria           レーザーバリア
  String "Scutum Persei"                    ; MIRR.SLD  Mirror Shield       peruseusunotate     ペルセウスノタテ      ペルセウスの盾
  String "Scutum Laconicum"                 ; LAC. SLD  Laconian Shield     rakoniashīrudo      ラコニアシールド
; vehicles: 21-23
  String "Terradominator"                   ; LANDROVR  Land Rover          randomasutā         ランドマスター
  String "Fluxumotor"                       ; HOVRCRFT  Hovercraft          furōmūbā            フロームーバー
  String "Glaciesfossor"                    ; ICE DIGR  Ice Digger          aisudekkā           アイスデッカー
; items: 24+
  String "PelorieMate"                      ; COLA      Cola                perorīmeito         ペロリーメイト
  String "Ruoginin"                         ; BURGER    Burger              ruoginin            ルオギニン
  String "Tibia Soothis"                    ; FLUTE     Flute               sūzufurūto          スーズフルート
  String "Lucerna"                          ; FLASH     Flash               sāchiraito          サーチライト
  String "Fugapannus"                       ; ESCAPER   Escaper             esukēpukurosu       エスケープクロス
  String "Tapetransitorium"                 ; TRANSER   Transer             torankāpetto        トランカーペット
  String "Pileum Magicum"                   ; MAGC HAT  Magic Hat           majikkuhatto        マジックハット
  String "Alsulinum"                        ; ALSULIN   Alsulin             arushurin           アルシュリン
  String "Polymeterum"                      ; POLYMTRL  Polymeteral         porimeterāru        ポリメテラール
  String "Clavis Carceris"                  ; DUGN KEY  Dungeon Key         danjonkī            ダンジョンキー
  String "Psychoglobus"                     ; SPHERE    Sphere              terepashībōru       テレパシーボール
  String "Fax Eclipsis"                     ; TORCH     Torch               ikuripusutōchi      イクリプストーチ
  String "Aeroprisma"                       ; PRISM     Prism               earopurizumu        エアロプリズム
  String "Baccae Laerma"                    ; NUTS      Nuts                raerumaberī         ラエルマベリー
  String "Hapsby"                           ; HAPSBY    Hapsby              hapusubī            ハプスビー
  String "Viapassus"                        ; ROADPASS  Roadpass            rōdopasu            ロードパス
  String "Passportus"                       ; PASSPORT  Passport            pasupōto            パスポート
  String "Compassus"                        ; COMPASS   Compass             konpasu             コンパス
  String "Breviplacenta"                    ; CAKE      Cake                shōtokēki           ショートケーキ
  String "Epistola Gubernatoris"            ; LETTER    Letter              soutokunotegami     ソウトクノテガミ      総督の手紙
  String "Olla Laconica"                    ; LAC. POT  Laconian Pot        rakonianpotto       ラコニアンポット
  String "Pendantum Lucis"                  ; MAG.LAMP  Magic Lamp          raitopendanto       ライトペンダント
  String "Oculus Carbunculi"                ; AMBR EYE  Amber Eye           kābankuruai         カーバンクルアイ
  String "Velum Gasi"                       ; GAS. SLD  Gas Shield          gasukuria           ガスクリア
  String "Crystallum Damoae"                ; CRYSTAL   Crystal             damoakurisutaru     ダモアクリスタル
  String "Master System"                    ; M SYSTEM  Master System       masutāshisutemu     マスターシステム
  String "Clavis Miracula"                  ; MRCL KEY  Miracle Key         mirakurukī          ミラクルキー
  String "Zillionum"                        ; ZILLION   Zillion             jirion              ジリオン
  String "Res Secreta"                      ; SECRET    Secret              himitsunomono       ヒミツノモノ        秘密の物

Names:
  String "Alisa"                            ; ALIS      Alis                arisa               アリサ
  String "Myau"                             ; MYAU      Myau                myau                ミャウ
  String "Tylon"                            ; ODIN      Odin                tairon              タイロン
  String "Lutz"                             ; LUTZ      Lutz                rutsu               ルツ

Enemies:
  String " " ; Empty
  String "Musca Monstruosa"                 ; SWORM     Sworm               monsutāfurai        モンスターフライ
  String "Limax Viridis"                    ; GR.SLIME  Green Slime         gurīnsuraimu        グリーンスライム
  String "Oculus Alatus"                    ; WING EYE  Wing Eye            uinguai             ウイングアイ
  String "Hominivorus"                      ; MANEATER  Man Eater           manītā              マンイーター
  String "Scorpio"                          ; SCORPION  Scorpion            sukōpirasu          スコーピラス
  String "Naiad Magna"                      ; G.SCORPI  Gold Scorpion       rājiyāgo            ラージヤーゴ       ラージ水蠆
  String "Limax Caeruleus"                  ; BL.SLIME  Blue Slime          burūsuraimu         ブルースライム
  String "Rusticus Motavianus"              ; N.FARMER  N.Farmer            motabiannōfu        モタビアンノーフ
  String "Vesperdiabolus"                   ; OWL BEAR  Owl Bear            debirubatto         デビルバット
  String "Planta Necatrix"                  ; DEADTREE  Dead Tree           kirāpuranto         キラープラント
  String "Herex"                            ; SCORPION  Scorpius            baitāfurai          バイターフライ      <-- Note that the sprite is a winged scorpion, see Herex below
  String "Malus Motavianus"                 ; E.FARMER  E.Farmer            motabianibiru       モタビアンイビル    モタビアン農夫
  String "Musca Mordax"                     ; GIANTFLY  Giant Fly           herekkusu           ヘレックス        <-- Note that the sprite is a fly, see Biting Fly above. The US translation seemingly transfers the fly name here.
  String "Vermis Arenae"                    ; CRAWLER   Crawler             sandofūmu           サンドフーム
  String "Maniacus Motavianus"              ; BARBRIAN  Barbarian           motabianmania       モタビアンマニア
  String "Lens Aurea"                       ; GOLDLENS  Goldlens            gōrudorenzu         ゴールドレンズ
  String "Limax Ruber"                      ; RD.SLIME  Red Slime           reddosuraimu        レッドスライム
  String "Homo Vespertilio"                 ; WERE BAT  Werebat             battoman            バットマン
  String "Cancer Equus"                     ; BIG CLUB  Big Club            kabutogani          カブトガニ
  String "Rex Piscis"                       ; FISHMAN   Fishman             shākin              シャーキン
  String "Mortifex"                         ; EVILDEAD  Evil Dead           ritchi              リッチ
  String "Tarantula"                        ; TARANTUL  Tarantula           taranuchura         タランチュラ
  String "Manticora"                        ; MANTICOR  Manticore           manchikoa           マンチコア
  String "Sceletus"                         ; SKELETON  Skeleton            sukeruton           スケルトン
  String "Formica Leo"                      ; ANT LION  Ant Lion            arijigoku           アリジゴク
  String "Vir Marinus"                      ; MARMAN    Marshman            māshīzu             マーシーズ
  String "Dezorianus"                       ; DEZORIAN  Dezorian            dezorian            デゾリアン
  String "Hirudo Desertum"                  ; LEECH     Leech               dezātorīchi         デザートリーチ
  String "Vampyrus"                         ; VAMPIRE   Vampire             kuraion             クライオン
  String "Nasus Magnus"                     ; ELEPHANT  Elephant            biggunōzu           ビッグノーズ
  String "Cadaverugo"                       ; GcOUL     Ghoul               gūru                グール
  String "Ammonites"                        ; SHELFISH  Shellfish           anmonaito           アンモナイト
  String "Executor"                         ; EXECUTER  Executer            eguzekyūto          エグゼキュート
  String "Mortivivus"                       ; WIGHT     Wight               waito               ワイト
  String "Miles Calvaria"                   ; SKULL-EN  Skull-En            sukarusorujā        スカルソルジャー
  String "Cochlea"                          ; AMMONITE  Ammonite            maimai              マイマイ
  String "Manticort"                        ; SPHINX    Sphinx              manchikōto          マンチコート
  String "Serpens"                          ; SERPENT   Serpent             sāpento             サーペント
  String "Vermis Arenarius"                 ; SANDWORM  Sandworm            ribaiasan           リバイアサン
  String "Drux"                             ; LICH      Lich                dorūju              ドルージュ
  String "Octopus"                          ; OCTOPUS   Octopus             atualização         オクトパス
  String "Insidiator Insanus"               ; STALKER   Stalker             maddosutōkā         マッドストーカー
  String "Caput Dezorianum"                 ; EVILHEAD  Evil Head           dezorianheddo       デゾリアンヘッド
  String "Zombus"                           ; ZOMBIE    Zombie              zonbi               ゾンビ
  String "Mortuus Vivens"                   ; BATALION  Battalion           byūto               ビュート
  String "Robovigil"                        ; ROBOTCOP  Robotcop            robottoporisu       ロボットポリス
  String "Magus Cyborg"                     ; SORCERER  Sorcerer            saibōgumeiji        サイボーグメイジ
  String "Lacerta Flammae"                  ; NESSIE    Nessie              furēmurizādo        フレームリザード
  String "Taximus"                          ; TARZIMAL  Tarzimal            tajimu              タジム
  String "Gaia"                             ; GOLEM     Golem               gaia                ガイア
  String "Custos Machina"                   ; ANDROCOP  Androcop            mashīngādā          マシーンガーダー
  String "Eator Magnus"                     ; TENTACLE  Tentacle            bigguītā            ビッグイーター
  String "Talos"                            ; GIANT     Giant               tarosu              タロス
  String "Domina Serpens"                   ; WYVERN    Wyvern              sunēkurōdo          スネークロード
  String "Portator Mortis"                  ; REAPER    Reaper              desubearā           デスベアラー
  String "Magus Chaosis"                    ; MAGICIAN  Magician            kaosusōsarā         カオスソーサラー
  String "Centaurus"                        ; HORSEMAN  Horseman            sentōru             セントール
  String "Homo Glaciei"                     ; FROSTMAN  Frostman            aisuman             アイスマン
  String "Vulcanus"                         ; AMUNDSEN  Amundsen            barukan             バルカン
  String "Draco Ruber"                      ; RD.DRAGN  Red Dragon          reddodoragon        レッドドラゴン
  String "Draco Viridis"                    ; GR.DRAGN  Green Dragon        gurīndoragon        グリーンドラゴン
  String "LaShiec"                          ; SHADOW    Shadow              rashīku             ラシーク
  String "Mammuthus"                        ; MAMMOTH   Mammoth             manmosu             マンモス
  String "Rex Sabulum"                      ; CENTAUR   Centaur             kinguseibā          キングセイバー
  String "Praedo Tenebrosus"                ; MARAUDER  Marauder            dākumarōdā          ダークマローダー
  String "Golemus"                          ; TITAN     Titan               gōremu              ゴーレム
  String "Medusa"                           ; MEDUSA    Medusa              medyūsa             メデューサ
  String "Draco Gelidus"                    ; WT.DRAGN  White Dragon        furosutodoragon     フロストドラゴン
  String "Draco Sapiens"                    ; BL.DRAGN  Blue Dragon         doragonwaizu        ドラゴンワイズ
  String "Draco Aureus"                     ; GD.DRAGN  Gold Dragon         gōrudodoreiku       ゴールドドレイク
  String "Doctor Insanus"                   ; DR.MAD    Dr. Mad             maddodokutā         マッドドクター
  String "LaShiec"                          ; LASSIC    Lassic              rashīku             ラシーク
  String "Dark Falz"                        ; DARKFALZ  Dark Falz           dākufarusu          ダークファルス
  String "Incubus"                          ; SACCUBUS  Saccubus            naitomea            ナイトメア
.ends
