//
//  CameraView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 28.11.20.
//

import SwiftUI
import FirebaseDatabase

struct CamView: View {
    var body: some View {
        CameraView()
    }
}

struct CameraView: View {
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    @StateObject var viewModel = CameraViewModel()
    
    var body: some View {
        return (
        VStack {
            NavigationLink(destination: PauseView().navigationBarHidden(true), tag: "Pause", selection: $viewModel.selection) { EmptyView() }
            NavigationLink(destination: FinishScreen().navigationBarHidden(true), tag: "Finish", selection: $viewModel.selection) { EmptyView() }
            ZStack(alignment: .top) {
               
                if viewModel.camera.isRecording {
                    Text("\(viewModel.timeMinutes):\(viewModel.timeSeconds)")
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(width: 70, height: 32, alignment: .center)
                        .background(Color.darkgreen)
                        .foregroundColor(.white)
                        .zIndex(2.0)
                        .cornerRadius(15.0)
                        .padding(.top, 20)
                } 
                CameraPreview(camera: viewModel.camera)
                    .ignoresSafeArea(.all, edges: .all)
                
            }
            Button(action: viewModel.onClick, label: {
                Image(systemName: viewModel.camera.isRecording ? "pause" : "video")
            }).buttonStyle(VideoButtonStyle(isRecording: $viewModel.camera.isRecording)).padding(.bottom, 20)
        }
        .environmentObject(status)
        .environmentObject(polarApi)
        .onAppear(perform: {
            viewModel.setup(status: self.status, polarApi: self.polarApi)
            viewModel.camera.checkAuth()
        })
            .alert(isPresented: $viewModel.camera.alert) {
            Alert(title: Text("Bitte erlaube Zugriff auf Kamera in den Einstellungen."))
        })
            .alert(isPresented: $viewModel.alert) { () -> Alert in
            let primaryButton = Alert.Button.cancel(Text("Ja")) {
                viewModel.stopCamera()
            }
            let secondaryButton = Alert.Button.default(Text("Nein")) {
                viewModel.camera.startRecording()
                viewModel.startTimer()
            }
            return Alert(title: Text("Aufnahme beenden"), message: Text("Wenn du fertig bist kannst du die Aufnahme stoppen. Jetzt beenden?"), primaryButton: primaryButton, secondaryButton: secondaryButton)
        }
    }
}


struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
