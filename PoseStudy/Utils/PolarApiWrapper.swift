//
//  PolarApiWrapper.swift
//  PoseStudy
//
//  Created by Franziska Lang on 14.12.20.
//

import Foundation
import PolarBleSdk
import RxSwift

enum ConnectionState {
    case connected
    case disconnected
    case failure
}

enum BlePowerState {
    case on
    case off
}

//class State: ObservableObject {
//    @Published var isConnected = false
//    @Published var streamStarted = false
//}

class PolarApiWrapper: ObservableObject, PolarBleApiObserver, PolarBleApiPowerStateObserver, PolarBleApiDeviceHrObserver {
    @Published var connetionState: ConnectionState = .disconnected
    @Published var blePowerState: BlePowerState = .off
    @Published var streanStarded: Bool = false
    
    var api: PolarBleApi
    var broadcast: Disposable?
    var autoConnect: Disposable?
    var ecgToggle: Disposable?
    var deviceId = "74D5EB20"
    
    init() {
        self.api = PolarBleApiDefaultImpl.polarImplementation(DispatchQueue.main, features: Features.allFeatures.rawValue)
        self.api.observer = self
    }
    
    func autoConnectToDevice() {
        autoConnect?.dispose()
        autoConnect = api.startAutoConnectToDevice(-55, service: nil, polarDeviceType: nil).subscribe() { e in
            switch e {
            case .completed:
                NSLog("auto connect search complete")
            case .error(let err):
                NSLog("auto connect failed: \(err)")
            }
        }
    }
    
    func startStreaming() {
        if ecgToggle == nil {
            ecgToggle = api.requestEcgSettings(deviceId).asObservable().flatMap({ (settings) -> Observable<PolarEcgData> in
                return self.api.startEcgStreaming(self.deviceId, settings: settings.maxSettings())
            }).observeOn(MainScheduler.instance).subscribe{ e in
                switch e {
                case .next(let data):
                    for µv in data.samples {
                        NSLog("    µV: \(µv)")
                    }
                case .error(let err):
                    NSLog("start ecg error: \(err)")
                    self.ecgToggle = nil
                case .completed:
                    break
                }
            }
        } else {
            ecgToggle?.dispose()
            ecgToggle = nil
        }
    }
    
    ///PolarBleApiObserver
    func deviceConnecting(_ identifier: PolarDeviceInfo) {
        NSLog("DEVICE CONNECTING: \(identifier)")
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
        print("(\(identifier)) HR notification: \(data.hr) rrs: \(data.rrs) rrsMs: \(data.rrsMs) c: \(data.contact) s: \(data.contactSupported)")
    }
    
}
