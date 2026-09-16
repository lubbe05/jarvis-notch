# Jarvis i notchen — opskrift til Mac'en

Lauritz: den her fil er til dig. Den siger hvad der er bygget, hvad du skal
gøre på Mac'en, og hvad du skal skrive hvis det ikke vil kompilere.

**Ærligt først:** koden er skrevet i huset på Linux, hvor der hverken er Mac
eller Xcode. De to faner er **kompileret hos GitHub** (16/9 14:14 UTC, sha
2f85268, Xcode 16.4, Release, arm64): **BUILD SUCCEEDED**, ingen fejl og ikke én
advarsel fra Jarvis-filerne, signeringen OK, udgivelsen
`jarvis-v20260916-2f85268`. Men den har **aldrig kørt på en rigtig Mac** — at
den oversætter er ikke det samme som at fanerne står pænt. Hvor sætningerne
knækker, om 760 × 260 er den rigtige størrelse, og om appen faktisk bliver løftet
frem når du klikker — det ser **du** først. Ser noget skævt ud, er punkt (d)
nederst prompten der ordner det.

## Hvad der er bygget

**To** faner i den udfoldede notch — «Jarvis» og «Aktier» — et lille mærke i den
sammenfoldede, og én indstilling. Alt nyt ligger i sin egen mappe, så appen kan
følge opstrøms-opdateringer:

- `boringNotch/Jarvis/JarvisModel.swift` — svaret fra husets bro + tilstanden i appen
- `boringNotch/Jarvis/JarvisPoller.swift` — henter `GET /notch` hvert 60. sekund
- `boringNotch/Jarvis/JarvisView.swift` — fanen «Jarvis» (kommandocentret) + mærket i den foldede notch
- `boringNotch/Jarvis/JarvisAktierView.swift` — fanen «Aktier»
- `boringNotch/Jarvis/JarvisFaelles.swift` — det de to faner deler (skal, rækker, knapper, farver)
- `boringNotch/Jarvis/JarvisSkriver.swift` — **det ene sted notchen skriver til huset**: Godkend/Afvis og «læg i køen», gennem husets egne døre
- `boringNotch/Jarvis/JarvisSettingsView.swift` — indstillingen «Jarvis»

Rørt ved i forvejen eksisterende filer (små, mærkede med `// JARVIS`):
`ContentView.swift`, `BoringHeader.swift`, `Tabs/TabSelectionView.swift`,
`enums/generic.swift`, `models/Constants.swift`, `models/BoringViewModel.swift`,
`sizing/matters.swift`, `Settings/SettingsView.swift`, `boringNotchApp.swift`,
`Localizable.xcstrings`, `boringNotch.xcodeproj`.

Notchen **læser kun**. Der sendes aldrig noget til huset, der er ingen nøgler i
koden, og Tailscale-adressen står kun som forslag i det tomme tekstfelt.
Der hentes **ét** kald i minuttet — begge faner læser samme svar, samme cache.

**Fanen «Jarvis» (hjerne-ikonet) — kommandocentret:** øverst hvor mange kort der
venter (badge + husets egne ord), og til højre hvad huset laver lige nu, hvad det
sidst leverede og hvornår, plus brevene. I midten står **de fem nyeste kort der
venter på dig** — slags, titel og afsender, og til højre **«Godkend»** og
**«Afvis»**. Nederst et tekstfelt, **«Sig det til Jarvis…»** med **Send**, og
knappen **«Åbn Kommandocenter»**. Venter der ingen kort, står agenterne i stedet
(grøn arbejder, grå hviler, rød fejl — hold musen over for hele sætningen).

### Ja og nej direkte i hakket

Trykker du **Godkend** eller **Afvis**, går det gennem husets **egne** døre —
`POST /decisions/<id>/approve` og `.../reject`, præcis de samme kald
Kommandocentret bruger. Derfor gælder husets værn, husets log og
**fortryd-linjen i Kommandocentret** for et tryk i notchen lige så meget som for
et tryk på skærmen. Notchen afgør ingenting selv, og et afvist kort slettes
ikke: det bliver liggende med status «afvist», så du kan fortryde.

* **Kortet forsvinder først ved næste opslag.** Indtil da står der «Godkendt»
  eller «Afvist» på linjen. Det er med vilje: listen skal ikke hoppe under
  hånden på dig, og det er huset der ved om kortet er væk.
* **Klik på titlen** åbner præcis det kort i appen, hvis du vil læse resten før
  du dømmer.
* **Nogle kort har ingen knapper**, og det er ikke en fejl. Et **fejl-kort** vil
  lægges i køen igen, ikke godkendes — den knap findes i Kommandocentret, hvor
  opgaveteksten og køen står ved siden af. Huset siger selv hvilke kort der må
  dømmes (`kan_godkendes`).
* **Udskyd og Fortryd er ikke i hakket.** De kræver en dato og en liste over
  hvad du fortryder. De findes kun i Kommandocentret.

### «Sig det til Jarvis…»

Skriv en sætning og tryk **Send** (eller retur). Opgaven lægges i køen gennem
`POST /tasks` — samme dør som appens Kø-skærm, med de samme værn. Kvitteringen
står nederst:

* **«lagt i køen hos Jarvis»** — den ligger der nu.
* **«den står der allerede hos Jarvis»** — dublet-værnet fangede den. Ikke en
  fejl, men der blev ikke skrevet noget nyt.
* En sætning fra huset, hvis den blev afvist (fx fordi teksten lød som en
  handel — opgaver må ikke handle). Så bliver din tekst **stående** i feltet, så
  du ikke skal skrive den igen.
* Hvilken kø den kommer i, bestemmer **huset** og ikke appen; den kan lægge
  opgaven et andet sted, hvis teksten beder om et værktøj køen ikke har, og så
  siger kvitteringen hvor den faktisk ligger.

Er knapperne og tekstfeltet **slet ikke der**, har huset ikke sagt hvem der
trykker (`skriv` i svaret). Det sker fx hvis du peger på en ældre bro. En knap
der ikke kan virke, hører ikke på en skærm — så vises den ikke.

**Fanen «Aktier» (kurve-ikonet):** øverst husets korte linje med pil og farve —
**«Depotet er op, mest SNDK»** (grøn op, rød ned, grå uændret) — så depotets
værdi **stort** og i ord, så beløbet: «én tusind kroner op siden seneste
lukkekurs». Derunder markedsvejret og kontanterne, hvis huset har noget at sige
om dem, næste regnskab («MU aflægger regnskab om 14 dage», med «foreløbig dato»
hvis datoen er kildens gæt), laboratoriernes ene sætning, og knappen **«Åbn
Investor»**. Kunne huset ikke måle bevægelsen, står der «bevægelsen kunne ikke
måles» — aldrig et nul, som ville blive læst som en måling.

> **Hvorfor der ikke står «i dag».** Du bad om «hvor meget jeg er oppe i dag».
> Huset skriver «Depotet er op, mest SNDK», og beløbslinjen siger «siden seneste
> lukkekurs». Grunden er målt: kursbrønden fyldes **én gang i døgnet** (22:30,
> efter New York lukker), så de kurser vi sammenligner, beskriver den senest
> **lukkede** handelsdag. «I dag» ville være forkert fire dage ud af syv — hele
> weekenden og hver formiddag før brønden er fyldt. Vil du have «i dag»
> alligevel, er det én sætning at rette i huset (`notch._depot`) — sig til.

Når broen ikke svarer: én dæmpet linje, «Jarvis er ikke at nå». Ingen popups.

**Størrelsen.** De to Jarvis-faner folder notchen større ud end appens egne, og
de er ikke ens: **Jarvis 780 × 340** (den har fået kortlisten og tekstfeltet),
**Aktier 760 × 310**, mod appens **640 × 190**.

> **Rettet 16/9 om aftenen** efter din besked: *«notchen inde på aktiesiden går
> ligesom op af, så jeg kan ikke se hele skærmen»*. Aktier-fanen var 260 pt høj,
> og da dagens linje, markedsvejret og kontanterne kom til, blev indholdet
> højere end fladen. En flade der er højere end sin ramme, blev **centreret** —
> altså væltede den lige meget ud over toppen og bunden, og toppen er skærmens
> kant. Tre ting er ændret:
>
> 1. **Toppen står fast.** Den åbne notch er nu top-justeret, så en flade der
>    er for høj, kun kan vælte **nedad**, ind i skyggens plads hvor man stadig
>    kan læse den. Det gælder alle faner, også Hjem og Hylde.
> 2. **Højderne er regnet efter indholdet.** Af fanens højde går der 58 pt fra
>    til appens egen header og polstring; resten er regnet linje for linje
>    (regnestykket står i `sizing/matters.swift`). Aktier har 27 pt luft, Jarvis
>    19 pt. Aktier-fanen bruger nu **bredden**: værdien og beløbet står på
>    samme linje, og markedsvejret og kontanterne står side om side.
> 3. **Noget giver efter, og det er ikke toppen.** På Aktier-fanen er det
>    **laboratoriernes sætning** der falder fra to linjer til én — den er den
>    længste og den mindst tidskritiske, og hele stillingen står på
>    Investor-skærmen. På Jarvis-fanen er det **antallet af kortrækker**: kan
>    fem ikke være der, vises fire eller tre, og de ældste står stadig i
>    Kommandocentret. Værdien, dagens linje og de nyeste kort giver aldrig efter.
>
> **Ærligt:** regnestykket er aritmetik og ikke en måling på en rigtig skærm —
> der er ingen Mac i huset. Ser det stadig skævt ud, så sig hvor mange
> millimeter, så flytter jeg tallet. Grunden er at husets tal står i **ord**
(«cirka 167 tusind kroner», «to tusind kroner op siden seneste lukkekurs»), og
de sætninger blev klippet med «…» i den gamle bredde. Nu bryder de over 2-3
linjer i stedet. Hjem og Hylde er uændrede. Styringen står ét sted:

- `sizing/matters.swift` — `jarvisOpenNotchSize`, `jarvisAktierNotchSize` og
  `aabenNotchStoerrelse(for:)`, som giver den åbne flade pr. fane. `windowSize`
  er nu den STØRSTE af dem alle (plus skyggen), fordi selve vinduet laves én
  gang og aldrig ændrer størrelse.
- `models/BoringViewModel.swift` — `open()` tager størrelsen fra den valgte fane,
  og `opdaterAabenStoerrelse()` retter den når du skifter fane mens notchen er åben.
- `ContentView.swift` — den åbne flade spændes fast på `vm.notchSize` i **både**
  bredde og højde, så Hjem og Hylde ikke flyder med ud i det bredere vindue.

Sammenfoldet: et lille hjerne-ikon med antallet, men kun når der faktisk er
kort der venter, og kun når der ikke spiller musik. Mærket har forrang for
det lille ansigt.

## Installér som app (uden Xcode) — den nemme vej

Du behøver ikke Xcode. GitHub bygger appen på en Mac for os, hver gang der
kommer noget nyt på grenen `jarvis`. Opskriften ligger i
`.github/workflows/jarvis_build.yml`, og den bruger **ingen** certifikater og
ingen hemmeligheder — appen bliver «ad hoc-signeret», og det har konsekvenser
du skal kende (de står ærligt nedenfor).

**1. Hent den færdige app — det almindelige downloadlink.**
Gå til <https://github.com/lubbe05/jarvis-notch/releases/latest> (samme link
står øverst i README'en som **«Hent nyeste boringNotch med Jarvis»**). Rul ned
til **Assets** og hent én af de to:

- `boringNotch-jarvis-<sha7>.dmg` — dobbeltklik, træk **boringNotch** over i
  **Programmer**.
- `boringNotch-jarvis-<sha7>.zip` — pak ud, træk **boringNotch.app** til
  **/Programmer**. (Denne vej virker altid; dmg'en laves kun hvis
  dmg-værktøjet kunne installeres på byggemaskinen — mangler den, siger
  udgivelsesteksten det.)

Der kommer en ny udgivelse af sig selv efter hvert **grønt** byg på grenen
`jarvis`; den hedder `jarvis-v<dato>-<sha7>`, og `…/releases/latest` peger
altid på den nyeste. Fejler bygget, kommer der ingen udgivelse — så står den
forrige stadig, og den virker.

*Reserve, hvis en udgivelse skulle mangle:* fanen **Actions** →
**«Jarvis: byg appen»** → øverste (nyeste) kørsel med grønt flueben → ned til
**Artifacts** → **`boringNotch-jarvis-<sha7>`**. Browseren henter en `.zip` med
de samme to filer indeni. Artifacts ligger kun i 30 dage; udgivelserne bliver.

**2. Luk den gamle først.** Klik menulinjens ikon → **Quit**, ellers vil macOS
ikke lade dig erstatte appen. Sig **Erstat** når Finder spørger.

**3. Første start: macOS advarer.** Appen er ad hoc-signeret — det vil sige
signeret uden et Apple-udviklerkonto — så macOS siger noget i retning af
«boringNotch kan ikke åbnes, fordi Apple ikke kan søge efter skadelig
software». Det er ikke en fejl i appen; det er prisen for at bygge uden
udviklerkonto. To veje:

- **Højreklik på appen → Åbn → Åbn.** Kun første gang. (Virker ikke altid på
  nyere macOS — så tag den næste.)
- Systemindstillinger → **Anonymitet & sikkerhed** → rul ned → **«Åbn
  alligevel»**.
- Eller i Terminal:

  ```bash
  xattr -dr com.apple.quarantine /Applications/boringNotch.app
  ```

**4. Dine indstillinger følger med.** Appen har samme bundle-id som den du har
i dag (`theboringteam.boringnotch`), så alt hvad du har sat — faner, højde,
genveje — står der stadig.

**5. Tilladelserne gør ikke.** macOS binder tilladelser til appens *signatur*,
og vores er en anden end den fra The Boring Teams officielle udgivelse. Regn
derfor med at skulle give dem igen: **kalender**, **påmindelser**,
**tilgængelighed**, **skærmoptagelse**, **Spotify/Musik**. Hvis en tilladelse
sidder fast (afkrydset, men virker ikke): Systemindstillinger → **Anonymitet &
sikkerhed** → den pågældende liste → markér **boringNotch** → **«−»** → start
appen igen og sig ja, når den spørger.

**6. Start ved login.** Appen bruger allerede `LaunchAtLogin` (Apples
`SMAppService`) — det er uændret i vores byg, der er ikke rørt en linje ved
det. Efter udskiftningen: **Settings → General → «Launch at login»** — slå den
**fra og til igen**, så macOS peger på den nye kopi. Tjek den gerne i
Systemindstillinger → **Generelt → Loginemner**. Bemærk: login-emnet vil kun
opføre sig pænt når appen ligger i **/Programmer** og karantænen er væk
(punkt 3).

**7. Jarvis-adressen.** Settings → **Jarvis** → skriv
`http://<din-tailscale-adresse>:8000/notch` → **Test** skal svare «Jarvis svarede».
*Lauritz: din adresse står i kortet i Kommandocentret.*

**8. Lad automatiske opdateringer stå TIL.** Settings → **About** →
«Automatically check for updates» **til**. Fra 16/9 spørger appen ikke længere
The Boring Team, men **huset** — se afsnittet **«Opdateringer gennem appen»**
nedenfor. Den kan altså ikke længere opdatere Jarvis-fanen væk, og du slipper
for at hente en zip i hånden hver gang.

*(Havde du slået den fra efter en tidligere udgave af den her opskrift, så slå
den til igen — men først når du har installeret en app, der er bygget efter
16/9. En ældre kopi peger stadig på opstrøms.)*

### Hvis appen ikke starter (forskellige team-id'er)

Starter appen slet ikke — den hopper op og forsvinder igen, eller Konsol viser

```
dyld: Library not loaded: @rpath/MediaRemoteAdapter.framework/Versions/A/MediaRemoteAdapter
Reason: code signature in '…/MediaRemoteAdapter' not valid for use in process:
mapping process and mapped file (non-platform) have different Team IDs
```

— så er det ikke en fejl i Jarvis-fanen. Det er signaturerne der ikke passer
sammen: **appen** var ad hoc-signeret (uden udviklerkonto, altså uden team-id),
mens et af de **indlejrede** frameworks stadig bar den oprindelige udviklers
signatur. Appen kører med «hardened runtime», og den regel siger, at en app kun
må indlæse kode med samme team-id som sin egen. To forskellige team-id'er =
dyld siger nej, før appen overhovedet når at tegne noget.

**Kuren i Terminal** (virker på en app du allerede har hentet):

```bash
codesign --force --deep --sign - /Applications/boringNotch.app && xattr -dr com.apple.quarantine /Applications/boringNotch.app
```

Første kommando signerer appen **og alt indeni** ad hoc, så alle dele har det
samme (tomme) team-id. Den anden fjerner karantænen, så macOS ikke spørger igen.
Start appen bagefter. Siger den første kommando `replacing existing signature`
en håndfuld gange, er det som det skal være.

Vil du selv se om det hjalp:

```bash
codesign -dvv /Applications/boringNotch.app 2>&1 | grep TeamIdentifier
codesign -dvv /Applications/boringNotch.app/Contents/Frameworks/MediaRemoteAdapter.framework/Versions/A/MediaRemoteAdapter 2>&1 | grep TeamIdentifier
```

Begge skal svare `TeamIdentifier=not set`. Står der et team-id i den nederste,
er omsigneringen ikke slået igennem — kør kommandoen igen med `sudo`.

*Byggemaskinen gør det samme af sig selv fra og med 16/9.* Trinnet **«Signér
alle indlejrede dele ad hoc»** i `jarvis_build.yml` signerer hver eneste
indlejret binær om indefra og ud efter bygget, tjekker bagefter at ingen af dem
har et team-id, og **lader bygget stå rødt og udgiver ingenting**, hvis en af
dem gør.

**Og det trin har nu kørt.** Byggene stod stille 16/9 mellem kl. 09 og 11 UTC,
fordi de gratis Actions-timer var brugt op på det dengang private repo. Da
Lauritz gjorde repoet offentligt kl. ca. 10:50 UTC, kørte bygget igennem — grønt
hele vejen, også trinnet «Signér alle indlejrede dele ad hoc», der aldrig havde
nået at køre før. Det blev samtidig repoets **allerførste** udgivelse:
`jarvis-v20260916-fe6dcb8` (tidligere byg lagde kun en artifact i Actions-fanen,
aldrig en release — så der stod ingenting på `releases/latest`).

Hent den udgivelse. Kør alligevel de to kommandoer ovenfor på den, første gang:
det koster ingenting, og de fjerner samtidig karantænen.

### Nyt byg, når der er rettet noget

Hver gang huset skubber til grenen `jarvis`, starter bygget af sig selv
(og du kan selv starte et: Actions → «Jarvis: byg appen» → **Run workflow**).
Bliver det grønt, står den færdige app som en ny udgivelse på
<https://github.com/lubbe05/jarvis-notch/releases/latest> — med en linje om
hvad der er nyt. Så henter du bare den og gentager punkt 1-3 og 6.

Rettelser der kun rører tekst og opskrifter skubbes med `[skip ci]` i
commit-beskeden, så de ikke koster en hel Mac-byggetur. Derfor kan den nyeste
commit godt stå uden kørsel — tag så den nyeste kørsel der er.

### Hvad bygget koster

Repoet er privat, og macOS-maskiner tæller 10× i GitHubs gratis timer. Derfor:
vi bygger kun **arm64** (alle Mac'er med notch er Apple Silicon), og opstrøms
eget `cicd.yml` er slået fra i vores kopi, så vi ikke betaler for det samme byg
to gange.

### Hvis timerne er brugt op

**Det er løst: repoet er offentligt fra 16/9, og så er Actions gratis — også
macOS.** Afsnittet her står som forklaring på, hvad der skete, og hvad man gør,
hvis det nogensinde sker igen.

Løber de gratis timer tør, stopper byggene uden varsel: en ny commit på grenen
`jarvis` får ingen kørsel, `build-logs/latest.md` bliver ikke opdateret, og
Actions-siden siger noget om at betalingen mangler.

*Sådan så det ud 16/9:* sidste byggelog var `22f56de` fra kl. 08:59 UTC. Derefter
blev `9d25319` og `a2f50be` skubbet til grenen uden `[skip ci]` — og ingen af
dem fik en kørsel eller en byggelog, heller ikke efter en halv time. Regnestykket
passer: GitHubs gratis konto giver 2.000 minutter om måneden, og macOS tæller
10×, så der er kun plads til et par timers Mac-byg i alt.

Der er to veje.

**A. Gør repoet offentligt — så er Actions gratis.** GitHub tager ikke betaling
for Actions i offentlige repoer, hverken for Linux eller macOS. Fremgangsmåden:
repoets **Settings** → helt ned i bunden → **Danger Zone** → **Change repository
visibility** → **Make public**.

Hvad det koster af privatliv, ærligt:

- Koden er alligevel boringNotch, som er frit tilgængelig i forvejen. Det nye,
  der bliver offentligt, er **Jarvis-fanen** og **denne opskrift**.
- Husets adresse står **ikke** i repoet. Overalt i opskriften og i appens tomme
  felt står der `http://<din-tailscale-adresse>:8000/notch`; den rigtige adresse
  skriver Lauritz selv ind, og den gemmes kun på hans egen Mac. Det er i øvrigt
  en **Tailscale-adresse** (100.64–100.127-serien), som kun kan nås indefra hans
  eget Tailscale-net — men nu hvor repoet er offentligt, står tallet ingen steder.
- Vil du ikke engang det: erstat adressen med `http://DIN-JARVIS-ADRESSE:8000/notch`
  her i opskriften **før** du gør repoet offentligt, og skriv den rigtige
  adresse ind i appens Settings → Jarvis i hånden. Der er ingen nøgler,
  adgangskoder eller certifikater nogen steder i repoet — det har der aldrig
  været, og bygget bruger kun GitHubs eget `GITHUB_TOKEN`.

Fortryder du, kan repoet gøres privat igen samme sted. Så koster byggene
minutter igen.

**B. Byg på din egen Mac i stedet.** Så koster det ingen GitHub-minutter
overhovedet — se **«Byg selv i Xcode»** nedenfor. Det kræver Xcode installeret.

## Opdateringer gennem appen

**Kort:** fra 16/9 kan du hente ny kode inde i appen — Settings → **About** →
**«Check for updates»** — i stedet for at gå på GitHub efter en zip. Der er
**én** håndvending først, og den kan ikke undgås.

### Den ene gang i hånden

Den app, du har i dag, er bygget med The Boring Teams opdaterings-adresse og
**deres** nøgle. Den kan ikke opdatere sig over til vores — Sparkle tjekker
opdateringen mod nøglen i den app, der **allerede** er installeret, og vores
nøgle står der ikke endnu. Derfor:

1. Hent den nyeste udgivelse i hånden, som beskrevet i punkt 1 ovenfor:
   <https://github.com/lubbe05/jarvis-notch/releases/latest>
   (du skal have en, hvis `commit:`-linje er fra **16/9 eller senere** — det er
   den første med husets nøgle i).
2. Luk den gamle app (menulinjens ikon → **Quit**), træk den nye til
   **/Programmer**, sig **Erstat**.
3. Kør de to kommandoer i Terminal — også selv om appen ser ud til at starte.
   Den første signerer appen og alt indeni ad hoc, så alle dele har det samme
   (tomme) team-id; den anden fjerner karantænen:

   ```bash
   codesign --force --deep --sign - /Applications/boringNotch.app && xattr -dr com.apple.quarantine /Applications/boringNotch.app
   ```

4. Start appen. Settings → **About** → slå **«Automatically check for
   updates»** **til**.

Derefter er det slut med at hente i hånden.

### Sådan gør du bagefter

Settings → **About** → **«Check for updates»**. Er der noget nyt, siger appen
det selv, henter det, og beder dig om at genstarte den. Med det automatiske tjek
slået til spørger den også af sig selv med jævne mellemrum.

### Hvad huset gør

Efter hvert **grønt** byg kører huset én kommando:

```bash
notch_appcast.py udgiv
```

Den henter release-zip'en fra GitHub, læser appens eget versionsnummer ud af
den, signerer zip'en med husets private Ed25519-nøgle og skubber en ny
`appcast.xml` til grenen `appcast` i repoet. Det er den fil, din app henter:

```
https://raw.githubusercontent.com/lubbe05/jarvis-notch/appcast/appcast.xml
```

Kommandoen kan køres igen og igen uden at lave rod: er der intet nyt, skriver
den intet. Den private nøgle ligger **kun** på husets maskine i
`~/.jarvis/notch/sparkle-ed25519.key` og kommer aldrig i et repo. Den
offentlige halvdel står i appens `Info.plist` som `SUPublicEDKey` — det er den,
din app bruger til at afvise alt, huset ikke har signeret.

Bemærk: `raw.githubusercontent.com` cacher filen i op mod fem minutter. Siger
appen «du er opdateret» lige efter et byg, så prøv igen om lidt.

### Det ærlige forbehold

Appen er **ad hoc-signeret** — bygget uden Apple-udviklerkonto. Normalt vil
Sparkle se, at den nye app er signeret af den samme udvikler som den gamle, og
det kan vores aldrig: en ad hoc-signatur hører til den enkelte binær og er
forskellig fra byg til byg. Sparkles regel står ordret i dens egen kilde
([`Sparkle/SUUpdateValidator.m`](https://github.com/sparkle-project/Sparkle/blob/2.x/Sparkle/SUUpdateValidator.m),
`validateUpdateForHost:`):

> If the update is a bundle, then it must meet any one of:
> * old and new Ed(DSA) public keys are the same and valid (it allows change of Code Signing identity), or
> * old and new Code Signing identity are the same and valid

**Én** af de to skal passe — og hos os er det den første: EdDSA-signaturen. Den
er derfor ikke en ekstra sikkerhed oven i noget andet; den er det **eneste**,
der står mellem din app og en forfalsket opdatering. Derfor er nøglen på husets
maskine og ingen andre steder.

Sparkles anden regel forbyder at *fjerne* en kodesignatur, og den nævner ad hoc
direkte:

> The old bundle is code signed but the update is not code signed. Sparkle only
> supports rotation, but not removal of Apple Code Signing identity. Please code
> sign the new app. If no Apple Code Signing certificate is available, adhoc
> signing can be used at minimum.

Ad hoc **tæller** altså som kodesigneret, og byggemaskinen signerer i forvejen
hver eneste del ad hoc (trinnet «Signér alle indlejrede dele ad hoc»). Så begge
regler er opfyldt.

To ting følger af det, og de er værd at kende:

- **macOS' karantæne fjernes ikke af Sparkle.** Opdateringen kommer ikke med en
  Apple-notarisering, og en opdatering, appen selv har hentet, plejer ikke at
  blive sat i karantæne — men starter en opdateret app ikke, er kuren den samme
  som i punkt 3 ovenfor.
- **Vi kan ikke skifte nøgle over luften.** Skulle husets nøgle en dag blive
  skiftet, kræver Sparkle enten den gamle nøgle eller en matchende
  kodesignatur — og den sidste har vi ikke. Så bliver det én installation i
  hånden igen. Nøglen skal altså blive, hvor den er.

### Hvis appen siger «du er opdateret», men der er noget nyt

- Er repoet stadig privat, kan hverken appen eller huset hente noget.
  `raw.githubusercontent.com` og GitHubs release-API svarer kun på et
  **offentligt** repo uden nøgle. Det skal altså gøres offentligt, før det her
  virker overhovedet.
- Er bygget rødt, er der ingen ny udgivelse — og så er der med rette ingen
  opdatering.
- Kør huset `notch_appcast.py udgiv` efter bygget? Uden den er appcasten
  stadig den gamle.
- Har du en app fra **før** 16/9? Så peger den stadig på opstrøms. Tag
  håndvendingen ovenfor.

## Byggeloggen: sådan ser huset hvad der gik galt

Huset har ingen adgang til GitHubs Actions-side. Derfor skriver bygget sin egen
log tilbage til repoet — også når det fejler — på grenen **`build-logs`**:

- `build-logs/latest.md` — status (grøn/rød), dato, sha, link til kørslen, hvilken
  udgivelse der kom ud af det (og hvilke filer der er vedhæftet), **signeringens
  dom** (om nogen indlejret del stadig har et team-id) med hele
  team-id-optællingen, de første 200 `error:`/`warning:`-linjer og de sidste 80
  linjer af loggen
- `build-logs/fejl.txt` — alle `error:`-linjer
- `build-logs/byggelog-hale.txt` — de sidste 1500 linjer rå log

I huset læses den sådan:

```bash
cd ~/jarvis-notch
git fetch origin build-logs
git show origin/build-logs:build-logs/latest.md
```

Den gren indeholder kun logfiler — aldrig kode — og bygget skriver den med
GitHubs eget `GITHUB_TOKEN`. Der er ingen hemmeligheder i den.

## Byg selv i Xcode

## (a) Forudsætninger

- Kun hvis du vil bygge selv: **Xcode**. Opstrøms README siger Xcode 26 eller
  nyere, men vores byg hos GitHub klarer den med **Xcode 16.4**, så en ældre
  Xcode er nok. Selve appen kører fra **macOS 14 Sonoma**.
- Vil du ikke bygge selv, så spring hele dette afsnit over — se «Installér som
  app (uden Xcode)» ovenfor.
- Tailscale tændt på Mac'en. Prøv først i Terminal:

  ```bash
  curl http://<din-tailscale-adresse>:8000/health
  curl http://<din-tailscale-adresse>:8000/notch
  ```

  Den første skal svare `{"ok": true, ...}`. Den anden er den JSON fanen viser.
  Svarer de ikke, er det huset eller Tailscale — ikke appen.

## (b) Hent og byg

```bash
git clone <dit repo>        # fx git@github.com:lubbe05/jarvis-notch.git
cd jarvis-notch
git checkout jarvis
open boringNotch.xcodeproj
```

I Xcode: vælg målet **boringNotch** → fanen **Signing & Capabilities** →
**Team**: din egen Apple-konto (en «Personal Team» er nok; sæt evt. et unikt
bundle-id hvis Xcode brokker sig). Så **Cmd + R** (Build & Run).

Netadgang er der i forvejen: `com.apple.security.network.client` stod allerede
i `boringNotch.entitlements`, så der er intet at tilføje.

## (c) Indstillingen

Menulinjens ikon (eller højreklik på notchen) → **Settings** → **Jarvis** i
listen til venstre. Skriv adressen i feltet:

```
http://<din-tailscale-adresse>:8000/notch
```

(Der står et blegt forslag i samme form i det tomme felt — erstat pladsholderen
med din egen adresse.) Tryk
**Test**: der kommer «Jarvis svarede» eller «Jarvis er ikke at nå». Så snart
adressen står der, dukker **begge** faner op i den udfoldede notch — «Jarvis»
(hjerne-ikonet) og «Aktier» (kurve-ikonet). Tømmer du feltet, forsvinder begge
faner, mærket og al hentning.

Vil du have en Jarvis-fane til at blive stående i stedet for at falde tilbage til
Home hver gang notchen lukker: **Settings → General** → «Remember last tab».

### «Open in» — og VÆLG appen i listen

Under **Settings → Jarvis** står valget «Open in»: *Jarvis-appen på denne Mac*
eller *web-appen*. Det gælder **begge** fanes knapper — «Åbn Kommandocenter» og
«Åbn Investor» — og alle klikbare rækker.

Vælger du appen, står der nu en **liste over de apps der kører lige nu**
(«Jarvis app»), med både navn og identitet: `Flet — com.flet.jarvis`. **Vælg din
Jarvis-app der.** Under listen står **«Kører lige nu: ja/nej»**, så du kan se med
det samme at valget rammer den rigtige proces — i stedet for at gætte efter et
klik. Er appen ikke på listen, så start den og tryk **«Opdatér listen»**.

**Hvorfor en liste og ikke bare et navn?** 16/9 startede notchen en **ny kopi**
af Jarvis-appen hver gang du trykkede «Åbn Kommandocenter». Grunden stod i din
egen skærmoptagelse: din Jarvis-app er en **Flet-desktop-klient**. Det navn
systemet kender den under, er **«Flet»** — det er kun *vinduet* der hedder
«Jarvis», og vinduestitler kan en app ikke se uden tilgængelighedsadgang. Feltet
«App name» kunne derfor aldrig ramme den kørende proces, og så faldt notchen
tilbage til «start `/Applications/Jarvis.app`» — en kopi nummer to, med sit eget
ikon i Docken. Vælgeren gemmer i stedet appens **bundle-id**, som følger
processen og er ligeglad med hvad den kalder sig på skærmen.

Feltet **«App name (manuel reserve)»** er der stadig, men det bruges **kun** når
der ikke er valgt noget i listen.

Rækkefølgen når du klikker: kører der en proces med det valgte **bundle-id**
(ellers den gemte **sti**, ellers navnet) → **løft den frem**. Der startes
**aldrig** en ny kopi, når en proces fra samme bundle allerede kører. Kører der
ingenting, startes appen fra den sti vælgeren gemte. Kan den heller ikke findes,
åbnes web-linket, så klikket aldrig dør i stilhed.

Selve løftet sker i tre trin, fordi macOS 14 og nyere afviser et simpelt
«aktivér» fra en app der ikke selv står forrest — og notchen står aldrig forrest:
først `unhide()` (appen kan være skjult med ⌘H), så `yieldActivation` +
`activate(from:)` (vi giver vores egen aktivering væk, og så accepterer systemet
løftet), og til sidst et rigtigt «åbn» på **den bundle processen allerede kører
fra**, fordi en app kan leve videre uden ét eneste vindue — det gør Flet- og
web-klienter tit, når man har lukket vinduet med ⌘W.

Teksterne er danske. Appen har ikke dansk i forvejen, så de danske sætninger
står i `Localizable.xcstrings` som både `da` og `en` — så ser du dansk uanset
hvilket sprog macOS kører. Nøglerne i koden er engelske og bruges som fallback
for alle andre sprog.

## (c2) Tilladelserne skal holde: husets eget certifikat

**Problemet, som du selv har mærket:** hver gang appen opdaterede sig, ville
macOS have Accessibility-tilladelsen igen. Det var ikke en fejl i appen. Den blev
**ad hoc-signeret**, altså uden en signerende identitet — og så er appens
«mærke» dens egne bytes (cdhash). Ændrer én byte sig, er det en fremmed app for
macOS' tilladelsesdatabase, og hvert byg ændrer flere tusind bytes.

**Kuren er ét certifikat der ikke skifter.** Huset har lavet et selvsigneret
codesigning-certifikat, **«Jarvis Notch»**, gyldigt til **13. september 2036**.
Nu er kravet «signeret af Jarvis Notch» i stedet for «præcis disse bytes», og så
husker macOS tilladelsen fra byg til byg.

* Nøglen og certifikatet ligger **kun** i `~/.jarvis/notch/` på husets maskine
  (`jarvis-notch-cert.key`, `.crt`, `.p12`, `.password`, alle mode 600). De står
  **ikke** i noget repo, og de må ikke komme til at gøre det.
* Det er **ikke** Apple-signering. macOS advarer stadig første gang (samme
  `xattr`-trin som før), og der er **intet team-id** — det er også meningen:
  uden team-id går library validation ikke i gang, og
  `MediaRemoteAdapter.framework` kan stadig indlæses.
* Mangler certifikatet i bygget, falder det tilbage til ad hoc som før. Så
  virker appen; du skal blot give Accessibility igen ved hver opdatering.

### Du skal sætte to secrets, én gang

Byggemaskinen hos GitHub kan ikke læse husets disk. Certifikatet kommer ind som
to **secrets** i repoet, og dem kan kun du sætte (huset har ikke en GitHub-login
til det — `gh` er ikke installeret på maskinen).

**På husets maskine**, hent de to værdier frem:

```bash
cat ~/.jarvis/notch/jarvis-notch-cert.p12.base64   # den lange linje = JARVIS_CERT_P12
cat ~/.jarvis/notch/jarvis-notch-cert.password     # de 40 tegn      = JARVIS_CERT_PASSWORD
```

**I browseren:** <https://github.com/lubbe05/jarvis-notch/settings/secrets/actions>
→ **New repository secret**, to gange:

| Name | Secret |
| --- | --- |
| `JARVIS_CERT_P12` | hele den lange base64-linje (ingen linjeskift) |
| `JARVIS_CERT_PASSWORD` | de 40 tegn |

**Eller med `gh`**, hvis du har den på Mac'en og er logget ind som `lubbe05`:

```bash
gh secret set JARVIS_CERT_P12      --repo lubbe05/jarvis-notch < ~/.jarvis/notch/jarvis-notch-cert.p12.base64
gh secret set JARVIS_CERT_PASSWORD --repo lubbe05/jarvis-notch < ~/.jarvis/notch/jarvis-notch-cert.password
```

(De to filer ligger på **Linux-maskinen**, så kopier dem over, eller kør
kommandoerne derfra hvis `gh` bliver installeret.)

Derefter siger hvert byg i loggen hvem der signerede — kig efter linjen
«signering: OK — alt signeret med certifikatet «Jarvis Notch»» i
`build-logs/latest.md` eller i udgivelsesteksten.

### Én sidste gang skal du give Accessibility igen

**Det første byg med certifikatet er en ny identitet for macOS.** Så den ene gang
skal du gøre det her:

1. Installér den nye version (den kommer gennem appen, se nedenfor).
2. Systemindstillinger → **Anonymitet & sikkerhed** → **Tilgængelighed**.
3. **Fjern** `boringNotch` med **«−»**, og **tilføj** den igen med **«+»**
   (eller slå den fra og til).
4. Gør det samme for skærmoptagelse, hvis den også er blevet glemt.

**Derefter holder det.** Alle senere opdateringer er signeret med det samme
certifikat, og macOS ser dem som den samme app.

### Opdateringen gennem appen virker — det er efterprøvet

Sparkle godtager skiftet fra ad hoc til certifikatet. Ikke fordi den er ligeglad,
men fordi den har en regel for netop dette (**«key rotation»**): den godtager en
opdatering hvis **enten** signaturen på arkivet (husets EdDSA-nøgle) **eller**
kode-signaturen matcher den gamle app — og huset har ikke skiftet EdDSA-nøgle.
Sparkles egen dokumentation kalder det «rotating signing keys», og reglen står
ordret i kilden (`SUUpdateValidator.m`): *«old and new Ed(DSA) public keys are
the same and valid (it allows change of Code Signing identity)»*.

To ting skal derfor holde, og de gør:

* **EdDSA-nøglen må ikke skifte i samme opdatering.** Den er uændret
  (`~/.jarvis/notch/sparkle-ed25519.key`). Man må skifte ét af de to, aldrig
  begge på én gang.
* **Den nye app skal være signeret og forseglet korrekt i sig selv.** Det er
  netop det bygget måler: `codesign --verify --deep --strict` skal stå OK, og
  ellers bliver bygget rødt og der udgives intet.

`SUVerifyUpdateBeforeExtraction` er ikke sat i `Info.plist` (standard: fra), og
den ville have været den ene ting der kunne have krævet en Apple-signeret dmg.

**Hvis opdateringen mod forventning bliver afvist** («The update is improperly
signed and could not be validated»), er kuren den samme som første installation:
hent dmg'en fra Releases og træk appen over i Programmer én gang i hånden.
Derefter er identiteten på plads, og appen opdaterer sig selv igen.

## (d) Hvis det ikke kompilerer

Start en Claude Code-session i mappen og skriv:

> Byg projektet `boringNotch.xcodeproj` med `xcodebuild -scheme boringNotch
> build` (eller i Xcode). Ret de oversætterfejl der kommer, men rør KUN filerne
> i `boringNotch/Jarvis/` og de steder i `ContentView.swift`,
> `BoringHeader.swift`, `Tabs/TabSelectionView.swift`, `enums/generic.swift`,
> `models/Constants.swift` og `Settings/SettingsView.swift` der er mærket
> `// JARVIS`. Lav ikke om på appens øvrige opførsel, tilføj ingen nye
> afhængigheder (kun Foundation/SwiftUI/URLSession og appens egen Defaults), og
> lad notchen blive læse-eneste — ingen POST til broen. Kør appen, sæt
> Jarvis-adressen til `http://<din-tailscale-adresse>:8000/notch` i Settings → Jarvis,
> og vis mig skærmbilleder af både den sammenfoldede og den udfoldede notch.

Hvis en fane eller en indstilling slet ikke vil samarbejde, er det hele
reversibelt: slet mappen `boringNotch/Jarvis/` og de otte `// JARVIS`-steder.
Vil du kun af med mærket i den foldede notch, er det de to blokke i
`ContentView.swift` der er mærket `// JARVIS`.

## (e) Opdatering fra upstream

```bash
git remote add upstream https://github.com/TheBoredTeam/boring.notch.git   # kun første gang
git fetch upstream
git checkout jarvis
git rebase upstream/main        # eller upstream/dev, hvis du følger dev-grenen
```

Konflikter kommer kun de få steder ovenfor; mappen `boringNotch/Jarvis/` rører
ingen andre. Efter en rebase: byg igen, og tjek at fanen stadig er der.

## Kendte usikkerheder

- Koden er ikke kompileret. Mest sandsynlige fejl: en modifier eller en
  SwiftUI-API der hedder noget andet end gættet.
- Mærket i den sammenfoldede notch er hængt på den eksisterende kæde af
  tilstande. Ser det skævt ud i kanten af notchen, så er det bredden i
  `JarvisLukketMaerke` (i `JarvisView.swift`) der skal skrues på.
- Fanen antager at broens rute `GET /notch` svarer som aftalt. Mangler et felt,
  udelader visningen bare den linje — den bør aldrig gå i stykker af det.

## Uden grenen: jarvis.patch

Har du kun `main`, ligger hele tilføjelsen som `jarvis.patch` i roden:

```bash
git checkout -b jarvis main
git am jarvis.patch      # eller: git apply jarvis.patch
```
