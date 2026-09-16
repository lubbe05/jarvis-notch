//
//  JarvisView.swift
//  boringNotch
//
//  Fanen «Jarvis» — kommandocentret — i den udfoldede notch, og det lille
//  mærke i den sammenfoldede. Alt der står her kommer i ord fra husets bro;
//  det eneste tal på skærmen er antallet i mærket og i badgen.
//
//  Aktierne har sin egen fane, JarvisAktierView. Begge faner læser det SAMME
//  svar — ét kald, én poller, én cache.
//
//  Lauritz 16/9: intet må klippes med «…» her. Husets tal står i ord
//  («cirka 167 tusind kroner»), og en halv sætning er værre end ingen.
//  Derfor bryder hver sætning over 2-3 linjer, og fanen folder notchen
//  større ud end de øvrige faner (se `jarvisOpenNotchSize`).
//

import AppKit
import Defaults
import SwiftUI

// MARK: - Den udfoldede visning

struct JarvisView: View {
    @EnvironmentObject var vm: BoringViewModel
    @ObservedObject private var jarvis = JarvisState.shared

    var body: some View {
        JarvisRamme {
            indhold
        }
    }

    private var indhold: some View {
        VStack(alignment: .leading, spacing: 9) {
            venterRaekke
            if let seneste = jarvis.svar?.venter?.seneste, jarvisOrd(seneste.titel) != nil {
                senesteKort(seneste)
            }
            if let ord = jarvisOrd(jarvis.svar?.breve?.ord), jarvis.breveAntal > 0 {
                JarvisRaekke(ikon: "envelope.fill", tekst: ord, farve: .white.opacity(0.9), linjer: 2)
            }
            husetBlok
            Spacer(minLength: 0)
            agentRaekke
            bundLinje
        }
        .padding(.horizontal, 6)
        .padding(.top, 2)
    }

    // MARK: Kort der venter

    private var venterRaekke: some View {
        HStack(spacing: 9) {
            ZStack {
                Capsule()
                    .fill(jarvis.venterAntal > 0 ? Color.effectiveAccent : Color.gray.opacity(0.25))
                    .frame(width: jarvis.venterAntal > 9 ? 32 : 26, height: 24)
                Text(verbatim: "\(jarvis.venterAntal)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(jarvis.venterAntal > 0 ? .white : .gray)
            }
            Text(jarvisOrd(jarvis.svar?.venter?.ord) ?? NSLocalizedString("Waiting for you", comment: "Jarvis: cards waiting"))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(jarvis.venterAntal > 0 ? .white : .gray)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    /// Det nyeste kort: hele titlen, og hvem der sendte det. Klikket åbner
    /// præcis det kort — notchen dømmer aldrig selv.
    private func senesteKort(_ seneste: JarvisSeneste) -> some View {
        JarvisLinkRaekke(url: URL(string: seneste.link ?? "") ?? jarvis.kommandocenterLink) {
            HStack(alignment: .top, spacing: 7) {
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
                    .frame(width: 12)
                    .padding(.top, 3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(jarvisOrd(seneste.titel) ?? "")
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let fra = jarvisOrd(seneste.fra) {
                        Text(String(format: NSLocalizedString("from %@", comment: "Jarvis: sender of the newest card"), fra))
                            .font(.system(size: 11))
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: Hvad huset laver lige nu

    @ViewBuilder
    private var husetBlok: some View {
        if let huset = jarvis.svar?.huset {
            VStack(alignment: .leading, spacing: 3) {
                if let ord = jarvisOrd(huset.ord) {
                    JarvisRaekke(
                        ikon: "house.fill",
                        tekst: ord,
                        farve: .white.opacity(0.9),
                        ikonfarve: jarvisTilstandsfarve(huset.tilstand),
                        stoerrelse: 13,
                        linjer: 2
                    )
                }
                if let seneste = jarvisOrd(huset.seneste) {
                    let linje = jarvisOrd(huset.hvornaar).map { "\(seneste) · \($0)" } ?? seneste
                    Text(linje)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 19)
                }
            }
        }
    }

    // MARK: Agenterne

    /// Navn + prik, hvis der er plads til navnene; ellers bare prikkerne.
    @ViewBuilder
    private var agentRaekke: some View {
        if let agenter = jarvis.svar?.agenter, !agenter.isEmpty {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    ForEach(Array(agenter.enumerated()), id: \.offset) { _, agent in
                        HStack(spacing: 5) {
                            Circle()
                                .fill(jarvisAgentfarve(agent.tilstand))
                                .frame(width: 7, height: 7)
                            Text(jarvisOrd(agent.navn) ?? "")
                                .font(.system(size: 11))
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                        }
                        .help(agentHjaelp(agent))
                    }
                    Spacer(minLength: 0)
                }
                HStack(spacing: 7) {
                    ForEach(Array(agenter.enumerated()), id: \.offset) { _, agent in
                        Circle()
                            .fill(jarvisAgentfarve(agent.tilstand))
                            .frame(width: 7, height: 7)
                            .help(agentHjaelp(agent))
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(.leading, 2)
        }
    }

    // MARK: Bunden

    private var bundLinje: some View {
        HStack(alignment: .center, spacing: 10) {
            JarvisKnap(
                tekst: "Open the command center",
                ikon: "arrow.up.forward.app",
                url: jarvis.kommandocenterLink
            )
            if let mangler = jarvisOrd(jarvis.svar?.mangler?.first) {
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 9))
                        .padding(.top, 2)
                    Text(mangler)
                        .font(.system(size: 11))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(Color.gray.opacity(0.75))
            }
            Spacer(minLength: 0)
        }
    }

    private func agentHjaelp(_ agent: JarvisAgent) -> String {
        let navn = jarvisOrd(agent.navn) ?? "?"
        if let ord = jarvisOrd(agent.ord) { return "\(navn): \(ord)" }
        if let tilstand = jarvisOrd(agent.tilstand) { return "\(navn): \(tilstand)" }
        return navn
    }
}

// MARK: - Mærket i den sammenfoldede notch

/// Målene herunder er læst ud af husets egen kode, ikke gennem gennemsyn af et skilt:
///
/// • `getClosedNotchSize()` (boringNotch/sizing/matters.swift) giver den lukkede
///   notch: bredden er skærmens hul (standard 185 pt), højden er `Defaults[.notchHeight]`
///   / `screen.safeAreaInsets.top` / menulinjens højde — altså omkring 32-38 pt.
/// • `BoringViewModel.effectiveClosedNotchHeight` (models/BoringViewModel.swift)
///   er den højde igen, eller 0 når notchen er skjult i fuldskærm.
/// • Appens egne elementer i den lukkede notch bruger ét mål:
///   `max(0, effectiveClosedNotchHeight - 12)` i både bredde og højde —
///   `BoringFaceAnimation()` og albumbilledet plus visualizeren i
///   `MusicLiveActivity()` (begge i ContentView.swift).
///   Midterfeltet, der dækker selve hullet, er `closedNotchSize.width - 20`.
/// • Chin-bredden (ContentView.swift) lægger `2 * (h - 12) + 20` oveni, altså
///   venstre element + højre element + HStack'ens to mellemrum à 8 pt.
///
/// Fejlen 16/9: det gamle mærke satte et SF-symbol (`brain.head.profile`) i en
/// `.frame(width: (h - 12) + 12, alignment: .leading)`. En fast ramme klipper ikke —
/// symbolet plus tallet er bredere end rammen, så de væltede ud over notchens
/// `clipShape(NotchShape)` og hovedet blev skåret midt over.
/// Kuren: ingen SF-symbol. En cirkel med tallet inden i, nøjagtig `h - 12` i diameter,
/// så mærket har samme fodaftryk som husets egne elementer og aldrig kan flyde over.
///
/// Mærket er UÆNDRET af de to faner: den foldede notch viser stadig kun
/// antallet af kort der venter.
struct JarvisLukketMaerke: View {
    @EnvironmentObject var vm: BoringViewModel
    @ObservedObject private var jarvis = JarvisState.shared

    /// Prikkens diameter: samme mål som husets egne elementer i den lukkede notch.
    static func diameter(lukketHoejde: CGFloat) -> CGFloat {
        max(8, lukketHoejde - 12)
    }

    /// Hvor meget bredere den lukkede notch bliver af mærket:
    /// det tomme felt til venstre + prikken + HStack'ens to mellemrum à 8 pt.
    static func ekstraBredde(lukketHoejde: CGFloat) -> CGFloat {
        max(0, lukketHoejde - 12) + diameter(lukketHoejde: lukketHoejde) + 16
    }

    var body: some View {
        let hoejde = vm.effectiveClosedNotchHeight
        let d = Self.diameter(lukketHoejde: hoejde)
        HStack(spacing: 8) {
            // Venstre: tomt felt i samme mål som appens egne elementer.
            Rectangle()
                .fill(.clear)
                .frame(width: max(0, hoejde - 12), height: max(0, hoejde - 12))
            // Midten: selve hullet i skærmen.
            Rectangle()
                .fill(.black)
                .frame(width: max(0, vm.closedNotchSize.width - 20))
            // Højre: prikken med antallet. Intet når huset ikke venter på ham.
            ZStack {
                if jarvis.venterAntal > 0 {
                    Circle()
                        .fill(Color.effectiveAccent)
                    Text(verbatim: "\(jarvis.venterAntal)")
                        .font(.system(size: max(7, d * 0.5), weight: .semibold, design: .monospaced))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 1)
                }
            }
            .frame(width: d, height: d)
        }
        .frame(height: hoejde, alignment: .center)
    }
}

#Preview {
    JarvisView()
        .environmentObject(BoringViewModel())
        .frame(width: jarvisOpenNotchSize.width - 62, height: jarvisOpenNotchSize.height - 50)
        .background(.black)
        .preferredColorScheme(.dark)
}
