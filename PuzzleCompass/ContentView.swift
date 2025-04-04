//
//  ContentView.swift
//  PuzzleCompass
//
//  Created by Sheng Ma on 4/3/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            // Display main content
            MainContentView()
                .environmentObject(appState)
        }
    }
}

// Simplified main content view
struct MainContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            Text(L10n.appName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Image(systemName: "puzzlepiece.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Screen: \(appState.currentScreen.rawValue)")
                .padding()
            
            Button(action: {
                // Switch to camera view
                appState.navigateToCameraScreen(mode: .puzzle)
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text(L10n.capturePhoto)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

// Simplified preview, not dependent on environment objects
struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .previewDisplayName("Main Content")
    }
}
