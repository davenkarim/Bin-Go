//
//  ScanningFrameView.swift
//  BinGo
//
//  Created by sam on 14/06/25.
//

import SwiftUI

struct ScanningFrameView: View {
    let geometry: GeometryProxy
    
    var body: some View {
        let isLandscape = geometry.size.width > geometry.size.height
        let scanningWidth = isLandscape ? geometry.size.width * 0.4 : geometry.size.width * 0.6
        let scanningHeight = isLandscape ? geometry.size.height * 0.8 : geometry.size.height * 0.7
        
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white, lineWidth: 3)
            .frame(width: scanningWidth, height: scanningHeight)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.clear)
            )
    }
}
