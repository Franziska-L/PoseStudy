//
//  InstructionView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct InstructionView: View {
    var instr = [String.exerciseInstr1, String.exerciseInstr11 , String.exerciseInstr2, String.exerciseInstr3, String.exerciseInstr4]

    @State private var selection: String? = nil
    
    @State var step = 0
    @State private var offset: CGFloat = 0
    let spacing: CGFloat = 10
    let totalInstructions = 5
    
    @State var alert = false
    
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    var body: some View {
        VStack {
            NavigationLink(destination: CamView().navigationBarHidden(true), tag: "Camera", selection: $selection) { EmptyView() }
            Text("Anweisungen").titleStyle()
            GeometryReader { geometry in
                return VStack {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: self.spacing) {
                            CardView(image: "pushUp", instruction: String.startInstr)
                                .frame(width: geometry.size.width).frame(height: 300)
                            ExerciseCardView(image: "pushUpKnee", instruction: String.exerciseInstr, exerciseInst: instr).frame(width: geometry.size.width).frame(height: 300)
                            SensorCardView(image: "pulsgurt", instruction: String.polarDeviceIntr)
                                .frame(width: geometry.size.width).frame(height: 300)
                            ConnectingCardView(instruction: String.connectInstr).frame(width: geometry.size.width).frame(height: 300)
                            PositionCardView(image: "position2")
                                .frame(width: geometry.size.width).frame(height: 300)
                        }
                    }
                    .content.offset(x: self.offset)
                    .frame(width: geometry.size.width, alignment: .leading)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                if abs(value.translation.width) > 50 {
                                    self.offset = value.translation.width - geometry.size.width * CGFloat(self.step)
                                }
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
                    Spacer()
                    HStack(spacing: 10) {
                        ForEach(0 ..< totalInstructions) { position in
                            Image(systemName: position == self.step ? "circle.fill" : "circle").scaleEffect(position == self.step ? 1 : 0.65).foregroundColor(.darkgreen)
                        }
                    }
                    Button(action: {
                        if polarApi.connectionState == .connected && (self.step >= totalInstructions - 1) && polarApi.isECGReady() {
                            selection = "Camera"
                        }
                        if (self.step >= totalInstructions - 1) && !polarApi.isECGReady() {
                            alert = true
                        } else {
                            self.step += 1
                            withAnimation { self.offset = -(CGFloat(geometry.size.width) + self.spacing) * CGFloat(self.step) }
                        }
                    }, label: {
                        if self.step >= totalInstructions - 1 {
                            Text(String.go)
                        } else {
                            Text(String.next)
                        }
                    }).buttonStyle(CustomButtonStyle())
                }
            }.padding(.top, 28)
        }.environmentObject(status).environmentObject(polarApi)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $alert, content: {
            Alert(title: Text(String.connection), message: Text(String.connectionMessage))
        })
    }
    
    
    func startCamera(width: CGFloat) {
        if polarApi.connectionState == .connected && (self.step >= totalInstructions - 1) && polarApi.isECGReady() {
            selection = "Camera"
        }
        if (self.step >= totalInstructions - 1) && !polarApi.isECGReady() {
            alert = true
        } else {
            self.step += 1
            withAnimation { self.offset = -(CGFloat(width) + self.spacing) * CGFloat(self.step) }
        }
    }
}




struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView().environmentObject(GlobalState())
    }
}
