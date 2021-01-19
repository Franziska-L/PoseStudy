//
//  PauseView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 02.12.20.
//

import SwiftUI
import Firebase

struct PauseView: View {
    @State private var selection: String? = nil
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    @State var data = MeasuredData()
    
    var body: some View {
        VStack {
            NavigationLink(destination: InstructionView().navigationBarHidden(true), tag: "next", selection: $selection) { EmptyView() }
            Text("Pause").titleStyle()
            Spacer()
            Image("break").resizable().scaledToFit()
            Text("Mache eine kurze Pause (2-4 Minuten) bevor du mit der zweiten Runde beginnst.").padding()
            Text("Behalte aber den Brustgurt in der Zeit an.").padding()
            Spacer()
            Text("Ausgeruht? Dann starte in die 2. Runde")
            Button(action: {
                setState()
            }) {
                Text(String.go)
            }.buttonStyle(CustomButtonStyle())
        }
        .environmentObject(status)
        .environmentObject(polarApi)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear(perform: {
            polarApi.startStreaming()
            let timestampStart: Int64 = Date().toMillis()

            data.startTime = timestampStart
            let ref: DatabaseReference = Database.database().reference().child(String.participants).child("Participant \(status.participantID)").child("Day \(self.status.day)").child("Resting")
            ref.setValue(["Start Time": timestampStart])
        })
    }
    
    func setState() {
        polarApi.stopStream()
        self.status.session = 2
        self.selection = "next"
        
        let timestampEnd = Date().toMillis()
        
        let ref: DatabaseReference = Database.database().reference().child(String.participants).child("Participant \(status.participantID)").child("Day \(self.status.day)").child("Resting")
        ref.updateChildValues(["HR" : polarApi.hrDataStream, "ECG" : polarApi.ecgDataStream, "ECGs" : polarApi.ecgDataStreamPerSecond, "HR Timestamp" : polarApi.hrDataTimestamp, "ECG Timestamp" : polarApi.ecgDataTimestamp, "RR" : polarApi.rrsDataStream, "RRMs" : polarApi.rrMsDataStream, "HRs" : polarApi.hrDataStreamPerSec, "RR Timestamp" : polarApi.rrDataTimestamp, "End Time": timestampEnd])
        
        data.ecgDataStream = polarApi.ecgDataStream
        data.ecgDataTimestamp = polarApi.ecgDataTimestamp
        data.ecgDataStreamPerSecond = polarApi.ecgDataStreamPerSecond
        
        data.hrDataStream = polarApi.hrDataStream
        data.hrDataTimestamp = polarApi.hrDataTimestamp
        
        data.rrsDataStream = polarApi.rrsDataStream
        data.rrMsDataStream = polarApi.rrMsDataStream
        data.rrDataTimestamp = polarApi.rrDataTimestamp
        data.hrDataStreamPerSec = polarApi.hrDataStreamPerSec
        data.endTime = timestampEnd
        
        status.userData.resting = data
        
        polarApi.hrDataStream.removeAll()
        polarApi.ecgDataStream.removeAll()
        
        polarApi.hrDataTimestamp.removeAll()
        polarApi.ecgDataTimestamp.removeAll()
        
        polarApi.rrsDataStream.removeAll()
        polarApi.rrMsDataStream.removeAll()
        polarApi.hrDataStreamPerSec.removeAll()
        polarApi.rrDataTimestamp.removeAll()
        
        polarApi.ecgDataStreamPerSecond.removeAll()
        polarApi.ecgDataStreamTest.removeAll()
    }
}

struct PauseView_Previews: PreviewProvider {
    static var previews: some View {
        PauseView()
    }
}
