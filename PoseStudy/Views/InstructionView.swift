//
//  InstructionView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct InstructionView: View {
    @State var img = ["jumpingjack", "jumpingjack", "jumpingjack", "jumpingjack", "jumpingjack"]
    @State var instructions = ["Lege jetzt den Brustgurt an", "Positioniere das Handy seitlich sodass dein ganzer Körper zu sehen ist.", "Positioniere das Handy seitlich sodass dein ganzer Körper zu sehen ist.", "Stelle Hände unter die Schultern", "Achte auf eine Körperspannung in der Mitte"]

    @State var step = 0
    @State private var offset: CGFloat = 0
    let spacing: CGFloat = 10
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Anweisungen").titleStyle().offset(y: -100)
                Spacer()
                VStack {
                    GeometryReader { geometry in
                        return ScrollView(.horizontal, showsIndicators: true) {
                            HStack(spacing: self.spacing) {
                                ForEach(0 ..< instructions.count) { position in
                                    CardView(image: $img[position], instruction: $instructions[position])
                                        .frame(width: geometry.size.width).frame(height: 200)
                                }
                            }
                        }
                        .content.offset(x: self.offset)
                        .frame(width: geometry.size.width, alignment: .leading)
                        .gesture(
                            DragGesture()
                                .onChanged({ value in
                                    self.offset = value.translation.width - geometry.size.width * CGFloat(self.step)
                                    print("weiter/zurück")
                                })
                                .onEnded({ value in
                                    print("test")
                                    if -value.predictedEndTranslation.width > geometry.size.width / 2, self.step < self.img.count - 1 {
                                        self.step += 1
                                    }
                                    if value.predictedEndTranslation.width > geometry.size.width / 2, self.step > 0 {
                                        self.step -= 1
                                    }
                                    withAnimation { self.offset = -(geometry.size.width + self.spacing) * CGFloat(self.step) }
                                })
                        )
                    }
                    HStack(spacing: 10) {
                        ForEach(0 ..< instructions.count) { position in
                            Image(systemName: position == self.step ? "circle.fill" : "circle").scaleEffect(position == self.step ? 1 : 0.65).foregroundColor(Color("darkgreen"))
                                
                        }
                    }
                    NavigationLink(
                        destination: CameraView().navigationBarHidden(true),
                        label: {
                            Text("Go")
                            
                        }).buttonStyle(CustomButtonStyle()).disabled(self.step >= img.count - 1 ? false : true)
                }
            }
        }
    }
}

struct SwipeView: View {
    @State private var offset: CGFloat = 0
    let spacing: CGFloat = 10
    @Binding var index: Int
    
    @Binding var img: [String]
    @Binding var instructions: [String]
    

    var body: some View {
        GeometryReader { geometry in
            return ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: self.spacing) {
                    ForEach(0 ..< instructions.count) { position in
                        CardView(image: $img[position], instruction: $instructions[position])
                            .frame(width: geometry.size.width)
                    }
                }
            }
            .content.offset(x: self.offset)
            .frame(width: geometry.size.width, alignment: .leading)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        self.offset = value.translation.width - geometry.size.width * CGFloat(self.index)
                    })
                    .onEnded({ value in
                        if -value.predictedEndTranslation.width > geometry.size.width / 2, self.index < self.img.count - 1 {
                            self.index += 1
                        }
                        if value.predictedEndTranslation.width > geometry.size.width / 2, self.index > 0 {
                            self.index -= 1
                        }
                        withAnimation { self.offset = -(geometry.size.width + self.spacing) * CGFloat(self.index) }
                    })
            )
        }
    }
}


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
                        Text(instruction).padding().font(.title2)
                    }
                    .padding(.bottom)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
    }
}


struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView()
    }
}
