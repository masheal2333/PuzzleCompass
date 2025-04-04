import SwiftUI
import AVFoundation

// 完整拼图拍摄/上传界面
struct FullPuzzleView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var fullPuzzleImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showingActionSheet = false
    @State private var navigateToNextStep = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // 检查并请求相机权限
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        // 首先检查设备是否有相机
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertTitle = "相机不可用"
            alertMessage = "您的设备不支持相机，已自动切换到照片库"
            showAlert = true
            completion(false)
            return
        }
        
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
                    imagePreviewView
                    actionButtonsView
                    Spacer()
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
                ImagePicker(selectedImage: $fullPuzzleImage, sourceType: sourceType)
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
                    destination: pieceCapturePage,
                    isActive: $navigateToNextStep
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
            Text("拍摄完整拼图")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("请拍摄或上传已完成的拼图照片作为分析参考")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var imagePreviewView: some View {
        ZStack {
            if let image = fullPuzzleImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(Color.secondary.opacity(0.5))
                    .frame(height: 250)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("暂无图片")
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            // 拍照或从相册选择
            Button(action: {
                showingActionSheet = true
            }) {
                HStack {
                    Image(systemName: "camera")
                    Text(fullPuzzleImage == nil ? "拍摄/选择图片" : "更换图片")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // 继续按钮 - 仅当有图片时可用
            Button(action: {
                navigateToNextStep = true
            }) {
                HStack {
                    Image(systemName: "arrow.right")
                    Text("继续")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(fullPuzzleImage != nil ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(fullPuzzleImage == nil)
        }
        .padding(.horizontal)
    }
    
    private var tipTextView: some View {
        Text("提示：确保拼图照片清晰、光线充足")
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
    
    // 提供拼图碎片页面
    var pieceCapturePage: some View {
        // 直接返回PieceCaptureView，不需要dummyImage
        return PieceCaptureView()
    }
} 