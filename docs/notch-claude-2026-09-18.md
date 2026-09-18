# Claude i notchen — 18. september 2026

Lauritz' bestilling: notchen skal kunne sige **at Claude står stille og venter
på et svar**, og den skal vise **hvor meget af Claudes forbrug der er brugt**.
Claude standser HELT når han spørger om lov eller om en afgørelse, så et svar
der først falder en time senere, er en time hvor ingen bygger noget. Det er
hele grunden til at det står i notchen og ikke i en skærm han skal åbne.

Intet er kompileret: der er ingen Xcode på maskinen. Alt herunder er læsning,
og GitHub Actions (`.github/workflows/jarvis_build.yml`, kun `xcodebuild build`)
er det første sted koden møder en compiler.

## 1. Kontrakten fra huset

`GET /notch` får et nyt felt, som en anden bygger leverer parallelt:

```
"claude": {"tilstand": "venter"|"arbejder"|"tilladelse"|"ukendt",
           "spoerger": Bool, "ord": String, "sidste_ord": String (<=120),
           "siden": Int?, "siden_ord": String,
           "forbrug": {"kendt": Bool, "vindue_pct": Int?, "vindue_ord": String,
                       "vindue_nulstilles": Int?, "vindue_nulstilles_ord": String,
                       "uge_pct": Int?, "uge_ord": String,
                       "uge_nulstilles": Int?, "uge_nulstilles_ord": String,
                       "farve": "ro"|"advarsel"|"fare", "hentet_ord": String}}
```

Feltet kan **mangle helt** i et ældre bro-svar. Derfor:

* `JarvisClaude` og `JarvisForbrug` (JarvisModel.swift) har **alt** som optional,
  og `claude` afkodes med sit eget `try?` i `JarvisSvar.init(from:)` som alle de
  øvrige blokke. Et felt huset laver om, kan ikke koste hele visningen.
* Mangler blokken, er `claudeTilstand` = «ukendt», `claudeVenter` = falsk, og der
  vises **hverken række, pop-up eller ring**. Ingen tom plads, intet gæt.
* Nøglerne er snake_case i JSON'en og camelCase i Swift, fordi polleren allerede
  kører med `keyDecodingStrategy = .convertFromSnakeCase` (`vindue_pct` ->
  `vinduePct`). Der er ingen håndskrevne `CodingKeys` i de to nye structs.
* `kendt: false` -> grå tom ring og husets eget ord for det (reserve:
  «forbrug ukendt lige nu»). Vi tegner **aldrig** en ring med et gæt i.

## 2. Hvor tingene sidder

### Forbruget: i toplinjen på Jarvis-fanen

`JarvisView.forbrugBlok` står i `topLinje`, **mellem badgen med antal ventende
kort og husets blok til højre**:

* en ring (`Circle().trim`) på 32 × 32 pt for 5-timers-vinduet, med procenten i
  midten, og `vindue_nulstilles_ord` i ord ved siden af (to linjer, 9 pt),
* under den en smal strimmel på 40 × 4 pt for ugen, med `uge_pct` og
  `uge_nulstilles_ord`,
* hele blokken er spændt fast på 136 pt i bredden, og `.help()` bærer alle fem
  sætninger (`vindue_ord`, `uge_ord`, de to «nulstilles» og `hentet_ord`) for den
  plads ringen ikke har.

**Procenten er det ene tal på hans skærme.** Husets regel fra 7/9 er ord og ikke
tal, men Lauritz bad 18/9 selv om procenten her, og et forbrug ER en procentdel:
«næsten opbrugt» siger ikke om han kan bygge en time mere. Alt andet i blokken er
husets egne sætninger.

**Farven er betydning, ikke pynt** (12/9): `forbrug.farve` er maskinfeltet, og
`jarvisForbrugsfarve` oversætter «ro» -> appens accent (teal), «advarsel» ->
rav, «fare» -> rød, alt andet -> grå. Sætningerne farver ingenting.

### «Claude venter på dit svar»: fast række øverst

`JarvisView.claudeRaekke` står **over** toplinjen, så længe `tilstand` er
«venter» eller «tilladelse». Ikon + husets ord + `sidste_ord` (én linje, klippet)
+ `siden_ord`, og til højre en «Åbn Claude»-knap. Stilen er kortrækkernes:
`JarvisLilleKnap`, samme farvelogik, en svag rav-baggrund og en tynd kant.

Ikonet er ikke det samme for de to tilstande: en tilladelse er `hand.raised.fill`
og et almindeligt «venter» er `exclamationmark.bubble.fill`. Han skal kunne se
forskellen uden at læse.

### Pop-uppen i den lukkede notch

`JarvisClaudeLukketKort` (nederst i JarvisView.swift) + én gren i
`ContentView.NotchLayout()` og én i `computedChinWidth`.

**Valget: det er hverken `sneakPeek` eller `InlineHUD`.**
`BoringViewCoordinator.toggleSneakPeek` (BoringViewCoordinator.swift:208-215)
returnerer med det samme for alle typer undtagen `.music`, når
`Defaults[.hudReplacement]` er slået fra — og den er slået fra som standard. En
besked der forsvinder i stilhed, fordi han ikke har tændt for husets
HUD-erstatning, er værre end ingen besked. Kortet er derfor en selvstændig
visning med sit eget ur i `JarvisState` (`claudePopup`, fem sekunder,
`Task.sleep` — samme mønster som `visKvittering`), og `ContentView` vælger den
som en gren i den lukkede notch, præcis som batteri-beskeden gør.

Fodaftrykket er bygget som batteri-beskedens: 132 pt til venstre, et sort felt
der dækker selve hullet i skærmen, 132 pt til højre. Teksten kan derfor ikke
havne bag hakket. Notchen bliver bredere af indholdet af sig selv (den lukkede
flade er ikke spændt fast på en bredde), og `computedChinWidth` får det samme mål
gennem `JarvisClaudeLukketKort.ekstraBredde()`, så hover-feltet under notchen
følger med. Teksten er 11 pt og højst to linjer: den lukkede notch er kun 32-38
pt høj, og to linjer i 11 pt er 27 pt.

Grenen står **før** musikken. En besked der venter på et svar, er vigtigere end
et albumbillede i fem sekunder — og den kommer kun når tilstanden SKIFTER.

### Det lukkede mærke

`JarvisLukketMaerke` får en rav-prik: står der kort i køen, sidder prikken som en
lille markør i kanten af tal-prikken; venter der intet kort, står rav-prikken
alene og lille. **Fodaftrykket er det samme `d × d` i begge tilfælde**, så
`ekstraBredde(lukketHoejde:)` holder, og mærket kan ikke flyde ud over notchens
eget klip (det var fejlen 16/9). Dertil er `visKompaktMaerke` udvidet, så mærket
også vises når KUN Claude venter.

### 19/9: Claude ses altid

Lauritz 19/9: **«der står ikke noget med dig i notchen».** Det var sandt. Alt
herover viser kun Claude når han VENTER — rækken, pop-uppen, rav-prikken. Sad han
og byggede i fire timer, stod der intet om ham nogen steder, og forbrugsblokken
sagde oven i købet bare «forbrug ukendt lige nu». Han kunne se at Claude var gået
i stå, men ikke at Claude var i live.

Nu bærer forbrugsblokken **Claudes eget ord om sig selv** — husets `claude.ord`,
altså «Claude arbejder», «Claude har hjælpere i gang», «Claude er klar til dig»,
«Claude er stille». Ét sted, én linje, og ordet kommer fra broen: notchen finder
aldrig selv på et ord om Claude. Kommer der intet ord (en bro fra før 18/9), står
der intet — nøjagtig som før.

`JarvisView.claudeStilleLinje` er linjen, og `claudeStilleOrd` afgør om den vises:

* **Forbruget ukendt** (`kendt: false`, eller ingen `forbrug`-blok overhovedet):
  ordet står dér hvor «forbrug ukendt lige nu» stod, ved siden af den grå tomme
  ring. Sætningen om det ukendte flytter ned i `.help()`. Den plads sagde
  alligevel ikke andet end at huset ikke vidste noget.
* **Forbruget kendt:** ring og strimmel er urørte, og ordet står som en lille
  linje OVER husets «nulstilles»-sætning, i søjlen ved siden af ringen.
* **Venter Claude:** linjen vises IKKE. Rækken øverst siger det samme, og den har
  også `sidste_ord` og «Åbn». Det samme to steder er ikke to beskeder.
  Ordet ligger stadig i `.help()`.

**Ikonet farves, teksten er grå.** `jarvisClaudeikon` og `jarvisClaudefarve` er de
samme som rækkens, så et hammer-ikon i accenten betyder det samme to steder. Men
teksten er grå og hele linjen står på 0,85 i opacity: farve er betydning (12/9),
og «Claude arbejder» er ikke noget han skal gøre noget ved. Rav — «det er din tur»
— er forbeholdt rækken øverst, og den farve kan linjen her aldrig få, fordi den
netop er skjult i de to tilstande der giver rav.

**Højden: linjen koster nul pt.** Se regnestykket i `sizing/matters.swift`. Er
forbruget ukendt, tager ordet pladsen fra en sætning der stod der i forvejen. Er
det kendt, står linjen inde i den plads ringen allerede gør rækken høj: 9 pt + 2
+ 9 pt = 24 pt tekst i en 32 pt høj række. Blokken er stadig 32 + 4 + 11 = 47 pt,
altså toplinjens egen højde, og stadig 136 pt bred.

**Prisen står ét sted, og den er lille:** «nulstilles»-sætningen ved siden af
ringen går fra to linjer til én klippet linje, så længe den stille linje står der
(`lineLimit(stilleOrd == nil ? 2 : 1)` — er linjen væk, er de to linjer tilbage
med det samme). Hele sætningen står i `.help()` sammen med de fire andre.

**Valget der blev fravalgt:** en ekstra linje UNDER ugestrimlen. Den ville have
kostet 4 + 11 = 15 pt af fanens 19 pt luft — og det ville faktisk have holdt,
fordi linjen kun vises når Claude-rækken IKKE står, så de to priser aldrig kan
lægges sammen. Men 4 pt luft tilbage på et regnestykke ingen har målt på en
skærm, er ikke en pris værd at betale for det samme ord.

Uændret: polleren, pop-uppen, det lukkede mærke, rækken øverst og
`Localizable.xcstrings` (ordet kommer fra broen, og `.help()` genbruger nøglen
«usage unknown right now» fra 18/9).

**To ting at se efter når der er en compiler:**

* «Claude har hjælpere i gang» er 26 tegn, og søjlen ved siden af ringen er
  ~83 pt bred. `minimumScaleFactor(0.75)` skrumper den til ~88 pt før den klipper,
  altså tæt på — bliver den klippet med «…», står den hel i `.help()`.
  Et kortere ord fra broen løser det helt.
* `jarvisClaudeikon` kender «venter», «tilladelse» og «arbejder». En tilstand den
  ikke kender (fx en ny «stille») får spørgsmålstegnet. Døber huset en ny
  tilstand, er det én linje i `switch`en i JarvisFaelles.swift.

## 3. Hvornår er en besked NY?

Det svære er ikke at vise en pop-up, men at vide om beskeden er ny. Huset sender
den samme ventetid igen hvert 20. sekund, så længe han ikke har svaret, og en
pop-up der kommer tre gange i minuttet er ikke en besked — det er en alarm han
slår fra.

`JarvisState.opdaterClaude()` regner et **anker** ud: `nu - siden`, altså det
øjeblik ventetiden begyndte. `siden` vokser for hvert kald, mens ankeret står
stille, og netop derfor kan to ventetider kendes fra hinanden kald efter kald.
Tre ting — og kun de tre — gør en ventetid ny:

1. Claude ventede ikke ved forrige svar.
2. Tilstanden skiftede («venter» -> «tilladelse» er et nyt spørgsmål).
3. Ankeret rykkede mere end halvandet minut fremad, altså `siden` sprang tilbage:
   et nyt spørgsmål, mens det forrige stod ubesvaret.

Er ventetiden ny, tælles `claudePuls` op. Er det **også** hans tur at svare
(`tilladelse`, eller `spoerger: true`), vises pop-uppen. Holder han op med at
vente, ryddes ankeret og tællerne, så den NÆSTE besked er ny.

**Opmærksomhedsanimationen** (2 pulser i ikonets opacity) kører når
`claudePuls > claudePulsKvitteret`, altså når rækken endnu ikke har vist
beskeden. Både `onAppear` og `onChange(of: claudePuls)` spørger. Kvitteringen
ligger i `JarvisState` og **ikke** i en `@State`, fordi fanen bygges fra ny hver
gang han åbner notchen på den (`ContentView.swift:392-395`) — en `@State` ville
pulse ved hvert kig, og det er det samme som aldrig.

## 4. Højdebudgettet

Jarvis-fanen er 780 × 340 og har 282 pt til indhold; regnestykket i
`sizing/matters.swift` gav 263 pt og **19 pt luft**. De 19 er ikke nok til
Claude-rækken, så prisen er betalt der hvor den gør mindst skade:

| | pt |
|---|---|
| Claude-rækken (24 + 8 mellemrum) | +32 |
| kortlisten viser FIRE rækker i stedet for fem | −26 |
| **i alt** | **269 -> 13 pt luft** |

De to kort der ryger, er de **ældste** (listen er sorteret med de nyeste først),
og de står stadig i Kommandocentret, som knappen nederst åbner. Skiftet sker
automatisk: `venteListe` sætter `maks = jarvis.claudeVenter ? 4 : 5`, og
`ViewThatFits` skruer selv videre ned til 3, 2 eller 1, hvis fanen alligevel
bliver for høj.

**Forbrugsringen koster ingen højde.** Den står INDE i toplinjens 47 pt (husets
tre linjer til højre er lige så høje) og er selv 47 pt: ring 32 + 4 + strimmel 11.
I bredden: badgen ~185 + 12 + ringblokken 136 + 12 + husets blok 320 = 665 af de
~706 pt fanen har indvendigt.

## 5. «Åbn Claude» — valget

Claude kører i en terminal inde i VS Code, og der er **intet URL-skema** der kan
pege på en bestemt samtale. `JarvisState.aabnClaude()` løfter derfor appen frem
med præcis de samme tre trin som `loeftFrem` bruger til Jarvis-appen: `unhide()`,
`NSApp.yieldActivation(to:)` + `activate(from:options:)`, og til sidst et «åbn»
på processens egen bundle (en editor kan køre videre uden vinduer).

Bundle-id'et `com.microsoft.VSCode` slås op hos systemet med
`NSWorkspace.urlForApplication(withBundleIdentifier:)`. Vi kalder **aldrig**
`open -b` gennem en shell: så skulle notchen have lov til at starte processer, og
det skal den ikke have for en knaps skyld. Er VS Code ikke på maskinen, falder
knappen tilbage til husets egen dør (`aabn`, altså Kommandocentret eller
Jarvis-appen efter valget i indstillingerne), så klikket aldrig dør i stilhed.

## 6. Poll-kadencen: 60 -> 20 sekunder

`JarvisPoller.sekunderMellemKald` 60 -> 20 og `mindsteSekunder` (gulvet, som både
løkken og hver opvågning spørger om lov) 30 -> 15. Grunden er netop
`claude`-blokken: et minuts forsinkelse på «Claude venter» er et minut hvor ingen
bygger noget. Svaret er under 4 kB og går til hans egen maskine, så tre kald i
minuttet er ikke en belastning nogen kan måle — kaldet varer millisekunder og
sover resten af tiden. Tålmodigheden med ét kald er urørt (15 s / 25 s i alt),
og den er stadig et godt stykke under hvilet, så to kald ikke kan overlappe.
Alle kommentarer der nævnte 60 eller 30 sekunder er rettet, i alle seks
Jarvis-filer.

## 7. Det jeg ikke kan afgøre uden en compiler

* **Bredden i toplinjen.** 665 af ~706 pt er aritmetik, ikke en måling.
  Bliver husets `venter.ord` meget længere end i dag, er det den der klemmes
  først (`minimumScaleFactor(0.8)` er der i forvejen), og derefter
  `uge_nulstilles_ord`, som er klippet med «…» med vilje.
* **Højden på Claude-rækken.** 24 pt er `JarvisLilleKnap` (10 pt tekst + 2 × 3 pt)
  plus rækkens 2 × 3 pt. Bliver den i virkeligheden 26-28, æder den de 13 pt luft,
  og så skruer `ViewThatFits` selv ned til tre kortrækker. Fladen kan derfor ikke
  vælte — `ContentView` top-justerer den også, så et uheld kun kan vælte nedad.
* **Om `siden` er sekunder.** Kontrakten siger `Int?`, og koden læser det som
  sekunder. Sender huset millisekunder, bliver ankeret forkert, og pop-uppen
  kommer for tit (regel 3 rammer ved hvert kald). Det er den ene ting der skal
  ses efter, når husets side er merget.
* **SF-symbolerne.** `hand.raised.fill` og `exclamationmark.bubble.fill` findes
  fra macOS 11. Et navn der alligevel ikke findes, tegner tomt — det bryder ikke
  bygget.

Ikke bygget, med vilje: intet nyt i Settings -> Jarvis (livstegnene fra 17/9 er
der allerede, og kadencen er husets regel og ikke en indstilling).
