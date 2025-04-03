# PuzzleCompass

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![iOS](https://img.shields.io/badge/iOS-16.0%2B-green.svg)](https://developer.apple.com/ios/)

PuzzleCompass is an iOS application designed to help puzzle enthusiasts locate the position of puzzle pieces within a complete puzzle image. Using advanced image recognition, the app analyzes puzzle pieces and identifies their exact location in the complete puzzle.

![App Preview](docs/app_preview.png)

## Screenshots

*Note: Place screenshots here when available*

| Main Screen | Capturing Puzzle | Results View |
|:-----------:|:----------------:|:------------:|
| [Main]      | [Camera]         | [Results]    |

[Main]: docs/screenshots/main_screen.png "Main Screen"
[Camera]: docs/screenshots/camera_view.png "Camera View"
[Results]: docs/screenshots/results_view.png "Results View"

## Features
- **Complete Puzzle Capture**: Take a photo or select an image of your complete puzzle as a reference
- **Puzzle Piece Analysis**: Capture individual puzzle pieces to find their location
- **Automatic Matching**: The app automatically analyzes and identifies where each piece belongs
- **Visual Results**: Clear highlighting of piece positions with confidence indicators
- **Multiple Piece Support**: Analyze multiple pieces at once and see all their positions
- **Intuitive User Flow**: Streamlined process from capturing to results
- **Recent Analyses**: Save and access your recent puzzle analyses

## Technology
- Built with SwiftUI for a modern, responsive UI
- Uses image processing for piece detection and matching
- Implements native iOS camera and photo library integration
- Optimized for performance on iOS devices

## How to Use
1. **Capture Complete Puzzle**:
   - Launch the app and tap "Capture Complete Puzzle"
   - Take a photo of your complete puzzle
   - The app will automatically process the image

2. **Capture Puzzle Pieces**:
   - After capturing the complete puzzle, you'll be prompted to capture puzzle pieces
   - Take photos of individual pieces you want to locate
   - Each piece will be automatically analyzed

3. **View Results**:
   - See the exact position of each piece highlighted on the complete puzzle
   - Confidence indicators show how certain the match is
   - Add more pieces as needed by tapping "Add More Pieces"

4. **Alternative Workflow**:
   - Use "Select from Library" to choose both the complete puzzle and pieces at once
   - The first image is treated as the complete puzzle, and subsequent images as pieces

## Requirements
- iOS 16.0 or later
- iPhone with camera
- Internet connection for optimal performance

## Privacy
PuzzleCompass processes all images locally on your device. No photos are uploaded to external servers, ensuring complete privacy of your puzzle images.

## Support
For support or feedback, please contact us at [support@puzzlecompass.app](mailto:support@puzzlecompass.app)

## License
© 2025 PuzzleCompass. All rights reserved.

## Installation

### For Users
1. Download from the App Store (coming soon)
2. Or build from source following the developer instructions below

### For Developers
1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/PuzzleCompass.git
   cd PuzzleCompass
   ```

2. Open the project in Xcode
   ```bash
   open PuzzleCompass.xcodeproj
   ```

3. Configure signing in Xcode with your developer account

4. Build and run on your device or simulator
   - Note: Camera functionality requires a physical device

## Development

### Project Structure
- `Models/`: Contains data models and the PuzzleService
- `Views/`: UI components organized by screen
- `Extensions/`: Swift extensions for added functionality
- `Utilities/`: Helper functions and utility classes

### Key Components
- `PuzzleService`: Core service managing puzzle data and analysis
- `CameraView`: Camera interface for capturing images
- `ResultView`: Displays analysis results with interactive elements
- `MainScreen`: Entry point with main navigation options

### Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgements

- SwiftUI for the UI framework
- AVFoundation for camera functionality
- PhotosUI for photo library integration
- CoreImage for image processing

---

Made with ❤️ for puzzle lovers 