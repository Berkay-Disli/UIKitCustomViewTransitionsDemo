import UIKit

class HomeView: UIViewController {
    enum Constants {
        static let interItemSpacing: CGFloat = 1.5
        static let lineSpacing: CGFloat = 1.5
        static let scaleFactor: CGFloat = 0.6
    }
    
    private var homeViews: [UIViewController] = [
        TwitterSwipeGestureView(),
        TwitterSplashScreenView(),
        PathView(),
        ModalCardView(),
        UntitledGridView(),
        PhotoGridView()
    ]
    
    public lazy var containerView = UIView()
    public lazy var settingsView = UIView()
    public lazy var titleLabel = UILabel()
    public lazy var descriptionLabel = UILabel()
    
    public lazy var layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width * Constants.scaleFactor,
                             height: UIScreen.main.bounds.height * Constants.scaleFactor + 40) 
        $0.minimumLineSpacing = Constants.lineSpacing
        $0.minimumInteritemSpacing = Constants.interItemSpacing
    }
    
    public lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    ).then {
        $0.register(HomeViewCell.self,
                    forCellWithReuseIdentifier: HomeViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.delaysContentTouches = false
        $0.backgroundColor = .clear
    }
    
    private let transitionAnimator = HomeTransitionAnimationController()
    public var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }
    
    private func setupView() {
        containerView.then {
            view.addSubview($0)
            view.layer.cornerCurve = .continuous
            view.layer.cornerRadius = UIScreen.main.displayCornerRadius
            view.layer.masksToBounds = true
        }.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
        }
        
        let backgroundImage = UIImageView(image: UIImage(named: "Background"))
        backgroundImage.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = UIScreen.main.displayCornerRadius
            $0.layer.masksToBounds = true
            containerView.fillWith($0)
        }
        
        setupHeader()
        setupCollectionView()
        setupSettings()
        setupPanGesture()
    }
    
    private func setupPanGesture() {
        containerView.addGestureRecognizer(panGestureRecognizer)
    }
    
    public var collectionViewHeightConstraint: NSLayoutConstraint?
    
    private func setupCollectionView() {
        collectionView.then {
            $0.contentInsetAdjustmentBehavior = .never
            $0.showsHorizontalScrollIndicator = false
            $0.alwaysBounceVertical = false
            containerView.addSubview($0)
        }.layout {
            $0.leading == containerView.leadingAnchor
            $0.trailing == containerView.trailingAnchor
            $0.bottom == containerView.bottomAnchor
            
            // Create and store the height constraint
            let heightConstraint = collectionView.heightAnchor.constraint(
                equalToConstant: UIScreen.main.bounds.height * Constants.scaleFactor + 40
            )
            self.collectionViewHeightConstraint = heightConstraint
            heightConstraint.isActive = true
        }
    }
    
    private func setupHeader() {
        let titleAS = NSAttributedString(
            string: "YUI",
            attributes: [
                NSAttributedString.Key.kern: -0.8,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)
            ]
        )
        titleLabel.attributedText = titleAS
        titleLabel.then {
            containerView.addSubview($0)
        }.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor + 20
            $0.leading == containerView.leadingAnchor + 20
        }
        
        let descriptionAS = NSAttributedString(
            string: "A gallery of custom view transitions and interfaces built entirely in UIKit. Inspired by apps like Instagram, Facebook Paper, Path, [untitled], and more.",
            attributes: [
                NSAttributedString.Key.kern: -0.2,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light),
                NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
        )
        descriptionLabel.attributedText = descriptionAS
        descriptionLabel.then {
            containerView.addSubview($0)
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }.layout {
            $0.top == titleLabel.bottomAnchor + 12
            $0.leading == containerView.leadingAnchor + 20
            $0.width == UIScreen.main.bounds.width * (UIScreen.main.displayCornerRadius == 0.0 ? 0.74 : 0.7)
        }
        
        let settingsButton = UIButton(configuration: .plain())
        settingsButton.then {
            let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
            let image = UIImage(systemName: "ellipsis", withConfiguration: configuration)
            $0.setImage(image, for: .normal)
            $0.tintColor = .white
            $0.addAction(settingsAction, for: .touchUpInside)
            $0.backgroundColor = .white.withAlphaComponent(0.2)
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = 16
            $0.widthAnchor.constraint(equalToConstant: 44).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
            containerView.addSubview($0)
        }.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor + 20
            $0.trailing == containerView.trailingAnchor - 20
        }
    }
    
    private var settingsAction: UIAction {
        UIAction(handler: { [weak self] _ in self?.toggleSettings() })
    }
    
    private func toggleSettings() {
        if settingsIsShowing {
            settingsIsShowing = false
            
            UIView.animate(withDuration: 0.6,
                          delay: 0,
                          usingSpringWithDamping: 0.8,
                          initialSpringVelocity: 0.6,
                          options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState])
            {
                self.containerView.transform = .identity
                self.settingsView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.settingsView.layer.opacity = 0
            }
        } else {
            settingsIsShowing = true
            
            UIView.animate(withDuration: 0.6,
                          delay: 0,
                          usingSpringWithDamping: 0.8,
                          initialSpringVelocity: 0.6,
                          options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState])
            {
                self.containerView.transform = CGAffineTransform(translationX: 0, y: self.maxSettingsTranslation)
                    .concatenating(CGAffineTransform(scaleX: self.scaleFactorWhenSettingsVisible,
                                                   y: self.scaleFactorWhenSettingsVisible))
                self.settingsView.transform = .identity
                self.settingsView.layer.opacity = 1
            }
        }
    }
    
    private var settingsIsShowing: Bool = false
    
    private func setupSettings() {
        settingsView.backgroundColor = .white
        
        settingsView.then {
            view.insertSubview($0, belowSubview: containerView)
        }.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
        }
        
        let gitHubLink = UIButton(type: .custom)
        let gitHubLinkAS = NSAttributedString(
            string: "View project on GitHub",
            attributes: [
                NSAttributedString.Key.kern: -0.2,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light),
                NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.9)
            ]
        )
        gitHubLink.setAttributedTitle(gitHubLinkAS, for: .normal)
        gitHubLink.then {
            settingsView.addSubview($0)
            $0.addAction(UIAction { _ in
                    UIApplication.shared.open(URL(string: "https://github.com/yihui-hu/YUI")!)
                }, for: .touchUpInside)
        }.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor + 20
            $0.leading == settingsView.leadingAnchor + 20
        }
        
        let siteLink = UIButton(type: .custom)
        let siteLinkAS = NSAttributedString(
            string: "View other works",
            attributes: [
                NSAttributedString.Key.kern: -0.2,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light),
                NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.9)
            ]
        )
        siteLink.setAttributedTitle(siteLinkAS, for: .normal)
        siteLink.then {
            settingsView.addSubview($0)
            $0.addAction(UIAction { _ in
                    UIApplication.shared.open(URL(string: "https://yihui.work")!)
                }, for: .touchUpInside)
        }.layout {
            $0.top == gitHubLink.bottomAnchor + 4
            $0.leading == settingsView.leadingAnchor + 20
        }
        
        let twitterLink = UIButton(type: .custom)
        let twitterLinkAS = NSAttributedString(
            string: "Follow on Twitter",
            attributes: [
                NSAttributedString.Key.kern: -0.2,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light),
                NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.9)
            ]
        )
        twitterLink.setAttributedTitle(twitterLinkAS, for: .normal)
        twitterLink.then {
            settingsView.addSubview($0)
            $0.addAction(UIAction { _ in
                    UIApplication.shared.open(URL(string: "https://twitter.com/_yihui")!)
                }, for: .touchUpInside)
        }.layout {
            $0.top == siteLink.bottomAnchor + 4
            $0.leading == settingsView.leadingAnchor + 20
        }
    }
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        gesture.delegate = self
        return gesture
    }()

    private var initialPanTransform: CGAffineTransform = .identity
    private let maxSettingsTranslation: CGFloat = UIScreen.main.bounds.height * 0.5
    private let scaleFactorWhenSettingsVisible: CGFloat = 0.96
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            initialPanTransform = containerView.transform
            
        case .changed:
            let progress = abs(translation.y / maxSettingsTranslation)
            
            if !settingsIsShowing, translation.y >= 0 {
                let scale = 1.0 - ((1.0 - scaleFactorWhenSettingsVisible) * progress)
                let currentTransform = CGAffineTransform(translationX: 0, y: translation.y)
                    .concatenating(CGAffineTransform(scaleX: scale, y: scale))
                
                containerView.transform = currentTransform
                settingsView.transform = CGAffineTransform(scaleX: 0.9 + (0.1 * progress),
                                                           y: 0.9 + (0.1 * progress))
                settingsView.layer.opacity = Float(progress)
            } else if settingsIsShowing, translation.y <= 0 {
                let scale = 1 + ((1 - scaleFactorWhenSettingsVisible) * progress)
                let currentTransform = CGAffineTransform(translationX: 0, y: translation.y)
                    .concatenating(CGAffineTransform(scaleX: scale, y: scale))
                
                containerView.transform = initialPanTransform.concatenating(currentTransform)
                settingsView.transform = CGAffineTransform(scaleX: 1 - (0.1 * progress),
                                                           y: 1 - (0.1 * progress))
                settingsView.layer.opacity = Float(1 - progress)
            }
            
        case .ended, .cancelled:
            let shouldShowSettings: Bool
            
            if abs(velocity.y) > 500 {
                shouldShowSettings = velocity.y > 0
            } else {
                let progress = translation.y / maxSettingsTranslation
                shouldShowSettings = progress > 0.5
            }
            
            if shouldShowSettings != settingsIsShowing {
                toggleSettings()
            } else {
                UIView.animate(withDuration: 0.4,
                             delay: 0,
                             usingSpringWithDamping: 1,
                             initialSpringVelocity: 0,
                             options: [.curveEaseOut])
                {
                    if self.settingsIsShowing {
                        self.containerView.transform = CGAffineTransform(translationX: 0, y: self.maxSettingsTranslation)
                            .concatenating(CGAffineTransform(scaleX: self.scaleFactorWhenSettingsVisible,
                                                           y: self.scaleFactorWhenSettingsVisible))
                        self.settingsView.transform = .identity
                        self.settingsView.layer.opacity = 1
                    } else {
                        self.containerView.transform = .identity
                        self.settingsView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        self.settingsView.layer.opacity = 0
                    }
                }
            }
            
        default:
            break
        }
    }
}

extension HomeView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // To prevent conflict with scrolling of UICollectionView, check
        // if vertical movement is significantly more than horizontal
        if otherGestureRecognizer.view is UICollectionView {
            if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = panGesture.velocity(in: view)
                return abs(velocity.y) > abs(velocity.x) * 1.5
            }
        }
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGesture.velocity(in: view)
        return abs(velocity.y) > abs(velocity.x) * 1.5
    }
}

extension HomeView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return homeViews.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewCell.identifier,
                                                      for: indexPath) as! HomeViewCell
        
        guard let viewController = homeViews[indexPath.item] as? ViewControllerIdentifiable else { return cell }
        
        // Configure cell with preview image of destination view controller
        let image = UIImage(named: viewController.stringIdentifier)
        cell.configure(image: image, title: viewController.nameIdentifier)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath)
    
    {
        if settingsIsShowing {
            settingsIsShowing = false
            
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 2,
                           initialSpringVelocity: 0,
                           options: [.curveEaseInOut, .allowUserInteraction])
            {
                self.containerView.transform = .identity
                self.settingsView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.settingsView.layer.opacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.selectedIndexPath = indexPath
                self.navigationController?.pushViewController(self.homeViews[indexPath.item],
                                                              animated: true)
            }
        } else {
            self.selectedIndexPath = indexPath
            self.navigationController?.pushViewController(self.homeViews[indexPath.item],
                                                          animated: true)
        }
    }
}

extension HomeView: UINavigationControllerDelegate {
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
}

extension HomeView {
    // Hide home bar
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

extension HomeView: HomeTransitioning {
    var sharedView: UIView? {
        guard let selectedIndexPath,
              let cell = collectionView.cellForItem(at: selectedIndexPath) as? HomeViewCell else
        {
            return nil
        }
        
        // Recreate a snapshot of the cell instead of returning the cell itself
        let snapshotView = UIView(frame: cell.imageContainer.frameInWindow ?? cell.imageContainer.frame)
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
