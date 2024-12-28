import UIKit

class UntitledDetailViewHeader: UIView {
    private let stackView = UIStackView()
    private let backButton = UIButton(configuration: .plain())
    var backNavigation: (() -> Void)?
    
    private var backAction: UIAction {
        UIAction(handler: { [weak self] _ in self?.backNavigation?() })
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UntitledDetailViewHeader {
    private func setupView() {
        setupStackView()
        setupBackButton()
    }
    
    private func setupStackView() {
        stackView.do {
            addSubview($0)
            fillWith($0, insets: .init(top: 20, left: 20, bottom: 20, right: 20))
            $0.axis = .horizontal
            $0.alignment = .center
        }
    }
    
    private func setupBackButton() {
        backButton.do {
            let configuration = UIImage.SymbolConfiguration(weight: .bold)
            let image = UIImage(systemName: "chevron.left", withConfiguration: configuration)
            $0.setImage(image, for: .normal)
            $0.tintColor = .white
            $0.addAction(backAction, for: .touchUpInside)
            $0.setContentHuggingPriority(.required, for: .horizontal)
            
            stackView.addArrangedSubview($0)
        }
    }
}
