//
//  ContentView.swift
//  PuzzleCompass
//
//  Created by Sheng Ma on 4/3/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var puzzleService: PuzzleService
    @State private var showResult = false
    
    var body: some View {
        NavigationView {
            MainScreen()
                .environmentObject(puzzleService)
                .fullScreenCover(isPresented: $showResult) {
                    ResultView()
                        .environmentObject(puzzleService)
                }
                // 注意：iOS 16.6的onChange API与iOS 17+有所不同
                .onReceive(puzzleService.$analysisResults) { results in
                    if !results.isEmpty {
                        showResult = true
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PuzzleService())
    }
}
