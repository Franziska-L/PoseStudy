//
//  InstructionView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct InstructionView: View {
    var img = ["pulsgurt", "position", "jumpingjack", "jumpingjack"]
    
    var image = "jumpingjack"
    var instr = [String.exerciseInstr1, String.exerciseInstr2, String.exerciseInstr3, String.exerciseInstr4]


    @State var step = 0
    @State private var offset: CGFloat = 0
    let spacing: CGFloat = 10
    let totalInstructions = 5
    
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    var body: some View {
        VStack {
            Text("Anweisungen").titleStyle()
            //Text("Gleich kannst du starten. Vorab noch einige Answeisungen. Bitte lies sie dir aufmerksam durch.")
            GeometryReader { geometry in
                return ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: self.spacing) {
                        CardView(image: "position", instruction: String.startInstr)
                            .frame(width: geometry.size.width).frame(height: 300)
                        ExerciseCardView(image: "position", instruction: String.exerciseInstr, exerciseInst: instr).frame(width: geometry.size.width).frame(height: 300)
                        CardView(image: "pulsgurt", instruction: String.polarDeviceIntr)
                            .frame(width: geometry.size.width).frame(height: 300)
                        ConnectingCardView(instruction: String.connectInstr).frame(width: geometry.size.width).frame(height: 300)
                        CardView(image: "position", instruction: String.positionInstr)
                            .frame(width: geometry.size.width).frame(height: 300)
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
                            if -value.predictedEndTranslation.width > geometry.size.width / 2, self.step < self.totalInstructions - 1 {
                                self.step += 1
                            }
                            if value.predictedEndTranslation.width > geometry.size.width / 2, self.step > 0 {
                                self.step -= 1
                            }
                            withAnimation { self.offset = -(geometry.size.width + self.spacing) * CGFloat(self.step) }
                        })
                )
            }.padding(.top, 32)
            HStack(spacing: 10) {
                ForEach(0 ..< totalInstructions) { position in
                    Image(systemName: position == self.step ? "circle.fill" : "circle").scaleEffect(position == self.step ? 1 : 0.65).foregroundColor(.darkgreen)
                }
            }
            NavigationLink(
                destination: CameraView().navigationBarHidden(true),
                label: {
                    Text("Los")
                }).buttonStyle(CustomButtonStyle()).disabled((self.step >= totalInstructions - 1) ? false : true)
        }.environmentObject(status).environmentObject(polarApi)
        .navigationBarBackButtonHidden(true)
    }
}




struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView().environmentObject(GlobalState())
    }
}
