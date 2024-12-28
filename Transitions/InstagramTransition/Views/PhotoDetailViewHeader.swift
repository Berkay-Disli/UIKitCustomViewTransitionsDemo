import UIKit

class PhotoDetailViewHeader: UIView {
    private let separator = UIView()
    private let backButton = UIButton(configuration: .plain())
    var backNavigation: (() -> Void)?
        
    private var backAction: UIAction {
        UIAction(handler: { [weak self] _ in self?.backNavigation?() })
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 48)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoDetailViewHeader {
    private func setupView() {
        setupSeparator()
        setupBackButton()
    }
    
    private func setupSeparator() {
        separator.then {
            addSubview($0)
            $0.backgroundColor = .black.withAlphaComponent(0.3)
        }.layout {
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
            $0.height == 0.5
        }
    }
    
    private func setupBackButton() {
        backButton.then {
            addSubview($0)
            let configuration = UIImage.SymbolConfiguration(weight: .bold)
            let image = UIImage(systemName: "chevron.left", withConfiguration: configuration)
            $0.setImage(image, for: .normal)
            $0.tintColor = .black
            $0.addAction(backAction, for: .touchUpInside)
        }.layout {
            $0.leading == leadingAnchor + 16
            $0.top == topAnchor + 4
            $0.size == CGSize(width: 24, height: 24)
        }
    }
}
