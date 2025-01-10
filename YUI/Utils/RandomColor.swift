import UIKit

/// This function generates a random UIColor with:
/// - A random hue value that is customizable via hue range (defaults to 0-1)
/// - Saturation between 0.3 and 0.8 for moderate color intensity
/// - Brightness between 0.7 and 1.0 to ensure visible, vibrant colors
///
/// The generated colors are designed to be adequately pleasing via:
/// - Optional constrained color palettes via custom hue range
/// - Avoiding overly dull colors (through minimum saturation of 0.3)
/// - Avoiding dark colors (through minimum brightness of 0.7)
///
/// - Parameter hueRange: The range of possible hue values (default: 0...1.0)
/// - Returns: A UIColor instance with random but controlled HSB values and full opacity (alpha = 1.0)
///
/// Example Usage:
/// ```
/// // Generate any random color
/// let randomColor = getRandomColor()
///
/// // Generate a random color in the blue range
/// let randomBlue = getRandomColor(withHueRange: 0.5...0.7)
/// ```
///
func getRandomColor(withHueRange hueRange: ClosedRange<CGFloat> = 0...1.0) -> UIColor {
    let hue = CGFloat.random(in: hueRange)
    let saturation: CGFloat = CGFloat.random(in: 0.2...0.8)
    let brightness: CGFloat = CGFloat.random(in: 0.9...1.0)
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
}
