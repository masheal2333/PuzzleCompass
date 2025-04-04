import SwiftUI
import AVFoundation

struct CameraDebuggerView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                debugSection("Camera Status") {
                    debugItem("Session Running", value: "\(viewModel.sessionRunning)")
                    debugItem("Camera Authorized", value: "\(viewModel.cameraAuthorized)")
                    debugItem("Taking Photo", value: "\(viewModel.isTakingPhoto)")
                    debugItem("Flash", value: "\(viewModel.flashEnabled ? "On" : "Off")")
                }
                
                debugSection("Performance Data") {
                    debugItem("Frame Rate", value: String(format: "%.1f FPS", viewModel.currentFps))
                    debugItem("Memory Usage", value: "\(getMemoryUsage()) MB")
                }
                
                debugSection("Camera Configuration") {
                    if let device = viewModel.session.inputs.first as? AVCaptureDeviceInput {
                        let camera = device.device
                        debugItem("Device Name", value: camera.localizedName)
                        debugItem("Focal Length", value: String(format: "%.1f°", camera.activeFormat.videoFieldOfView))
                        debugItem("ISO", value: String(format: "%.0f", camera.iso))
                        debugItem("Exposure Time", value: String(format: "%.2f ms", camera.exposureDuration.seconds * 1000))
                        debugItem("White Balance", value: String(format: "%.2f R", camera.deviceWhiteBalanceGains.redGain))
                    } else {
                        Text("Unable to get camera device info")
                            .foregroundColor(.red)
                    }
                }
                
                debugSection("Latest Error") {
                    if let error = CameraDebugger.shared.lastError {
                        Text(error)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.red)
                    } else {
                        Text("No errors")
                            .foregroundColor(.green)
                    }
                }
                
                debugSection("Recent Logs") {
                    VStack(alignment: .leading) {
                        ForEach(CameraDebugger.shared.recentLogs.prefix(5), id: \.self) { log in
                            Text(log)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.vertical, 2)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func debugSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 2)
            
            content()
                .padding(.leading, 10)
            
            Divider()
                .background(Color.gray.opacity(0.5))
                .padding(.vertical, 5)
        }
    }
    
    private func debugItem(_ name: String, value: String) -> some View {
        HStack {
            Text(name)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
                .frame(width: 90, alignment: .leading)
            
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
        }
    }
    
    private func getMemoryUsage() -> String {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return String(format: "%.1f", Double(info.resident_size) / 1024.0 / 1024.0)
        } else {
            return "Unable to get"
        }
    }
}

// MARK: - Preview
#Preview {
    CameraDebuggerView(viewModel: CameraViewModel())
        .preferredColorScheme(.dark)
        .background(Color.black)
} 