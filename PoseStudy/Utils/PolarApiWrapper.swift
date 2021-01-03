//
//  PolarApiWrapper.swift
//  PoseStudy
//
//  Created by Franziska Lang on 14.12.20.
//

import Foundation
import PolarBleSdk
import RxSwift
import FirebaseDatabase

enum ConnectionState {
    case connected
    case connecting
    case disconnected
    case failure
}

enum BlePowerState {
    case on
    case off
}

class PolarApiWrapper: ObservableObject,
                       PolarBleApiObserver,
                       PolarBleApiPowerStateObserver,
                       PolarBleApiDeviceHrObserver,
//                       PolarBleApiDeviceInfoObserver
                       PolarBleApiDeviceFeaturesObserver
//                       PolarBleApiLogger,
//                       PolarBleApiCCCWriteObserver
{
    @Published var connetionState: ConnectionState = .disconnected
    @Published var blePowerState: BlePowerState = .off
    
    var api: PolarBleApi
    var broadcast: Disposable?
    var autoConnect: Disposable?
    var ecgToggle: Disposable?
    var deviceId = "74D5EB20"
    
    @Published var ecgDataStream: [Int32] = [Int32]()
    @Published var hrDataStream: [UInt8] = [UInt8]()
    
    @Published var ecgDataTimestamp = [Int64]()
    @Published var hrDataTimestamp = [Int64]()
    
    @Published var rrsDataStream: [[Int]] = [[Int]]()
    @Published var rrMsDataStream: [[Int]] = [[Int]]()
    
    @Published var rrDataTimestamp = [Int64]()
    
    @Published var isRecording = false
    
    
    init() {
        self.api = PolarBleApiDefaultImpl.polarImplementation(DispatchQueue.main, features: Features.allFeatures.rawValue)
        self.api.observer = self
        self.api.powerStateObserver = self
        self.api.deviceHrObserver = self 
    }
    
    func autoConnectToDevice() {
        stopAutoConnectToDevice()
        autoConnect = api.startAutoConnectToDevice(-55, service: nil, polarDeviceType: nil).subscribe() { e in
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
        //Start ECG Stream
        ecgToggle = api.requestEcgSettings(deviceId).asObservable().flatMap({ (settings) -> Observable<PolarEcgData> in
            return self.api.startEcgStreaming(self.deviceId, settings: settings.maxSettings())
        }).observeOn(MainScheduler.instance).subscribe{ e in
            switch e {
            case .next(let data):
                for µv in data.samples {
                    NSLog("    µV: \(µv)")
                    self.ecgDataStream.append(µv)
                    
                    let timestamp = Date().toMillis()
                    self.ecgDataTimestamp.append(timestamp)
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
    }
    
    func stopStream() {
        //Stop HR Stream
        broadcast?.dispose()
        broadcast = nil
        
        //Stop ECG Stream
        ecgToggle?.dispose()
        ecgToggle = nil
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
        blePowerState = .on
    }
    
    func blePowerOff() {
        NSLog("BLE OFF")
        blePowerState = .off
    }
    
    ///PolarBleApiDeviceHrObserver
    func hrValueReceived(_ identifier: String, data: PolarHrData) {
        NSLog("(\(identifier)) HR notification: \(data.hr) rrs: \(data.rrs) rrsMs: \(data.rrsMs) c: \(data.contact) s: \(data.contactSupported)")
        if isRecording {
            rrsDataStream.append(data.rrs)
            rrMsDataStream.append(data.rrsMs)
            
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
