//
//  ContentView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI
import FirebaseDatabase


class GlobalState: ObservableObject {
    @Published var isSecondRun: String = "first"
    @Published var participantID: String = ""
}

struct WelcomeView: View {
    @ObservedObject var status = GlobalState()
    
    @State private var selection: String? = nil
    //TODO: info.plist photo library wieder löschen wenn videos in firebase gescpeichert werden
    @State var ID: String = ""
    @State var isCodeValide = false
    @State var codeExists = false
    @State var codeList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: DemographicFormView(), tag: "Demographic", selection: $selection) { EmptyView() }
                NavigationLink(destination: WarmUpView(), tag: "WarmUp", selection: $selection) { EmptyView() }
                
                Text("Willkommen zur Studie.").titleStyle()
                Spacer()
                TextField("Gib deine ID ein", text: $ID)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(TextAlignment.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                
                Button(action: start) {
                    Text("Los gehts")
                }.buttonStyle(CustomButtonStyle())
            }
        }.navigationBarBackButtonHidden(true).environmentObject(status)
    }
    
    
    func start() {
        var ref: DatabaseReference = Database.database().reference()
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild("Participant \(ID)") {
                self.status.participantID = ID
                self.selection = "WarmUp"
            } else {
                if !ID.isEmpty && codeList.contains(ID) {
                    ref = ref.child("Participant \(ID)")
                    ref.setValue(["Participant ID": ID])
                    self.status.participantID = ID
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
