//
//  WarmUpView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct WarmUpView: View {
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Text("Aufwärmen").titleStyle()
                    Image("jumpingjack")
                    Text("Wärme dich kurz auf, bevor du mit den Übungen beginnst:")
                    Text("Mache 30 Hampelmänner")
                    Text("Wenn du fertig bist kanns los gehen.")
                    Spacer()
                    NavigationLink(
                        destination: InstructionView().navigationBarHidden(true),
                        label: {
                            Text("Weiter")
                            
                        }).buttonStyle(CustomButtonStyle())
                }
            }
        }
    }
}

struct WarmUpView_Previews: PreviewProvider {
    static var previews: some View {
        WarmUpView()
    }
}
