//
//  FinishScreen.swift
//  PoseStudy
//
//  Created by Franziska Lang on 07.12.20.
//

import SwiftUI
import Firebase


struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}




struct FinishScreen: View {
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    @State private var isSharePresented: Bool = false

    
    var body: some View {
        VStack {
            Text("Geschafft!").titleStyle().padding(.bottom, 50)
            Image("done").resizable().scaledToFit()
            Text("Danke für deine Teilnahme!").titleStyle()
        }.environmentObject(status).environmentObject(polarApi).onAppear() {
            self.setDay()
            self.saveToFile()
        }
    }
    
    func setDay() {
        let ref = Database.database().reference().child(String.participants).child("Participant \(status.participantID)").child("Day")
        
        ref.observeSingleEvent(of: .value) { (snap) in
            if let value = snap.value as? Int {
                self.status.day = value + 1
                ref.setValue(value + 1)
            }
        }
    }
    
    func saveToFile() {
        let identifier = UUID()
        
        let file = getDocumentsDirectory().appendingPathComponent("Participant_\(status.participantID)_Day_\(status.day)_\(identifier).json")
        do {
            let jsonData = try JSONEncoder().encode(status.userData)
            let jsonString = String(data: jsonData, encoding: .utf8)
            try jsonString?.write(to: file, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct FinishScreen_Previews: PreviewProvider {
    static var previews: some View {
        FinishScreen()
    }
}
