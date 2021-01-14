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
    @State private var alert = false
    
    @State private var cardiovascular = false
    @State private var musculoskeletal = false
    @State private var neuromuscular = false
    @State private var highBlood = false
    @State private var diabetes = false
    @State private var nothing = false
    
    @State private var medicaments = false
    @State private var nomedicaments = false
    
    @State private var other = ""
    @State private var never = false
    @State private var more = false
    @State private var less = false
            
    var body: some View {
        let yes = Binding<Bool>(get: { self.medicaments }, set: { self.medicaments = $0; self.nomedicaments = false})
        let no = Binding<Bool>(get: { self.nomedicaments }, set: { self.medicaments = false; self.nomedicaments = $0})
        
        let more = Binding<Bool>(get: { self.more }, set: { self.more = $0; self.less = false; self.never = false})
        let less = Binding<Bool>(get: { self.less }, set: { self.more = false; self.less = $0; self.never = false})
        let never = Binding<Bool>(get: { self.never }, set: { self.more = false; self.less = false; self.never = $0})
        ScrollView {
            VStack {
                NavigationLink(destination: WarmUpView().navigationBarHidden(true), tag: "WarmUp", selection: $selection) { EmptyView() }
                Text("Angaben zum Gesundheitszustand").titleStyle()
                GroupBox(label: Text("Hast du eine der folgenden Krankheiten?")) {
                    Toggle(isOn: $cardiovascular) {
                        Text("Herz-Kreislauf-Krankheit")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: $musculoskeletal ) {
                        Text("Muskel-Skelett-Erkrankung")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: $neuromuscular) {
                        Text("Neuromuskuläre Erkrankung")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: $highBlood) {
                        Text("Bluthochdruck")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: $diabetes) {
                        Text("Diabetes")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: $nothing) {
                        Text("Nichts")
                    }.toggleStyle(CheckboxToggleStyle())
                }.padding().padding(.top, 40)
                
                GroupBox(label: Text("Hast du eine andere chronische Krankheit?")) {
                    TextField("Sonstiges", text: $other)
                }.padding()
                
                GroupBox(label: Text("Nimmst du regelmäßig Medikamente?")) {
                    Toggle(isOn: yes) {
                        Text("Ja")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: no) {
                        Text("Nein")
                    }.toggleStyle(CheckboxToggleStyle())
                }.padding()
                
                GroupBox(label: Text("Wie oft trainierst du in der Woche?")) {
                    Toggle(isOn: more) {
                        Text("3 mal oder öfter")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: less) {
                        Text("Weniger als 3 mal")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: never) {
                        Text("Nie")
                    }.toggleStyle(CheckboxToggleStyle())
                }.padding()
                Spacer()
                Button(action: save, label: {
                    Text(String.next)
                }).buttonStyle(CustomButtonStyle())
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .environmentObject(status)
        .environmentObject(polarApi)
        .alert(isPresented: $alert, content: {
            Alert(title: Text(String.questions))
        })
    }
    
    private func save() {
        if (nomedicaments || medicaments) && (cardiovascular || musculoskeletal || neuromuscular || nothing || diabetes || highBlood) && (less || more || never) {
            status.userData.health.cardiovascularDiseases = "\(cardiovascular)"
            status.userData.health.musculoskeletalDiseases = "\(musculoskeletal)"
            status.userData.health.neuromuscularDisorder = "\(neuromuscular)"
            status.userData.health.medication = "\(medicaments)"
            status.userData.health.highBlood = "\(highBlood)"
            status.userData.health.diabetes = "\(diabetes)"
            status.userData.health.nothing = "\(nothing)"
            status.userData.health.other = other
            
            let ref: DatabaseReference = Database.database().reference().child("Participants").child("Participant \(self.status.participantID)").child("Health Status")
            ref.updateChildValues(["Medication": "\(medicaments)", "Cardiovascular diseases": "\(cardiovascular)", "Musculoskeletal diseases": "\(musculoskeletal)", "Neuromuscular disorder": "\(neuromuscular)", "High Blood": "\(highBlood)", "Diabetes": "\(neuromuscular)", "Nothing": "\(nothing)", "Other": other])
            
            self.selection = "WarmUp"
        } else {
            alert = true
        }
    }
}


struct HealthFormView_Previews: PreviewProvider {
    static var previews: some View {
        HealthFormView()
    }
}
