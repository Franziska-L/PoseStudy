//
//  Test.swift
//  PoseStudy
//
//  Created by Franziska Lang on 07.12.20.
//

import SwiftUI
import AVFoundation
import UIKit


struct Test: View {
    
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timeSeconds: String = "00"
    @State var timeMinutes: String = "00"
    @State var timer: Timer? = nil
    
    var body: some View {
        VStack {
            CameraView()
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

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
