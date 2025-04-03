import SwiftUI
import PhotosUI

struct PhotoPicker: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isSelectionComplete = false
    @State private var showProcessing = false
    
    // 数据管理服务
    @EnvironmentObject var puzzleService: PuzzleService
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("选择照片")
                .font(.headline)
                .padding(.top)
            
            // 提示文字
            Text("请选择完整拼图和拼图碎片的照片\n第一张被视为完整拼图，其余为碎片")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 选择器
            PhotosPicker(
                selection: $selectedItems,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("从相册中选择照片", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            
            // 已选照片预览
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            VStack {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                
                                // 显示标签，区分完整拼图和碎片
                                Text(index == 0 ? "完整拼图" : "碎片\(index)")
                                    .font(.caption2)
                                    .foregroundColor(index == 0 ? .blue : .secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 确认按钮
                Button(action: {
                    showProcessing = true
                    
                    // 处理照片 - 符合"自动识别并分析"的动线
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if selectedImages.count >= 2 {
                            // 第一张是完整拼图，其余是碎片
                            let completePuzzle = selectedImages[0]
                            let pieces = Array(selectedImages.dropFirst())
                            
                            // 设置完整拼图和碎片
                            puzzleService.setCompletePuzzle(completePuzzle)
                            puzzleService.setPuzzlePieces(pieces)
                            
                            // 分析所有碎片
                            puzzleService.analyzeAllPieces()
                            
                            isSelectionComplete = true
                        } else if selectedImages.count == 1 {
                            // 只有一张图片时，视为完整拼图
                            puzzleService.setCompletePuzzle(selectedImages[0])
                            
                            // 发送拍摄碎片通知，符合设计动线
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                NotificationCenter.default.post(name: NSNotification.Name("CaptureMode.pieceCapture"), object: nil)
                                isSelectionComplete = true
                            }
                        }
                        
                        showProcessing = false
                    }
                }) {
                    Text("确认并分析")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedImages.count < 1 ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(selectedImages.isEmpty)
                .opacity(selectedImages.isEmpty ? 0.5 : 1)
            }
            
            Spacer()
            
            // 取消按钮
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("取消")
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)
        }
        .onChange(of: selectedItems) { newItems in
            Task {
                selectedImages = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImages.append(uiImage)
                    }
                }
            }
        }
        .overlay(
            Group {
                if showProcessing {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .overlay(
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                
                                Text("正在分析图片...")
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                            }
                        )
                }
            }
        )
        .onChange(of: isSelectionComplete) { complete in
            if complete {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct PhotoPicker_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPicker()
            .environmentObject(PuzzleService())
    }
} 