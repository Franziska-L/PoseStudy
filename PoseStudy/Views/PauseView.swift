//
//  PauseView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 02.12.20.
//

import SwiftUI

struct PauseView: View {
    @State private var selection: String? = nil
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    
    var body: some View {
        VStack {
            NavigationLink(destination: InstructionView().navigationBarHidden(true), tag: "next", selection: $selection) { EmptyView() }
            Text("Pause").titleStyle()
            Spacer()
            Image("brake")
            Text("Mache mind. 5 Minuten Pause bevor du mit der zweiten Runde beginnst").padding()
            Spacer()
            Text("Ausgeruht? Dann starte in die 2. Runde")
            Button(action: {
                setState()
            }) {
                Text("Los")
            }.buttonStyle(CustomButtonStyle())
        }.environmentObject(status).environmentObject(polarApi)
    }
    
    fileprivate func setState() {
        self.status.isSecondRun = "second"
        self.selection = "next"
    }
}

struct PauseView_Previews: PreviewProvider {
    static var previews: some View {
        PauseView()
    }
}
