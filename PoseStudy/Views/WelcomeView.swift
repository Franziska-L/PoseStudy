//
//  ContentView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI
import FirebaseDatabase
import Network

class GlobalState: ObservableObject {
    @Published var session: String = "first"
    @Published var participantID: String = ""
    @Published var day: Int = 0
}

struct WelcomeView: View {
    @ObservedObject var status = GlobalState()
    @ObservedObject var polarApi = PolarApiWrapper()
    
    @State private var selection: String? = nil
    //TODO: info.plist photo library wieder löschen wenn videos in firebase gescpeichert werden
    @State var ID: String = ""
    @State var isCodeValide = false
    @State var codeExists = false
    @State var codeList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    @State var hasInternetConnection = false
    
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
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .environmentObject(status)
        .environmentObject(polarApi)
        .onAppear() {
            checkConnection()
        }
        .alert(isPresented: $hasInternetConnection, content: {
            Alert(title: Text("Bitte stelle eine Verbindung zum Internet her."))
        })
    }
    
    func checkConnection() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                print("Internet connection is on.")
                hasInternetConnection = true
            } else {
                print("There's no internet connection.")
                hasInternetConnection = false
            }
        }

            
        monitor.start(queue: queue)
    }
    
    func start() {
        if hasInternetConnection {
            let ref: DatabaseReference = Database.database().reference()
            
            var refParticipants = ref.child("Participants")
            refParticipants.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild("Participant \(ID)") {
                    self.status.participantID = ID
                    self.selection = "WarmUp"
                    let refDay = refParticipants.child("Participant \(ID)").child("Day")
                    refDay.observeSingleEvent(of: .value) { (snap) in
                        if let value = snap.value as? Int {
                            self.status.day = value + 1
                            refDay.setValue(value + 1)
                        }
                    }
                } else {
                    let refID = ref.child("IDs")
                    refID.observeSingleEvent(of: .value) { (snap) in
                        snap.children.forEach({ (child) in
                            if let child = child as? DataSnapshot, let value = child.value {
                                print(value)
                            }
                        })
                        if snap.hasChild(ID) && !ID.isEmpty {
                            refParticipants = refParticipants.child("Participant \(ID)")
                            refParticipants.setValue(["Participant ID": ID, "Day": 1])
                            self.status.participantID = ID
                            self.status.day = 1
                            self.selection = "Demographic"
                        }
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
