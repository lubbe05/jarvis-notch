//
//  JarvisPoller.swift
//  boringNotch
//
//  Henter husets ene læse-rute (GET /notch) hvert 60. sekund — aldrig
//  oftere end hvert 30. — og kun når «Jarvis-adresse» er sat i
//  indstillingerne. Skriver aldrig til broen. Fejl er stille: ingen
//  advarsler, ingen genforsøgs-storm, næste forsøg om et minut.
//

import Foundation

@MainActor
final class JarvisPoller {
    static let shared = JarvisPoller()

    /// Hvileperiode mellem to kald. Gulvet på 30 sekunder er husets regel.
    private static let sekunderMellemKald: TimeInterval = 60
    private static let mindsteSekunder: TimeInterval = 30
    /// Broen lover ≤ 2 kB; vi afviser alt der er vildt større.
    private static let stoersteSvar = 256 * 1024

    private var loekke: Task<Void, Never>?
    private let session: URLSession

    private init() {
        let opsaetning = URLSessionConfiguration.ephemeral
        opsaetning.requestCachePolicy = .reloadIgnoringLocalCacheData
        opsaetning.urlCache = nil
        opsaetning.timeoutIntervalForRequest = 5
        opsaetning.timeoutIntervalForResource = 8
        opsaetning.waitsForConnectivity = false
        opsaetning.httpShouldSetCookies = false
        opsaetning.httpAdditionalHeaders = ["Accept": "application/json"]
        session = URLSession(configuration: opsaetning)
    }

    /// Starter den stille løkke. Sikker at kalde flere gange.
    func start() {
        guard loekke == nil else { return }
        loekke = Task { @MainActor in
            while !Task.isCancelled {
                await JarvisPoller.shared.hentEnGang()
                let hvile = max(JarvisPoller.mindsteSekunder, JarvisPoller.sekunderMellemKald)
                try? await Task.sleep(for: .seconds(hvile))
            }
        }
    }

    func stop() {
        loekke?.cancel()
        loekke = nil
    }

    /// Ét kald. Returnerer sandt når broen svarede — bruges af «Test»-knappen.
    @discardableResult
    func hentEnGang() async -> Bool {
        let state = JarvisState.shared
        let adresse = JarvisState.adresse

        guard !adresse.isEmpty else {
            state.nulstil()
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
        foresporgsel.timeoutInterval = 5
        foresporgsel.cachePolicy = .reloadIgnoringLocalCacheData

        state.henter = true
        defer { state.henter = false }

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
