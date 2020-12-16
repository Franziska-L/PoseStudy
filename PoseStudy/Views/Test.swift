//
//  Test.swift
//  PoseStudy
//
//  Created by Franziska Lang on 07.12.20.
//

import SwiftUI
import AVFoundation
import UIKit

public class CameraState : NSObject, ObservableObject {
    @Published public var capturedImage : UIImage?
    @Published public var capturedImageError : Error?
}

public protocol CameraViewDelegate {
    func cameraAccessGranted()
    func cameraAccessDenied()
    func noCameraDetected()
    func cameraSessionStarted()
}

enum Camera {
   case captureSessionAlreadyRunning
   case captureSessionIsMissing
   case inputsAreInvalid
   case invalidOperation
   case noCamerasAvailable
   case unknown
}


struct Test: View {
    
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timeSeconds: String = "00"
    @State var timeMinutes: String = "00"
    @State var timer: Timer? = nil
    
    var body: some View {
        VStack {
            Button(action: startTimer, label: {
                Text("Start")
            }).padding()
            Button(action: stopTimer, label: {
                Text("Stop")
            }).padding()
            Text("\(timeMinutes):\(timeSeconds)")
                .fixedSize(horizontal: true, vertical: true)
                .frame(width: 70, height: 32, alignment: .center)
                .background(Color.darkgreen)
                .foregroundColor(.white)
                .zIndex(2.0)
                .cornerRadius(15.0)
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


struct CameraView2: View {
    
    @ObservedObject var camera = CameraModel()
    
    var body: some View{
        
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            Button(action: startRecording, label: {
                
                ZStack{
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 65, height: 65)
                    
                    Circle()
                        .stroke(Color.white,lineWidth: 2)
                        .frame(width: 75, height: 75)
                }
            })
        }
        .onAppear(perform: {
            
            camera.checkAuth()
        })
        .alert(isPresented: $camera.alert) {
            Alert(title: Text("Please Enable Camera Access"))
        }
    }
    
    func startRecording() {
        print(camera.isRecording)
//        if camera.isRecording {
//            camera.stopSession()
//        } else {
//            camera.startRecording()
//        }
        camera.startRecording()
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
