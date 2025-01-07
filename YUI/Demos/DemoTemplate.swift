import UIKit

final class DemoTemplate: UIViewController, ViewControllerIdentifiable {
    var stringIdentifier: String = "DemoTemplateView"
    var nameIdentifier: String = "Demo Template"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupViews() {
        // Setup views here
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

extension DemoTemplate: HomeTransitioning {
    var sharedView: UIView? {
        return UIView()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
