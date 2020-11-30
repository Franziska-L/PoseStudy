//
//  Test.swift
//  PoseStudy
//
//  Created by Franziska Lang on 26.11.20.
//

import SwiftUI

struct HealthFormView: View {
    @State private var status = false
    @State private var status2 = false
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    Text("Angaben zum Gesundheitszustand").titleStyle()
                    GroupBox(label: Text("Hast du eine der folgenden Krankheiten")) {
                        Toggle(isOn: $status) {
                            Text("Herz-Kreislauf-Krankheit")
                        }.toggleStyle(CheckboxToggleStyle())
                        Toggle(isOn: $status2) {
                            Text("Muskel-Skelett-Erkrankung")
                        }.toggleStyle(CheckboxToggleStyle())
                        Toggle(isOn: $status2) {
                            Text("Neuromuskuläre Erkrankung")
                        }.toggleStyle(CheckboxToggleStyle())
                        Toggle(isOn: $status2) {
                            Text("Nichts")
                        }.toggleStyle(CheckboxToggleStyle())
                    }.padding()
                    GroupBox(label: Text("Nimmst du regelmäßig Medikamente")) {
                        Toggle(isOn: $status2) {
                            Text("Ja")
                        }.toggleStyle(CheckboxToggleStyle())
                        Toggle(isOn: $status2) {
                            Text("Nein")
                        }.toggleStyle(CheckboxToggleStyle())
                    }.padding()
                    NavigationLink(
                        destination: WarmUpView().navigationBarHidden(true),
                        label: {
                            Text("Weiter")
                            
                        }).buttonStyle(CustomButtonStyle())
                }
            }
        }
    }
}


struct HealthFormView_Previews: PreviewProvider {
    static var previews: some View {
        HealthFormView()
    }
}
