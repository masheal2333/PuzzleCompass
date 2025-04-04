import Foundation
import SwiftUI
import Combine

/// Main navigation states for the app
enum AppScreen: String {
    case main = "Main"
    case camera = "Camera"
    case album = "Album"
    case result = "Result"
    case confirmation = "Confirmation"
}

/// Camera modes
enum CameraMode {
    case puzzle
    case piece
}

/// Camera source
enum CameraSource {
    case camera
    case album
}

/// Global application state
class AppState: ObservableObject {
    // Navigation
    @Published var currentScreen: AppScreen = .main
    
    // Camera state
    @Published var cameraMode: CameraMode = .puzzle
    @Published var cameraSource: CameraSource = .camera
    
    // Images
    @Published private var puzzleImage: UIImage?
    @Published private var pieceImages: [UIImage] = []
    
    // Processing state
    @Published var isAnalyzing: Bool = false
    
    // Results
    @Published var matchResults: [MatchResult] = []
    
    // Simplified initialization
    init() {
        // Basic initialization
    }
    
    // Image management
    func setPuzzleImage(_ image: UIImage) {
        self.puzzleImage = image
    }
    
    func getPuzzleImage() -> UIImage? {
        return puzzleImage
    }
    
    func hasPuzzleImage() -> Bool {
        return puzzleImage != nil
    }
    
    func addPieceImage(_ image: UIImage) {
        self.pieceImages.append(image)
    }
    
    func getPieceImages() -> [UIImage] {
        return pieceImages
    }
    
    // Navigation helper methods
    func navigateToCameraScreen(mode: CameraMode) {
        self.cameraMode = mode
        self.currentScreen = .camera
    }
    
    func navigateToMainScreen() {
        self.currentScreen = .main
    }
    
    func navigateToAlbumScreen(mode: CameraMode) {
        self.cameraMode = mode
        self.currentScreen = .album
    }
    
    func navigateToConfirmation(source: CameraSource) {
        self.cameraSource = source
        self.currentScreen = .confirmation
    }
    
    func navigateToMain() {
        self.currentScreen = .main
    }
    
    // Analysis
    func startAnalysis() {
        // Simplified version, only changes state
        self.isAnalyzing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isAnalyzing = false
            self.currentScreen = .result
        }
    }
} 