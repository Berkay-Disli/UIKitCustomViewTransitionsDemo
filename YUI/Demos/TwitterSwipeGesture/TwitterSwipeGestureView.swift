import UIKit

final class TwitterSwipeGestureView: UIViewController, ViewControllerIdentifiable {
    var stringIdentifier: String = "TwitterSwipeGestureView"
    var nameIdentifier: String = "Twitter Swipe Gesture"
    
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    private var panningIndexPath: IndexPath?
    private var panningCell: UICollectionViewCell?
    private var tweets: [Tweet] = []
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: view.safeAreaInsets.top, left: 0,
                                           bottom: view.safeAreaInsets.bottom + 120, right: 0)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .twitterGray
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: TweetCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.indicatorStyle = .black
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: view.safeAreaInsets.top, left: 0,
                                                            bottom: view.safeAreaInsets.bottom + 120, right: 0)
        return collectionView
    }()
    
    private lazy var xMark: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)?
            .withTintColor(.black, renderingMode: .alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .black
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private lazy var xButton: UIView = {
        let xButton = UIView()
        xButton.backgroundColor = .white
        return xButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupCells()
        setupXButton()
        setupBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        collectionView.then {
            view.addSubview($0)
        }.layout {
            $0.top == view.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
        
        collectionView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }
    
    private func setupCells() {
        for i in 1...30 {
            // Generate random date
            var date = Calendar.current.date(byAdding: .day,
                                             value: -i * 3, to: Date()) ?? Date()
            date = Calendar.current.date(byAdding: .second,
                                         value: Bool.random() ? Int.random(in: -24800...0) : Int.random(in: 0...46572),
                                         to: date) ?? Date()
            
            // Convert to relative date
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let relativeDate = formatter.localizedString(for: date, relativeTo: Date.now)
            
            // Generate random text
            let description = GlobalConstants.bodyFragments.randomElement()!
            let username = GlobalConstants.usernameFragments.randomElement()!
            
            let tweet = Tweet(
                date: date,
                relativeDate: relativeDate,
                username: username,
                description: description
            )
            
            tweets.append(tweet)
        }
        collectionView.reloadData()
    }
    
    var xButtonCenterYConstraint: NSLayoutConstraint?
    var xButtonLeadingConstraint: NSLayoutConstraint?
    
    private func setupXButton() {
        xMark.then {
            xButton.addSubview($0)
        }.layout {
            $0.centerX == xButton.centerXAnchor
            $0.centerY == xButton.centerYAnchor
        }
        
        xButton.then {
            $0.layer.cornerRadius = 22
            collectionView.addSubview($0)
        }.layout {
            $0.height == 44
            $0.width == 44
        }
        
        xButton.layer.zPosition = -1
    }
    
    private func setupBackButton() {
        let backButton = BackButton(blurStyle: .systemUltraThinMaterialDark)
        backButton.backNavigation = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        backButton.then {
            view.addSubview($0)
        }.layout {
            $0.leading == view.leadingAnchor + 20
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor - 20
        }
    }
}

extension TwitterSwipeGestureView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // Calculate available width, accounting for section insets
        let availableWidth = collectionView.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        
        let cell = TweetCell()
        cell.configure(with: tweets[indexPath.item])
        
        // Calculate the required size using cell contents
        let size = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        return CGSize(width: availableWidth, height: size.height)
    }
}

extension TwitterSwipeGestureView: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return tweets.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TweetCell.identifier,
                                                      for: indexPath) as! TweetCell
        cell.configure(with: tweets[indexPath.item])
        return cell
    }
}

extension TwitterSwipeGestureView: UIGestureRecognizerDelegate {
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let window = UIApplication.keyWindow!

        switch recognizer.state {
        case .began:
            let point = recognizer.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: point),
                  let cell = collectionView.cellForItem(at: indexPath) else {
                return
            }
            
            panningIndexPath = indexPath
            panningCell = cell
            collectionView.isScrollEnabled = false
            
        case .changed:
            let horizontalDrag = recognizer.translation(in: window).x
            guard horizontalDrag < 0 else { return }
            
            let progress = min(1, abs(horizontalDrag) / (UIScreen.main.bounds.width * 0.24))
            
            guard let indexPath = panningIndexPath,
                  let cell = panningCell else
            {
                return
            }
            
            // Transform current cell first
            cell.transform = CGAffineTransform(translationX: horizontalDrag, y: 0)
            cell.layer.cornerCurve = .continuous
            cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.layer.cornerRadius = (cell.bounds.height / 5) * progress
            cell.layer.shadowColor = UIColor.black.withAlphaComponent(0.16).cgColor
            cell.layer.shadowRadius = (4 + progress) * 2
            cell.layer.shadowOpacity = Float(progress)
            cell.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.layer.zPosition = 3
            
            // Transform xButton
            xButton.layer.opacity = Float(progress)
            
            xButtonCenterYConstraint?.isActive = false
            xButtonCenterYConstraint = xButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
            xButtonCenterYConstraint?.isActive = true
            
            xButtonLeadingConstraint?.isActive = false
            xButtonLeadingConstraint = xButton.leadingAnchor.constraint(equalTo: cell.trailingAnchor,
                                                                        constant: -xButton.bounds.width / 2)
            xButtonLeadingConstraint?.isActive = true
            xButton.transform = CGAffineTransform(translationX: horizontalDrag * 0.5, y: 0)
            
            xButton.layer.zPosition = 2
            
            if progress == 1 {
                xMark.tintColor = .red
            } else {
                xMark.tintColor = .black
            }
            
            // Transform adjacent cells
            if let cellAbove = collectionView.cellForItem(at: IndexPath(row: indexPath.row + 1,
                                                                        section: indexPath.section))
            {
                cellAbove.layer.cornerCurve = .continuous
                cellAbove.layer.maskedCorners = [.layerMaxXMinYCorner]
                cellAbove.layer.cornerRadius = (cell.bounds.height / 3) * progress
            }
            if let cellBelow = collectionView.cellForItem(at: IndexPath(row: indexPath.row - 1,
                                                                        section: indexPath.section))
            {
                cellBelow.layer.cornerCurve = .continuous
                cellBelow.layer.maskedCorners = [.layerMaxXMaxYCorner]
                cellBelow.layer.cornerRadius = (cell.bounds.height / 3) * progress
            }
            
            collectionView.isScrollEnabled = true
            
        case .ended:
            let horizontalDrag = recognizer.translation(in: window).x
            guard horizontalDrag < 0 else { return }
            
            let progress = min(1, abs(horizontalDrag) / (UIScreen.main.bounds.width * 0.24))
            
            guard let indexPath = panningIndexPath,
                  let cell = panningCell else
            {
                return
            }
            
            // Function to reset cells to their initial states
            let resetCellStates = {
                cell.transform = .identity
                cell.layer.cornerRadius = 0
                cell.layer.shadowRadius = 0
                cell.layer.shadowOpacity = 0
                cell.layer.zPosition = 1
                
                self.xMark.tintColor = .black
                self.xButton.transform = .identity
                self.xButton.layer.opacity = 0
                self.xButton.layer.zPosition = -1
                
                if let cellAbove = self.collectionView.cellForItem(at: IndexPath(row: indexPath.row + 1,
                                                                               section: indexPath.section))
                {
                    cellAbove.transform = .identity
                    cellAbove.layer.cornerRadius = 0
                }
                if let cellBelow = self.collectionView.cellForItem(at: IndexPath(row: indexPath.row - 1,
                                                                               section: indexPath.section))
                {
                    cellBelow.transform = .identity
                    cellBelow.layer.cornerRadius = 0
                }
            }
            
            // Animate cell deletion if threshold is hit
            if progress == 1 {
                tweets.remove(at: indexPath.row)
                
                UIView.animate(withDuration: 0.2) {
                    cell.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
                    cell.alpha = 0
                    
                    self.xButton.transform = .identity
                    self.xButton.layer.opacity = 0
                    self.xButton.layer.zPosition = -1
                    
                    if let cellAbove = self.collectionView.cellForItem(at: IndexPath(row: indexPath.row + 1,
                                                                                   section: indexPath.section))
                    {
                        cellAbove.transform = .identity
                        cellAbove.layer.cornerRadius = 0
                    }
                    if let cellBelow = self.collectionView.cellForItem(at: IndexPath(row: indexPath.row - 1,
                                                                                   section: indexPath.section))
                    {
                        cellBelow.transform = .identity
                        cellBelow.layer.cornerRadius = 0
                    }
                } completion: { _ in
                    self.collectionView.deleteItems(at: [indexPath])
                    
                    resetCellStates()
                }
            } else {
                UIView.animate(withDuration: 0.4,
                               delay: 0,
                               usingSpringWithDamping: 1,
                               initialSpringVelocity: 0,
                               options: [.curveEaseOut])
                {
                    resetCellStates()
                }
            }
            
            panningIndexPath = nil
            panningCell = nil
            collectionView.isScrollEnabled = true
            
        default:
            collectionView.isScrollEnabled = true
        }
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // To prevent conflict with scrolling of UICollectionView, check
        // if horizontal movement is significantly more than vertical
        if otherGestureRecognizer.view is UICollectionView {
            if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = panGesture.velocity(in: view)
                return abs(velocity.x) > abs(velocity.y) * 1.5
            }
        }
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGesture.velocity(in: view)
        return abs(velocity.x) > abs(velocity.y) * 1.5
    }
}


extension TwitterSwipeGestureView: HomeTransitioning {
    var sharedView: UIView? {
        return UIView()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
