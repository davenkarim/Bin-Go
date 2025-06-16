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
        // Fixed size 360x360 square at center
        let frameSize: CGFloat = 360
        
        ZStack {
            // White border frame
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 3)
                .frame(width: frameSize, height: frameSize)
            
        }
        .frame(width: frameSize, height: frameSize)
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
}
