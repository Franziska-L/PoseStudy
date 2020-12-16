//
//  ButtonStyle.swift
//  PoseStudy
//
//  Created by Franziska Lang on 02.12.20.
//

import Foundation
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [.darkgreen, .lightgreen]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .padding(.horizontal, 40)
            .padding(.vertical, 30)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct VideoButtonStyle: ButtonStyle {
    @Binding var isRecording: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .font(.title)
            .background(Color.darkgreen)
            .foregroundColor(.white)
            .clipShape(Circle())
            .scaleEffect(isRecording ? 0.6 : 0.9)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4))
    }
}

struct RecordButtonView: View {
    @State private var animationAmount: CGFloat = 1
    @Binding var isRecording: Bool
    
    var body: some View {
        Image(systemName: isRecording ? "stop" : "video").font(.title)
            .padding(30)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Circle())
            .scaleEffect(isRecording ? 0.6 : 0.9)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
        
        )
    }
}
