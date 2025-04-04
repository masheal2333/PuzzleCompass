import Foundation
import SwiftUI
import Combine

// 拼图分析记录
struct PuzzleAnalysis: Identifiable {
    let id = UUID()
    let completePuzzleImage: UIImage
    let pieceImages: [UIImage]
    let date: Date
    
    var thumbnailImage: UIImage {
        return completePuzzleImage
    }
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// 简化版PuzzleService用于预览
class PuzzleService: ObservableObject {
    // 完整拼图图像
    @Published var completePuzzleImage: UIImage?
    
    // 拼图碎片图像
    @Published var puzzlePieceImages: [UIImage] = []
    
    // 分析结果
    @Published var analysisResults: [PieceAnalysisResult] = []
    
    // 初始化
    init() {
        print("初始化PuzzleService")
    }
    
    // 设置完整拼图
    func setCompletePuzzle(_ image: UIImage) {
        self.completePuzzleImage = image
    }
    
    // 设置拼图碎片
    func setPuzzlePieces(_ images: [UIImage]) {
        self.puzzlePieceImages = images
    }
    
    // 添加拼图碎片
    func addPuzzlePiece(_ image: UIImage) {
        self.puzzlePieceImages.append(image)
    }
    
    // 分析所有拼图碎片位置
    func analyzeAllPieces() -> [PieceAnalysisResult] {
        guard let _ = completePuzzleImage, !puzzlePieceImages.isEmpty else {
            return []
        }
        
        var analysisResults: [PieceAnalysisResult] = []
        
        // 分析每个碎片
        for (_, pieceImage) in puzzlePieceImages.enumerated() {
            let result = analyzePosition(for: pieceImage)
            analysisResults.append(result)
        }
        
        // 更新发布的结果
        self.analysisResults = analysisResults
        
        return analysisResults
    }
    
    // 分析单个碎片的位置
    private func analyzePosition(for pieceImage: UIImage) -> PieceAnalysisResult {
        // 在实际应用中,这里会有复杂的图像处理逻辑
        // 简化版本仅返回一个模拟结果
        return PieceAnalysisResult(
            pieceImage: pieceImage,
            position: CGPoint(x: 100, y: 100),
            rotation: 0.0,
            confidence: 0.9
        )
    }
}

// 拼图碎片分析结果
struct PieceAnalysisResult: Identifiable {
    let id = UUID()
    let pieceImage: UIImage
    let position: CGPoint
    let rotation: CGFloat
    let confidence: Double
} 