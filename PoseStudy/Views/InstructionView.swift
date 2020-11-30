//
//  InstructionView.swift
//  PoseStudy
//
//  Created by Franziska Lang on 25.11.20.
//

import SwiftUI

struct InstructionView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                Text("Stelle Hände unter die Scultern")
                Text("Achte auf eine Körperspannung in der Mitte")
                Text("Achte auf eine Körperspannung im Rumpf")
                Text("Achte auf eine gerade Linie, ziehe Kopf und Schultern nach hinten")
                NavigationLink(
                    destination: CameraView().navigationBarHidden(true),
                    label: {
                        Text("Go")
                        
                    }).buttonStyle(CustomButtonStyle())
            }
        }
    }
}

struct InstructionView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionView()
    }
}