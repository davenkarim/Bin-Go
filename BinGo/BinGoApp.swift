//
//  BinGoApp.swift
//  BinGo
//
//  Created by Daven Karim on 12/06/25.
//

import SwiftUI

@main
struct BinGoApp: App {
    var body: some Scene {
        WindowGroup {
            CameraScanView()
                .preferredColorScheme(.light)
                .onAppear {
                    // Force landscape orientation
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
        }
    }
}
