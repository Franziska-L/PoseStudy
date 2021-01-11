//
//  CardView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 02.12.20.
//

import SwiftUI
import PolarBleSdk
import CoreBluetooth

struct CardView: View {
    var image: String
    var instruction: String
    
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    
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
    
    @State var alert = false
    @State var alertConnection = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(instruction)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .center) {
                    if polarApi.connectionState == .connected && polarApi.streamReady {
                        Text("Erfolgreich Verbunden").foregroundColor(.darkgreen)
                    }
                    if polarApi.connectionState == .connecting || (polarApi.connectionState == .connected && !polarApi.streamReady) {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    }
                    if polarApi.connectionState == .disconnected || polarApi.connectionState == .unknown {
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
        }.alert(isPresented: $alert, content: {
            Alert(title: Text("Bluetooth Status"), message: Text("Bitte schalte Bluetooth ein um fortzufahren."))
        })
        .alert(isPresented: $alert, content: {
            Alert(title: Text("Etwas ist schief gelaufen."), message: Text("Bitte stelle sicher, dass du den Brustgurt richtig angelegt hast. Befeuchte ggf. den Elektrodenbereich erneut und lege ihn fest um die Brust."))
        })
    }
    
    func connectToDevice() {
        if polarApi.bleState == .poweredOn {
            polarApi.autoConnectToDevice()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                if polarApi.connectionState != .connected || !polarApi.streamReady {
                    polarApi.connectionState = .unknown
                    alertConnection = true
                }
            }
        } else if polarApi.bleState == .poweredOff {
            alert = true
        }
    }
}

struct ExerciseCardView: View {
    var image: String
    var instruction: String
    var exerciseInst: [String]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
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
                    Image("pushUp").resizable().scaledToFit().padding()
                    Image("pushUpKnee").resizable().scaledToFit().padding()
                }
                .padding(.bottom)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
    }
}
