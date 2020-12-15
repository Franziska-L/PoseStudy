//
//  Test.swift
//  PoseStudy
//
//  Created by Franziska Lang on 07.12.20.
//

import SwiftUI

class GlobalState2 : ObservableObject {
    @Published var currentTopic: String = "Ho ho"
}



struct Test: View {
    @State private var selection: String? = nil
    @State var code: String = ""
    
    @ObservedObject var status = GlobalState2()
    
    @State var img = "jumpingjack"
    @State var title = "Test"
    @State var instr = ["Hebe und senke deinen Körper mit den Armen bis zum Boden.", "Halte dabei den Rücken gerade und den Kopf in Verlängerung der Wirbelsäule.", "Körpermitte ist fest." ,"Wenn die Übung auf den Beinen zu anstrengend ist, gehe gerne auf die Knie."]
    var body: some View {
        NavigationView {
                    VStack {
                        ConnectingCardView2(instruction: $title).frame(width: 300, height: 300, alignment: .center)
                    }
                    .navigationBarTitle("Navigation")
                }.environmentObject(status)
    }
    
    func change() {
        if code == "" {
            selection = "Second"
        } else {
            selection = "Third"
        }
    }
}

struct ConnectingCardView2: View {
    @Binding var instruction: String
    @State var connectionState: ConnectionState = .disconnected
    //var api = PolarApiWrapper()
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text(instruction)
                    .padding()
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                if connectionState == .connected {
                    
                }
                Button(action: { print("start connecting") }, label: {
                    Text("Verbinden")
                }).buttonStyle(CustomButtonStyle()).padding(.horizontal, 60)
            }
            .padding(.bottom)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
    
    
}


struct SubView: View {
    @EnvironmentObject var state: GlobalState2
    
    var body: some View {
        VStack {
            Text("\(self.state.currentTopic)")
        }
    }
}

struct SubViewTwo: View {
    @EnvironmentObject var state: GlobalState2
    var body: some View {
        VStack {
            NavigationLink(
                destination: SubViewThree(),
                label: {
                    /*@START_MENU_TOKEN@*/Text("Navigate")/*@END_MENU_TOKEN@*/
                })
            Text(state.currentTopic)
        }.environmentObject(state)
       
    }
}

struct SubViewThree: View {
    @EnvironmentObject var state: GlobalState2
    
    var body: some View {
        VStack {
            NavigationLink(
                destination: SubViewTwo(),
                label: {
                    Button(action: {self.state.currentTopic = "new topic" }) {
                        Text("Go back")
                    }
                })
            Button(action: {self.state.currentTopic = "new topic" }) {
                Text("Change state")
            }
        }
    }
}


struct ExerciseCardView1: View {
    @Binding var image: String
    @Binding var instruction: String
    @Binding var exerciseInst: [String]

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
                ForEach(0..<exerciseInst.count) { position in
                    Text("\(exerciseInst[position])")
                        .padding(.top, 10).padding(.leading, 10)
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

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
