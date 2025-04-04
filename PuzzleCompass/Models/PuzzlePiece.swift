import SwiftUI

/// Represents a puzzle piece image
struct PuzzlePiece: Identifiable, Codable, Equatable {
    /// Unique identifier for the piece
    var id: UUID
    
    /// The piece image data
    var image: Data
    
    /// Timestamp when the piece was created or captured
    var createdAt: Date
    
    /// Optional reference to the parent puzzle
    var puzzleId: UUID?
    
    /// The size of the image in points
    var imageSize: CGSize
    
    /// Creates a new PuzzlePiece with auto-generated UUID and current timestamp
    /// - Parameter image: The image data for the piece
    /// - Parameter size: The size of the image
    /// - Parameter puzzleId: Optional reference to the parent puzzle
    init(image: Data, size: CGSize, puzzleId: UUID? = nil) {
        self.id = UUID()
        self.image = image
        self.createdAt = Date()
        self.puzzleId = puzzleId
        self.imageSize = size
    }
    
    /// Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, image, createdAt, puzzleId, imageSize
    }
    
    /// Custom encoder for CGSize
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(image, forKey: .image)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(puzzleId, forKey: .puzzleId)
        
        var sizeContainer = container.nestedContainer(keyedBy: SizeKeys.self, forKey: .imageSize)
        try sizeContainer.encode(imageSize.width, forKey: .width)
        try sizeContainer.encode(imageSize.height, forKey: .height)
    }
    
    /// Custom decoder for CGSize
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        image = try container.decode(Data.self, forKey: .image)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        puzzleId = try container.decodeIfPresent(UUID.self, forKey: .puzzleId)
        
        let sizeContainer = try container.nestedContainer(keyedBy: SizeKeys.self, forKey: .imageSize)
        let width = try sizeContainer.decode(CGFloat.self, forKey: .width)
        let height = try sizeContainer.decode(CGFloat.self, forKey: .height)
        imageSize = CGSize(width: width, height: height)
    }
    
    /// Keys for encoding/decoding CGSize
    enum SizeKeys: String, CodingKey {
        case width, height
    }
    
    /// Equality check
    static func == (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool {
        lhs.id == rhs.id
    }
} 