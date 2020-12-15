//
//  WarmUpView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct WarmUpView: View {
    @EnvironmentObject var status: GlobalState
    
    var body: some View {
            VStack {
                Text("Aufwärmen").titleStyle()
                Spacer()
                Text("Wärme dich kurz auf, bevor du mit den Übungen beginnst")
                Image("jumpingjack")
                Text("30 Hampelmänner").padding()
                Spacer()
                Text("Wenn du fertig bist kanns los gehen.")
                NavigationLink(
                    destination: InstructionView().navigationBarHidden(true),
                    label: {
                        Text("Weiter")
                    }).buttonStyle(CustomButtonStyle())
            
            }.environmentObject(status)
            .navigationBarBackButtonHidden(true)
    }
}

struct WarmUpView_Previews: PreviewProvider {
    static var previews: some View {
        WarmUpView()
    }
}
