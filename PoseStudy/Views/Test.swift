//
//  Test.swift
//  PoseStudy
//
//  Created by Franziska Lang on 07.12.20.
//

import SwiftUI
import AVFoundation

struct Test: View {
    
    var body: some View {
        VStack {
            CameraView2()
        }
    }
}


struct CameraView2: View {
    
    @StateObject var camera = CameraModel()
    
    var body: some View{
        
        ZStack{
            
            // Going to Be Camera preview...
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                
                if camera.isTaken{
                    
                    HStack {
                        
                        Spacer()
                        
                        Button(action: camera.reTake, label: {

                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        })
                        .padding(.trailing,10)
                    }
                }
                
                Spacer()
                
                HStack{
                    Button(action: camera.takePic, label: {
                        
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
                .frame(height: 75)
            }
        }
        .onAppear(perform: {
            
            camera.checkAuth()
        })
        .alert(isPresented: $camera.alert) {
            Alert(title: Text("Please Enable Camera Access"))
        }
    }
}

// Camera Model...

class CameraModel: NSObject,ObservableObject,AVCapturePhotoCaptureDelegate{
    
    @Published var isTaken = false
    
    
    @Published var alert = false
    
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    // Pic Data...
    
    @Published var isSaved = false
    
    @Published var picData = Data(count: 0)
    
    func checkAuth(){
        
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
        
        do{
            
            // setting configs...
            self.session.beginConfiguration()
            
            // change for your own...
            
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            // checking and adding to session...
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            // same for output....
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    // take and retake functions...
    
    func takePic(){
        
        self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
        DispatchQueue.global(qos: .background).async {
            
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                
                withAnimation{self.isTaken.toggle()}
            }
        }
    }
    
    func reTake(){
        
        DispatchQueue.global(qos: .background).async {
            
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
                //clearing ...
                self.isSaved = false
                self.picData = Data(count: 0)
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if error != nil{
            return
        }
        
        print("pic taken...")
        
        guard let imageData = photo.fileDataRepresentation() else{return}
        
        self.picData = imageData
    }
    
    func savePic(){
        
        guard let image = UIImage(data: self.picData) else{return}
        
        // saving Image...
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        self.isSaved = true
        
        print("saved Successfully....")
    }
}

// setting view for preview...

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera : CameraModel
    
    func makeUIView(context: Context) ->  UIView {
     
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        // Your Own Properties...
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        // starting session
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}


struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
