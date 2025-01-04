import UIKit
import Photos

final class PhotoGridView: UIViewController, ViewControllerIdentifiable {
    var stringIdentifier: String = "PhotoGridView"
    var nameIdentifier: String = "Instagram"
    
    private enum Constants {
        static let numberOfCols = 4
        static let sectionInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        static let interItemSpacing: CGFloat = 1
        static let lineSpacing: CGFloat = 1
        static let pageSize = 40
    }
    
    // Define the data source type using PHAsset as the item identifier
    typealias DataSource = UICollectionViewDiffableDataSource<Int, PHAsset>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, PHAsset>
    
    private let transitionAnimator = SharedTransitionAnimationController()
    private let fbPaperTransitionAnimator = FBPaperTransitionAnimationController()
    private let header = PhotoGridViewHeader(title: "Photos")
    
    private lazy var layout = UICollectionViewFlowLayout().then {
        $0.sectionInset = Constants.sectionInset
        $0.minimumLineSpacing = Constants.lineSpacing
        $0.minimumInteritemSpacing = Constants.interItemSpacing
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        $0.delegate = self
        $0.prefetchDataSource = self
        $0.delaysContentTouches = false
        $0.backgroundColor = .white
    }
    
    private lazy var dataSource = makeDataSource()
    private var selectedIndexPath: IndexPath? = nil
    private var fetchResult: PHFetchResult<PHAsset>?
    private let imageManager = PHCachingImageManager()
    
    // Pagination state
    private var isLoadingPhotos = false
    private var currentPage = 0
    private var hasMorePhotos = true
    
    private let imageRequestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .none
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        return options
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        PHPhotoLibrary.shared().register(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupView()
        checkPhotoLibraryAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }
    
    private func checkPhotoLibraryAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            initializePhotosFetch()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                Task { @MainActor in
                    if status == .authorized || status == .limited {
                        self?.initializePhotosFetch()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func initializePhotosFetch() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        loadNextPage()
    }
    
    private func loadNextPage() {
        guard !isLoadingPhotos,
              hasMorePhotos,
              let fetchResult = fetchResult else { return }
        
        isLoadingPhotos = true
        
        let startIndex = currentPage * Constants.pageSize
        let endIndex = min(startIndex + Constants.pageSize, fetchResult.count)
        
        guard startIndex < fetchResult.count else {
            hasMorePhotos = false
            isLoadingPhotos = false
            return
        }
        
        var snapshot = dataSource.snapshot()
        if snapshot.numberOfSections == 0 {
            snapshot.appendSections([0])
        }
        
        let newAssets = (startIndex..<endIndex).map { fetchResult.object(at: $0) }
        snapshot.appendItems(newAssets, toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.isLoadingPhotos = false
            self?.currentPage += 1
            self?.hasMorePhotos = endIndex < fetchResult.count
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerCurve = .continuous
        
        setupHeader()
        setupCollectionView()
        setupBackButton()
    }
    
    private func setupHeader() {
        header.then {
            view.addSubview($0)
        }.layout {
            $0.top == view.safeAreaLayoutGuide.topAnchor + 12
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
    }
    
    private func setupCollectionView() {
        collectionView.then {
            view.addSubview($0)
        }.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == header.bottomAnchor
            $0.bottom == view.bottomAnchor
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

extension PhotoGridView {
    private func makeDataSource() -> DataSource {
        DataSource(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, asset in
                guard let self = self else { return nil }
                
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PhotoCell.identifier,
                    for: indexPath
                ) as! PhotoCell
                
                // Calculate a larger target size for better quality
                let scale = UIScreen.main.scale
                let targetSize = CGSize(
                    width: self.layout.itemSize.width * scale,
                    height: self.layout.itemSize.height * scale
                )
                
                self.imageManager.requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: self.imageRequestOptions
                ) { image, info in
                    if let image = image {
                        cell.setupWithUIImage(with: image)
                    }
                }
                
                return cell
            }
        )
    }
    
    private func updateCollectionView() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        if let fetchResult = fetchResult {
            let assets = (0..<fetchResult.count).map { fetchResult.object(at: $0) }
            snapshot.appendItems(assets, toSection: 0)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension PhotoGridView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        guard let asset = dataSource.itemIdentifier(for: indexPath) else { return }
        
        // Calculate a larger target size for better quality
        let scale = UIScreen.main.scale
        let targetSize = CGSize(
            width: self.layout.itemSize.width * scale,
            height: self.layout.itemSize.height * scale
        )
        
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: imageRequestOptions
        ) { [weak self] image, _ in
            guard let image = image else { return }
            let viewController = PhotoDetailView(image: image, asset: asset)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension PhotoGridView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacingWidth = CGFloat(Constants.numberOfCols - 1) * Constants.interItemSpacing
        let contentWidth = collectionView.frame.inset(by: Constants.sectionInset).width
        let availableWidth = contentWidth - spacingWidth
        let size = availableWidth / CGFloat(Constants.numberOfCols)
        return CGSize(width: size, height: size)
    }
}

extension PhotoGridView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        // If navigating between PhotoDetailView and PhotoGridView
        if fromVC is Self, toVC is PhotoDetailView {
            transitionAnimator.transition = .push
            return transitionAnimator
        } else if toVC is Self, fromVC is PhotoDetailView {
            transitionAnimator.transition = .pop
            return transitionAnimator
        } else if toVC is FBPaperHomeView, fromVC is Self {
            fbPaperTransitionAnimator.transition = .pop
            return fbPaperTransitionAnimator
        }
        
        // Use default animation otherwise
        return nil
    }
}

extension PhotoGridView: SharedTransitioning {
    /// Get the frame of the cell to animate into detail view during the transition.
    ///
    var sharedFrame: CGRect {
        guard let selectedIndexPath,
              let cell = collectionView.cellForItem(at: selectedIndexPath),
              let frame = cell.frameInWindow else { return .zero }
        return frame
    }
    
    /// Ensures the item is within view before the pop transition from detail view begins.
    ///
    func prepare(for transition: TransitionType) {
        guard transition == .pop, let selectedIndexPath else { return }
        collectionView.verticalScrollItemVisible(at: selectedIndexPath,
                                                 withPadding: 40, animated: false)
    }
}

extension PhotoGridView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath])
    {
        // Prefetch next page when approaching the end
        if let maxIndex = indexPaths.map({ $0.item }).max()
        {
            let totalItems = dataSource.snapshot().itemIdentifiers.count
            if maxIndex >= totalItems - 10 {
                loadNextPage()
            }
        }
    }
}

extension PhotoGridView: PHPhotoLibraryChangeObserver {
    /// Attaches a listener to the `PhotoGridView` to listen to changes to photo library
    /// (e.g. taking a photo, deleting a photo, etc.)
    ///
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor [weak self] in
            guard let self = self,
                  let fetchResult = self.fetchResult,
                  let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
            
            self.fetchResult = changes.fetchResultAfterChanges
            updateCollectionView()
        }
    }
}

extension PhotoGridView: FBPaperTransitioning {
    var sharedView: UIView? {
        return UIView()
    }
}
