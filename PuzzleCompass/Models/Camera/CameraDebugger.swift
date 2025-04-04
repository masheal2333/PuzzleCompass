import Foundation
import AVFoundation
import OSLog

/// Camera system debugging tool
class CameraDebugger {
    /// Singleton access
    static let shared = CameraDebugger()
    
    /// Limit log entry count
    private let maxLogEntries = 100
    
    /// Recently recorded logs
    var recentLogs: [String] = []
    
    /// Latest captured error
    var lastError: String?
    
    /// Record camera module log
    func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logEntry = "[\(timestamp)] \(message)"
        
        // Add to in-memory logs
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.recentLogs.insert(logEntry, at: 0)
            
            // Limit log entry count
            if self.recentLogs.count > self.maxLogEntries {
                self.recentLogs = Array(self.recentLogs.prefix(self.maxLogEntries))
            }
        }
        
        // Also output to console
        print("📷 \(logEntry)")
        
        // Record to system log
        if #available(iOS 14.0, *) {
            let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app.puzzlecompass", category: "Camera")
            logger.debug("\(message)")
        }
    }
    
    /// Record error
    func logError(_ error: Error, context: String? = nil) {
        let errorMessage = context != nil ? "\(context!): \(error.localizedDescription)" : error.localizedDescription
        
        // Update latest error
        DispatchQueue.main.async { [weak self] in
            self?.lastError = errorMessage
        }
        
        // Record to log
        log("❌ Error: \(errorMessage)")
    }
    
    /// Clear all logs
    func clearLogs() {
        DispatchQueue.main.async { [weak self] in
            self?.recentLogs.removeAll()
            self?.lastError = nil
        }
    }
    
    /// Monitor camera session
    func monitorSession(_ session: AVCaptureSession) {
        log("Start monitoring camera session")
        
        // Record session status
        log("Camera session status: \(session.isRunning ? "running" : "not running")")
        
        // Record camera configuration
        if let deviceInput = session.inputs.first as? AVCaptureDeviceInput {
            let device = deviceInput.device
            log("Camera device: \(device.localizedName)")
            log("Camera position: \(device.position == .back ? "rear" : "front")")
            log("Flash available: \(device.hasFlash)")
            log("Auto focus available: \(device.isFocusPointOfInterestSupported)")
        } else {
            log("Unable to get camera device info")
        }
        
        // Record camera output configuration
        var outputsInfo: [String] = []
        for output in session.outputs {
            if output is AVCapturePhotoOutput {
                outputsInfo.append("Photo Output")
            } else if output is AVCaptureVideoDataOutput {
                outputsInfo.append("Video Data Output")
            } else if output is AVCaptureAudioDataOutput {
                outputsInfo.append("Audio Data Output")
            } else {
                outputsInfo.append("Other Output: \(type(of: output))")
            }
        }
        
        if outputsInfo.isEmpty {
            log("Camera session has no outputs configured")
        } else {
            log("Camera output configuration: \(outputsInfo.joined(separator: ", "))")
        }
    }
}

// MARK: - Global debugging helper functions
/// Record camera-related log information
func logCamera(_ message: String) {
    CameraDebugger.shared.log(message)
} 