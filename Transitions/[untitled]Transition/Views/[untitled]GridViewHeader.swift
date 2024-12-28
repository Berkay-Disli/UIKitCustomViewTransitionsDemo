import UIKit

class UntitledGridViewHeader: UIView {
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        setupView()
        titleLabel.text = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UntitledGridViewHeader {
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        setupStackView()
        setupTitleLabel()
    }
    
    private func setupStackView() {
        stackView.do {
            addSubview($0)
            fillWith($0, insets: .init(top: 20, left: 20, bottom: 20, right: 20))
            $0.axis = .horizontal
            $0.alignment = .center
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.do {
            $0.font = .systemFont(ofSize: 20, weight: .bold)
            $0.textColor = .white
            $0.setContentHuggingPriority(.required, for: .horizontal)
            stackView.addArrangedSubview($0)
        }
    }
}
