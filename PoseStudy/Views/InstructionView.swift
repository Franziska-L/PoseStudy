//
//  InstructionView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct InstructionView: View {
    @State var img = ["pulsgurt", "position", "jumpingjack", "jumpingjack", "jumpingjack"]
    @State var instructions = ["Lege jetzt das Pulsmessgerät unterhalb deiner Brust an.", "Positioniere das Handy seitlich sodass dein ganzer Körper zu sehen ist.", "Positioniere das Handy seitlich sodass dein ganzer Körper zu sehen ist.", "Stelle Hände unter die Schultern", "Achte auf eine Körperspannung in der Mitte"]

    @State var step = 0
    @State private var offset: CGFloat = 0
    let spacing: CGFloat = 10
    
    @EnvironmentObject var status: GlobalState
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Anweisungen").titleStyle().offset(y: -100)
                Spacer()
                Text("Gleich kannst du starten. Vorab noch einige Answeisungen. Bitte lies sie dir aufmerksam durch.")
                GeometryReader { geometry in
                    return ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: self.spacing) {
                            ForEach(0 ..< instructions.count) { position in
                                CardView(image: $img[position], instruction: $instructions[position])
                                    .frame(width: geometry.size.width).frame(height: 300)
                            }
                        }
                    }
                    .content.offset(x: self.offset)
                    .frame(width: geometry.size.width, alignment: .leading)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                self.offset = value.translation.width - geometry.size.width * CGFloat(self.step)
                            })
                            .onEnded({ value in
                                if -value.predictedEndTranslation.width > geometry.size.width / 2, self.step < self.img.count - 1 {
                                    self.step += 1
                                }
                                if value.predictedEndTranslation.width > geometry.size.width / 2, self.step > 0 {
                                    self.step -= 1
                                }
                                withAnimation { self.offset = -(geometry.size.width + self.spacing) * CGFloat(self.step) }
                            })
                    )
                }.padding(.top, 90)
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
        }.environmentObject(status)
        .navigationBarBackButtonHidden(true)
    }
}




struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView().environmentObject(GlobalState())
    }
}
