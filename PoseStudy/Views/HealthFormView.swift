//
//  Test.swift
//  PoseStudy
//
//  Created by Franziska Lang on 26.11.20.
//

import SwiftUI
import FirebaseDatabase

struct HealthFormView: View {
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    @State private var selection: String? = nil
    
    @State private var cardiovascular = false
    @State private var musculoskeletal = false
    @State private var neuromuscular = false
    @State private var nothing = false
    
    @State private var medicaments = false
    @State private var nomedicaments = false
            
    var body: some View {
        let yes = Binding<Bool>(get: { self.medicaments }, set: { self.medicaments = $0; self.nomedicaments = false})
        let no = Binding<Bool>(get: { self.nomedicaments }, set: { self.medicaments = false; self.nomedicaments = $0})
        
        VStack {
            NavigationLink(destination: WarmUpView().navigationBarHidden(true), tag: "WarmUp", selection: $selection) { EmptyView() }
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
            Button(action: save, label: {
                Text("Weiter")
            }).buttonStyle(CustomButtonStyle())
        }.environmentObject(status).environmentObject(polarApi)
    }
    
    private func save() {
        if (nomedicaments || medicaments) && (cardiovascular || musculoskeletal || neuromuscular || nothing) {
            
            //let ref: DatabaseReference = Database.database().reference().child("Participant \(self.status.participantID)")
            //ref.updateChildValues(["Medicaments": medicaments, "Her-Kreislauf": cardiovascular, "Muskel-Erkrankung": musculoskeletal, "Neuromuskuläre Erkrankung": neuromuscular, "Nichts": nothing])
            
            self.selection = "WarmUp"
        }
    }
}


struct HealthFormView_Previews: PreviewProvider {
    static var previews: some View {
        HealthFormView()
    }
}
