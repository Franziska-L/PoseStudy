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
    
    @State private var next = false
        
    var body: some View {
        let m = Binding<Bool>(get: { self.male }, set: { self.male = $0; self.female = false})
        let w = Binding<Bool>(get: { self.female }, set: { self.male = false; self.female = $0})
                
        VStack {
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
            
            Spacer()
            NavigationLink(
                destination: HealthFormView(),
                isActive: $next,
                label: {
                    Text(String.next)
                }).buttonStyle(CustomButtonStyle()).simultaneousGesture(TapGesture().onEnded{
                    save()
                })
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .environmentObject(status)
        .environmentObject(polarApi)
        .onTapGesture {
            self.endEditing()
        }
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    private func save() {
        if (male == true || female == true) && age != "" {
            let ref: DatabaseReference = Database.database().reference().child(String.participants).child("Participant \(status.participantID)")
            ref.updateChildValues(["\(String.age)": age, "\(String.gender)": male ? "männlich" : "weiblich"])
            
            self.next = true
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
