import UIKit

extension UIView {
    /// This computed property converts a view's frame to window coordinates.
    /// We do this because we need to know the exact position of a view in the
    /// window's coordinate space (i.e. the physical screen), not just its local superview.
    ///
    var frameInWindow: CGRect? {
        superview?.convert(frame, to: nil)
    }

    /// A convenience wrapper around `UIView.animate` that adds support for
    /// custom timing functions (`CAMediaTimingFunction`).
    ///
    static func animate(
        duration: TimeInterval,
        curve: CAMediaTimingFunction? = nil,
        options: UIView.AnimationOptions = [],
        animations: @escaping () -> Void,
        completion: (() -> Void)? = nil
    ) {
        // Begin CATransaction to set timing curve
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(curve)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: animations,
            completion: { _ in completion?() }
        )
        
        // Commit the transaction
        CATransaction.commit()
    }
}
