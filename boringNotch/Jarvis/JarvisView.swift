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
//  16/9 AFTEN blev fanen et rigtigt kommandocenter: de kort der venter, står
//  som en liste med «Godkend» og «Afvis», og nederst kan han skrive en opgave.
//  Notchen afgør stadig intet selv — hvert tryk går gennem husets EGNE døre,
//  se `JarvisSkriver`. Er der ingen `skriv`-blok i husets svar, er der hverken
//  knapper eller tekstfelt: så har huset ikke sagt hvem der trykker, og en
//  knap der ikke kan virke, hører ikke på en skærm.
//

import AppKit
import Defaults
import SwiftUI

// MARK: - Den udfoldede visning

struct JarvisView: View {
    @EnvironmentObject var vm: BoringViewModel
    @ObservedObject private var jarvis = JarvisState.shared
    /// Sandt mens en opgave er på vej i køen. Kun til Send-knappen.
    @State private var sender: Bool = false

    var body: some View {
        JarvisRamme {
            indhold
        }
    }

    private var indhold: some View {
        VStack(alignment: .leading, spacing: 8) {
            topLinje
            venteListe
            Spacer(minLength: 0)
            skrivLinje
            bundLinje
        }
        .padding(.horizontal, 6)
        .padding(.top, 2)
        // Toppen står fast: vælter noget, vælter det nedad.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Øverst: hvor mange venter, og hvad huset laver

    private var topLinje: some View {
        HStack(alignment: .top, spacing: 12) {
            HStack(spacing: 8) {
                ZStack {
                    Capsule()
                        .fill(jarvis.venterAntal > 0 ? Color.effectiveAccent : Color.gray.opacity(0.25))
                        .frame(width: jarvis.venterAntal > 9 ? 30 : 24, height: 22)
                    Text(verbatim: "\(jarvis.venterAntal)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(jarvis.venterAntal > 0 ? .white : .gray)
                }
                Text(jarvisOrd(jarvis.svar?.venter?.ord)
                     ?? NSLocalizedString("Waiting for you", comment: "Jarvis: cards waiting"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(jarvis.venterAntal > 0 ? .white : .gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            husetBlok
                .frame(width: 320, alignment: .topLeading)
        }
    }

    /// Hvad huset laver lige nu, hvad det sidst leverede, og brevene.
    /// Står til højre, fordi midten nu tilhører kortene han skal svare på.
    @ViewBuilder
    private var husetBlok: some View {
        if let huset = jarvis.svar?.huset {
            VStack(alignment: .leading, spacing: 2) {
                // ÉN LINJE PR. SÆTNING HER, og det er en højde-beslutning:
                // blokken står ved siden af badgen, så alt den bruger, er højde
                // kortlisten ikke får. Husets sætninger er korte («natten
                // arbejder på opgaverne lige nu»), og hele leverancen kan læses
                // i Kommandocentret. Kortene er det han skal svare på.
                if let ord = jarvisOrd(huset.ord) {
                    JarvisRaekke(
                        ikon: "house.fill",
                        tekst: ord,
                        farve: .white.opacity(0.9),
                        ikonfarve: jarvisTilstandsfarve(huset.tilstand),
                        stoerrelse: 12,
                        linjer: 1
                    )
                }
                if let seneste = jarvisOrd(huset.seneste) {
                    let linje = jarvisOrd(huset.hvornaar).map { "\(seneste) · \($0)" } ?? seneste
                    Text(linje)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.leading, 19)
                }
                if let ord = jarvisOrd(jarvis.svar?.breve?.ord), jarvis.breveAntal > 0 {
                    JarvisRaekke(ikon: "envelope.fill", tekst: ord,
                                 farve: Color.gray, stoerrelse: 10, linjer: 1)
                }
            }
        }
    }

    // MARK: Kortene han kan svare på

    /// Listen — og den giver efter i ANTAL RÆKKER, ikke i toppen.
    ///
    /// Lauritz 16/9 23:5x om Aktier-fanen: «notchen går ligesom op af». Samme
    /// fare her: bryder to af de fem titler over to linjer, bliver fladen
    /// højere end notchen, og et barn der er højere end sin ramme, vælter ud
    /// over toppen. Fanens højde er målt til fem ÉN-linjede rækker
    /// (`jarvisOpenNotchSize`), og `ViewThatFits` tager fire eller tre hvis fem
    /// ikke kan være der. De kort der ryger, er de ÆLDSTE — listen er sorteret
    /// med de nyeste først — og de står stadig i Kommandocentret, som knappen
    /// nedenunder åbner.
    @ViewBuilder
    private var venteListe: some View {
        let liste = jarvis.venterListe
        if !liste.isEmpty {
            ViewThatFits(in: .vertical) {
                raekker(liste)
                raekker(Array(liste.prefix(4)))
                raekker(Array(liste.prefix(3)))
                raekker(Array(liste.prefix(2)))
                raekker(Array(liste.prefix(1)))
            }
        } else if jarvis.venterAntal > 0,
                  let seneste = jarvis.svar?.venter?.seneste,
                  jarvisOrd(seneste.titel) != nil {
            // Der venter kort, men husets svar bar ingen liste (en ældre bro).
            // Så bliver det ene gamle kort stående — uden knapper, for vi ved
            // ikke om det må dømmes.
            senesteKort(seneste)
        } else {
            // Intet venter. Så er agenterne det der er værd at se.
            agentRaekke
        }
    }

    private func raekker(_ liste: [JarvisVenterKort]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(liste, id: \.raekkeId) { kort in
                kortRaekke(kort)
            }
        }
    }

    /// Én linje: slags · titel · afsender, og til højre Godkend/Afvis.
    ///
    /// Titlen er klikbar og åbner PRÆCIS det kort — så han kan læse resten før
    /// han dømmer, hvis linjen ikke er nok.
    private func kortRaekke(_ kort: JarvisVenterKort) -> some View {
        let id = kort.id ?? ""
        return HStack(alignment: .center, spacing: 7) {
            if let slags = jarvisOrd(kort.slags) {
                Text(slags)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .lineLimit(1)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(Capsule().fill(Color.gray.opacity(0.18)))
            }
            JarvisLinkRaekke(url: kortLink(id)) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    // ÉN LINJE PR. KORT. Titlen er i forvejen klippet til 60
                    // tegn af huset, og 60 tegn i 12 punkter er omkring 400 pt —
                    // der er plads. Ét kort der bryder over to linjer, ville
                    // skubbe et andet kort ud af listen, og fem kort man kan
                    // svare på, er mere værd end én titel der står helt ud.
                    // Hele titlen står i Kommandocentret, som et klik åbner.
                    Text(jarvisOrd(kort.titel) ?? "")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if let fra = jarvisOrd(kort.fra) {
                        Text(fra)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.gray)
                            .lineLimit(1)
                            .layoutPriority(-1)
                    }
                }
            }
            Spacer(minLength: 4)
            domKnapper(id: id, kanGodkendes: kort.kanGodkendes == true)
        }
    }

    /// Godkend/Afvis — eller det ord der står i stedet for dem.
    ///
    /// FIRE TILSTANDE, og hver af dem siger sandheden:
    ///   * svaret er undervejs         -> en snurre, ingen knapper (intet dobbelttryk)
    ///   * han HAR svaret              -> «Godkendt»/«Afvist», til kortet er væk
    ///   * huset siger `kan_godkendes: false` -> ingen knapper. Et fejl-kort vil
    ///     lægges i køen igen, ikke godkendes, og den knap hører i
    ///     Kommandocentret hvor opgaveteksten står ved siden af.
    ///   * huset har ikke sagt hvem der trykker -> ingen knapper. Navnet er hele
    ///     forslags-trinnet; kunne vi fylde det ud selv, var trinnet pynt.
    @ViewBuilder
    private func domKnapper(id: String, kanGodkendes: Bool) -> some View {
        if let ord = jarvis.besvaret[id] {
            Text(ord)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.gray)
                .lineLimit(1)
        } else if jarvis.besvarer.contains(id) {
            ProgressView()
                .controlSize(.small)
                .scaleEffect(0.7)
        } else if kanGodkendes && jarvis.kanDoemme && !id.isEmpty {
            HStack(spacing: 5) {
                JarvisLilleKnap(tekst: "Approve", farve: .green) { doem(id, true) }
                JarvisLilleKnap(tekst: "Reject", farve: .red) { doem(id, false) }
            }
        }
    }

    /// Det dybe link til ét kort. Bygges af husets egen adresse, aldrig af os.
    private func kortLink(_ id: String) -> URL? {
        guard !id.isEmpty,
              let kommando = jarvis.svar?.links?.kommandocenter,
              let url = URL(string: "\(kommando)?kort=\(id)")
        else { return jarvis.kommandocenterLink }
        return url
    }

    /// Trykket. Kortet forsvinder IKKE af sig selv — det gør det ved næste
    /// poll, når huset siger det er væk. Indtil da står ordet «Godkendt», så
    /// han kan se at trykket kom igennem uden at listen hopper under hånden.
    private func doem(_ id: String, _ godkend: Bool) {
        guard !id.isEmpty, !jarvis.besvarer.contains(id) else { return }
        let navn = jarvis.skriverNavn
        guard !navn.isEmpty else { return }
        jarvis.besvarer.insert(id)
        Task { @MainActor in
            let svar = await JarvisSkriver.shared.doem(kortId: id, godkend: godkend, af: navn)
            jarvis.besvarer.remove(id)
            switch svar {
            case .ok(let ord):
                jarvis.besvaret[id] = ord
                jarvis.visKvittering(ord)
            case .nej(let hvorfor):
                jarvis.visKvittering(hvorfor)
            case .ikkeKontakt:
                jarvis.visKvittering(
                    NSLocalizedString("Jarvis can't be reached",
                                      comment: "Quiet error line in the Jarvis view"))
            }
        }
    }

    /// Det gamle ene kort — står kun hvis husets svar ikke bærer en liste.
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

    // MARK: Sig det til Jarvis

    /// Tekstfeltet. Går gennem `POST /tasks` — samme dør som appens Kø-skærm,
    /// med de samme værn (pengehandels-vagten, dublet-vagten, kanoniseringen).
    /// Feltet findes kun når huset har sagt HVILKEN kø opgaven hører i: et tomt
    /// mål er husets fælles pulje, altså en anden kø end den han taler til.
    @ViewBuilder
    private var skrivLinje: some View {
        if jarvis.kanSkriveOpgave {
            HStack(spacing: 8) {
                TextField("", text: $jarvis.udkast, prompt: Text("Tell Jarvis…"))
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(Color.gray.opacity(0.16))
                    )
                    .onSubmit { send() }

                if sender {
                    ProgressView()
                        .controlSize(.small)
                        .scaleEffect(0.7)
                } else {
                    JarvisLilleKnap(tekst: "Send", farve: Color.effectiveAccent) { send() }
                        .disabled(jarvis.udkast.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func send() {
        let tekst = jarvis.udkast.trimmingCharacters(in: .whitespacesAndNewlines)
        let maal = jarvis.opgaveMaal
        guard !tekst.isEmpty, !maal.isEmpty, !sender else { return }
        sender = true
        Task { @MainActor in
            let svar = await JarvisSkriver.shared.laegIKoeen(tekst: tekst, maal: maal)
            sender = false
            switch svar {
            case .ok(let ord):
                // Feltet ryddes FØRST når huset har taget imod. Sagde det nej,
                // står teksten der endnu, så han ikke skal skrive den igen.
                jarvis.udkast = ""
                jarvis.visKvittering(ord)
            case .nej(let hvorfor):
                jarvis.visKvittering(hvorfor)
            case .ikkeKontakt:
                jarvis.visKvittering(
                    NSLocalizedString("Jarvis can't be reached",
                                      comment: "Quiet error line in the Jarvis view"))
            }
        }
    }

    // MARK: Agenterne

    /// Navn + prik, hvis der er plads til navnene; ellers bare prikkerne.
    /// Står kun når der ikke venter kort — så har listen pladsen.
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
                agentPrikker
            }
            .padding(.leading, 2)
        }
    }

    @ViewBuilder
    private var agentPrikker: some View {
        if let agenter = jarvis.svar?.agenter, !agenter.isEmpty {
            HStack(spacing: 6) {
                ForEach(Array(agenter.enumerated()), id: \.offset) { _, agent in
                    Circle()
                        .fill(jarvisAgentfarve(agent.tilstand))
                        .frame(width: 7, height: 7)
                        .help(agentHjaelp(agent))
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func agentHjaelp(_ agent: JarvisAgent) -> String {
        let navn = jarvisOrd(agent.navn) ?? "?"
        if let ord = jarvisOrd(agent.ord) { return "\(navn): \(ord)" }
        if let tilstand = jarvisOrd(agent.tilstand) { return "\(navn): \(tilstand)" }
        return navn
    }

    // MARK: Bunden

    /// Knappen, den ene kvitteringslinje, og prikkerne når listen tog pladsen.
    private var bundLinje: some View {
        HStack(alignment: .center, spacing: 10) {
            JarvisKnap(
                tekst: "Open the command center",
                ikon: "arrow.up.forward.app",
                url: jarvis.kommandocenterLink
            )
            if let ord = jarvisOrd(jarvis.kvittering) {
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 10))
                        .padding(.top, 2)
                    Text(ord)
                        .font(.system(size: 11))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(Color.effectiveAccent)
            } else if let mangler = jarvisOrd(jarvis.svar?.mangler?.first) {
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
            if !jarvis.venterListe.isEmpty {
                agentPrikker
                    .fixedSize()
            }
        }
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
/// Mærket er UÆNDRET af de to faner og af knapperne: den foldede notch viser
/// stadig kun antallet af kort der venter.
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
        .frame(width: jarvisOpenNotchSize.width - 62,
               height: jarvisOpenNotchSize.height - 46)
        .background(.black)
        .preferredColorScheme(.dark)
}
