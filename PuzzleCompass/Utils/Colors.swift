import SwiftUI

/// Color system for the PuzzleCompass app
struct AppColors {
    // Main colors
    static let primary = Color(hex: "4A90E2")
    static let accent = Color(hex: "50E3C2")
    static let background = Color(hex: "F7F7F7")
    static let text = Color(hex: "333333")
    static let secondaryBackground = Color(hex: "EFEFEF")
    
    // Status colors
    static let success = Color(hex: "27AE60")
    static let error = Color(hex: "E74C3C")
    static let warning = Color(hex: "F39C12")
    
    // Highlight colors for pieces
    static let pieceHighlights: [Color] = [
        Color(hex: "FF5252"),  // Red
        Color(hex: "4CAF50"),  // Green
        Color(hex: "2196F3"),  // Blue
        Color(hex: "FF9800"),  // Orange
        Color(hex: "9C27B0"),  // Purple
        Color(hex: "00BCD4"),  // Cyan
        Color(hex: "FFEB3B"),  // Yellow
        Color(hex: "795548"),  // Brown
    ]
}

// Extension to support hex color initialization
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Extension to SwiftUI Color to make our colors accessible in SwiftUI views
extension Color {
    static let primary = AppColors.primary
    static let accent = AppColors.accent
    static let background = AppColors.background
    static let textColor = AppColors.text
    static let secondaryBackground = AppColors.secondaryBackground
    static let success = AppColors.success
    static let error = AppColors.error
    static let warning = AppColors.warning
} 