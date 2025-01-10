import UIKit

struct Tweet {
    let date: Date
    let relativeDate: String
    let username: String
    let description: String
}

final class TweetCell: UICollectionViewCell {
    private lazy var profileImageView: UIView = {
        let profileImageView = UIView()
        profileImageView.clipsToBounds = true
        return profileImageView
    }()
    
    private lazy var headerView: UIView = {
        return UIView()
    }()
    
    private lazy var contentStackView: UIStackView = {
        let contentStack = UIStackView()
        contentStack.axis = .horizontal
        contentStack.spacing = 12
        contentStack.alignment = .top
        return contentStack
    }()
    
    private lazy var textStackView: UIStackView = {
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 20
        return textStack
    }()
    
    private lazy var dotSeparator: UILabel = {
        let dotSeparator = UILabel()
        dotSeparator.text = "•"
        dotSeparator.font = .systemFont(ofSize: 14)
        dotSeparator.textColor = .gray
        return dotSeparator
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        return dateLabel
    }()
    
    
    private lazy var usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        usernameLabel.textColor = .black
        return usernameLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
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
        backgroundColor = .white
        
        profileImageView.then {
            $0.layer.cornerRadius = 20
        }.layout {
            $0.width == 40
            $0.height == 40
        }
        
        usernameLabel.then {
            headerView.addSubview($0)
        }.layout {
            $0.top == headerView.topAnchor
            $0.leading == headerView.leadingAnchor
        }
        
        dotSeparator.then {
            headerView.addSubview($0)
        }.layout {
            $0.top == headerView.topAnchor
            $0.leading == usernameLabel.trailingAnchor + 4
        }
        
        dateLabel.then {
            headerView.addSubview($0)
        }.layout {
            $0.top == headerView.topAnchor
            $0.leading == dotSeparator.trailingAnchor + 4
        }
        
        textStackView.do {
            $0.addArrangedSubview(headerView)
            $0.addArrangedSubview(descriptionLabel)
        }
        
        contentStackView.do {
            $0.addArrangedSubview(profileImageView)
            $0.addArrangedSubview(textStackView)
        }
        
        contentView.do {
            $0.addSubview(contentStackView)
        }
        
        contentStackView.layout {
            $0.top == contentView.topAnchor + 12
            $0.leading == contentView.leadingAnchor + 16
            $0.trailing == contentView.trailingAnchor - 16
            $0.bottom == contentView.bottomAnchor - 12
        }
        
        let divider = UIView()
        divider.then {
            $0.backgroundColor = .twitterGray
            contentView.addSubview($0)
        }.layout {
            $0.leading == contentView.leadingAnchor
            $0.trailing == contentView.trailingAnchor
            $0.bottom == contentView.bottomAnchor
            $0.height == 0.5
        }
    }
    
    func configure(with item: Tweet) {
        usernameLabel.text = item.username
        dateLabel.text = item.relativeDate
        descriptionLabel.text = item.description
        profileImageView.backgroundColor = getRandomColor(withHueRange: 0.6...0.7)
        
        setNeedsLayout()
    }
}
