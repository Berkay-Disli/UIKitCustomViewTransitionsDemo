import UIKit

class HomeViewCell: UICollectionViewCell {
    public let imageContainer = UIView()
    public let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.then {
            $0.textAlignment = .left
            addSubview($0)
        }.layout {
            $0.top == topAnchor
            $0.leading == leadingAnchor + 20
            $0.trailing == trailingAnchor
            $0.height == 40
        }
        
        imageContainer.then {
            $0.backgroundColor = .white.withAlphaComponent(0.2)
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = max(0, UIScreen.main.displayCornerRadius - 32)
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.clipsToBounds = true
            addSubview($0)
        }.layout {
            $0.top == titleLabel.bottomAnchor
            $0.leading == leadingAnchor
            $0.trailing == trailingAnchor
            $0.bottom == bottomAnchor
        }
    }
    
    func configure(image: UIImage?, title: String?) {
        // Clean up existing image
        imageContainer.subviews.forEach { $0.removeFromSuperview() }
        
        // Add new image if available
        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.do {
                $0.contentMode = .scaleAspectFill
                imageContainer.addSubview($0)
                imageContainer.fillWith($0)
            }
        }
        
        let titleAS = NSAttributedString(
            string: title!,
            attributes: [
                NSAttributedString.Key.kern: -0.2,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular),
                NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
        )
        titleLabel.attributedText = titleAS
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerCurve = .continuous
        layer.cornerRadius = max(0, UIScreen.main.displayCornerRadius - 32)
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageContainer.subviews.forEach { $0.removeFromSuperview() }
        titleLabel.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
