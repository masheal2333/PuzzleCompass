import Foundation

/// Localization helper
struct L10n {
    // App general
    static let appName = NSLocalizedString("PuzzleCompass", comment: "App name")
    static let ok = NSLocalizedString("OK", comment: "OK button")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel button")
    static let confirm = NSLocalizedString("Confirm", comment: "Confirm button")
    static let error = NSLocalizedString("Error", comment: "Error title")
    static let unknownError = NSLocalizedString("An unknown error occurred", comment: "Unknown error message")
    
    // Main screen
    static let takePicture = NSLocalizedString("Capture with Camera", comment: "Take picture button")
    static let selectFromAlbum = NSLocalizedString("Select from Album", comment: "Select from album button")
    static let mainScreenTitle = NSLocalizedString("Puzzle Compass", comment: "Main screen title")
    static let mainScreenPrompt = NSLocalizedString("Choose a method to identify puzzle pieces", comment: "Main screen prompt")
    static let mainCapturePuzzle = NSLocalizedString("Capture Complete Puzzle", comment: "Main screen capture puzzle button")
    static let mainCapturePuzzleDescription = NSLocalizedString("Take a photo of the assembled puzzle or box image", comment: "Main screen capture puzzle description")
    
    // Camera
    static let shootPuzzle = NSLocalizedString("Shoot Complete Puzzle", comment: "Shoot puzzle")
    static let shootPieces = NSLocalizedString("Shoot Puzzle Pieces", comment: "Shoot pieces")
    static let capturePhoto = NSLocalizedString("Capture", comment: "Capture photo")
    static let switchCamera = NSLocalizedString("Switch Camera", comment: "Switch camera")
    static let positionPuzzle = NSLocalizedString("Position the puzzle inside the frame", comment: "Position puzzle")
    static let positionPiece = NSLocalizedString("Position the piece inside the frame", comment: "Position piece")
    static let cameraPermissionDenied = NSLocalizedString("Please allow camera access in Settings", comment: "Camera permission denied")
    static let nowCapturePieces = NSLocalizedString("Now capture puzzle pieces", comment: "Now capture pieces")
    
    // Photo picker
    static let selectPhotos = NSLocalizedString("Select Photos", comment: "Select photos")
    static let selectPuzzle = NSLocalizedString("Select Puzzle", comment: "Select puzzle")
    static let selectPieces = NSLocalizedString("Select Pieces", comment: "Select pieces")
    static let selectPuzzlePrompt = NSLocalizedString("Please select a complete puzzle photo", comment: "Select puzzle prompt")
    static let selectPiecesPrompt = NSLocalizedString("Please select puzzle piece photos (up to 10)", comment: "Select pieces prompt")
    static let selectOnlyOnePuzzle = NSLocalizedString("You can only select one puzzle photo", comment: "Select only one puzzle")
    
    // Confirmation
    static let confirmPuzzle = NSLocalizedString("Confirm Puzzle Photo", comment: "Confirm puzzle")
    static let confirmPieces = NSLocalizedString("Confirm Piece Photos", comment: "Confirm pieces")
    static let retake = NSLocalizedString("Retake", comment: "Retake button")
    static let puzzleConfirmationPrompt = NSLocalizedString("Please confirm the puzzle photo is clear and visible", comment: "Puzzle confirmation prompt")
    static let pieceConfirmationPrompt = NSLocalizedString("Please confirm the piece photo is clear and visible", comment: "Piece confirmation prompt")
    
    // Image processing
    static let processing = NSLocalizedString("Processing...", comment: "Processing message")
    static let analyzing = NSLocalizedString("Analyzing...", comment: "Analyzing message")
    static let puzzleRecognitionFailed = NSLocalizedString("Puzzle recognition failed, please try again", comment: "Puzzle recognition failed")
    static let pieceRecognitionFailed = NSLocalizedString("Piece recognition failed, please try again", comment: "Piece recognition failed")
    
    // Results
    static let results = NSLocalizedString("Results", comment: "Results title")
    static let noMatches = NSLocalizedString("No matches found", comment: "No matches")
    static let matchFound = NSLocalizedString("Match found", comment: "Match found")
    static let matchesFound = NSLocalizedString("%d matches found", comment: "Matches found")
    static let captureMore = NSLocalizedString("Capture More", comment: "Capture more")
    static let backToMain = NSLocalizedString("Back to Main", comment: "Back to main")
    static let shareResult = NSLocalizedString("Share Result", comment: "Share result")
} 