import UIKit

class PhotoGridViewHeader: UIView {
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        setupView()
        
        let attributedString = NSAttributedString(
            string: title,
            attributes: [
                NSAttributedString.Key.kern: -1.0,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .bold),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        titleLabel.attributedText = attributedString
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoGridViewHeader {
    private func setupView() {
        setupStackView()
        setupTitleLabel()
    }
    
    private func setupStackView() {
        stackView.do {
            addSubview($0)
            fillWith($0, insets: .init(top: 0, left: 16, bottom: 12, right: 12))
            $0.axis = .horizontal
            $0.alignment = .center
        }
    }
    
    private func setupTitleLabel() {
        titleLabel.do {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            stackView.addArrangedSubview($0)
        }
    }
}
