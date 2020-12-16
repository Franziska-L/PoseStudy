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
    
    var body: some View {
        VStack {
            CameraView2()
        }
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

// Camera Model...

class CameraModel: NSObject,ObservableObject,AVCaptureFileOutputRecordingDelegate{
    @Published var isRecording = false
    @Published var stoppedRecording = false
    
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
            return
        case .notDetermined:
            // retusting for permission
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    self.setUpCamera()
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
            // setting configs...
            self.session.beginConfiguration()

            // change for your own...

            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)

            guard device != nil, let deviceInput = try? AVCaptureDeviceInput(device: device!), session.canAddInput(deviceInput) else {
                        return
            }
            
            if self.session.canAddInput(deviceInput){
                self.session.addInput(deviceInput)
            }

            // same for output....

            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    // take and retake functions...
    
    func startRecording(){
        
        print("recording")
        let videoPreviewLayerOrientation = previewLayer?.connection?.videoOrientation
        
        DispatchQueue(label: "session queue").async {
            if !self.output.isRecording {
                DispatchQueue.main.async {
                    self.isRecording = true
                }
                if UIDevice.current.isMultitaskingSupported {
                    //self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
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
    
    func stopSession() {
        self.session.stopRunning()
        print(session.isRunning)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("end")
        stoppedRecording = true
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
    
    
}

// setting view for preview...

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera : CameraModel
    
    func makeUIView(context: Context) ->  UIView {
     
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.previewLayer.frame = view.frame
        
        // Your Own Properties...
        camera.previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
