//
//  DemographicViewModel.swift
//  PoseStudy
//
//  Created by Franziska Lang on 17.10.21.
//

import SwiftUI
import FirebaseDatabase

final class DemographicViewModel: ObservableObject {
    @Published var status: GlobalState?
    @Published var polarApi: PolarApiWrapper?
      
    func setup(status: GlobalState, polarApi: PolarApiWrapper) {
        self.status = status
        self.polarApi = polarApi
    }
    
    @Published var age: String = ""
    @Published var mass: String = ""
    @Published var height: String = ""
    @Published var male = false
    @Published var female = false
    
    @Published var alert = false
        
    @Published var selection: String? = nil
    
    func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    func save() {
        guard let ID = status?.participantID else {
            return
        }
        if (male == true || female == true) && age != "" && mass != "" && height != "" {
            status?.userData.demographic.age = age
            status?.userData.demographic.gender = male ? "männlich" : "weiblich"
            status?.userData.demographic.height = height
            status?.userData.demographic.mass = mass
            let ref: DatabaseReference = Database.database().reference().child(String.participants).child("Participant \(ID)").child("Demographic")
            ref.updateChildValues(["Age": age, "Gender": male ? "männlich" : "weiblich", "Mass": mass, "Height": height])
            
            self.selection = "Form"
        } else {
            alert = true
        }
    }

}
