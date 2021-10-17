//
//  WelcomeViewModel.swift
//  PoseStudy
//
//  Created by Franziska Lang on 17.10.21.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import Network
import FirebaseStorage


final class WelcomeViewModel: ObservableObject {
    @ObservedObject var status = GlobalState()
    @ObservedObject var polarApi = PolarApiWrapper()
    
    @Published var selection: String? = nil
    @Published var ID: String = ""
    @Published var isCodeValide = false
    @Published var codeExists = false
    
    @Published var hasInternetConnection = false
    @Published var alertItem: AlertItem?
    
    @Published var wait = false

    private let ref: DatabaseReference = Database.database().reference()
    
    
    func start() {
        if hasInternetConnection && !ID.isEmpty {
            wait = true
            saveToDatabase()
        } else if ID.isEmpty {
            alertItem = AlertContext.IdMissing
        } else if !hasInternetConnection {
            alertItem = AlertContext.noInternetConnetion
        }
    }
    
    
    func observeID() {
        //If ID is valid check if ID already is used
        let refParticipants = ref.child("Participants")
        
        refParticipants.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild("Participant \(self.ID)") {
                
                let refParticipantWithID = refParticipants.child("Participant \(self.ID)")
                refParticipantWithID.observeSingleEvent(of: .value) { (snap) in
                    if snap.hasChild("Demographic") && snap.hasChild("Health Status") {
                        self.setData(selection: "WarmUp")
                        let refDay = refParticipants.child("Participant \(self.ID)").child("Day")
                        refDay.observeSingleEvent(of: .value) { (snap) in
                            if let value = snap.value as? Int {
                                self.status.day = value
                                refDay.setValue(value)
                            }
                        }
                    } else {
                        self.setData(selection: "Demographic")
                        self.status.day = 1
                    }
                }
            } else {
                let refParticipantID = refParticipants.child("Participant \(self.ID)")
                refParticipantID.setValue(["Participant ID": self.ID, "Day": 1])
                self.setData(selection: "Demographic")
                self.status.day = 1
            }
        }
    }
    
    func saveToDatabase() {
        status.userData.ID = ID
        
        ref.child("IDs").observeSingleEvent(of: .value) { (snap) in
            if snap.hasChild(self.ID) {
                self.observeID()
            }
            else {
                self.alertItem = AlertContext.IdMissing
                self.wait = false
            }
        }
    }
    
    func setData(selection: String) {
        self.selection = selection
        self.status.participantID = ID
        self.wait = false
    }
    
    func checkConnection() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                self.hasInternetConnection = true
            } else {
                NSLog("There's no internet connection.")
                self.hasInternetConnection = false
            }
        }
        monitor.start(queue: queue)
    }
}


