import SwiftUI

/// Main screen with options for camera and album
struct MainScreen: View {
    // App state for managing navigation and data
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 30) {
            // App logo and title
            VStack(spacing: 20) {
                Image(systemName: "puzzlepiece.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text(L10n.appName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.top, 60)
            
            Spacer()
            
            // App description
            Text(L10n.mainScreenPrompt)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Main action buttons
            VStack(spacing: 20) {
                // Capture complete puzzle button
                Button(action: {
                    appState.cameraMode = .puzzle
                    appState.navigateToCameraScreen(mode: .puzzle)
                }) {
                    MainActionButton(
                        title: L10n.mainCapturePuzzle,
                        icon: "camera.fill",
                        description: L10n.mainCapturePuzzleDescription
                    )
                }
                
                // Capture puzzle pieces button
                Button(action: {
                    appState.cameraMode = .piece
                    appState.navigateToCameraScreen(mode: .piece)
                }) {
                    MainActionButton(
                        title: L10n.shootPieces,
                        icon: "camera.on.rectangle.fill",
                        description: L10n.positionPiece
                    )
                }
                
                // Select from album button
                Button(action: {
                    appState.cameraMode = .puzzle
                    appState.navigateToAlbumScreen(mode: .puzzle)
                }) {
                    MainActionButton(
                        title: L10n.selectFromAlbum,
                        icon: "photo.fill",
                        description: L10n.selectPhotos
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

/// Reusable button component for main actions
struct MainActionButton: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 30))
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
            
            // Text content
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Chevron icon
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock AppState, don't trigger real functionality
        let mockAppState = AppState()
        
        MainScreen()
            .environmentObject(mockAppState)
            .onAppear {
                // Disable any initialization that might cause preview crashes
            }
            .previewDisplayName("Main Screen")
    }
} 