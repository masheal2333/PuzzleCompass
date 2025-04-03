import SwiftUI

// 结果展示界面
struct ResultView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var puzzleService: PuzzleService
    
    // 支持直接传递数据的初始化方法
    init() {}
    
    init(fullPuzzleImage: UIImage, puzzlePieces: [UIImage]) {
        // 这个初始化器用于向后兼容，但实际上我们使用环境对象
    }
    
    @State private var selectedPieceIndex: Int? = nil
    @State private var showCamera = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完成")
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("分析结果")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // 分享功能
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
            
            // 结果显示区域
            ScrollView {
                if let completePuzzle = puzzleService.completePuzzleImage,
                   !puzzleService.analysisResults.isEmpty {
                    
                    // 完整拼图与匹配结果
                    VStack(alignment: .leading) {
                        Text("完整拼图")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // 显示完整拼图和匹配位置
                        CompleteWithPiecesView(
                            completePuzzle: completePuzzle,
                            results: puzzleService.analysisResults,
                            selectedPieceIndex: $selectedPieceIndex
                        )
                        .frame(height: 300)
                        .padding(.horizontal)
                        
                        // 匹配置信度信息
                        if let selectedIndex = selectedPieceIndex,
                           puzzleService.analysisResults.indices.contains(selectedIndex) {
                            let result = puzzleService.analysisResults[selectedIndex]
                            HStack {
                                Text("匹配置信度:")
                                    .font(.subheadline)
                                
                                Text(result.confidenceString)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(result.confidenceColor)
                            }
                            .padding(.horizontal)
                            .padding(.top, 5)
                        }
                        
                        Divider()
                            .padding(.vertical)
                        
                        // 碎片列表
                        Text("拼图碎片")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<puzzleService.analysisResults.count, id: \.self) { index in
                                    let result = puzzleService.analysisResults[index]
                                    
                                    PieceThumbView(
                                        image: result.pieceImage,
                                        isSelected: selectedPieceIndex == index,
                                        confidence: result.confidence
                                    )
                                    .frame(width: 80, height: 80)
                                    .onTapGesture {
                                        selectedPieceIndex = index
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 110)
                        
                        // 添加更多碎片按钮
                        Button {
                            showCamera = true
                        } label: {
                            HStack {
                                Image(systemName: "camera")
                                Text("添加更多碎片")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                    .padding(.bottom, 30)
                } else {
                    // 无数据状态
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                            .padding(.top, 50)
                        
                        Text("没有有效的分析结果")
                            .font(.headline)
                        
                        Text("请确保已上传完整拼图和至少一个拼图碎片")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("返回主界面")
                                .fontWeight(.medium)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView(captureMode: .puzzlePiece)
                .environmentObject(puzzleService)
        }
        .onAppear {
            // 确保有分析结果
            if puzzleService.analysisResults.isEmpty && 
               puzzleService.completePuzzleImage != nil && 
               !puzzleService.puzzlePieceImages.isEmpty {
                _ = puzzleService.analyzeAllPieces()
            }
            
            // 默认选中第一个碎片
            if !puzzleService.analysisResults.isEmpty {
                selectedPieceIndex = 0
            }
        }
    }
}

// 完整拼图和碎片位置视图
struct CompleteWithPiecesView: View {
    let completePuzzle: UIImage
    let results: [PieceAnalysisResult]
    @Binding var selectedPieceIndex: Int?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 完整拼图
                Image(uiImage: completePuzzle)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // 高亮标记
                ForEach(0..<results.count, id: \.self) { index in
                    let result = results[index]
                    let isSelected = selectedPieceIndex == index
                    
                    // 计算绝对位置和大小
                    let absoluteRect = CGRect(
                        x: result.relativePosition.origin.x * geometry.size.width,
                        y: result.relativePosition.origin.y * geometry.size.height,
                        width: result.relativePosition.width * geometry.size.width,
                        height: result.relativePosition.height * geometry.size.height
                    )
                    
                    Rectangle()
                        .path(in: absoluteRect)
                        .stroke(isSelected ? result.confidenceColor : Color.white.opacity(0.6), 
                                lineWidth: isSelected ? 3 : 1.5)
                        .background(
                            Rectangle()
                                .path(in: absoluteRect)
                                .fill(isSelected ? result.confidenceColor.opacity(0.2) : Color.clear)
                        )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 碎片缩略图
struct PieceThumbView: View {
    let image: UIImage
    let isSelected: Bool
    let confidence: Double
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected 
                            ? Color.blue.opacity(0.8) 
                            : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 3 : 1
                    )
                )
                .shadow(
                    color: isSelected ? Color.blue.opacity(0.4) : Color.clear, 
                    radius: 4, x: 0, y: 2
                )
            
            // 置信度指示器
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(confidenceColor)
                            .frame(width: 22, height: 22)
                        
                        Text("\(Int(confidence * 100))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(4)
                }
            }
        }
    }
    
    var confidenceColor: Color {
        if confidence >= 0.9 {
            return .green
        } else if confidence >= 0.7 {
            return .yellow
        } else {
            return .orange
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        let service = PuzzleService()
        // 添加示例数据
        
        return ResultView()
            .environmentObject(service)
    }
} 