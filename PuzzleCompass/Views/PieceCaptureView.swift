import SwiftUI
import AVFoundation

// 拼图碎片拍摄/上传界面
struct PieceCaptureView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var puzzleService: PuzzleService
    @State private var puzzlePieces: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showingActionSheet = false
    @State private var navigateToResults = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // 检查并请求相机权限
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            alertTitle = "相机访问受限"
            alertMessage = "请前往设置允许PuzzleCompass访问您的相机"
            showAlert = true
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    headerView
                    pieceGridView
                    Spacer()
                    actionButtonsView
                    tipTextView
                }
            }
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("取消")
                }
            )
            .actionSheet(isPresented: $showingActionSheet) {
                createActionSheet()
            }
            .sheet(isPresented: $showingImagePicker) {
                createImagePicker()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
            .background(
                NavigationLink(
                    destination: resultDestination,
                    isActive: $navigateToResults
                ) {
                    EmptyView()
                }
            )
        }
    }
    
    // MARK: - 子视图组件
    
    private var headerView: some View {
        VStack {
            // 顶部说明
            Text("拍摄拼图碎片")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("拍摄或上传您想要定位的拼图碎片\n可以添加多个碎片")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var pieceGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                // 添加按钮
                addPieceButton
                
                // 已添加的碎片
                pieceItems
            }
            .padding()
        }
        .frame(maxHeight: 400)
    }
    
    private var addPieceButton: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            VStack {
                Image(systemName: "plus")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .clipShape(Circle())
                
                Text("添加碎片")
                    .foregroundColor(.primary)
                    .font(.caption)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private var pieceItems: some View {
        ForEach(0..<puzzlePieces.count, id: \.self) { index in
            ZStack(alignment: .topTrailing) {
                Image(uiImage: puzzlePieces[index])
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(10)
                
                // 删除按钮
                Button(action: {
                    puzzlePieces.remove(at: index)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .background(Color.red)
                        .clipShape(Circle())
                        .padding(5)
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            // 开始定位按钮 - 符合"自动分析并显示结果界面"
            Button(action: {
                if !puzzleService.puzzlePieceImages.isEmpty {
                    // 完成拍摄，分析结果
                    _ = puzzleService.analyzeAllPieces()

                    // 更新导航状态
                    navigateToResults = false
                    presentationMode.wrappedValue.dismiss()
                } else if !puzzlePieces.isEmpty {
                    // 设置碎片图像到服务
                    puzzleService.setPuzzlePieces(puzzlePieces)
                    
                    // 完成拍摄，分析结果
                    _ = puzzleService.analyzeAllPieces()
                    
                    // 关闭当前视图，结果会自动显示
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("开始定位")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(!puzzlePieces.isEmpty || !puzzleService.puzzlePieceImages.isEmpty ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(puzzlePieces.isEmpty && puzzleService.puzzlePieceImages.isEmpty)
        }
        .padding(.horizontal)
    }
    
    private var tipTextView: some View {
        Text("提示：碎片照片越清晰，定位越准确")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom)
    }
    
    // MARK: - 辅助方法
    
    private func createActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("选择图片来源"),
            buttons: [
                .default(Text("拍照")) {
                    checkCameraPermission { granted in
                        if granted {
                            self.sourceType = .camera
                            self.showingImagePicker = true
                        } else {
                            // 如果相机权限被拒绝，使用照片库
                            self.sourceType = .photoLibrary
                            self.showingImagePicker = true
                        }
                    }
                },
                .default(Text("从相册选择")) {
                    self.sourceType = .photoLibrary
                    self.showingImagePicker = true
                },
                .cancel()
            ]
        )
    }
    
    private func createImagePicker() -> ImagePicker {
        // 在创建ImagePicker前检查相机可用性
        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera) {
            // 如果相机不可用，自动切换到照片库
            sourceType = .photoLibrary
            // 显示提示信息
            alertTitle = "相机不可用"
            alertMessage = "您的设备不支持相机，已自动切换到照片库"
            showAlert = true
        }
        
        return ImagePicker(selectedImage: Binding<UIImage?>(
            get: { nil },
            set: { newImage in
                if let image = newImage {
                    // 添加到本地数组
                    puzzlePieces.append(image)
                    
                    // 同时添加到服务
                    puzzleService.addPuzzlePiece(image)
                }
            }
        ), sourceType: sourceType)
    }
    
    var resultDestination: some View {
        // 使用已注入的环境对象
        ResultView()
    }
} 