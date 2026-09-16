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

    /// Den ene dør ud af notchen. Alle klikbare rækker i Jarvis-fanen går
    /// herigennem, så valget i indstillingerne gælder overalt.
    ///
    /// Ved valget «Jarvis-appen på denne Mac»:
    ///   1. kører den allerede → løft den frem (ingen browser overhovedet)
    ///   2. ellers: find den på disken og start den
    ///   3. lykkes intet → fald tilbage til web-linket, så klikket aldrig dør i stilhed.
    ///
    /// Et bestemt kort kan kun åbnes i web-appen; appen har intet URL-skema,
    /// så vi løfter den blot frem.
    func aabn(_ link: URL?) {
        guard Defaults[.jarvisAabnI] == .app else {
            aabnWeb(link)
            return
        }
        let navn = Defaults[.jarvisAppNavn].trimmingCharacters(in: .whitespacesAndNewlines)
        guard !navn.isEmpty else {
            aabnWeb(link)
            return
        }
        if loeftFremHvisKoerende(navn) { return }
        guard let appURL = findAppPaaDisken(navn) else {
            aabnWeb(link)
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

    /// Sandt hvis en kørende app matcher navnet (eller bundle-id'et) og blev løftet frem.
    private func loeftFremHvisKoerende(_ navn: String) -> Bool {
        let soegt = navn.lowercased()
        let koerende = NSWorkspace.shared.runningApplications
        let fundet =
            koerende.first { ($0.localizedName ?? "").lowercased() == soegt }
            ?? koerende.first { ($0.bundleIdentifier ?? "").lowercased() == soegt }
            ?? koerende.first { app in
                guard app.activationPolicy == .regular else { return false }
                return (app.localizedName ?? "").lowercased().contains(soegt)
                    || (app.bundleIdentifier ?? "").lowercased().contains(soegt)
            }
        guard let app = fundet else { return false }
        return app.activate(options: [.activateAllWindows])
    }

    /// Leder efter appen på disken: først som bundle-id, så som navn i de to Programmer-mapper.
    private func findAppPaaDisken(_ navn: String) -> URL? {
        if navn.contains("."),
           let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: navn)
        {
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
