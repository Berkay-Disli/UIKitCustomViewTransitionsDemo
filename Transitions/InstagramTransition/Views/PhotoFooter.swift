import UIKit

class PhotoFooter: UIView {
    private let stackView = UIStackView()
    private let heartIconView = UIImageView()
    private let messageIconView = UIImageView()
    private let sendIconView = UIImageView()
    private let bookMarkIconView = UIImageView()
    private let dateLabel = UILabel()

    init(date: String) {
        super.init(frame: .zero)
        dateLabel.text = date
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoFooter {
    private func setupView() {
        setupStackView()
        addIcon("heart", imageView: heartIconView)
        addIcon("message", imageView: messageIconView)
        addIcon("paperplane", imageView: sendIconView)
        setupBookMarkIconView()
        setupDateLabel()
    }

    private func setupStackView() {
        stackView.then {
            addSubview($0)
            $0.axis = .horizontal
            $0.alignment = .center
        }.layout {
            $0.leading == leadingAnchor + 8
            $0.top == topAnchor
        }
    }

    private func addIcon(_ iconName: String, imageView: UIImageView) {
        imageView.then {
            stackView.addArrangedSubview($0)
            stackView.setCustomSpacing(16, after: $0)
            let configuration = UIImage.SymbolConfiguration(weight: .semibold)
            $0.image = UIImage(systemName: iconName,
                               withConfiguration: configuration)
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .black
        }.layout {
            $0.size == CGSize(width: 28, height: 28)
        }
    }

    private func setupBookMarkIconView() {
        bookMarkIconView.then {
            addSubview($0)
            let configuration = UIImage.SymbolConfiguration(weight: .semibold)
            $0.image = UIImage(systemName: "bookmark",
                               withConfiguration: configuration)
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .black
        }.layout {
            $0.trailing == trailingAnchor - 8
            $0.size == CGSize(width: 28, height: 28)
            $0.centerY == stackView.centerYAnchor
        }
    }

    private func setupDateLabel() {
        dateLabel.then {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .gray
            addSubview($0)
        }.layout {
            $0.top == stackView.bottomAnchor + 8
            $0.leading == leadingAnchor + 12
            $0.bottom == bottomAnchor
        }
    }
}
