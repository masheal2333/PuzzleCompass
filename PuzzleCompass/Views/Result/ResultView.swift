import SwiftUI

/// View for displaying puzzle matching results
struct ResultView: View {
    @EnvironmentObject var appState: AppState
    
    // Selected piece index for highlighting
    @State private var selectedPieceIndex: Int?
    
    // Zoom scale for the puzzle image
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastZoomScale: CGFloat = 1.0
    
    // Drag offset for the puzzle image
    @State private var dragOffset: CGSize = .zero
    @State private var lastDragOffset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button(action: {
                    appState.navigateToMain()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(L10n.backToMain)
                    }
                    .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(L10n.results)
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // Share functionality would go here
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color.background)
            
            // Main content
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Puzzle image with matches
                    puzzleImageView
                        .padding(.top)
                    
                    // Piece thumbnails
                    pieceScrollView
                        .frame(height: 120)
                        .padding(.vertical)
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            // Navigate to camera to capture more pieces
                            appState.cameraMode = .piece
                            appState.navigateToCameraScreen(mode: .piece)
                        }) {
                            Text(L10n.captureMore)
                                .font(.mediumButton)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.primary)
                                )
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Puzzle image with match highlights
    private var puzzleImageView: some View {
        GeometryReader { geometry in
            if let puzzleImage = appState.getPuzzleImage() {
                ZStack {
                    // Puzzle image
                    Image(uiImage: puzzleImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(zoomScale)
                        .offset(dragOffset)
                        .gesture(
                            // Magnification gesture for zooming
                            MagnificationGesture()
                                .onChanged { value in
                                    zoomScale = max(1.0, lastZoomScale * value)
                                }
                                .onEnded { value in
                                    lastZoomScale = zoomScale
                                }
                        )
                        .gesture(
                            // Drag gesture for panning
                            DragGesture()
                                .onChanged { value in
                                    if zoomScale > 1.0 {
                                        dragOffset = CGSize(
                                            width: lastDragOffset.width + value.translation.width,
                                            height: lastDragOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { value in
                                    lastDragOffset = dragOffset
                                }
                        )
                        .gesture(
                            // Double tap gesture for resetting zoom
                            TapGesture(count: 2)
                                .onEnded {
                                    withAnimation {
                                        zoomScale = 1.0
                                        lastZoomScale = 1.0
                                        dragOffset = .zero
                                        lastDragOffset = .zero
                                    }
                                }
                        )
                    
                    // Match highlights
                    ForEach(appState.matchResults.indices, id: \.self) { resultIndex in
                        let result = appState.matchResults[resultIndex]
                        
                        if selectedPieceIndex == resultIndex || selectedPieceIndex == nil {
                            ForEach(result.matches.indices, id: \.self) { matchIndex in
                                let match = result.matches[matchIndex]
                                
                                // Calculate position in the view
                                let imageSize = puzzleImage.size
                                let imageWidth = min(geometry.size.width, geometry.size.height * imageSize.width / imageSize.height)
                                let imageHeight = imageWidth * imageSize.height / imageSize.width
                                
                                let scale = imageWidth / imageSize.width
                                
                                let x = match.rect.origin.x * scale * zoomScale + dragOffset.width
                                let y = match.rect.origin.y * scale * zoomScale + dragOffset.height
                                let width = match.rect.width * scale * zoomScale
                                let height = match.rect.height * scale * zoomScale
                                
                                Rectangle()
                                    .strokeBorder(
                                        selectedPieceIndex == resultIndex ? Color.green : Color.yellow,
                                        lineWidth: 3
                                    )
                                    .frame(width: width, height: height)
                                    .position(
                                        x: imageWidth/2 + x - imageWidth/2 + width/2,
                                        y: imageHeight/2 + y - imageHeight/2 + height/2
                                    )
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                // Fallback if no puzzle image
                Text(L10n.error)
                    .font(.mediumText)
                    .foregroundColor(.primary)
            }
        }
    }
    
    // Piece thumbnails scroll view
    private var pieceScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All pieces button
                AllPiecesThumbnailView(
                    totalMatchCount: appState.matchResults.flatMap { $0.matches }.count,
                    isSelected: selectedPieceIndex == nil,
                    action: {
                        withAnimation {
                            selectedPieceIndex = nil
                        }
                    }
                )
                .padding(.leading)
                
                // Piece thumbnails
                ForEach(appState.matchResults.indices, id: \.self) { index in
                    let result = appState.matchResults[index]
                    
                    PieceThumbnailView(
                        image: result.pieceImage,
                        matchCount: result.matches.count,
                        isSelected: selectedPieceIndex == index,
                        action: {
                            withAnimation {
                                if selectedPieceIndex == index {
                                    // Deselect if already selected
                                    selectedPieceIndex = nil
                                } else {
                                    selectedPieceIndex = index
                                }
                            }
                        }
                    )
                }
                .padding(.trailing)
            }
        }
    }
} 