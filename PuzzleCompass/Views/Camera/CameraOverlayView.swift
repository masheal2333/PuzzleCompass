import SwiftUI

/// 相机叠加视图，显示引导线和指示
struct CameraOverlayView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: CameraViewModel
    @Binding var showGuide: Bool
    @Binding var showDebugger: Bool
    
    var body: some View {
        ZStack {
            // 全屏叠加层
            Color.clear
            
            // 引导框
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 2)
                .frame(
                    width: UIScreen.main.bounds.width * 0.8,
                    height: UIScreen.main.bounds.width * 0.8
                )
            
            // 框架角落
            VStack {
                HStack {
                    frameCorner(rotation: .degrees(0))
                    Spacer()
                    frameCorner(rotation: .degrees(90))
                }
                
                Spacer()
                
                HStack {
                    frameCorner(rotation: .degrees(270))
                    Spacer()
                    frameCorner(rotation: .degrees(180))
                }
            }
            .frame(
                width: UIScreen.main.bounds.width * 0.8 + 20,
                height: UIScreen.main.bounds.width * 0.8 + 20
            )
            
            // 顶部指示横幅
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.7))
                        .frame(height: 50)
                    
                    // 使用来自环境的AppState获取当前模式
                    Text(instructionText)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 顶部区域
                HStack {
                    Button(action: {
                        appState.currentScreen = .main
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleFlash()
                    }) {
                        Image(systemName: viewModel.flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        showDebugger.toggle()
                    }) {
                        Image(systemName: "ladybug")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                // 添加控制栏
                CameraControlsBar(viewModel: viewModel)
                    .padding(.bottom, 40)
            }
            .edgesIgnoringSafeArea(.top)
            
            // 如果显示指导
            if showGuide {
                GuidanceView(mode: .puzzle, isShowing: $showGuide)
                    .transition(.opacity)
            }
        }
        .overlay(
            // 在需要时显示提示信息
            Group {
                if viewModel.showToast, let message = viewModel.toastMessage {
                    ToastView(message: message)
                }
            }
        )
    }
    
    // 创建角标记的辅助函数
    private func frameCorner(rotation: Angle) -> some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 20))
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 20, y: 0))
            }
            .stroke(Color.white, lineWidth: 4)
        }
        .frame(width: 20, height: 20)
        .rotationEffect(rotation)
    }
    
    // 根据环境中的AppState确定合适的指示文字
    private var instructionText: String {
        // 使用一个通用提示，稍后可以根据模式自定义
        "将物体置于框内拍摄"
    }
}

/// 底部相机控制栏
struct CameraControlsBar: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        HStack(spacing: 60) {
            // 闪光灯按钮
            Button(action: {
                // 记录用户交互
                logInfo("用户点击闪光灯按钮", category: "CameraUI")
                // 添加闪光灯切换功能调用
                viewModel.toggleFlash()
            }) {
                Image(systemName: viewModel.flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            
            // 拍照按钮
            Button(action: {
                // 记录用户交互
                logInfo("用户点击拍摄按钮", category: "CameraUI")
                // 添加拍照功能调用
                viewModel.capturePhoto { _ in
                    // 处理拍照结果
                }
            }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.8), lineWidth: 2)
                            .frame(width: 60, height: 60)
                    )
            }
            
            // 相机切换按钮（前后摄像头）
            Button(action: {
                // 记录用户交互
                logInfo("用户点击切换相机按钮", category: "CameraUI")
                // 使用toggleCamera而不是switchCamera
                viewModel.toggleCamera()
            }) {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(40)
    }
}

#Preview {
    // 创建ViewModel用于预览，使用预览模式
    let viewModel = CameraViewModel()
    CameraOverlayView(viewModel: viewModel, showGuide: .constant(true), showDebugger: .constant(false))
        .background(Color.black)
} 