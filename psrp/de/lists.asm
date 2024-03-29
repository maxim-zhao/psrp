.slot 2
.section "Enemy, name, item lists" superfree
Lists:

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
  String "<Das> Laconiaschwert"
  String "<Die> Laconiaaxt"
; armour: 10-18
  String "Lederkleidung"
  String "<Ein> Weiße[r](n) Umhang"
  String "<Ein> Leichte[r](n) Anzug"
  String "<Eine> Eisenrüstung"
  String "<EinN> Stacheltierfell"
  String "<Ein> Zirconiaharnisch"
  String "<Eine> Diamantrüstung"
  String "<Die> Laconiarüstung"
  String "<Der> Frahd-Umhang"
; shields: 19-20
  String "<Ein> Lederschild"
  String "<Ein> Eisenschild"
  String "<Ein> Bronzeschild"
  String "<Ein> Keramikschild"
  String "Tierhandschuhe‹n›"
  String "<Eine> Laserbarriere"
  String "<Der> Schild des Perseus"
  String "<Der> Laconiaschild"
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
  String "<Ein> Laconiatopf"
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
; Max width 20 for enemy window, excluding <...> prefix (with space)
  String " " ; Empty
  String "<Die> Riesenfliege"
  String "<Der> Grünschleim{s}"
  String "<Das> Flügelauge{s}"
  String "<Der> Menschenfresser{s}"
  String "<Der> Skorpion{s}"
  String "<Die> Riesenlibelle"
  String "<Der> Blauschleim{s}"
  String "<Der> Motavia-Bauer{s}(n)"
  String "<Die> Teufelsfledermaus"
  String "<Der> Mörderbaum{s}"
  String "<Die> Beißerfliege"
  String "<Der> Motavia-Pläger{s}"
  String "<Der> Herex"
  String "<Der> Sandwurm{s}"
  String "<Der> Motavianische[r]{n}(n) Irre[r]{n}(n)"
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
  String "<Der> Vampir{s}"
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
  String "<Der> Dezorianer-Häuptling{s}"
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
  String "Dark Falz{'}"
  String "<Der> Albtraum{s}"

.ends
