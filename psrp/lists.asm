.slot 2
.section "Enemy, name, item lists" superfree
Lists:

.if LANGUAGE == "en" || LANGUAGE == "literal"
; Order is important!
Items:
  ; Max width 18 excluding <...> prefix (with space)
  String " " ; empty item (blank). Must be at least one space.
  ;        Retranslation name                 Sega translation              Romaji              Japanese
; weapons: 01-0f
  String "<A> Wood Cane"                    ; WOODCANE  Wood Cane           uddokein            ウッドケイン
  String "<A> Short Sword"                  ; SHT. SWD  Short Sword         shōtosōdo           ショートソード
  String "<An> Iron Sword"                  ; IRN. SWD  Iron Sword          aiansōdo            アイアンソード
  String "<A> Psycho Wand"                  ; WAND      Wand                saikowondo          サイコウォンド
  String "<A> Silver Tusk"                  ; IRN.FANG  Iron Fang           shirubātasuku       シルバータスク   <-- Note, Silver fang/tusk reversed in Sega translation
  String "<An> Iron Axe"                    ; IRN. AXE  Iron Axe            aianakusu           アイアンアクス
  String "<A> Titanium Sword"               ; TIT. SWD  Titanium Sword      chitaniumusōdo      チタニウムソード
  String "<A> Ceramic Sword"                ; CRC. SWD  Ceramic Sword       seramikkusōdo       セラミックソード
  String "<A> Needle Gun"                   ; NEEDLGUN  Needle Gun          nīdorugan           ニードルガン
  String "<A> Saber Claw"                   ; SIL.FANG  Silver Fang         sāberukurō          サーベルクロー   <--
  String "<A> Heat Gun"                     ; HEAT.GUN  Heat Gun            ītogan              ヒートガン
  String "<A> Light Saber"                  ; LGT.SABR  Light Saber         raitoseibā          ライトセイバー
  String "<A> Laser Gun"                    ; LASR.GUN  Laser Gun           rēzāgan             レーザーガン
  String "<A> Laconian Sword"               ; LAC. SWD  Laconian Sword      rakoniansōdo        ラコニアンソード
  String "<A> Laconian Axe"                 ; LAC. AXE  Laconian Axe        rakonianakusu       ラコニアンアクス
; armour: 10-18
  String "<A> Leather Clothes"              ; LTH.ARMR  Leather Armor       rezākurosu          レザークロス
  String "<A> White Mantle"                 ; WHT.MANT  White Mantle        howaitomanto        ホワイトマント
  String "<A> Light Suit"                   ; LGT.SUIT  Light Suit          raitosūtsu          ライトスーツ
  String "<An> Iron Armor"                  ; IRN.ARMR  Iron Armor          aianāma             アイアンアーマ
  String "<A> Spiky Squirrel Fur"           ; THCK.FUR  Thick Fur           togerisunokegawa    トゲリスノケガワ
  String "<A> Zirconia Mail"                ; ZIR.ARMR  Zirconian Armour    jirukoniameiru      ジルコニアメイル
  String "<A> Diamond Armor"                ; DMD.ARMR  Diamond Armor       daiyanoyoroi        ダイヤノヨロイ
  String "<A> Laconian Armor"               ; LAC.ARMR  Laconian Armor      rakoniāama          ラコニアアーマ
  String "<The> Frad Mantle"                ; FRD.MANT  Frad Mantle         furādomanto         フラードマント
; shields: 19-20
  String "<A> Leather Shield"               ; LTH. SLD  Leather Shield      rezāshīrudo         レザーシールド
  String "<An> Iron Shield"                 ; BRNZ.SLD  Bronze Shield       aianshīrudo         アイアンシールド  <-- Note, order reversed in Sega translation
  String "<A> Bronze Shield"                ; IRN. SLD  Iron Shield         boronshīrudo        ボロンシールド   <--
  String "<A> Ceramic Shield"               ; CRC. SLD  Ceramic Shield      seramikkunotate     セラミックノタテ
  String "<An> Animal Glove"                ; GLOVE     Glove               animarugurabu       アニマルグラブ
  String "<A> Laser Barrier"                ; LASR.SLD  Laser Shield        rēzābaria           レーザーバリア
  String "<The> Shield of Perseus"          ; MIRR.SLD  Mirror Shield       peruseusunotate     ペルセウスノタテ
  String "<A> Laconian Shield"              ; LAC. SLD  Laconian Shield     rakoniashīrudo      ラコニアシールド
; vehicles: 21-23
  String "<The> LandMaster"                 ; LANDROVR  Land Rover          randomasutā         ランドマスター
  String "<The> FlowMover"                  ; HOVRCRFT  Hovercraft          furōmūbā            フロームーバー
  String "<The> IceDecker"                  ; ICE DIGR  Ice Digger          aisudekkā           アイスデッカー
; items: 24+
  String "<A> PelorieMate"                  ; COLA      Cola                perorīmeito         ペロリーメイト
  String "<A> Ruoginin"                     ; BURGER    Burger              ruoginin            ルオギニン
  String "<The> Soothe Flute"               ; FLUTE     Flute               sūzufurūto          スーズフルート
  String "<A> Searchlight"                  ; FLASH     Flash               sāchiraito          サーチライト
  String "<An> Escape Cloth"                ; ESCAPER   Escaper             esukēpukurosu       エスケープクロス
  String "<A> TranCarpet"                   ; TRANSER   Transer             torankāpetto        トランカーペット
  String "<A> Magic Hat"                    ; MAGC HAT  Magic Hat           majikkuhatto        マジックハット
  String "<An> Alsuline"                    ; ALSULIN   Alsulin             arushurin           アルシュリン
  String "<A> Polymeteral"                  ; POLYMTRL  Polymeteral         porimeterāru        ポリメテラール
  String "<A> Dungeon Key"                  ; DUGN KEY  Dungeon Key         danjonkī            ダンジョンキー
  String "<A> Telepathy Ball"               ; SPHERE    Sphere              terepashībōru       テレパシーボール
  String "<The> Eclipse Torch"              ; TORCH     Torch               ikuripusutōchi      イクリプストーチ
  String "<The> Aeroprism" ; $30            ; PRISM     Prism               earopurizumu        エアロプリズム
  String "<The> Laerma Berries"             ; NUTS      Nuts                raerumaberī         ラエルマベリー
  String "Hapsby"                           ; HAPSBY    Hapsby              hapusubī            ハプスビー
  String "<A> Roadpass"                     ; ROADPASS  Roadpass            rōdopasu            ロードパス
  String "<A> Passport"                     ; PASSPORT  Passport            pasupōto            パスポート
  String "<A> Compass"                      ; COMPASS   Compass             konpasu             コンパス
  String "<A> Shortcake"                    ; CAKE      Cake                shōtokēki           ショートケーキ
  String "<The> Governor[-General]'s Letter"; LETTER    Letter              soutokunotegami     ソウトクノテガミ
  String "<A> Laconian Pot"                 ; LAC. POT  Laconian Pot        rakonianpotto       ラコニアンポット
  String "<The> Light Pendant"              ; MAG.LAMP  Magic Lamp          raitopendanto       ライトペンダント
  String "<The> Carbuncle Eye"              ; AMBR EYE  Amber Eye           kābankuruai         カーバンクルアイ
  String "<A> GasClear"                     ; GAS. SLD  Gas Shield          gasukuria           ガスクリア
  String "Damoa's Crystal"                  ; CRYSTAL   Crystal             damoakurisutaru     ダモアクリスタル
  String "<A> Master System"                ; M SYSTEM  Master System       masutāshisutemu     マスターシステム
  String "<The> Miracle Key"                ; MRCL KEY  Miracle Key         mirakurukī          ミラクルキー
  String "Zillion"                          ; ZILLION   Zillion             jirion              ジリオン
  String "<A> Secret Thing"                 ; SECRET    Secret              himitsunomono       ヒミツノモノ

Names:
  String "Alisa"                            ; ALIS      Alis                arisa               アリサ
  String "Myau"                             ; MYAU      Myau                myau                ミャウ
.if LANGUAGE == "en"
  String "Tylon"                            ; ODIN      Odin                tairon              タイロン
.else
  String "Tairon" ; for "literal"
.endif
  String "Lutz"                             ; LUTZ      Lutz                rutsu               ルツ

Enemies:
  String " " ; Empty
  String "<The> Monster Fly"                ; SWORM     Sworm               monsutāfurai        モンスターフライ
  String "<The> Green Slime"                ; GR.SLIME  Green Slime         gurīnsuraimu        グリーンスライム
  String "<The> Wing Eye"                   ; WING EYE  Wing Eye            uinguai             ウイングアイ
  String "<The> Maneater"                   ; MANEATER  Man Eater           manītā              マンイーター
  String "<The> Scorpius"                   ; SCORPION  Scorpion            sukōpirasu          スコーピラス
  String "<The> Giant Naiad"                ; G.SCORPI  Gold Scorpion       rājāgo              ラージャーゴ
  String "<The> Blue Slime"                 ; BL.SLIME  Blue Slime          burūsuraimu         ブルースライム
  String "<The> Motavian Peasant"           ; N.FARMER  N.Farmer            motabiannōfu        モタビアンノーフ
  String "<The> Devil Bat"                  ; OWL BEAR  Owl Bear            debirubatto         デビルバット
  String "<The> Killer Plant"               ; DEADTREE  Dead Tree           kirāpuranto         キラープラント
  String "<The> Biting Fly"                 ; SCORPIUS  Scorpius            baitāfurai          バイターフライ
  String "<The> Motavian Teaser"            ; E.FARMER  E.Farmer            motabianibiru       モタビアンイビル
  String "<The> Herex"                      ; GIANTFLY  Giant Fly           herekkusu           ヘレックス
  String "<The> Sandworm"                   ; CRAWLER   Crawler             sandofūmu           サンドフーム
  String "<The> Motavian Maniac"            ; BARBRIAN  Barbarian           motabianmania       モタビアンマニア
  String "<The> Gold Lens" ; $10            ; GOLDLENS  Goldlens            gōrudorenzu         ゴールドレンズ
  String "<The> Red Slime"                  ; RD.SLIME  Red Slime           reddosuraimu        レッドスライム
  String "<The> Bat Man"                    ; WERE BAT  Werebat             battoman            バットマン
  String "<The> Horseshoe Crab"             ; BIG CLUB  Big Club            kabutogani          カブトガニ
  String "<The> Shark King"                 ; FISHMAN   Fishman             shākin              シャーキン
  String "<The> Lich"                       ; EVILDEAD  Evil Dead           ritchi              リッチ
  String "<The> Tarantula"                  ; TARANTUL  Tarantula           taranuchirra        タラヌチッラ
  String "<The> Manticort"                  ; MANTICOR  Manticore           manchikoa           マンチコア
  String "<The> Skeleton"                   ; SKELETON  Skeleton            sukeruton           スケルトン
  String "<The> Ant-lion"                   ; ANT LION  Ant Lion            arijigoku           アリジゴク
  String "<The> Marshes"                    ; MARMAN    Marshman            māshīzu             マーシーズ
  String "<The> Dezorian"                   ; DEZORIAN  Dezorian            dezorian            デゾリアン
  String "<The> Desert Leech"               ; LEECH     Leech               dezātorīchi         デザートリーチ
  String "<The> Cryon"                      ; VAMPIRE   Vampire             kuraion             クライオン
  String "<The> Big Nose"                   ; ELEPHANT  Elephant            biggunōzu           ビッグノーズ
  String "<The> Ghoul"                      ; GHOUL     Ghoul               gūru                グール
  String "<The> Ammonite" ; $20             ; SHELFISH  Shellfish           anmonaito           アンモナイト
  String "<The> Executor"                   ; EXECUTER  Executer            eguzekyūto          エグゼキュート
  String "<The> Wight"                      ; WIGHT     Wight               waito               ワイト
  String "<The> Skull Soldier"              ; SKULL-EN  Skull-En            sukarusorujā        スカルソルジャー
  String "<The> Snail"                      ; AMMONITE  Ammonite            maimai              マイマイ
  String "<The> Manticore"                  ; SPHINX    Sphinx              manchikōto          マンチコート
  String "<The> Serpent"                    ; SERPENT   Serpent             sāpento             サーペント
  String "<The> Leviathan"                  ; SANDWORM  Sandworm            ribaiasan           リバイアサン
  String "<The> Dorouge"                    ; LICH      Lich                dorūju              ドルージュ
  String "<The> Octopus"                    ; OCTOPUS   Octopus             okutopasu           オクトパス
  String "<The> Mad Stalker"                ; STALKER   Stalker             maddosutōkā         マッドストーカー
  String "<The> Dezorian Head"              ; EVILHEAD  Evil Head           dezorianheddo       デゾリアンヘッド
  String "<The> Zombie"                     ; ZOMBIE    Zombie              zonbi               ゾンビ
  String "<The> Living Dead"                ; BATALION  Battalion           byūto               ビュート
  String "<The> Robot Police"               ; ROBOTCOP  Robotcop            robottoporisu       ロボットポリス
  String "<The> Cyborg Mage"                ; SORCERER  Sorcerer            saibōgumeiji        サイボーグメイジ
  String "<The> Flame Lizard" ; $30         ; NESSIE    Nessie              furēmurizado        フレームリザド
  String "Tajim"                            ; TARZIMAL  Tarzimal            tajimu              タジム
  String "<The> Gaia"                       ; GOLEM     Golem               gaia                ガイア
  String "<The> Machine Guard"              ; ANDROCOP  Androcop            mashīngādā          マシーンガーダー
  String "<The> Big Eater"                  ; TENTACLE  Tentacle            bigguītā            ビッグイーター
  String "<The> Talos"                      ; GIANT     Giant               tarosu              タロス
  String "<The> Snake Lord"                 ; WYVERN    Wyvern              sunēkurōdo          スネークロード
  String "<The> Death Bearer"               ; REAPER    Reaper              desubearā           デスベアラー
  String "<The> Chaos Sorcerer"             ; MAGICIAN  Magician            kaosusōsarā         カオスソーサラー
  String "<The> Centaur"                    ; HORSEMAN  Horseman            sentōru             セントール
  String "<The> Ice Man"                    ; FROSTMAN  Frostman            aisuman             アイスマン
  String "<The> Vulcan"                     ; AMUNDSEN  Amundsen            barukan             バルカン
  String "<The> Red Dragon"                 ; RD.DRAGN  Red Dragon          reddodoragon        レッドドラゴン
  String "<The> Green Dragon"               ; GR.DRAGN  Green Dragon        gurīndoragon        グリーンドラゴン
  String "LaShiec"                          ; SHADOW    Shadow              rashīku             ラシーク
  String "<The> Mammoth"                    ; MAMMOTH   Mammoth             manmosu             マンモス
  String "<The> King Saber"   ; $40         ; CENTAUR   Centaur             kinguseibā          キングセイバー
  String "<The> Dark Marauder"              ; MARAUDER  Marauder            dākumarōdā          ダークマローダー
  String "<The> Golem"                      ; TITAN     Titan               kōremu              コーレム
  String "Medusa"                           ; MEDUSA    Medusa              medyūsa             メデューサ
  String "<The> Frost Dragon"               ; WT.DRAGN  White Dragon        furosutodoragon     フロストドラゴン
  String "Dragon Wise"                      ; B.DRAGN   Blue Dragon         doragonwaizu        ドラゴンワイズ
  String "<The> Gold Drake"                 ; GD.DRAGN  Gold Dragon         gōrudodoreiku       ゴールドドレイク
  String "<The> Mad Doctor"                 ; DR.MAD    Dr. Mad             maddodokutā         マッドドクター
  String "LaShiec"                          ; LASSIC    Lassic              rashīku             ラシーク
  String "Dark Force"                       ; DARKFALZ  Dark Falz           dākufarusu          ダークファルス
  String "Nightmare"                        ; SACCUBUS  Saccubus            naitomea            ナイトメア
.endif

.if LANGUAGE == "fr"
Items:
; empty item (blank)
  String " "
; Armes
  String "<du> Sceptre"
  String "<du> Glaive"
  String "<de l'>Épée"
  String "<du> Sceptre Psycho"
  String "<des> Griffes d'acier"
  String "<de la> Hache"
  String "<de l'>Épée titane"
  String "<de l'>Épée céramique"
  String "<du> Pistolet à pointes"
  String "<des> Crocs en métal"
  String "<du> Canon plasma"
  String "<du> Sabre laser"
  String "<du> Pistolet laser"
  String "<de l'>Épée laconian"
  String "<de la> Hache laconian"
; Armures
  String "<du> Tenue de cuir"
  String "<de la> Cape blanche"
  String "<du> Plastron"
  String "<de l'>Armure d'acier"
  String "<de la> Fourrure piquante"
  String "<de la> Armure zircon"
  String "<de l'>Armure diamant"
  String "<de l'>Armure laconian"
  String "<de la> Cape de Frad"
; Boucliers
  String "<du> Bouclier de cuir"
  String "<du> Bouclier de bronze"
  String "<du> Bouclier d'acier"
  String "<du> Bouclier céramique"
  String "<des> Gants sauvages"
  String "<du> Bouclier laser"
  String "<du> Bouclier de Persée"
  String "<du> Bouclier laconian"
; véhicules
  String "<du> GéoMaster"
  String "<de l'>AquaNaute"
  String "<du> ForaGlace"
; objets
  String "<de la> Vitabarre"
  String "<de l'>Aquavital"
  String "<de la> Flute apaisante"
  String "<de la> Lampe torche"
  String "<du> Voile de fuite"
  String "<du> Tapis du croyant"
  String "<de la> Coiffe magique"
  String "<de l'>Alsuline"
  String "<de la> Polymatériau"
  String "<de la> Clé des donjons"
  String "<de la> Sphère d'esprit"
  String "<de la> Torche d'éclipse"
  String "<de l'>Aéroprisme"
  String "<des> Baies Laerma"
  String "<de> Hapsby"
  String "<du> Permis"
  String "<du> Passeport"
  String "<du> Boussole"
  String "<de la> Tarte"
  String "<de la> Lettre [du Gouverneur]"
  String "<du> Vase laconian"
  String "<du> Pendentif lumineux"
  String "<de l'>Œil d'escarboucle"
  String "<du> Masque à gaz"
  String "<du> Cristal de Damoa"
  String "<de la> Master System"
  String "<de la> Clé Magique"
  String "<de> Shinobi"
  String "<de l'>Objet secret"
Names:
; Persos
  String "<d'>Alisa"
  String "<de> Myau"
  String "<de> Tylon"
  String "<de> Lutz"
Enemies:
; Monstres
; empty item (blank)
  String " "
  String "<de la> Mouche géante"
  String "<du> Gluant vert"
  String "<de l'>Oculum ailé"
  String "<du> Dévoreur"
  String "<du> Scorpion"
  String "<de la> Naïade géante"
  String "<du> Gluant bleu"
  String "<du> Paysan Motavien"
  String "<de l'>Oculum vampire"
  String "<de la> Plante carnivore"
  String "<de l'>Hélix"
  String "<du> Chineur Motavien"
  String "<de la> Mouche piquante"
  String "<du> Vers des sables"
  String "<du> Barjot Motavien"
  String "<de l'>Oculum doré"
  String "<du> Gluant rouge"
  String "<de l'>Homo chiropter"
  String "<de la> Limule"
  String "<de l'>Homo squalus"
  String "<de l'>Âme errante"
  String "<de la> Tarentule"
  String "<de la> Manticore"
  String "<du> Squelette"
  String "<du> Fourmilion"
  String "<de l'>Homo palustris"
  String "<du> Dézorien"
  String "<de la> Sangsue du désert"
  String "<de l'>Homo nosferatu"
  String "<de l'>Éléphant"
  String "<du> Goule"
  String "<de l'>Ammonite"
  String "<de l'>Exécuteur"
  String "<de la> Liche"
  String "<du> Soldat squelette"
  String "<du> Nautilus"
  String "<du> Sphinx"
  String "<du> Serpent"
  String "<du> Léviathan"
  String "<du> Roi Liche"
  String "<de la> Pieuvre"
  String "<du> Rôdeur"
  String "<du> Chef Dézorien"
  String "<du> Revenant"
  String "<du> Mort vivant"
  String "<du> Cyber garde"
  String "<du> Sorcier du Chaos"
  String "<du> Lézard de feu"
  String "<de> Maître Tajim"
  String "<du> Gaia"
  String "<du> Garde mécanique"
  String "<du> Kraken"
  String "<du> Talos"
  String "<du> Seigneur serpent"
  String "<du> Porteur de mort"
  String "<du> Cyber mage"
  String "<du> Centaure"
  String "<du> Géant de glace"
  String "<du> Géant de feu"
  String "<du> Dragon rouge"
  String "<du> Dragon vert"
  String "<de l'>Ombre de Lassic"
  String "<du> Mammouth"
  String "<du> Roi des sabres"
  String "<du> Maraudeur sombre"
  String "<du> Golem"
  String "<de> Médusa"
  String "<du> Dragon blanc"
  String "<du> Dragon de Casba"
  String "<du> Dragon doré"
  String "<du> Savant fou"
  String "<de> Lassic"
  String "<de> Force Obscure"
  String "<de> Cauchemar"
.endif

.if LANGUAGE == "pt-br"
Items:
; empty item (blank)
  String " "
; Armas         123456789012345678
  String  "<um> Cajado"
  String "<uma> Espada Curta"
  String "<uma> Espada de Ferro"
  String  "<um> Cajado Mágico"
  String "<uma> Presa de Prata"
  String  "<um> Machado de Ferro"
  String "<uma> Espada de Titânio"
  String "<uma> Espada de Cerâmica"
  String "<uma> Pistola de Agulhas"
  String "<uma> Garra Afiada"
  String "<uma> Pistola de Calor"
  String  "<um> Sabre de Luz"
  String "<uma> Arma Laser"
  String "<uma> Espada de Lacônia"
  String  "<um> Machado de Lacônia"
; Armaduras     123456789012345678
  String "<uma> Veste de Couro"
  String  "<um> Manto Branco"
  String "<uma> Veste Leve"
  String "<uma> Armadura de Ferro"
  String "<uma> Pele Espinhosa"
  String "<uma> Malha de Zicórnio"
  String "<uma> Armadura de Diamante"
  String "<uma> Armadura de Lacônia"
  String   "<o> Manto de Frade"
; Escudos       123456789012345678
  String  "<um> Escudo de Couro"
  String  "<um> Escudo de Bronze"
  String  "<um> Escudo de Ferro"
  String  "<um> Escudo de Cerâmica"
  String "<uma> Luva Animal"
  String "<uma> Barreira Laser"
  String   "<o> Escudo de Perseu"
  String  "<um> Escudo de Lacônia"
; veículos      123456789012345678
  String   "<o> Rover Terrestre"
  String   "<o> Aerobarco"
  String   "<o> Escavador de Gelo"
; objetos       123456789012345678
  String "<uma> PelorieMate"
  String "<uma> Ruoginina"
  String   "<a> Flauta Calmante"
  String "<uma> Lanterna"
  String "<uma> Capa de Fuga"
  String  "<um> Teletapete"
  String  "<um> Chapéu Mágico"
  String "<uma> Alsulina"
  String  "<um> Polimaterial"
  String "<uma> Chave do Calabouço"
  String "<uma> Bola de Telepatia"
  String   "<a> Tocha Eclipse"
  String   "<o> Aeroprisma"
  String  "<as> Frutas de Laerma"
  String       "Hapsby"
  String  "<um> Passe"
  String  "<um> Passaporte"
  String "<uma> Bússola"
  String  "<um> Bolo"
  String   "<a> Carta do Governador[-Geral]"
  String  "<um> Pote de Lacônia"
  String   "<o> Pingente de Luz"
  String   "<o> Olho de Carbúnculo"
  String "<uma> Máscara de Gás"
  String   "<o> Cristal de Damoa"
  String  "<um> Master System"
  String   "<a> Chave Milagrosa"
  String       "Zillion"
  String "<uma> Coisa Secreta"
Names:
; Personagens
  String "Alisa"
  String "Myau"
  String "Tylon"
  String "Lutz"
Enemies:
; Monstros
; empty item (blank)
  String " "
  String "<a> Mosca Gigante"
  String "<a> Gosma Verde"
  String "<o> Olho Alado"
  String "<o> Devorador"
  String "<o> Escorpião"
  String "<o> Escorpião Gigante"
  String "<a> Gosma Azul"
  String "<o> Motaviano Camponês"
  String "<o> Olho Perverso"
  String "<a> Planta Assassina"
  String "<o> Escorpião Assassino"
  String "<o> Motaviano Cardador"
  String "<a> Herex"
  String "<o> Verme da Areia"
  String "<o> Motaviano Maníaco"
  String "<a> Lente Dourada"
  String "<a> Gosma Vermelha"
  String "<o> Homem Morcego"
  String "<o> Caranguejo-Ferradura"
  String "<o> Homem-Peixe"
  String "<o> Lich"
  String "<a> Tarântula"
  String "<a> Mantícora"
  String "<o> Esqueleto"
  String "<a> Formiga-Leão"
  String "<o> Homem do Pântano"
  String "<o> Dezoriano"
  String "<a> Sanguessuga"
  String "<o> Vampiro"
  String "<o> Elefante"
  String "<o> Canibal"
  String "<a> Amonita"
  String "<o> Executor"
  String "<a> Alma Penada"
  String "<o> Soldado Caveira"
  String "<o> Caracol"
  String "<a> Esfinge"
  String "<a> Serpente"
  String "<o> Leviatã"
  String "<o> Opressor"
  String "<o> Polvo"
  String "<o> Caçador Maluco"
  String "<o> Líder Dezoriano"
  String "<o> Zumbi"
  String "<o> Morto-Vivo"
  String "<o> Robô Policial"
  String "<o> Mago Ciborgue"
  String "<a> Salamandra"
  String "<nome> Tajim"
  String "<o> Titã"
  String "<o> Guarda Mecânico"
  String "<o> Tentáculo"
  String "<o> Talos"
  String "<a> Senhora Serpente"
  String "<o> Ceifador"
  String "<o> Mago Caótico"
  String "<o> Centauro"
  String "<o> Homem de Gelo"
  String "<o> Vulcão"
  String "<o> Dragão Vermelho"
  String "<o> Dragão Verde"
  String "<nome> LaShiec"
  String "<o> Mamute"
  String "<o> Centauro Rei"
  String "<o> Saqueador Negro"
  String "<o> Golem"
  String "<nome> Medusa"
  String "<o> Dragão de Gelo"
  String "<o> Dragão Sábio"
  String "<o> Dragão Dourado"
  String "<o> Doutor Maluco"
  String "<nome> LaShiec"
  String "<nome> Força Sombria"
  String "<nome> Pesadelo"
.endif

.if LANGUAGE == "ca"
Items:
; empty item (blank)
  String " "
; Armas         123456789012345678
  String  "<un> Bastó"
  String "<una> Espasa Curta"
  String "<una> Espasa de Ferro"
  String  "<un> Bastó Màgic"
  String  "<un> Ullal de Plata"
  String "<una> Destral de Ferro"
  String "<una> Espasa de Titani"
  String "<una> Espasa de Ceràmica"
  String "<una> Pistola d'Agulles"
  String "<una> Garra Esmolada"
  String "<una> Pistola de Calor"
  String  "<un> Sabre de Llum"
  String "<una> Arma Làser"
  String "<una> Espasa de Laconia"
  String "<una> Destral de Laconia"
; Armaduras     123456789012345678
  String  "<un> Peto de Cuir"
  String  "<un> Mantell Blanc"
  String  "<un> Vestit Lleuger"
  String "<una> Armadura de Ferro"
  String "<una> Pell Punxeguda"
  String "<una> Malla de Zicorni"
  String "<una> Armadura de Diamant"
  String "<una> Armadura de Laconia"
  String  "<la> Capa de Frai"
; Escudos       123456789012345678
  String  "<un> Escut de Cuir"
  String  "<un> Escut de Bronze"
  String  "<un> Escut de Ferro"
  String  "<un> Escut de Ceràmica"
  String  "<un> Guant Animal"
  String "<una> Barrera Làser"
  String  "<el> Escut de Perseu"
  String  "<un> Escut de Laconia"
; veículos      123456789012345678
  String  "<el> LandMaster"
  String  "<l'>AeroLliscador"
  String  "<el> Trencaglaç"
; objetos       123456789012345678
  String  "<un> PelorieMate"
  String  "<un> Ruoginin"
  String  "<la> Flauta Calmant"
  String "<una> Llanterna"
  String "<una> Capa de Fuga"
  String "<una> Telecatifa"
  String  "<un> Barret Màgic"
  String "<una> Alsulina"
  String  "<un> Polymeteral"
  String "<una> Clau de Masmorra"
  String "<una> Bola Telepàtica"
  String  "<la> Torcha d'Eclipsi"
  String  "<el> Aeroprisma"
  String "<els> Fruits de Laerma"
  String  "<en> Hapsby"
  String  "<un> Salconduit"
  String  "<un> Passaport"
  String "<una> Brúixola"
  String  "<un> Pastís"
  String  "<la> Carta del Governador[ General]"
  String "<una> Olla de Laconia"
  String   "<l'>Arrecada de Llum"
  String   "<l'>Ull de Carboncle"
  String "<una> Màscara de Gas"
  String  "<el> Cristall de Damoa"
  String "<una> Master System"
  String  "<la> Clau Miraculosa"
  String       "Zillion"
  String "<una> Cosa Secreta"
Names:
; Personagens
  String "Alisa"
  String "Myau"
  String "Tylon"
  String "Lutz"
Enemies:
; Monstres
; empty item (blank)
  String " "
  String "<el> Borinot"
  String "<el> Llot Verd"
  String  "<l'>Ull Volador"
  String "<el> Devorahomes"
  String  "<l'>Escorpí"
  String  "<l'>Escorpí Gegant"
  String "<el> Llot Blau"
  String "<el> Pagés de Motavia"
  String "<el> Ratpenat Pervers"
  String "<la> Planta Assassina"
  String  "<l'>Escorpí Assassí"
  String "<el> Tafur de Motavia"
  String "<el> Herex"
  String "<el> Cuc de Terra"
  String "<el> Maníac de Motavia"
  String "<la> Lent Daurada"
  String "<el> Llot Vermell"
  String  "<l'>Home Ratpenat"
  String "<el> Cranc Ferradura"
  String "<el> Rei Tauró"
  String "<el> Calabre"
  String "<la> Taràntula"
  String "<la> Mantícora"
  String  "<l'>Esquelet"
  String "<la> Formiga Lleó"
  String  "<l'>Home de l'Aiguamoll"
  String "<el> Dezorià"
  String "<la> Sangonera de Sorra"
  String "<el> Vampir"
  String  "<l'>Elefant"
  String "<el> Gul"
  String  "<l'>Ammonita"
  String "<el> Botxí"
  String  "<l'>Anima en Pena"
  String "<el> Soldat Calavera"
  String "<el> Cargol"
  String "<l'> Esfinx"
  String "<la> Serp"
  String "<el> Leviatà"
  String  "<l'>Opressor"
  String "<el> Pop"
  String "<el> Caçador Foll"
  String "<el> Cabdill Dezorià"
  String "<el> Zombi"
  String "<el> Mort Vivent"
  String "<el> Policia Robot"
  String "<el> Mag Cyborg"
  String "<la> Salamandra"
  String "<en> Tajim"
  String "<el> Tità"
  String "<el> Guardia Mecànic"
  String "<el> Tentacle"
  String "<el> Talos"
  String "<la> Senyora Serp"
  String "<el> Portamort"
  String "<el> Mag del Caos"
  String "<el> Centaure"
  String  "<l'>Home de Gel"
  String "<el> Vulcà"
  String "<el> Drac Vermell"
  String "<el> Drac Verd"
  String "<en> Lashiec"
  String "<el> Mamut"
  String "<el> Rei Centaure"
  String "<el> Cavaller Negre"
  String "<el> Golem"
  String "<na> Medusa"
  String "<el> Drac de Gel"
  String "<el> Drac Savi"
  String "<el> Drac Daurat"
  String "<el> Doctor Boig"
  String "<en> Lashiec"
  String "<na> Força Fosca"
  String "<el> Súcube"
.endif

.if LANGUAGE == "es"
Items:
; empty item (blank)
  String " "
; Armas         123456789012345678
  String  "<un> Bastón"
  String "<una> Espada Corta"
  String "<una> Espada de Hierro"
  String  "<un> Bastón Mágico"
  String  "<un> Colmillo de Plata"
  String "<una> Hacha de Hierro"
  String "<una> Espada de Titanio"
  String "<una> Espada de Cerámica"
  String "<una> Pistola de Agujas"
  String "<una> Garra Afilada"
  String "<una> Pistola de Calor"
  String  "<un> Sable de Luz"
  String "<una> Arma Láser"
  String "<una> Espada de Laconia"
  String "<una> Hacha de Laconia"
; Armaduras     123456789012345678
  String  "<un> Peto de Cuero"
  String  "<un> Mantel Blanco"
  String  "<un> Vestido Ligero"
  String "<una> Armadura de Hierro"
  String "<una> Piel Puntiaguda"
  String "<una> Malla de Zicornio"
  String "<una> Armadura de Diamante"
  String "<una> Armadura de Laconia"
  String  "<la> Capa de Fray"
; Escudos       123456789012345678
  String  "<un> Escudo de Cuero"
  String  "<un> Escudo de Bronce"
  String  "<un> Escudo de Hierro"
  String  "<un> Escudo de Cerámica"
  String  "<un> Guante Animal"
  String "<una> Barrera Láser"
  String  "<el> Escudo de Perseo"
  String  "<un> Escudo de Laconia"
; veículos      123456789012345678
  String  "<el> LandMaster"
  String  "<el> Aerodeslizador"
  String  "<el> Rompehielos"
; objetos       123456789012345678
  String  "<un> PelorieMate"
  String  "<un> Ruoginin"
  String  "<la> Flauta Calmante"
  String "<una> Linterna"
  String "<una> Capa de Fuga"
  String "<una> TeleAlfombra"
  String  "<un> Sombrero Mágico"
  String "<una> Alsulina"
  String  "<un> Polymeteral"
  String "<una> Llave de Mazmorra"
  String "<una> Bola Telepática"
  String  "<la> Antorcha de Eclipse"
  String  "<el> Aeroprisma"
  String "<los> Frutos de Laerma"
  String  "Hapsby"
  String  "<un> Salvoconducto"
  String  "<un> Pasaporte"
  String "<una> Brújula"
  String  "<un> Pastel"
  String  "<la> Carta del Gobernador[ General]"
  String "<una> Olla de Laconia"
  String "<el> Pendiente de Luz"
  String "<el> Ojo de Carbúnculo"
  String "<una> Máscara de Gas"
  String  "<el> Cristal de Damoa"
  String "<una> Master System"
  String  "<la> llave Milagrosa"
  String       "Zillion"
  String "<una> Cosa Secreta"
Names:
; Personajes
  String "Alisa"
  String "Myau"
  String "Tylon"
  String "Lutz"
Enemies:
; Monstres
; empty item (blank)
  String " "
  String "<el> Abejorro"
  String "<el> Limo Verde"
  String "<el> Ojo Volador"
  String "<el> Devorahombres"
  String "<el> Escorpión"
  String "<el> Escorpión Gigante"
  String "<el> Limo Azul"
  String "<el> Agricultor de Motavia"
  String "<el> Murcielago Perverso"
  String "<la> Planta Asesina"
  String "<el> Escorpión Asesino"
  String "<el> Tahur de Motavia"
  String "<el> Herex"
  String "<la> Lombriz de Tierra"
  String "<el> Maníaco de Motavia"
  String "<la> Lente Dorada"
  String "<el> Limo Rojo"
  String "<el> Hombre Murciélago"
  String "<el> Cangrejo Herradura"
  String "<el> Rey Tiburón"
  String "<el> Liche"
  String "<la> Tarántula"
  String "<la> Mantícora"
  String "<el> Esqueleto"
  String "<la> Hormiga León"
  String "<el> Hombree del Pantano"
  String "<el> Dezoriano"
  String "<la> Sanguijuela de Arena"
  String "<el> Vampiro"
  String "<el> Elefante"
  String "<el> Necrófago"
  String "<la> Ammonita"
  String "<el> Verdugo"
  String "<el> Alma en Pena"
  String "<el> Soldado Calavera"
  String "<el> Caracol"
  String "<la> Esfinge"
  String "<la> Serpiente"
  String "<el> Leviatán"
  String "<el> Opresor"
  String "<el> Pulpo"
  String "<el> Cazador Loco"
  String "<el> Cabecilla Dezoriano"
  String "<el> Zombi"
  String "<el> Muerto Viviente"
  String "<el> Policía Robot"
  String "<el> Mago Cyborg"
  String "<la> Salamandra"
  String "Tajim"
  String "<el> Titán"
  String "<el> Guardia Mecánico"
  String "<el> Tentáculo"
  String "<el> Talos"
  String "<la> Señora Serpiente"
  String "<el> Portador de Muerte"
  String "<el> Mago del Caos"
  String "<el> Centauro"
  String "<el> Hombre de Hielo"
  String "<el> Vulcano"
  String "<el> Dragón Rojo"
  String "<el> Dragón Verde"
  String "Lashiec"
  String "<el> Mamut"
  String "<el> Rey Centauro"
  String "<el> Caballero Negro"
  String "<el> Golem"
  String "Medusa"
  String "<el> Dragón de Hielo"
  String "<el> Dragón Sabio"
  String "<el> Dragón Dorado"
  String "<el> Doctor Loco"
  String "Lashiec"
  String "Fuerza Oscura"
  String "<el> Súcubo"
.endif
.if LANGUAGE == "de"
Items:
  ; Max width 20 excluding <...> prefix (with space)
  ; Characters in [] only get printed in windows (enemy name, inventory, equipped items).
  ; Those in {} get printed only in the script window, if <item>/<player>/<monster> comes after <gen>.
  ; Those in () get printed only in the script window, if <item>/<player>/<monster> comes after <dat>.
  ; Those in «» get printed only in the script window, with no dependence on previous tags.

  String " " ; empty item (blank). Must be at least one space.
; weapons: 01-0f
  String "<Ein> Holzstock"
  String "<EinN> Kurzschwert"
  String "<EinN> Eisenschwert"
  String "<Ein> Psychostab"
  String "<Ein> Silberzahn"
  String "<Eine> Eisenaxt"
  String "<EinN> Titanschwert"
  String "<EinN> Keramikschwert"
  String "<Eine> Nadelpistole"
  String "<Eine> Säbelklaue"
  String "<Eine> Heißluftpistole"
  String "<EinN> Lichtschwert"
  String "<Eine> Laserpistole"
  String "<Das> Lakoniumschwert"
  String "<Die> Lakoniumaxt"
; armour: 10-18
  String "Lederkleidung"
  String "<Ein> Weiße[r](n) Umhang"
  String "<Ein> Leichte[r](n) Anzug"
  String "<Eine> Eisenrüstung"
  String "<EinN> Stacheltierfell"
  String "<Ein> Zirkoniumharnisch"
  String "<Eine> Diamantrüstung"
  String "<Die> Lakoniumrüstung"
  String "<Der> Frahd-Umhang"
; shields: 19-20
  String "<Ein> Lederschild"
  String "<Ein> Eisenschild"
  String "<Ein> Bronzeschild"
  String "<Ein> Keramikschild"
  String "Tierhandschuhe‹n›"
  String "<Eine> Laserbarriere"
  String "<Der> Schild des Perseus"
  String "<Der> Lakoniumschild"
; vehicles: 21-23
  String "<Der> LandMaster"
  String "<Der> FlowMover"
  String "<Der> IceDecker"
; items: 24+
  String "<EinN> PelorieMate"
  String "<EinN> Ruoginin"
  String "<Die> Sanfte Flöte"			; alt: "<Die> Besänftigungsflöte"
  String "<Ein> Scheinwerfer"
  String "<Ein> Tarnumhang"
  String "<Ein> Fliegende[r](n) Teppich"
  String "<Ein> Zauberhut"
  String "<Das> Alsulin"				; alt: "<Die> «Flasche »Alsulin"
  String "<Das> Polymeteral"			; alt: "<Eine> «Flasche »Polymeteral"
  String "<Der> Generalschlüssel"
  String "<Eine> Telepathiekugel"
  String "<Die> Sonnenfackel"
  String "<Das> Aeroprisma"
  String "<Die> Laermabeeren"
  String "Hapsby"
  String "<Ein> Straßenpass"			; use definite article?
  String "<Ein> Reisepass"				; use definite article?
  String "<Der> Kompass"
  String "<EinN> Törtchen"
  String "<Der> Brief vom G«eneralg»ouverneur"
  String "<Ein> Lakoniumtopf"
  String "<Ein> Lichtanhänger"
  String "<Das> Karbunkelauge"
  String "<Eine> Gasmaske"
  String "Damoas Kristall"
  String "<EinN> Master System"
  String "<Der> Wunderschlüssel"
  String "Zillion"
  String "<EinN> Geheimnis"

Names:
  String "Alisa{s}"
  String "Myau{s}"
  String "Tylon{s}"
  String "Lutz{'}"

Enemies:
; Max width 18 for enemy window, excluding <...> prefix (with space)
  String " " ; Empty
  String "<Die> Riesenfliege"
  String "<Der> Grünschleim{s}"
  String "<Das> Flügelauge{s}"
  String "<Der> Menschenfresser{s}"
  String "<Der> Skorpion{s}"
  String "<Der> Goldskorpion{s}"
  String "<Der> Blauschleim{s}"
  String "<Der> Motavische[r]{n}(n) Bauer{s}(n)"
  String "<Die> Teufelsfledermaus"
  String "<Der> Mörderbaum{s}"
  String "<Die> Beißerfliege"
  String "<Der> Motavische[r]{n}(n) Pläger{s}"
  String "<Der> Herex"
  String "<Der> Sandwurm{s}"
  String "<Der> Motavische[r]{n}(n) Irre[r]{n}(n)"
  String "<Die> Goldlinse"
  String "<Der> Rotschleim{s}"
  String "<Der> Fledermausmann{s}"
  String "<Der> Pfeilschwanzkrebs{es}"
  String "<Der> Haikönig{s}"
  String "<Der> Lich{s}"
  String "<Die> Tarantel"
  String "<Der> Mantikor{s}"
  String "<Das> Skelett{s}"
  String "<Der> Ameisenlöwe{n}(n)"
  String "<Der> Morastmann{s}"
  String "<Der> Dezorianer{s}"
  String "<Der> Wüstenegel{s}"
  String "<Der> Cryon{s}"							; think of a different translation
  String "<Der> Riesenrüssel{s}"
  String "<Der> Ghul{s}"
  String "<Der> Ammonit{s}"
  String "<Der> Hinrichter{s}"
  String "<Der> Wicht{s}"
  String "<Der> Schädelsoldat{en}(en)"
  String "<Die> Schnecke"							; different name, maybe?
  String "<Der> Mantikort{s}"
  String "<Die> Riesenschlange"
  String "<Der> Leviathan{s}"
  String "<Der> Königslich{s}"
  String "<Der> Krake{n}(n)"
  String "<Der> Wilde[r]{n}(n) Jäger{s}"
  String "<Der> Dezorianer-Häuptling{s}"			; too long
  String "<Der> Zombie{s}"
  String "<Der> Lebende[r]{n}(n) Tote[r]{n}(n)"
  String "<Der> Roboterpolizist{en}(en)"
  String "<Der> Cyborgmagier{s}"
  String "<Die> Feuerechse"
  String "Tajim{s}"
  String "<Der> Erdriese{n}(n)"
  String "<Die> Wächtermaschine"
  String "<Der> Vielfraß{es}"
  String "<Der> Talos"
  String "<Die> Oberschlange"
  String "<Der> Todbringer{s}"
  String "<Der> Chaosmagier{s}"
  String "<Der> Zentaur{en}(en)"
  String "<Der> Eismensch{en}(en)"
  String "<Der> Vulcanus"
  String "<Der> Rote[r]{n}(n) Drache{n}(n)"
  String "<Der> Grüne[r]{n}(n) Drache{n}(n)"
  String "Lashiec{s}"
  String "<Das> Mammut{s}"
  String "<Der> Säbelkönig{s}"
  String "<Der> Schattenplünderer{s}"
  String "<Der> Golem{s}"
  String "Medusa{s}"
  String "<Der> Eisdrache{n}(n)"
  String "<Der> Weise[r]{n}(n) Drache{n}(n)"
  String "<Der> Golddrache{n}(n)"
  String "<Der> Irre[r]{n}(n) Doktor{s}"
  String "Lashiec{s}"
  String "Dunkle{r} Macht"							; with or without article is the question
  String "<Der> Albtraum{s}"
.endif

.ends
