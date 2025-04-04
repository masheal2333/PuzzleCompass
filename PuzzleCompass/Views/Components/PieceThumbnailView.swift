import SwiftUI

/// A thumbnail view for a puzzle piece with match count
struct PieceThumbnailView: View {
    let image: UIImage
    let matchCount: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    // Piece image
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Selection indicator
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.success, lineWidth: 3)
                            .frame(width: 80, height: 80)
                    }
                }
                
                // Match count
                Text(matchCountText)
                    .font(.smallCaption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(width: 80)
            }
        }
    }
    
    // Match count text based on the number of matches
    private var matchCountText: String {
        if matchCount == 0 {
            return L10n.noMatches
        } else if matchCount == 1 {
            return L10n.matchFound
        } else {
            return L10n.matchesFound.replacingOccurrences(of: "%d", with: String(matchCount))
        }
    }
}

/// A thumbnail view for all pieces with total match count
struct AllPiecesThumbnailView: View {
    let totalMatchCount: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.primary : Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "puzzlepiece.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                Text(L10n.matchesFound.replacingOccurrences(of: "%d", with: String(totalMatchCount)))
                    .font(.smallCaption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(width: 80)
            }
        }
    }
} 