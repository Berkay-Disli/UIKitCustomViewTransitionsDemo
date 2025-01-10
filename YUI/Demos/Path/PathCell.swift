import UIKit

struct PathItem {
    let date: Date
    let relativeDate: String
    let username: String
    let description: String
    let location: String?
    let iconType: IconType?
    let reactionCount: Int?
    
    enum IconType {
        case location
        case sun
    }
}

final class PathItemCell: UICollectionViewCell {
    private let avatarView: UIView = {
        let avatarView = UIView()
        avatarView.backgroundColor = getRandomColor(withHueRange: 0.0...0.1)
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 20
        return avatarView
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        return stack
    }()
    
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        return label
    }()
    
    private let reactionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        button.tintColor = .black.withAlphaComponent(0.2)
        return button
    }()
    
    private let reactionCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black.withAlphaComponent(0.2)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(contentStackView)
        
        avatarView.layout {
            $0.width == 40
            $0.height == 40
        }
        
        iconContainer.layout {
            $0.width == 24
            $0.height == 24
        }
        iconContainer.layer.cornerRadius = 12
        iconContainer.addSubview(iconImageView)
        
        iconImageView.layout {
            $0.centerX == iconContainer.centerXAnchor
            $0.width == 16
            $0.height == 16
        }
        
        contentStackView.layout {
            $0.leading == contentView.leadingAnchor + 16
            $0.trailing == contentView.trailingAnchor - 16
            $0.top == contentView.topAnchor + 16
            $0.bottom == contentView.bottomAnchor - 16
        }
        
        contentStackView.addArrangedSubview(avatarView)
        
        let rightContentStack = UIStackView()
        rightContentStack.axis = .horizontal
        rightContentStack.spacing = 8
        rightContentStack.alignment = .top
        
        contentStackView.addArrangedSubview(rightContentStack)
        
        rightContentStack.addArrangedSubview(textStackView)
        textStackView.addArrangedSubview(descriptionLabel)
        textStackView.addArrangedSubview(locationLabel)
        
        let reactionStack = UIStackView()
        reactionStack.axis = .horizontal
        reactionStack.spacing = 4
        reactionStack.alignment = .center
        
        rightContentStack.addArrangedSubview(reactionStack)
        reactionStack.addArrangedSubview(reactionButton)
        reactionStack.addArrangedSubview(reactionCountLabel)
        
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor.black.withAlphaComponent(0.05).cgColor
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
        descriptionLabel.text = item.description
        locationLabel.text = item.location
        locationLabel.isHidden = item.location == nil
        
        if let iconType = item.iconType {
            iconContainer.isHidden = false
            switch iconType {
            case .sun:
                iconContainer.backgroundColor = .systemYellow
                iconImageView.image = UIImage(systemName: "sun.max.fill")
            case .location:
                iconContainer.backgroundColor = .systemBlue
                iconImageView.image = UIImage(systemName: "location.fill")
            }
        } else {
            iconContainer.isHidden = true
        }
        
        if let reactionCount = item.reactionCount {
            reactionButton.isHidden = false
            reactionCountLabel.isHidden = false
            reactionCountLabel.text = "\(reactionCount)"
        } else {
            reactionButton.isHidden = true
            reactionCountLabel.isHidden = true
        }
    }
}
