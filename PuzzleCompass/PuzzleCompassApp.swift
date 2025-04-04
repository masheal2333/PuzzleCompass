//
//  PuzzleCompassApp.swift
//  PuzzleCompass
//
//  Created by Sheng Ma on 4/3/25.
//

import SwiftUI

@main
struct PuzzleCompassApp: App {
    // Application state
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
