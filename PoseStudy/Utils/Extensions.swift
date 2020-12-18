//
//  Extensions.swift
//  PoseStudy
//
//  Created by Franziska Lang on 15.12.20.
//

import Foundation
import SwiftUI

extension Color {
    static let darkgray = Color("darkgray")
    static let darkgreen = Color ("darkgreen")
    static let lightgreen = Color ("lightgreen")
}

extension String {
    //Warm up
    static let warmup = "Wärme dich kurz auf, bevor du mit den Übungen beginnst"
    
    //Sit Up Instruction
    static let exerciseInstr = "Richtige Ausführung:"
    static let exerciseInstr1 = "Hebe und senke deinen Körper mit den Armen bis zum Boden."
    static let exerciseInstr2 = "Halte dabei den Rücken gerade und den Kopf in Verlängerung der Wirbelsäule."
    static let exerciseInstr3 = "Achte auf eine feste Körpermitte."
    static let exerciseInstr4 = "Wenn die Übung auf den Füßen zu anstrengend ist, gehe auf die Knie. Bitte entscheide dich aber vorab, ob du die Übungen auf den Knien ausführen willst oder nicht."
    
    static let startInstr = "Als nächstes wirst du Liegestützen machen bis zur maximalen Erschöpfung. Nimm auch die Wiederholung mit, die du nicht mehr schaffen würdest. \n\nWische nach links, um die nächste Anweisung zu lesen."
    static let polarDeviceIntr = "Lege jetzt den Brustgurt an. Befeuchte dazu zunächst den Elektrodenbereich des Gurtes. Lege den Gurt um die Brust und stelle ihn so ein, dass er fest sitzt."
    static let connectInstr = "Verbinde das Pulsmessgerät mit dem Handy."
    static let positionInstr = "Stelle das Handy auf dem Handyhalter und positioniere diesen so, dass dein gesamter Körper seitlich zu sehen ist.\n\nWenn alles bereit ist kann es los gehen."
    
    //Buttons
    static let next = "Weiter"
    static let go = "Los"
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
