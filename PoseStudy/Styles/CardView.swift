//
//  CardView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 02.12.20.
//

import SwiftUI

struct CardView1: View {
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
                        Text(instruction).padding().font(.title2)
                    }
                    .padding(.bottom)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
    }
}

struct CardView_Previews: PreviewProvider {
    @State var img: String = "jumpingjack"
    @State var instruction: String = "Test"
    
    static var previews: some View {
        Preview()
    }
    
    struct Preview: View {
        @State var img: String = "jumpingjack"
        @State var instruction: String = "Test"
        
        var body: some View {
            CardView1(image: $img, instruction: $instruction).frame(height: 300).padding()
            }
    }
}
