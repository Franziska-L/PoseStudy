//
//  Style.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import Foundation
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [Color("darkgreen"), Color("lightgreen")]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .padding(.horizontal, 40)
            .padding(.vertical, 30)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(Color("darkgreen"))
                .onTapGesture { configuration.isOn.toggle() }
            configuration
                .label
                .foregroundColor(configuration.isOn ? Color("darkgreen") : .black)
            Spacer()
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius:20))
    }
}

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.top, 40)
            .font(.title)
            .foregroundColor(Color("darkgreen"))
    }
}

extension View {
    func titleStyle() -> some View {
        self.modifier(Title())
    }
}

struct CaptureVideoButtonView: View {
    @State private var animationAmount: CGFloat = 1
    @Binding var isRecording: Bool
    
    var body: some View {
        Image(systemName: isRecording ? "stop" : "video").font(.title)
            .padding(30)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Circle())
            .scaleEffect(isRecording ? 0.7 : 0.9)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
        
        )
    }
}
