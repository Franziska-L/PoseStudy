//
//  CameraView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 28.11.20.
//

import SwiftUI
import FirebaseDatabase

struct CamView: View {
    var body: some View {
        CameraView()
    }
}



struct CameraView: View {
    @State private var selection: String? = nil
        
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timeSeconds: String = "00"
    @State var timeMinutes: String = "00"
    @State var timer: Timer? = nil
    
    @State var isRecording = false
    
    var startTime: String?
    
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    @ObservedObject var camera = CameraModel()
    
    var body: some View {
        return (
        VStack {
            NavigationLink(destination: PauseView().navigationBarHidden(true), tag: "Pause", selection: $selection) { EmptyView() }
            NavigationLink(destination: FinishScreen().navigationBarHidden(true), tag: "Finish", selection: $selection) { EmptyView() }
            ZStack(alignment: .top) {
               
                if camera.isRecording {
                    Text("\(timeMinutes):\(timeSeconds)")
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(width: 70, height: 32, alignment: .center)
                        .background(Color.darkgreen)
                        .foregroundColor(.white)
                        .zIndex(2.0)
                        .cornerRadius(15.0)
                        .padding(.top, 20)
                }
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all, edges: .all)
                
            }
            Button(action: onClick, label: {
                Image(systemName: camera.isRecording ? "pause" : "video")
            }).buttonStyle(VideoButtonStyle(isRecording: $camera.isRecording)).padding(.bottom, 20)
        }.environmentObject(status).environmentObject(polarApi)
        .onAppear(perform: {
            
            camera.checkAuth()
        })
        .alert(isPresented: $camera.alert) {
            Alert(title: Text("Bitte erlaube Zugriff auf Kamera in den Einstellungen."))
        })
    }
    
    func onClick() {
        //Todo überprüfe was passiert wenn ecg daten nicht vorhanden (schon 2 mal passiert nach aufnahme!)
        if camera.authState && camera.cameraAvailable {
            camera.startRecording()
            //TODO: start und end timestamp hinzufügen
            //TODO hier überprüfen evtl isRecording nicht schnell genug?
            if !camera.isRecording {
                let timestamp = Date().initTimestamp()
                self.startTimer()
                self.polarApi.startStreaming()
                DispatchQueue.global(qos: .background).async {
                    //TODO startStreaming in background?
                }
            }
            else {
                self.camera.stopSession()
                self.stopTimer()
                self.polarApi.stopStream()
                self.saveToDatabase()
                if status.session == 2 {
                    self.selection = "Finish"
                } else {
                    self.selection = "Pause"
                }
            }
        } else {
            camera.checkAuth()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.seconds == 59 {
                self.seconds = 0
                if self.minutes == 59 {
                    self.minutes = 0
                } else {
                    self.minutes = self.minutes + 1
                }
            } else {
                self.seconds = self.seconds + 1
            }
            if minutes < 10 {
                timeMinutes = "0\(minutes)"
            } else {
                timeMinutes = "\(minutes)"
            }
            if seconds < 10 {
                timeSeconds = "0\(seconds)"
            } else {
                timeSeconds = "\(seconds)"
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        minutes = 0
        seconds = 0
        timeSeconds = "0\(seconds)"
        timeMinutes = "0\(minutes)"
    }
    
    private func saveToDatabase() {
        let timestamp = Date().initTimestamp()
        
        let ref: DatabaseReference = Database.database().reference().child(String.participants).child("Participant \(status.participantID)").child("Day \(self.status.day)").child("Session \(status.session)")
        //"Start Timestamp":  startTime,"End Timestamp": timestamp hinzufügen
        ref.setValue(["HR" : polarApi.hrDataStream, "ECG" : polarApi.ecgDataStream, "ECGs" : polarApi.ecgDataStreamPerSecond, "HR Timestamp" : polarApi.hrDataTimestamp, "ECG Timestamp" : polarApi.ecgDataTimestamp, "RR" : polarApi.rrsDataStream, "RRMs" : polarApi.rrMsDataStream, "RR Timestamp" : polarApi.rrDataTimestamp])
        
        polarApi.hrDataStream.removeAll()
        polarApi.ecgDataStream.removeAll()
        
        polarApi.hrDataTimestamp.removeAll()
        polarApi.ecgDataTimestamp.removeAll()
        
        polarApi.rrsDataStream.removeAll()
        polarApi.rrMsDataStream.removeAll()
        polarApi.rrDataTimestamp.removeAll()
        
        polarApi.ecgDataStreamPerSecond.removeAll()
        polarApi.ecgDataStreamTest.removeAll()
    }
}


struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
