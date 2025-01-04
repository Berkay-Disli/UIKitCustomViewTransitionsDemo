import UIKit

struct PathItem {
    let date: Date
    let relativeDate: String
    let username: String
    let description: String
}

final class PathItemCell: UICollectionViewCell {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    private let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = .gray
        
        return dateLabel
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        usernameLabel.textColor = .black
        
        usernameLabel.layer.shadowColor = UIColor.white.cgColor
        usernameLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        usernameLabel.layer.shadowOpacity = 1
        usernameLabel.layer.shadowRadius = 0
        
        return usernameLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
        
        descriptionLabel.layer.shadowColor = UIColor.white.cgColor
        descriptionLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        descriptionLabel.layer.shadowOpacity = 1
        descriptionLabel.layer.shadowRadius = 0
        
        return descriptionLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.do {
            $0.addSubview(stackView)
        }
        
        stackView.then {
            $0.addArrangedSubview(dateLabel)
            $0.addArrangedSubview(usernameLabel)
            $0.addArrangedSubview(descriptionLabel)
        }.layout {
            $0.top == contentView.topAnchor + 16
            $0.leading == contentView.leadingAnchor + 16
            $0.trailing == contentView.trailingAnchor - 16
            $0.bottom == contentView.bottomAnchor - 16
        }
        
        dateLabel.layout { $0.height == 20 }
        usernameLabel.layout { $0.height == 20 }
        descriptionLabel.layout { $0.height >= 20 }
        
        // Add subtle bottom border
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor.black.withAlphaComponent(0.1).cgColor
        bottomBorder.frame = CGRect(x: 0,
                                    y: contentView.bounds.height - 1,
                                    width: contentView.bounds.width,
                                    height: 1)
        contentView.layer.addSublayer(bottomBorder)
        contentView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update border frame when cell size changes
        if let bottomBorder = contentView.layer.sublayers?.first(where: { $0.frame.height == 1 })
        {
            bottomBorder.frame = CGRect(x: 0,
                                        y: contentView.bounds.height - 1,
                                        width: contentView.bounds.width,
                                        height: 1)
        }
    }
    
    func configure(with item: PathItem) {
        dateLabel.text = item.relativeDate
        usernameLabel.text = item.username
        descriptionLabel.text = item.description
        
        setNeedsLayout()
    }
}
