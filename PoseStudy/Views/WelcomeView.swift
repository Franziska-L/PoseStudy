//
//  ContentView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI
import FirebaseDatabase

struct WelcomeView: View {

    @State private var selection: String? = nil
    //TODO: info.plist photo library wieder löschen wenn videos in firebase gescpeichert werden
    @State var code: String = ""
    @State var isCodeValide = false
    @State var codeExists = false
    @State var codeList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    @State var data: Dataset = Dataset()
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: DemographicFormView(data: $data), tag: "Demographic", selection: $selection) { EmptyView() }
                NavigationLink(destination: WarmUpView(), tag: "WarmUp", selection: $selection) { EmptyView() }
                
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
            }
        }
    }
    
    
    func start() {
        var ref: DatabaseReference = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild("Participant \(code)") {
                data.participantID = code
                self.selection = "WarmUp"
            } else {
                if !code.isEmpty && codeList.contains(code) {
                    ref = ref.child("Participant \(code)")
                    ref.setValue(["Participant ID": code])
                    data.participantID = code
                    self.selection = "Demographic"
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
