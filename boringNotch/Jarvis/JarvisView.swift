//
//  JarvisView.swift
//  boringNotch
//
//  Jarvis-fanen i den udfoldede notch, og det lille mærke i den
//  sammenfoldede. Alt der står her kommer i ord fra husets bro —
//  det eneste tal på skærmen er antallet i mærket.
//

import AppKit
import Defaults
import SwiftUI

// MARK: - Den udfoldede visning

struct JarvisView: View {
    @EnvironmentObject var vm: BoringViewModel
    @ObservedObject private var jarvis = JarvisState.shared
    @Default(.jarvisAdresse) private var jarvisAdresse

    var body: some View {
        Group {
            if jarvisAdresse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                stilleLinje(Text("Jarvis is not set up yet"))
            } else if let fejl = jarvis.fejl {
                stilleLinje(Text(fejl))
            } else if jarvis.svar == nil {
                stilleLinje(Text("Asking the house…"))
            } else {
                indhold
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

    private var indhold: some View {
        HStack(alignment: .top, spacing: 16) {
            venstreSpalte
                .frame(maxWidth: .infinity, alignment: .topLeading)
            hoejreSpalte
                .frame(width: 250, alignment: .topLeading)
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)
    }

    // MARK: Venstre: det huset venter på

    private var venstreSpalte: some View {
        VStack(alignment: .leading, spacing: 8) {
            venterRaekke
            if let seneste = jarvis.svar?.venter?.seneste, (seneste.titel?.isEmpty == false) {
                senesteKort(seneste)
            }
            if let ord = ordEller(jarvis.svar?.breve?.ord), jarvis.breveAntal > 0 {
                JarvisRaekke(ikon: "envelope.fill", tekst: ord, farve: .white)
            }
            husetRaekke
            Spacer(minLength: 0)
            bundLinje
        }
    }

    private var venterRaekke: some View {
        HStack(spacing: 8) {
            ZStack {
                Capsule()
                    .fill(jarvis.venterAntal > 0 ? Color.effectiveAccent : Color.gray.opacity(0.25))
                    .frame(width: jarvis.venterAntal > 9 ? 28 : 22, height: 20)
                Text("\(jarvis.venterAntal)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(jarvis.venterAntal > 0 ? .white : .gray)
            }
            Text(ordEller(jarvis.svar?.venter?.ord) ?? NSLocalizedString("Waiting for you", comment: "Jarvis: cards waiting"))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(jarvis.venterAntal > 0 ? .white : .gray)
                .lineLimit(1)
        }
    }

    private func senesteKort(_ seneste: JarvisSeneste) -> some View {
        JarvisLinkRaekke(url: URL(string: seneste.link ?? "") ?? jarvis.kommandocenterLink) {
            HStack(spacing: 6) {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
                Text(seneste.titel ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                if let fra = ordEller(seneste.fra) {
                    Text(verbatim: "·")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                    Text(fra)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }
            }
        }
    }

    @ViewBuilder
    private var husetRaekke: some View {
        if let huset = jarvis.svar?.huset, let seneste = ordEller(huset.seneste) ?? ordEller(huset.ord) {
            HStack(spacing: 6) {
                Image(systemName: "house.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(tilstandsfarve(huset.tilstand))
                Text(seneste)
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                    .lineLimit(1)
                if let hvornaar = ordEller(huset.hvornaar) {
                    Text(hvornaar)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray.opacity(0.7))
                        .lineLimit(1)
                }
            }
        }
    }

    @ViewBuilder
    private var bundLinje: some View {
        HStack(spacing: 8) {
            if let url = jarvis.kommandocenterLink {
                JarvisLinkRaekke(url: url) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 10))
                        Text("Open the command center")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.gray)
                }
            }
            if let mangler = jarvis.svar?.mangler?.first, !mangler.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 9))
                    Text(mangler)
                        .font(.system(size: 11))
                        .lineLimit(1)
                }
                .foregroundStyle(Color.gray.opacity(0.7))
            }
        }
    }

    // MARK: Højre: depot, laboratorier, agenter

    private var hoejreSpalte: some View {
        VStack(alignment: .leading, spacing: 8) {
            depotRaekke
            regnskabRaekke
            if let ord = ordEller(jarvis.svar?.labs?.ord) {
                JarvisRaekke(ikon: "flask.fill", tekst: ord, farve: .gray, linjer: 2)
            }
            Spacer(minLength: 0)
            agentPrikker
        }
    }

    @ViewBuilder
    private var depotRaekke: some View {
        if let depot = jarvis.svar?.depot, let vaerdi = ordEller(depot.vaerdiOrd) {
            HStack(spacing: 6) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
                Text(vaerdi)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                if let aendring = ordEller(depot.dagsaendringOrd) {
                    Text(aendring)
                        .font(.system(size: 12))
                        .foregroundStyle(retningsfarve(depot.retning))
                        .lineLimit(1)
                }
            }
        }
    }

    @ViewBuilder
    private var regnskabRaekke: some View {
        if let regnskab = jarvis.svar?.depot?.naesteRegnskab,
           let navn = ordEller(regnskab.ticker) ?? ordEller(regnskab.navn),
           let naar = ordEller(regnskab.datoOrd) {
            let saetning = String(
                format: NSLocalizedString(
                    "%1$@ reports earnings %2$@",
                    comment: "Jarvis: next earnings, e.g. MU reports earnings tomorrow"
                ),
                navn, naar
            )
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
                Text(saetning)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                if regnskab.foreloebig == true {
                    Text("(preliminary)")
                        .font(.system(size: 11))
                        .foregroundStyle(.gray)
                }
            }
        }
    }

    @ViewBuilder
    private var agentPrikker: some View {
        if let agenter = jarvis.svar?.agenter, !agenter.isEmpty {
            HStack(spacing: 6) {
                ForEach(Array(agenter.enumerated()), id: \.offset) { _, agent in
                    Circle()
                        .fill(agentfarve(agent.tilstand))
                        .frame(width: 7, height: 7)
                        .help(agentHjaelp(agent))
                }
            }
        }
    }

    // MARK: Små hjælpere

    private func agentHjaelp(_ agent: JarvisAgent) -> String {
        let navn = ordEller(agent.navn) ?? "?"
        if let ord = ordEller(agent.ord) { return "\(navn): \(ord)" }
        if let tilstand = ordEller(agent.tilstand) { return "\(navn): \(tilstand)" }
        return navn
    }

    private func ordEller(_ tekst: String?) -> String? {
        guard let tekst = tekst?.trimmingCharacters(in: .whitespacesAndNewlines), !tekst.isEmpty else {
            return nil
        }
        return tekst
    }

    private func retningsfarve(_ retning: String?) -> Color {
        switch (retning ?? "").lowercased() {
        case "op": return .green
        case "ned": return .red
        default: return .gray
        }
    }

    private func tilstandsfarve(_ tilstand: String?) -> Color {
        switch (tilstand ?? "").lowercased() {
        case "broen er tavs": return .red
        case "natten kører", "arbejder": return Color.effectiveAccent
        default: return .gray
        }
    }

    private func agentfarve(_ tilstand: String?) -> Color {
        switch (tilstand ?? "").lowercased() {
        case "arbejder": return .green
        case "fejl": return .red
        default: return .gray
        }
    }
}

// MARK: - Rækker

private struct JarvisRaekke: View {
    let ikon: String
    let tekst: String
    var farve: Color = .gray
    var linjer: Int = 1

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: ikon)
                .font(.system(size: 10))
                .foregroundStyle(.gray)
                .padding(.top, 2)
            Text(tekst)
                .font(.system(size: 12))
                .foregroundStyle(farve)
                .lineLimit(linjer)
                .multilineTextAlignment(.leading)
        }
    }
}

/// En klikbar række der åbner web-appen i browseren. Notchen handler ikke selv.
private struct JarvisLinkRaekke<Indhold: View>: View {
    private let url: URL?
    private let indhold: () -> Indhold
    @State private var pegerPaa: Bool = false

    init(url: URL?, @ViewBuilder indhold: @escaping () -> Indhold) {
        self.url = url
        self.indhold = indhold
    }

    var body: some View {
        Button {
            if let url = url { NSWorkspace.shared.open(url) }
        } label: {
            indhold()
                .padding(.vertical, 3)
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

// MARK: - Mærket i den sammenfoldede notch

struct JarvisLukketMaerke: View {
    @EnvironmentObject var vm: BoringViewModel
    @ObservedObject private var jarvis = JarvisState.shared

    var body: some View {
        HStack {
            Rectangle()
                .fill(.clear)
                .frame(
                    width: max(0, vm.effectiveClosedNotchHeight - 12),
                    height: max(0, vm.effectiveClosedNotchHeight - 12)
                )
            Rectangle()
                .fill(.black)
                .frame(width: vm.closedNotchSize.width - 20)
            HStack(spacing: 3) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 10))
                Text("\(jarvis.venterAntal)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(Color.effectiveAccent)
            .frame(width: max(0, vm.effectiveClosedNotchHeight - 12) + 12, alignment: .leading)
        }
        .frame(height: vm.effectiveClosedNotchHeight, alignment: .center)
    }
}

#Preview {
    JarvisView()
        .environmentObject(BoringViewModel())
        .frame(width: 600, height: 150)
        .background(.black)
        .preferredColorScheme(.dark)
}
