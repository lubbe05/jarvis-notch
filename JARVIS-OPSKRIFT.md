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
- `boringNotch/Jarvis/JarvisFaelles.swift` — det de to faner deler (skal, rækker, knap, farver)
- `boringNotch/Jarvis/JarvisSettingsView.swift` — indstillingen «Jarvis»

Rørt ved i forvejen eksisterende filer (små, mærkede med `// JARVIS`):
`ContentView.swift`, `BoringHeader.swift`, `Tabs/TabSelectionView.swift`,
`enums/generic.swift`, `models/Constants.swift`, `models/BoringViewModel.swift`,
`sizing/matters.swift`, `Settings/SettingsView.swift`, `boringNotchApp.swift`,
`Localizable.xcstrings`, `boringNotch.xcodeproj`.

Notchen **læser kun**. Der sendes aldrig noget til huset, der er ingen nøgler i
koden, og Tailscale-adressen står kun som forslag i det tomme tekstfelt.
Der hentes **ét** kald i minuttet — begge faner læser samme svar, samme cache.

**Fanen «Jarvis» (hjerne-ikonet) — kommandocentret:** hvor mange kort der venter
(badge + husets egne ord), det nyeste kort med hele titlen og afsenderen (klik
åbner præcis det kort), nye beskeder fra huset, hvad huset laver lige nu + hvad
det sidst leverede og hvornår, navn og farve pr. agent (grøn arbejder, grå
hviler, rød fejl — hold musen over for hele sætningen), og knappen
**«Åbn Kommandocenter»**.

**Fanen «Aktier» (kurve-ikonet):** depotets værdi **stort** og i ord, dagens
ændring i ord med pil og farve — **grøn op, rød ned, grå uændret** — næste
regnskab («MU aflægger regnskab om 14 dage», med «foreløbig dato» hvis datoen er
kildens gæt), laboratoriernes ene sætning, og knappen **«Åbn Investor»**.
Kunne huset ikke måle bevægelsen, står der «bevægelsen kunne ikke måles» —
aldrig et nul, som ville blive læst som en måling.

Når broen ikke svarer: én dæmpet linje, «Jarvis er ikke at nå». Ingen popups.

**Størrelsen.** De to Jarvis-faner folder notchen større ud end appens egne:
**760 × 260** mod **640 × 190**. Grunden er at husets tal står i **ord**
(«cirka 167 tusind kroner», «to tusind kroner op siden seneste lukkekurs»), og
de sætninger blev klippet med «…» i den gamle bredde. Nu bryder de over 2-3
linjer i stedet. Hjem og Hylde er uændrede. Styringen står ét sted:

- `sizing/matters.swift` — `jarvisOpenNotchSize` og `aabenNotchStoerrelse(for:)`,
  som giver den åbne flade pr. fane. `windowSize` er nu den STØRSTE af dem (plus
  skyggen), fordi selve vinduet laves én gang og aldrig ændrer størrelse.
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

**«Open in» og feltet «App name».** Under **Settings → Jarvis** står valget
«Open in»: *Jarvis-appen på denne Mac* eller *web-appen*. Det gælder **begge**
fanes knapper — «Åbn Kommandocenter» og «Åbn Investor» — og alle klikbare
rækker. Vælger du appen, **skal feltet «App name» være udfyldt** med det navn
appen har i **Programmer** (fx `Jarvis`), eller med dens bundle-id. Er feltet
tomt, ved notchen ikke hvilken app der menes, og klikket går direkte i browseren.

Kører appen allerede, bliver den løftet frem i stedet for at åbne en browserfane.
Det sker i tre trin, fordi macOS 14 og nyere afviser et simpelt «aktivér» fra en
app der ikke selv står forrest — og notchen står aldrig forrest: først `unhide()`
(appen kan være skjult med ⌘H), så `yieldActivation` + `activate(from:)` (vi
giver vores egen aktivering væk, og så accepterer systemet løftet), og til sidst
et rigtigt «åbn» på samme bundle, fordi en app kan køre videre uden ét eneste
vindue — det gør web-apps tit, når man har lukket vinduet med ⌘W. Virker intet af
det, åbnes web-linket, så klikket aldrig dør i stilhed.

Teksterne er danske. Appen har ikke dansk i forvejen, så de danske sætninger
står i `Localizable.xcstrings` som både `da` og `en` — så ser du dansk uanset
hvilket sprog macOS kører. Nøglerne i koden er engelske og bruges som fallback
for alle andre sprog.

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
