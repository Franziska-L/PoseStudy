//
//  InstructionViewModel.swift
//  PoseStudy
//
//  Created by Franziska Lang on 17.10.21.
//

import SwiftUI

final class InstructionViewModel: ObservableObject {
    var status: GlobalState?
    var polarApi: PolarApiWrapper?
      
    func setup(status: GlobalState, polarApi: PolarApiWrapper) {
        self.status = status
        self.polarApi = polarApi
    }
    
    @Published var selection: String? = nil
    @Published var alert = false

    @Published var step = 0
    @Published var offset: CGFloat = 0
    
    let totalInstructions = 5

    
    func startCamera(proxy: GeometryProxy) {
        if polarApi?.connectionState == .connected && (step >= totalInstructions - 1) && (polarApi?.isECGReady() ?? false) {
            selection = "Camera"
        }
        if (step >= totalInstructions - 1) && !(polarApi?.isECGReady() ?? false) {
            alert = true
        } else {
            step += 1
            withAnimation { offset = -(CGFloat(proxy.size.width) + spacing) * CGFloat( step) }
        }
    }
    
    
}
