import SwiftUI
import AVFoundation

// Image Picker - UIViewControllerRepresentable
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
        
        // Check camera permissions and availability
        if sourceType == .camera {
            // First check if the device has a camera
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                // Device doesn't have a camera, switch to photo library
                print("Device doesn't support camera, switching to photo library")
                picker.sourceType = .photoLibrary
                return picker
            }
            
            // Check camera permissions
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if authStatus == .denied || authStatus == .restricted {
                alertTitle = "Camera Access Restricted"
                alertMessage = "Please go to Settings and allow PuzzleCompass to access your camera"
                showAlert = true
                // Since camera can't be accessed, use photo library instead
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
            // Process photo selection
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let imageData = info[.originalImage] as? UIImage {
                parent.selectedImage = imageData
            }
            
            // Close the picker
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 