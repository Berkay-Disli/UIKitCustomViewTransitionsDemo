import UIKit

/// This class is used to implement the interactive pop transition that can be activated by a gesture
/// and leverages the existing, non-interactive pop transition in order to "interpolate" between the
/// two states: the interactive portion driven by gesture, and non-interactive portion after user ends gesture.
///
class SharedTransitionInteractionController: NSObject {
    
    /// An internal struct designed to store the frames, transformations and references of
    /// the participants of the interactive transition.
    ///
    struct Context {
        var transitionContext: UIViewControllerContextTransitioning
        var fromFrame: CGRect
        var toFrame: CGRect
        var fromView: UIView
        var toView: UIView
        var mask: UIView
        var transform: CGAffineTransform
        var backdrop: UIView
        var placeholder: UIView
    }
    
    /// We store the context as a property of this class, since the system invokes
    /// `startInteractiveTransition(_ transitionContext:)` only once
    /// at the beginning of the transition. To successfully execute the interactive transition,
    /// we need access to these components throughout the process.
    ///
    public var context: Context?
    
    private var config: SharedTransitionConfig = .interactive
    private var alreadyFinished = false
    private var alreadyCancelled = false
}

extension SharedTransitionInteractionController: UIViewControllerInteractiveTransitioning {
    var wantsInteractiveStart: Bool { false }

    // Tells the navigation controller to begin the interactive transition
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        prepareViewController(from: transitionContext)

        guard let (fromView, fromFrame, toView, toFrame) = setup(with: transitionContext) else {
            transitionContext.completeTransition(false)
            return
        }

        let transform: CGAffineTransform = .transform(
            parent: fromView.frame,
            suchThatChild: fromFrame,
            aspectFills: toFrame
        )
        
        let mask = UIView(frame: fromView.frame).then {
            $0.layer.cornerCurve = .continuous
            $0.backgroundColor = .black
            $0.layer.cornerRadius = config.maskCornerRadius
        }
        fromView.mask = mask
        
        let placeholder = UIView().then {
            $0.frame = toFrame
            $0.backgroundColor = config.placeholderColor
        }
        toView.addSubview(placeholder)
        
        let backdrop = UIView().then {
            $0.backgroundColor = .black
            $0.layer.opacity = config.overlayOpacity
            $0.frame = toView.frame
        }
        toView.addSubview(backdrop)

        // Populate context with the calculated values and
        // initial state, stored for later use
        context = Context(
            transitionContext: transitionContext,
            fromFrame: fromFrame,
            toFrame: toFrame,
            fromView: fromView,
            toView: toView,
            mask: mask,
            transform: transform,
            backdrop: backdrop,
            placeholder: placeholder
        )

        // Prevent gesture conflicts when view is already animating
        if alreadyFinished { finish() }
        if alreadyCancelled { cancel() }
    }
}

/// This extension overrides the default methods of an interactive transition.
///
/// - `update(_ percentComplete:)`: Updates the progress of our animation based on a percentage value ranging from 0 to 1.
/// - `cancel()`: Reverts the animation, transitioning our views back to their initial state and consequently aborting the transition.
/// - `finish()`: Concludes the animation by playing it through to the end from its current progress point.
///
extension SharedTransitionInteractionController {
    func update(_ recognizer: UIPanGestureRecognizer) {
        // Ensure context struct exists, since we need its components
        // to drive our interactive transition
        guard let context else { return }
        
        // Determine progress of the transition via the horizontal translation
        // of the gesture
        let window = UIApplication.keyWindow!
        let translation = recognizer.translation(in: window)
                
        let progress = abs(translation.x / window.frame.width)
        
        // Inform UIKit of our transition’s progress, using the transitionContext
        // reference previously saved in our context.
        context.transitionContext.updateInteractiveTransition(progress)
        
        // Determine scale of the fromView based on the horizontal translation
        var scaleFactor = 1 - progress * (1 - config.interactionScaleFactor)
        scaleFactor = min(max(scaleFactor, config.interactionScaleFactor), 1)
        
        // Combine both translation and scale transformations
        context.fromView.transform = .init(scaleX: scaleFactor,
                                           y: scaleFactor)
                                     .translatedBy(x: translation.x,
                                                   y: translation.y)
    }

    func cancel() {
        // Ensure context struct exists, since we need its components
        // to drive our interactive transition, and set alreadyCancelled
        // flag to true to prevent multiple swipe conflicts
        guard let context else {
            alreadyCancelled = true
            return
        }
        
        // Let UIKit know that the interactive portion of this transition is cancelled
        // so that the usual non-interactive portion can take over from where it's left off
        context.transitionContext.cancelInteractiveTransition()
        
        // Revert changes made during the transition
        let maskRadius = config.maskCornerRadius
        let overlayOpacity = config.overlayOpacity
        UIView.animate(duration: config.duration, curve: config.curve) {
            context.fromView.transform = .identity
            context.mask.frame = context.fromView.frame
            context.mask.layer.cornerRadius = maskRadius
            context.backdrop.layer.opacity = overlayOpacity
        } completion: {
            // Cleanup views
            context.backdrop.removeFromSuperview()
            context.placeholder.removeFromSuperview()
            context.toView.removeFromSuperview()
            
            // Signal to UIKit that transition is cancelled
            context.transitionContext.completeTransition(false)
        }
    }

    func finish() {
        // Ensure context struct exists, since we need its components
        // to drive our interactive transition, and set alreadyFinished
        // flag to true to prevent multiple swipe conflicts
        guard let context else {
            alreadyFinished = true
            return
        }
        
        // Let UIKit know that the interactive portion of this transition is finished
        // so that the usual non-interactive portion can take over from where it's left off
        context.transitionContext.finishInteractiveTransition()
        
        // Update views
        let maskFrame = context.toFrame.aspectFit(to: context.fromFrame)
        UIView.animate(duration: config.duration, curve: config.curve) {
            context.fromView.transform = context.transform
            context.mask.frame = maskFrame
            context.mask.layer.cornerRadius = 0
            context.backdrop.layer.opacity = 0
        } completion: {
            // Cleanup views
            context.backdrop.removeFromSuperview()
            context.placeholder.removeFromSuperview()
            
            // Signal to UIKit that transition is complete
            context.transitionContext.completeTransition(true)
        }
    }
}

extension SharedTransitionInteractionController {
    private func prepareViewController(from context: UIViewControllerContextTransitioning) {
        let toVC = context.viewController(forKey: .to) as? SharedTransitioning
        toVC?.prepare(for: .pop)
    }
    
    /// Setup the transition by supplying the required components to the interaction controller.
    /// Only handles pop transitions (hence adding `toView` beneath `fromView`).
    ///
    private func setup(with context: UIViewControllerContextTransitioning) -> (UIView, CGRect, UIView, CGRect)? {
        guard let toView = context.view(forKey: .to),
              let fromView = context.view(forKey: .from) else {
            return nil
        }
        
        context.containerView.insertSubview(toView, belowSubview: fromView)
        
        guard let toFrame = context.sharedFrame(forKey: .to),
              let fromFrame = context.sharedFrame(forKey: .from) else
        {
            return nil
        }
        
        return (fromView, fromFrame, toView, toFrame)
    }
}
