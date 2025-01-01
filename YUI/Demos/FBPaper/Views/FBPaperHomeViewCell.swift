import UIKit

class FBPaperHomeViewCell: UICollectionViewCell {
    private let imageContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white.withAlphaComponent(0.2)
        
        layer.cornerCurve = .continuous
        layer.cornerRadius = max(0, UIScreen.main.displayCornerRadius - 32)
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        
        setupViews()
    }
    
    private func setupViews() {
        imageContainer.do {
            addSubview($0)
            fillWith($0)
        }
    }
    
    func configure(image: UIImage?) {
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
