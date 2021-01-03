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
    
    @State var hasInternetConnection = false
    @State var alertConnection = false
    @State var alertID = false
    
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
                    Text(String.next)
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
        .alert(isPresented: $alertConnection, content: {
            Alert(title: Text("Bitte stelle eine Verbindung zum Internet her."))
        })
        .alert(isPresented: $alertID, content: {
            Alert(title: Text("Bitte gib deine ID ein."))
        })
    }
    
    func checkConnection() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .satisfied {
                hasInternetConnection = true
            } else {
                NSLog("There's no internet connection.")
                hasInternetConnection = false
            }
        }
        monitor.start(queue: queue)
    }
    
    func start() {
        if hasInternetConnection && !ID.isEmpty {
            saveToDatabase()
        } else if !hasInternetConnection {
            alertConnection = true
        } else if ID.isEmpty {
            alertID = true
        }
    }
    
    func saveToDatabase() {
        let ref: DatabaseReference = Database.database().reference()
        
        var refParticipants = ref.child("Participants")
        refParticipants.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("Participant \(ID)") {
                let ref1 = refParticipants.child("Participant \(ID)")
                ref1.observeSingleEvent(of: .value) { (snap) in
                    if snap.hasChild(String.gender) && snap.hasChild(String.age) {
                        self.status.participantID = ID
                        self.selection = "WarmUp"
                        //TODO lösche tag -> wird in finish screen gemanaged 
                        let refDay = refParticipants.child("Participant \(ID)").child("Day")
                        refDay.observeSingleEvent(of: .value) { (snap) in
                            if let value = snap.value as? Int {
                                self.status.day = value
                                refDay.setValue(value)
                            }
                        }
                    } else {
                        self.selection = "Demographic"
                        self.status.day = 1
                        self.status.participantID = ID
                    }
                }
            } else {
                let refID = ref.child("IDs")
                refID.observeSingleEvent(of: .value) { (snap) in
                    snap.children.forEach({ (child) in
                        if let child = child as? DataSnapshot, let value = child.value as? String {
                            if value == ID {
                                print("ja, dann kopiere code hier rein!")
                            }
                        }
                    })
                    if snap.hasChild(ID) {
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

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
