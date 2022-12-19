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
  String "<A> Spiky Squirrel Fur"           ; THCK.FUR  Thick Fur           togerisunokegawa    トゲリスノケガワ       棘栗鼠の毛皮
  String "<A> Zirconia Mail"                ; ZIR.ARMR  Zirconian Armour    jirukoniameiru      ジルコニアメイル
  String "<A> Diamond Armor"                ; DMD.ARMR  Diamond Armor       daiyanoyoroi        ダイヤノヨロイ        ダイヤの鎧
  String "<A> Laconian Armor"               ; LAC.ARMR  Laconian Armor      rakoniāama          ラコニアアーマ
  String "<The> Frad Mantle"                ; FRD.MANT  Frad Mantle         furādomanto         フラードマント
; shields: 19-20
  String "<A> Leather Shield"               ; LTH. SLD  Leather Shield      rezāshīrudo         レザーシールド
  String "<An> Iron Shield"                 ; BRNZ.SLD  Bronze Shield       aianshīrudo         アイアンシールド  <-- Note, order reversed in Sega translation
  String "<A> Bronze Shield"                ; IRN. SLD  Iron Shield         boronshīrudo        ボロンシールド   <--
  String "<A> Ceramic Shield"               ; CRC. SLD  Ceramic Shield      seramikkunotate     セラミックノタテ       セラミックの盾
  String "<An> Animal Glove"                ; GLOVE     Glove               animarugurabu       アニマルグラブ
  String "<A> Laser Barrier"                ; LASR.SLD  Laser Shield        rēzābaria           レーザーバリア
  String "<The> Shield of Perseus"          ; MIRR.SLD  Mirror Shield       peruseusunotate     ペルセウスノタテ      ペルセウスの盾
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
  String "<The> Governor[-General]'s Letter"; LETTER    Letter              soutokunotegami     ソウトクノテガミ      総督の手紙
  String "<A> Laconian Pot"                 ; LAC. POT  Laconian Pot        rakonianpotto       ラコニアンポット
  String "<The> Light Pendant"              ; MAG.LAMP  Magic Lamp          raitopendanto       ライトペンダント
  String "<The> Carbuncle Eye"              ; AMBR EYE  Amber Eye           kābankuruai         カーバンクルアイ
  String "<A> GasClear"                     ; GAS. SLD  Gas Shield          gasukuria           ガスクリア
  String "Damoa's Crystal"                  ; CRYSTAL   Crystal             damoakurisutaru     ダモアクリスタル
  String "<A> Master System"                ; M SYSTEM  Master System       masutāshisutemu     マスターシステム
  String "<The> Miracle Key"                ; MRCL KEY  Miracle Key         mirakurukī          ミラクルキー
  String "Zillion"                          ; ZILLION   Zillion             jirion              ジリオン
  String "<A> Secret Thing"                 ; SECRET    Secret              himitsunomono       ヒミツノモノ        秘密の物

Names:
  String "Alisa"                            ; ALIS      Alis                arisa               アリサ
  String "Myau"                             ; MYAU      Myau                myau                ミャウ
  String "Tylon"                            ; ODIN      Odin                tairon              タイロン
  String "Lutz"                             ; LUTZ      Lutz                rutsu               ルツ

Enemies:
  String " " ; Empty
  String "<The> Monster Fly"                ; SWORM     Sworm               monsutāfurai        モンスターフライ
  String "<The> Green Slime"                ; GR.SLIME  Green Slime         gurīnsuraimu        グリーンスライム
  String "<The> Wing Eye"                   ; WING EYE  Wing Eye            uinguai             ウイングアイ
  String "<The> Maneater"                   ; MANEATER  Man Eater           manītā              マンイーター
  String "<The> Scorpius"                   ; SCORPION  Scorpion            sukōpirasu          スコーピラス
  String "<The> Large Naiad"                ; G.SCORPI  Gold Scorpion       rājāgo              ラージャーゴ       ラージ水蠆
  String "<The> Blue Slime"                 ; BL.SLIME  Blue Slime          burūsuraimu         ブルースライム
  String "<The> Motavian Peasant"           ; N.FARMER  N.Farmer            motabiannōfu        モタビアンノーフ
  String "<The> Devil Bat"                  ; OWL BEAR  Owl Bear            debirubatto         デビルバット
  String "<The> Killer Plant"               ; DEADTREE  Dead Tree           kirāpuranto         キラープラント
  String "<The> Biting Fly"                 ; SCORPIUS  Scorpius            baitāfurai          バイターフライ
  String "<The> Motavian Evil"              ; E.FARMER  E.Farmer            motabianibiru       モタビアンイビル    モタビアン農夫
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
.ends
