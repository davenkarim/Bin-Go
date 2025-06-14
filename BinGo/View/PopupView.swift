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
        VStack(spacing: 0) {
            // Header with detected item info
            PopupHeaderView(detectedItem: detectedItem)
            
            // Countdown
            PopupCountdownView(countdown: viewModel.countdown)
            
            // Characters
            PopupCharactersView()
        }
        .frame(width: 500, height: 350)
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
}

/// Popup header component
struct PopupHeaderView: View {
    let detectedItem: DetectedTrash
    
    var body: some View {
        VStack(spacing: 15) {
            Text("it's a")
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
    
    var body: some View {
        HStack {
            Text("This pop up will be closed in")
                .foregroundColor(.secondary)
            
            Text("\(countdown)")
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding(.bottom, 30)
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
