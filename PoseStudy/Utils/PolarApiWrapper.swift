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
import CoreBluetooth

enum ConnectionState {
    case connected
    case connecting
    case disconnected
    case failure
    case unknown
    case notAvailable
}


class PolarApiWrapper: ObservableObject,
                       PolarBleApiObserver,
                       PolarBleApiPowerStateObserver,
                       PolarBleApiDeviceHrObserver,
                       PolarBleApiDeviceFeaturesObserver,
                       PolarBleApiDeviceInfoObserver,
                       PolarBleApiLogger,
                       PolarBleApiCCCWriteObserver
{

    
    var api: PolarBleApi
    var broadcast: Disposable?
    var autoConnect: Disposable?
    var searchToggle: Disposable?
    var ecgToggle: Disposable?
    var deviceId = "74D5EB20"
    var timer: Timer? = nil
    
    @Published var searchDone = true
    
    @Published var bleState = BleState.unknown
    @Published var connectionState: ConnectionState = .unknown
    
    @Published var ecgDataStream: [Int32] = [Int32]()
    @Published var ecgDataStreamTest: [Int32] = [Int32]()
    @Published var hrDataStream: [UInt8] = [UInt8]()
   
    @Published var ecgDataStreamPerSecond: [[Int32]] = [[Int32]]()
    
    @Published var ecgDataTimestamp = [Int64]()
    @Published var hrDataTimestamp = [Int64]()
    
    @Published var hrDataStreamPerSec: [UInt8] = [UInt8]()
    @Published var rrsDataStream: [[Int]] = [[Int]]()
    @Published var rrMsDataStream: [[Int]] = [[Int]]()
    
    @Published var rrDataTimestamp = [Int64]()
    
    @Published var ecgResting: [Int32] = [Int32]()

    @Published var isRecording = false
    @Published var streamReady = false
    
    init() {
        self.api = PolarBleApiDefaultImpl.polarImplementation(DispatchQueue.main, features: Features.allFeatures.rawValue)
        self.api.observer = self
        self.api.powerStateObserver = self
        self.api.deviceHrObserver = self
        self.api.deviceFeaturesObserver = self
        self.api.logger = self
        self.api.cccWriteObserver = self
        self.api.polarFilter(false)
    }
    
    func autoConnectToDevice() {
        stopAutoConnectToDevice()
        autoConnect = api.startAutoConnectToDevice(-55, service: nil, polarDeviceType: "H10").subscribe() { e in
            switch e {
            case .completed:
                NSLog("auto connect search complete")
            case .error(let err):
                NSLog("auto connect failed: \(err)")
                self.connectionState = .failure
            }
        }
    }
    
    func stopAutoConnectToDevice() {
        autoConnect?.dispose()
        autoConnect = nil
    }
    
    func searchForDevice() {
        if searchToggle != nil {
            self.stopSearch()
        }
        searchDone = false
        searchToggle = api.searchForDevice().observeOn(MainScheduler.instance).subscribe{ e in
            switch e {
            case .completed:
                NSLog("search complete")
            case .error(let err):
                NSLog("search error: \(err)")
            case .next(let item):
                if item.name.contains("H10") {
                    self.autoConnectToDevice()
                    self.stopSearch()
                } else {
                    self.connectionState = .notAvailable
                }
                NSLog("polar device found: \(item.name) connectable: \(item.connectable) address: \(item.address.uuidString)")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.searchDone = true
        }
    }
    
    func stopSearch() {
        searchToggle?.dispose()
        searchToggle = nil
    }
    
    func startStreaming() {
    //Start ECG Stream
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
                NSLog("\(broadcast.deviceInfo.name) HR BROADCAST: \(broadcast.hr)  Battery: \(broadcast.batteryStatus)")
                self.hrDataStream.append(broadcast.hr)
                
                let timestamp = Date().toMillis()
                self.hrDataTimestamp.append(timestamp)
            }
        }
        
        DispatchQueue.main.async {
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    self.ecgDataStreamPerSecond.append(self.ecgDataStreamTest)
                    self.ecgDataStreamTest.removeAll()
                }
            }
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
        
        broadcast?.dispose()
        broadcast = nil
    }
    
    
    func stopStream() {
        //Stop HR Stream
        stopECGStream()
        
        isRecording = false
        
        if self.timer != nil {
            self.timer?.invalidate()
        }
        self.timer = nil
        
        if !ecgDataStreamTest.isEmpty {
            self.ecgDataStreamPerSecond.append(ecgDataStreamTest)
            self.ecgDataStreamTest.removeAll()
        }
    }
    
    ///PolarBleApiObserver
    func deviceConnecting(_ identifier: PolarDeviceInfo) {
        NSLog("DEVICE CONNECTING: \(identifier)")
        connectionState = .connecting
    }
    
    func deviceConnected(_ identifier: PolarDeviceInfo) {
        NSLog("DEVICE CONNECTED: \(identifier)")
        deviceId = identifier.deviceId
        connectionState = .connected
    }
    
    func deviceDisconnected(_ identifier: PolarDeviceInfo) {
        NSLog("DISCONNECTED: \(identifier)")
        connectionState = .disconnected
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
            hrDataStreamPerSec.append(data.hr)
            
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
    
    /// PolarBleApiDeviceInfoObserver
    func batteryLevelReceived(_ identifier: String, batteryLevel: UInt) {
        NSLog("battery level updated: \(batteryLevel)")
    }
    
    func disInformationReceived(_ identifier: String, uuid: CBUUID, value: String) {
        NSLog("dis info: \(uuid.uuidString) value: \(value)")
    }
    
    func message(_ str: String) {
        NSLog(str)
    }
    
    /// ccc write observer
    func cccWrite(_ address: UUID, characteristic: CBUUID) {
        NSLog("ccc write: \(address) chr: \(characteristic)")
    }
}
