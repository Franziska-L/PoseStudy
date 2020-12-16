//
//  CameraViewController.swift
//  PoseStudy
//
//  Created by Franziska Lang on 30.11.20.
//

import Foundation
import SwiftUI
import UIKit
import AVFoundation

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

//
//
//final class CameraViewController: UIViewController {
//    let cameraController = CameraController()
//
//    @IBOutlet fileprivate var previewView: UIView!
//
//    override func viewDidLoad() {
//
//        previewView = UIView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
//        previewView.contentMode = UIView.ContentMode.scaleAspectFit
//        view.addSubview(previewView)
//
//        cameraController.prepare {(error) in
//            if let error = error {
//                print(error)
//            }
//
//            try? self.cameraController.displayPreview(on: self.previewView)
//        }
//    }
//}
//
//
///*extension CameraViewController : UIViewControllerRepresentable {
//    public typealias UIViewControllerType = CameraViewController
//
//    public func makeUIViewController(context: UIViewControllerRepresentableContext<CameraViewController>) -> CameraViewController {
//        return CameraViewController()
//    }
//
//    public func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraViewController>) {
//        cameraController.recording()
//    }
//}*/
//
//struct CameraRepresentable: UIViewControllerRepresentable {
//    typealias UIViewControllerType = CameraViewController
//
//
//    @Binding var isRecording: Bool
//    @Binding var didTap: Bool
//
//    public func makeUIViewController(context: Context) -> CameraViewController {
//        return CameraViewController()
//    }
//
//    public func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
//        if(self.didTap) {
//            DispatchQueue.main.async {
//                uiViewController.cameraController.recording()
//                self.didTap = false
//            }
//        }
//        if !isRecording {
//            try? uiViewController.cameraController.stopSession()
//        }
//    }
//}
//
