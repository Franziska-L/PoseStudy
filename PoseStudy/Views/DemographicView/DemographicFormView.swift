//
//  QuestionnaireView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct DemographicFormView: View {
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    @StateObject var viewModel = DemographicViewModel()
        
    var body: some View {
        let m = Binding<Bool>(get: { viewModel.male }, set: { viewModel.male = $0; viewModel.female = false})
        let w = Binding<Bool>(get: { viewModel.female }, set: { viewModel.male = false; viewModel.female = $0})
        ScrollView {
            VStack {
                NavigationLink(destination: HealthFormView().navigationBarHidden(true), tag: "Form", selection: $viewModel.selection) { EmptyView() }
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
                    TextField("Gib dein Alter an", text: $viewModel.age).keyboardType(.numberPad)
                }.padding()
                GroupBox(label: Text("Größe")) {
                    TextField("Gib dein Größe (in cm) an", text: $viewModel.hight).keyboardType(.numberPad)
                }.padding()
                
                GroupBox(label: Text("Gewicht")) {
                    TextField("Gib dein Gewicht (in kg) an", text: $viewModel.mass).keyboardType(.numberPad)
                }.padding()
                
                Spacer()
                Button(action: viewModel.save, label: {
                    Text(String.next)
                }).buttonStyle(CustomButtonStyle())
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .environmentObject(status)
            .environmentObject(polarApi)
            .onTapGesture {
                viewModel.endEditing()
            }
            .alert(isPresented: $viewModel.alert, content: {
                Alert(title: Text(String.questions))
            })
            .onAppear {
                viewModel.setup(status: self.status, polarApi: self.polarApi)
            }
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
