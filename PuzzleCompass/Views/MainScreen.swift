import SwiftUI

struct MainScreen: View {
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var captureMode: CaptureMode = .completePuzzle
    @EnvironmentObject var puzzleService: PuzzleService
    
    enum CaptureMode {
        case completePuzzle, puzzlePiece
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("拼图定位")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // 主按钮区域
                VStack(spacing: 16) {
                    ActionButton(
                        title: "拍摄完整拼图",
                        systemImage: "camera.viewfinder",
                        color: .blue
                    ) {
                        captureMode = .completePuzzle
                        showCamera = true
                    }
                    
                    ActionButton(
                        title: "从相册选择",
                        systemImage: "photo.on.rectangle",
                        color: .green
                    ) {
                        showPhotoLibrary = true
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 30)
                
                // 最近分析记录
                if !puzzleService.recentAnalyses.isEmpty {
                    VStack(alignment: .leading) {
                        Text("最近分析")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(puzzleService.recentAnalyses) { analysis in
                                    RecentAnalysisCard(analysis: analysis)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
            }
            .sheet(isPresented: $showCamera) {
                CameraView(captureMode: captureMode)
                    .environmentObject(puzzleService)
            }
            .sheet(isPresented: $showPhotoLibrary) {
                PhotoPicker()
                    .environmentObject(puzzleService)
            }
            .navigationBarItems(trailing: Button(action: {
                // 打开设置
            }) {
                Image(systemName: "gear")
                    .foregroundColor(.primary)
            })
            .onAppear {
                setupNotifications()
            }
            .onDisappear {
                // 清理通知监听
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    // 设置通知监听
    private func setupNotifications() {
        // 监听拍摄碎片通知
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CaptureMode.pieceCapture"),
            object: nil,
            queue: .main) { _ in
                captureMode = .puzzlePiece
                // 延迟一小段时间，确保前一个视图已经消失
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showCamera = true
                }
            }
    }
}

struct ActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(title)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(color.opacity(0.7))
            }
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct RecentAnalysisCard: View {
    let analysis: PuzzleAnalysis
    
    var body: some View {
        VStack {
            Image(uiImage: analysis.thumbnailImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 90)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text(analysis.dateFormatted)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
            .environmentObject(PuzzleService())
    }
} 