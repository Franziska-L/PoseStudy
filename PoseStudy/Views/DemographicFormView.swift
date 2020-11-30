//
//  QuestionnaireView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct DemographicFormView: View {
    @State var age: String = ""
    @State private var status = false
    @State private var status2 = false
    
    var body: some View {
        VStack {
            Text("Persönliche Angaben").titleStyle()
        
            GroupBox(label: Text("Gender")) {
                Toggle(isOn: $status) {
                    Text("Männlich")
                }.toggleStyle(CheckboxToggleStyle())
                Toggle(isOn: $status2) {
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
                destination: HealthFormView().navigationBarHidden(true),
                label: {
                    Text("Weiter")
                }).buttonStyle(CustomButtonStyle())
            
            /*ProgressView(value: /*@START_MENU_TOKEN@*/0.5/*@END_MENU_TOKEN@*/).accentColor(Color("darkgreen"))*/
        }
    }
}

struct DemographicFormView_Previews: PreviewProvider {
    static var previews: some View {
        DemographicFormView()
    }
}
