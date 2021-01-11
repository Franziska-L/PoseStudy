//
//  FinishScreen.swift
//  PoseStudy
//
//  Created by Franziska Lang on 07.12.20.
//

import SwiftUI
import Firebase

struct FinishScreen: View {
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    var body: some View {
        VStack {
            Text("Geschafft!").titleStyle().padding(.bottom, 50)
            Image("done").resizable().scaledToFit()
            Text("Danke für deine Teilnahme!").titleStyle()
        }.environmentObject(status).environmentObject(polarApi).onAppear() {
            self.setDay()
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
}

struct FinishScreen_Previews: PreviewProvider {
    static var previews: some View {
        FinishScreen()
    }
}
