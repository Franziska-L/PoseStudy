//
//  DemographicViewModel.swift
//  PoseStudy
//
//  Created by Franziska Lang on 17.10.21.
//

import SwiftUI
import FirebaseDatabase

final class DemographicViewModel: ObservableObject {
    var status: GlobalState?
    var polarApi: PolarApiWrapper?
      
    func setup(status: GlobalState, polarApi: PolarApiWrapper) {
        self.status = status
        self.polarApi = polarApi
    }
    
    @Published var age: String = ""
    @Published var mass: String = ""
    @Published var hight: String = ""
    @Published var male = false
    @Published var female = false
    
    @Published var alert = false
        
    @Published var selection: String? = nil
    
    func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    func save() {
        if (male == true || female == true) && age != "" && mass != "" && hight != "" {
            status?.userData.demographic.age = age
            status?.userData.demographic.gender = male ? "männlich" : "weiblich"
            status?.userData.demographic.height = hight
            status?.userData.demographic.mass = mass
            let ref: DatabaseReference = Database.database().reference().child(String.participants).child("Participant \(status?.participantID)").child("Demographic")
            ref.updateChildValues(["Age": age, "Gender": male ? "männlich" : "weiblich", "Mass": mass, "Height": hight])
            
            self.selection = "Form"
        } else {
            alert = true
        }
    }

}
