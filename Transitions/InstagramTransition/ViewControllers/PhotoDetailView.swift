import UIKit
import Photos

class PhotoDetailView: UIViewController {
    private var image: UIImage
    private var asset: PHAsset
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let header = PhotoDetailViewHeader()
    private let imageView = UIImageView()
    private lazy var imageFooter: PhotoFooter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = asset.creationDate.map { dateFormatter.string(from: $0) } ?? ""
        return PhotoFooter(date: dateString)
    }()
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    private let transitionAnimator = SharedTransitionAnimationController()
    
    // We supply an interaction controller object here that conforms to `UIViewControllerInteractiveTransitioning`
    // in order to support interactive transitions. The reason for making it optional is to ensure
    // that our custom, non-interactive transition is preserved when the user taps the back button.
    // We instantiate this solely when a gesture is detected, and remove it once the gesture ends.
    private var interactionController: SharedTransitionInteractionController?
    
    private let imageManager = PHCachingImageManager()
    
    init(image: UIImage, asset: PHAsset) {
        self.image = image
        self.asset = asset
        
        super.init(nibName: nil, bundle: nil)
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = .white
        self.imageView.accessibilityIgnoresInvertColors = true
        self.view.backgroundColor = .white
        
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.resizeMode = .none
        imageRequestOptions.isNetworkAccessAllowed = true
        imageRequestOptions.deliveryMode = .highQualityFormat
        self.imageManager.requestImage(
            for: asset,
            targetSize: self.view.bounds.size.pixelSize,
            contentMode: .aspectFit,
            options: imageRequestOptions
        ) { (image, info) in
            self.imageView.image = image
        }
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

extension PhotoDetailView {
    private func setupView() {
        view.backgroundColor = .white
        
        // Add pan gesture recognizer that will activate the interactive pop transition
        view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        setupHeader()
        setupScrollView()
        setupImageView()
        setupImageFooter()
    }
    
    private func setupHeader() {
        header.then {
            view.addSubview($0)
            $0.backNavigation = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
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
            $0.top == header.bottomAnchor
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
            $0.leading == contentView.leadingAnchor
            $0.trailing == contentView.trailingAnchor
            $0.top == contentView.topAnchor
        }
        
        let imageViewSize = imageView.image!.size
        let ratio = imageViewSize.height / imageViewSize.width
        
        imageView.heightAnchor.constraint(
            equalTo: imageView.widthAnchor,
            multiplier: ratio
        ).isActive = true
    }
    
    private func setupImageFooter() {
        imageFooter.then {
            contentView.addSubview($0)
        }.layout {
            $0.top == imageView.bottomAnchor + 10
            $0.leading == contentView.leadingAnchor
            $0.trailing == contentView.trailingAnchor
            $0.bottom == contentView.bottomAnchor - 10
        }
    }
}

extension PhotoDetailView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

extension PhotoDetailView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        // Use default animation if not going to PhotoGridView
        guard fromVC is Self, toVC is PhotoGridView else { return nil }

        transitionAnimator.transition = .pop
        return transitionAnimator
    }
    
    // Since we allow interactive transitions from this view controller, we supply our
    // interaction controller through this method
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        interactionController
    }
}

extension PhotoDetailView {
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        // !!!: scrollView handling
        // If scrollView is set to view.bottomAnchor,
        // when it's scrolled to the bottom and this gesture is activated,
        // the contentOffset jumps up for some reason. To counter this,
        // we save the contentOffset.y before the gesture is activated and
        // set it at the end.
        let contentOffsetY = scrollView.contentOffset.y
        
        let window = UIApplication.keyWindow!
        
        switch recognizer.state {
        case .began:
            // Check if we should start a horizontal or vertical transition
            // Allow horizontal from anywhere, but vertical only when at top
            let velocity = recognizer.velocity(in: window)
            let isHorizontalGesture = velocity.x > abs(velocity.y)
            let isAtTop = scrollView.contentOffset.y <= 0
            
            guard isHorizontalGesture || (isAtTop && velocity.y > 0) else { return }
            
            // Create interaction controller and initiate the pop navigation on the navigation controller.
            //
            // !!!: NOTE ON SUPPORTING INTERACTIVE TRANSITIONS
            // Prior to initiating the pop transition, the navigation controller will check for an interaction
            // controller (using the navigationController(navigationController:interactionControllerFor:)
            // method we implemented above). If it finds one, it will delegate the responsibility of driving
            // the transition's progress to our percent-driven interaction controller.
            //
            interactionController = SharedTransitionInteractionController()
            navigationController?.popViewController(animated: true)
            
            scrollView.isScrollEnabled = false

        case .changed:
            interactionController?.update(recognizer)
            
        case .ended:
            let horizontalVelocity = recognizer.velocity(in: window).x
            let translation = recognizer.translation(in: window)
            let horizontalProgress = abs(translation.x / window.frame.width)
            let verticalProgress = abs(translation.y / window.frame.height)

            if horizontalVelocity > 900 ||
               horizontalProgress > 0.1 ||
               verticalProgress > 0.1 &&
               !(horizontalVelocity <= 0)
            {
                interactionController?.finish()
            } else {
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

extension PhotoDetailView: SharedTransitioning {
    /// This provides the frame of the imageView in window coordinates.
    /// Used by the transition animator to animate between grid and detail views.
    /// 
    var sharedFrame: CGRect {
        imageView.frameInWindow ?? .zero
    }
}
