import UIKit

final class PathView: UIViewController, IdentifiableViewController {
    var stringIdentifier: String = "PathView"
    
    enum Constants {
        static let interItemSpacing: CGFloat = 1.5
        static let lineSpacing: CGFloat = 1.5
        static let scaleFactor: CGFloat = 0.6
    }
    
    private var homeViews: [UIViewController] = [
        PhotoGridView(),
        UntitledGridView()
    ]
    
    public lazy var layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: GlobalConstants.screenW * Constants.scaleFactor,
                             height: GlobalConstants.screenH * Constants.scaleFactor)
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
        view.backgroundColor = .black
        setupBackButton()
    }
    
    private func setupLabel() {
        let pathLabel = UILabel()
        pathLabel.text = "Path"
        pathLabel.textColor = .white
        pathLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        
        pathLabel.then {
            view.addSubview($0)
        }.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
        }
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
            
            let heightConstraint = collectionView.heightAnchor.constraint(
                equalToConstant: UIScreen.main.bounds.height * Constants.scaleFactor
            )
            self.collectionViewHeightConstraint = heightConstraint
            heightConstraint.isActive = true
        }
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

extension PathView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return homeViews.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FBPaperHomeViewCell.identifier,
                                                      for: indexPath) as! FBPaperHomeViewCell
        
        guard let viewController = homeViews[indexPath.item] as? IdentifiableViewController else { return cell }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        navigationController?.pushViewController(homeViews[indexPath.item],
                                               animated: true)
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
