import SwiftUI
import PhotosUI

struct PhotoPicker: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isSelectionComplete = false
    @State private var showProcessing = false
    
    // Data management service
    @EnvironmentObject var puzzleService: PuzzleService
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text(L10n.selectPhotos)
                .font(.headline)
                .padding(.top)
            
            // Prompt text
            Text(L10n.selectPuzzlePrompt)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Picker
            PhotosPicker(
                selection: $selectedItems,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label(L10n.selectPhotos, systemImage: "photo.on.rectangle")
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
            
            // Selected photos preview
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
                                
                                // Display label, distinguish complete puzzle and pieces
                                Text(index == 0 ? L10n.selectPuzzle : "\(L10n.selectPieces) \(index)")
                                    .font(.caption2)
                                    .foregroundColor(index == 0 ? .blue : .secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Confirm button
                Button(action: {
                    showProcessing = true
                    
                    // Process photos - follows the "automatic recognition and analysis" flow
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if selectedImages.count >= 2 {
                            // First image is complete puzzle, rest are pieces
                            let completePuzzle = selectedImages[0]
                            let pieces = Array(selectedImages.dropFirst())
                            
                            // Set complete puzzle and pieces
                            puzzleService.setCompletePuzzle(completePuzzle)
                            puzzleService.setPuzzlePieces(pieces)
                            
                            // Analyze all pieces
                            _ = puzzleService.analyzeAllPieces()
                            
                            isSelectionComplete = true
                        } else if selectedImages.count == 1 {
                            // If only one image, treat as complete puzzle
                            puzzleService.setCompletePuzzle(selectedImages[0])
                            
                            // Send capture piece notification, following design flow
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                NotificationCenter.default.post(name: NSNotification.Name("CaptureMode.pieceCapture"), object: nil)
                                isSelectionComplete = true
                            }
                        }
                        
                        showProcessing = false
                    }
                }) {
                    Text(L10n.confirm)
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
            
            // Cancel button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text(L10n.cancel)
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
                                
                                Text(L10n.analyzing)
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
        // Create an environment object for preview
        let mockService = PuzzleService()
        
        return VStack {
            Text(L10n.selectPhotos)
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(0..<9, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .padding()
            }
            
            Spacer()
            
            Button(action: {}) {
                Text(L10n.confirm)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .environmentObject(mockService)
        .previewDisplayName(L10n.selectPhotos)
    }
} 