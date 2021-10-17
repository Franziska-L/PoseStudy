//
//  InstructionView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

let spacing = 10.0

struct InstructionView: View {
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
   
    @StateObject var viewModel = InstructionViewModel()
   
    
    var body: some View {
        VStack {
            NavigationLink(destination: CamView().navigationBarHidden(true), tag: "Camera", selection: $viewModel.selection) { EmptyView() }
            Text("Anweisungen").titleStyle()
            GeometryReader { geometry in
                VStack {
                    CardViewList(proxy: geometry, viewModel: viewModel)
                    Spacer()
                    Indicators(viewModel: viewModel)
                    Button((viewModel.step >= viewModel.totalInstructions - 1) ? String.go : String.next) {
                        viewModel.startCamera(proxy: geometry)
                    }.buttonStyle(CustomButtonStyle())
                }
            }.padding(.top, 28)
        }
        .environmentObject(status)
        .environmentObject(polarApi)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $viewModel.alert, content: {
            Alert(title: Text(String.connection), message: Text(String.connectionMessage))
        })
        .onAppear {
            viewModel.setup(status: self.status, polarApi: self.polarApi)
        }
    }
    
    
}


struct CardViewList: View {
    var instr = [String.exerciseInstr1, String.exerciseInstr11 , String.exerciseInstr2, String.exerciseInstr3, String.exerciseInstr4]

    var proxy: GeometryProxy
    @StateObject var viewModel: InstructionViewModel
   
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: spacing) {
                CardView(image: "pushUp", instruction: String.startInstr)
                    .frame(width: proxy.size.width).frame(height: 300)
                ExerciseCardView(image: "pushUpKnee", instruction: String.exerciseInstr, exerciseInst: instr).frame(width: proxy.size.width).frame(height: 300)
                SensorCardView(image: "pulsgurt", instruction: String.polarDeviceIntr)
                    .frame(width: proxy.size.width).frame(height: 300)
                ConnectingCardView(instruction: String.connectInstr).frame(width: proxy.size.width).frame(height: 300)
                PositionCardView(image: "position2")
                    .frame(width: proxy.size.width).frame(height: 300)
            }
        }
        .content.offset(x: viewModel.offset)
        .frame(width: proxy.size.width, alignment: .leading)
        .gesture(
            DragGesture()
                .onChanged({ value in
                    if abs(value.translation.width) > 50 {
                        viewModel.offset = value.translation.width - proxy.size.width * CGFloat(viewModel.step)
                    }
                })
                .onEnded({ value in
                    if -value.predictedEndTranslation.width > proxy.size.width / 2, viewModel.step < viewModel.totalInstructions - 1 {
                        viewModel.step += 1
                    }
                    if value.predictedEndTranslation.width > proxy.size.width / 2, viewModel.step > 0 {
                        viewModel.step -= 1
                    }
                    withAnimation { viewModel.offset = -(proxy.size.width + spacing) * CGFloat(viewModel.step) }
                })
        )
    }
}

struct Indicators: View {
    @StateObject var viewModel: InstructionViewModel
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< viewModel.totalInstructions) { position in
                Image(systemName: position == viewModel.step ? "circle.fill" : "circle")
                    .scaleEffect(position == viewModel.step ? 1 : 0.65)
                    .foregroundColor(.darkgreen)
            }
        }
    }
}


struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView().environmentObject(GlobalState())
    }
}
