import SwiftUI

// Help guide view
struct HelpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Use Puzzle Compass")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    featuresSection
                    
                    Divider()
                    
                    tipsSection
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .fontWeight(.semibold)
                }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Subview Components
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("•")
                Text("Colored frames indicate piece locations in the complete puzzle")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("Tap a piece thumbnail to highlight its matching location")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("Pinch to zoom in or out of the puzzle view")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("Drag to move around the puzzle view")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("Tap \"Reset\" button to restore the original view")
            }
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(alignment: .top) {
                Text("•")
                Text("Clearer puzzle photos lead to more accurate recognition")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("Well-lit environments produce the best results")
            }
            
            HStack(alignment: .top) {
                Text("•")
                Text("Avoid shadows and reflections when taking photos")
            }
        }
    }
} 