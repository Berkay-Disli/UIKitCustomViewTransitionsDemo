import UIKit

protocol HomeTransitioning {
    var sharedView: UIView? { get }
}

extension UIViewControllerContextTransitioning {
    func sharedViewForFBPaper(forKey key: UITransitionContextViewControllerKey) -> UIView?
    {
        let viewController = viewController(forKey: key)
        viewController?.view.layoutIfNeeded()
                
        let sharedView = (viewController as? HomeTransitioning)?.sharedView
        return sharedView
    }
}
