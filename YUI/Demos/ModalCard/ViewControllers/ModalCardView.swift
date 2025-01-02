import UIKit

class ModalCardView: UIViewController, IdentifiableViewController {
    var stringIdentifier: String = "ModalCardView"

    var startX = CGFloat(0)
    private let transitionAnimator = FBPaperTransitionAnimationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupInteractiveCard()
        setupBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }

    func setupInteractiveCard() {
        let cardView = ModalCard()
        
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        cardView.updateLayout(for: .half, animated: false)
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

private extension ModalCardView {
    func setupView() {
        view.backgroundColor = .white
    }
}

extension ModalCardView: UINavigationControllerDelegate {
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

extension ModalCardView: FBPaperTransitioning {
    var sharedView: UIView? {
        return UIView()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
