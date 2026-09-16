//
//  JarvisSettingsView.swift
//  boringNotch
//
//  Indstillingen «Jarvis»: adressen på husets læse-rute. Tom adresse =
//  fanen og mærket er væk, og der hentes intet.
//  Dertil: hvor et klik i notchen skal åbne — Jarvis-appen på Mac'en eller web-appen.
//

import Defaults
import SwiftUI

struct JarvisSettings: View {
    @Default(.jarvisAdresse) var jarvisAdresse
    @Default(.jarvisAabnI) var jarvisAabnI
    @Default(.jarvisAppNavn) var jarvisAppNavn
    @ObservedObject private var jarvis = JarvisState.shared

    @State private var proever: Bool = false
    @State private var proeveSvar: String?

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
                    TextField(
                        "App name",
                        text: $jarvisAppNavn,
                        prompt: Text(verbatim: "Jarvis")
                    )
                    Text("The name (or bundle id) of the Jarvis app on this Mac. If it is running it is simply brought to the front; if not, it is launched from your Applications folder. If it can be found neither way, the link opens in the web app instead.")
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
        .onChange(of: jarvisAdresse) {
            proeveSvar = nil
            if adresse.isEmpty {
                JarvisState.shared.nulstil()
            }
        }
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
