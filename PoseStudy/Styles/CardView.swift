//
//  CardView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 02.12.20.
//

import SwiftUI
import PolarBleSdk

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
    
    @State var alert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(instruction)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .center) {
                    if polarApi.connectionState == .disconnected || polarApi.connectionState == .unknown || polarApi.connectionState == .notAvailable {
                        Button(action: connectToDevice, label: {
                            Text("Verbinden")
                        }).buttonStyle(CustomButtonStyle()).padding(.horizontal, 40)
                    }
                    if polarApi.connectionState == .connected && polarApi.streamReady {
                        Text("Erfolgreich Verbunden").foregroundColor(.darkgreen)
                    }
                    if polarApi.connectionState == .connecting || (polarApi.connectionState == .connected && !polarApi.streamReady) || !polarApi.searchDone {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    }
                }
                if polarApi.connectionState == .notAvailable && polarApi.searchDone {
                    Text("Die Verbindung zum Puls-Sensor konnte nicht hergestellt werden. Stelle sicher, dass du den Elektrodenbereich des Brustgurtes befeuchtet hast und der Brustgurt fest am Körper anliegt.")
                }
                
               
            }
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }.alert(isPresented: $alert, content: {
            Alert(title: Text("Bluetooth Status"), message: Text("Bitte schalte Bluetooth ein um fortzufahren."))
        })
    }
    
    func connectToDevice() {
        if polarApi.bleState == .poweredOn {
            polarApi.searchForDevice()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                if polarApi.connectionState != .connected || !polarApi.streamReady {
                    polarApi.connectionState = .notAvailable
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
                    Text(String.exerciseIntr0)
                        .padding()
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Image("push-up").resizable().scaledToFit().padding()
                    ForEach(0..<exerciseInst.count) { position in
                        Text("\(exerciseInst[position])")
                            .padding(.top, 10).padding(.horizontal, 10)
                            .lineLimit(nil)
                            .foregroundColor(.darkgray)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Image("push-up-knee").resizable().scaledToFit().padding()
                }
            }
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}
