import UIKit

final class PathView: UIViewController, IdentifiableViewController {
    var stringIdentifier: String = "PathView"
    
    private let transitionAnimator = FBPaperTransitionAnimationController()
    public var selectedIndexPath: IndexPath?
    
    private lazy var clockTooltip = PathClockTooltip()
    private var tooltipTimer: Timer?
    private var pathItems: [PathItem] = []
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom + 120, right: 0)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .pathBackground
        collectionView.register(PathItemCell.self, forCellWithReuseIdentifier: PathItemCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.indicatorStyle = .black
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: view.safeAreaInsets.top, left: 0,
                                                            bottom: view.safeAreaInsets.bottom + 120, right: 0)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCells()
        setupBackButton()
        
        clockTooltip.alpha = 0
        clockTooltip.transform = CGAffineTransform(translationX: 4, y: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor.pathBackground
        
        collectionView.then {
            view.addSubview($0)
        }.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
        }
        
        clockTooltip.then {
            view.addSubview($0)
        }.layout {
            $0.trailing == view.trailingAnchor - 4
            $0.top == view.safeAreaLayoutGuide.topAnchor
            $0.height == 40
            $0.width == 120
        }
    }
    
    private func setupCells() {
        for i in 1...100 {
            // Generate random date
            var date = Calendar.current.date(byAdding: .day,
                                             value: -i * 3, to: Date()) ?? Date()
            date = Calendar.current.date(byAdding: .second,
                                         value: Bool.random() ? -i * 24800 : i * 46572,
                                         to: date) ?? Date()

            // Convert to relative date
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            let relativeDate = formatter.localizedString(for: date, relativeTo: Date.now)
            
            // Generate random text
            let description = GlobalConstants.bodyFragments.randomElement()!
            let username = GlobalConstants.usernameFragments.randomElement()!
            
            let item = PathItem(
                date: date,
                relativeDate: relativeDate,
                username: username,
                description: description
            )
            
            pathItems.append(item)
        }
        collectionView.reloadData()
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

extension PathView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // Calculate available width, accounting for section insets
        let availableWidth = collectionView.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        
        let cell = PathItemCell()
        cell.configure(with: pathItems[indexPath.item])
        
        // Calculate the required size using cell contents
        let size = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        return CGSize(width: availableWidth, height: size.height)
    }
}

extension PathView: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return pathItems.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PathItemCell.identifier,
                                                      for: indexPath) as! PathItemCell
        cell.configure(with: pathItems[indexPath.item])
        return cell
    }
}

extension PathView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateClockTooltipPosition()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tooltipTimer?.invalidate()

        UIView.animate(withDuration: 0.2) {
            self.clockTooltip.alpha = 1
            
            let currentY = self.clockTooltip.transform.ty
            self.clockTooltip.transform = CGAffineTransform(
                translationX: -8,
                y: currentY
            )
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { startOverlayHideTimer() }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startOverlayHideTimer()
    }
    
    private func startOverlayHideTimer() {
        tooltipTimer?.invalidate()
        
        tooltipTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                            repeats: false)
        { [weak self] _ in
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                self?.clockTooltip.alpha = 0
                let currentY = self?.clockTooltip.transform.ty ?? 0
                self?.clockTooltip.transform = CGAffineTransform(translationX: 4, y: currentY)
            }
        }
    }
}

extension PathView {
    private func updateClockTooltipPosition() {
        guard !pathItems.isEmpty else { return }
        
        // Calculate tooltip's center point in collection view's coordinate space
        let tooltipCenter = CGPoint(x: clockTooltip.frame.minX, y: clockTooltip.frame.midY)
        let convertedPoint = view.convert(tooltipCenter, to: collectionView)
        
        // Find the cell that intersects with the tooltip's position
        if let indexPath = collectionView.indexPathForItem(at: convertedPoint),
           indexPath.item < pathItems.count
        {
            let item = pathItems[indexPath.item]
            
            // Format dates
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeStr = timeFormatter.string(from: item.date)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let dateStr = dateFormatter.string(from: item.date)
            
            // Update overlay with new info
            clockTooltip.updateTime(
                date: item.date,
                text: "\(timeStr)\n\(dateStr)"
            )
        }
        
        // Calculate max distance tooltip can travel
        let bottomInset = view.safeAreaInsets.bottom + 120
        let maxTooltipTravel = collectionView.bounds.height - bottomInset - clockTooltip.bounds.height
        
        // Calculate normalized scroll progress (0 to 1)
        let contentHeight = collectionView.contentSize.height - collectionView.bounds.height
        let scrollProgress = min(max(collectionView.contentOffset.y / contentHeight, 0), 1)

        // Translate tooltip to new position
        self.clockTooltip.transform = CGAffineTransform(
            translationX: -8,
            y: scrollProgress * maxTooltipTravel
        )
    }
}


extension PathView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if toVC is Self {
            transitionAnimator.transition = .push
            return transitionAnimator
        } else if toVC is FBPaperHomeView, fromVC is Self {
            transitionAnimator.transition = .pop
            return transitionAnimator
        }
        return nil
    }
}

extension PathView: FBPaperTransitioning {
    var sharedView: UIView? {
        return UIView()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
