//
//  QuestionnaireView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI
import FirebaseDatabase

struct DemographicFormView: View {
    @State private var age: String = ""
    @State private var male = false
    @State private var female = false
    
    @State private var next = true
    
    @Binding var data: Dataset
    
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
                TextField("Gib dein Alter an", text: $age)
            }.padding()
            
            Spacer()
            NavigationLink(
                destination: HealthFormView(data: $data).navigationBarHidden(true),
                isActive: $next,
                label: {
                    Text("Weiter")
                }).buttonStyle(CustomButtonStyle()).simultaneousGesture(TapGesture().onEnded{
                    save()
                })
        }
    }
    
    private func save() {
        if (male == true || female == true) && age != "" {
            //let ref: DatabaseReference = Database.database().reference().child("Participant \(data.participantID)")
            //ref.updateChildValues(["Age": age, "Gender": male ? "männlich" : "weiblich"])
            
            self.next = false
        }
    }
}



struct DemographicFormView_Previews: PreviewProvider {
    @State var data: Dataset = Dataset()
    
    static var previews: some View {
        Preview()
    }
    
    struct Preview: View {
        @State var data: Dataset = Dataset()
        
        var body: some View {
            DemographicFormView(data: $data)
            }
    }
}
