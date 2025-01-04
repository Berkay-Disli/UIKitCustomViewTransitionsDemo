import UIKit

class ModalCardView: UIViewController, ViewControllerIdentifiable {
    var stringIdentifier: String = "ModalCardView"
    var nameIdentifier: String = "Modal Card"

    var startX = CGFloat(0)
    private let transitionAnimator = FBPaperTransitionAnimationController()
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    
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
    
    func setupView() {
        view.backgroundColor = .white
        
        // Add pan gesture recognizer that will activate the interactive pop transition
        view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
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

extension ModalCardView: UIGestureRecognizerDelegate {
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let window = UIApplication.keyWindow!

        switch recognizer.state {
        case .began:
            let velocity = recognizer.velocity(in: window)
            guard abs(velocity.x) > abs(velocity.y) else { return }
                        
        case .ended:
            let horizontalVelocity = recognizer.velocity(in: window).x
            let verticalVelocity = recognizer.velocity(in: window).y

            if horizontalVelocity > 500 && abs(horizontalVelocity) > abs(verticalVelocity)
            {
                navigationController?.popViewController(animated: true)
            }
            
        default:
            break
            // No op
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
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
