//
//  Test.swift
//  PoseStudy
//
//  Created by Franziska Lang on 07.12.20.
//

import SwiftUI

struct Test: View {
    @State private var selection: String? = nil
    @State var code: String = ""
    
    var body: some View {
        NavigationView {
                    VStack {
                        NavigationLink(destination: WelcomeView(), tag: "Second", selection: $selection) { EmptyView() }
                        NavigationLink(destination: FinishScreen(), tag: "Third", selection: $selection) { EmptyView() }
                        TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: $code)
                        Button("Tap to show second") {
                            change()
                        }
                        Button("Tap to show third") {
                            self.selection = "Third"
                        }
                    }
                    .navigationBarTitle("Navigation")
                }
    }
    
    func change() {
        if code == "" {
            selection = "Second"
        } else {
            selection = "Third"
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
