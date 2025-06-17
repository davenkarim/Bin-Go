//
//  PopupView.swift
//  BinGo
//
//  Created by sam on 14/06/25.
//

import SwiftUI

struct PopupOverlayView: View {
    let detectedItem: DetectedTrash
    let onDismiss: () -> Void
    
    var body: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
                onDismiss()
            }
        
        TrashDetectionPopup(detectedItem: detectedItem)
            .transition(.scale.combined(with: .opacity)
            .animation(.spring(response: 0.6, dampingFraction: 0.8)))
    }
}

/// Trash detection popup view
struct TrashDetectionPopup: View {
    let detectedItem: DetectedTrash
    @StateObject private var viewModel = PopupViewModel()
    
    var body: some View {
        
        HStack(spacing:20) {
            // Captured image display
            if let capturedImage = detectedItem.capturedImage {
                PopupImageView(image: capturedImage)
            }
            VStack(spacing: 0) {
                // Header with detected item info
                PopupHeaderView(detectedItem: detectedItem)
                
                
                
                // Countdown
                PopupCountdownView(countdown: viewModel.countdown)
                
                // Characters
                PopupCharactersView()
            }
            
        }.frame(width: 750, height: 480)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 20)
            )
        
        .onAppear {
            viewModel.startCountdown()
        }
        .onDisappear {
            viewModel.stopCountdown()
        }
    }
    
    private var capturedImage: UIImage? {
        detectedItem.capturedImage
    }
}

/// Popup image display component
struct PopupImageView: View {
    let image: UIImage
    
    var body: some View {
        VStack {
            // Image with green border frame
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 240, height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 3)
                )
                .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.bottom, 15)
    }
}

/// Popup header component
struct PopupHeaderView: View {
    let detectedItem: DetectedTrash
    
    var body: some View {
        VStack(spacing: 15) {
            Text("We think this might be a")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("\(detectedItem.name)!")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.green)
            
            Text("and it's \(detectedItem.category)")
                .font(.title2)
                .foregroundColor(.green)
                .underline()
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
    }
}

/// Popup countdown component
struct PopupCountdownView: View {
    let countdown: Int
    private let totalDuration = 5
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
            
            // Smooth pie fill
            SmoothPieShape(progress: progressValue)
                .fill(fillColor)
                .frame(width: 50, height: 50)
                .animation(
                    .timingCurve(0.25, 0.1, 0.25, 1, duration: 1.0),
                    value: countdown
                )
        }
        .padding(.bottom, 15)
    }
    
    private var progressValue: Double {
        Double(totalDuration - countdown) / Double(totalDuration)
    }
    
    private var fillColor: Color {
        let progress = progressValue
        if progress > 0.7 { return .red }
        if progress > 0.4 { return .orange }
        return .green
    }
}

struct SmoothPieShape: Shape {
    var progress: Double // 0.0 - 1.0
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let startAngle = Angle(degrees: -90) // Mulai dari tengah atas (12 jam)
            let endAngle = Angle(degrees: -90 + 360 * progress)
            
            path.move(to: center)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            path.closeSubpath()
        }
    }
}
               

/// Popup characters component
struct PopupCharactersView: View {
    var body: some View {
        HStack(spacing: 30) {
            Image("bingo_character_left")
                .resizable()
                .frame(width: 60, height: 60)
            
            Image("bingo_character_middle")
                .resizable()
                .frame(width: 60, height: 60)
            
            Image("bingo_character_right")
                .resizable()
                .frame(width: 60, height: 60)
        }
        .padding(.bottom, 20)
    }
}
