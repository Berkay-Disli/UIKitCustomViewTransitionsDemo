import UIKit

class UntitledDetailViewHeader: UIView {
    private let stackView = UIStackView()
    private let backButton = UIButton(configuration: .plain())
    private let rightStackView = UIStackView()
    private let linkButton = UIButton(configuration: .plain())
    private let moreButton = UIButton(configuration: .plain())
    
    var backNavigation: (() -> Void)?
    var linkNavigation: (() -> Void)?
    var moreNavigation: (() -> Void)?
    
    private var backAction: UIAction {
        UIAction(handler: { [weak self] _ in self?.backNavigation?() })
    }
    
    private var linkAction: UIAction {
        UIAction(handler: { [weak self] _ in self?.linkNavigation?() })
    }
    
    private var moreAction: UIAction {
        UIAction(handler: { [weak self] _ in self?.moreNavigation?() })
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
        setupRightButtons()
    }
    
    private func setupStackView() {
        stackView.do {
            addSubview($0)
            fillWith($0, insets: .init(top: 20, left: 20, bottom: 20, right: 20))
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
    }
    
    private func setupBackButton() {
        backButton.do {
            let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
            let image = UIImage(systemName: "chevron.left", withConfiguration: configuration)
            $0.setImage(image, for: .normal)
            $0.tintColor = .white
            $0.addAction(backAction, for: .touchUpInside)
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = 16
            $0.widthAnchor.constraint(equalToConstant: 44).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setupRightButtons() {
        rightStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
            stackView.addArrangedSubview($0)
        }
        
        linkButton.do {
            let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
            let image = UIImage(systemName: "link", withConfiguration: configuration)
            $0.setImage(image, for: .normal)
            $0.tintColor = .white
            $0.addAction(linkAction, for: .touchUpInside)
            $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = 16
            $0.widthAnchor.constraint(equalToConstant: 44).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            rightStackView.addArrangedSubview($0)
        }
        
        moreButton.do {
            let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
            let image = UIImage(systemName: "ellipsis", withConfiguration: configuration)
            $0.setImage(image, for: .normal)
            $0.tintColor = .white
            $0.addAction(moreAction, for: .touchUpInside)
            $0.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = 16
            $0.widthAnchor.constraint(equalToConstant: 44).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            rightStackView.addArrangedSubview($0)
        }
    }
}
