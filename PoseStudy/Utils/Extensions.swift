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
    static let participants = "Participants"
    
    static let questions = "Bitte fülle erst alle Angaben aus."
    //Personal Questions
    static let gender = "Geschlecht"
    static let male = "männlich"
    static let female = "weiblich"
    static let age = "Alter"
    
    //Health
    static let medicaments = "Medikamente"
    static let heartDesease = "Herz-Kreislauf"
    static let musculoskeletal = "Muskel-Erkrankung"
    static let neuromuscular = "Neuromuskuläre Erkrankung"
    static let nothing = "Nichts"
    
    //Warm up
    static let warmup = "Wärme dich kurz auf, bevor du mit den Übungen beginnst"
    
    //Sit Up Instruction
    static let exerciseInstr = "Richtige Ausführung:"
    static let exerciseInstr1 = "Stelle die Hände etwa Schulterbreit auf den Boden und drehe sie leicht nach innen."
    static let exerciseInstr2 = "Halte den Rücken gerade und den Kopf in Verlängerung der Wirbelsäule."
    static let exerciseInstr3 = "Achte auf eine feste Körpermitte. Hebe und senke deinen Körper mit den Armen bis zum Boden."
    static let exerciseInstr4 = "Wenn die Übung auf den Füßen zu anstrengend ist, gehe auf die Knie. Entscheide dich aber vorab, ob du die Übungen auf den Knien ausführen willst oder nicht."
    
    static let startInstr = "Als nächstes wirst du Liegestützen machen bis zur maximalen Erschöpfung. Nimm auch die Wiederholung mit, die du nicht mehr schaffen würdest. \n\nWische nach links, um die nächste Anweisung zu lesen oder klicke auf den Weiter Button."
    static let polarDeviceIntr = "Lege jetzt den Brustgurt an. Befeuchte dazu zunächst den Elektrodenbereich des Gurtes. Lege den Gurt um die Brust und stelle ihn so ein, dass er fest sitzt."
    static let connectInstr = "Verbinde das Pulsmessgerät mit dem Handy."
    static let positionInstr = "Stelle das Handy quer auf dem Handyhalter. Positioniere den Handyhalter in ca. 1 m bis 1,5 m Abstand längs zu deinem Körper, sodass dein gesamter Körper seitlich zu sehen ist.\n\nWenn alles bereit ist kann es los gehen."
    
    //Buttons
    static let next = "Weiter"
    static let go = "Los"
    
    //Connection
    static let connection = "Verbindungsfehler"
    static let connectionMessage = "Das Polar Gerät ist noch nicht bereit. Bitte überprüfe die Verbindung zum Brustgurt. Stelle dazu sicher, dass der Brustgurt fest am Körper liegt."
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0))
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    func toString(millisec: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(millisec / 1000))
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd HH:mm:ss.SSSSSS"
        
        return formatter.string(from: date)
    }
    
    func toMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000.0)
    }
    
    func initTimestamp() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd HH:mm:ss.SSSSSS"
        
        return formatter.string(from: date)
    }
}

