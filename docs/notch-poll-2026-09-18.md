# «Kan ikke nå hjernen» 17/9 10:32–11:19 — hvad koden faktisk kan udvise

Dato: 18. september 2026. Læst: `boringNotch/Jarvis/JarvisPoller.swift`,
`JarvisModel.swift`, `JarvisFaelles.swift`, `JarvisView.swift`,
`JarvisAktierView.swift`, `JarvisSettingsView.swift`, `JarvisSkriver.swift`,
`boringNotchApp.swift`, `ContentView.swift`, `boringNotch/Info.plist`,
`boringNotch.xcodeproj/project.pbxproj`.

Intet er kompileret: der er ingen Xcode på maskinen. Alt herunder er læsning.

## 1. Sådan hænger det sammen i dag (før rettelsen)

* Løkken ejes af `JarvisPoller.shared` — én global, `@MainActor`.
  `JarvisPoller.swift:23` holder `loekke: Task<Void, Never>?`.
* Den startes ét sted rigtigt: `boringNotchApp.swift:426`, inde i
  `applicationDidFinishLaunching` (synkront, hovedtråden, ikke inde i en Task).
* Den startes to steder mere: `JarvisFaelles.swift:47` (`JarvisRamme.onAppear`,
  altså hver gang en Jarvis-fane kommer frem i den åbne notch — `ContentView.swift:385-395`
  bygger `JarvisView`/`JarvisAktierView` fra ny hver gang) og
  `JarvisSettingsView.swift:183` efter et grønt «Test».
* `stop()` (`JarvisPoller.swift:50`) kaldes **ingen steder**. Grep over hele
  træet giver kun definitionen. Løkken cancelleres altså ikke af at en view
  forsvinder, af faneskift eller af at notchen lukkes.
* URLSession: `URLSessionConfiguration.ephemeral` med
  `timeoutIntervalForRequest = 5`, `timeoutIntervalForResource = 8`,
  `waitsForConnectivity = false` (`JarvisPoller.swift:27-35`) og dertil
  `foresporgsel.timeoutInterval = 5` (`:76`).
* «Kan ikke nå hjernen» er `JarvisState.fejl`, sat i `fejlede()`
  (`JarvisModel.swift:344-346`) og **ryddet i `modtog()`** (`JarvisModel.swift:336`).
  Visningen læser den i `JarvisFaelles.swift:36`.

## 2. Hypoteserne, én for én

### (a) Løkken dør eller hænger — DELVIST

**Hænger: nej, det kan koden ikke.** Der ER timeout på kaldet
(`JarvisPoller.swift:30-31` og `:76`). Et kald der ikke kommer igennem, giver op
efter 5–8 sekunder. Et hængende URLSession-kald kan altså ikke forklare 47
minutters stilhed. Hypotesen om «URLSession-kald uden timeout» holder ikke.

**Dør af en `try` der kaster ud af while-løkken: nej.** `hentEnGang()` har
`do/catch` om hele kroppen (`:82-100`) og kaster ikke. `Task.sleep` er `try?`
(`:45`). Der er ingen `try` i løkkens krop der kan slippe ud.

**Men: hvis løkken ALLIGEVEL dør, kan den ikke rejses igen.** Det er en rigtig
fejl, og den er beviselig: `start()` (`JarvisPoller.swift:40`) står på
`guard loekke == nil else { return }`, og `loekke` bliver **aldrig** nil af sig
selv — kun `stop()` sætter den, og `stop()` kaldes ingen steder. Bliver Task'en
afbrudt eller løber den ud (uanset hvorfor), står `loekke` som en død reference,
og hvert senere `start()` — fra fanen der kommer frem, fra «Test»-knappen — er et
stille afslag. Det er den mekanisme der gør en engangsfejl permanent indtil
appen genstartes. **Det passer på «kl. 11:19 virkede det igen af sig selv»,
hvis han genstartede appen.**

### (b) Fejlordet ryddes aldrig — NEJ

`modtog()` sætter `fejl = nil` (`JarvisModel.swift:336`). Ét vellykket svar
rydder ordet. `JarvisSkriver` (godkend/afvis/opgave) rører aldrig `fejl` — den
skriver kun i `kvittering`. Hypotesen holder ikke.

Der ER dog noget skævt i nærheden, som jeg med vilje **ikke** har rettet:
`JarvisFaelles.swift:36` viser fejllinjen FØR den ser på `jarvis.svar`, så ét
enkelt mislykket kald skifter hele fladen til «Jarvis er ikke at nå», også når
der ligger et godt svar i cachen fra et minut siden. Det er forsvarligt (vi
viser ikke gamle tal som om de var friske) og det er hans skærm, ikke min
beslutning. Men det betyder at ét tabt kald ser lige så slemt ud som et dødt
hus — og at han derfor ikke kunne se forskellen den 17/9.

### (c) Efter søvn starter løkken ikke igen — JA, det er hullet

* Der er **ingen** `NSWorkspace.didWakeNotification` nogen steder i træet
  (grep på `didWakeNotification|willSleepNotification|NSWorkspace.shared.notificationCenter`
  giver kun to træf i `YouTubeMusicController.swift`, om start/stop af en app).
  Ingen del af appen gør noget når Mac'en vågner.
* Løkkens eneste ur er `Task.sleep(for: .seconds(60))`. Hverken opvågning,
  netværksskift eller at notchen åbnes fremskynder næste kald. Kommer vejen
  til huset tilbage 5 sekunder efter et mislykket forsøg, står der «Jarvis er
  ikke at nå» i 55 sekunder mere.
* `INFOPLIST_KEY_LSUIElement = YES` (`project.pbxproj:1244,1297`) — appen er en
  baggrundsagent uden Dock-ikon, og der er **intet** `ProcessInfo.beginActivity`
  og intet `NSAppSleepDisabled` i træet. Den er altså App Nap-berettiget, og
  App Nap udskyder netop Dispatch-timere i minutter. Det er den eneste mekanisme
  jeg kan finde der forklarer «broens adgangslog har INGEN GET /notch i 47
  minutter» uden at løkken er død. **Men jeg kan ikke bevise den af koden** —
  kun at intet i koden forhindrer den.

## 3. Hvad der IKKE kan afgøres uden logs fra Mac'en

1. **Broens adgangslog kan ikke skelne «notchen spurgte ikke» fra «notchen
   spurgte, men pakkerne nåede aldrig frem».** Var Tailscale-vejen væk
   10:32–11:19, står der ingenting i loggen i begge tilfælde. Den mest kedelige
   forklaring er derfor stadig: vejen var væk, appen opførte sig korrekt, og
   den kom selv tilbage. Det udelukker intet af ovenstående — men det betyder at
   vi ikke ved om løkken levede.
2. Om han genstartede appen kl. 11:19. Gjorde han det, peger det på (a)-hullet
   (død løkke der ikke kan rejses). Gjorde han det ikke, peger det på en vej
   der kom tilbage — eller på App Nap der slap taget da han rørte maskinen.
3. Om Mac'en faktisk sov i tidsrummet, og om hovedtråden var blokeret af noget
   andet i appen (så ville løkken også stå stille, og det kan ingen kode her
   afvise).

Punkt 4 i rettelsen findes netop for at lukke 1–3 **næste gang**: tre linjer i
Indstillinger → Jarvis der siger hvornår huset sidst blev hørt, hvornår notchen
sidst PRØVEDE, og hvor mange forsøg der er gået galt i træk. Flytter «sidst
prøvet» sig hvert minut mens der står «Jarvis er ikke at nå», så lever løkken og
vejen er væk. Står den stille, er løkken død. Det er forskellen vi manglede.

## 4. Hvad der er rettet (og hvad der ikke er)

Rettet:

1. `start()` kan rejse en død løkke. Vagten er flyttet fra «har jeg en
   Task-reference» til «kører løkkens krop faktisk», og løkken melder selv af i
   en `defer`, uanset hvordan den kommer ud.
2. Hele iterationen kan ikke dø: `Task.sleep` fortsætter i stedet for at bryde
   ud, hvis den kaster af andet end en afbrydelse.
3. «Spørg nu» ved `NSWorkspace.didWakeNotification`,
   `screensDidWakeNotification` og `sessionDidBecomeActiveNotification`, og når
   en Jarvis-fane kommer frem. Altid med husets 30-sekunders-gulv foran — både
   løkken og opvågningen spørger det samme gulv om lov, så vækningen ikke bliver
   en bagdør rundt om reglen.
4. Efter en fejl venter løkken kun gulvet (30 s) og ikke et helt minut, så en vej
   der kommer tilbage bliver fundet dobbelt så hurtigt.
5. Tålmodigheden med ét kald er 5 → 15 sekunder (25 i alt). 5 sekunder gør en
   langsom Tailscale-vej — et håndtryk eller en DERP-omvej efter søvn — til en
   fejl. 25 sekunder er stadig et godt stykke under hvilet, så to kald aldrig
   kan overlappe.
6. Tre linjer i ord i Indstillinger → Jarvis, og `NSLog` ved hver ny fejlstribe
   og ved hvert comeback. Linjerne tikker hvert femte sekund, så han kan SE om
   «Notchen spurgte sidst» bevæger sig. Der står ingen optælling på skærmen
   (husets regel: ord, ikke tal) — antallet lever i Console-loggen.
7. To små ting der faldt ud af (4): en TOM adresse tæller ikke som en fejl, så
   løkken ikke begynder at spinde hvert halve minut når Jarvis er slået fra; og
   `nulstil()` kaldes kun når der faktisk ER noget at rydde, så en slukket Jarvis
   ikke sender en ændring til hver visning hvert minut for ingenting.
8. De fem nye sætninger er lagt i `Localizable.xcstrings` på dansk under `da`,
   `en` og `en-GB` — samme mønster som de øvrige Jarvis-linjer, så skærmen står
   på dansk uanset systemets sprog.

IKKE rettet, med vilje:

* **App Nap.** Et `ProcessInfo.beginActivity(options: .userInitiated, ...)`-hold
  ville forhindre at systemet udskyder løkkens timer — men det er en assertion
  der gælder hele appen og koster batteri, og jeg kan ikke bevise at App Nap var
  årsagen. De tre linjer i indstillingerne afgør det næste gang: er «sidst
  prøvet» meget ældre end et minut mens løkken er i live, så ER det timeren der
  bliver holdt tilbage, og så er `beginActivity` kuren.
* Rækkefølgen i `JarvisFaelles.swift:36` (fejl før cache), se (b).
* `stop()` bliver stadig ikke kaldt. Den skal ikke kaldes; den står som den
  ene vej ud hvis der en dag skal være en.
