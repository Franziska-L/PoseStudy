//
//  PauseView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 02.12.20.
//

import SwiftUI

struct PauseView: View {
    
    @State var didPause = false
    
    var body: some View {
        VStack {
            Text("Pause").titleStyle()
            Spacer()
            Image("brake")
            Text("Mache mind. 5 Minuten Pause bevor du mit der zweiten Runde beginnst").padding()
            Spacer()
            Text("Ausgeruht? Dann starte in die 2. Runde")
            NavigationLink(
                destination: InstructionView().navigationBarHidden(true),
                label: {
                    Text("Los")
                    
                }).buttonStyle(CustomButtonStyle())
        
        }
    }
}

struct PauseView_Previews: PreviewProvider {
    static var previews: some View {
        PauseView()
    }
}
