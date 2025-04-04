import SwiftUI

/// Represents the result of a puzzle piece matching analysis
struct AnalysisResult: Identifiable, Codable, Equatable {
    /// Unique identifier for the analysis result
    var id: UUID
    
    /// The puzzle that was analyzed
    var puzzle: Puzzle
    
    /// The pieces that were analyzed
    var pieces: [PuzzlePiece]
    
    /// The matching results for each piece
    var matches: [Match]
    
    /// Timestamp when the analysis was created
    var createdAt: Date
    
    /// Represents a single match between a piece and a location in the puzzle
    struct Match: Codable, Equatable, Identifiable {
        /// Unique identifier for this match
        var id: UUID
        
        /// The ID of the matched piece
        var pieceId: UUID
        
        /// The normalized rectangle in the puzzle where the piece was matched
        /// Values are in the range 0.0 to 1.0, representing percentages of puzzle dimensions
        var matchRect: CGRect
        
        /// Confidence score for the match (0.0 to 1.0)
        var confidence: Float
        
        /// Creates a new Match
        /// - Parameters:
        ///   - pieceId: The ID of the matched piece
        ///   - rect: The rectangle in the puzzle where the piece was matched
        ///   - confidence: Confidence score for the match
        init(pieceId: UUID, rect: CGRect, confidence: Float) {
            self.id = UUID()
            self.pieceId = pieceId
            self.matchRect = rect
            self.confidence = confidence
        }
        
        /// Coding keys for Codable conformance
        enum CodingKeys: String, CodingKey {
            case id, pieceId, matchRect, confidence
        }
        
        /// Custom encoder for CGRect
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(pieceId, forKey: .pieceId)
            try container.encode(confidence, forKey: .confidence)
            
            var rectContainer = container.nestedContainer(keyedBy: RectKeys.self, forKey: .matchRect)
            try rectContainer.encode(matchRect.origin.x, forKey: .x)
            try rectContainer.encode(matchRect.origin.y, forKey: .y)
            try rectContainer.encode(matchRect.width, forKey: .width)
            try rectContainer.encode(matchRect.height, forKey: .height)
        }
        
        /// Custom decoder for CGRect
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            pieceId = try container.decode(UUID.self, forKey: .pieceId)
            confidence = try container.decode(Float.self, forKey: .confidence)
            
            let rectContainer = try container.nestedContainer(keyedBy: RectKeys.self, forKey: .matchRect)
            let x = try rectContainer.decode(CGFloat.self, forKey: .x)
            let y = try rectContainer.decode(CGFloat.self, forKey: .y)
            let width = try rectContainer.decode(CGFloat.self, forKey: .width)
            let height = try rectContainer.decode(CGFloat.self, forKey: .height)
            matchRect = CGRect(x: x, y: y, width: width, height: height)
        }
        
        /// Keys for encoding/decoding CGRect
        enum RectKeys: String, CodingKey {
            case x, y, width, height
        }
        
        /// Equality check
        static func == (lhs: Match, rhs: Match) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    /// Creates a new AnalysisResult
    /// - Parameters:
    ///   - puzzle: The puzzle that was analyzed
    ///   - pieces: The pieces that were analyzed
    ///   - matches: The matching results for each piece
    init(puzzle: Puzzle, pieces: [PuzzlePiece], matches: [Match]) {
        self.id = UUID()
        self.puzzle = puzzle
        self.pieces = pieces
        self.matches = matches
        self.createdAt = Date()
    }
    
    /// Equality check
    static func == (lhs: AnalysisResult, rhs: AnalysisResult) -> Bool {
        lhs.id == rhs.id
    }
} 