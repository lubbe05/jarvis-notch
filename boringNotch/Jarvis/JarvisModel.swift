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
import SwiftUI

// MARK: - Svaret fra broen

struct JarvisSeneste: Codable, Hashable {
    var id: String?
    var titel: String?
    var fra: String?
    var link: String?
}

/// Én linje i `venter.liste` — et kort han kan sige ja eller nej til i hakket.
struct JarvisVenterKort: Codable, Hashable, Identifiable {
    var id: String?
    var titel: String?
    var fra: String?
    /// Kortets slags i ét dansk ord («personlig», «ai posts», «fejl» …).
    /// Til at LÆSE, ikke til at farve efter — huset kan lave nye bunker.
    var slags: String?
    /// Maskinfeltet. Falsk = vis linjen UDEN knapper (fejl-kort vil lægges i
    /// køen igen, ikke godkendes; et kort uden id kan der ikke svares på).
    var kanGodkendes: Bool?

    /// `Identifiable` skal have et id der ikke er nil.
    var raekkeId: String { id ?? (titel ?? "?") }
}

struct JarvisVenter: Codable, Hashable {
    var antal: Int?
    var ord: String?
    var seneste: JarvisSeneste?
    /// De højst fem nyeste. Mangler når intet venter.
    var liste: [JarvisVenterKort]?
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

/// Papiret der trak mest — `depot.stoerste_bevaegelse`.
struct JarvisBevaegelse: Codable, Hashable {
    var ticker: String?
    var retning: String?
    var ord: String?
}

struct JarvisDepot: Codable, Hashable {
    var vaerdiOrd: String?
    var dagsaendringOrd: String?
    var retning: String?
    /// Aktier-fanens FØRSTE linje: «Depotet er op, mest SNDK». Farves efter
    /// `retning`. Mangler ved `retning: "ukendt"` — der er intet at sige.
    var dagensOrd: String?
    var stoersteBevaegelse: JarvisBevaegelse?
    /// To sætninger huset lægger ind ved siden af. Er nøglen der, vises
    /// linjen; er den ikke, findes linjen ikke. Vi regner ikke på dem.
    var markedsvejrOrd: String?
    var kontanterOrd: String?
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

/// Det huset siger vi skal sende MED, når notchen svarer. Vi gætter ingen af
/// dem: `af` er mennesket der trykker (hele forslags-trinnet i huset hænger på
/// det navn), og `opgaveMaal` er køen en fritekst-opgave hører i — et tomt mål
/// er husets fælles pulje, altså en anden kø end den han taler til.
///
/// Mangler blokken, vises hverken knapper eller tekstfelt.
struct JarvisSkriv: Codable, Hashable {
    var af: String?
    var opgaveMaal: String?
}

/// Claudes forbrug af sit eget vindue — `claude.forbrug`.
///
/// Det ENESTE sted på hans skærme hvor der står et tal (husets regel fra 7/9 er
/// ord, ikke tal). Lauritz' egen undtagelse 18/9: et forbrug er en procentdel,
/// og «næsten opbrugt» er ikke det samme som 91. Resten står stadig i ord:
/// `vindue_ord`, `uge_ord` og de to «nulstilles»-sætninger.
///
/// `kendt: false` betyder at huset ikke kunne læse forbruget — så står der
/// «forbrug ukendt lige nu» i gråt, og der tegnes ingen ring med et gæt i.
struct JarvisForbrug: Codable, Hashable {
    var kendt: Bool?
    /// 5-timers-vinduet, 0-100. Nil når huset ikke ved det.
    var vinduePct: Int?
    var vindueOrd: String?
    /// Sekunder til vinduet nulstilles. Vi regner ikke på det; ordet er sandheden.
    var vindueNulstilles: Int?
    var vindueNulstillesOrd: String?
    var ugePct: Int?
    var ugeOrd: String?
    var ugeNulstilles: Int?
    var ugeNulstillesOrd: String?
    /// Maskinfeltet der farver ringen: «ro», «advarsel», «fare». Aldrig sætningen.
    var farve: String?
    var hentetOrd: String?

    /// Sandt kun når huset FAKTISK har læst forbruget. Mangler `kendt` helt
    /// (en ældre bro), tæller det som ukendt — vi tegner ikke et gæt.
    var erKendt: Bool { kendt == true }

    /// Andelen af en ring eller en strimmel, klemt ind i 0-1 — så en ring aldrig
    /// kan tegnes to gange rundt, hvad huset end sender. `CGFloat` og ikke
    /// `Double`, fordi det er det SwiftUI's `trim` og `frame` regner i.
    func andel(_ tal: Int?) -> CGFloat {
        guard let tal = tal else { return 0 }
        return CGFloat(min(100, max(0, tal))) / 100.0
    }

    /// Procenten som den står i ringen. Tankestreg når huset ikke ved det —
    /// en tom ring med et 0 i midten ville være et gæt.
    func pctTekst(_ tal: Int?) -> String {
        guard let tal = tal else { return "–" }
        return "\(min(100, max(0, tal)))%"
    }
}

/// Claude — byggeren i terminalen. `claude`-blokken i husets svar.
///
/// Hele pointen er ét spørgsmål: **venter han på Lauritz?** Claude står stille
/// indtil der er svaret, og et svar der først falder en time senere, er en time
/// hvor ingen bygger noget. Derfor er «venter» og «tilladelse» det notchen
/// fortæller om — og de øvrige tilstande er bare ord på en række.
///
/// Feltet kan MANGLE helt (en bro fra før 18/9). Så er tilstanden «ukendt», og
/// der vises hverken række, pop-up eller ring.
struct JarvisClaude: Codable, Hashable {
    /// «venter», «arbejder», «tilladelse» eller «ukendt».
    var tilstand: String?
    /// Sandt når det er et rigtigt spørgsmål til ham og ikke blot en pause.
    var spoerger: Bool?
    var ord: String?
    /// Det sidste Claude sagde, klippet af huset til 120 tegn.
    var sidsteOrd: String?
    /// Sekunder siden tilstanden sidst skiftede. Bruges KUN til at kende to
    /// ventetider fra hinanden; ordet er det der står på skærmen.
    var siden: Int?
    var sidenOrd: String?
    var forbrug: JarvisForbrug?
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
    var skriv: JarvisSkriv?
    var claude: JarvisClaude?
    var mangler: [String]?

    enum CodingKeys: String, CodingKey {
        case version, hentet, venter, breve, huset, depot, labs, agenter, links,
             skriv, claude, mangler
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
        skriv = try? beholder.decodeIfPresent(JarvisSkriv.self, forKey: .skriv)
        claude = try? beholder.decodeIfPresent(JarvisClaude.self, forKey: .claude)
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

// MARK: - «for 12 sekunder siden»

/// Et tidspunkt i ord, som systemet selv staver det — så linjen står på dansk på
/// en dansk Mac uden at vi bøjer noget selv. Nil når det aldrig er sket.
///
/// `nu` gives med udefra, så en visning kan tikke linjen frem hvert femte
/// sekund uden at bygge en ny formatter for hvert tik.
func jarvisForLaengeSiden(_ tid: Date?, nu: Date = Date()) -> String? {
    guard let tid = tid else { return nil }
    let ord = RelativeDateTimeFormatter()
    ord.unitsStyle = .full
    return ord.localizedString(for: tid, relativeTo: nu)
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

    // MARK: Lever løkken?
    //
    // De tre felter herunder er hele lærepengen fra 17/9 10:32-11:19, hvor der
    // stod «Jarvis er ikke at nå» i tre kvarter, mens broen svarede alle andre
    // normalt. Vi kunne ikke se om notchen spurgte og ikke fik svar, eller om
    // pollerens løkke var død — og de to ting kræver hver sin kur. Nu står
    // forskellen i ord i Indstillinger -> Jarvis:
    //
    //   `sidstForsoegt` flytter sig hvert 20. sek -> løkken lever, vejen er væk
    //   `sidstForsoegt` står stille              -> løkken er død
    //
    // Se docs/notch-poll-2026-09-18.md.

    /// Hvornår notchen sidst PRØVEDE at spørge — også når forsøget gik galt.
    @Published var sidstForsoegt: Date?
    /// Hvornår et forsøg sidst gik galt.
    @Published var sidstFejlede: Date?
    /// Hvor mange forsøg der er gået galt i træk siden huset sidst blev hørt.
    @Published var fejlIStribe: Int = 0

    // MARK: Claude — venter han på et svar?
    //
    // Claude bygger i en terminal, og han standser HELT når han spørger om lov
    // eller om en afgørelse. Et svar der først falder en time senere, er en
    // time hvor ingen bygger noget — og det er hele grunden til at notchen
    // fortæller om det. Blokken kan mangle i et ældre bro-svar; så er
    // tilstanden «ukendt», og der vises hverken række, pop-up eller ring.

    /// `claude`-blokken som huset sidst sagde den. Nil = feltet kom ikke.
    @Published var claude: JarvisClaude?
    /// Sandt mens den lille pop-up står i den LUKKEDE notch (cirka fem sekunder).
    @Published var claudePopup: Bool = false
    /// Tælles op ved hver NY ventetid. Rækken på Jarvis-fanen pulser, når
    /// tælleren er foran kvitteringen — altså når han ikke har set beskeden endnu.
    @Published var claudePuls: Int = 0
    /// Hvor langt rækken er nået med at kvittere. Står HER og ikke i visningen,
    /// fordi fanen bygges fra ny hver gang han åbner notchen på den.
    @Published var claudePulsKvitteret: Int = 0

    /// Tilstanden ved forrige svar — «venter» -> «tilladelse» er en ny besked.
    private var claudeSidsteTilstand: String = "ukendt"
    /// Det øjeblik den nuværende ventetid begyndte, regnet af husets `siden`.
    /// `siden` vokser for hvert kald, mens ankeret står stille — og netop derfor
    /// kan vi kende én ny ventetid fra den samme igen, kald efter kald.
    private var claudeAnker: Date?
    /// Nøglen for den pop-up der står lige nu, så en gammel nedtælling ikke
    /// lukker en ny pop-up.
    private var claudePopupNoegle: String?

    private init() {}

    /// Adressen fra indstillingerne, renset for blanktegn. Tom = Jarvis er slået fra.
    static var adresse: String {
        Defaults[.jarvisAdresse].trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var erSlaaetTil: Bool { !JarvisState.adresse.isEmpty }

    var venterAntal: Int { max(0, svar?.venter?.antal ?? 0) }

    // MARK: Svarene han giver fra hakket
    //
    // De tre felter herunder lever HER og ikke i visningen, fordi visningen
    // bygges om ved hvert nyt svar fra huset — og en halvskrevet
    // sætning eller en knap midt i et kald må ikke forsvinde under hænderne
    // på ham.

    /// Kort der har et kald undervejs. Rækken viser en snurre i stedet for knapper.
    @Published var besvarer: Set<String> = []
    /// Kort han HAR svaret på: id -> ordet der står i stedet for knapperne
    /// («Godkendt»/«Afvist»). Ryddes når kortet er væk af husets svar.
    @Published var besvaret: [String: String] = [:]
    /// Den ene kvitteringslinje nederst. Sættes af et svar, ryddes af næste.
    @Published var kvittering: String?
    /// Det han er ved at skrive i «Sig det til Jarvis…». Overlever et faneskift.
    @Published var udkast: String = ""

    /// Kortene han kan svare på lige nu. Tom liste = ingen.
    var venterListe: [JarvisVenterKort] { svar?.venter?.liste ?? [] }

    /// Navnet der skal med i et ja/nej. Tomt = huset ved det ikke, og så
    /// vises der ingen knapper: kunne modtageren fylde navnet ud selv, kunne
    /// en agent godkende sit eget forslag.
    var skriverNavn: String {
        (svar?.skriv?.af ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Køen en fritekst-opgave hører i, som huset staver den. Tomt = intet felt.
    var opgaveMaal: String {
        (svar?.skriv?.opgaveMaal ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var kanDoemme: Bool { !skriverNavn.isEmpty }
    var kanSkriveOpgave: Bool { !opgaveMaal.isEmpty }

    var breveAntal: Int { max(0, svar?.breve?.antal ?? 0) }

    // MARK: Claude i ord

    /// Maskinfeltet i små bogstaver. «ukendt» når blokken mangler.
    var claudeTilstand: String {
        (claude?.tilstand ?? "ukendt").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Står Claude stille og venter på ham? Kun de to tilstande er hans tur.
    var claudeVenter: Bool { claudeTilstand == "venter" || claudeTilstand == "tilladelse" }

    var claudeForbrug: JarvisForbrug? { claude?.forbrug }

    /// Skal rækken bede om et blik? Sandt indtil rækken har kvitteret, så en
    /// besked der blev misset mens notchen var lukket, stadig bliver set.
    var claudeBoerPulse: Bool { claudeVenter && claudePuls > claudePulsKvitteret }

    func kvitterClaudePuls() { claudePulsKvitteret = claudePuls }

    /// Lille mærke i den sammenfoldede notch: kun når huset faktisk venter på ham.
    ///
    /// 18/9: også når CLAUDE venter. Han står HELT stille indtil der er svaret,
    /// så det er lige så meget «huset venter på dig» som et kort i køen — og
    /// mærket er det eneste sted den lukkede notch kan sige det.
    var visKompaktMaerke: Bool {
        erSlaaetTil && fejl == nil && (venterAntal > 0 || claudeVenter)
    }

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
        let harDagens = (depot.dagensOrd?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        // Markedsvejret og kontanterne lægger andre dele af huset ind. Er DE
        // det eneste der kom, er fanen stadig værd at tegne.
        let harSide = (depot.markedsvejrOrd?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            || (depot.kontanterOrd?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        return harVaerdi || harAendring || harDagens || harSide
            || depot.naesteRegnskab != nil
    }

    func modtog(_ nyt: JarvisSvar) {
        // Den ene linje der gør et comeback læseligt i Console bagefter. Den
        // står kun når der FAKTISK var noget at komme tilbage fra.
        if fejlIStribe > 0 {
            NSLog("Jarvis: huset svarer igen efter \(fejlIStribe) mislykkede forsøg")
        }
        svar = nyt
        sidst = Date()
        fejl = nil
        fejlIStribe = 0
        // Kortet er dømt OG væk af husets svar: så skal ordet «Godkendt» også
        // væk, ellers står der en gammel kvittering på en ny liste.
        let stadigDer = Set((nyt.venter?.liste ?? []).compactMap { $0.id })
        besvaret = besvaret.filter { stadigDer.contains($0.key) }
        besvarer = besvarer.intersection(stadigDer)
        opdaterClaude(nyt.claude)
    }

    func fejlede() {
        fejl = NSLocalizedString("Jarvis can't be reached", comment: "Quiet error line in the Jarvis view")
        sidstFejlede = Date()
        fejlIStribe += 1
        // Sparsomt med vilje: de tre første, og derefter en halv time imellem.
        // En linje ved hvert kald i tre kvarter er ikke en log, det er tapet.
        if fejlIStribe <= 3 || fejlIStribe % 30 == 0 {
            NSLog("Jarvis: broen svarede ikke (\(fejlIStribe). gang i træk)")
        }
    }

    func nulstil() {
        svar = nil
        sidst = nil
        fejl = nil
        henter = false
        sidstForsoegt = nil
        sidstFejlede = nil
        fejlIStribe = 0
        besvarer = []
        besvaret = [:]
        kvittering = nil
        claude = nil
        claudePopup = false
        claudePuls = 0
        claudePulsKvitteret = 0
        claudeSidsteTilstand = "ukendt"
        claudeAnker = nil
        claudePopupNoegle = nil
    }

    /// Kvitteringen nederst — ét kort øjeblik, så den ikke bliver tapet.
    func visKvittering(_ tekst: String) {
        kvittering = tekst
        let mit = tekst
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(12))
            if self?.kvittering == mit { self?.kvittering = nil }
        }
    }

    // MARK: - Claude: er dette en NY ventetid?

    /// Kaldes ved hvert svar. Den svære del er ikke at vise en pop-up, men at
    /// vide om beskeden er NY: huset sender den samme ventetid igen hvert 20.
    /// sekund, så længe han ikke har svaret, og en pop-up der kommer tre gange
    /// i minuttet er ikke en besked, det er en alarm han slår fra.
    ///
    /// Tre ting gør en ventetid ny — og kun dem:
    ///   1. Claude ventede ikke ved forrige svar.
    ///   2. Tilstanden skiftede («venter» -> «tilladelse» er et nyt spørgsmål).
    ///   3. Ankeret rykkede mere end halvandet minut fremad, altså `siden`
    ///      sprang tilbage: et NYT spørgsmål, mens det forrige stod ubesvaret.
    private func opdaterClaude(_ nyt: JarvisClaude?) {
        claude = nyt
        let tilstand = (nyt?.tilstand ?? "ukendt")
            .trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let venter = (tilstand == "venter" || tilstand == "tilladelse")
        let forrige = claudeSidsteTilstand
        claudeSidsteTilstand = tilstand

        guard venter else {
            // Han har svaret (eller Claude gik videre selv). Så skal både
            // pop-uppen og hukommelsen om ventetiden væk, ellers er den NÆSTE
            // besked ikke ny.
            claudeAnker = nil
            claudePopupNoegle = nil
            claudePuls = 0
            claudePulsKvitteret = 0
            if claudePopup {
                withAnimation(.smooth(duration: 0.25)) { claudePopup = false }
            }
            return
        }

        let anker = Date().addingTimeInterval(-Double(max(0, nyt?.siden ?? 0)))
        var nyVentetid = (claudeAnker == nil) || (tilstand != forrige)
        if !nyVentetid, let gammel = claudeAnker, anker.timeIntervalSince(gammel) > 90 {
            nyVentetid = true
        }
        guard nyVentetid else { return }

        claudeAnker = anker
        // Rækken skal bede om et blik, uanset om pop-uppen kommer: er notchen
        // åben lige nu, er pop-uppen ikke engang tegnet.
        claudePuls += 1

        // Pop-up kun når det ER hans tur. En tilladelse spørger altid — også
        // hvis huset ikke fik sat flaget.
        guard tilstand == "tilladelse" || nyt?.spoerger == true else { return }
        visClaudePopup(noegle: tilstand + "|" + String(Int(anker.timeIntervalSince1970)))
    }

    /// Den lille pop-up i den lukkede notch. Samme mønster som `visKvittering`:
    /// en Task der lukker den igen, og nøglen afgør at det er DEN pop-up der
    /// lukkes og ikke en nyere.
    private func visClaudePopup(noegle: String) {
        claudePopupNoegle = noegle
        withAnimation(.smooth(duration: 0.25)) { claudePopup = true }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(5))
            guard let self = self, self.claudePopupNoegle == noegle, self.claudePopup else { return }
            withAnimation(.smooth(duration: 0.25)) { self.claudePopup = false }
        }
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

    /// «Åbn» på Claude-rækken.
    ///
    /// VALGET (18/9): Claude kører i en terminal inde i VS Code, og der er
    /// INTET URL-skema der kan pege på en bestemt samtale. Vi løfter derfor
    /// appen frem med præcis samme tre trin som `loeftFrem` bruger til
    /// Jarvis-appen — `unhide()`, `yieldActivation` + `activate`, og et «åbn» på
    /// processens egen bundle, fordi en editor kan køre videre uden vinduer.
    /// Bundle-id'et er slået op hos systemet (`urlForApplication`); vi kalder
    /// ALDRIG `open -b` gennem en shell, for så skulle notchen have lov til at
    /// starte processer, og det skal den ikke have for en knaps skyld.
    ///
    /// Er VS Code ikke på maskinen, falder vi tilbage til husets egen dør, så
    /// klikket aldrig dør i stilhed.
    func aabnClaude() {
        let bundleId = "com.microsoft.VSCode"
        let redning = kommandocenterLink
        if let app = NSWorkspace.shared.runningApplications.first(where: {
            $0.bundleIdentifier == bundleId
        }) {
            loeftFrem(app, redning: redning)
            return
        }
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            aabn(redning)
            return
        }
        let opsaetning = NSWorkspace.OpenConfiguration()
        opsaetning.activates = true
        NSWorkspace.shared.openApplication(at: appURL, configuration: opsaetning) { [weak self] _, fejl in
            guard fejl != nil else { return }
            Task { @MainActor in self?.aabn(redning) }
        }
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
