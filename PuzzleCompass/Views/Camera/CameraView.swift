import SwiftUI
import AVFoundation

/// View for capturing photos using the camera
struct CameraView: View {
    // App state for managing navigation and data
    @EnvironmentObject var appState: AppState
    
    // View model for the camera
    @StateObject var viewModel = CameraViewModel()
    
    // Local state
    @State private var showGuide = true
    @State private var showDebugger = false
    
    var body: some View {
        ZStack {
            // 主相机预览
            CameraPreview(cameraViewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            // 相机叠加层UI
            CameraOverlayView(viewModel: viewModel, showGuide: $showGuide, showDebugger: $showDebugger)
            
            // 调试器视图
            if showDebugger {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showDebugger = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    
                    CameraDebuggerView(viewModel: viewModel)
                        .frame(maxHeight: 400)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(10)
                        .padding()
                }
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: showDebugger)
                .zIndex(100)
            }
            
            // Camera status overlay 
            if !viewModel.sessionRunning && viewModel.cameraAuthorized {
                VStack {
                    Spacer()
                    Text("Starting camera...")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 100)
                }
            }
            
            // Camera permissions overlay
            if !viewModel.cameraAuthorized {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "camera.metering.unknown")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        Text("Camera access is required")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        Text("Please enable camera access in Settings")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.bottom)
                        
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Open Settings")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(30)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(15)
                    .padding(30)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.7))
                .ignoresSafeArea()
            }
            
            // Camera controls
            VStack {
                // Header with mode and close button
                HStack {
                    Text(appState.cameraMode == .puzzle ? "Capture Complete Puzzle" : "Capture Puzzle Piece")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    Button(action: {
                        appState.navigateToMainScreen()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding()
                
                Spacer()
                
                // Camera control bar
                CameraControlBar(
                    flashEnabled: $viewModel.flashEnabled,
                    isCapturing: $viewModel.isTakingPhoto,
                    onCapture: {
                        takePicture()
                    },
                    onToggleFlash: {
                        viewModel.toggleFlash()
                    }
                )
                .padding(.bottom, 30)
                .disabled(!viewModel.sessionRunning || viewModel.isTakingPhoto)
                .opacity(viewModel.sessionRunning ? 1.0 : 0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Toast message
            if viewModel.showToast, let message = viewModel.toastMessage {
                VStack {
                    Spacer()
                    
                    Text(message)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 100)
                }
            }
            
            // Taking photo animation
            if viewModel.isTakingPhoto {
                Color.black
                    .ignoresSafeArea()
                    .opacity(0.3)
            }
            
            // Guidance view
            if showGuide {
                GuidanceView(mode: appState.cameraMode, isShowing: $showGuide)
                    .background(Color.black.opacity(0.7))
            }
        }
        .onAppear {
            print("📱 CameraView出现")
            
            // 添加详细日志
            logInfo("CameraView appeared", category: "Camera")
            
            // 设置和启动相机
            setupCamera()
            
            // 连接调试器
            #if DEBUG
            CameraDebugger.shared.monitorSession(viewModel.session)
            logCamera("CameraView 已连接调试器")
            #endif
            
            // 直接更新状态以反映当前情况
            viewModel.sessionRunning = viewModel.session.isRunning
            print("📱 CameraView初始状态 - 相机会话运行: \(viewModel.sessionRunning)")
            logInfo("Camera session running: \(viewModel.sessionRunning)", category: "Camera")
            
            // 强制启动相机会话
            DispatchQueue.global(qos: .userInitiated).async {
                // 如果会话还未运行，尝试启动
                if !viewModel.session.isRunning {
                    print("📱 强制启动相机会话")
                    logInfo("Forcing camera session to start", category: "Camera")
                    
                    // 记录活动尝试
                    #if DEBUG
                    logCamera("尝试强制启动相机会话")
                    #endif
                    
                    viewModel.session.startRunning()
                    
                    // 等待相机启动
                    Thread.sleep(forTimeInterval: 0.7)
                    
                    // 更新UI状态
                    DispatchQueue.main.async {
                        // 再次获取最新状态
                        let isRunning = viewModel.session.isRunning
                        print("📱 相机强制启动后状态: \(isRunning)")
                        logInfo("Camera forced start result: \(isRunning ? "success" : "failure")", category: "Camera")
                        
                        #if DEBUG
                        logCamera("相机强制启动结果: \(isRunning ? "成功" : "失败")")
                        #endif
                        
                        viewModel.sessionRunning = isRunning
                        
                        // 如果相机仍未启动，尝试第二种方式
                        if !isRunning {
                            print("📱 常规启动失败，重新进行完整设置")
                            logWarning("Regular start failed, performing full camera setup", category: "Camera")
                            
                            #if DEBUG
                            logCamera("常规启动失败，开始完整相机设置过程")
                            #endif
                            
                            viewModel.checkPermissionsAndSetupCamera()
                            
                            // 给相机更多时间初始化
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                if !viewModel.session.isRunning {
                                    print("📱 相机初始化持续失败，显示错误消息")
                                    logError("Camera initialization persistently failed", category: "Camera")
                                    
                                    // 记录当前相机状态详情
                                    let authStatus = AVCaptureDevice.authorizationStatus(for: .video).rawValue
                                    let hasInputs = viewModel.session.inputs.count > 0
                                    let hasOutputs = viewModel.session.outputs.count > 0
                                    let isInterrupted = viewModel.session.isInterrupted
                                    
                                    logError("Camera details: auth=\(authStatus), inputs=\(hasInputs), outputs=\(hasOutputs), interrupted=\(isInterrupted)", category: "Camera")
                                    
                                    #if DEBUG
                                    logError("相机初始化持续失败")
                                    if !viewModel.cameraAuthorized {
                                        logError("相机未授权，权限状态: \(AVCaptureDevice.authorizationStatus(for: .video).rawValue)")
                                    }
                                    #endif
                                    
                                    viewModel.showToast(message: "Camera initialization failed. Please restart the app.")
                                }
                            }
                        }
                    }
                } else {
                    print("📱 相机会话已经运行中")
                    logInfo("Camera session already running", category: "Camera")
                    
                    #if DEBUG
                    logCamera("相机会话已在运行")
                    #endif
                    
                    DispatchQueue.main.async {
                        viewModel.sessionRunning = true
                    }
                }
            }
            
            // 显示指导提示
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showGuide = false
                }
            }
        }
        .onDisappear {
            print("📱 CameraView消失")
            // Stop camera session when view disappears
            if viewModel.session.isRunning {
                viewModel.session.stopRunning()
            }
        }
    }
    
    // Setup camera on appear
    private func setupCamera() {
        print("📱 设置相机")
        logInfo("Setting up camera", category: "Camera")
        
        // Check permissions and set up camera
        viewModel.checkPermissionsAndSetupCamera()
        
        // 获取相机权限状态进行额外检查
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        print("📱 相机权限状态: \(authStatus.rawValue)")
        logInfo("Camera authorization status: \(authStatus.rawValue)", category: "Camera")
        
        // 如果权限状态为未确定，添加额外的权限请求处理
        if authStatus == .notDetermined {
            print("📱 相机权限未确定，显式请求权限")
            logInfo("Camera permission not determined, explicitly requesting", category: "Camera")
            
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    print("📱 相机权限请求结果: \(granted)")
                    logInfo("Camera permission request result: \(granted)", category: "Camera")
                    
                    if granted {
                        // 权限获取后重新设置相机
                        self.viewModel.checkPermissionsAndSetupCamera()
                    } else {
                        // 权限被拒绝，显示提示
                        self.viewModel.showToast(message: "Camera permission denied")
                        logError("Camera permission denied by user", category: "Camera")
                    }
                }
            }
        }
    }
    
    // Capture photo using the view model
    private func takePicture() {
        print("📱 开始拍照流程")
        logInfo("Starting photo capture process", category: "Camera")
        
        // 防止重复点击
        guard !viewModel.isTakingPhoto else {
            print("📱 已经在拍照中，忽略重复点击")
            logInfo("Already taking photo, ignoring duplicate tap", category: "Camera")
            return
        }
        
        // 检查相机权限状态
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus != .authorized {
            print("📱 相机未授权，无法拍照 (状态: \(authStatus.rawValue))")
            logError("Camera not authorized for capture (status: \(authStatus.rawValue))", category: "Camera")
            viewModel.showToast(message: "Camera not authorized")
            
            // 如果权限未确定，尝试请求权限
            if authStatus == .notDetermined {
                setupCamera()
            }
            return
        }
        
        // 检查相机状态
        guard viewModel.cameraAuthorized else {
            print("📱 相机未授权，无法拍照")
            logError("Camera not authorized, cannot take photo", category: "Camera")
            viewModel.showToast(message: "Camera not authorized")
            return
        }
        
        guard viewModel.sessionRunning else {
            print("📱 相机未就绪，无法拍照")
            logWarning("Camera not ready, cannot take photo", category: "Camera")
            
            // 显示正在准备相机的提示
            viewModel.showToast(message: "Preparing camera...")
            
            // 尝试启动相机并稍后重试
            DispatchQueue.global(qos: .userInteractive).async {
                // 尝试启动相机会话
                if !self.viewModel.session.isRunning {
                    print("📱 尝试启动相机会话")
                    logInfo("Attempting to start camera session", category: "Camera")
                    self.viewModel.session.startRunning()
                }
                
                // 等待相机启动（较长延迟确保启动完成）
                Thread.sleep(forTimeInterval: 1.5)
                
                // 再次检查相机状态
                let isReady = self.viewModel.session.isRunning
                logInfo("Camera session running after wait: \(isReady)", category: "Camera")
                
                DispatchQueue.main.async {
                    // 更新UI状态
                    self.viewModel.sessionRunning = isReady
                    
                    if isReady {
                        // 相机已就绪，提示用户再次尝试
                        print("📱 相机已就绪，指示用户再次尝试")
                        logInfo("Camera is now ready, prompting user to try again", category: "Camera")
                        self.viewModel.showToast(message: "Camera is ready, please try again")
                    } else {
                        // 相机启动失败，提示用户重启应用
                        print("📱 相机会话无法启动")
                        logError("Cannot start camera session", category: "Camera")
                        self.viewModel.showToast(message: "Cannot start camera, please restart the app")
                    }
                }
            }
            return
        }
        
        // 防止并发拍照请求
        withAnimation {
            viewModel.isTakingPhoto = true
        }
        
        // 显示UI反馈
        print("📱 触发拍照请求")
        logInfo("Photo capture request triggered", category: "Camera")
        
        // Haptic feedback
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
        
        // 捕获照片
        viewModel.capturePhoto { capturedImage in
            print("📱 拍照完成回调")
            logInfo("Photo capture completed", category: "Camera")
            
            // 确保UI更新在主线程
            DispatchQueue.main.async {
                // 重置拍照状态
                withAnimation {
                    self.viewModel.isTakingPhoto = false
                }
                
                // 检查照片是否成功捕获
                guard let image = capturedImage else {
                    print("📱 拍照失败，未返回图像")
                    logError("Photo capture failed, no image returned", category: "Camera")
                    self.viewModel.showToast(message: "Failed to capture image")
                    return
                }
                
                print("📱 拍照成功，图像尺寸: \(image.size.width) x \(image.size.height)")
                logInfo("Photo captured successfully: \(image.size.width) x \(image.size.height)", category: "Camera")
                
                // 防止处理无效图像
                guard image.size.width > 0 && image.size.height > 0 else {
                    print("📱 图像尺寸无效")
                    logError("Invalid image dimensions", category: "Camera")
                    self.viewModel.showToast(message: "Invalid image captured")
                    return
                }
                
                // 处理图像前进行保护性复制
                guard let safeCopy = self.createImageCopy(image) else {
                    print("📱 无法创建图像副本")
                    logError("Failed to create image copy", category: "Camera")
                    self.viewModel.showToast(message: "Failed to process image")
                    return
                }
                
                // 根据模式处理图像
                self.processAndNavigate(with: safeCopy)
            }
        }
    }
    
    // 创建图像的安全副本
    private func createImageCopy(_ original: UIImage) -> UIImage? {
        guard let cgImage = original.cgImage else {
            if let ciImage = original.ciImage {
                let context = CIContext()
                if let cgImg = context.createCGImage(ciImage, from: ciImage.extent) {
                    return UIImage(cgImage: cgImg, scale: original.scale, orientation: original.imageOrientation)
                }
            }
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: original.scale, orientation: original.imageOrientation)
    }
    
    // 处理图像并导航
    private func processAndNavigate(with image: UIImage) {
        // 处理图像并导航到下一个界面
        if appState.cameraMode == .puzzle {
            print("📱 设置完整拼图图像，尺寸: \(image.size.width) x \(image.size.height)")
            
            appState.setPuzzleImage(image)
            
            // 验证图像是否设置成功
            if appState.getPuzzleImage() != nil {
                print("📱 成功设置拼图图像")
            } else {
                print("📱 设置拼图图像失败")
                viewModel.showToast(message: "Failed to set puzzle image")
                return
            }
        } else {
            let previousCount = appState.getPieceImages().count
            print("📱 添加拼图碎片图像，当前数量: \(previousCount)")
            
            appState.addPieceImage(image)
            
            // 验证图像是否添加成功
            if appState.getPieceImages().count > previousCount {
                print("📱 成功添加碎片图像")
            } else {
                print("📱 添加碎片图像失败")
                viewModel.showToast(message: "Failed to add piece image")
                return
            }
        }
        
        // 导航到确认视图
        print("📱 即将导航到确认视图，当前屏幕: \(appState.currentScreen)")
        
        // 使用主线程确保UI更新安全
        DispatchQueue.main.async {
            // 导航到确认视图
            self.appState.navigateToConfirmation(source: .camera)
            
            // 验证导航结果
            print("📱 导航后的屏幕: \(self.appState.currentScreen)")
        }
    }
}

/// Control bar for camera actions
struct CameraControlBar: View {
    @Binding var flashEnabled: Bool
    @Binding var isCapturing: Bool
    let onCapture: () -> Void
    let onToggleFlash: () -> Void
    
    var body: some View {
        HStack(spacing: 60) {
            // Flash toggle button
            Button(action: onToggleFlash) {
                Image(systemName: flashEnabled ? "bolt.fill" : "bolt.slash")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            
            // Capture button
            Button(action: onCapture) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(isCapturing ? Color.gray : Color.white)
                        .frame(width: 70, height: 70)
                        .scaleEffect(isCapturing ? 0.8 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isCapturing)
                }
            }
            
            // Placeholder for balance
            Circle()
                .fill(Color.clear)
                .frame(width: 50, height: 50)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(40)
    }
}

// MARK: - Previews
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        // 使用模拟视图，不触发相机功能
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("相机界面预览")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(4/3, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 50) {
                    Button(action: {}) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {}) {
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 70, height: 70)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .padding()
            .background(Color.black)
        }
        .previewDisplayName("相机界面")
    }
} 