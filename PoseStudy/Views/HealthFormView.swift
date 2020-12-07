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
    
    @State var next = true
    
    var body: some View {
        let yes = Binding<Bool>(get: { self.medicaments }, set: { self.medicaments = $0; self.nomedicaments = false})
        let no = Binding<Bool>(get: { self.nomedicaments }, set: { self.medicaments = false; self.nomedicaments = $0})
        
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
                    }.padding().padding(.top, 40)
                    GroupBox(label: Text("Nimmst du regelmäßig Medikamente")) {
                        Toggle(isOn: yes) {
                            Text("Ja")
                        }.toggleStyle(CheckboxToggleStyle())
                        Toggle(isOn: no) {
                            Text("Nein")
                        }.toggleStyle(CheckboxToggleStyle())
                    }.padding()
                    Spacer()
                    NavigationLink(
                        destination: WarmUpView().navigationBarHidden(true),
                        isActive: $next,
                        label: {
                            Text("Weiter")
                        }).buttonStyle(CustomButtonStyle()).simultaneousGesture(TapGesture().onEnded{
                            save()
                        })
                }
            
        
    }
    
    private func save() {
        
        if (nomedicaments || medicaments) && (cardiovascular || musculoskeletal || neuromuscular || nothing) {
            
            //let ref: DatabaseReference = Database.database().reference().child("Participant \(self.data.participantID)")
            //ref.updateChildValues(["Medicaments": medicaments, "Her-Kreislauf": cardiovascular, "Muskel-Erkrankung": musculoskeletal, "Neuromuskuläre Erkrankung": neuromuscular, "Nichts": nothing])
            
            self.next = false
        }
    }
    
}


struct HealthFormView_Previews: PreviewProvider {
    @State var data: Dataset = Dataset()
    
    static var previews: some View {
        Preview()
    }
    
    struct Preview: View {
        @State var data: Dataset = Dataset()
        
        var body: some View {
            HealthFormView(data: $data)
            }
    }
}
