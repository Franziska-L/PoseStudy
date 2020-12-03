//
//  Test.swift
//  PoseStudy
//
//  Created by Franziska Lang on 26.11.20.
//

import SwiftUI
import FirebaseDatabase

struct HealthFormView: View {
    @State private var cardiovascular = false
    @State private var musculoskeletal = false
    @State private var neuromuscular = false
    @State private var nothing = false
    
    @State private var medicaments = false
    @State private var nomedicaments = false
    
    @Binding var data: Dataset
    
    var body: some View {
        let yes = Binding<Bool>(get: { self.medicaments }, set: { self.medicaments = $0; self.nomedicaments = false})
        let no = Binding<Bool>(get: { self.nomedicaments }, set: { self.medicaments = false; self.nomedicaments = $0})
        
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    Text("Angaben zum Gesundheitszustand").titleStyle()
                    GroupBox(label: Text("Hast du eine der folgenden Krankheiten")) {
                        Toggle(isOn: $cardiovascular) {
                            Text("Herz-Kreislauf-Krankheit")
                        }.toggleStyle(CheckboxToggleStyle())
                        Toggle(isOn: $musculoskeletal ) {
                            Text("Muskel-Skelett-Erkrankung")
                        }.toggleStyle(CheckboxToggleStyle())
                        Toggle(isOn: $neuromuscular) {
                            Text("Neuromuskuläre Erkrankung")
                        }.toggleStyle(CheckboxToggleStyle())
                        Toggle(isOn: $nothing) {
                            Text("Nichts")
                        }.toggleStyle(CheckboxToggleStyle())
                    }.padding()
                    GroupBox(label: Text("Nimmst du regelmäßig Medikamente")) {
                        Toggle(isOn: yes) {
                            Text("Ja")
                        }.toggleStyle(CheckboxToggleStyle())
                        Toggle(isOn: no) {
                            Text("Nein")
                        }.toggleStyle(CheckboxToggleStyle())
                    }.padding()
                    NavigationLink(
                        destination: WarmUpView().navigationBarHidden(true),
                        label: {
                            Text("Weiter")
                        }).buttonStyle(CustomButtonStyle()).simultaneousGesture(TapGesture().onEnded{
                            save()
                        })
                }
            }
        }
    }
    
    private func save() {
        let ref: DatabaseReference = Database.database().reference().child("Participant \(self.data.participantID)")
        //ref.updateChildValues(["Age": age, "Gender": male ? "männlich" : "weiblich"])
    }
    
}


/*struct HealthFormView_Previews: PreviewProvider {
    static var previews: some View {
        HealthFormView(data: $data)
    }
}*/
