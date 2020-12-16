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

enum CameraControllerError: Swift.Error {
   case captureSessionAlreadyRunning
   case captureSessionIsMissing
   case inputsAreInvalid
   case invalidOperation
   case noCamerasAvailable
   case unknown
}


class CameraController: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var session: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    //For saving videos
    var videoOutput: AVCaptureMovieFileOutput?
    var backgroundRecordingID: UIBackgroundTaskIdentifier?
  
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        //Setup session
        func createCaptureSession() {
            self.session = AVCaptureSession()
        }
        
        //Setup camera position
        func configureCaptureDevices() throws {
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {
                throw CameraControllerError.noCamerasAvailable
            }
            self.frontCamera = camera
            
            try camera.lockForConfiguration()
            camera.unlockForConfiguration()
        }
        
        //Setup input device
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
        
        //Setup output
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
            }
        }
        
        func startSession() throws {
            guard let session = self.session else {
                throw CameraControllerError.captureSessionIsMissing
            }
            session.startRunning()
        }
           
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configureVideoOutput()
                try startSession()
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
        self.previewLayer?.frame = view.frame
        view.layer.insertSublayer(self.previewLayer!, at: 0)
    }
    
//    func checkPermission() {
//            
//        // first checking camerahas got permission...
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            setUp()
//            return
//            // Setting Up Session
//        case .notDetermined:
//            // retusting for permission....
//            AVCaptureDevice.requestAccess(for: .video) { (status) in
//                
//                if status{
//                    self.setUp()
//                }
//            }
//        case .denied:
//            self.alert.toggle()
//            return
//            
//        default:
//            return
//        }
//    }
    
    func recording() {
        guard let movieFileOutput = self.videoOutput else {
            return
        }
        print("recording")
        
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
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mp4")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
                print("stoooop")
            }
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        /*if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
                    
                else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
                    let image = UIImage(data: data) {
                    
                    self.photoCaptureCompletionBlock?(image, nil)
                }
                    
                else {
                    self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
                }*/
        
        print("stop recording")
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
    
    func stopSession() throws {
        guard let session = self.session else {
            throw CameraControllerError.captureSessionIsMissing
        }
        session.stopRunning()
        print(session.isRunning)
    }
    
    
    func saveVideoToDatabase(url: URL,
                             success : @escaping (String) -> Void,
                             failure : @escaping (Error) -> Void) {
        // Data in memory
        let data = Data()
        print(url)
        do{
            try data.write(to: url, options: [.atomic])
            } catch {
                print("error with video!")
            }
        // Create a reference to the file you want to upload
        let riversRef = Storage.storage().reference().child("videos").child("video.mp4")

        // Upload the file to the path "images/rivers.jpg"
        riversRef.putFile(from: url, metadata: nil, completion:  { (metadata, error) in
            if error == nil {
                            print("Successful video upload")
                        } else {
                            print(error?.localizedDescription)
                        }
        })
    }
    
    
    func uploadToFireBaseVideo(url: URL,
                                      success : @escaping (String) -> Void,
                                      failure : @escaping (Error) -> Void) {

        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        let path = NSTemporaryDirectory() + name

        let dispatchgroup = DispatchGroup()

        dispatchgroup.enter()

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputurl = documentsURL.appendingPathComponent(name)
        var ur = outputurl
       
        let data = NSData(contentsOf: ur as URL)

        do {

            try data?.write(to: URL(fileURLWithPath: path), options: .atomic)

        } catch {

            print(error)
        }

        let storageRef = Storage.storage().reference().child("Videos").child(name)
        if let uploadData = data as Data? {
            storageRef.putData(uploadData, metadata: nil
                , completion: { (metadata, error) in
                    if let error = error {
                        failure(error)
                    }else{
//                        let strPic: String = (metadata?.downloadURL()?.absoluteString)!
//                        success(strPic)
                    }
            })
        }
    }
    
    func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
        try! FileManager.default.removeItem(at: outputURL as URL)
        let asset = AVURLAsset(url: inputURL as URL, options: nil)

        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously(completionHandler: {
            handler(exportSession)
        })
    }
}
