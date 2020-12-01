//
//  CameraView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 28.11.20.
//

import SwiftUI

struct CameraView: View {
    
    @State var isRecording: Bool = false
    @State var minutes: Int = 00
    @State var seconds: Int = 00
    @State var timeSeconds: String = "00"
    @State var timeMinutes: String = "00"
    @State var timer: Timer? = nil
    @State var currentDate = Date()
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                if isRecording {
                    Text("\(timeMinutes):\(timeSeconds)")
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .foregroundColor(.white).zIndex(2.0)
                }
                CameraRepresentable(didTapCapture: $isRecording).edgesIgnoringSafeArea(.top)
                
            }
            CaptureVideoButtonView(isRecording: $isRecording).onTapGesture {
                self.isRecording = !self.isRecording
                countTimer()
            }
        }
        
        
    }
    
    func countTimer() {
        if isRecording {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
                  // 2. Check time to add to H:M:S
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
        else {
            timer?.invalidate()
            timer = nil 
            minutes = 00
            seconds = 00
            timeSeconds = "\(seconds)"
            timeMinutes = "\(minutes)"
        }
    }
}


struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
