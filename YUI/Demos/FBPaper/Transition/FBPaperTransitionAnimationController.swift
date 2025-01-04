import UIKit

final class FBPaperTransitionAnimationController: NSObject {
    var transition: TransitionType = .push
    private var config: SharedTransitionConfig = .default
}

extension FBPaperTransitionAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        config.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transition {
        case .push:
            pushAnimation(with: transitionContext)
        case .pop:
            popAnimation(with: transitionContext)
        }
    }
}

extension FBPaperTransitionAnimationController {
    private func pushAnimation(with context: UIViewControllerContextTransitioning) {
        guard let (fromView, fromSharedView, toView, _, fromVC, _) = setup(with: context),
              let fromViewController = fromVC as? FBPaperHomeView else
        {
            context.completeTransition(false)
            return
        }

        let collectionView = fromViewController.collectionView
        let selectedIndexPath = fromViewController.selectedIndexPath ?? IndexPath(item: 0, section: 0)
        
        // Store initial height constraint
        let initialHeight = collectionView.bounds.height
                
        // Create a new layout for the animation
        let finalLayout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.itemSize = CGSize(width: GlobalConstants.screenW, height: GlobalConstants.screenH + 80)
            $0.minimumLineSpacing = FBPaperHomeView.Constants.lineSpacing
            $0.minimumInteritemSpacing = FBPaperHomeView.Constants.interItemSpacing
        }
        
        let targetOffset = CGPoint(x: CGFloat(selectedIndexPath.item) * GlobalConstants.screenW, y: 0)
        
        let toViewTransform: CGAffineTransform = .transform(originalFrame: toView.frameInWindow ?? toView.frame,
                                                            toTargetFrame: fromSharedView.frameInWindow ?? fromSharedView.frame)
        toView.layer.opacity = 0
        toView.transform = toViewTransform
        toView.layer.cornerRadius = max(0, UIScreen.main.displayCornerRadius - 12)
        
        let backdrop = UIView().then {
            $0.backgroundColor = .black
            $0.layer.opacity = 0
            $0.frame = fromView.frame
        }
        fromView.insertSubview(backdrop, belowSubview: collectionView)

        // Update corner radius for all visible cells
        collectionView.visibleCells.forEach { cell in
            let cell = cell as! FBPaperHomeViewCell
            cell.imageContainer.layer.cornerRadius = cell.imageContainer.layer.cornerRadius // Preserve current corner radius
        }

        // First, update height to match initial collection view height
        fromViewController.collectionViewHeightConstraint?.constant = initialHeight
        fromView.layoutIfNeeded()

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 2,
            initialSpringVelocity: 0.2,
            options: [.curveEaseInOut])
        {
            // Animate both layout and height together
            collectionView.setCollectionViewLayout(finalLayout, animated: true)
            collectionView.contentOffset = targetOffset
            fromViewController.collectionViewHeightConstraint?.constant = GlobalConstants.screenH
            fromView.layoutIfNeeded() // Force layout update for smooth height animation
            
            // Animate corner radius for all visible cells
            collectionView.visibleCells.forEach { cell in
                let cell = cell as! FBPaperHomeViewCell
                cell.imageContainer.layer.cornerRadius = UIScreen.main.displayCornerRadius
                cell.titleLabel.layer.opacity = 0
            }
            
            toView.layer.opacity = 1
            toView.transform = .identity
            toView.layer.cornerRadius = UIScreen.main.displayCornerRadius
            
            backdrop.layer.opacity = 0.5
        } completion: { _ in
            // Reset collectionView to original state
            collectionView.setCollectionViewLayout(fromViewController.layout, animated: false)
            fromViewController.collectionViewHeightConstraint?.constant = GlobalConstants.screenH * FBPaperHomeView.Constants.scaleFactor + 40
            collectionView.visibleCells.forEach { cell in
                let cell = cell as! FBPaperHomeViewCell
                cell.imageContainer.layer.cornerRadius = max(0, UIScreen.main.displayCornerRadius - 32)
                cell.titleLabel.layer.opacity = 1
            }
            
            backdrop.removeFromSuperview()
            context.completeTransition(true)
        }
    }
    
    private func popAnimation(with context: UIViewControllerContextTransitioning) {
        guard let (fromView, _, toView, toSharedView, _, toVC) = setup(with: context),
              let toViewController = toVC as? FBPaperHomeView  else
        {
            context.completeTransition(false)
            return
        }

        let collectionView = toViewController.collectionView
        let selectedIndexPath = toViewController.selectedIndexPath ?? IndexPath(item: 0, section: 0)
        
        let finalLayout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.itemSize = CGSize(width: GlobalConstants.screenW, height: GlobalConstants.screenH + 80)
            $0.minimumLineSpacing = FBPaperHomeView.Constants.lineSpacing
            $0.minimumInteritemSpacing = FBPaperHomeView.Constants.interItemSpacing
        }

        // Initially set full screen height
        toViewController.collectionViewHeightConstraint?.constant = GlobalConstants.screenH
        
        // Initially, collection view takes up entire screen
        collectionView.setCollectionViewLayout(finalLayout, animated: false)
        let targetOffset = CGPoint(x: CGFloat(selectedIndexPath.item) * GlobalConstants.screenW, y: 0)
        collectionView.contentOffset = targetOffset
        
        let fromViewTransform: CGAffineTransform = .transform(originalFrame: fromView.frameInWindow ?? fromView.frame,
                                                              toTargetFrame: toSharedView.frameInWindow ?? toSharedView.frame)
        
        // Set initial corner radius for fromView
        fromView.layer.cornerRadius = UIScreen.main.displayCornerRadius
        
        let backdrop = UIView().then {
            $0.backgroundColor = .black
            $0.layer.opacity = 0.5
            $0.frame = fromView.frame
        }
        toView.insertSubview(backdrop, belowSubview: collectionView)
        
        // Force initial layout
        toView.layoutIfNeeded()
        
        // Now set the corner radius after the layout has been updated
        collectionView.visibleCells.forEach { cell in
            let cell = cell as! FBPaperHomeViewCell
            cell.imageContainer.layer.cornerRadius = UIScreen.main.displayCornerRadius
        }
        
        fromView.layer.opacity = 1

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 2,
            initialSpringVelocity: 0.2,
            options: [])
        {
            // Animate to final layout and height
            collectionView.setCollectionViewLayout(toViewController.layout, animated: true)
            toViewController.collectionViewHeightConstraint?.constant = GlobalConstants.screenH * FBPaperHomeView.Constants.scaleFactor + 40
            toView.layoutIfNeeded() // Force layout update for smooth height animation
            
            // Animate corner radius for all visible cells
            collectionView.visibleCells.forEach { cell in
                let cell = cell as! FBPaperHomeViewCell
                cell.imageContainer.layer.cornerRadius = max(0, UIScreen.main.displayCornerRadius - 32)
                cell.titleLabel.layer.opacity = 1
            }
            
            fromView.layer.opacity = 0
            fromView.transform = fromViewTransform
            fromView.layer.cornerRadius = max(0, UIScreen.main.displayCornerRadius - 16)
            
            backdrop.layer.opacity = 0
        } completion: { _ in
            fromView.transform = .identity
            fromView.layer.cornerRadius = 0
            backdrop.removeFromSuperview()
            
            let isCancelled = context.transitionWasCancelled
            context.completeTransition(!isCancelled)
        }
    }
    
    private func setup(with context: UIViewControllerContextTransitioning) -> (UIView, UIView, UIView, UIView, UIViewController, UIViewController)? {
        // Get the source and destination views
        guard let toView = context.view(forKey: .to),
              let fromView = context.view(forKey: .from) else
        {
            return nil
        }
        
        guard let toViewController = context.viewController(forKey: .to),
              let fromViewController = context.viewController(forKey: .from) else
        {
            return nil
        }
        
        // Add views to the empty container view in the correct order
        if transition == .push {
            context.containerView.addSubview(toView)
        } else {
            context.containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        guard let toSharedView = context.sharedViewForFBPaper(forKey: .to),
              let fromSharedView = context.sharedViewForFBPaper(forKey: .from) else
        {
            return nil
        }
        
        // Return necessary components for the transition
        return (fromView, fromSharedView, toView,
                toSharedView, fromViewController, toViewController)
    }
}
