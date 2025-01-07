import UIKit

class ModalCardView: UIViewController, ViewControllerIdentifiable {
    var stringIdentifier: String = "ModalCardView"
    var nameIdentifier: String = "Modal Card"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupInteractiveCard()
        setupBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupView() {
        view.backgroundColor = .white
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

extension ModalCardView: HomeTransitioning {
    var sharedView: UIView? {
        return UIView()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
