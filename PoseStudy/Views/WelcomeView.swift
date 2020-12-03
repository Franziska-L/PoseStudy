//
//  ContentView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI
import FirebaseDatabase

struct WelcomeView: View {

    //TODO: info.plist photo library wieder löschen wenn videos in firebase gescpeichert werden
    @State var code: String = ""
    //false!
    @State var isCodeValide = false
    @State var codeExists = false
    @State var codeList = ["1234", "1235", "126", "1237"]
    @State var data: Dataset = Dataset()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Willkommen zur Studie.").titleStyle()
                Spacer()
                TextField("Gib deine ID ein", text: $code)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(TextAlignment.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                
                Button(action: start) {
                    Text("Los gehts")
                }.buttonStyle(CustomButtonStyle())
                if codeExists {
                    NavigationLink(
                        destination: WarmUpView().navigationBarHidden(true),
                        isActive: $isCodeValide,
                        label: {
                            Text("").opacity(1.0)
                        }).buttonStyle(PlainButtonStyle())
                } else {
                    NavigationLink(
                        destination: DemographicFormView(data: $data).navigationBarHidden(true),
                        isActive: $isCodeValide,
                        label: {
                            Text("").opacity(1.0)
                        }).buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    
    func start() {
        var ref: DatabaseReference = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild("Participant \(code)") {
                isCodeValide = true
                codeExists = true
                data.participantID = code
            } else {
                if !code.isEmpty && codeList.contains(code) {
                    isCodeValide = true
                    codeExists = false
                    
                    ref = ref.child("Participant \(code)")
                    ref.setValue(["Participant ID": code])
                    data.participantID = code
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
