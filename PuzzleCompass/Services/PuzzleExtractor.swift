import UIKit
import Vision

/// Service for extracting puzzle shapes from images
class PuzzleExtractor {
    
    /// Extract a puzzle from an image
    /// - Parameter image: The source image to extract from
    /// - Returns: The extracted puzzle image, or nil if extraction failed
    static func extract(from image: UIImage) async -> UIImage? {
        // Convert the UIImage to a CIImage
        guard let ciImage = CIImage(image: image) else {
            print("Failed to create CIImage from UIImage")
            return nil
        }
        
        // Try to detect rectangles in the image
        if let rectangleImage = await detectAndCropRectangle(in: ciImage, originalImage: image) {
            return rectangleImage
        }
        
        // If rectangle detection fails, return a cropped version of the original
        let croppedImage = cropCenterSquare(image: image)
        return croppedImage
    }
    
    /// Detect and crop a rectangle from an image
    /// - Parameters:
    ///   - ciImage: The CIImage to detect rectangles in
    ///   - originalImage: The original UIImage for fallback
    /// - Returns: The cropped and perspective-corrected image
    private static func detectAndCropRectangle(in ciImage: CIImage, originalImage: UIImage) async -> UIImage? {
        // Create a request to detect rectangles
        let request = VNDetectRectanglesRequest()
        request.minimumAspectRatio = 0.5
        request.maximumAspectRatio = 2.0
        request.minimumSize = 0.2
        request.maximumObservations = 1
        
        // Create a request handler
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            // Perform the rectangle detection
            try handler.perform([request])
            
            // Check if any rectangles were detected
            guard let results = request.results, let rectangle = results.first else {
                print("No rectangles detected")
                return nil
            }
            
            // Convert to UIImage with perspective correction
            return await correctPerspective(rectangle: rectangle, originalImage: originalImage)
            
        } catch {
            print("Rectangle detection failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Correct the perspective of a detected rectangle
    /// - Parameters:
    ///   - rectangle: The detected rectangle observation
    ///   - originalImage: The original image
    /// - Returns: The perspective-corrected image
    private static func correctPerspective(rectangle: VNRectangleObservation, originalImage: UIImage) async -> UIImage? {
        let imageSize = originalImage.size
        
        // Convert normalized coordinates to pixel coordinates
        let topLeft = CGPoint(x: rectangle.topLeft.x * imageSize.width, y: (1 - rectangle.topLeft.y) * imageSize.height)
        let topRight = CGPoint(x: rectangle.topRight.x * imageSize.width, y: (1 - rectangle.topRight.y) * imageSize.height)
        let bottomLeft = CGPoint(x: rectangle.bottomLeft.x * imageSize.width, y: (1 - rectangle.bottomLeft.y) * imageSize.height)
        let bottomRight = CGPoint(x: rectangle.bottomRight.x * imageSize.width, y: (1 - rectangle.bottomRight.y) * imageSize.height)
        
        // Calculate the width and height of the output rectangle
        let width = max(distance(from: topLeft, to: topRight), distance(from: bottomLeft, to: bottomRight))
        let height = max(distance(from: topLeft, to: bottomLeft), distance(from: topRight, to: bottomRight))
        
        // Create a new image context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Define the target rectangle
        let destinationPoints = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: width, y: 0),
            CGPoint(x: 0, y: height),
            CGPoint(x: width, y: height)
        ]
        
        // Define the source points
        let sourcePoints = [topLeft, topRight, bottomLeft, bottomRight]
        
        // Apply perspective transform
        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        
        let transform = perspectiveTransform(from: sourcePoints, to: destinationPoints)
        context.concatenate(transform)
        
        // Draw the image
        originalImage.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        // Get the transformed image
        let transformedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return transformedImage
    }
    
    /// Calculate the perspective transform matrix
    /// - Parameters:
    ///   - source: Source quadrilateral points
    ///   - destination: Destination quadrilateral points
    /// - Returns: The perspective transform
    private static func perspectiveTransform(from source: [CGPoint], to destination: [CGPoint]) -> CGAffineTransform {
        // In a real implementation, this would calculate a perspective transform matrix
        // For simplicity, we'll just use a basic affine transform
        return CGAffineTransform.identity
    }
    
    /// Calculate the distance between two points
    /// - Parameters:
    ///   - p1: The first point
    ///   - p2: The second point
    /// - Returns: The distance between the points
    private static func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
    }
    
    /// Crop the center square of an image
    /// - Parameter image: The image to crop
    /// - Returns: The cropped image
    private static func cropCenterSquare(image: UIImage) -> UIImage {
        let size = min(image.size.width, image.size.height)
        let x = (image.size.width - size) / 2
        let y = (image.size.height - size) / 2
        
        let cropRect = CGRect(x: x, y: y, width: size, height: size)
        
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return image
    }
} 