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

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera : CameraModel
    
    func makeUIView(context: Context) ->  UIView {
     
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.previewLayer.frame = view.frame
   
        camera.previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
