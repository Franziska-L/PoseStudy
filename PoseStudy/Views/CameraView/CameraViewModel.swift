//
//  CameraViewModel.swift
//  PoseStudy
//
//  Created by Franziska Lang on 17.10.21.
//

import SwiftUI
import FirebaseDatabase

final class CameraViewModel: ObservableObject {
    @Published var status: GlobalState?
    @Published var polarApi: PolarApiWrapper?
    
    @ObservedObject var camera = CameraModel()

    func setup(status: GlobalState, polarApi: PolarApiWrapper) {
        self.status = status
        self.polarApi = polarApi
    }
    @State var selection: String? = nil
        
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timeSeconds: String = "00"
    @State var timeMinutes: String = "00"
    @State var timer: Timer? = nil
    
    @State var isRecording = false
    @State var data = MeasuredData()

    @State var alert = false
    
    func onClick() {
        if camera.authState && camera.cameraAvailable {
            camera.startRecording()
            if !camera.isRecording {
                self.setStartTime()
                self.startTimer()
                self.polarApi?.startStreaming()
            }
            else {
                alert = true
                timer?.invalidate()
            }
        } else {
            camera.checkAuth()
        }
    }
    
    func stopCamera() {
        self.camera.stopSession()
        self.stopTimer()
        self.polarApi?.stopStream()
        self.saveToDatabase()
        if status?.session == 2 {
            self.selection = "Finish"
        } else {
            self.selection = "Pause"
        }
    }
    
    func startTimer() {
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
            if self.minutes < 10 {
                self.timeMinutes = "0\(self.minutes)"
            } else {
                self.timeMinutes = "\(self.minutes)"
            }
            if self.seconds < 10 {
                self.timeSeconds = "0\(self.seconds)"
            } else {
                self.timeSeconds = "\(self.seconds)"
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        minutes = 0
        seconds = 0
        timeSeconds = "0\(seconds)"
        timeMinutes = "0\(minutes)"
    }
    
    func setStartTime() {
        guard let status = status else {
            return
        }
        let timestampStart: Int64 = Date().toMillis()

        data.startTime = timestampStart
        let ref: DatabaseReference = Database.database().reference().child(String.participants).child("Participant \(status.participantID)").child("Day \(status.day)").child("Session \(status.session)")
        ref.setValue(["Start Time": timestampStart])
    }
    
    
    func saveToDatabase() {
        guard let status = status else {
            return
        }
        guard let polarApi = polarApi else {
            return 
        }
        let timestampEnd = Date().toMillis()
        
        let ref: DatabaseReference = Database.database().reference().child(String.participants).child("Participant \(status.participantID)").child("Day \(status.day)").child("Session \(status.session)")
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
        
        status.userData.measured.append(data)

        
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
