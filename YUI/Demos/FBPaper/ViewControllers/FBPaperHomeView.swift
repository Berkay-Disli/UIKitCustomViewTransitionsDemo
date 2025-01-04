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
        ModalCardView(),
        PathView(),
        TwitterSplashScreenView()
    ]
    
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
        $0.register(FBPaperHomeViewCell.self,
                    forCellWithReuseIdentifier: FBPaperHomeViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.delaysContentTouches = false
        $0.backgroundColor = .clear
    }
    
    private let transitionAnimator = FBPaperTransitionAnimationController()
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
            $0.alwaysBounceVertical = false
            view.addSubview($0)
        }.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
            
            // Create and store the height constraint
            let heightConstraint = collectionView.heightAnchor.constraint(
                equalToConstant: UIScreen.main.bounds.height * Constants.scaleFactor + 40
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
            $0.width == UIScreen.main.bounds.width * (UIScreen.main.displayCornerRadius == 0.0 ? 0.8 : 0.7)
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
        
        guard let viewController = homeViews[indexPath.item] as? ViewControllerIdentifiable else { return cell }
        
        // Configure cell with preview image of destination view controller
        let image = UIImage(named: viewController.stringIdentifier)
        cell.configure(image: image, title: viewController.nameIdentifier)
        
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
}

extension FBPaperHomeView {
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
