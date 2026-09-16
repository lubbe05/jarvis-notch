//
//  JarvisModel.swift
//  boringNotch
//
//  Jarvis: Lauritz' eget agenthus. Modellen for svaret fra husets bro
//  (GET /notch — læse-eneste JSON, ≤ 2 kB). Alle felter kan mangle, så
//  alt er optional og afkodningen giver op i stilhed felt for felt.
//

import AppKit
import Defaults
import Foundation

// MARK: - Svaret fra broen

struct JarvisSeneste: Codable, Hashable {
    var id: String?
    var titel: String?
    var fra: String?
    var link: String?
}

struct JarvisVenter: Codable, Hashable {
    var antal: Int?
    var ord: String?
    var seneste: JarvisSeneste?
}

struct JarvisBreve: Codable, Hashable {
    var antal: Int?
    var ord: String?
}

struct JarvisHuset: Codable, Hashable {
    var tilstand: String?
    var ord: String?
    var seneste: String?
    var hvornaar: String?
}

struct JarvisRegnskab: Codable, Hashable {
    var ticker: String?
    var navn: String?
    var datoOrd: String?
    var foreloebig: Bool?
}

struct JarvisDepot: Codable, Hashable {
    var vaerdiOrd: String?
    var dagsaendringOrd: String?
    var retning: String?
    var naesteRegnskab: JarvisRegnskab?
}

struct JarvisLabs: Codable, Hashable {
    var ord: String?
}

struct JarvisAgent: Codable, Hashable, Identifiable {
    var navn: String?
    var tilstand: String?
    var ord: String?

    /// Ikke en del af JSON'en; kun til ForEach.
    var id: String { (navn ?? "?") + "|" + (tilstand ?? "?") }
}

struct JarvisLinks: Codable, Hashable {
    var app: String?
    var kommandocenter: String?
    var investor: String?
}

/// Hele svaret. Hvert felt afkodes for sig med `try?`, så et enkelt felt
/// broen har ændret aldrig kan koste hele visningen.
struct JarvisSvar: Codable {
    var version: Int?
    var hentet: String?
    var venter: JarvisVenter?
    var breve: JarvisBreve?
    var huset: JarvisHuset?
    var depot: JarvisDepot?
    var labs: JarvisLabs?
    var agenter: [JarvisAgent]?
    var links: JarvisLinks?
    var mangler: [String]?

    enum CodingKeys: String, CodingKey {
        case version, hentet, venter, breve, huset, depot, labs, agenter, links, mangler
    }

    init() {}

    init(from decoder: Decoder) throws {
        let beholder = try decoder.container(keyedBy: CodingKeys.self)
        version = try? beholder.decodeIfPresent(Int.self, forKey: .version)
        hentet = try? beholder.decodeIfPresent(String.self, forKey: .hentet)
        venter = try? beholder.decodeIfPresent(JarvisVenter.self, forKey: .venter)
        breve = try? beholder.decodeIfPresent(JarvisBreve.self, forKey: .breve)
        huset = try? beholder.decodeIfPresent(JarvisHuset.self, forKey: .huset)
        depot = try? beholder.decodeIfPresent(JarvisDepot.self, forKey: .depot)
        labs = try? beholder.decodeIfPresent(JarvisLabs.self, forKey: .labs)
        agenter = try? beholder.decodeIfPresent([JarvisAgent].self, forKey: .agenter)
        links = try? beholder.decodeIfPresent(JarvisLinks.self, forKey: .links)
        mangler = try? beholder.decodeIfPresent([String].self, forKey: .mangler)
    }
}

// MARK: - Hvilken app på Mac'en er «Jarvis»?
//
// Det står UDEN FOR JarvisState med vilje: indstillingernes vælger skal kunne
// spørge uden at gå gennem hovedtråd-isolationen, og der er ingen tilstand at
// beskytte — vi læser kun NSWorkspace og Defaults.

/// En app der kører lige nu, som han kan vælge i indstillingerne.
struct JarvisKoerendeApp: Identifiable, Hashable {
    /// Bundle-id'et — og listens id, så to vinduer af samme app kun fylder én linje.
    let id: String
    let navn: String
    let sti: String

    var etiket: String { id.isEmpty ? navn : "\(navn) — \(id)" }
}

/// Alle almindelige apps der kører lige nu, sorteret efter navn.
/// `.regular` sorterer baggrundsagenter og hjælpeprocesser fra — kun
/// programmer med et ikon i Docken bliver tilbage.
func jarvisKoerendeApps() -> [JarvisKoerendeApp] {
    var fundet: [String: JarvisKoerendeApp] = [:]
    for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular {
        guard let id = app.bundleIdentifier, !id.isEmpty, fundet[id] == nil else { continue }
        fundet[id] = JarvisKoerendeApp(
            id: id,
            navn: app.localizedName ?? id,
            sti: app.bundleURL?.path ?? ""
        )
    }
    return fundet.values.sorted {
        $0.navn.localizedStandardCompare($1.navn) == .orderedAscending
    }
}

/// Sandt hvis den valgte app kører lige nu. Linjen «Kører lige nu: ja/nej»
/// i indstillingerne står på denne, så han kan SE at matchet virker,
/// i stedet for at gætte efter et klik.
var jarvisValgtAppKoerer: Bool { jarvisValgtKoerendeApp() != nil }

/// Den kørende proces han mener. Rækkefølgen er med vilje:
///
///   1. **bundle-id** fra vælgeren — det eneste sikre match. Det følger
///      processen og er uafhængigt af hvad appen kalder sig på skærmen.
///   2. **stien** (bundleURL) fra vælgeren, hvis id'et skulle være skiftet.
///   3. **navnet** fra tekstfeltet — manuel reserve, og kun det.
///
/// Lauritz 16/9 (skærmoptagelse): hans Jarvis-app er en Flet-desktop-klient.
/// Processens `localizedName` er «Flet»; kun VINDUET hedder «Jarvis», og det
/// kan systemet ikke se. Navnematchet ramte derfor aldrig den kørende app, og
/// notchen startede en ny kopi fra `/Applications`. Bundle-id'et er kuren.
func jarvisValgtKoerendeApp() -> NSRunningApplication? {
    let koerende = NSWorkspace.shared.runningApplications

    let valgtId = Defaults[.jarvisAppBundleId].trimmingCharacters(in: .whitespacesAndNewlines)
    if !valgtId.isEmpty, let app = koerende.first(where: { $0.bundleIdentifier == valgtId }) {
        return app
    }

    let valgtSti = Defaults[.jarvisAppSti].trimmingCharacters(in: .whitespacesAndNewlines)
    if !valgtSti.isEmpty {
        let sti = URL(fileURLWithPath: valgtSti).standardizedFileURL.path
        if let app = koerende.first(where: { $0.bundleURL?.standardizedFileURL.path == sti }) {
            return app
        }
    }

    let navn = Defaults[.jarvisAppNavn].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !navn.isEmpty else { return nil }
    return koerende.first { ($0.localizedName ?? "").lowercased() == navn }
        ?? koerende.first { ($0.bundleIdentifier ?? "").lowercased() == navn }
        ?? koerende.first { app in
            guard app.activationPolicy == .regular else { return false }
            return (app.localizedName ?? "").lowercased().contains(navn)
                || (app.bundleIdentifier ?? "").lowercased().contains(navn)
        }
}

// MARK: - Tilstanden i appen

@MainActor
final class JarvisState: ObservableObject {
    static let shared = JarvisState()

    /// Seneste svar fra broen (nil indtil første svar).
    @Published var svar: JarvisSvar?
    /// Hvornår svaret kom.
    @Published var sidst: Date?
    /// Sat når broen ikke kunne nås — teksten Lauritz ser er «Jarvis er ikke at nå».
    @Published var fejl: String?
    /// Sandt mens et kald er undervejs.
    @Published var henter: Bool = false

    private init() {}

    /// Adressen fra indstillingerne, renset for blanktegn. Tom = Jarvis er slået fra.
    static var adresse: String {
        Defaults[.jarvisAdresse].trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var erSlaaetTil: Bool { !JarvisState.adresse.isEmpty }

    var venterAntal: Int { max(0, svar?.venter?.antal ?? 0) }

    var breveAntal: Int { max(0, svar?.breve?.antal ?? 0) }

    /// Lille mærke i den sammenfoldede notch: kun når huset faktisk venter på ham.
    var visKompaktMaerke: Bool { erSlaaetTil && fejl == nil && venterAntal > 0 }

    /// Linket der åbnes når han klikker på det seneste kort — ellers kommandocentret.
    var senesteLink: URL? {
        if let tekst = svar?.venter?.seneste?.link, let url = URL(string: tekst) { return url }
        return kommandocenterLink
    }

    var kommandocenterLink: URL? {
        if let tekst = svar?.links?.kommandocenter, let url = URL(string: tekst) { return url }
        if let tekst = svar?.links?.app, let url = URL(string: tekst) { return url }
        return nil
    }

    /// Investor-skærmen. Kommer altid med i svaret (`links.investor`); vi bygger
    /// den aldrig selv. Mangler `links` helt, står Aktier-fanen uden knap.
    var investorLink: URL? {
        if let tekst = svar?.links?.investor, let url = URL(string: tekst) { return url }
        if let tekst = svar?.links?.app, let url = URL(string: tekst) { return url }
        return nil
    }

    /// Sandt når huset slet ikke har noget at fortælle om depotet.
    var harDepotNoget: Bool {
        guard let depot = svar?.depot else { return false }
        let harVaerdi = (depot.vaerdiOrd?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        let harAendring = (depot.dagsaendringOrd?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        return harVaerdi || harAendring || depot.naesteRegnskab != nil
    }

    func modtog(_ nyt: JarvisSvar) {
        svar = nyt
        sidst = Date()
        fejl = nil
    }

    func fejlede() {
        fejl = NSLocalizedString("Jarvis can't be reached", comment: "Quiet error line in the Jarvis view")
    }

    func nulstil() {
        svar = nil
        sidst = nil
        fejl = nil
        henter = false
    }

    // MARK: - Åbning: appen på Mac'en eller web-appen

    /// Den ene dør ud af notchen. Alle klikbare rækker og begge fanes knapper
    /// går herigennem, så «Åbn i»-valget i indstillingerne gælder overalt.
    ///
    /// Ved valget «Jarvis-appen på denne Mac»:
    ///   1. kører den allerede → løft den frem. **Der startes aldrig en ny kopi,
    ///      når en proces med samme bundle-id kører.**
    ///   2. kører den ikke → start den fra den sti/det id vælgeren gemte
    ///      (ellers fra navnet).
    ///   3. lykkes intet → fald tilbage til web-linket, så klikket aldrig dør i stilhed.
    ///
    /// Et bestemt kort kan kun åbnes i web-appen; appen har intet URL-skema,
    /// så vi løfter den blot frem.
    func aabn(_ link: URL?) {
        guard Defaults[.jarvisAabnI] == .app else {
            aabnWeb(link)
            return
        }

        // 1.
        if let app = jarvisValgtKoerendeApp() {
            loeftFrem(app, redning: link)
            return
        }

        // 2.
        guard let appURL = jarvisAppPaaDisken() else {
            aabnWeb(link)
            return
        }
        // Sidste værn mod dobbeltgængeren: kører der allerede en proces fra
        // præcis den bundle, løfter vi DEN frem i stedet for at starte en ny.
        let sti = appURL.standardizedFileURL.path
        if let koerer = NSWorkspace.shared.runningApplications.first(where: {
            $0.bundleURL?.standardizedFileURL.path == sti
        }) {
            loeftFrem(koerer, redning: link)
            return
        }
        let opsaetning = NSWorkspace.OpenConfiguration()
        opsaetning.activates = true
        NSWorkspace.shared.openApplication(at: appURL, configuration: opsaetning) { [weak self] _, fejl in
            guard fejl != nil else { return }
            Task { @MainActor in self?.aabnWeb(link) }
        }
    }

    private func aabnWeb(_ link: URL?) {
        guard let link = link else { return }
        NSWorkspace.shared.open(link)
    }

    /// Løfter en app der ALLEREDE kører frem.
    ///
    /// Lauritz 16/9: «hvis Jarvis-appen allerede kører, skal den smides foran
    /// når jeg klikker på Kommandocenter-tingen i notchen». `activate(options:)`
    /// alene bliver afvist af macOS 14+, når den app der beder om løftet
    /// (boringNotch) ikke selv står forrest — og notchen står aldrig forrest:
    /// den er en baggrundsagent uden fokus. Derfor tre trin:
    ///
    ///   1. `unhide()` — appen kan være skjult (⌘H) eller minimeret, og så er
    ///      der ikke noget at aktivere.
    ///   2. `NSApp.yieldActivation(to:)` + `activate(from:options:)` — vi giver
    ///      vores EGEN aktivering væk først, og så accepterer systemet løftet.
    ///      (Begge dele findes fra macOS 14, og projektets mindste system er
    ///      netop macOS 14.0, så der er intet at falde tilbage på.)
    ///   3. `NSWorkspace.openApplication` på **processens egen** `bundleURL` —
    ///      en app kan køre videre uden ét eneste vindue (det gør Flet- og
    ///      web-klienter tit, når man har lukket vinduet med ⌘W), og så hjælper
    ///      aktivering ikke. Et «åbn» på den bundle processen allerede kører fra
    ///      giver vinduet tilbage og starter ingen ny kopi.
    ///
    /// Lykkes hverken 2 eller 3, åbnes web-linket.
    private func loeftFrem(_ app: NSRunningApplication, redning link: URL?) {
        // 1.
        _ = app.unhide()

        // 2.
        NSApp.yieldActivation(to: app)
        let loeftet = app.activate(from: NSRunningApplication.current, options: [.activateAllWindows])

        // 3.
        guard let bundle = app.bundleURL else {
            if !loeftet { aabnWeb(link) }
            return
        }
        let opsaetning = NSWorkspace.OpenConfiguration()
        opsaetning.activates = true
        NSWorkspace.shared.openApplication(at: bundle, configuration: opsaetning) { [weak self] koerer, fejl in
            guard fejl != nil || koerer == nil else { return }
            guard !loeftet else { return }
            Task { @MainActor in self?.aabnWeb(link) }
        }
    }

    /// Hvor appen ligger, når den IKKE kører. Samme rækkefølge som matchet:
    /// vælgerens sti, vælgerens bundle-id, og til sidst navnet i tekstfeltet.
    private func jarvisAppPaaDisken() -> URL? {
        let sti = Defaults[.jarvisAppSti].trimmingCharacters(in: .whitespacesAndNewlines)
        if !sti.isEmpty, FileManager.default.fileExists(atPath: sti) {
            return URL(fileURLWithPath: sti)
        }
        let id = Defaults[.jarvisAppBundleId].trimmingCharacters(in: .whitespacesAndNewlines)
        if !id.isEmpty, let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id) {
            return url
        }
        let navn = Defaults[.jarvisAppNavn].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !navn.isEmpty else { return nil }
        if navn.contains("."), let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: navn) {
            return url
        }
        let filnavn = navn.hasSuffix(".app") ? navn : navn + ".app"
        var steder = [URL(fileURLWithPath: "/Applications").appendingPathComponent(filnavn)]
        if let hjem = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first {
            steder.append(hjem.appendingPathComponent(filnavn))
        }
        return steder.first { FileManager.default.fileExists(atPath: $0.path) }
    }
}
