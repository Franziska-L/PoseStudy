//
//  CameraViewController.swift
//  PoseStudy
//
//  Created by Franziska Lang on 30.11.20.
//

import Foundation
import SwiftUI
import UIKit

final class CameraViewController: UIViewController {
    let cameraController = CameraController()
    
    @IBOutlet fileprivate var previewView: UIView!
    
    override func viewDidLoad() {
                    
        previewView = UIView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(previewView)
        
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.previewView)
        }
    }
}


/*extension CameraViewController : UIViewControllerRepresentable {
    public typealias UIViewControllerType = CameraViewController
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<CameraViewController>) -> CameraViewController {
        return CameraViewController()
    }
    
    public func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraViewController>) {
        cameraController.recording()
    }
}*/

struct CameraRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraViewController
    
    
    @Binding var didTapCapture: Bool
    
    public func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }
    
    public func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if(self.didTapCapture) {
            uiViewController.cameraController.recording()
        }
    }
        
 
    
}
