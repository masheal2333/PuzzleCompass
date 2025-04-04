import SwiftUI

/// Guidance view for showing camera usage instructions
struct GuidanceView: View {
    // Camera mode
    let mode: CameraMode
    
    // Show state
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            VStack {
                // Banner
                ZStack {
                    // Background
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .frame(height: 80)
                    
                    HStack {
                        // Icon
                        Image(systemName: mode == .puzzle ? "puzzlepiece.fill" : "puzzlepiece")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        // Text
                        Text(guidanceText)
                            .font(.mediumText)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 8)
                        
                        Spacer()
                        
                        // Close button
                        Button(action: {
                            withAnimation {
                                isShowing = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding(.trailing)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
            }
            .transition(.move(edge: .top))
            .animation(.easeInOut, value: isShowing)
            .zIndex(100)
        }
    }
    
    // Get appropriate guidance text based on mode
    private var guidanceText: String {
        mode == .puzzle ? 
            "Make sure the entire puzzle is inside the frame and clearly visible" :
            "Position each piece in the center frame, one piece at a time"
    }
}

#Preview {
    GuidanceView(mode: .puzzle, isShowing: .constant(true))
} 