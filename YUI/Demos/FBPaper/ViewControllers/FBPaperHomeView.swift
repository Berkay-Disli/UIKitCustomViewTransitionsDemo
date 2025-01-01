import UIKit

class FBPaperHomeView: UIViewController {
    enum Constants {
        static let interItemSpacing: CGFloat = 1.5
        static let lineSpacing: CGFloat = 1.5
        static let scaleFactor: CGFloat = 0.6
    }
    
    private var homeViews: [UIViewController] = [
        PhotoGridView(),
        UntitledGridView(),
        PathView()
    ]
    
    public lazy var layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width * Constants.scaleFactor,
                             height: UIScreen.main.bounds.height * Constants.scaleFactor)
        $0.minimumLineSpacing = Constants.lineSpacing
        $0.minimumInteritemSpacing = Constants.interItemSpacing
    }
    
    public lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    ).then {
        $0.register(FBPaperHomeViewCell.self,
                    forCellWithReuseIdentifier: FBPaperHomeViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.delaysContentTouches = false
//        $0.layer.borderWidth = 1
//        $0.layer.borderColor = UIColor.red.cgColor
        $0.backgroundColor = .clear
    }
    
    private let transitionAnimator = FBPaperTransitionAnimationController()
    private var interactionController = FBPaperTransitionInteractionController()
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(
        target: self,
        action: #selector(handlePan)
    )
    public var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }
    
    private func setupView() {
        let backgroundImage = UIImageView(image: UIImage(named: "Background"))
        backgroundImage.do {
            $0.contentMode = .scaleAspectFill
            view.fillWith($0)
        }
        
        setupInfo()
        setupCollectionView()
    }
    
    public var collectionViewHeightConstraint: NSLayoutConstraint?
    
    private func setupCollectionView() {
        collectionView.then {
            $0.contentInsetAdjustmentBehavior = .never
            $0.showsHorizontalScrollIndicator = false
            
            // TODO: Implement interactive transition
            // $0.addGestureRecognizer(panGestureRecognizer)
            // panGestureRecognizer.delegate = self
            
            $0.alwaysBounceVertical = false
            
            view.addSubview($0)
        }.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
            
            // Create and store the height constraint
            let heightConstraint = collectionView.heightAnchor.constraint(
                equalToConstant: UIScreen.main.bounds.height * Constants.scaleFactor
            )
            self.collectionViewHeightConstraint = heightConstraint
            heightConstraint.isActive = true
        }
    }
    
    private func setupInfo() {
        let title = UILabel()
        let titleAS = NSAttributedString(
            string: "YUI",
            attributes: [
                NSAttributedString.Key.kern: -0.8,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)
            ]
        )
        title.attributedText = titleAS
        title.then {
            view.addSubview($0)
        }.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor + 20
            $0.leading == view.leadingAnchor + 20
        }
        
        let description = UILabel()
        let descriptionAS = NSAttributedString(
            string: "A gallery of custom view transitions and interfaces built entirely in UIKit. Inspired by apps like Instagram, Facebook Paper, Path, [untitled], and more.",
            attributes: [
                NSAttributedString.Key.kern: -0.2,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light),
                NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
        )
        description.attributedText = descriptionAS
        description.then {
            view.addSubview($0)
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }.layout {
            $0.top == title.bottomAnchor + 12
            $0.leading == view.leadingAnchor + 20
            $0.width == UIScreen.main.bounds.width * 0.7
        }
    }
}

extension FBPaperHomeView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

extension FBPaperHomeView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return homeViews.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FBPaperHomeViewCell.identifier,
                                                      for: indexPath) as! FBPaperHomeViewCell
        
        guard let viewController = homeViews[indexPath.item] as? IdentifiableViewController else { return cell }
        
        // Configure cell with preview image of destination view controller
        let image = UIImage(named: viewController.stringIdentifier)
        cell.configure(image: image)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    
    {
        selectedIndexPath = indexPath
        navigationController?.pushViewController(homeViews[indexPath.item],
                                                 animated: true)
    }
}

extension FBPaperHomeView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if fromVC is Self {
            transitionAnimator.transition = .push
            return transitionAnimator
        } else if toVC is Self {
            transitionAnimator.transition = .pop
            return transitionAnimator
        }
        
        // Use default animation otherwise
        return nil
    }
    
    //    func navigationController(
    //        _ navigationController: UINavigationController,
    //        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    //    {
    //        interactionController
    //    }
}

extension FBPaperHomeView {
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let screenW: CGFloat = UIScreen.main.bounds.width
        let screenH: CGFloat = UIScreen.main.bounds.height
        
        switch recognizer.state {
        case .began:
            // Store the relative touch position within the visible content
            let touchPoint = recognizer.location(in: collectionView)
            initialTouchPoint = touchPoint
            initialContentOffset = collectionView.contentOffset
            
            // Store the touched cell's index and frame
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                let cellFrame = collectionView.layoutAttributesForItem(at: indexPath)?.frame ?? .zero
                initialCenterX = cellFrame.midX - collectionView.contentOffset.x
            }
            
        case .changed:
            guard let initialTouchPoint = initialTouchPoint,
                  let initialContentOffset = initialContentOffset,
                  let initialCenterX = initialCenterX else { return }
            
            let translation = recognizer.translation(in: view)
            
            // Calculate progress with slight dampening
            let progress = min(1, max(0, -translation.y / (screenH * 0.3)))
            
            // Calculate new sizes
            let initialWidth = screenW * Constants.scaleFactor
            let initialHeight = screenH * Constants.scaleFactor
            let finalWidth = screenW
            let finalHeight = screenH
            
            let newWidth = initialWidth + ((finalWidth - initialWidth) * progress)
            let newHeight = initialHeight + ((finalHeight - initialHeight) * progress)
            
            // Calculate scale factors
            let scaleX = newWidth / initialWidth
            
            // Update layout
            let updatedLayout = UICollectionViewFlowLayout()
            updatedLayout.scrollDirection = .horizontal
            updatedLayout.itemSize = CGSize(width: newWidth, height: newHeight)
            updatedLayout.minimumLineSpacing = Constants.lineSpacing
            updatedLayout.minimumInteritemSpacing = Constants.interItemSpacing
            
            // Calculate the new content offset to maintain the cell position
            let scaledCenterX = initialCenterX * scaleX
            let touchPointInView = recognizer.location(in: view)
            let targetContentOffsetX = scaledCenterX - (touchPointInView.x - collectionView.frame.minX)
            
            // Apply changes with dampening for smoother scrolling
            let currentOffset = collectionView.contentOffset.x
            let dampening: CGFloat = 0.7
            let newContentOffsetX = currentOffset + (targetContentOffsetX - currentOffset) * dampening
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            collectionView.setCollectionViewLayout(updatedLayout, animated: false)
            collectionView.contentOffset.x = newContentOffsetX
            collectionViewHeightConstraint?.constant = newHeight
            
            CATransaction.commit()
            
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: view)
            let translation = recognizer.translation(in: view)
            
            // Clear stored values
            initialTouchPoint = nil
            initialContentOffset = nil
            initialCenterX = nil
            
            // Determine if we should complete the expansion
            let shouldExpand = -translation.y > screenH * 0.2 || velocity.y < -500
            
            if shouldExpand {
                if let mostVisibleIndex = getMostVisibleCellIndex() {
                    selectedIndexPath = IndexPath(item: mostVisibleIndex, section: 0)
                    navigationController?.pushViewController(homeViews[mostVisibleIndex], animated: true)
                }
            } else {
                // Reset to original state with animation
                let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1) {
                    let currentOffset = self.collectionView.contentOffset
                    self.collectionView.setCollectionViewLayout(self.layout, animated: false)
                    self.collectionView.contentOffset = currentOffset
                    self.collectionViewHeightConstraint?.constant = screenH * Constants.scaleFactor
                    self.view.layoutIfNeeded()
                }
                animator.startAnimation()
            }
            
        default:
            break
        }
    }

    // Add this property to store the initial center position
    private struct AssociatedKeys {
        static var initialTouchPoint = "initialTouchPoint"
        static var initialContentOffset = "initialContentOffset"
        static var initialCenterX = "initialCenterX"
    }

    private var initialCenterX: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.initialCenterX) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.initialCenterX, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Helper method to determine the most visible cell
    private func getMostVisibleCellIndex() -> Int? {
        let visibleCells = collectionView.visibleCells
        var maxVisibleArea: CGFloat = 0
        var mostVisibleCellIndex: Int?
        
        for cell in visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else { continue }
            let cellFrame = cell.frame
            let visibleCellFrame = collectionView.convert(cellFrame, to: view)
            let intersection = visibleCellFrame.intersection(view.bounds)
            let visibleArea = intersection.width * intersection.height
            
            if visibleArea > maxVisibleArea {
                maxVisibleArea = visibleArea
                mostVisibleCellIndex = indexPath.item
            }
        }
        
        return mostVisibleCellIndex
    }

    private var initialTouchPoint: CGPoint? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.initialTouchPoint) as? CGPoint
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.initialTouchPoint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var initialContentOffset: CGPoint? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.initialContentOffset) as? CGPoint
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.initialContentOffset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Hide home bar
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

extension FBPaperHomeView: FBPaperTransitioning {
    var sharedView: UIView? {
        guard let selectedIndexPath,
              let cell = collectionView.cellForItem(at: selectedIndexPath) as? FBPaperHomeViewCell else
        {
            return nil
        }
        
        // Recreate a snapshot of the cell instead of returning the cell itself
        let snapshotView = UIView(frame: cell.frameInWindow ?? cell.frame)
        snapshotView.layer.cornerCurve = .continuous
        snapshotView.layer.cornerRadius = 8
        
        return snapshotView
    }
}

extension UIView {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}
