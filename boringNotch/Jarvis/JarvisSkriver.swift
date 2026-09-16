//
//  JarvisSkriver.swift
//  boringNotch
//
//  DET ENE STED NOTCHEN SKRIVER TIL HUSET.
//
//  Til 16. september var notchen læse-eneste. Lauritz ændrede det den aften:
//  han vil kunne sige ja eller nej til et kort, og skrive en opgave, uden at
//  finde appen frem. To ting gælder stadig:
//
//    1. `GET /notch` ER og BLIVER læsning. Der skrives aldrig dertil.
//    2. Notchen afgør INTET selv. Den kalder husets EGNE døre — de samme som
//       appens skærme bruger — så husets værn, husets log og fortryd-linjen i
//       Kommandocentret gælder for et tryk i hakket præcis som for et tryk på
//       skærmen. Der findes ingen regel her som huset ikke også har.
//
//  TRE DØRE, OG IKKE ÉN MERE:
//
//      POST <bro>/decisions/<id>/approve   {"af": …, "hvorfor": "fra notchen"}
//      POST <bro>/decisions/<id>/reject    {"af": …, "hvorfor": "fra notchen"}
//      POST <bro>/tasks                    {"text": …, "target": …}
//
//  Udskyd og Fortryd hører ikke i et hak: de kræver en dato og en liste over
//  hvad man fortryder. De findes kun i Kommandocentret.
//
//  ADRESSEN BYGGES IKKE. Den udledes af den ene adresse han selv har skrevet i
//  indstillingerne (`…/notch`) ved at tage stien af. Så kan der ikke ligge en
//  vært hårdkodet i Swift, og der kan ikke sendes noget til en anden maskine
//  end den han har peget på.
//
//  `af` ER IKKE PYNT. Navnet kommer fra husets eget svar (`skriv.af`) og er
//  hele forslags-trinnet: kunne modtageren fylde det ud selv, kunne en agent
//  godkende sit eget forslag. Er navnet tomt, vises der ingen knapper — se
//  `JarvisState.kanDoemme`.
//

import Foundation

/// Hvad et kald endte med, i ord han kan læse. Der er ingen fejlkoder her.
enum JarvisSvarResultat {
    /// Huset tog imod. Teksten er kvitteringen.
    case ok(String)
    /// Huset sagde nej, og sagde hvorfor — på dansk, fra husets eget svar.
    case nej(String)
    /// Broen var ikke at nå.
    case ikkeKontakt
}

@MainActor
final class JarvisSkriver {
    static let shared = JarvisSkriver()

    /// Grunden til at kortet blev afgjort — så det kan læses i husets log
    /// bagefter, og man kan se at trykket kom fra hakket og ikke fra skærmen.
    private static let hvorfor = "fra notchen"

    private let session: URLSession

    private init() {
        let opsaetning = URLSessionConfiguration.ephemeral
        opsaetning.requestCachePolicy = .reloadIgnoringLocalCacheData
        opsaetning.urlCache = nil
        opsaetning.timeoutIntervalForRequest = 8
        opsaetning.timeoutIntervalForResource = 12
        opsaetning.waitsForConnectivity = false
        opsaetning.httpShouldSetCookies = false
        session = URLSession(configuration: opsaetning)
    }

    // MARK: - Adressen

    /// Broens rod, udledt af den adresse han selv skrev: `http://…:8000/notch`
    /// -> `http://…:8000/`. Ingen vært, ingen port og ingen sti i koden.
    private static func bro() -> URL? {
        let tekst = JarvisState.adresse
        guard !tekst.isEmpty,
              let url = URL(string: tekst),
              let skema = url.scheme?.lowercased(),
              skema == "http" || skema == "https",
              url.host != nil
        else { return nil }
        return url.deletingLastPathComponent()
    }

    // MARK: - Dømme et kort

    /// «Godkend» eller «Afvis» på ét kort. Samme dør som Kommandocentret.
    ///
    /// Huset svarer `200` med kortets nye tilstand, eller `400` med
    /// `{"error": "…"}` — en dansk sætning vi viser som den kom. Vi regner
    /// ikke på kroppen: kortet forsvinder af sig selv fra `venter.liste` ved
    /// næste poll, for det er huset der ved om det er væk.
    func doem(kortId: String, godkend: Bool, af: String) async -> JarvisSvarResultat {
        let id = kortId.trimmingCharacters(in: .whitespacesAndNewlines)
        let navn = af.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, !navn.isEmpty else { return .ikkeKontakt }
        // Kort-id'er er `[a-z0-9-]` i huset, men vi koder alligevel: en dag
        // hvor et id får et andet tegn, skal det ikke blive en skæv adresse.
        guard let sikkerId = id.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(CharacterSet(charactersIn: "-_."))),
              let rod = JarvisSkriver.bro(),
              let url = URL(string: godkend ? "decisions/\(sikkerId)/approve"
                                            : "decisions/\(sikkerId)/reject",
                            relativeTo: rod)
        else { return .ikkeKontakt }

        let svar = await send(url, krop: ["af": navn,
                                         "hvorfor": JarvisSkriver.hvorfor])
        switch svar {
        case .ok:
            return .ok(godkend
                ? NSLocalizedString("Approved", comment: "Jarvis: receipt after approving a card")
                : NSLocalizedString("Rejected", comment: "Jarvis: receipt after rejecting a card"))
        case .nej(let hvorfor):
            return .nej(hvorfor)
        case .ikkeKontakt:
            return .ikkeKontakt
        }
    }

    // MARK: - Lægge en opgave i køen

    /// «Sig det til Jarvis…» -> `POST /tasks`, samme dør som appens Kø-skærm.
    ///
    /// Vi sender kun teksten og målet. Vigtigheden er hans egen, og døren
    /// stempler selv opgaven som hans — sendte vi `score` eller `kilde`, ville
    /// notchen skrive hans dom for ham.
    ///
    /// TRE SVAR, OG DE ER FORSKELLIGE:
    ///   * `dublet_af` i kroppen: opgaven stod der allerede, og der blev IKKE
    ///     skrevet noget nyt. Det er ikke en fejl — men det er en løgn at sige
    ///     «lagt i køen».
    ///   * `target` i kroppen er hvor den FAKTISK ligger. Broen kan have lagt
    ///     den i en anden kø, fordi teksten bad om et værktøj køen ikke har.
    ///     Derfor kvitterer vi med husets svar og ikke med vores bestilling.
    ///   * `400` med `error`: pengehandels-værnet, eller et ukendt mål. Sætningen
    ///     kommer fra huset og vises som den er.
    func laegIKoeen(tekst: String, maal: String) async -> JarvisSvarResultat {
        let ren = tekst.trimmingCharacters(in: .whitespacesAndNewlines)
        let koe = maal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !ren.isEmpty, !koe.isEmpty else { return .ikkeKontakt }
        guard let rod = JarvisSkriver.bro(),
              let url = URL(string: "tasks", relativeTo: rod)
        else { return .ikkeKontakt }

        switch await send(url, krop: ["text": ren, "target": koe]) {
        case .ok(let krop):
            let hvor = (krop["target"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? koe
            let dublet = (krop["dublet_af"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !dublet.isEmpty {
                return .ok(String(
                    format: NSLocalizedString(
                        "it is already in the queue at %@",
                        comment: "Jarvis: the task was a duplicate, nothing new was written"),
                    hvor))
            }
            if let besked = (krop["besked"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines), !besked.isEmpty {
                return .ok(besked)          // broen lagde den et andet sted og sagde hvorfor
            }
            return .ok(String(
                format: NSLocalizedString("put in the queue at %@",
                                          comment: "Jarvis: receipt after queueing a task"),
                hvor))
        case .nej(let hvorfor):
            return .nej(hvorfor)
        case .ikkeKontakt:
            return .ikkeKontakt
        }
    }

    // MARK: - Det ene POST-kald

    private enum Svar {
        case ok([String: Any])
        case nej(String)
        case ikkeKontakt
    }

    /// Ét POST med JSON. Alt hvad huset ikke selv forklarer, bliver
    /// «Jarvis er ikke at nå» — vi opfinder ikke en fejltekst.
    private func send(_ url: URL, krop: [String: String]) async -> Svar {
        var foresporgsel = URLRequest(url: url)
        foresporgsel.httpMethod = "POST"
        foresporgsel.timeoutInterval = 8
        foresporgsel.cachePolicy = .reloadIgnoringLocalCacheData
        foresporgsel.setValue("application/json", forHTTPHeaderField: "Content-Type")
        foresporgsel.setValue("application/json", forHTTPHeaderField: "Accept")
        guard let data = try? JSONSerialization.data(withJSONObject: krop) else {
            return .ikkeKontakt
        }
        foresporgsel.httpBody = data

        do {
            let (svarData, svar) = try await session.data(for: foresporgsel)
            let kode = (svar as? HTTPURLResponse)?.statusCode ?? 0
            let krop = (try? JSONSerialization.jsonObject(with: svarData))
                as? [String: Any] ?? [:]
            if (200..<300).contains(kode) {
                // Huset kan sige 200 OG lægge en fejl i kroppen (det gør
                // `POST /tasks` ikke, men vi læser den hvis den er der).
                if let fejl = (krop["error"] as? String)?
                    .trimmingCharacters(in: .whitespacesAndNewlines), !fejl.isEmpty {
                    return .nej(fejl)
                }
                return .ok(krop)
            }
            if let fejl = (krop["error"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines), !fejl.isEmpty {
                return .nej(fejl)
            }
            return .ikkeKontakt
        } catch {
            return .ikkeKontakt
        }
    }
}
