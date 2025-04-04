import Foundation
import AVFoundation
import SwiftUI
import UIKit

/// 用于相机预览层的实际UIView
class CameraPreviewUIView: UIView {
    var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    init(session: AVCaptureSession?) {
        super.init(frame: .zero)
        self.session = session
        setupPreviewLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPreviewLayer()
    }
    
    func setupPreviewLayer() {
        if let session = session {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.videoOrientation = .portrait
            
            layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer
            
            // 记录创建状态
            logInfo("Camera preview layer created and added to view", category: "CameraPreview")
        } else {
            logWarning("Attempted to setup preview layer with nil session", category: "CameraPreview")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        
        // 记录布局信息
        if let previewLayer = previewLayer {
            logInfo("Camera preview layer layout updated: \(previewLayer.frame)", category: "CameraPreview")
        }
    }
    
    /// 更新相机会话
    func updateSession(_ session: AVCaptureSession?) {
        if self.session !== session {
            logInfo("Updating camera preview with new session", category: "CameraPreview")
            
            // 移除旧的预览层
            previewLayer?.removeFromSuperlayer()
            
            // 保存新会话并重新创建预览层
            self.session = session
            setupPreviewLayer()
            layoutSubviews()
        }
    }
    
    /// 记录预览层状态
    func logPreviewLayerStatus() {
        guard let previewLayer = previewLayer else {
            logWarning("No preview layer to report status", category: "CameraPreview")
            return
        }
        
        var status = "预览层状态:\n"
        status += "- 连接: \(previewLayer.connection != nil ? "已连接" : "未连接")\n"
        
        if let connection = previewLayer.connection {
            status += "- 连接是否有效: \(connection.isEnabled ? "有效" : "无效")\n"
            status += "- 视频方向: \(connection.videoOrientation.rawValue)\n"
        }
        
        status += "- 尺寸: \(previewLayer.frame.width)x\(previewLayer.frame.height)\n"
        status += "- 视频重力模式: \(previewLayer.videoGravity.rawValue)\n"
        
        if let session = session {
            status += "- 会话运行中: \(session.isRunning ? "是" : "否")\n"
        } else {
            status += "- 会话未设置\n"
        }
        
        logInfo(status, category: "CameraPreview")
    }
}

/// 将相机预览视图包装为SwiftUI视图
final class CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraViewModel: CameraViewModel
    
    // 初始化器
    init(cameraViewModel: CameraViewModel) {
        self.cameraViewModel = cameraViewModel
    }
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        logInfo("Creating camera preview view", category: "CameraPreview")
        
        let previewView = CameraPreviewUIView(session: cameraViewModel.session)
        
        // 检查预览视图状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            previewView.logPreviewLayerStatus()
        }
        
        return previewView
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        logInfo("Updating camera preview view", category: "CameraPreview")
        
        // 更新预览视图的会话
        uiView.updateSession(cameraViewModel.session)
        
        // 如果会话不在运行，尝试运行它
        if !cameraViewModel.session.isRunning && cameraViewModel.sessionRunning {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                logInfo("Starting AVCaptureSession from preview view", category: "CameraPreview")
                self.cameraViewModel.session.startRunning()
            }
        }
    }
    
    static func dismantleUIView(_ uiView: CameraPreviewUIView, coordinator: ()) {
        logInfo("Dismantling camera preview view", category: "CameraPreview")
    }
    
    typealias UIViewType = CameraPreviewUIView
}

/// 相机预览包装器 - 主视图组件
struct CameraPreviewWrapper: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            CameraPreview(cameraViewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            // 如果相机未运行显示错误指示
            if !viewModel.sessionRunning {
                VStack {
                    Image(systemName: "video.slash.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                    Text("Camera not available")
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    Button(action: {
                        Task {
                            viewModel.checkPermissionsAndSetupCamera()
                        }
                    }) {
                        Text("Retry")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                }
                .padding(30)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.frame
        
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.frame
        }
    }
}

struct CameraPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        // 不要直接调用CameraView()，因为它会尝试访问真实摄像头
        // 相反，创建一个基本的模拟视图
        VStack {
            Text("相机预览(模拟)")
                .font(.headline)
                .padding()
            
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .aspectRatio(4/3, contentMode: .fit)
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 30) {
                Button(action: {}) {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
                
                Button(action: {}) {
                    Image(systemName: "circle")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                }
                
                Button(action: {}) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.black)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Camera Setup Methods
extension CameraPreviewView {
    
    /// 请求相机权限并设置会话
    func requestCameraAccess() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCamera()
        case .notDetermined:
            let granted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
            
            if granted {
                startCamera()
            }
        case .denied, .restricted:
            viewModel.showToast(message: "相机访问被拒绝。请在设置中允许访问相机。")
        @unknown default:
            viewModel.showToast(message: "未知的相机权限状态")
        }
    }
    
    /// 开始相机
    private func startCamera() {
        viewModel.checkPermissionsAndSetupCamera()
    }
} 