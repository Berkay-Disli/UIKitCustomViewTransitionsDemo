import UIKit

final class UntitledGridView: UIViewController, IdentifiableViewController {
    var stringIdentifier: String = "UntitledGridView"
    
    private enum Constants {
        static let numberOfCols = 2
        static let sectionInset: UIEdgeInsets = .init(top: 72, left: 32,
                                                      bottom: 32, right: 32)
        static let interItemSpacing: CGFloat = 32
        static let lineSpacing: CGFloat = 40
    }
    
    private let transitionAnimator = UntitledTransitionAnimationController()
    private let fbPaperTransitionAnimator = FBPaperTransitionAnimationController()
    private let header = UntitledGridViewHeader(title: "[untitled]")
    private var selectedIndexPath: IndexPath?
    private var albumImages: [UIImage] = [
        UIImage(named: "CarpetGolf")!,
        UIImage(named: "CURB")!,
        UIImage(named: "Sobs")!,
        UIImage(named: "SubsonicEye")!,
        UIImage(named: "toe")!,
        UIImage(named: "HikaruUtada")!,
        UIImage(named: "NoPartyForCaoDong")!,
        UIImage(named: "Nujabes")!,
        UIImage(named: "PorterRobinson")!,
        UIImage(named: "TwoDoorCinemaClub")!,
    ]
    
    private lazy var layout = UICollectionViewFlowLayout().then {
        $0.sectionInset = Constants.sectionInset
        $0.minimumLineSpacing = Constants.lineSpacing
        $0.minimumInteritemSpacing = Constants.interItemSpacing
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.delaysContentTouches = false
        $0.backgroundColor = .white
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
    
    private func setupView() {
        view.backgroundColor = .untitledGrey
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        
        setupCollectionView()
        setupHeader()
        setupBackButton()
    }
    
    private func setupHeader() {
        header.then {
            view.addSubview($0)
        }.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
    }
    
    private func setupCollectionView() {
        collectionView.then {
            $0.backgroundColor = .untitledGrey
            $0.showsVerticalScrollIndicator = false
            view.addSubview($0)
        }.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
        }
    }
    
    private var backButtonAction: UIAction {
        UIAction(handler: { [weak self] _ in self?.navigationController?.popViewController(animated: true) })
    }
    
    private func setupBackButton() {
        let backButton = BackButton(customTintColor: .white)
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

extension UntitledGridView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int
    {
        return albumImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.identifier,
                                                      for: indexPath) as! AlbumCell
        
        let albumImage = albumImages[indexPath.item]
        cell.setupWithUIImage(with: albumImage)
        
        return cell
    }
}

extension UntitledGridView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedIndexPath = indexPath
        let image = albumImages[indexPath.item]
        let untitledDetailView = UntitledDetailView(image: image)
        self.navigationController?.pushViewController(untitledDetailView, animated: true)
    }
}

extension UntitledGridView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let spacingWidth = CGFloat(Constants.numberOfCols - 1) * Constants.interItemSpacing
        let contentWidth = collectionView.frame.inset(by: Constants.sectionInset).width
        let availableWidth = contentWidth - spacingWidth
        let size = availableWidth / CGFloat(Constants.numberOfCols)
        return CGSize(width: size, height: size)
    }
}

extension UntitledGridView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if fromVC is Self, toVC is UntitledDetailView {
            transitionAnimator.transition = .push
            return transitionAnimator
        } else if toVC is Self, fromVC is UntitledDetailView {
            transitionAnimator.transition = .pop
            return transitionAnimator
        } else if toVC is FBPaperHomeView, fromVC is Self {
            fbPaperTransitionAnimator.transition = .pop
            return fbPaperTransitionAnimator
        }
        
        return nil
    }
}

extension UntitledGridView: SharedTransitioning, FBPaperTransitioning {
    var sharedFrame: CGRect {
        guard let selectedIndexPath,
              let cell = collectionView.cellForItem(at: selectedIndexPath),
              let frame = cell.frameInWindow else { return .zero }
        return frame
    }
    
    var sharedView: UIView? {
        guard let selectedIndexPath,
              let cell = collectionView.cellForItem(at: selectedIndexPath) as? AlbumCell else
        {
            // We don't return nil here to support FBPaperTransitioning
            // TODO: Clean up
            return UIView()
        }
        
        // Recreate a snapshot of the cell instead of returning the cell itself
        let snapshotView = UIView(frame: cell.frameInWindow ?? cell.frame)
        let imageView = UIImageView(image: albumImages[selectedIndexPath.item])
        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = true
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = 16
            snapshotView.addSubview($0)
            snapshotView.fillWith($0)
        }
        
        return snapshotView
    }

    func prepare(for transition: TransitionType) {
        guard transition == .pop, let selectedIndexPath else { return }
        collectionView.verticalScrollItemVisible(at: selectedIndexPath,
                                                 withPadding: 120, animated: false)
    }
}
