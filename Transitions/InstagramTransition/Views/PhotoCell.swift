import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    var requestID: PHImageRequestID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    private func setupImageView() {
        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = true
            contentView.addSubview($0)
            contentView.fillWith($0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWithUIImage(with img: UIImage) {
        imageView.image = img
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        requestID = nil
        imageView.image = nil
    }
}
