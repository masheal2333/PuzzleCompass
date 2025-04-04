import SwiftUI

/// Toast view for displaying temporary messages
struct ToastView: View {
    let message: String
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.7))
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            
            // Text
            Text(message)
                .font(.mediumText)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 100, maxWidth: 300)
        .padding(.horizontal, 20)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

/// Toast container view that manages multiple toasts
struct ToastContainer: View {
    @Binding var isVisible: Bool
    let message: String?
    
    var body: some View {
        if isVisible, let message = message {
            VStack {
                Spacer().frame(height: 60)
                
                ToastView(message: message)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut, value: isVisible)
                
                Spacer()
            }
            .zIndex(100) // Ensure it's on top of everything
        }
    }
}

#Preview {
    ToastView(message: "Photo captured successfully")
} 