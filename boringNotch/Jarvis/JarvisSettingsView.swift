//
//  JarvisSettingsView.swift
//  boringNotch
//
//  Indstillingen «Jarvis»: adressen på husets læse-rute. Tom adresse =
//  fanerne og mærket er væk, og der hentes intet.
//  Dertil: hvor et klik i notchen skal åbne — Jarvis-appen på Mac'en eller web-appen.
//
//  17/9 10:32-11:19 stod der «Jarvis er ikke at nå» i tre kvarter, mens broen
//  svarede alle andre normalt. Vi kunne ikke se om notchen spurgte uden at få
//  svar, eller om pollerens løkke var død — to ting med hver sin kur. Derfor
//  står der nu et LIVSTEGN under «Test», i ord: hvornår huset sidst blev hørt,
//  hvornår notchen sidst prøvede, og om forsøgene går galt i træk. Flytter
//  «sidst prøvet» sig hvert minut, lever løkken og vejen er væk; står den
//  stille, er løkken død. Se docs/notch-poll-2026-09-18.md.
//
//  Appen VÆLGES i en liste over det der kører lige nu, ikke ved at skrive et
//  navn. Lauritz 16/9: hans Jarvis-app er en Flet-desktop-klient, hvis navn i
//  systemet er «Flet» — kun vinduet hedder «Jarvis». Et navnefelt kan altså
//  aldrig ramme den, og notchen startede i stedet en ny kopi. Vælgeren gemmer
//  bundle-id'et, som følger processen.
//

import Combine
import Defaults
import SwiftUI

struct JarvisSettings: View {
    @Default(.jarvisAdresse) var jarvisAdresse
    @Default(.jarvisAabnI) var jarvisAabnI
    @Default(.jarvisAppNavn) var jarvisAppNavn
    @Default(.jarvisAppBundleId) var jarvisAppBundleId
    @Default(.jarvisAppSti) var jarvisAppSti
    @ObservedObject private var jarvis = JarvisState.shared

    @State private var proever: Bool = false
    @State private var proeveSvar: String?
    @State private var koerendeApps: [JarvisKoerendeApp] = []
    @State private var valgtKoerer: Bool = false
    /// Tidspunktet livstegnets linjer regnes fra. Flyttes af uret nedenfor, så
    /// «for 12 sekunder siden» faktisk tikker mens han står og ser på det —
    /// det er hele pointen: han skal kunne SE om løkken lever.
    @State private var nu: Date = Date()

    /// Uret. Ligger som en egenskab og ikke inde i `.onReceive`, så der ikke
    /// bygges en ny udsender hver gang fladen tegnes om.
    private let ur = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    private var adresse: String {
        jarvisAdresse.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Form {
            Section {
                TextField(
                    "Jarvis address",
                    text: $jarvisAdresse,
                    prompt: Text(verbatim: "http://<din-tailscale-adresse>:8000/notch")
                )
                .onSubmit { proev() }

                HStack(spacing: 10) {
                    Button("Test") { proev() }
                        .disabled(adresse.isEmpty || proever)
                    if proever {
                        ProgressView()
                            .controlSize(.small)
                    }
                    if let proeveSvar = proeveSvar {
                        Text(proeveSvar)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                if !adresse.isEmpty {
                    livstegn
                }
            } header: {
                HStack {
                    Text("Jarvis")
                }
            } footer: {
                Text("The house's own bridge, read only: the notch never writes anything. The tab appears when the address is filled in.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Picker("Open in", selection: $jarvisAabnI) {
                    ForEach(JarvisAabnI.allCases) { valg in
                        Text(valg.rawValue).tag(valg)
                    }
                }
                .pickerStyle(.radioGroup)

                if jarvisAabnI == .app {
                    Picker("Jarvis app", selection: valgtApp) {
                        Text("Not chosen").tag("")
                        ForEach(appListe) { app in
                            Text(app.etiket).tag(app.id)
                        }
                    }

                    HStack(spacing: 10) {
                        Button("Refresh list") { opdaterListen() }
                        // Bevidst to hele sætninger og ikke en ternær inde i
                        // Text(): en ternær af to strengliteraler bliver en
                        // String, ikke en LocalizedStringKey — og så ville
                        // linjen stå på engelsk uanset hvad katalogen siger.
                        if valgtKoerer {
                            Text("Running right now: yes")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("Running right now: no")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }

                    Text("Pick the Jarvis app in the list of apps that are running right now. The choice is remembered by the app's identity, not by its name — a Flet or web client is often called something else in the system than in its window title. Is it not in the list, start it and press «Refresh list».")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField(
                        "App name (manual fallback)",
                        text: $jarvisAppNavn,
                        prompt: Text(verbatim: "Jarvis")
                    )
                    Text("Only used when nothing is chosen above: the name (or bundle id) of the app in your Applications folder. If the app is running it is brought to the front — also when it is hidden or its window has been closed — and a second copy is never started. If it can be found neither way, the link opens in the web app instead.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Links")
            } footer: {
                Text("A specific card can only be opened in the web app.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            opdaterListen()
            nu = Date()
        }
        .onReceive(ur) { tid in
            nu = tid
        }
        .onChange(of: jarvisAabnI) { opdaterListen() }
        .onChange(of: jarvisAppNavn) { valgtKoerer = jarvisValgtAppKoerer }
        .onChange(of: jarvisAdresse) {
            proeveSvar = nil
            if adresse.isEmpty {
                JarvisState.shared.nulstil()
            }
        }
    }

    // MARK: - Livstegnet: lever løkken?

    /// Tre linjer i ord, ingen tal-koder, ingen fejlkoder (husets regel fra 7/9).
    ///
    /// Den MIDTERSTE er den vigtige og den nye: «Notchen spurgte sidst …».
    /// Står der samtidig at huset ikke blev hørt, siger de to linjer tilsammen
    /// hvad der er i vejen — og det var præcis den forskel der manglede 17/9.
    @ViewBuilder
    private var livstegn: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let hoert = jarvisForLaengeSiden(jarvis.sidst, nu: nu) {
                Text("Last heard from the house: \(hoert)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Last heard from the house: not yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let proevede = jarvisForLaengeSiden(jarvis.sidstForsoegt, nu: nu) {
                Text("The notch last asked: \(proevede)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                // Løkken har ikke spurgt én gang siden appen startede. Det er
                // ikke «huset er væk» — det er noget der er galt her.
                Text("The notch has not asked yet")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            // Ingen optælling her: husets regel er ord og ikke tal på hans
            // skærme. Tallet lever bagved i `fejlIStribe` og i Console-loggen,
            // hvor det hører.
            if jarvis.fejlIStribe > 0, let gik = jarvisForLaengeSiden(jarvis.sidstFejlede, nu: nu) {
                Text("The attempt failed: \(gik)")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }

    // MARK: - Vælgeren over kørende apps

    /// Listen i vælgeren. Er hans valg ikke kørende lige nu, står det stadig
    /// øverst med sit gemte navn — ellers ville valget se ud som om det var væk.
    private var appListe: [JarvisKoerendeApp] {
        var liste = koerendeApps
        let valgt = jarvisAppBundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        if !valgt.isEmpty, !liste.contains(where: { $0.id == valgt }) {
            let navn = jarvisAppSti.isEmpty
                ? valgt
                : URL(fileURLWithPath: jarvisAppSti).deletingPathExtension().lastPathComponent
            liste.insert(JarvisKoerendeApp(id: valgt, navn: navn, sti: jarvisAppSti), at: 0)
        }
        return liste
    }

    /// Valget gemmer BÅDE bundle-id'et (matchet) og stien (starten, hvis appen
    /// ikke kører). Tomt valg rydder begge, så tekstfeltet nedenunder overtager.
    private var valgtApp: Binding<String> {
        Binding(
            get: { self.jarvisAppBundleId },
            set: { nyt in
                self.jarvisAppBundleId = nyt
                self.jarvisAppSti =
                    self.koerendeApps.first { $0.id == nyt }?.sti
                    ?? (nyt.isEmpty ? "" : self.jarvisAppSti)
                self.valgtKoerer = jarvisValgtAppKoerer
            }
        )
    }

    private func opdaterListen() {
        koerendeApps = jarvisKoerendeApps()
        valgtKoerer = jarvisValgtAppKoerer
    }

    private func proev() {
        guard !adresse.isEmpty, !proever else { return }
        proever = true
        proeveSvar = nil
        Task { @MainActor in
            let svarede = await JarvisPoller.shared.hentEnGang()
            proever = false
            proeveSvar =
                svarede
                ? NSLocalizedString("Jarvis answered", comment: "Result of the Jarvis test button")
                : NSLocalizedString("Jarvis can't be reached", comment: "Quiet error line in the Jarvis view")
            if svarede { JarvisPoller.shared.start() }
        }
    }
}

#Preview {
    JarvisSettings()
        .frame(width: 600, height: 240)
}
