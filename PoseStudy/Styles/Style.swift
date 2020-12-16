//
//  Style.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import Foundation
import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(.darkgreen)
                .onTapGesture { configuration.isOn.toggle() }
            configuration
                .label
                .foregroundColor(configuration.isOn ? .darkgreen : .black)
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
            .foregroundColor(.darkgreen)
    }
}

extension View {
    func titleStyle() -> some View {
        self.modifier(Title())
    }
}


