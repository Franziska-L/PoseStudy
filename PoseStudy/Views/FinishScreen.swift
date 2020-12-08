//
//  FinishScreen.swift
//  PoseStudy
//
//  Created by Franziska Lang on 07.12.20.
//

import SwiftUI

struct FinishScreen: View {
    var body: some View {
        VStack {
            Text("Geschafft!").titleStyle().padding(.bottom, 50)
            Image("done").resizable().scaledToFit()
            Text("Danke für deine Teilnahme!").titleStyle()
        }
    }
}

struct FinishScreen_Previews: PreviewProvider {
    static var previews: some View {
        FinishScreen()
    }
}
