//
//  JarvisPoller.swift
//  boringNotch
//
//  Henter husets ene læse-rute (GET /notch) hvert 20. sekund — aldrig
//  oftere end hvert 15. — og kun når «Jarvis-adresse» er sat i
//  indstillingerne. Skriver aldrig til broen. Fejl er stille: ingen
//  advarsler, ingen genforsøgs-storm, næste forsøg om et kvart minut.
//
//  18/9 blev kadencen 60 -> 20 sekunder og gulvet 30 -> 15. Grunden er
//  `claude`-blokken: Claude standser HELT når han spørger om lov, og et minuts
//  forsinkelse på den besked er et minut hvor ingen bygger noget. Svaret er
//  under 4 kB og går over Tailscale til hans egen maskine, så tre kald i
//  minuttet er ikke en belastning nogen kan måle — hverken på broen eller på
//  batteriet (kaldet varer millisekunder og sover resten af tiden).
//
//  17/9 10:32-11:19 stod der «Jarvis er ikke at nå» i tre kvarter, mens broen
//  svarede alle andre normalt — og broens adgangslog havde INGEN GET /notch fra
//  Mac'en i det tidsrum. Fire huller er lukket her; hele diagnosen, også det
//  der IKKE kunne afgøres, står i docs/notch-poll-2026-09-18.md.
//
//    1. `start()` kunne ikke rejse en død løkke. Den gamle vagt var
//       `guard loekke == nil`, og `loekke` bliver aldrig nil af sig selv — kun
//       `stop()` sætter den, og `stop()` kaldes ingen steder. Døde Task'en, stod
//       referencen tilbage som en attest på at alt var i orden, og hvert senere
//       `start()` — fra fanen der kom frem, fra «Test»-knappen — var et stille
//       afslag indtil appen blev genstartet. Nu følger vi om løkkens krop
//       FAKTISK kører, og løkken melder selv af i en `defer`, uanset hvordan den
//       kommer ud.
//    2. Intet vækkede løkken. Nu spørger vi med det samme når Mac'en vågner, når
//       skærmene vågner, når hans session bliver aktiv igen, og når en
//       Jarvis-fane kommer frem — altid med husets 15-sekunders-gulv foran.
//    3. Efter en fejl ventede vi et helt minut. Nu venter vi kun gulvet ud, så
//       en vej der kommer tilbage bliver fundet inden for et kvart minut.
//    4. Vi kunne ikke se bagefter om løkken levede. Nu står der tre linjer i
//       Indstillinger -> Jarvis, i ord: hvornår huset sidst blev hørt, hvornår
//       notchen sidst PRØVEDE, og hvor mange forsøg der er gået galt i træk.
//       Flytter «sidst prøvet» sig hvert 20. sekund mens der står at huset ikke
//       er at nå, så lever løkken og vejen er væk. Står den stille, er den død.
//
//  Tålmodigheden er flyttet fra 5 til 15 sekunder med vilje: vejen til huset går
//  gennem Tailscale, og efter Mac'ens søvn skal håndtrykket (og måske en
//  DERP-omvej) på plads først. 5 sekunder gjorde en langsom vej til en fejl.
//

import AppKit
import Foundation

@MainActor
final class JarvisPoller {
    static let shared = JarvisPoller()

    /// Hvileperiode mellem to kald. Gulvet på 15 sekunder er husets regel, og
    /// BÅDE løkken og en opvågning spørger det om lov (`resterendeGulv`).
    private static let sekunderMellemKald: TimeInterval = 20
    private static let mindsteSekunder: TimeInterval = 15
    /// Tålmodigheden med ét kald. Skal blive et godt stykke under hvilet, så to
    /// kald aldrig kan overlappe.
    private static let taalmodighed: TimeInterval = 15
    private static let taalmodighedIAlt: TimeInterval = 25
    /// Broen lover ≤ 2 kB; vi afviser alt der er vildt større.
    private static let stoersteSvar = 256 * 1024

    private var loekke: Task<Void, Never>?
    /// Sandt så længe løkkens krop faktisk kører. `loekke != nil` er IKKE det
    /// samme: en Task der er løbet ud eller er blevet afbrudt, bliver ikke nil
    /// af sig selv, og netop den forskel gjorde en engangsfejl permanent.
    private var koerer: Bool = false
    /// Hvor mange kald der er i luften lige nu. En opvågning springer over når
    /// der allerede er et, så et klik og en opvågning ikke bliver to kald.
    private var kaldIGang: Int = 0
    /// Vagterne på NSWorkspace. Sættes én gang og holdes, så de ikke ryger.
    private var vaegtere: [NSObjectProtocol] = []
    private let session: URLSession

    private init() {
        let opsaetning = URLSessionConfiguration.ephemeral
        opsaetning.requestCachePolicy = .reloadIgnoringLocalCacheData
        opsaetning.urlCache = nil
        opsaetning.timeoutIntervalForRequest = JarvisPoller.taalmodighed
        opsaetning.timeoutIntervalForResource = JarvisPoller.taalmodighedIAlt
        opsaetning.waitsForConnectivity = false
        opsaetning.httpShouldSetCookies = false
        opsaetning.httpAdditionalHeaders = ["Accept": "application/json"]
        session = URLSession(configuration: opsaetning)
    }

    // MARK: - Løkken

    /// Starter den stille løkke. Sikker at kalde flere gange — og rejser løkken
    /// igen hvis den er død.
    func start() {
        lytEfterOpvaagning()
        guard !koerer else { return }
        koerer = true
        loekke = Task { @MainActor in
            // Uanset HVORDAN vi kommer ud herfra — afbrydelse, eller noget
            // ingen har set endnu — skal det stå skrevet at løkken ikke kører
            // mere. Ellers kan den næste `start()` ikke rejse den.
            defer {
                JarvisPoller.shared.koerer = false
                JarvisPoller.shared.loekke = nil
            }
            while !Task.isCancelled {
                // Gulvet kan være brugt af en opvågning eller af «Test»-knappen
                // lige før. Så venter vi resten af det ud først.
                let gulv = JarvisPoller.shared.resterendeGulv
                if gulv > 0 {
                    do {
                        try await Task.sleep(for: .seconds(gulv))
                    } catch {
                        if Task.isCancelled { break }
                    }
                    if Task.isCancelled { break }
                }

                // `hentEnGang()` kaster ikke — den har do/catch om hele kroppen
                // — og det skal den blive ved med ikke at gøre.
                let svarede = await JarvisPoller.shared.hentEnGang()
                if Task.isCancelled { break }

                // Efter en fejl venter vi kun gulvet ud, så en vej der kommer
                // tilbage bliver fundet inden for et kvart minut i stedet for et.
                // En TOM adresse er derimod ingen fejl — Jarvis er slået fra, og
                // så er der intet at skynde sig med.
                let hvile = (svarede || !JarvisState.shared.erSlaaetTil)
                    ? max(JarvisPoller.mindsteSekunder, JarvisPoller.sekunderMellemKald)
                    : JarvisPoller.mindsteSekunder
                do {
                    try await Task.sleep(for: .seconds(hvile))
                } catch {
                    // Kun en afbrydelse kan kaste her. Er vi ikke afbrudt, så
                    // kører vi videre: et dårligt hvil må ikke koste løkken.
                    if Task.isCancelled { break }
                }
            }
        }
    }

    /// Den ene vej ud. Kaldes ikke af noget i dag; den står her, så der ER en.
    func stop() {
        loekke?.cancel()
        loekke = nil
        koerer = false
    }

    /// «Spørg nu.» Mac'en er vågnet, skærmene er tændt, hans session er tilbage,
    /// eller en Jarvis-fane er kommet frem. Tre ting, i den rækkefølge:
    ///
    ///   1. Rejs løkken hvis den ikke kører. En frisk løkke spørger med det
    ///      samme, så der er ikke mere at gøre.
    ///   2. Ellers: spring over hvis et kald allerede er i luften.
    ///   3. Ellers: spørg NU — men kun hvis gulvet er overholdt. En opvågning må
    ///      ikke være en bagdør rundt om husets 15-sekunders-regel.
    func vaekOp() {
        guard koerer else {
            start()
            return
        }
        guard kaldIGang == 0, resterendeGulv <= 0 else { return }
        Task { @MainActor in
            // `_ =` med vilje: ellers bliver den ene-udtryks-lukning en
            // Task<Bool, Never>, og svaret her er ingens svar — det står i
            // JarvisState bagefter.
            _ = await JarvisPoller.shared.hentEnGang()
        }
    }

    /// Sekunder til næste kald er tilladt. 0 betyder «spørg bare».
    private var resterendeGulv: TimeInterval {
        let sidst = JarvisState.shared.sidstForsoegt ?? Date.distantPast
        return max(0, JarvisPoller.mindsteSekunder - Date().timeIntervalSince(sidst))
    }

    /// Vagterne der siger «spørg nu». Tre begivenheder, fordi de tre ting sker
    /// hver for sig: maskinen kan vågne uden at skærmene tændes, skærmene kan
    /// tændes uden at maskinen har sovet, og hans session kan komme tilbage
    /// efter et brugerskift. Alle tre er øjeblikke hvor vejen til huset netop
    /// kan være kommet tilbage.
    private func lytEfterOpvaagning() {
        guard vaegtere.isEmpty else { return }
        let center = NSWorkspace.shared.notificationCenter
        let navne: [NSNotification.Name] = [
            NSWorkspace.didWakeNotification,
            NSWorkspace.screensDidWakeNotification,
            NSWorkspace.sessionDidBecomeActiveNotification,
        ]
        for navn in navne {
            let vagt = center.addObserver(forName: navn, object: nil, queue: .main) { _ in
                // Vi rører ingen tilstand herinde: alt går ind på hovedtråden
                // gennem den ene dør.
                Task { @MainActor in
                    JarvisPoller.shared.vaekOp()
                }
            }
            vaegtere.append(vagt)
        }
    }

    // MARK: - Ét kald

    /// Ét kald. Returnerer sandt når broen svarede — bruges af «Test»-knappen.
    /// Der er med vilje ingen gulv-vagt her: trykker han på «Test», skal der
    /// spørges, og et svar skal være hans svar og ikke en overspringelse.
    @discardableResult
    func hentEnGang() async -> Bool {
        let state = JarvisState.shared
        let adresse = JarvisState.adresse

        guard !adresse.isEmpty else {
            // Jarvis er slået fra. Ryd kun hvis der ER noget at rydde: ellers
            // sender vi en ændring til hver Jarvis-visning ved hvert kald for
            // ingenting, og @Published spørger ikke om værdien blev anderledes.
            if state.svar != nil || state.fejl != nil || state.sidst != nil {
                state.nulstil()
            }
            return false
        }
        guard let url = URL(string: adresse),
              let skema = url.scheme?.lowercased(),
              skema == "http" || skema == "https",
              url.host != nil
        else {
            state.fejlede()
            return false
        }

        var foresporgsel = URLRequest(url: url)
        foresporgsel.httpMethod = "GET"
        foresporgsel.timeoutInterval = JarvisPoller.taalmodighed
        foresporgsel.cachePolicy = .reloadIgnoringLocalCacheData

        // Stemplet der siger at løkken lever. Det sættes FØR kaldet og også når
        // kaldet går galt — det er hele forskellen på «huset er væk» og
        // «løkken er død», og den forskel manglede vi den 17/9.
        state.sidstForsoegt = Date()
        kaldIGang += 1
        state.henter = true
        defer {
            kaldIGang -= 1
            state.henter = kaldIGang > 0
        }

        do {
            let (data, svar) = try await session.data(for: foresporgsel)
            guard let http = svar as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                state.fejlede()
                return false
            }
            guard data.count <= JarvisPoller.stoersteSvar else {
                state.fejlede()
                return false
            }
            let afkoder = JSONDecoder()
            afkoder.keyDecodingStrategy = .convertFromSnakeCase
            let nyt = try afkoder.decode(JarvisSvar.self, from: data)
            state.modtog(nyt)
            return true
        } catch {
            state.fejlede()
            return false
        }
    }
}
