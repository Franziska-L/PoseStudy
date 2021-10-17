//
//  Alerts.swift
//  PoseStudy
//
//  Created by Franziska Lang on 17.10.21.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
}

struct AlertContext {
    static let noInternetConnetion = AlertItem(title: Text(String.connection), message: Text("Bitte stelle eine Verbindung zum Internet her."))
   
    static let IdMissing = AlertItem(title: Text("Falsche ID"), message: Text("Gib die ID ein, die du zu Beginn der Studie bekommen hast."))
}
