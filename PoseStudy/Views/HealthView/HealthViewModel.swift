//
//  HealthViewModel.swift
//  PoseStudy
//
//  Created by Franziska Lang on 17.10.21.
//

import SwiftUI
import FirebaseDatabase

final class HealthViewModel: ObservableObject {
    var status: GlobalState?
    var polarApi: PolarApiWrapper?
      
    func setup(status: GlobalState, polarApi: PolarApiWrapper) {
        self.status = status
        self.polarApi = polarApi
    }
    
    @Published var selection: String? = nil
    @Published var alert = false
    
    @Published var cardiovascular = false
    @Published var musculoskeletal = false
    @Published var neuromuscular = false
    @Published var highBlood = false
    @Published var diabetes = false
    @Published var nothing = false
    
    @Published var medicaments = false
    @Published var nomedicaments = false
    
    @Published var other = ""
    @Published var never = false
    @Published var more = false
    @Published var less = false
    
    
    func save() {
        if (nomedicaments || medicaments) && (cardiovascular || musculoskeletal || neuromuscular || nothing || diabetes || highBlood) && (less || more || never) {
            var fitness = ""
            if more {
                fitness = "3 mal oder öfter"
            } else if less {
                fitness = "Weniger als 3 mal"
            } else {
                fitness = "Nie"
            }
            status?.userData.health.cardiovascularDiseases = "\(cardiovascular)"
            status?.userData.health.musculoskeletalDiseases = "\(musculoskeletal)"
            status?.userData.health.neuromuscularDisorder = "\(neuromuscular)"
            status?.userData.health.medication = "\(medicaments)"
            status?.userData.health.highBlood = "\(highBlood)"
            status?.userData.health.diabetes = "\(diabetes)"
            status?.userData.health.nothing = "\(nothing)"
            status?.userData.health.other = other
            
            let ref: DatabaseReference = Database.database().reference().child("Participants").child("Participant \(status?.participantID)").child("Health Status")
            ref.updateChildValues(["Medication": "\(medicaments)", "Cardiovascular diseases": "\(cardiovascular)", "Musculoskeletal diseases": "\(musculoskeletal)", "Neuromuscular disorder": "\(neuromuscular)", "High Blood": "\(highBlood)", "Diabetes": "\(neuromuscular)", "Nothing": "\(nothing)", "Other": other, "Fitness": fitness])
            
            self.selection = "WarmUp"
        } else {
            alert = true
        }
    }
    
}
