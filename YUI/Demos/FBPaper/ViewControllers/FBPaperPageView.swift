import UIKit

class FBPaperPageView: UIViewController {
    private var pageViewController: UIPageViewController!
    public var pages: [UIViewController] = []
    public var currentIndex: Int = 0
    
    init(initialPage: Int) {
        self.currentIndex = initialPage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageViewController()
    }
    
    private func setupPages() {
        let photoGridView = PhotoGridView()
        let untitledGridView = UntitledGridView()
        let fbPaperHomeView = FBPaperHomeView()
        
        pages = [photoGridView, untitledGridView, fbPaperHomeView]
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                navigationOrientation: .horizontal)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        // Add as child view controller
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)
        
        // Set initial page
        if !pages.isEmpty {
            pageViewController.setViewControllers([pages[currentIndex]],
                                                  direction: .forward,
                                                  animated: false)
        }
    }
}

extension FBPaperPageView: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let index = pages.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
}

extension FBPaperPageView: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                          didFinishAnimating finished: Bool,
                          previousViewControllers: [UIViewController],
                          transitionCompleted completed: Bool)
    {
        if completed, let visibleViewController = pageViewController.viewControllers?.first,
                      let index = pages.firstIndex(of: visibleViewController)
        {
            currentIndex = index
        }
    }
}

extension FBPaperPageView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        // Forward the delegate call to the current page if it implements UINavigationControllerDelegate
        if let currentVC = pages[currentIndex] as? UINavigationControllerDelegate {
            return currentVC.navigationController?(navigationController,
                                                 animationControllerFor: operation,
                                                 from: fromVC,
                                                 to: toVC)
        }
        return nil
    }
}

extension FBPaperPageView: FBPaperTransitioning {
    var sharedView: UIView? {
        return UIView()
    }
}
