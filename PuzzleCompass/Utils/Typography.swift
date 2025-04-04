import SwiftUI

/// Typography system for the PuzzleCompass app
struct AppTypography {
    // Title fonts
    static let title = Font.system(.title, design: .default).weight(.bold)
    
    // Heading fonts
    static let heading = Font.system(.headline, design: .default)
    
    // Body fonts
    static let body = Font.system(.body, design: .default)
    
    // Caption fonts
    static let caption = Font.system(.caption, design: .default)
    
    // Based on design specs
    static let titleFont = Font.system(size: 17, weight: .bold, design: .default)
    static let bodyFont = Font.system(size: 14, weight: .regular, design: .default)
    static let smallFont = Font.system(size: 12, weight: .regular, design: .default)
    
    // Font sizes
    enum Size {
        static let small: CGFloat = 12
        static let regular: CGFloat = 14
        static let medium: CGFloat = 16
        static let large: CGFloat = 17
        static let xlarge: CGFloat = 20
    }
}

// Extension to SwiftUI Font to make our fonts accessible in SwiftUI views
extension Font {
    static let appTitle = AppTypography.title
    static let appHeading = AppTypography.heading
    static let appBody = AppTypography.body
    static let appCaption = AppTypography.caption
    
    // Specific fonts from design spec
    static let titleFont = AppTypography.titleFont
    static let bodyFont = AppTypography.bodyFont
    static let smallFont = AppTypography.smallFont
}

// Extension for Text styles
extension Text {
    func titleStyle() -> some View {
        self
            .font(.largeTitle)
            .foregroundColor(.textColor)
    }
    
    func bodyStyle() -> some View {
        self
            .font(.mediumText)
            .foregroundColor(.textColor)
    }
    
    func captionStyle() -> some View {
        self
            .font(.smallFont)
            .foregroundColor(.textColor.opacity(0.7))
    }
} 