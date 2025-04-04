import UIKit

/// Match position in the puzzle
struct MatchPosition {
    /// The rectangle where the piece is positioned in the puzzle
    let rect: CGRect
    
    /// Match confidence (0.0 to 1.0)
    let confidence: Double
}

/// Result of matching a piece to the puzzle
struct MatchResult {
    /// The piece image that was matched
    let pieceImage: UIImage
    
    /// Positions where the piece was matched in the puzzle
    let matches: [MatchPosition]
    
    /// Identifier for the piece
    let id: Int
} 