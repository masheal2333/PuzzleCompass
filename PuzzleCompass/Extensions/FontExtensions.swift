import SwiftUI

/// Additional font extensions for the app
extension Font {
    /// Large title font
    static var largeTitle: Font {
        return .system(size: 28, weight: .bold, design: .rounded)
    }
    
    /// Subheading font
    static var subheading: Font {
        return .system(size: 20, weight: .bold, design: .rounded)
    }
    
    /// Medium text font
    static var mediumText: Font {
        return .system(size: 16, weight: .regular, design: .rounded)
    }
    
    /// Medium button font
    static var mediumButton: Font {
        return .system(size: 16, weight: .medium, design: .rounded)
    }
    
    /// Small caption font
    static var smallCaption: Font {
        return .system(size: 12, weight: .regular, design: .rounded)
    }
} 