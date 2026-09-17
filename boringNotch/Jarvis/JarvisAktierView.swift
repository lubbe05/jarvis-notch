//
//  JarvisAktierView.swift
//  boringNotch
//
//  Fanen «Aktier». Lauritz 16/9: «lav en til aktier, hvor jeg kan se hvor
//  meget jeg er oppe i dag».
//
//  Det vigtigste står øverst og stort: depotets værdi i ord, og dagens
//  bevægelse i ord med retning og farve — grøn op, rød ned, grå uændret.
//  Farven kommer fra `depot.retning` (maskinfeltet), aldrig fra sætningen.
//
//  16/9 AFTEN kom husets korte linje øverst: «Depotet er op, mest SNDK»
//  (`depot.dagens_ord`). Den siger retningen OG papiret der trak mest, i én
//  sætning han kan læse i forbifarten — og beløbslinjen lige under bærer
//  «siden seneste lukkekurs». Bemærk at huset med vilje IKKE skriver «i dag»:
//  kursbrønden fyldes én gang i døgnet, så parret kurs/forrige lukkekurs
//  beskriver den senest LUKKEDE handelsdag, og «i dag» ville være forkert fire
//  dage ud af syv. Vi omskriver ikke husets sætninger.
//
//  Dertil to linjer huset kan lægge ind ved siden af: markedsvejret og
//  kontanterne. Er nøglen der, står linjen; er den ikke, findes linjen ikke.
//
//  HØJDEN ER EN REGEL HER (Lauritz 16/9 23:5x: «notchen inde på aktiesiden går
//  ligesom op af, så jeg kan ikke se hele skærmen»). Da de tre nye linjer kom
//  til, blev indholdet højere end den åbne notch, og en flade der er højere end
//  sin ramme, vælter ud over TOPPEN — op bag hakket. Tre ting holder det nede:
//
//    1. **Bredden bruges.** Værdien og beløbet står på SAMME linje, og
//       markedsvejret og kontanterne står SIDE OM SIDE. 698 pt er rigeligt til
//       to spalter, og to spalter er to linjer sparet.
//    2. **Laboratoriernes sætning er det der giver efter.** Den er den længste
//       og den mindst tidskritiske (den flytter sig kun på en måling), så den
//       falder fra tre linjer til to — og kan de ikke være der, til én.
//       Toppen giver ALDRIG efter: værdien og dagens linje er hele pointen.
//    3. **Fanen har sin egen højde** (`jarvisAktierNotchSize`), målt på
//       indholdet ovenfor, og `ContentView` top-justerer fladen, så et uheld
//       kun kan vælte nedad.
//
//  Fanen henter INTET selv. Den læser `depot`, `labs` og `links` af præcis
//  det svar Jarvis-fanen allerede har hentet: samme poller, samme cache,
//  ét kald hvert 20. sekund.
//
//  Huset skriver «siden seneste lukkekurs», ikke «i dag», og det er målt:
//  kursbrønden fyldes én gang i døgnet. Vi omskriver ikke husets sætninger.
//

import AppKit
import Defaults
import SwiftUI

struct JarvisAktierView: View {
    @EnvironmentObject var vm: BoringViewModel
    @ObservedObject private var jarvis = JarvisState.shared

    var body: some View {
        JarvisRamme {
            indhold
        }
    }

    @ViewBuilder
    private var indhold: some View {
        VStack(alignment: .leading, spacing: 8) {
            if jarvis.harDepotNoget || jarvisOrd(jarvis.svar?.labs?.ord) != nil {
                depotBlok
                husetsLinjer
                regnskabRaekke
                labsRaekke
            } else {
                // Tomt er et rigtigt svar. Ingen kasse med nuller, ingen
                // tomme pladser — én stille linje, og forklaringen står i
                // «mangler» nedenfor hvis der er en.
                Text("The house has nothing about the portfolio right now")
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            bundLinje
        }
        .padding(.horizontal, 6)
        .padding(.top, 2)
        // Toppen står fast. Er der mod forventning mere indhold end plads,
        // vælter det nedad — aldrig op bag hakket.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Værdien og dagens bevægelse — det vigtigste

    @ViewBuilder
    private var depotBlok: some View {
        let depot = jarvis.svar?.depot
        VStack(alignment: .leading, spacing: 5) {
            // Husets korte linje øverst: retningen og papiret der trak mest.
            // Farven er `retning` — maskinfeltet — og ikke et ord i sætningen.
            if let dagens = jarvisOrd(depot?.dagensOrd) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    if let pil = jarvisRetningsikon(depot?.retning) {
                        Image(systemName: pil)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(jarvisRetningsfarve(depot?.retning))
                    }
                    Text(dagens)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(jarvisRetningsfarve(depot?.retning))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            // VÆRDIEN OG BELØBET PÅ SAMME LINJE. Fanen er 698 pt bred, og
            // «cirka 167 tusind kroner» fylder omkring 300 af dem i 24 punkter —
            // der er rigelig plads til beløbet ved siden af, og det er én linje
            // sparet på en flade hvor højden er det knappe.
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                if let vaerdi = jarvisOrd(depot?.vaerdiOrd) {
                    Text(vaerdi)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                if let aendring = jarvisOrd(depot?.dagsaendringOrd) {
                    // Beløbet og «siden seneste lukkekurs». Pilen står i linjen
                    // ovenfor — to pile om den samme bevægelse er én for meget.
                    Text(aendring)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(jarvisRetningsfarve(depot?.retning))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                } else if (depot?.retning ?? "").lowercased() == "ukendt" {
                    // Huset kunne ikke måle bevægelsen. Så siger vi netop DET —
                    // aldrig et nul, som ville blive læst som en måling.
                    Text("the movement could not be measured")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: To linjer huset kan lægge ind ved siden af

    /// Markedsvejret og kontanterne. Vi **viser** dem hvis nøglen er der og
    /// **springer dem over** hvis den ikke er — vi regner ikke på dem, og der
    /// står aldrig en tom plads hvor huset ikke havde noget at sige.
    @ViewBuilder
    private var husetsLinjer: some View {
        let vejr = jarvisOrd(jarvis.svar?.depot?.markedsvejrOrd)
        let kontanter = jarvisOrd(jarvis.svar?.depot?.kontanterOrd)
        if vejr != nil || kontanter != nil {
            // SIDE OM SIDE og ikke oven på hinanden: to spalter er én linje
            // sparet, og der er plads til dem. Er der kun én af dem, fylder den
            // hele bredden af sig selv.
            HStack(alignment: .top, spacing: 14) {
                if let ord = vejr {
                    JarvisRaekke(ikon: "cloud.sun.fill", tekst: ord,
                                 farve: .white.opacity(0.85), stoerrelse: 12,
                                 linjer: 2)
                }
                if let ord = kontanter {
                    JarvisRaekke(ikon: "banknote", tekst: ord,
                                 farve: .white.opacity(0.85), stoerrelse: 12,
                                 linjer: 2)
                }
            }
        }
    }

    // MARK: Næste regnskab

    @ViewBuilder
    private var regnskabRaekke: some View {
        if let regnskab = jarvis.svar?.depot?.naesteRegnskab,
           let navn = jarvisOrd(regnskab.ticker) ?? jarvisOrd(regnskab.navn),
           let naar = jarvisOrd(regnskab.datoOrd)
        {
            let saetning = String(
                format: NSLocalizedString(
                    "%1$@ reports earnings %2$@",
                    comment: "Jarvis: next earnings, e.g. MU reports earnings tomorrow"
                ),
                navn, naar
            )
            HStack(alignment: .top, spacing: 7) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
                    .frame(width: 12)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 1) {
                    Text(saetning)
                        .font(.system(size: 13))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    // Står der «foreløbig» i svaret, SKAL det stå på skærmen —
                    // ellers ser et gæt ud som en aftale.
                    if regnskab.foreloebig == true {
                        Text("preliminary date")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.gray)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: Laboratoriernes ene sætning

    @ViewBuilder
    private var labsRaekke: some View {
        if let ord = jarvisOrd(jarvis.svar?.labs?.ord) {
            // Sætningen ER husets dom; vi bygger ingen dom af den.
            //
            // DEN ER OGSÅ DEN DER GIVER EFTER, når højden bliver knap. Den er
            // den længste (op til 200 tegn) og den mindst tidskritiske — den
            // flytter sig kun på en måling, og hele stillingen står på
            // Investor-skærmen, som knappen nedenunder åbner. `ViewThatFits`
            // prøver to linjer først og tager én, hvis to ikke kan være der.
            // Toppen — værdien og dagens linje — giver ALDRIG efter.
            ViewThatFits(in: .vertical) {
                JarvisRaekke(ikon: "flask.fill", tekst: ord, farve: .gray,
                             stoerrelse: 12, linjer: 2)
                JarvisRaekke(ikon: "flask.fill", tekst: ord, farve: .gray,
                             stoerrelse: 11, linjer: 1)
            }
        }
    }

    // MARK: Bunden

    private var bundLinje: some View {
        HStack(alignment: .center, spacing: 10) {
            JarvisKnap(
                tekst: "Open Investor",
                ikon: "arrow.up.forward.app",
                url: jarvis.investorLink
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
}

#Preview {
    JarvisAktierView()
        .environmentObject(BoringViewModel())
        .frame(width: jarvisAktierNotchSize.width - 62,
               height: jarvisAktierNotchSize.height - 46)
        .background(.black)
        .preferredColorScheme(.dark)
}
