//
//  PuzzleCompassApp.swift
//  PuzzleCompass
//
//  Created by Sheng Ma on 4/3/25.
//

import SwiftUI

@main
struct PuzzleCompassApp: App {
    @StateObject private var puzzleService = PuzzleService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(puzzleService)
        }
    }
}
