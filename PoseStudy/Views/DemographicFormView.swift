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
    @State private var mass: String = ""
    @State private var hight: String = ""
    @State private var male = false
    @State private var female = false
    
    @State private var alert = false
        
    @State private var selection: String? = nil
        
    var body: some View {
        let m = Binding<Bool>(get: { self.male }, set: { self.male = $0; self.female = false})
        let w = Binding<Bool>(get: { self.female }, set: { self.male = false; self.female = $0})
        ScrollView {
            VStack {
                NavigationLink(destination: HealthFormView().navigationBarHidden(true), tag: "Form", selection: $selection) { EmptyView() }
                Text("Persönliche Angaben").titleStyle()
                
                GroupBox(label: Text(String.gender)) {
                    Toggle(isOn: m) {
                        Text(String.male)
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: w) {
                        Text(String.female)
                    }.toggleStyle(CheckboxToggleStyle())
                }.padding().padding(.top, 40)
                GroupBox(label: Text(String.age)) {
                    TextField("Gib dein Alter an", text: $age).keyboardType(.numberPad)
                }.padding()
                GroupBox(label: Text("Größe")) {
                    TextField("Gib dein Größe (in cm) an", text: $hight).keyboardType(.numberPad)
                }.padding()
                
                GroupBox(label: Text("Gewicht")) {
                    TextField("Gib dein Gewicht (in kg) an", text: $mass).keyboardType(.numberPad)
                }.padding()
                
                Spacer()
                Button(action: self.save, label: {
                    Text(String.next)
                }).buttonStyle(CustomButtonStyle())
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .environmentObject(status)
            .environmentObject(polarApi)
            .onTapGesture {
                self.endEditing()
            }
            .alert(isPresented: $alert, content: {
                Alert(title: Text("Bitte fülle erst alle Angaben aus."))
            })
        }
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    private func save() {
        if (male == true || female == true) && age != "" && mass != "" && hight != "" {
            let ref: DatabaseReference = Database.database().reference().child(String.participants).child("Participant \(status.participantID)").child("Demographic")
            ref.updateChildValues(["Age": age, "Gender": male ? "männlich" : "weiblich", "Mass": mass, "Hight": hight])
            
            self.selection = "Form"
        } else {
            alert = true
        }
    }
}


struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color.white
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .overlay(content)
    }
}


struct DemographicFormView_Previews: PreviewProvider {
    static var previews: some View {
        DemographicFormView()
    }
}
