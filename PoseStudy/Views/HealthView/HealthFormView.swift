//
//  Test.swift
//  PoseStudy
//
//  Created by Franziska Lang on 26.11.20.
//

import SwiftUI

struct HealthFormView: View {
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    @StateObject var viewModel = HealthViewModel()
            
    var body: some View {
        let yes = Binding<Bool>(get: { viewModel.medicaments }, set: { viewModel.medicaments = $0; viewModel.nomedicaments = false})
        let no = Binding<Bool>(get: { viewModel.nomedicaments }, set: { viewModel.medicaments = false; viewModel.nomedicaments = $0})
        
        let nothing = Binding<Bool>(get: { viewModel.nothing }, set: { viewModel.cardiovascular = false; viewModel.musculoskeletal = false; viewModel.neuromuscular = false; viewModel.highBlood = false; viewModel.diabetes = false; viewModel.nothing = $0})
        let cardio = Binding<Bool>(get: { viewModel.cardiovascular }, set: { viewModel.cardiovascular = $0; viewModel.nothing = false})
        let musco = Binding<Bool>(get: { viewModel.musculoskeletal }, set: { viewModel.musculoskeletal = $0; viewModel.nothing = false})
        let neuro = Binding<Bool>(get: { viewModel.neuromuscular }, set: { viewModel.neuromuscular = $0; viewModel.nothing = false})
        let blood = Binding<Bool>(get: { viewModel.highBlood }, set: { viewModel.highBlood = $0; viewModel.nothing = false})
        let diab = Binding<Bool>(get: { viewModel.diabetes }, set: { viewModel.diabetes = $0; viewModel.nothing = false})
        
        let more = Binding<Bool>(get: { viewModel.more }, set: { viewModel.more = $0; viewModel.less = false; viewModel.never = false})
        let less = Binding<Bool>(get: { viewModel.less }, set: { viewModel.more = false; viewModel.less = $0; viewModel.never = false})
        let never = Binding<Bool>(get: { viewModel.never }, set: { viewModel.more = false; viewModel.less = false; viewModel.never = $0})
        ScrollView {
            VStack {
                NavigationLink(destination: WarmUpView().navigationBarHidden(true), tag: "WarmUp", selection: $viewModel.selection) { EmptyView() }
                Text("Angaben zum Gesundheitszustand").titleStyle()
                GroupBox(label: Text("Hast du eine der folgenden Krankheiten?")
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)) {
                    Toggle(isOn: cardio) {
                        Text("Herz-Kreislauf-Krankheit")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: musco ) {
                        Text("Muskel-Skelett-Erkrankung")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: neuro) {
                        Text("Neuromuskuläre Erkrankung")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: blood) {
                        Text("Bluthochdruck")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: diab) {
                        Text("Diabetes")
                    }.toggleStyle(CheckboxToggleStyle())
                    Toggle(isOn: nothing) {
                        Text("Nichts")
                    }.toggleStyle(CheckboxToggleStyle())
                }.padding().padding(.top, 40)
                
                GroupBox(label: Text("Hast du eine andere chronische Krankheit? (optional)")
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)) {
                    TextField("Sonstiges", text: $viewModel.other)
                }.padding()
                
                GroupBox(label: Text("Nimmst du regelmäßig Medikamente?")
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)) {
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
                Button(action: viewModel.save, label: {
                    Text(String.next)
                }).buttonStyle(CustomButtonStyle())
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .environmentObject(status)
        .environmentObject(polarApi)
        .alert(isPresented: $viewModel.alert, content: {
            Alert(title: Text(String.questions))
        })
        .onAppear {
            viewModel.setup(status: self.status, polarApi: self.polarApi)
        }
    }
    
}


struct HealthFormView_Previews: PreviewProvider {
    static var previews: some View {
        HealthFormView()
    }
}
