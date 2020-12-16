//
//  CardView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 02.12.20.
//

import SwiftUI

struct CardView: View {
    var image: String
    var instruction: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                    .clipped()
                Text(instruction)
                    .padding()
                    .lineLimit(nil)
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

struct ConnectingCardView: View {
    var instruction: String
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(instruction)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .center) {
                    if polarApi.connetionState == .connected {
                        Text("Erfolgreich Verbunden").foregroundColor(.darkgreen)
                    }
                    if polarApi.connetionState == .connecting {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    }
                    if polarApi.connetionState == .disconnected {
                        Button(action: connectToDevice, label: {
                            Text("Verbinden")
                        }).buttonStyle(CustomButtonStyle()).padding(.horizontal, 40)
                    }
                }
                
               
            }
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
    
    func connectToDevice() {
        polarApi.autoConnectToDevice()
    }
}

struct ExerciseCardView: View {
    var image: String
    var instruction: String
    var exerciseInst: [String]

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                
                Text(instruction)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(0..<exerciseInst.count) { position in
                    Text("\(exerciseInst[position])")
                        .padding(.top, 10).padding(.horizontal, 10)
                        .lineLimit(nil)
                        .foregroundColor(.darkgray)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}
