import UIKit

final class UntitledDetailView: UIViewController {
    private enum Constants {
        static let scrollViewInset: UIEdgeInsets = .init(top: 78, left: 20,
                                                         bottom: 20, right: 20)
    }
    
    private var image: UIImage
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let header = UntitledDetailViewHeader()
    private let imageView = UIImageView()
    private let transitionAnimator = UntitledTransitionAnimationController()
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    
    init(image: UIImage) {
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = .untitledGrey
        self.imageView.layer.cornerCurve = .continuous
        self.imageView.layer.cornerRadius = 39 // So it matches the transition
        self.imageView.accessibilityIgnoresInvertColors = true
        
        self.imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }
}

extension UntitledDetailView {
    private func setupView() {
        view.backgroundColor = .untitledGrey
        
        // Add pan gesture recognizer that will activate the interactive pop transition
        view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        setupScrollView()
        setupImageView()
        setupHeader()
    }
    
    private func setupHeader() {
        header.then {
            $0.backNavigation = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            $0.backgroundColor = .clear
            view.addSubview($0)
        }.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
    }
    
    private func setupScrollView() {
        scrollView.then {
            $0.alwaysBounceVertical = true
            view.addSubview($0)
        }.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
        
        contentView.then {
            scrollView.addSubview($0)
        }.layout {
            $0.top == scrollView.contentLayoutGuide.topAnchor
            $0.leading == scrollView.contentLayoutGuide.leadingAnchor
            $0.trailing == scrollView.contentLayoutGuide.trailingAnchor
            $0.bottom == scrollView.contentLayoutGuide.bottomAnchor
            $0.width == scrollView.frameLayoutGuide.widthAnchor
        }
    }
    
    private func setupImageView() {
        imageView.then {
            contentView.addSubview($0)
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = true
            $0.image = image
        }.layout {
            $0.leading == contentView.leadingAnchor + Constants.scrollViewInset.right
            $0.trailing == contentView.trailingAnchor - Constants.scrollViewInset.right
            $0.top == contentView.safeAreaLayoutGuide.topAnchor + Constants.scrollViewInset.top
        }

        // Fix album art to square ratio
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let contentOffsetY = scrollView.contentOffset.y

        let window = UIApplication.keyWindow!

        switch recognizer.state {
        case .began:
            let velocity = recognizer.velocity(in: window)
            guard abs(velocity.x) > abs(velocity.y) else { return }
            interactionController = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewController(animated: true)
            
            scrollView.isScrollEnabled = false

        case .changed:
            let translation = recognizer.translation(in: window)
            let progress = translation.x / window.frame.width
            
            interactionController?.update(progress)
            
        case .ended:
            let horizontalVelocity = recognizer.velocity(in: window).x
            let translation = recognizer.translation(in: window)
            let progress = translation.x / window.frame.width

            if horizontalVelocity > 900 || progress > 0.1 && !(horizontalVelocity <= 0) {
                interactionController?.finish()
            } else {
                interactionController?.completionSpeed = progress
                interactionController?.cancel()
            }
            
            interactionController = nil
            
            scrollView.isScrollEnabled = true

        default:
            interactionController?.cancel()
            interactionController = nil
            
            scrollView.isScrollEnabled = true
        }
        
        scrollView.contentOffset.y = contentOffsetY
    }
}

extension UntitledDetailView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        // Use default animation if not going to PhotoGridView
        guard fromVC is Self, toVC is UntitledGridView else { return nil }
        
        transitionAnimator.transition = .pop
        return transitionAnimator
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }
}

extension UntitledDetailView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

extension UntitledDetailView: SharedTransitioning, FBPaperTransitioning {
    var sharedFrame: CGRect {
        imageView.frameInWindow ?? .zero
    }
    
    var sharedView: UIView? {
        // Recreate a snapshot of the cell instead of returning the cell itself
        let snapshotView = UIView(frame: imageView.frameInWindow ?? imageView.frame)
        let imageView = UIImageView(image: image)
        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = true
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = 40
            snapshotView.addSubview($0)
            snapshotView.fillWith($0)
        }
        
        return snapshotView
    }
}
