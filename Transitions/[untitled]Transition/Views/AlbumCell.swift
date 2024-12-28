import UIKit
import Photos

class AlbumCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    private func setupImageView() {
        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = true
            $0.layer.cornerCurve = .continuous
            $0.layer.cornerRadius = 16
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
        imageView.image = nil
    }
}
