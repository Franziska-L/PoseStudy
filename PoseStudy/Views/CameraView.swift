//
//  CameraView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 28.11.20.
//

import SwiftUI

struct CameraView: View {
    
    @State var isRecording: Bool = false
    
    var body: some View {
        CameraViewController().edgesIgnoringSafeArea(.top)
        Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
            Text("Test")
        }.buttonStyle(CustomButtonStyle())
    }
}

func startRecording() {
    //start record video
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
