//
//  StateModel.swift
//  PoseStudy
//
//  Created by Franziska Lang on 17.10.21.
//

import Foundation

final class GlobalState: ObservableObject {
    @Published var session: Int = 1
    @Published var participantID: String = ""
    @Published var day: Int = 0
    @Published var userData = UserData()
}
