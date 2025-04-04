import SwiftUI

/// View for confirming captured or selected images
struct ConfirmationView: View {
    // App state for managing navigation and data
    @EnvironmentObject var appState: AppState
    
    // 添加一个本地状态来强制刷新视图
    @State private var refreshCounter = 0
    
    // 使用初始化器设置通知观察者
    init() {
        // 不需要在这里添加通知观察者，因为它们会在onAppear时添加
        print("👁️ ConfirmationView初始化")
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Header with title and close button
                HStack {
                    Text(appState.cameraMode == .puzzle ? "Confirm Puzzle" : "Confirm Pieces")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Navigate back based on source
                        if appState.cameraSource == .camera {
                            appState.navigateToCameraScreen(mode: appState.cameraMode)
                        } else {
                            appState.navigateToMainScreen()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                Spacer()
                
                // Image preview
                if appState.cameraMode == .puzzle, let puzzleImage = appState.getPuzzleImage() {
                    // Single puzzle image
                    Image(uiImage: puzzleImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding()
                        .id("puzzle_image_\(refreshCounter)") // 强制刷新视图
                } else if !appState.getPieceImages().isEmpty {
                    // Multiple piece images
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                            ForEach(0..<appState.getPieceImages().count, id: \.self) { index in
                                Image(uiImage: appState.getPieceImages()[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .id("piece_\(index)_\(refreshCounter)") // 强制刷新视图
                            }
                        }
                        .padding()
                    }
                } else {
                    // Error case - no images
                    Text("No images to display")
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 20) {
                    // Retake/Cancel button
                    Button(action: {
                        // Go back to capture or selection
                        if appState.cameraSource == .camera {
                            appState.navigateToCameraScreen(mode: appState.cameraMode)
                        } else {
                            appState.navigateToAlbumScreen(mode: appState.cameraMode)
                        }
                    }) {
                        HStack {
                            Image(systemName: appState.cameraSource == .camera ? "camera.fill" : "photo.fill")
                            Text(appState.cameraSource == .camera ? "Retake" : "Select Again")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    // Confirm button
                    Button(action: {
                        confirmSelection()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Confirm")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            print("👁️ ConfirmationView出现")
            // 打印当前状态信息
            print("👁️ 当前屏幕: \(appState.currentScreen), 相机模式: \(appState.cameraMode == .puzzle ? "拼图" : "碎片"), 相机来源: \(appState.cameraSource == .camera ? "相机" : "相册")")
            
            // 检查图像状态
            if appState.cameraMode == .puzzle {
                let puzzleImage = appState.getPuzzleImage()
                print("👁️ 拼图图像是否存在: \(puzzleImage != nil)")
                if let image = puzzleImage {
                    print("👁️ 拼图图像尺寸: \(image.size.width) x \(image.size.height)")
                }
            } else {
                let pieceImages = appState.getPieceImages()
                print("👁️ 碎片图像数量: \(pieceImages.count)")
                for (index, image) in pieceImages.enumerated() {
                    print("👁️ 碎片[\(index)]尺寸: \(image.size.width) x \(image.size.height)")
                }
            }
            
            // 立即刷新一次视图，确保显示最新数据
            refreshCounter += 1
            print("👁️ 初始视图已刷新，计数器: \(refreshCounter)")
            
            // 添加通知观察者
            NotificationCenter.default.addObserver(
                forName: Notification.Name("PuzzleImageUpdated"), 
                object: nil, 
                queue: .main
            ) { [self] _ in
                print("👁️ 收到拼图图像更新通知")
                self.refreshCounter += 1
                print("👁️ 视图已刷新，计数器: \(self.refreshCounter)")
            }
            
            NotificationCenter.default.addObserver(
                forName: Notification.Name("PieceImagesUpdated"), 
                object: nil, 
                queue: .main
            ) { [self] _ in
                print("👁️ 收到碎片图像更新通知")
                self.refreshCounter += 1
                print("👁️ 视图已刷新，计数器: \(self.refreshCounter)")
            }
        }
        .onDisappear {
            print("👁️ ConfirmationView消失")
            
            // 移除通知观察者 - 使用类对象作为observer会导致内存泄漏
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    // Handle confirmation of selected images
    private func confirmSelection() {
        print("👍 确认选择")
        
        if appState.cameraMode == .puzzle {
            print("👍 拼图模式确认")
            // If we captured a puzzle, switch to piece mode
            appState.cameraMode = .piece
            
            // Go back to the appropriate screen based on source
            if appState.cameraSource == .camera {
                print("👍 导航到相机（碎片模式）")
                appState.navigateToCameraScreen(mode: .piece)
            } else {
                print("👍 导航到主屏幕")
                appState.navigateToMainScreen()
            }
        } else {
            print("👍 碎片模式确认")
            // If we have both puzzle and pieces, start analysis
            if appState.hasPuzzleImage() {
                print("👍 开始分析")
                appState.startAnalysis()
            } else {
                print("👍 缺少拼图，返回主屏幕")
                // If missing the puzzle, go to the main screen
                appState.navigateToMainScreen()
            }
        }
    }
} 