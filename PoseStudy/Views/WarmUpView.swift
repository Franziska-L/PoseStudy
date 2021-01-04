//
//  WarmUpView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct WarmUpView: View {
    @EnvironmentObject var status: GlobalState
    @EnvironmentObject var polarApi: PolarApiWrapper
    
    var body: some View {
            VStack {
                Text("Aufwärmen").titleStyle()
                Spacer()
                Text(String.warmup).padding()
                Image("jumpingjack")
                Text("30 Hampelmänner").padding()
                Spacer()
                Text("Wenn du fertig bist kanns los gehen.")
                NavigationLink(
                    destination: InstructionView().navigationBarHidden(true),
                    label: {
                        Text(String.next)
                    }).buttonStyle(CustomButtonStyle())
            
            }.environmentObject(status).environmentObject(polarApi)
            .navigationBarBackButtonHidden(true).navigationBarHidden(true)
    }
}

struct WarmUpView_Previews: PreviewProvider {
    static var previews: some View {
        WarmUpView()
    }
}
