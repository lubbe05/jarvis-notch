//
//  sizeMatters.swift
//  boringNotch
//
//  Created by Harsh Vardhan  Goswami  on 05/08/24.
//

import Defaults
import Foundation
import SwiftUI

let downloadSneakSize: CGSize = .init(width: 65, height: 1)
let batterySneakSize: CGSize = .init(width: 160, height: 1)

let shadowPadding: CGFloat = 20
let openNotchSize: CGSize = .init(width: 640, height: 190)

// JARVIS: de to Jarvis-faner folder notchen større ud end husets egne faner.
// Lauritz 16/9: «vil gerne have den lidt større så jeg kan se flere ting — den
// behøver ikke være samme størrelse som de andre sider». Tallene i ord (fx
// «cirka 167 tusind kroner» og «to tusind kroner op siden seneste lukkekurs»)
// er lange sætninger, ikke tal, og de må ikke klippes med «…».
// HØJDERNE ER REGNET EFTER INDHOLDET (Lauritz 16/9 23:5x: «notchen inde på
// aktiesiden går ligesom op af, så jeg kan ikke se hele skærmen»). 260 pt var
// for lidt til Aktier-fanen efter at dagens linje, markedsvejret og kontanterne
// kom til — og en flade der er højere end sin ramme, vælter ud over TOPPEN,
// altså op bag hakket hvor man ikke kan læse den.
//
// AF FANENS HØJDE GÅR DER TRE TING FRA, før indholdet får noget:
// husets egen header (`max(24, effectiveClosedNotchHeight)`, op til 38 pt),
// `NotchLayout`s eget mellemrum (8) og `mainLayout`s bundpolstring (12) — 58 pt.
//
//   Aktier (760 × 310 -> 252 pt til indhold):
//     dagens linje 20 + værdi og beløb på SAMME linje 34
//     + markedsvejr og kontanter SIDE OM SIDE 32 + regnskab 32
//     + labbene (2 linjer) 32 + «Åbn Investor» 28
//     + mellemrum 40 + 5 + top 2                                  = 225
//     -> 27 pt luft, nok til at dagens linje bryder over to linjer.
//
//   Jarvis (780 × 340 -> 282 pt til indhold):
//     toplinjen 47 + FEM kortrækker à 24 med mellemrum 128
//     + tekstfeltet 26 + «Åbn Kommandocenter» 28
//     + mellemrum 32 + top 2                                      = 263
//     -> 19 pt luft. Rækkerne er ÉN linje hver, og det er derfor tallet
//        holder; kan de fem alligevel ikke være der, viser fanen fire eller
//        tre (`venteListe`), og de ældste står stadig i Kommandocentret.
//
//     18/9, CLAUDE-RÆKKEN: venter Claude på et svar eller beder han om lov,
//     står der en fast række øverst på fanen (24 pt + 8 pt mellemrum = 32), og
//     så viser kortlisten FIRE rækker i stedet for fem (-26 pt). Regnestykket
//     bliver 263 + 32 - 26 = 269 -> 13 pt luft. De to kort der ryger, er de
//     ældste, og de står stadig i Kommandocentret.
//     Forbrugsringen koster INTET: den står INDE i toplinjens 47 pt, mellem
//     badgen og husets blok, og er selv 47 pt høj (ring 32 + 4 + strimmel 11).
//     I bredden: badgen ~185 + 12 + ringblokken 136 + 12 + husets blok 320
//     = 665 af de ~706 pt fanen har indvendigt.
//
// Regnestykket er aritmetik og ikke en måling på en skærm — der er ingen Mac i
// huset. Derfor står der to VÆRN under det: `ContentView` top-justerer den åbne
// flade, så et uheld kun kan vælte NEDAD, og hver af de to faner skruer selv ned
// (labbenes sætning, antallet af rækker) før noget kan nå at vælte.
//
// De to faner behøver netop ikke være lige store — det var Lauritz' egen
// sætning — og Aktier holdes en smule mindre end Jarvis, som han bad om.
let jarvisAktierNotchSize: CGSize = .init(width: 760, height: 310)
let jarvisOpenNotchSize: CGSize = .init(width: 780, height: 340)

/// Vinduet har én fast størrelse hele appens levetid (det oprettes én gang i
/// `createBoringNotchWindow` og flyttes kun), så det skal kunne rumme den
/// STØRSTE åbne flade. Selve notchen er stadig præcis `vm.notchSize` bred og
/// høj — `ContentView` spænder den åbne flade fast på det mål — så de øvrige
/// faner beholder deres 640 × 190.
let windowSize: CGSize = .init(
    width: max(openNotchSize.width,
               max(jarvisOpenNotchSize.width, jarvisAktierNotchSize.width)),
    height: max(openNotchSize.height,
                max(jarvisOpenNotchSize.height, jarvisAktierNotchSize.height))
        + shadowPadding
)

/// Den åbne flade for en bestemt fane.
func aabenNotchStoerrelse(for visning: NotchViews) -> CGSize {
    switch visning {
    case .jarvis: return jarvisOpenNotchSize
    case .jarvisAktier: return jarvisAktierNotchSize
    case .home, .shelf: return openNotchSize
    }
}
let cornerRadiusInsets: (opened: (top: CGFloat, bottom: CGFloat), closed: (top: CGFloat, bottom: CGFloat)) = (opened: (top: 19, bottom: 24), closed: (top: 6, bottom: 14))

enum MusicPlayerImageSizes {
    static let cornerRadiusInset: (opened: CGFloat, closed: CGFloat) = (opened: 13.0, closed: 4.0)
    static let size = (opened: CGSize(width: 90, height: 90), closed: CGSize(width: 20, height: 20))
}

@MainActor func getScreenFrame(_ screenUUID: String? = nil) -> CGRect? {
    var selectedScreen = NSScreen.main

    if let uuid = screenUUID {
        selectedScreen = NSScreen.screen(withUUID: uuid)
    }
    
    if let screen = selectedScreen {
        return screen.frame
    }
    
    return nil
}

@MainActor func getClosedNotchSize(screenUUID: String? = nil) -> CGSize {
    // Default notch size, to avoid using optionals
    var notchHeight: CGFloat = Defaults[.nonNotchHeight]
    var notchWidth: CGFloat = 185

    var selectedScreen = NSScreen.main

    if let uuid = screenUUID {
        selectedScreen = NSScreen.screen(withUUID: uuid)
    }

    // Check if the screen is available
    if let screen = selectedScreen {
        // Calculate and set the exact width of the notch
        if let topLeftNotchpadding: CGFloat = screen.auxiliaryTopLeftArea?.width,
           let topRightNotchpadding: CGFloat = screen.auxiliaryTopRightArea?.width
        {
            notchWidth = screen.frame.width - topLeftNotchpadding - topRightNotchpadding + 4
        }

        // Check if the Mac has a notch
        if screen.safeAreaInsets.top > 0 {
            // This is a display WITH a notch - use notch height settings
            notchHeight = Defaults[.notchHeight]
            if Defaults[.notchHeightMode] == .matchRealNotchSize {
                notchHeight = screen.safeAreaInsets.top
            } else if Defaults[.notchHeightMode] == .matchMenuBar {
                notchHeight = screen.frame.maxY - screen.visibleFrame.maxY
            }
        } else {
            // This is a display WITHOUT a notch - use non-notch height settings
            notchHeight = Defaults[.nonNotchHeight]
            if Defaults[.nonNotchHeightMode] == .matchMenuBar {
                notchHeight = screen.frame.maxY - screen.visibleFrame.maxY
            }
        }
    }

    return .init(width: notchWidth, height: notchHeight)
}
