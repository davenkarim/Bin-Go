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
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.6, dampingFraction: 0.8))
    }
}

struct TrashDetectionPopup: View {
    let detectedItem: DetectedTrash
    @StateObject private var viewModel = PopupViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content with shadow
            ZStack {
                mainContent
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                
                // characters
                characterRow
                    .offset(y: 250)
                
            }.padding(.bottom,140)
        }
        .frame(width: 750, height: 480)
        .offset(x:-40)
        .onAppear { viewModel.startCountdown() }
        .onDisappear { viewModel.stopCountdown() }
    }
    
    private var mainContent: some View {
        HStack(spacing: 35) {
            // Image section
            if let capturedImage = detectedItem.capturedImage {
                imageSection(image: capturedImage)
                    .padding(.top, 70)
                    .padding(.leading, -50)
                    .rotationEffect(.degrees(-5))
                
            }
            
            // Info section
            infoSection
                .padding(.trailing, 30)
                .padding(.top, 80)
        }
        .frame(width: 600, height: 600)
    }
    
    private func imageSection(image: UIImage) -> some View {
        VStack (alignment: .leading, spacing: 20) {
            // Main image
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 240, height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("lightGreen"), lineWidth: 8)
                    )
                
                // Sparkle effect
                Image(systemName: "sparkle")
                    .foregroundColor(.white)
                    .font(.system(size: 50))
                    .padding(8)
                    .offset(x: -120, y: -120)
            }
            Spacer()
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Countdown timer
            HStack {
                Spacer()
                PopupCountdownView(countdown: viewModel.countdown)
                    .padding(.trailing, 5)
            }
            .padding(.top, -80)
            
            // Header text
            VStack(alignment: .leading, spacing: 10) {
                Text("We think it's a")
                    .font(.system(size: 25))
                    .foregroundColor(.gray)
                
                Text(detectedItem.name)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundColor(Color("darkGreen"))
                
                HStack {
                    Text("and it's")
                        .font(.system(size: 25))
                        .foregroundColor(Color(.gray))
                    
                    Text("\(detectedItem.category)")
                        .font(.system(size: 25))
                        .foregroundColor(Color("normalGreen"))
                        .underline()
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
        }
        .padding(.vertical, 30)
        
    }
    
    private var characterRow: some View {
        HStack (spacing: 0) {
            Image("bingo_character_left")
                .resizable()
                .frame(width: 600, height: 600)
                .padding(.trailing, -100)
                .padding(.leading, 10)
            
            Image("bingo_character_middle")
                .resizable()
                .frame(width: 480, height: 350)
            
            Image("bingo_character_right")
                .resizable()
                .frame(width: 600, height: 600)
                .padding(.leading, -80)
        }
    }
}

struct PopupCountdownView: View {
    let countdown: Int
    private let totalDuration = 5
    
    var body: some View {
        ZStack {
            // Static background circle
            Circle()
                .fill(Color.white)
                .frame(width: 60, height: 60)
            
            // Animated decreasing fill (starts from top)
            SmoothPieShape(progress: progressValue)
                .fill(Color("darkGreen"))
                .frame(width: 60, height: 60)
                .animation(
                    .timingCurve(0.25, 0.1, 0.25, 1, duration: 1.0),
                    value: countdown
                )
                .overlay(
                    Circle()
                        .stroke(Color("darkGreen"), lineWidth: 3)
                        .frame(width: 70, height: 70)
                )
        }
    }
    
    private var progressValue: CGFloat {
        CGFloat(countdown) / CGFloat(totalDuration)
    }
}

struct SmoothPieShape: Shape {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Start from top (-90 degrees)
        let startAngle = Angle(degrees: -90)
        let endAngle = Angle(degrees: -90 + (360 * Double(progress)))
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItem = DetectedTrash(
            name: "Cardboard",
            category: "Recyclable",
            confidence: 0.95,
            capturedImage: UIImage(systemName: "photo")!
        )
        
        TrashDetectionPopup(detectedItem: sampleItem)
            .previewDevice("iPad Pro (11-inch) (4th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

