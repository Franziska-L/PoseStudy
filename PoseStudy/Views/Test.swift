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
    
    var body: some View {
        NavigationView {
                    VStack {
                        NavigationLink(destination: SubView(), tag: "Second", selection: $selection) { EmptyView() }
                        NavigationLink(destination: SubViewTwo(), tag: "Third", selection: $selection) { EmptyView() }
                        TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: $code)
                        Text(status.currentTopic)
                        Button("Tap to show second") {
                            change()
                        }
                        Button("Tap to show third") {
                            self.selection = "Third"
                        }
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

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
