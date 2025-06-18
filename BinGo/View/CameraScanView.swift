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
                
                // Instruction text - animate out when popup shows
                InstructionView()
                    .opacity(viewModel.showPopup ? 0 : 1)
                    .offset(y: viewModel.showPopup ? -50 : 0)
                    .animation(.easeOut(duration: 0.3), value: viewModel.showPopup)
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                }
                
                // Popup overlay
                if viewModel.showPopup, let item = viewModel.detectedItem {
                    PopupOverlayView(detectedItem: item, onDismiss: viewModel.dismissPopup)
                        .zIndex(1)
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
    let frameSize: CGFloat = 480

    var body: some View {
        ZStack {
            // Linear gradient overlay with blur, masked to carve out center
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.black.opacity(0.3), location: 0.0),
                    .init(color: Color.black.opacity(0.5), location: 0.6),
                    .init(color: Color.black.opacity(0.8), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                    .opacity(0.5)
            )
            .mask(
                Rectangle()
                    .overlay(
                        // Transparent cutout in the center
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: frameSize, height: frameSize)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .blendMode(.destinationOut)
                    )
                    .compositingGroup()
            )
            .ignoresSafeArea()

            // Green corner guide
            CornerGuideView()
                .stroke(Color("lightGreen"), lineWidth: 6)
                .frame(width: frameSize, height: frameSize)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .offset(y: -25)

            // Instruction
            Text("Please use rear camera to scan!")
                .font(.headline)
                .foregroundColor(.white)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 10)
        }
    }
}

struct CornerGuideView: Shape {
    var cornerLength: CGFloat = 135
    var cornerRadius: CGFloat = 12
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        // Top-left corner
        path.move(to: CGPoint(x: topLeft.x + cornerLength, y: topLeft.y))
        path.addLine(to: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y))
        path.addArc(center: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-180),
                    clockwise: true)
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + cornerLength))
        
        // Top-right corner
        path.move(to: CGPoint(x: topRight.x - cornerLength, y: topRight.y))
        path.addLine(to: CGPoint(x: topRight.x - cornerRadius, y: topRight.y))
        path.addArc(center: CGPoint(x: topRight.x - cornerRadius, y: topRight.y + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: topRight.x, y: topRight.y + cornerLength))
        
        // Bottom-right corner
        path.move(to: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerLength))
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerRadius))
        path.addArc(center: CGPoint(x: bottomRight.x - cornerRadius, y: bottomRight.y - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: bottomRight.x - cornerLength, y: bottomRight.y))
        
        // Bottom-left corner
        path.move(to: CGPoint(x: bottomLeft.x + cornerLength, y: bottomLeft.y))
        path.addLine(to: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomLeft.y))
        path.addArc(center: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomLeft.y - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - cornerLength))
        
        return path
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}


#Preview {
    CameraScanView()
}
