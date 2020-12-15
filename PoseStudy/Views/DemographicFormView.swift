//
//  QuestionnaireView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI
import FirebaseDatabase

struct DemographicFormView: View {
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    @State private var age: String = ""
    @State private var male = false
    @State private var female = false
    
    @State private var next = true
        
    var body: some View {
        let m = Binding<Bool>(get: { self.male }, set: { self.male = $0; self.female = false})
        let w = Binding<Bool>(get: { self.female }, set: { self.male = false; self.female = $0})
                
        VStack {
            Text("Persönliche Angaben").titleStyle()
            
            GroupBox(label: Text("Gender")) {
                Toggle(isOn: m) {
                    Text("Männlich")
                }.toggleStyle(CheckboxToggleStyle())
                Toggle(isOn: w) {
                    Text("Weiblich")
                }.toggleStyle(CheckboxToggleStyle())
            }.padding().padding(.top, 40)
            GroupBox(label: Text("Alter")) {
                TextField("Gib dein Alter an", text: $age).keyboardType(.numberPad)
            }.padding()
            
            Spacer()
            NavigationLink(
                destination: HealthFormView().navigationBarHidden(true),
                isActive: $next,
                label: {
                    Text("Weiter")
                }).buttonStyle(CustomButtonStyle()).simultaneousGesture(TapGesture().onEnded{
                    save()
                })
        }.environmentObject(status).environmentObject(polarApi)
    }
    
    private func save() {
        if (male == true || female == true) && age != "" {
            //let ref: DatabaseReference = Database.database().reference().child("Participant \(status.participantID)")
            //ref.updateChildValues(["Age": age, "Gender": male ? "männlich" : "weiblich"])
            
            self.next = false
        }
    }
}



struct DemographicFormView_Previews: PreviewProvider {
    static var previews: some View {
        DemographicFormView()
    }
}
