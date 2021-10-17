//
//  ContentView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI



struct WelcomeView: View {
    @StateObject var viewModel = WelcomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    NavigationLink(destination: DemographicFormView(), tag: "Demographic", selection: $viewModel.selection) { EmptyView() }
                    NavigationLink(destination: WarmUpView(), tag: "WarmUp", selection: $viewModel.selection) { EmptyView() }
                    
                    Text("Willkommen zur Studie.").titleStyle().onTapGesture(count: 5) {
                        print("Tapped on text")
                        viewModel.isSharePresented = true
                    }
                    Spacer()
                    TextField("Gib deine Teilnehmer ID ein", text: $viewModel.ID)
                        .padding(.horizontal, 40)
                        .multilineTextAlignment(TextAlignment.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    Spacer()
                    
                    Button(action: viewModel.start) {
                        Text(String.next)
                    }.buttonStyle(CustomButtonStyle())
                }
                if viewModel.wait {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .environmentObject(viewModel.status)
        .environmentObject(viewModel.polarApi)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear() {
            viewModel.checkConnection()
        }
        .sheet(isPresented: $viewModel.isSharePresented, content: {
            let url = viewModel.show()
            ActivityViewController(activityItems: url, applicationActivities: nil)
        })
        .alert(item: $viewModel.alertItem) { item in
            Alert(title: item.title, message: item.message)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
