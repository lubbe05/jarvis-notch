*Private fork of [boring.notch](https://github.com/TheBoredTeam/boring.notch) with a Jarvis tab — not the official project; get the official app at [theboring.name](https://theboring.name).*

# boringNotch med Jarvis-fanen

## 1. Hvad er det her?

Det er en **privat fork** af [TheBoredTeam/boring.notch](https://github.com/TheBoredTeam/boring.notch),
lavet til ét hjem. Der er lagt **to faner** til — «Jarvis» og «Aktier» — som viser,
hvad husets system laver. Alt andet i appen er deres arbejde.

- **Det er ikke et officielt projekt.** The Boring Team har ikke lavet eller
  godkendt denne kopi og har intet med den at gøre.
- **Fejl i denne kopi meldes HER:**
  [lubbe05/jarvis-notch/issues](https://github.com/lubbe05/jarvis-notch/issues).
  Aldrig hos dem — de kan ikke gøre noget ved ændringer, de ikke har lavet.
- **Al ære tilkommer The Boring Team.** Hele appen er deres. Deres egen README
  ligger uændret i [README.upstream.md](README.upstream.md).
- **Licensen er deres og uændret:** GPL-3.0, se [LICENSE](LICENSE). Ændringerne
  her udgives under samme licens.
- **Vil du bare have appen?** Hent den officielle hos dem:
  [theboring.name](https://theboring.name) ·
  [boring.notch/releases](https://github.com/TheBoredTeam/boring.notch/releases).

## 2. Hent

### ➜ [**Hent nyeste boringNotch med Jarvis**](https://github.com/lubbe05/jarvis-notch/releases/latest)

Under **Assets** ligger to filer:

| Fil | Sådan bruger du den |
| --- | --- |
| `boringNotch-jarvis-<sha7>.dmg` | Dobbeltklik, træk **boringNotch** over i **Programmer**. |
| `boringNotch-jarvis-<sha7>.zip` | Pak ud, træk **boringNotch.app** til **/Programmer**. Virker altid. |

Der kommer en ny udgivelse af sig selv efter hvert grønt byg. Fejler bygget,
kommer der ingen — så bliver den forrige stående, og den virker. dmg'en laves kun,
hvis dmg-værktøjet kunne installeres på byggemaskinen; mangler den, siger
udgivelsesteksten det, og så tager du zip'en.

## 3. Første installation

1. **Luk den gamle app først** — menulinjens ikon → **Quit**. Ellers vil macOS
   ikke lade dig erstatte den. Sig **Erstat**, når Finder spørger.
2. **macOS advarer første gang.** Appen er bygget uden Apple-udviklerkonto
   («ad hoc-signeret»), så macOS siger, at den ikke kan søge efter skadelig
   software. Tre veje — tag den første, der virker:
   - Højreklik på appen → **Åbn** → **Åbn**.
   - Systemindstillinger → **Anonymitet & sikkerhed** → rul ned → **«Åbn alligevel»**.
   - Terminal:
     ```bash
     codesign --force --deep --sign - /Applications/boringNotch.app && xattr -dr com.apple.quarantine /Applications/boringNotch.app
     ```
     Den sidste er også kuren, hvis appen slet ikke starter — se
     [JARVIS-OPSKRIFT.md](JARVIS-OPSKRIFT.md).
3. **Tilladelserne skal gives igen.** macOS binder dem til appens signatur, og
   vores er en anden end den officielle: kalender, påmindelser, tilgængelighed,
   skærmoptagelse, Spotify/Musik. Sidder en fast, fjern **boringNotch** fra listen
   i Systemindstillinger med **«−»** og start appen igen.
4. **«Launch at login» fra og til.** Settings → **General** → slå den fra og til
   igen, så macOS peger på den nye kopi. Den opfører sig kun pænt, når appen
   ligger i **/Programmer** og karantænen er væk.

Dine indstillinger følger med: appen har samme bundle-id som den officielle
(`theboringteam.boringnotch`).

## 4. Slå Jarvis-fanen til

Settings → **Jarvis** → skriv husets adresse i feltet:

```
http://<din-tailscale-adresse>:8000/notch
```

Tryk **Test**. Der skal stå «Jarvis svarede». Adressen gemmes kun på din egen
maskine — den står ikke i koden, og appen sender aldrig noget den anden vej.

*Lauritz: din adresse står i kortet i Kommandocentret.*

Så har du **to nye faner** i den udfoldede notch. Begge folder notchen lidt
større ud end appens egne faner — Jarvis 780 × 320, Aktier 760 × 260, mod
640 × 190 — så husets sætninger (tallene står i ord, ikke i cifre) kan bryde over
flere linjer i stedet for at blive klippet med «…». Hjem og Hylde beholder deres
størrelse.

- **«Jarvis» (hjerne-ikonet) — kommandocentret:** hvor mange kort der venter
  (badge + husets egne ord), **de fem nyeste kort med «Godkend» og «Afvis»** (klik
  på titlen åbner præcis det kort), hvad huset laver lige nu + hvad det sidst
  leverede og hvornår, brevene, og nederst **«Sig det til Jarvis…»** med **Send**
  plus knappen **«Åbn Kommandocenter»**. Venter der ingen kort, står agenterne i
  stedet (grøn arbejder, grå hviler, rød fejl).
- **«Aktier» (kurve-ikonet):** husets korte linje øverst — **«Depotet er op, mest
  SNDK»** med pil og farve (**grøn op, rød ned, grå uændret**) — så depotets værdi
  **stort** og i ord og beløbet «siden seneste lukkekurs», markedsvejret og
  kontanterne hvis huset har noget at sige om dem, næste regnskab («MU aflægger
  regnskab om 14 dage», med «foreløbig dato» hvis datoen er kildens gæt),
  laboratoriernes ene sætning, og knappen **«Åbn Investor»**.
- **Et lille mærke i den foldede notch** — en prik med antallet, men kun når der
  faktisk venter kort, og kun når der ikke spiller musik. Uændret.

Begge knapper følger valget **Settings → Jarvis → «Open in»**: kører
Jarvis-appen på Mac'en allerede, bliver den løftet frem (også hvis den er skjult
eller har fået sit vindue lukket), og der startes **aldrig** en kopi nummer to;
ellers startes den, og som sidste redning åbnes web-appen. **Vælg appen i listen
«Jarvis app»** over det der kører lige nu — valget huskes på appens identitet,
ikke på dens navn, og linjen «Kører lige nu: ja/nej» viser med det samme at
matchet rammer. Det er nødvendigt, fordi en Flet- eller web-klient hedder noget
andet i systemet («Flet») end i sit vinduestitel («Jarvis»).

Svarer huset ikke, står der én dæmpet linje: «Jarvis er ikke at nå». Ingen popups.
Der hentes stadig kun **ét** kald i minuttet: begge faner læser samme svar.

**Notchen afgør intet selv.** «Godkend», «Afvis» og «Send» kalder husets **egne**
døre — de samme som appens skærme bruger — så husets værn, husets log og
fortryd-linjen i Kommandocentret gælder for et tryk i hakket præcis som for et
tryk på skærmen. `GET /notch` er og bliver læsning. Har huset ikke sagt hvem der
trykker, vises der hverken knapper eller tekstfelt.

## 5. Opdateringer

Appen henter selv ny kode. Settings → **About** → **«Check for updates»**, eller
lad **«Automatically check for updates»** stå til.

Den spørger **ikke** The Boring Team — den spørger husets eget Sparkle-feed, så
den kan ikke opdatere Jarvis-fanen væk. Efter hvert grønt byg skriver huset en ny,
signeret `appcast.xml` til grenen [`appcast`](https://github.com/lubbe05/jarvis-notch/tree/appcast),
og appen henter den derfra. Kun det, huset har signeret med sin private nøgle,
bliver godtaget.

**Én gang i hånden først:** den udgave, du har nu, peger stadig på The Boring
Teams feed og bærer deres nøgle, så den kan ikke opdatere sig over til vores.
Installér én gang som i afsnit 3 — derefter går alt gennem appen. Hele forklaringen,
og det ærlige forbehold om ad hoc-signerede apps, står i
[JARVIS-OPSKRIFT.md](JARVIS-OPSKRIFT.md) under «Opdateringer gennem appen».

## 6. Hvad er ændret i forhold til upstream

Alt nyt ligger i sin egen mappe, så opstrøms-opdateringer kan flettes ind:

| Nyt | |
| --- | --- |
| `boringNotch/Jarvis/JarvisModel.swift` | svaret fra husets bro + tilstanden i appen |
| `boringNotch/Jarvis/JarvisPoller.swift` | henter `GET /notch` hvert 60. sekund |
| `boringNotch/Jarvis/JarvisView.swift` | fanen «Jarvis» (kommandocentret) + mærket i den foldede notch |
| `boringNotch/Jarvis/JarvisAktierView.swift` | fanen «Aktier» — depotets værdi, dagens ændring, regnskab, labs |
| `boringNotch/Jarvis/JarvisFaelles.swift` | det de to faner deler: skallen, rækkerne, knapperne, farverne |
| `boringNotch/Jarvis/JarvisSkriver.swift` | det ene sted notchen skriver til huset — gennem husets egne døre |
| `boringNotch/Jarvis/JarvisSettingsView.swift` | indstillingen «Jarvis» |

Rørt ved i forvejen eksisterende filer — små tilføjelser, mærket `// JARVIS`:
`ContentView.swift`, `boringNotchApp.swift`,
`components/Notch/BoringHeader.swift`, `components/Tabs/TabSelectionView.swift`,
`components/Settings/SettingsView.swift`, `enums/generic.swift`,
`models/Constants.swift`, `models/BoringViewModel.swift`, `sizing/matters.swift`,
`Localizable.xcstrings` og `boringNotch.xcodeproj`.

Den åbne størrelse styres ét sted: `aabenNotchStoerrelse(for:)` i
`sizing/matters.swift` giver `jarvisOpenNotchSize` for de to Jarvis-faner og
`openNotchSize` for resten; `ContentView` spænder den åbne flade fast på
`vm.notchSize` i både bredde og højde, så ingen anden fane flyder med ud.

Derudover:

- `boringNotch/Info.plist` — `SUFeedURL` og `SUPublicEDKey` peger på husets eget
  Sparkle-feed i stedet for The Boring Teams (afsnit 5).
- `.github/workflows/jarvis_build.yml` — vores eget byg: ad hoc-signering af hver
  indlejret del, zip + dmg, og en udgivelse pr. grønt byg. Opstrøms' egne workflows
  er fjernet i denne fork, så den aldrig kan skrive eller kommentere i deres projekt.
- `JARVIS-OPSKRIFT.md`, `jarvis.patch` — opskriften til Mac'en, og ændringerne som
  én patch mod opstrøms.

`GET /notch` **læses kun** — der skrives aldrig dertil. Siden 16/9 om aftenen kan
notchen til gengæld **svare**: «Godkend»/«Afvis» og «læg en opgave i køen» går
gennem husets egne, i forvejen eksisterende døre, med de samme værn og den samme
fortryd-linje som appens skærme. Alt ligger i `JarvisSkriver.swift`, adressen
udledes af den ene adresse du selv har skrevet, og der er ingen nøgler i koden.

Appen signeres med husets eget selvsignerede certifikat, **«Jarvis Notch»**
(gyldigt til 2036), så macOS husker Accessibility-tilladelsen på tværs af
opdateringer. Nøglen ligger kun på husets egen maskine; mangler den i bygget,
falder det tilbage til ad hoc-signering. Se
[JARVIS-OPSKRIFT.md](JARVIS-OPSKRIFT.md) afsnit (c2).

## 7. Bygge selv

Kræver Xcode 16.4 og en Mac:

```bash
git clone -b jarvis git@github.com:lubbe05/jarvis-notch.git
cd jarvis-notch
open boringNotch.xcodeproj      # vælg skemaet boringNotch, tryk ▶
```

Den lange udgave — Swift-pakker, signering, og hvad man gør når det ikke oversætter
— står i [JARVIS-OPSKRIFT.md](JARVIS-OPSKRIFT.md) under «Byg selv i Xcode».

## 8. Licens og ære

boringNotch er skabt af **[The Boring Team](https://github.com/TheBoredTeam)** og
udgives under **GPL-3.0**. Licensen her er deres, uændret: [LICENSE](LICENSE).
Tredjepartsbiblioteker og deres licenser står i
[THIRD_PARTY_LICENSES](THIRD_PARTY_LICENSES). Deres egen README ligger uændret i
[README.upstream.md](README.upstream.md).

Ændringerne i denne fork udgives under samme licens. Støt dem gerne — men gør det
hos dem, ikke her: [theboring.name](https://theboring.name).
