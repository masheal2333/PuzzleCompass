import SwiftUI
import AVFoundation

// 权限工具类
struct PermissionUtils {
    // 检查并请求相机权限
    static func checkCameraPermission(completion: @escaping (Bool, String, String) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true, "", "")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        completion(true, "", "")
                    } else {
                        completion(false, "相机访问受限", "请前往设置允许PuzzleCompass访问您的相机")
                    }
                }
            }
        case .denied, .restricted:
            completion(false, "相机访问受限", "请前往设置允许PuzzleCompass访问您的相机")
        @unknown default:
            completion(false, "权限状态未知", "无法确定相机权限状态")
        }
    }
    
    // 提供跳转到应用设置的方法
    static func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
} 