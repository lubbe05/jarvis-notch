//
//  JarvisFaelles.swift
//  boringNotch
//
//  Det de to Jarvis-faner deler: skallen om dem (adressen mangler, broen
//  svarer ikke, første svar er ikke kommet), rækkerne, knappen ud af notchen
//  og farverne. Farverne kommer KUN fra husets maskinfelter — `huset.tilstand`,
//  `depot.retning`, `agenter[].tilstand` — aldrig fra en sætning.
//
//  Ingen af de to faner henter noget selv: samme poller, samme svar, samme
//  cache. Aktier-fanen læser blot andre felter af det svar der allerede er
//  hentet.
//

import AppKit
import Defaults
import SwiftUI

// MARK: - Skallen om en Jarvis-fane

/// De tre stille tilstande begge faner deler, så teksten står ét sted.
struct JarvisRamme<Indhold: View>: View {
    @ObservedObject private var jarvis = JarvisState.shared
    @Default(.jarvisAdresse) private var jarvisAdresse

    private let indhold: () -> Indhold

    init(@ViewBuilder indhold: @escaping () -> Indhold) {
        self.indhold = indhold
    }

    var body: some View {
        Group {
            if jarvisAdresse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                stilleLinje(Text("Jarvis is not set up yet"))
            } else if let fejl = jarvis.fejl {
                // «Jarvis er ikke at nå» — stille, grå, ingen fejlkode.
                stilleLinje(Text(fejl))
            } else if jarvis.svar == nil {
                stilleLinje(Text("Asking the house…"))
            } else {
                indhold()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            JarvisPoller.shared.start()
        }
    }

    private func stilleLinje(_ tekst: Text) -> some View {
        tekst
            .font(.system(size: 13))
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Rækker

/// Ikon + sætning. `linjer` er hvor mange linjer sætningen må bryde over —
/// aldrig 1 på de to store faner, for husets tal står i ord og bliver lange.
struct JarvisRaekke: View {
    let ikon: String
    let tekst: String
    var farve: Color = .gray
    var ikonfarve: Color = .gray
    var stoerrelse: CGFloat = 12
    var linjer: Int = 2

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: ikon)
                .font(.system(size: 10))
                .foregroundStyle(ikonfarve)
                .frame(width: 12)
                .padding(.top, 2)
            Text(tekst)
                .font(.system(size: stoerrelse))
                .foregroundStyle(farve)
                .lineLimit(linjer)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// En klikbar række der åbner web-appen i browseren. Notchen handler ikke selv.
struct JarvisLinkRaekke<Indhold: View>: View {
    private let url: URL?
    private let indhold: () -> Indhold
    @State private var pegerPaa: Bool = false

    init(url: URL?, @ViewBuilder indhold: @escaping () -> Indhold) {
        self.url = url
        self.indhold = indhold
    }

    var body: some View {
        Button {
            // Én fælles dør: JarvisState.aabn respekterer valget
            // «Jarvis-appen på denne Mac» / «Web-appen» i indstillingerne.
            let link = url
            Task { @MainActor in JarvisState.shared.aabn(link) }
        } label: {
            indhold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(pegerPaa ? Color.gray.opacity(0.2) : .clear)
                )
                .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(url == nil)
        .onHover { peger in
            withAnimation(.smooth(duration: 0.2)) { pegerPaa = peger }
        }
    }
}

/// Den ene knap nederst på hver fane. Går gennem samme dør som alt andet,
/// så «Åbn i»-valget i indstillingerne gælder begge faner.
struct JarvisKnap: View {
    let tekst: LocalizedStringKey
    let ikon: String
    let url: URL?
    @State private var pegerPaa: Bool = false

    var body: some View {
        Button {
            let link = url
            Task { @MainActor in JarvisState.shared.aabn(link) }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: ikon)
                    .font(.system(size: 11))
                Text(tekst)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(url == nil ? Color.gray : Color.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                Capsule().fill(
                    pegerPaa ? Color.effectiveAccent.opacity(0.45) : Color.gray.opacity(0.22)
                )
            )
            .contentShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(url == nil)
        .onHover { peger in
            withAnimation(.smooth(duration: 0.2)) { pegerPaa = peger }
        }
    }
}

// MARK: - Små hjælpere, fælles for begge faner

/// Tom streng og kun-blanktegn tæller som «feltet kom ikke» — så tegner vi
/// ingen plads for det.
func jarvisOrd(_ tekst: String?) -> String? {
    guard let tekst = tekst?.trimmingCharacters(in: .whitespacesAndNewlines), !tekst.isEmpty else {
        return nil
    }
    return tekst
}

/// `depot.retning`: grøn op, rød ned, grå ellers. Maskinfeltet, ikke sætningen.
func jarvisRetningsfarve(_ retning: String?) -> Color {
    switch (retning ?? "").lowercased() {
    case "op": return .green
    case "ned": return .red
    default: return .gray
    }
}

/// Pilen der hører til retningen. Intet ved «ukendt» — vi tegner ikke en
/// bevægelse huset ikke kunne måle.
func jarvisRetningsikon(_ retning: String?) -> String? {
    switch (retning ?? "").lowercased() {
    case "op": return "arrow.up.right"
    case "ned": return "arrow.down.right"
    case "flad": return "arrow.right"
    default: return nil
    }
}

/// `huset.tilstand`: kun «broen er tavs» er noget han skal gøre noget ved.
/// «hjernen er klar» er hvile og neutral.
func jarvisTilstandsfarve(_ tilstand: String?) -> Color {
    switch (tilstand ?? "").lowercased() {
    case "broen er tavs": return .red
    case "natten kører", "arbejder": return Color.effectiveAccent
    default: return .gray
    }
}

/// `agenter[].tilstand`.
func jarvisAgentfarve(_ tilstand: String?) -> Color {
    switch (tilstand ?? "").lowercased() {
    case "arbejder": return .green
    case "fejl": return .red
    default: return .gray
    }
}
