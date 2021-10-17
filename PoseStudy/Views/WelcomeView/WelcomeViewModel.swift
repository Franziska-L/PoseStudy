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
        
    @Published var status = GlobalState()
    @Published var polarApi = PolarApiWrapper()
    
    @Published var selection: String? = nil
    @Published var ID: String = ""
    @Published var isCodeValide = false
    @Published var codeExists = false
    
    @Published var hasInternetConnection = false
    @Published var alertItem: AlertItem?
    
    @Published var wait = false

    
    
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
    
    
    func saveToDatabase() {
        status.userData.ID = ID
        let ref: DatabaseReference = Database.database().reference()
        
        let refID = ref.child("IDs")
        refID.observeSingleEvent(of: .value) { (snap) in
            if snap.hasChild(self.ID) {
                let refParticipants = ref.child("Participants")
                refParticipants.observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.hasChild("Participant \(self.ID)") {
                        let refParticipantWithID = refParticipants.child("Participant \(self.ID)")
                        refParticipantWithID.observeSingleEvent(of: .value) { (snap) in
                            if snap.hasChild("Demographic") && snap.hasChild("Health Status") {
                                self.status.participantID = self.ID
                                self.selection = "WarmUp"
                                self.wait = false
                                let refDay = refParticipants.child("Participant \(self.ID)").child("Day")
                                refDay.observeSingleEvent(of: .value) { (snap) in
                                    if let value = snap.value as? Int {
                                        self.status.day = value
                                        refDay.setValue(value)
                                    }
                                }
                            } else {
                                self.selection = "Demographic"
                                self.status.day = 1
                                self.status.participantID = self.ID
                                self.wait = false
                            }
                        }
                    } else {
                        let refParticipantID = refParticipants.child("Participant \(self.ID)")
                        refParticipantID.setValue(["Participant ID": self.ID, "Day": 1])
                        self.status.participantID = self.ID
                        self.status.day = 1
                        self.selection = "Demographic"
                        self.wait = false
                    }
                }
            }
            else {
                self.alertItem = AlertContext.IdMissing
                self.wait = false
            }
        }
        print(selection)
    }
    
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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


