//
//  ContentView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct WelcomeView: View {
    
    @State var code: String = ""
    @State var isCodeValide = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Willkommen zur Studie.").titleStyle()
                Spacer()
                TextField("Enter Code", text: $code)
                    .padding()
                    .multilineTextAlignment(TextAlignment.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                NavigationLink(
                    destination: CameraView().navigationBarHidden(true),
                    isActive: $isCodeValide,
                    label: {
                        Button(action: start) {
                            Text("Los gehts")
                        }
                    }).buttonStyle(CustomButtonStyle())
            }
        }
    }
    
    func start() {
        if code == "1234" {
            //If code exists skip questionnaire views!!
            isCodeValide = true
        }
        else {
            isCodeValide = false
            print("color textfield red")
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
