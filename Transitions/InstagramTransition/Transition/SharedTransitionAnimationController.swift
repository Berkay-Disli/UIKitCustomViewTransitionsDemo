import UIKit

/// This class is an "animation controller" and conforms to
/// `UIViewControllerAnimatedTransitioning` in order to implement a
/// custom transition animation when pushing and popping.
///
/// We return an instance of this animation controller to view controllers that conform to
/// `UINavigationControllerDelegate` through the required method
/// `navigationController(_:animationControllerFor:from:to: UIViewController)`.
///
/// The reason why we don't have this animation controller conform to the delegate and
/// implement the method above is as follows:
///
/// 1. It requires shared state between view controllers: for example, the `PhotoGridView`
///   needs to track the `selectedIndexPath` for the transition as it tells us about the
///   `cell` and its `frame`, which it retrieves from the `collectionView`.
/// 2. The transitions are specific to paired navigations, like the one between `PhotoGridView`
///   and `PhotoDetailView`. We have custom logic to determine when to apply the transition
///   (checking if `fromVC` and `toVC` are the types we expect)
/// 3. For interactive transitions, e.g. like the one in `PhotoDetailView`, the pan gesture needs
///   direct access to this animation controller and the interaction controller.
///
final class SharedTransitionAnimationController: NSObject {
    var transition: TransitionType = .push
    private var config: SharedTransitionConfig = .default
}

extension SharedTransitionAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        config.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        // Before animation begins, prepare the view controllers for any configuration
        // required for the transition
        prepareViewControllers(from: transitionContext, for: transition)
        
        // Depending on transition type, run a different animation type
        switch transition {
        case .push:
            pushAnimation(with: transitionContext)
        case .pop:
            popAnimation(with: transitionContext)
        }
    }
}

extension SharedTransitionAnimationController {
    /// The push animation of our custom`SharedTransition`
    ///
    private func pushAnimation(with context: UIViewControllerContextTransitioning) {
        // Retrieve necessary components for the transition (namely, the shared view between
        // the two view controllers).
        //
        // Also adds the destination view to the containerView.
        guard let (fromView, fromFrame, toView, toFrame) = setup(with: context) else {
            context.completeTransition(false)
            return
        }
        
        // Calculate the initial transformation for the destination view,
        // scaling it down such that the shared view of the destination view
        // aspect fills the shared view of source view.
        //
        // This gives the effect that the destination view grows from the source view
        // (unless source view is larger than destination view for some reason, in
        // which case the latter shrinks from the former).
        let transform: CGAffineTransform = .transform(
            parent: toView.frame, // e.g. the detail view
            suchThatChild: toFrame, // e.g. the photo in the detail view
            aspectFills: fromFrame // e.g. the photo cell in the grid view
        )
        toView.transform = transform
        
        // Compute and set the mask for the destination view, which will
        // expand throughout the animation
        let maskFrame = fromFrame.aspectFit(to: toFrame)
        let mask = UIView(frame: maskFrame).then {
            $0.layer.cornerCurve = .continuous
            $0.backgroundColor = .black
        }
        toView.mask = mask
        
        // Add placeholder view to cover up the fromView (e.g. the photo cell) to create the
        // illusion of the source view expanding and departing from its origin to the dest. view
        let placeholder = UIView().then {
            $0.backgroundColor = config.placeholderColor
            $0.frame = fromFrame
        }
        fromView.addSubview(placeholder)
        
        // Add dark backdrop to the source view
        let backdrop = UIView().then {
            $0.backgroundColor = .black
            $0.layer.opacity = 0
            $0.frame = fromView.frame
        }
        fromView.addSubview(backdrop)
        
        // Within the animation block, gradually:
        // 1. Revert destination view to its original dimensions and position
        // 2. Adjust mask's frame to unveil entire destination screen, applying a corner radius too
        // 3. Increase opacity of dark backdrop
        //
        // And afterwards, in the completion handler:
        // 1. Dispose of the mask, backdrop and placeholder view
        // 2. Invoke `completeTransition` on `transitionContext` to signal that transition is done
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 2,
            initialSpringVelocity: 0.4,
            options: [])
        { [config] in
            toView.transform = .identity
            mask.frame = toView.frame
            mask.layer.cornerRadius = config.maskCornerRadius
            backdrop.layer.opacity = config.overlayOpacity
        } completion: { _ in
            toView.mask = nil
            backdrop.removeFromSuperview()
            placeholder.removeFromSuperview()
            context.completeTransition(true)
        }
    }
    
    /// The pop animation of our custom`SharedTransition`
    ///
    private func popAnimation(with context: UIViewControllerContextTransitioning) {
        // Retrieve necessary components for the transition (namely, the shared view between
        // the two view controllers).
        //
        // Also adds the destination view to the containerView, but this time positioning it under
        // the source view.
        guard let (fromView, fromFrame, toView, toFrame) = setup(with: context) else {
            context.completeTransition(false)
            return
        }
        
        let transform: CGAffineTransform = .transform(
            parent: fromView.frame, // e.g. the detail view
            suchThatChild: fromFrame, // e.g. the photo in the detail view
            aspectFills: toFrame // e.g. the photo cell in the grid view
        )
        
        // Compute and set the mask, which starts off with the same
        // frame size as the source view, but gradually shrinks
        let mask = UIView(frame: fromView.frame).then {
            $0.layer.cornerCurve = .continuous
            $0.backgroundColor = .black
            $0.layer.cornerRadius = config.maskCornerRadius
        }
        fromView.mask = mask
        
        // Add dark backdrop to destination view
        let backdrop = UIView().then {
            $0.backgroundColor = .black
            $0.layer.opacity = config.overlayOpacity
            $0.frame = toView.frame
        }
        toView.addSubview(backdrop)
        
        // Add placeholder view to cover up the toView (e.g. the photo cell) to create the
        // illusion of the source view shrinking and returning to its origin in the dest. view
        let placeholder = UIView().then {
            $0.backgroundColor = config.placeholderColor
            $0.frame = toFrame
        }
        toView.addSubview(placeholder)
        
        // Determine the final frame for the mask to guide its shrinking during the transition
        let maskFrame = toFrame.aspectFit(to: fromFrame)
        
        // Within the animation block, gradually:
        // 1. Apply the transform to the source view
        // 2. Resize mask of the source view according to the final frame, removing corner radius
        // 3. Remove dark backdrop
        //
        // And afterwards, in the completion handler:
        // 1. Dispose of the mask, backdrop and placeholder view
        // 2. In the event that the transition is interactive, check if it was cancelled
        // 3. Invoke `completeTransition` on `transitionContext` to signal that transition is done
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 2,
            initialSpringVelocity: 0.4,
            options: [])
        {
            fromView.transform = transform
            mask.frame = maskFrame
            mask.layer.cornerRadius = 0
            backdrop.layer.opacity = 0
        } completion: { _ in
            fromView.mask = nil
            backdrop.removeFromSuperview()
            placeholder.removeFromSuperview()
            let isCancelled = context.transitionWasCancelled
            context.completeTransition(!isCancelled)
        }
    }
    
    /// Before the animation begins, prepare the view controllers for the transition if necessary – unrelated to
    /// the actual animation of the transition.
    ///
    private func prepareViewControllers(from context: UIViewControllerContextTransitioning,
                                        for transition: TransitionType)
    {
        // Get the source and destination view controllers from the context object
        let fromVC = context.viewController(forKey: .from) as? SharedTransitioning
        let toVC = context.viewController(forKey: .to) as? SharedTransitioning
        
        // If a configuration exists for the source view controller, use it
        if let customConfig = fromVC?.config { config = customConfig }
        
        // Prepare the view controllers for transition if necessary
        // e.g. PhotoGridView ensures the selected cell is visible before pop
        fromVC?.prepare(for: transition)
        toVC?.prepare(for: transition)
    }
    
    /// This function is used to handle the initial configuration needed for both the push and pop transitions,
    /// using the `UIViewControllerContextTransitioning` object to obtain info about both
    /// the source and destination view controllers.
    ///
    private func setup(with context: UIViewControllerContextTransitioning) -> (UIView, CGRect, UIView, CGRect)?
    {
        // Get the source and destination views
        guard let toView = context.view(forKey: .to),
              let fromView = context.view(forKey: .from) else
        {
            return nil
        }
        
        // Add views to the empty container view in the correct order
        // For push: add destination view on top
        // For pop: add destination view below source view
        if transition == .push {
            context.containerView.addSubview(toView)
        } else {
            context.containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        // Ensure the frames that will be used for the shared transition exist
        // in both view controllers
        guard let toFrame = context.sharedFrame(forKey: .to),
              let fromFrame = context.sharedFrame(forKey: .from) else
        {
            return nil
        }
        
        // Return necessary components for the transition
        return (fromView, fromFrame, toView, toFrame)
    }
}
