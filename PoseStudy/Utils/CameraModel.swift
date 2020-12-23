//
//  CameraController.swift
//  PoseStudy
//
//  Created by Franziska Lang on 30.11.20.
//

import UIKit
import AVFoundation
import Photos
import FirebaseStorage


class CameraModel: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate{
    @Published var isRecording = false
    @Published var cameraAvailable = false
    @Published var authState = false
    @Published var alert = false
    
    @Published var session = AVCaptureSession()
    @Published var output = AVCaptureMovieFileOutput()
    @Published var previewLayer : AVCaptureVideoPreviewLayer!

    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    var backgroundRecordingID: UIBackgroundTaskIdentifier?
       
    func checkAuth() {
        
        // Check if camera has permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUpCamera()
            authState = true
            return
        case .notDetermined:
            // retusting for permission
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    self.setUpCamera()
                    DispatchQueue.main.async {
                        self.authState = true
                    }
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUpCamera() {
        do {
            func createCaptureSession() {
                self.session = AVCaptureSession()
            }
            self.session.beginConfiguration()

            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)

            guard device != nil, let deviceInput = try? AVCaptureDeviceInput(device: device!), session.canAddInput(deviceInput) else {
                print("nicht availbale")
                return
            }
            
            if self.session.canAddInput(deviceInput){
                self.session.addInput(deviceInput)
            }

            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }

            self.session.commitConfiguration()
            self.session.startRunning()
            DispatchQueue.main.async {
                self.cameraAvailable = true
            }
        }
    }
    

    
    func startRecording(){
        let videoPreviewLayerOrientation = previewLayer?.connection?.videoOrientation
        
        DispatchQueue(label: "session queue").async {
            if !self.output.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    //ToDo schau ob hier nötig oder wieder auskommentieren
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // Update the orientation on the movie file output video connection before recording.
                let movieFileOutputConnection = self.output.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
                
                let availableVideoCodecTypes = self.output.availableVideoCodecTypes
                
                if availableVideoCodecTypes.contains(.hevc) {
                    self.output.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
                // Start recording video to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mp4")!)
                self.output.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                DispatchQueue.main.async {
                    self.isRecording = false
                }
                self.output.stopRecording()
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func stopSession() {
        self.session.stopRunning()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // Note: Because we use a unique file path for each recording, a new recording won't overwrite a recording mid-save.
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
            
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true

        if error != nil {
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        
        if success {
            
//            saveVideoToDatabase(url: outputFileURL) { (success) in
//                print("test")
//                cleanup()
//            } failure: { (error) in
//                print(error)
//                cleanup()
//            }
//


//            print(outputFileURL)
//            // Check the authorization status.
//            PHPhotoLibrary.requestAuthorization { status in
//                if status == .authorized {
//                    // Save the movie file to the photo library and cleanup.
//                    PHPhotoLibrary.shared().performChanges({
//                        let options = PHAssetResourceCreationOptions()
//                        options.shouldMoveFile = true
//                        let creationRequest = PHAssetCreationRequest.forAsset()
//                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
//                    }, completionHandler: { success, error in
//                        if !success {
//                            print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
//                        }
//                        cleanup()
//                    }
//                    )
//                } else {
//                    cleanup()
//                }
//            }
        } else {
            cleanup()
        }
    }
    
    
}
