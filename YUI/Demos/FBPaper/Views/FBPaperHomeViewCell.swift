import UIKit

class FBPaperHomeViewCell: UICollectionViewCell {
   public let imageContainer = UIView()
   private let titleLabel = UILabel()
   
   override init(frame: CGRect) {
       super.init(frame: frame)
       
       setupViews()
   }
   
   private func setupViews() {
       titleLabel.do {
           $0.textColor = .white
           $0.font = .systemFont(ofSize: 16)
           $0.textAlignment = .left
           addSubview($0)
           $0.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               $0.topAnchor.constraint(equalTo: topAnchor),
               $0.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
               $0.trailingAnchor.constraint(equalTo: trailingAnchor),
               $0.heightAnchor.constraint(equalToConstant: 40)
           ])
       }
       
       imageContainer.do {
           $0.backgroundColor = .white.withAlphaComponent(0.2)
           
           addSubview($0)
           
           $0.layer.cornerCurve = .continuous
           $0.layer.cornerRadius = max(0, UIScreen.main.displayCornerRadius - 32)
           $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
           $0.clipsToBounds = true
           
           $0.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
               $0.leadingAnchor.constraint(equalTo: leadingAnchor),
               $0.trailingAnchor.constraint(equalTo: trailingAnchor),
               $0.bottomAnchor.constraint(equalTo: bottomAnchor)
           ])
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
       
       titleLabel.text = title
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
