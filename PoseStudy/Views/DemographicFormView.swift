//
//  QuestionnaireView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI
import FirebaseDatabase

struct DemographicFormView: View {
    @State var age: String = ""
    @State private var male = false
    @State private var female = false
    
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
            }.padding()
            /*GroupBox(label: Text("Geschlecht")) {
                Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: Text("Picker")) {
                    Text("männlich").tag(1)
                    Text("weiblich").tag(2)
                }
            }.padding()*/
            GroupBox(label: Text("Alter")) {
                TextField("Gib dein Alter an", text: $age)
            }.padding()
            
            Spacer()
            NavigationLink(
                destination: HealthFormView(data: $data).navigationBarHidden(true),
                label: {
                    Text("Weiter")
                }).buttonStyle(CustomButtonStyle()).simultaneousGesture(TapGesture().onEnded{
                    save()
                })
            
            /*ProgressView(value: /*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/).accentColor(Color("darkgreen"))*/
        }
    }
    
    private func save() {
        let ref: DatabaseReference = Database.database().reference().child("Participant \(data.participantID)")
        ref.updateChildValues(["Age": age, "Gender": male ? "männlich" : "weiblich"])
    }
    
}



/*struct DemographicFormView_Previews: PreviewProvider {
    static var previews: some View {
        DemographicFormView()
    }
}*/
