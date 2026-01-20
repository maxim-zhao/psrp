.slot 2
.section "Enemy, name, item lists" superfree
Lists:

; Order is important!
Items:
  ; Max width 18 excluding <...> prefix (with space)
  String " " ; empty item (blank). Must be at least one space.
  ;        Retranslation name                 Sega translation              Romaji              Japanese
; weapons: 01-0f
  String "<A> Wood Cane"                    ; WOODCANE  Wood Cane           uddokein            ウッドケイン
  String "<A> Short Sword"                  ; SHT. SWD  Short Sword         shōtosōdo           ショートソード
  String "<An> Iron Sword"                  ; IRN. SWD  Iron Sword          aiansōdo            アイアンソード
  String "<A> Wand"                         ; WAND      Wand                saikowondo          サイコウォンド
  String "<A> Iron Fang"                    ; IRN.FANG  Iron Fang           shirubātasuku       シルバータスク   <-- Note, Silver fang/tusk reversed in Sega translation
  String "<An> Iron Axe"                    ; IRN. AXE  Iron Axe            aianakusu           アイアンアクス
  String "<A> Titanium Sword"               ; TIT. SWD  Titanium Sword      chitaniumusōdo      チタニウムソード
  String "<A> Ceramic Sword"                ; CRC. SWD  Ceramic Sword       seramikkusōdo       セラミックソード
  String "<A> Needle Gun"                   ; NEEDLGUN  Needle Gun          nīdorugan           ニードルガン
  String "<A> Silver Fang"                  ; SIL.FANG  Silver Fang         sāberukurō          サーベルクロー   <--
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
  String "<A> Thick Fur"                    ; THCK.FUR  Thick Fur           togerisunokegawa    トゲリスノケガワ       棘栗鼠の毛皮
  String "<A> Zirconia Mail"                ; ZIR.ARMR  Zirconian Armour    jirukoniameiru      ジルコニアメイル
  String "<A> Diamond Armor"                ; DMD.ARMR  Diamond Armor       daiyanoyoroi        ダイヤノヨロイ        ダイヤの鎧
  String "<A> Laconian Armor"               ; LAC.ARMR  Laconian Armor      rakoniāama          ラコニアアーマ
  String "<A> Frad Mantle"                ; FRD.MANT  Frad Mantle         furādomanto         フラードマント US manual says FRD MANTLE but the script says "Frad". The US script suggests "Frad" is a type of material, but the Japanese script acts more like it's a unique item.
; shields: 19-20
  String "<A> Leather Shield"               ; LTH. SLD  Leather Shield      rezāshīrudo         レザーシールド
  String "<An> Bronze Shield"               ; BRNZ.SLD  Bronze Shield       aianshīrudo         アイアンシールド  <-- Note, order reversed in Sega translation
  String "<A> Iron Shield"                  ; IRN. SLD  Iron Shield         boronshīrudo        ボロンシールド   <--
  String "<A> Ceramic Shield"               ; CRC. SLD  Ceramic Shield      seramikkunotate     セラミックノタテ       セラミックの盾
  String "<A> Glove"                        ; GLOVE     Glove               animarugurabu       アニマルグラブ
  String "<A> Laser Shield"                 ; LASR.SLD  Laser Shield        rēzābaria           レーザーバリア
  String "<A> Mirror Shield"                ; MIRR.SLD  Mirror Shield       peruseusunotate     ペルセウスノタテ      ペルセウスの盾
  String "<A> Laconian Shield"              ; LAC. SLD  Laconian Shield     rakoniashīrudo      ラコニアシールド
; vehicles: 21-23
  String "<The> Land Rover"                 ; LANDROVR  Land Rover          randomasutā         ランドマスター
  String "<The> Hovercraft"                 ; HOVRCRFT  Hovercraft          furōmūbā            フロームーバー
  String "<The> Ice Digger"                 ; ICE DIGR  Ice Digger          aisudekkā           アイスデッカー
; items: 24+
  String "<A> Cola"                         ; COLA      Cola                perorīmeito         ペロリーメイト
  String "<A> Burger"                       ; BURGER    Burger              ruoginin            ルオギニン
  String "<A> Flute"                        ; FLUTE     Flute               sūzufurūto          スーズフルート
  String "<A> Flashlight"                   ; FLASH     Flashlight          sāchiraito          サーチライト ; It's FLASH(LIGHT) in the US manual
  String "<An> Escaper"                     ; ESCAPER   Escaper             esukēpukurosu       エスケープクロス
  String "<A> Transfer"                     ; TRANSER   Transfer            torankāpetto        トランカーペット ; It's "TRANSFER" in the US manual
  String "<A> Magic Hat"                    ; MAGC HAT  Magic Hat           majikkuhatto        マジックハット
  String "<An> Alsulin"                     ; ALSULIN   Alsulin             arushurin           アルシュリン
  String "<A> Polymeteral"                  ; POLYMTRL  Polymeteral         porimeterāru        ポリメテラール
  String "<A> Dungeon Key"                  ; DUGN KEY  Dungeon Key         danjonkī            ダンジョンキー
  String "<A> Sphere"                       ; SPHERE    Sphere              terepashībōru       テレパシーボール
  String "<The> Torch"                      ; TORCH     Torch               ikuripusutōchi      イクリプストーチ
  String "<The> Prism" ; $30                ; PRISM     Prism               earopurizumu        エアロプリズム
  String "<The> Nuts"                       ; NUTS      Nuts                raerumaberī         ラエルマベリー
  String "Hapsby"                           ; HAPSBY    Hapsby              hapusubī            ハプスビー
  String "<A> Roadpass"                     ; ROADPASS  Roadpass            rōdopasu            ロードパス
  String "<A> Passport"                     ; PASSPORT  Passport            pasupōto            パスポート
  String "<A> Compass"                      ; COMPASS   Compass             konpasu             コンパス
  String "<A> Cake"                         ; CAKE      Cake                shōtokēki           ショートケーキ
  String "<The> Letter"                     ; LETTER    Letter              soutokunotegami     ソウトクノテガミ      総督の手紙
  String "<A> Laconian Pot"                 ; LAC. POT  Laconian Pot        rakonianpotto       ラコニアンポット
  String "<The> Magic Lamp"                 ; MAG.LAMP  Magic Lamp          raitopendanto       ライトペンダント
  String "<The> Amber Eye"                  ; AMBR EYE  Amber Eye           kābankuruai         カーバンクルアイ
  String "<A> Gas Shield"                   ; GAS. SLD  Gas Shield          gasukuria           ガスクリア
  String "Crystal"                          ; CRYSTAL   Crystal             damoakurisutaru     ダモアクリスタル
  String "<A> Master System"                ; M SYSTEM  Master System       masutāshisutemu     マスターシステム
  String "<The> Miracle Key"                ; MRCL KEY  Miracle Key         mirakurukī          ミラクルキー
  String "Zillion"                          ; ZILLION   Zillion             jirion              ジリオン
  String "<A> Secret"                       ; SECRET    Secret              himitsunomono       ヒミツノモノ        秘密の物

Names:
  String "Alis"                             ; ALIS      Alis                arisa               アリサ
  String "Myau"                             ; MYAU      Myau                myau                ミャウ
  String "Odin"                             ; ODIN      Odin                tairon              タイロン
  String "Lutz"                             ; LUTZ      Lutz                rutsu               ルツ

Enemies:
  String " " ; Empty
  String "<The> Sworm"                      ; SWORM     Sworm               monsutāfurai        モンスターフライ
  String "<The> Green Slime"                ; GR.SLIME  Green Slime         gurīnsuraimu        グリーンスライム
  String "<The> Wing Eye"                   ; WING EYE  Wing Eye            uinguai             ウイングアイ
  String "<The> Man Eater"                  ; MANEATER  Man Eater           manītā              マンイーター
  String "<The> Scorpion"                   ; SCORPION  Scorpion            sukōpirasu          スコーピラス
  String "<The> Gold Scorpion"              ; G.SCORPI  Gold Scorpion       rājiyāgo            ラージヤーゴ       ラージ水蠆
  String "<The> Blue Slime"                 ; BL.SLIME  Blue Slime          burūsuraimu         ブルースライム
  String "<The> North Farmer"               ; N.FARMER  N.Farmer            motabiannōfu        モタビアンノーフ
  String "<The> Owl Bear"                   ; OWL BEAR  Owl Bear            debirubatto         デビルバット
  String "<The> Dead Tree"                  ; DEADTREE  Dead Tree           kirāpuranto         キラープラント
  String "<The> Scorpius"                   ; SCORPIUS  Scorpius            baitāfurai          バイターフライ      <-- Note that the sprite is a winged scorpion, see Herex below
  String "<The> East Farmer"                ; E.FARMER  E.Farmer            motabianibiru       モタビアンイビル    モタビアン農夫
  String "<The> Giant Fly"                  ; GIANTFLY  Giant Fly           herekkusu           ヘレックス        <-- Note that the sprite is a fly, see Biting Fly above. The US translation seemingly transfers the fly name here.
  String "<The> Crawler"                    ; CRAWLER   Crawler             sandofūmu           サンドフーム
  String "<The> Barbarian"                  ; BARBRIAN  Barbarian           motabianmania       モタビアンマニア
  String "<The> Goldlens" ; $10             ; GOLDLENS  Goldlens            gōrudorenzu         ゴールドレンズ
  String "<The> Red Slime"                  ; RD.SLIME  Red Slime           reddosuraimu        レッドスライム
  String "<The> Werebat"                    ; WERE BAT  Werebat             battoman            バットマン
  String "<The> Big Club"                   ; BIG CLUB  Big Club            kabutogani          カブトガニ
  String "<The> Fishman"                    ; FISHMAN   Fishman             shākin              シャーキン
  String "<The> Evil Dead"                  ; EVILDEAD  Evil Dead           ritchi              リッチ
  String "<The> Tarantula"                  ; TARANTUL  Tarantula           taranuchura         タランチュラ
  String "<The> Manticore"                  ; MANTICOR  Manticore           manchikoa           マンチコア
  String "<The> Skeleton"                   ; SKELETON  Skeleton            sukeruton           スケルトン
  String "<The> Ant Lion"                   ; ANT LION  Ant Lion            arijigoku           アリジゴク
  String "<The> Marshman"                   ; MARMAN    Marshman            māshīzu             マーシーズ
  String "<The> Dezorian"                   ; DEZORIAN  Dezorian            dezorian            デゾリアン
  String "<The> Leech"                      ; LEECH     Leech               dezātorīchi         デザートリーチ
  String "<The> Vampire"                    ; VAMPIRE   Vampire             kuraion             クライオン
  String "<The> Elephant"                   ; ELEPHANT  Elephant            biggunōzu           ビッグノーズ
  String "<The> Ghoul"                      ; GHOUL     Ghoul               gūru                グール
  String "<The> Shellfish" ; $20            ; SHELFISH  Shellfish           anmonaito           アンモナイト
  String "<The> Executer"                   ; EXECUTER  Executer            eguzekyūto          エグゼキュート
  String "<The> Wight"                      ; WIGHT     Wight               waito               ワイト
  String "<The> Skull-En"                   ; SKULL-EN  Skull-En            sukarusorujā        スカルソルジャー
  String "<The> Ammonite"                   ; AMMONITE  Ammonite            maimai              マイマイ
  String "<The> Sphinx"                     ; SPHINX    Sphinx              manchikōto          マンチコート
  String "<The> Serpent"                    ; SERPENT   Serpent             sāpento             サーペント
  String "<The> Sandworm"                   ; SANDWORM  Sandworm            ribaiasan           リバイアサン
  String "<The> Lich"                       ; LICH      Lich                dorūju              ドルージュ
  String "<The> Octopus"                    ; OCTOPUS   Octopus             okutopasu           オクトパス
  String "<The> Stalker"                    ; STALKER   Stalker             maddosutōkā         マッドストーカー
  String "<The> Evil Head"                  ; EVILHEAD  Evil Head           dezorianheddo       デゾリアンヘッド
  String "<The> Zombie"                     ; ZOMBIE    Zombie              zonbi               ゾンビ
  String "<The> Battalion"                  ; BATALION  Battalion           byūto               ビュート
  String "<The> Robotcop"                   ; ROBOTCOP  Robotcop            robottoporisu       ロボットポリス
  String "<The> Sorcerer"                   ; SORCERER  Sorcerer            saibōgumeiji        サイボーグメイジ
  String "<The> Nessie" ; $30               ; NESSIE    Nessie              furēmurizādo        フレームリザード
  String "Tarzimal"                         ; TARZIMAL  Tarzimal            tajimu              タジム
  String "<The> Golem"                      ; GOLEM     Golem               gaia                ガイア
  String "<The> Androcop"                   ; ANDROCOP  Androcop            mashīngādā          マシーンガーダー
  String "<The> Tentacle"                   ; TENTACLE  Tentacle            bigguītā            ビッグイーター
  String "<The> Giant"                      ; GIANT     Giant               tarosu              タロス
  String "<The> Wyvern"                     ; WYVERN    Wyvern              sunēkurōdo          スネークロード
  String "<The> Reaper"                     ; REAPER    Reaper              desubearā           デスベアラー
  String "<The> Magician"                   ; MAGICIAN  Magician            kaosusōsarā         カオスソーサラー
  String "<The> Horseman"                   ; HORSEMAN  Horseman            sentōru             セントール
  String "<The> Frostman"                   ; FROSTMAN  Frostman            aisuman             アイスマン
  String "<The> Amundsen"                   ; AMUNDSEN  Amundsen            barukan             バルカン
  String "<The> Red Dragon"                 ; RD.DRAGN  Red Dragon          reddodoragon        レッドドラゴン
  String "<The> Green Dragon"               ; GR.DRAGN  Green Dragon        gurīndoragon        グリーンドラゴン
  String "Shadow"                           ; SHADOW    Shadow              rashīku             ラシーク
  String "<The> Mammoth"                    ; MAMMOTH   Mammoth             manmosu             マンモス
  String "<The> Centaur"   ; $40            ; CENTAUR   Centaur             kinguseibā          キングセイバー
  String "<The> Marauder"                   ; MARAUDER  Marauder            dākumarōdā          ダークマローダー
  String "<The> Titan"                      ; TITAN     Titan               gōremu              ゴーレム
  String "Medusa"                           ; MEDUSA    Medusa              medyūsa             メデューサ
  String "<The> White Dragon"               ; WT.DRAGN  White Dragon        furosutodoragon     フロストドラゴン
  String "<The> Blue Dragon"                ; BL.DRAGN  Blue Dragon         doragonwaizu        ドラゴンワイズ
  String "<The> Gold Dragon"                ; GD.DRAGN  Gold Dragon         gōrudodoreiku       ゴールドドレイク
  String "Doctor Mad"                       ; DR.MAD    Dr. Mad             maddodokutā         マッドドクター
  String "Lassic"                           ; LASSIC    Lassic              rashīku             ラシーク
  String "Dark Falz"                        ; DARKFALZ  Dark Falz           dākufarusu          ダークファルス
  String "Saccubus"                         ; SACCUBUS  Saccubus            naitomea            ナイトメア
.ends
