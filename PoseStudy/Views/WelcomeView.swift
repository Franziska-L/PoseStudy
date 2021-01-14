//
//  ContentView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI
import FirebaseDatabase
import Network
import FirebaseStorage

class GlobalState: ObservableObject {
    @Published var session: Int = 1
    @Published var participantID: String = ""
    @Published var day: Int = 0
    @Published var userData = UserData()
}

struct WelcomeView: View {
    @ObservedObject var status = GlobalState()
    @ObservedObject var polarApi = PolarApiWrapper()
    
    @State private var selection: String? = nil
    @State var ID: String = ""
    @State var isCodeValide = false
    @State var codeExists = false
    
    @State var hasInternetConnection = false
    @State var alertConnection = false
    @State var alertID = false
    
    @State var wait = false
    @State private var isSharePresented: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    NavigationLink(destination: DemographicFormView(), tag: "Demographic", selection: $selection) { EmptyView() }
                    NavigationLink(destination: WarmUpView(), tag: "WarmUp", selection: $selection) { EmptyView() }
                    
                    Text("Willkommen zur Studie.").titleStyle().onTapGesture(count: 5) {
                        print("Tapped on text")
                        self.isSharePresented = true
                    }
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
                if wait {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
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
            Alert(title: Text("Falsche ID"), message: Text("Gib die ID ein, die du zu Beginn der Studie bekommen hast."))
        })
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $isSharePresented, onDismiss: {
            print("Dismiss")
        }, content: {
            let url = show()
            ActivityViewController(activityItems: url, applicationActivities: nil)
        })
    }
    
    func show() -> [URL] {
        var urls = [URL]()
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(fileURLs)
            for file in fileURLs {
                let input = try String(contentsOf: file)
                urls.append(file)
                print(input)
            }
            // process files
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        return urls
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
            wait = true
            saveToDatabase()
        } else if !hasInternetConnection {
            alertConnection = true
        } else if ID.isEmpty {
            alertID = true
        }
    }
    
    func saveToDatabase() {
        status.userData.ID = ID
        let ref: DatabaseReference = Database.database().reference()
        
        var refParticipants = ref.child("Participants")
        refParticipants.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("Participant \(ID)") {
                let ref1 = refParticipants.child("Participant \(ID)")
                ref1.observeSingleEvent(of: .value) { (snap) in
                    if snap.hasChild("Demographic") && snap.hasChild("Health Status") {
                        self.status.participantID = ID
                        self.selection = "WarmUp"
                        let refDay = refParticipants.child("Participant \(ID)").child("Day")
                        refDay.observeSingleEvent(of: .value) { (snap) in
                            if let value = snap.value as? Int {
                                self.status.day = value
                                refDay.setValue(value)
                                self.wait = false
                            }
                        }
                    } else {
                        self.selection = "Demographic"
                        self.status.day = 1
                        self.status.participantID = ID
                        self.wait = false
                    }
                    self.wait = false
                }
            } else {
                let refID = ref.child("IDs")
                refID.observeSingleEvent(of: .value) { (snap) in
                    if snap.hasChild(ID) {
                        refParticipants = refParticipants.child("Participant \(ID)")
                        refParticipants.setValue(["Participant ID": ID, "Day": 1])
                        self.status.participantID = ID
                        self.status.day = 1
                        self.selection = "Demographic"
                    }
                    else {
                        alertID = true
                    }
                    self.wait = false
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
