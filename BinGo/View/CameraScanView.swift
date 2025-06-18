//
//  CameraScanView.swift
//  BinGo
//
//  Created by sam on 14/06/25.
//

import SwiftUI
import AVFoundation

/// Main camera scanning view
struct CameraScanView: View {
    @StateObject private var viewModel = CameraScanViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera View
                CameraPreview(previewLayer: viewModel.previewLayer)
                    .ignoresSafeArea()
                
                // Blur overlay with cutout for scanning area
                BlurOverlayView(geometry: geometry)
                
                // Instruction text
                InstructionView()
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                }
                
                // Popup overlay
                if viewModel.showPopup, let item = viewModel.detectedItem {
                    PopupOverlayView(detectedItem: item, onDismiss: viewModel.dismissPopup)
                }
            }
        }
        .onAppear {
            viewModel.startCameraSession()
        }
        .onDisappear {
            viewModel.stopCameraSession()
        }
    }
}

/// Camera preview UIViewRepresentable
struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let containerView = CameraPreviewView()
        containerView.backgroundColor = .black
        return containerView
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        uiView.setPreviewLayer(previewLayer)
    }
}

/// Custom UIView to handle camera preview layer
class CameraPreviewView: UIView {
    private var currentPreviewLayer: AVCaptureVideoPreviewLayer?
    
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        // Remove existing layer
        currentPreviewLayer?.removeFromSuperlayer()
        currentPreviewLayer = nil
        
        guard let previewLayer = previewLayer else { return }
        
        // Add new layer
        previewLayer.frame = bounds
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        currentPreviewLayer = previewLayer
        
        // Update frame immediately
        updatePreviewLayerFrame()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePreviewLayerFrame()
    }
    
    private func updatePreviewLayerFrame() {
        guard let previewLayer = currentPreviewLayer else { return }
        
        // Ensure the preview layer fills the entire view
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer.frame = bounds
        CATransaction.commit()
    }
}

/// Blur overlay with cutout for scanning area
struct BlurOverlayView: View {
    let geometry: GeometryProxy
    
    var body: some View {
        let frameSize: CGFloat = 480
        
        
        ZStack {
            
            // Dark overlay outside the frame
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            // Clear the center area (360x360)
            RoundedRectangle(cornerRadius: 12)
                .frame(width: frameSize, height: frameSize)
                .blendMode(.destinationOut)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 3)
                .frame(width: frameSize, height: frameSize)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            Text("Please use rear camera to scan!")
                .font(.headline)
                .foregroundColor(.white)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 10)
        }
        .compositingGroup()
    }
}

#Preview {
    CameraScanView()
}
