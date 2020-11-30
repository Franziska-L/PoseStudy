//
//  ContentView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct WelcomeView: View {
    
    //TODO: info.plist photo library wieder löschen wenn videos in firebase gescpeichert werden
    @State var code: String = ""
    //false!
    @State var isCodeValide = true
    
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
                //TODO: hier den richtigen NavigationLink!
                //-> Wenn code nicht vorhanden gehe zu Fragebögen
                //Sonst gehe direkt zur Warm up View
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
