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

class PuzzleService: ObservableObject {
    @Published var completePuzzleImage: UIImage?
    @Published var puzzlePieceImages: [UIImage] = []
    @Published var analysisResults: [PieceAnalysisResult] = []
    @Published var recentAnalyses: [PuzzleAnalysis] = []
    
    // 设置完整拼图
    func setCompletePuzzle(_ image: UIImage) {
        // 自动扣取完整拼图逻辑
        let processedImage = processCompletePuzzle(image)
        self.completePuzzleImage = processedImage
    }
    
    // 设置拼图碎片
    func setPuzzlePieces(_ images: [UIImage]) {
        self.puzzlePieceImages = images
    }
    
    // 添加单个拼图碎片
    func addPuzzlePiece(_ image: UIImage) {
        self.puzzlePieceImages.append(image)
        
        // 如果已有完整拼图，则自动分析新添加的碎片
        if let _ = completePuzzleImage {
            // 先清除之前的分析结果，然后分析所有碎片，确保结果页面能正确显示
            analysisResults = []
            for pieceImage in puzzlePieceImages {
                let result = analyzePosition(for: pieceImage)
                analysisResults.append(result)
            }
            
            // 保存本次分析到最近记录
            saveAnalysisToHistory()
        }
    }
    
    // 分析拼图碎片位置
    func analyzeAllPieces() -> [PieceAnalysisResult] {
        guard let completePuzzle = completePuzzleImage, !puzzlePieceImages.isEmpty else {
            return []
        }
        
        // 清空之前的分析结果
        analysisResults = []
        
        // 分析每个碎片
        for (index, pieceImage) in puzzlePieceImages.enumerated() {
            let result = analyzePosition(for: pieceImage)
            analysisResults.append(result)
        }
        
        // 保存本次分析到最近记录
        saveAnalysisToHistory()
        
        return analysisResults
    }
    
    // 保存分析记录
    private func saveAnalysisToHistory() {
        guard let completePuzzle = completePuzzleImage, !puzzlePieceImages.isEmpty else {
            return
        }
        
        let newAnalysis = PuzzleAnalysis(
            completePuzzleImage: completePuzzle,
            pieceImages: puzzlePieceImages,
            date: Date()
        )
        
        // 添加到最近记录
        recentAnalyses.insert(newAnalysis, at: 0)
        
        // 限制保存的数量
        if recentAnalyses.count > 10 {
            recentAnalyses = Array(recentAnalyses.prefix(10))
        }
    }
    
    // 处理完整拼图（自动扣取）
    private func processCompletePuzzle(_ image: UIImage) -> UIImage {
        // 在实际应用中，这里应该实现拼图边缘检测和自动扣取
        // 这里简单返回原图，真实应用中需要替换为图像处理逻辑
        return image
    }
    
    // 分析碎片位置（示例逻辑）
    private func analyzePosition(for pieceImage: UIImage) -> PieceAnalysisResult {
        // 在实际应用中，这里应该实现图像识别和位置匹配算法
        // 以下仅为示例数据
        
        // 随机生成位置（实际应用中应该是真实的匹配算法）
        let randomX = CGFloat.random(in: 0.1...0.9)
        let randomY = CGFloat.random(in: 0.1...0.9)
        let randomWidth = CGFloat.random(in: 0.05...0.2)
        let randomHeight = CGFloat.random(in: 0.05...0.2)
        
        let relativePosition = CGRect(
            x: randomX,
            y: randomY,
            width: randomWidth,
            height: randomHeight
        )
        
        // 置信度（实际应用中应该是真实的匹配准确度）
        let confidence = Double.random(in: 0.7...0.99)
        
        return PieceAnalysisResult(
            pieceImage: pieceImage,
            relativePosition: relativePosition,
            confidence: confidence
        )
    }
}

// 碎片分析结果
struct PieceAnalysisResult: Identifiable, Equatable {
    let id = UUID()
    let pieceImage: UIImage
    
    // 在完整拼图中的相对位置（范围0-1）
    let relativePosition: CGRect
    
    // 匹配置信度（0-1）
    let confidence: Double
    
    // 匹配置信度的可读性表示
    var confidenceString: String {
        let percentage = Int(confidence * 100)
        return "\(percentage)%"
    }
    
    // 颜色表示置信度
    var confidenceColor: Color {
        if confidence >= 0.9 {
            return .green
        } else if confidence >= 0.7 {
            return .yellow
        } else {
            return .orange
        }
    }
    
    // Equatable实现
    static func == (lhs: PieceAnalysisResult, rhs: PieceAnalysisResult) -> Bool {
        return lhs.id == rhs.id
    }
} 