//
//  CameraManager.swift
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

/// Camera management class (part of the data layer)
class CameraManager: NSObject, ObservableObject {
    @Published var detectedTrash: DetectedTrash?
    @Published var isSessionRunning = false
    @Published var errorMessage: String?
    
    private var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var model: VNCoreMLModel?
    private var lastScanTime = Date(timeIntervalSince1970: 0)
    private let scanInterval: TimeInterval = 2.0
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var isScanningPaused=false
    
    override init() {
        super.init()
        setupModel()
        setupOrientationObserver()
    }
    
    private func setupModel() {
        guard let coreMLModel = try? VNCoreMLModel(for: TrashClassifierDavenTerbaru().model) else {
            print("Failed to load CoreML model")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load CoreML model"
            }
            return
        }
        self.model = coreMLModel
        print("CoreML model loaded successfully")
    }
    
    private func setupOrientationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func orientationDidChange() {
        DispatchQueue.main.async {
            self.updatePreviewOrientation()
        }
    }
    
    private func updatePreviewOrientation() {
        guard let previewLayer = previewLayer else { return }
        
        let orientation = UIDevice.current.orientation
        var videoOrientation: AVCaptureVideoOrientation = .landscapeLeft
        
        switch orientation {
//        case .portrait:
//            videoOrientation = .portrait
//        case .portraitUpsideDown:
//            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        default:
            videoOrientation = .landscapeLeft
        }
        
        if previewLayer.connection?.isVideoOrientationSupported == true {
            previewLayer.connection?.videoOrientation = videoOrientation
        }
        
        // Also update the video data output connection
        if let videoConnection = videoDataOutput?.connection(with: .video),
           videoConnection.isVideoOrientationSupported {
            videoConnection.videoOrientation = videoOrientation
        }
    }
    
    func startSession() {
        guard captureSession == nil else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let session = AVCaptureSession()
            session.sessionPreset = .hd1920x1080
            
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else {
                print("Failed to setup camera input")
                return
            }
            
            session.addInput(input)
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            guard session.canAddOutput(output) else {
                print("Failed to add camera output")
                return
            }
            
            session.addOutput(output)
            self.videoDataOutput = output
            
            // Configure previewLayer on the main thread
            DispatchQueue.main.async {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                self.previewLayer = previewLayer
                self.captureSession = session
                
                // Set initial orientation
                self.updatePreviewOrientation()
            }
            
            session.startRunning()
            
            DispatchQueue.main.async {
                self.isSessionRunning = true
                print("Camera session started successfully")
            }
        }
    }
    
    func stopSession() {
        print("Stopping camera session...")
        captureSession?.stopRunning()
        captureSession = nil
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        videoDataOutput = nil
        isSessionRunning = false
    }
    
    func pauseScanning() {
          isScanningPaused = true
          print("Scanning paused")
      }
      
      func resumeScanning() {
          isScanningPaused = false
          // Reset the scan timer so it waits 5 seconds before scanning again
          lastScanTime = Date()
          print("Scanning resumed - will scan again in 2 seconds")
      }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private enum CameraError: LocalizedError {
        case deviceNotAvailable
        case cannotAddInput
        case cannotAddOutput
        
        var errorDescription: String? {
            switch self {
            case .deviceNotAvailable:
                return "Camera device not available"
            case .cannotAddInput:
                return "Cannot add camera input"
            case .cannotAddOutput:
                return "Cannot add camera output"
            }
        }
    }
}

// MARK: - Camera Delegate Extension
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isScanningPaused else { return }
        
        let now = Date()
        guard now.timeIntervalSince(lastScanTime) >= scanInterval else { return }
        lastScanTime = now
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let croppedBuffer = cropToSquare(pixelBuffer), // Gunakan cropped buffer!
              let model = model else { return }
        
        // Capture the cropped image for display
        let capturedImage = createUIImageFromPixelBuffer(croppedBuffer)
        
        let request = VNCoreMLRequest(model: model) { [weak self] req, err in
            guard let results = req.results as? [VNClassificationObservation],
                  let first = results.first else { return }
            
            let category = TrashCategory.categorize(from: first.identifier)
            
            DispatchQueue.main.async {
                self?.detectedTrash = DetectedTrash(
                    name: first.identifier.capitalized,
                    category: category.rawValue,
                    confidence: first.confidence,
                    capturedImage: capturedImage
                )
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: croppedBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Vision request failed: \(error)")
        }
    }
}

extension CameraManager {
    private func cropToSquare(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // Calculate crop area (center 360x360)
        let cropSize = 480
        let cropX = max(0, (width - cropSize) / 2)
        let cropY = max(0, (height - cropSize) / 2)
        
        // Perform crop (Core Graphics)
        var croppedBuffer: CVPixelBuffer?
        CVPixelBufferCreate(
            nil,
            cropSize,
            cropSize,
            CVPixelBufferGetPixelFormatType(pixelBuffer),
            nil,
            &croppedBuffer
        )
        
        guard let croppedBuffer = croppedBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        CVPixelBufferLockBaseAddress(croppedBuffer, [])
        
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            CVPixelBufferUnlockBaseAddress(croppedBuffer, [])
        }
        
        // Copy pixel data
        if let src = CVPixelBufferGetBaseAddress(pixelBuffer),
           let dst = CVPixelBufferGetBaseAddress(croppedBuffer) {
            let srcRowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let dstRowBytes = CVPixelBufferGetBytesPerRow(croppedBuffer)
            
            for row in 0..<cropSize {
                let srcOffset = (row + cropY) * srcRowBytes + cropX * 4
                let dstOffset = row * dstRowBytes
                
                memcpy(
                    dst.advanced(by: dstOffset),
                    src.advanced(by: srcOffset),
                    cropSize * 4
                )
            }
        }
        
        return croppedBuffer
    }
    
    // Image conversion method
    private func createUIImageFromPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
