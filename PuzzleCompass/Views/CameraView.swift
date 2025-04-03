import SwiftUI
import AVFoundation

struct CameraView: View {
    let captureMode: MainScreen.CaptureMode
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var puzzleService: PuzzleService
    @State private var showNextStep = false
    @State private var capturedImage: UIImage?
    @State private var showProcessingIndicator = false
    
    init(captureMode: MainScreen.CaptureMode) {
        self.captureMode = captureMode
    }
    
    var body: some View {
        ZStack {
            // 直接显示系统相机视图
            ImagePickerDirectView(
                captureMode: captureMode,
                onImageSelected: handleImageSelected,
                onCancel: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            // 处理指示器
            if showProcessingIndicator {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("正在处理...")
                                .foregroundColor(.white)
                                .padding(.top, 20)
                        }
                    )
            }
        }
        .alert(isPresented: $showNextStep) {
            // 根据tips中的设计动线，拍摄完整拼图后直接提示"现在拍摄碎片"
            Alert(
                title: Text("已保存完整拼图"),
                message: Text("现在请拍摄拼图碎片"),
                primaryButton: .default(Text("开始拍摄")) {
                    // 返回主屏幕，并触发拍摄碎片的操作
                    NotificationCenter.default.post(name: NSNotification.Name("CaptureMode.pieceCapture"), object: nil)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("返回")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // 处理选择的图像
    func handleImageSelected(_ image: UIImage?) {
        if let image = image {
            showProcessingIndicator = true
            capturedImage = image
            
            if captureMode == .completePuzzle {
                // 处理完整拼图
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    puzzleService.setCompletePuzzle(image)
                    showProcessingIndicator = false
                    // 显示提示，引导用户进入下一步
                    showNextStep = true
                }
            } else {
                // 处理拼图碎片
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    puzzleService.addPuzzlePiece(image)
                    showProcessingIndicator = false
                    // 分析完成，返回上一个界面
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } else {
            // 用户取消了拍摄，返回上一个界面
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// 这里保留预览提供者
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(captureMode: .completePuzzle)
            .environmentObject(PuzzleService())
    }
}

// 直接显示系统相机视图的组件
struct ImagePickerDirectView: UIViewControllerRepresentable {
    let captureMode: MainScreen.CaptureMode
    let onImageSelected: (UIImage?) -> Void
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // 默认使用相机，严格遵循"直接进入相机"的动线
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
            picker.showsCameraControls = true
        } else {
            // 如果相机不可用，才使用照片库作为备选
            print("警告：设备不支持相机，使用照片库作为备选")
            picker.sourceType = .photoLibrary
        }
        
        // 禁用编辑，直接使用原始图像
        picker.allowsEditing = false
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerDirectView
        
        init(_ parent: ImagePickerDirectView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 获取原始图像
            let image = info[.originalImage] as? UIImage
            
            // 打印图像信息以便调试
            if let image = image {
                print("成功获取图像: \(image.size.width) x \(image.size.height)")
            } else {
                print("无法获取图像")
            }
            
            // 回调返回图像
            parent.onImageSelected(image)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("用户取消了图像选择")
            parent.onCancel()
        }
    }
} 