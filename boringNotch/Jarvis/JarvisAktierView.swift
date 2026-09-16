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
//  Fanen henter INTET selv. Den læser `depot`, `labs` og `links` af præcis
//  det svar Jarvis-fanen allerede har hentet: samme poller, samme cache,
//  ét kald hvert minut.
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
        VStack(alignment: .leading, spacing: 10) {
            if jarvis.harDepotNoget || jarvisOrd(jarvis.svar?.labs?.ord) != nil {
                depotBlok
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
    }

    // MARK: Værdien og dagens bevægelse — det vigtigste

    @ViewBuilder
    private var depotBlok: some View {
        let depot = jarvis.svar?.depot
        VStack(alignment: .leading, spacing: 5) {
            if let vaerdi = jarvisOrd(depot?.vaerdiOrd) {
                Text(vaerdi)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let aendring = jarvisOrd(depot?.dagsaendringOrd) {
                HStack(alignment: .top, spacing: 6) {
                    if let pil = jarvisRetningsikon(depot?.retning) {
                        Image(systemName: pil)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(jarvisRetningsfarve(depot?.retning))
                            .padding(.top, 2)
                    }
                    Text(aendring)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(jarvisRetningsfarve(depot?.retning))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else if (depot?.retning ?? "").lowercased() == "ukendt" {
                // Huset kunne ikke måle bevægelsen. Så siger vi netop DET —
                // aldrig et nul, som ville blive læst som en måling.
                Text("the movement could not be measured")
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
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
            // Sætningen ER husets dom. Vi bygger ingen dom af den, og vi
            // klipper den ikke: op til 200 tegn får tre linjer her.
            JarvisRaekke(
                ikon: "flask.fill",
                tekst: ord,
                farve: .gray,
                stoerrelse: 12,
                linjer: 3
            )
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
        .frame(width: jarvisOpenNotchSize.width - 62, height: jarvisOpenNotchSize.height - 50)
        .background(.black)
        .preferredColorScheme(.dark)
}
