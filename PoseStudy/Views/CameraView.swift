//
//  CameraView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 28.11.20.
//

import SwiftUI

struct CameraView: View {
    @State private var selection: String? = nil
    
    @State var isRecording: Bool = false
    @State var didTap: Bool = false
    
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timeSeconds: String = "00"
    @State var timeMinutes: String = "00"
    @State var timer: Timer? = nil
    
    @EnvironmentObject var status: GlobalState
    
    var body: some View {
        VStack {
            NavigationLink(destination: PauseView().navigationBarHidden(true), tag: "Pause", selection: $selection) { EmptyView() }
            NavigationLink(destination: FinishScreen().navigationBarHidden(true), tag: "Finish", selection: $selection) { EmptyView() }
            ZStack(alignment: .top) {
               
                if isRecording {
                    Text("\(timeMinutes):\(timeSeconds)")
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .foregroundColor(.white).zIndex(2.0).cornerRadius(3.0)
                }
                CameraRepresentable(isRecording: $isRecording, didTap: $didTap).edgesIgnoringSafeArea(.top)
                
            }
            Button(action: onClick, label: {
                Image(systemName: isRecording ? "pause" : "video")
            }).buttonStyle(VideoButtonStyle(isRecording: $isRecording))
        }.environmentObject(status)
    }
    
    func onClick() {
        if self.isRecording {
            self.stopTimer()
            self.isRecording = !self.isRecording
            if status.isSecondRun == "second" {
                self.selection = "Finish"
            } else {
                self.selection = "Pause"
            }
        } else {
            self.didTap = true
            self.isRecording = !self.isRecording
            startTimer()
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
}


struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
