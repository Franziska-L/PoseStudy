//
//  CameraController.swift
//  PoseStudy
//
//  Created by Franziska Lang on 30.11.20.
//

import UIKit
import AVFoundation

enum CameraControllerError: Swift.Error {
   case captureSessionAlreadyRunning
   case captureSessionIsMissing
   case inputsAreInvalid
   case invalidOperation
   case noCamerasAvailable
   case unknown
}


class CameraController: NSObject, AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // Note: Because we use a unique file path for each recording, a new recording won't overwrite a recording mid-save.
        /*func cleanup() {
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
            // Check the authorization status.
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // Save the movie file to the photo library and cleanup.
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }, completionHandler: { success, error in
                        if !success {
                            print("AVCam couldn't save the movie to your photo library: \(String(describing: error))")
                        }
                        cleanup()
                    }
                    )
                } else {
                    cleanup()
                }
            }
        } else {
            cleanup()
        }
        
        // Enable the Camera and Record buttons to let the user switch camera and start another recording.
        DispatchQueue.main.async {
            // Only enable the ability to change camera if the device has more than one camera.
            self.cameraButton.isEnabled = self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
            self.recordButton.isEnabled = true
            self.captureModeControl.isEnabled = true
            self.recordButton.setImage(#imageLiteral(resourceName: "CaptureVideo"), for: [])
        }*/
    }
    
    
    var session: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var videoOutput: AVCaptureMovieFileOutput?
    
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.session = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {
                throw CameraControllerError.noCamerasAvailable
            }
            self.frontCamera = camera
            
            try camera.lockForConfiguration()
            camera.unlockForConfiguration()
        }
        
        func configureDeviceInputs() throws {
            guard let session = self.session else {
                throw CameraControllerError.captureSessionIsMissing
            }
               
            if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                   
                if session.canAddInput(self.frontCameraInput!) {
                    session.addInput(self.frontCameraInput!)
                } else { throw CameraControllerError.inputsAreInvalid }
                   
            } else { throw CameraControllerError.noCamerasAvailable }
        }
        
        func configureVideoOutput() throws {
            guard let session = self.session else {
                throw CameraControllerError.captureSessionIsMissing
            }
            
            self.videoOutput = AVCaptureMovieFileOutput()
            
            if session.canAddOutput(self.videoOutput!) {
                session.addOutput(self.videoOutput!)
                session.sessionPreset = .high
                if let connection = videoOutput!.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                //self.session.commitConfiguration()
                
            }
            session.startRunning()
        }
           
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configureVideoOutput()
            }
                
            catch {
                DispatchQueue.main.async{
                    completionHandler(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    
    func displayPreview(on view: UIView) throws {
        guard let session = self.session, session.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
            
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func recording(completion: (UIImage?, Error?) -> Void) {
        guard let movieFileOutput = self.videoOutput else {
            return
        }
        
        let videoPreviewLayerOrientation = previewLayer?.connection?.videoOrientation
        
        DispatchQueue(label: "session queue").async {
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    //self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // Update the orientation on the movie file output video connection before recording.
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
                
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
                // Start recording video to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }
}
