//
//  CameraView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 28.11.20.
//

import SwiftUI
import FirebaseDatabase

struct CameraView: View {
    @State private var selection: String? = nil
    
    @State var didTap: Bool = false
    
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timeSeconds: String = "00"
    @State var timeMinutes: String = "00"
    @State var timer: Timer? = nil
    
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    @ObservedObject var camera = CameraModel()
    
    var body: some View {
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
                }
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all, edges: .all)
                
            }
            Button(action: onClick, label: {
                Image(systemName: camera.isRecording ? "pause" : "video")
            }).buttonStyle(VideoButtonStyle(isRecording: $camera.isRecording))
        }.environmentObject(status).environmentObject(polarApi)
        .onAppear(perform: {
            
            camera.checkAuth()
        })
        .alert(isPresented: $camera.alert) {
            Alert(title: Text("Please Enable Camera Access"))
        }
    }
    
    func onClick() {
        if camera.authState {
            camera.startRecording()
            if !camera.isRecording {
                self.didTap = true
                self.startTimer()
                self.polarApi.startStreaming()
            }
            else {
                camera.stopSession()
                self.stopTimer()
                self.polarApi.stopStream()
                self.saveToDatabase()
                if status.session == "second" {
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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { tempTimer in
            
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
        print(polarApi.hrDataStream)
        let ref = Database.database().reference().child("Participant \(status.participantID)").child("Day").child("Session").child("HR_Data")
        ref.updateChildValues(["Test" : "test", "Noch ein test" : "testtest"])
    }
}


struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
