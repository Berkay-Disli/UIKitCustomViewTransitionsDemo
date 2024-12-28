import UIKit

extension CGRect {
    /// Main  `aspectFit` method that decides whether to fit by width or height.
    /// Used by the mask view in `SharedTransitionAnimationController`.
    ///
    func aspectFit(to frame: CGRect) -> CGRect {
        let ratio = width / height
        let frameRatio = frame.width / frame.height
        
        // If target frame is narrower than original, fit to width,
        // else if target frame is wider than original, fit to height
        if frameRatio < ratio {
            return aspectFitWidth(to: frame)
        } else {
            return aspectFitHeight(to: frame)
        }
    }

    // Fits the rect to the target frame's width while maintaining aspect ratio,
    // and centers the result vertically in the target frame
    func aspectFitWidth(to frame: CGRect) -> CGRect {
        let ratio = width / height
        let height = frame.width * ratio
        let offsetY = (frame.height - height) / 2 // Center vertically
        let origin = CGPoint(x: frame.origin.x, y: frame.origin.y + offsetY)
        let size = CGSize(width: frame.width, height: height)
        return CGRect(origin: origin, size: size)
    }

    // Fits the rect to the target frame's height while maintaining aspect ratio,
    // and cnters the result horizontally in the target frame
    func aspectFitHeight(to frame: CGRect) -> CGRect {
        let ratio = height / width
        let width = frame.height * ratio
        let offsetX = (frame.width - width) / 2 // Center horizontally
        let origin = CGPoint(x: frame.origin.x + offsetX, y: frame.origin.y)
        let size = CGSize(width: width, height: frame.height)
        return CGRect(origin: origin, size: size)
    }
}
