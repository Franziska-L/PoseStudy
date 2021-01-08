//
//  PolarApiWrapper.swift
//  PoseStudy
//
//  Created by Franziska Lang on 14.12.20.
//

import Foundation
import SwiftUI
import PolarBleSdk
import RxSwift
import FirebaseDatabase

enum ConnectionState {
    case connected
    case connecting
    case disconnected
    case failure
}


class PolarApiWrapper: ObservableObject,
                       PolarBleApiObserver,
                       PolarBleApiPowerStateObserver,
                       PolarBleApiDeviceHrObserver,
                       PolarBleApiDeviceFeaturesObserver
//                       PolarBleApiDeviceInfoObserver
//                       PolarBleApiLogger,
//                       PolarBleApiCCCWriteObserver
{
    @Published var connetionState: ConnectionState = .disconnected
    
    var api: PolarBleApi
    var broadcast: Disposable?
    var autoConnect: Disposable?
    var ecgToggle: Disposable?
    var deviceId = "74D5EB20"
    
    @Published var bleState = BleState.unknown
        
    @Published var isFeatureReady = false
    //TODO: Lösche hier alle Werte die nicht gebraucht werden und Überprüfe alles
    @Published var ecgDataStream: [Int32] = [Int32]()
    @Published var ecgDataStreamTest: [Int32] = [Int32]()
    @Published var hrDataStream: [UInt8] = [UInt8]()
   
    @Published var ecgDataStreamPerSecond: [[Int32]] = [[Int32]]()
    
    @Published var ecgDataTimestamp = [Int64]()
    @Published var hrDataTimestamp = [Int64]()
    
    @Published var hrDataStreamTest: [UInt8] = [UInt8]()
    @Published var rrsDataStream: [[Int]] = [[Int]]()
    @Published var rrMsDataStream: [[Int]] = [[Int]]()
    
    @Published var rrDataTimestamp = [Int64]()
    
    @Published var hrDataStreamBreak: [UInt8] = [UInt8]()
    @Published var hrDataTimestampBreak = [Int64]()
    @Published var rrsDataStreamBreak: [[Int]] = [[Int]]()
    @Published var rrMsDataStreamBreak: [[Int]] = [[Int]]()
    
    @Published var rrDataTimestampBreak = [Int64]()
    
    @Published var isRecording = false
    @Published var streamReady = false
    @State var timer: Timer? = nil
    
    init() {
        self.api = PolarBleApiDefaultImpl.polarImplementation(DispatchQueue.main, features: Features.allFeatures.rawValue)
        self.api.observer = self
        self.api.powerStateObserver = self
        self.api.deviceHrObserver = self
        self.api.deviceFeaturesObserver = self
    }
    
    func autoConnectToDevice() {
        stopAutoConnectToDevice()
        autoConnect = api.startAutoConnectToDevice(-55, service: nil, polarDeviceType: "H10").subscribe() { e in
            switch e {
            case .completed:
                NSLog("auto connect search complete")
            case .error(let err):
                NSLog("auto connect failed: \(err)")
            }
        }
    }
    
    func stopAutoConnectToDevice() {
        autoConnect?.dispose()
        autoConnect = nil
    }
    
    func startStreaming() {
        //        let tiem = api.setLocalTime(self.deviceId, time: Date.init(timeIntervalSince1970: NSTimeIntervalSince1970), zone: TimeZone.current)
        //        print(tiem)
                //Start ECG Stream

                //TODO schau ob ecg ready ist sonst nimmts nicht auf
        let ready = isFeatureReady(self.deviceId, feature: Features.polarSensorStreaming.rawValue)
        if ready {
            stopECGStream()
            ecgToggle = api.requestEcgSettings(deviceId).asObservable().flatMap({ (settings) -> Observable<PolarEcgData> in
                return self.api.startEcgStreaming(self.deviceId, settings: settings.maxSettings())
            }).observeOn(MainScheduler.instance).subscribe{ e in
                switch e {
                case .next(let data):
                    NSLog("      Timestamp: \(data.timeStamp)")
                    for µv in data.samples {
                        NSLog("    µV: \(µv)")
                        self.ecgDataStream.append(µv)
                        self.ecgDataStreamTest.append(µv)

                        let timestamp = Date().toMillis()
                        self.ecgDataTimestamp.append(timestamp)
                        //self.timer?.invalidate()
    //                    self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { time in
    //                        self.ecgDataStreamPerSecond.append(self.ecgDataStreamTest)
    //                        self.ecgDataStreamTest.removeAll()
    //                        //self.timer?.invalidate()
    //                    }
                    }
                    self.isRecording = true
                case .error(let err):
                    NSLog("start ecg error: \(err)")
                    self.ecgToggle = nil
                case .completed:
                    break
                }
            }
            
          
            //Start HR Stream
            broadcast = api.startListenForPolarHrBroadcasts(nil).observeOn(MainScheduler.instance).subscribe{ e in
                switch e {
                case .completed:
                    NSLog("completed")
                case .error(let err):
                    NSLog("listening error: \(err)")
                case .next(let broadcast):
                    NSLog("\(broadcast.deviceInfo.name) HR BROADCAST: \(broadcast.hr)")
                    self.hrDataStream.append(broadcast.hr)
                    
                    let timestamp = Date().toMillis()
                    self.hrDataTimestamp.append(timestamp)
                }
            }
            //TODO: mit timesamps schauen dass alle dieselben sind
            //TODO das hier funktioniert noch nicht!
            if isRecording {
                DispatchQueue.main.async {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { time in
                        NSLog("Timer \(time)")
                        self.ecgDataStreamPerSecond.append(self.ecgDataStreamTest)
                        self.ecgDataStreamTest.removeAll()
                        //self.timer?.invalidate()
                    }
                    self.timer?.fire()
                }
            }
        } else {
            //TODO wenn ecg features nicht ready sind???
        }
    }
    
    
    func isECGReady() -> Bool {
        return isFeatureReady(self.deviceId, feature: Features.polarSensorStreaming.rawValue)
    }
    
    
    func isFeatureReady(_ identifier: String, feature: Int) -> Bool {
        return self.api.isFeatureReady(identifier, feature: Features.init(rawValue: feature) ?? Features.allFeatures)
    }
    
    
    private func stopECGStream() {
        ecgToggle?.dispose()
        ecgToggle = nil
    }
    
    
    func stopStream() {
        //Stop HR Stream
        broadcast?.dispose()
        broadcast = nil
        
        //Stop ECG Stream
        ecgToggle?.dispose()
        ecgToggle = nil
        
        
        if !ecgDataStreamTest.isEmpty {
            //ecgDataStreamPerSecond.append(ecgDataStreamTest)
        }
        print(hrDataStream)
        print(hrDataStreamTest)
        print(ecgDataStream)

        hrDataStreamTest.removeAll()
        isRecording = false
        
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    ///PolarBleApiObserver
    func deviceConnecting(_ identifier: PolarDeviceInfo) {
        NSLog("DEVICE CONNECTING: \(identifier)")
        connetionState = .connecting
    }
    
    func deviceConnected(_ identifier: PolarDeviceInfo) {
        NSLog("DEVICE CONNECTED: \(identifier)")
        deviceId = identifier.deviceId
        connetionState = .connected
    }
    
    func deviceDisconnected(_ identifier: PolarDeviceInfo) {
        NSLog("DISCONNECTED: \(identifier)")
        connetionState = .disconnected
    }
    
    
    ///PolarBleApiPowerStateObserver
    func blePowerOn() {
        NSLog("BLE ON")
        bleState = .poweredOn
    }
    
    func blePowerOff() {
        NSLog("BLE OFF")
        bleState = .poweredOff
    }
    
    ///PolarBleApiDeviceHrObserver
    func hrValueReceived(_ identifier: String, data: PolarHrData) {
        //NSLog("(\(identifier)) HR notification: \(data.hr) rrs: \(data.rrs) rrsMs: \(data.rrsMs) c: \(data.contact) s: \(data.contactSupported)")
        if isRecording {
            rrsDataStream.append(data.rrs)
            rrMsDataStream.append(data.rrsMs)
            hrDataStreamTest.append(data.hr)
            
            let timestamp = Date().toMillis()
            rrDataTimestamp.append(timestamp)
        }
    }
    
    
    ///PolarBleApiDeviceFeaturesObserver
    func hrFeatureReady(_ identifier: String) {
        NSLog("HR READY")
    }
    
    func ecgFeatureReady(_ identifier: String) {
        NSLog("ECG READY")
        self.streamReady = true
        
    }
    
    func accFeatureReady(_ identifier: String) {
        NSLog("ACC READY")
    }
    
    func ohrPPGFeatureReady(_ identifier: String) {
        NSLog("PPG READY")
    }
    
    func ohrPPIFeatureReady(_ identifier: String) {
        NSLog("PPI READY")
    }
    
    func ftpFeatureReady(_ identifier: String) {
        NSLog("FTP READY")
    }
}
