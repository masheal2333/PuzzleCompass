import Foundation
import AVFoundation
import UIKit
import SwiftUI

/// Camera view model, responsible for handling camera operations
class CameraViewModel: NSObject, ObservableObject {
    // MARK: - Public Properties
    
    /// Camera capture session
    let session = AVCaptureSession()
    
    /// Camera output
    private let photoOutput = AVCapturePhotoOutput()
    
    /// Currently taking photo
    @Published var isTakingPhoto = false
    
    /// Camera preview view
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// Camera authorized
    @Published var cameraAuthorized = false
    
    /// Session is running
    @Published var sessionRunning = false
    
    /// Flash enabled
    @Published var flashEnabled = false
    
    /// Captured image
    @Published var capturedImage: UIImage?
    
    /// Captured image data
    @Published var capturedImageData: Data?
    
    /// Show toast
    @Published var showToast = false
    
    /// Toast message
    @Published var toastMessage: String?
    
    /// Current frame rate (for debugging)
    @Published var currentFps: Double = 0.0
    
    // MARK: - Private Properties
    
    /// Camera device
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    /// Queue
    private let sessionQueue = DispatchQueue(label: "session.queue")
    
    /// Frame rate calculation properties
    private var lastFrameTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    private let fpsUpdateInterval: CFTimeInterval = 1.0
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        // Check camera permission
        checkCameraPermission()
    }
    
    // MARK: - Camera Setup
    
    /// Configure camera capture session
    func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            // Set session preset quality
            self.session.sessionPreset = .photo
            
            // Add video input
            do {
                var defaultVideoDevice: AVCaptureDevice?
                
                if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    defaultVideoDevice = backCameraDevice
                } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    defaultVideoDevice = frontCameraDevice
                }
                
                guard let videoDevice = defaultVideoDevice else {
                    logCamera("Default camera unavailable")
                    self.setToastMessage("Camera unavailable")
                    self.session.commitConfiguration()
                    return
                }
                
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                    
                    // Create camera preview layer
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        previewLayer.videoGravity = .resizeAspectFill
                        self.previewLayer = previewLayer
                    }
                    
                    // Add video data output for frame rate calculation
                    let videoDataOutput = AVCaptureVideoDataOutput()
                    videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                    
                    if self.session.canAddOutput(videoDataOutput) {
                        self.session.addOutput(videoDataOutput)
                    }
                    
                } else {
                    logCamera("Cannot add video input")
                    self.setToastMessage("Cannot configure camera")
                    self.session.commitConfiguration()
                    return
                }
                
                // Add photo output
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                    
                    // Set high resolution
                    if #available(iOS 16.0, *) {
                        // Use new API for iOS 16 and above
                        self.photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
                    } else {
                        // Use old API for iOS below 16
                        self.photoOutput.isHighResolutionCaptureEnabled = true
                    }
                    
                } else {
                    logCamera("Cannot add photo output")
                    self.setToastMessage("Cannot configure camera output")
                    self.session.commitConfiguration()
                    return
                }
            } catch {
                logCamera("Camera setup error: \(error.localizedDescription)")
                CameraDebugger.shared.logError(error, context: "Configuring camera session")
                self.setToastMessage("Camera configuration failed")
                self.session.commitConfiguration()
                return
            }
            
            self.session.commitConfiguration()
            
            // Safely start the session
            self.startSessionSafely()
        }
    }
    
    /// Safely start camera session
    private func startSessionSafely() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Defensive programming - check authorization before starting
            guard self.cameraAuthorized else {
                logCamera("Attempted to start session but camera not authorized")
                return
            }
            
            do {
                try self.startSession()
            } catch {
                logCamera("Failed to start camera session: \(error.localizedDescription)")
                CameraDebugger.shared.logError(error, context: "Starting camera session")
                DispatchQueue.main.async {
                    self.setToastMessage("Camera startup failed")
                }
            }
        }
    }
    
    /// Start camera session
    private func startSession() throws {
        if !session.isRunning {
            logCamera("Starting camera session")
            session.startRunning()
            DispatchQueue.main.async { [weak self] in
                self?.sessionRunning = self?.session.isRunning ?? false
                logCamera("Session running status: \(self?.sessionRunning ?? false)")
            }
        }
    }
    
    /// Stop camera session
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.session.isRunning {
                logCamera("Stopping camera session")
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.sessionRunning = false
                }
            }
        }
    }
    
    /// Check permissions and setup camera
    func checkPermissionsAndSetupCamera() {
        // Check camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Authorized, configure camera
            logCamera("Camera authorized")
            DispatchQueue.main.async {
                self.cameraAuthorized = true
            }
            self.configureSession()
            
        case .notDetermined:
            // Request authorization
            logCamera("Requesting camera authorization")
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.cameraAuthorized = granted
                }
                
                self.sessionQueue.resume()
                
                if granted {
                    logCamera("Camera authorization obtained successfully")
                    self.configureSession()
                } else {
                    logCamera("Camera authorization denied")
                    DispatchQueue.main.async {
                        self.showToast(message: "Camera access denied")
                    }
                }
            }
            
        case .denied, .restricted:
            // Denied or restricted
            logCamera("Camera authorization denied or restricted")
            DispatchQueue.main.async { [weak self] in
                self?.cameraAuthorized = false
                self?.showToast(message: "Camera access required. Please enable in Settings.")
            }
            
        @unknown default:
            logCamera("Unknown camera authorization status")
            DispatchQueue.main.async { [weak self] in
                self?.cameraAuthorized = false
            }
        }
    }
    
    /// Show toast message
    func showToast(message: String) {
        setToastMessage(message)
    }
    
    /// Toggle between front and rear cameras
    func toggleCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Start configuration
            self.session.beginConfiguration()
            
            // Get current camera position
            let currentPosition: AVCaptureDevice.Position = {
                if let input = self.videoDeviceInput {
                    return input.device.position
                }
                // Default to rear
                return .back
            }()
            
            // Prepare to switch to opposite position
            let preferredPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
            
            // Find new device
            let devices = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: preferredPosition
            ).devices
            
            if let newDevice = devices.first {
                do {
                    // Create new input
                    let newVideoInput = try AVCaptureDeviceInput(device: newDevice)
                    
                    // Remove old input
                    if let oldInput = self.videoDeviceInput {
                        self.session.removeInput(oldInput)
                    }
                    
                    // Add new input
                    if self.session.canAddInput(newVideoInput) {
                        self.session.addInput(newVideoInput)
                        self.videoDeviceInput = newVideoInput
                        logCamera("Camera switched to: \(preferredPosition == .front ? "Front" : "Rear")")
                    } else {
                        // If cannot add new input, restore old input
                        if let oldInput = self.videoDeviceInput {
                            self.session.addInput(oldInput)
                        }
                    }
                } catch {
                    logCamera("Camera switch failed: \(error.localizedDescription)")
                    CameraDebugger.shared.logError(error, context: "Switching camera")
                }
            }
            
            // Commit configuration
            self.session.commitConfiguration()
        }
    }
    
    // MARK: - Camera Operations
    
    /// Take photo
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Defensive programming - check if session is running
            guard self.session.isRunning else {
                logCamera("Attempted to take photo but session not running")
                DispatchQueue.main.async {
                    self.setToastMessage("Camera not ready")
                    completion(nil)
                }
                return
            }
            
            // Set flash
            let photoSettings = AVCapturePhotoSettings()
            
            // Check flash availability
            if self.photoOutput.supportedFlashModes.contains(.on) && self.flashEnabled {
                photoSettings.flashMode = .on
            } else {
                photoSettings.flashMode = .off
            }
            
            // Take photo
            logCamera("Starting photo capture")
            DispatchQueue.main.async {
                self.isTakingPhoto = true
            }
            
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    /// Toggle flash
    func toggleFlash() {
        flashEnabled.toggle()
        
        // Record flash status change
        logCamera("Flash status: \(flashEnabled ? "On" : "Off")")
    }
    
    // MARK: - Permission Check
    
    /// Check camera permission
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Authorized, configure camera
            logCamera("Camera authorized")
            DispatchQueue.main.async {
                self.cameraAuthorized = true
            }
            self.configureSession()
            
        case .notDetermined:
            // Request authorization
            logCamera("Requesting camera authorization")
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.cameraAuthorized = granted
                }
                
                self.sessionQueue.resume()
                
                if granted {
                    logCamera("Camera authorization obtained successfully")
                    self.configureSession()
                } else {
                    logCamera("Camera authorization denied")
                }
            }
            
        case .denied, .restricted:
            // Denied or restricted
            logCamera("Camera authorization denied or restricted")
            DispatchQueue.main.async { [weak self] in
                self?.cameraAuthorized = false
            }
            
        @unknown default:
            logCamera("Unknown camera authorization status")
            DispatchQueue.main.async { [weak self] in
                self?.cameraAuthorized = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Set toast message
    func setToastMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.toastMessage = message
            self.showToast = true
            
            // Hide toast after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.showToast = false
            }
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Mark photo capture completed
            self.isTakingPhoto = false
            
            // Handle error
            if let error = error {
                logCamera("Photo processing error: \(error.localizedDescription)")
                CameraDebugger.shared.logError(error, context: "Processing photo")
                self.setToastMessage("Photo capture failed")
                return
            }
            
            // Get image data
            guard let imageData = photo.fileDataRepresentation() else {
                logCamera("Cannot get image data")
                self.setToastMessage("Cannot process photo")
                return
            }
            
            // Convert to UIImage
            guard let capturedImage = UIImage(data: imageData) else {
                logCamera("Cannot convert image data")
                self.setToastMessage("Cannot process photo")
                return
            }
            
            // Store result
            self.capturedImage = capturedImage
            self.capturedImageData = imageData
            
            logCamera("Photo capture succeeded: \(imageData.count) bytes")
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Calculate frame rate
        let timestamp = CACurrentMediaTime()
        frameCount += 1
        
        if timestamp - lastFrameTimestamp >= fpsUpdateInterval {
            let fps = Double(frameCount) / (timestamp - lastFrameTimestamp)
            
            DispatchQueue.main.async { [weak self] in
                self?.currentFps = fps
            }
            
            lastFrameTimestamp = timestamp
            frameCount = 0
        }
    }
} 