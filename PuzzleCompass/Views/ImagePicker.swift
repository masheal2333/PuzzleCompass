import SwiftUI
import AVFoundation

// 图片选择器 - UIViewControllerRepresentable
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // 检查相机权限和可用性
        if sourceType == .camera {
            // 首先检查设备是否有相机
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                // 设备没有相机，切换到照片库
                print("设备不支持相机，切换到照片库")
                picker.sourceType = .photoLibrary
                return picker
            }
            
            // 检查相机权限
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if authStatus == .denied || authStatus == .restricted {
                alertTitle = "相机访问受限"
                alertMessage = "请前往设置允许PuzzleCompass访问您的相机"
                showAlert = true
                // 由于无法访问相机，改为使用照片库
                picker.sourceType = .photoLibrary
            } else {
                picker.sourceType = sourceType
            }
        } else {
            picker.sourceType = sourceType
        }
        
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 添加错误处理
            do {
                if let editedImage = info[.editedImage] as? UIImage {
                    parent.selectedImage = editedImage
                } else if let originalImage = info[.originalImage] as? UIImage {
                    parent.selectedImage = originalImage
                }
            } catch {
                print("处理照片时出错: \(error.localizedDescription)")
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 