//
//  CameraScanViewModel.swift
//  BinGo
//
//  Created by sam on 14/06/25.
//

import Foundation
import SwiftUI
import AVFoundation
import Vision
import CoreML
import Combine

/// ViewModel for camera scanning functionality
class CameraScanViewModel: NSObject, ObservableObject {
    // Published properties for UI binding
    @Published var showPopup = false
    @Published var detectedItem: DetectedTrash?
    @Published var isSessionRunning = false
    @Published var errorMessage: String?
    
    // Camera management
    private let cameraManager = CameraManager()
    private var cancellables = Set<AnyCancellable>()
    private var popupTimer: Timer?
    
    override init() {
        super.init()
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind camera manager's detected trash to our published property
        cameraManager.$detectedTrash
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                self?.handleDetectedTrash(item)
            }
            .store(in: &cancellables)
        
        cameraManager.$isSessionRunning
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSessionRunning, on: self)
            .store(in: &cancellables)
        
        cameraManager.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    private func handleDetectedTrash(_ item: DetectedTrash?) {
        guard let item = item,
              !showPopup,
              item.name.lowercased() != "background" else { return }
        
        // Pause scanning when popup appears
        cameraManager.pauseScanning()
        
        detectedItem = item
        showPopup = true
        
        // Auto-hide popup after 5 seconds
        popupTimer?.invalidate()
        popupTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            withAnimation(.easeOut(duration: 0.3)) {
                self?.hidePopupAndResumeScanning()
            }
        }
    }
    
    private func hidePopupAndResumeScanning() {
        showPopup = false
        // Resume scanning with 5-second timer reset
        cameraManager.resumeScanning()
    }
    
    func startCameraSession() {
        cameraManager.startSession()
    }
    
    func stopCameraSession() {
        cameraManager.stopSession()
        popupTimer?.invalidate()
    }
    
    func dismissPopup() {
        withAnimation(.easeOut(duration: 0.3)) {
            hidePopupAndResumeScanning()
        }
        popupTimer?.invalidate()
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        cameraManager.previewLayer
    }
    
    deinit {
        popupTimer?.invalidate()
        cancellables.removeAll()
    }
}
