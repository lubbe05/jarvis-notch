//
//  JarvisSettingsView.swift
//  boringNotch
//
//  Indstillingen «Jarvis»: adressen på husets læse-rute. Tom adresse =
//  fanen og mærket er væk, og der hentes intet.
//

import Defaults
import SwiftUI

struct JarvisSettings: View {
    @Default(.jarvisAdresse) var jarvisAdresse
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
                    prompt: Text(verbatim: "http://100.125.171.38:8000/notch")
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
