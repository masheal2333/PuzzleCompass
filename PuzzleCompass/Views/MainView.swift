import SwiftUI

/// Main content view for the app
struct MainView: View {
    // App state for managing navigation and data
    @StateObject private var appState = AppState()
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            // Screen switching based on app state
            Group {
                switch appState.currentScreen {
                case .main:
                    MainScreen()
                        .environmentObject(appState)
                        .transition(.opacity)
                
                case .camera:
                    CameraView()
                        .environmentObject(appState)
                        .transition(.opacity)
                        .edgesIgnoringSafeArea(.all)
                
                case .album:
                    PhotoPickerView()
                        .environmentObject(appState)
                        .transition(.opacity)
                
                case .confirmation:
                    ConfirmationView()
                        .environmentObject(appState)
                        .transition(.opacity)
                        .edgesIgnoringSafeArea(.all)
                
                case .result:
                    ResultView()
                        .environmentObject(appState)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: appState.currentScreen)
            
            // Loading overlay
            if appState.isAnalyzing {
                LoadingView()
                    .transition(.opacity)
            }
        }
    }
}

/// Loading overlay view
struct LoadingView: View {
    var message: String = L10n.analyzing
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            // Loading indicator
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color(.systemGray6).opacity(0.8))
            .cornerRadius(20)
        }
    }
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock environment, avoid accessing camera during preview
        MainView()
            .previewDisplayName("Main View")
            .onAppear {
                // Disable any initializations that might cause issues
            }
    }
} 