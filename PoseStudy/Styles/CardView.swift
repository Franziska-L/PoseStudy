//
//  CardView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 02.12.20.
//

import SwiftUI

struct CardView: View {
    @Binding var image: String
    @Binding var instruction: String
    
    var body: some View {
        GeometryReader { geometry in
                    VStack(alignment: .leading) {
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
                            .clipped()
                        Text(instruction)
                            .padding()
                            .font(.title2)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
    }
}
