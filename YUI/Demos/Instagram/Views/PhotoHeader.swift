import UIKit

class PhotoHeader: UIView {
    private let stackView = UIStackView()
    private let filenameLabel = UILabel()
    private let moreIconView = UIImageView()

    var filename: String = "" {
        didSet {
            filenameLabel.text = filename
        }
    }

    init(filename: String = "") {
        super.init(frame: .zero)
        self.filename = filename
        setupView()
        filenameLabel.text = filename
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoHeader {
    private func setupView() {
        setupStackView()
        setupFilenameLabel()
        setupMoreIconView()
    }

    private func setupStackView() {
        stackView.do {
            addSubview($0)
            fillWith($0, insets: .init(top: 0, left: 8, bottom: 0, right: 16))
            $0.axis = .horizontal
            $0.alignment = .center
        }
    }

    private func setupFilenameLabel() {
        filenameLabel.do {
            stackView.addArrangedSubview($0)
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .black
        }
    }

    private func setupMoreIconView() {
        moreIconView.then {
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(systemName: "ellipsis")
            $0.tintColor = .black
            stackView.addArrangedSubview($0)
        }.layout {
            $0.size == CGSize(width: 22, height: 22)
        }
    }
}
