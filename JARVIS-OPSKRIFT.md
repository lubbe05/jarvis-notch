# Jarvis i notchen — opskrift til Mac'en

Lauritz: den her fil er til dig. Den siger hvad der er bygget, hvad du skal
gøre på Mac'en, og hvad du skal skrive hvis det ikke vil kompilere.

**Ærligt først:** koden er skrevet i huset på Linux, hvor der hverken er Mac
eller Xcode. **Den er aldrig kompileret.** Alt er skrevet konservativt og i
appens egen stil, men regn med at der kan være et par oversætterfejl der skal
rettes på Mac'en. Punkt (d) nederst er prompten der ordner det.

## Hvad der er bygget

En ny fane «Jarvis» i den udfoldede notch, et lille mærke i den sammenfoldede,
og én indstilling. Alt nyt ligger i sin egen mappe, så appen kan følge
opstrøms-opdateringer:

- `boringNotch/Jarvis/JarvisModel.swift` — svaret fra husets bro + tilstanden i appen
- `boringNotch/Jarvis/JarvisPoller.swift` — henter `GET /notch` hvert 60. sekund
- `boringNotch/Jarvis/JarvisView.swift` — fanen + mærket i den foldede notch
- `boringNotch/Jarvis/JarvisSettingsView.swift` — indstillingen «Jarvis»

Rørt ved i forvejen eksisterende filer (små, mærkede med `// JARVIS`):
`ContentView.swift`, `BoringHeader.swift`, `Tabs/TabSelectionView.swift`,
`enums/generic.swift`, `models/Constants.swift`, `Settings/SettingsView.swift`,
`boringNotchApp.swift`, `Localizable.xcstrings`, `boringNotch.xcodeproj`.

Notchen **læser kun**. Der sendes aldrig noget til huset, der er ingen nøgler i
koden, og Tailscale-adressen står kun som forslag i det tomme tekstfelt.

Det du ser, udfoldet: hvor mange kort der venter (tal i mærket + husets egne
ord), det seneste kort (titel · afsender) som du kan klikke på — det åbner
web-appen i browseren, en linje om hvad huset sidst gjorde, depotets værdi og
dagens ændring (grøn/rød/grå), næste regnskab («MU aflægger regnskab i
morgen», med «(foreløbig)» hvis datoen er kildens gæt), laboratoriernes ene
sætning, og en prik pr. agent (grøn arbejder, grå hviler, rød fejl — hold
musen over prikken for navnet). Når broen ikke svarer: én dæmpet linje,
«Jarvis er ikke at nå». Ingen popups.

Sammenfoldet: et lille hjerne-ikon med antallet, men kun når der faktisk er
kort der venter, og kun når der ikke spiller musik. Mærket har forrang for
det lille ansigt.

## (a) Forudsætninger

- **macOS 15.6 eller nyere** og **Xcode 26 eller nyere** for at bygge
  (selve appen kører fra macOS 14 Sonoma).
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

(Det er også teksten der står som blegt forslag i det tomme felt.) Tryk
**Test**: der kommer «Jarvis svarede» eller «Jarvis er ikke at nå». Så snart
adressen står der, dukker fanen «Jarvis» op i den udfoldede notch (hjerne-
ikonet). Tømmer du feltet, forsvinder både fanen, mærket og al hentning.

Vil du have Jarvis-fanen til at blive stående i stedet for at falde tilbage til
Home hver gang notchen lukker: **Settings → General** → «Remember last tab».

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
