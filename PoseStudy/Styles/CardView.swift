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
                VStack {
                    Text("Als nächstes wirst du Liegestützen machen bis zur") + Text(" maximalen Belastung").bold().font(.system(size: 18)) + Text(". Nimm auch die Wiederholung mit, die du nicht mehr sauber ausführen kannst. \n\nWische nach links, um die nächste Anweisung zu lesen oder klicke auf den Weiter Button.")
                }
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


struct SensorCardView: View {
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
                VStack {
                    Text("Lege jetzt den Brustgurt wie folgt an. Befeuchte zunächst den ") + Text("Elektrodenbereich des Gurtes").bold().font(.system(size: 18)) + Text(". Lege den Gurt so um die Brust, dass er unter dem Brustmuskel sitzt und das Polar Logo") + Text(" mittig zur Brust").bold().font(.system(size: 18)) + Text(" ausgerichtet ist.\n\nStelle die Gurtlänge so ein, dass der Brustgurt fest, aber nicht zu eng sitzt.")
                }
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


struct PositionCardView: View {
    var image: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                    .clipped()
                VStack {
                    Text("Stelle das Handy") + Text(" quer").bold().font(.system(size: 18)) + Text(" auf die Handyhalterung. Positioniere die Handyhalterung in ca. 1,5 m bis 2 m Abstand") + Text(" längs zu deinem Körper").bold().font(.system(size: 18)) + Text(", sodass dein gesamter Körper seitlich zu sehen ist (inklusive Arme und Beine)!\n\nWenn alles bereit ist kann es los gehen.")
                }
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
                if polarApi.bleState == .poweredOff && polarApi.searchDone {
                    Text("Bluetooth ist ausgeschaltet. Bitte schalte zunächst Bluetooth ein um fortzufahren.")
                } else if polarApi.connectionState == .notAvailable && polarApi.searchDone {
                    Text("Die Verbindung zum Puls-Sensor konnte nicht hergestellt werden. Stelle sicher, dass du den Elektrodenbereich des Brustgurtes befeuchtet hast und der Brustgurt fest am Körper anliegt.")
                }
                
               
            }
            .alert(isPresented: $alert, content: {
                Alert(title: Text("Bluetooth Status"), message: Text("Bitte schalte Bluetooth ein um fortzufahren."))
            })
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(width: geometry.size.width)
        }
    }
    
    func connectToDevice() {
        print(polarApi.bleState)
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
