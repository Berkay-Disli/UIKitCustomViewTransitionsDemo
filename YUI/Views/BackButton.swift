import UIKit

final class BackButton: UIButton {
    private let buttonSize: CGFloat = 52
    private let customTintColor: UIColor
    private let blurStyle: UIBlurEffect.Style
    var backNavigation: (() -> Void)?
    
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = buttonSize / 2
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
        
    private lazy var chevronImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let image = UIImage(systemName: "arrow.left", withConfiguration: config)?
            .withTintColor(customTintColor, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    init(customTintColor: UIColor = .white,
         blurStyle: UIBlurEffect.Style = .systemUltraThinMaterial)
    {
        self.blurStyle = blurStyle
        self.customTintColor = customTintColor
        
        super.init(frame: .zero)
        
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        blurView.do {
            addSubview($0)
            fillWith($0)
        }

        chevronImageView.then {
            blurView.contentView.addSubview($0)
        }.layout {
            $0.centerX == blurView.centerXAnchor
            $0.centerY == blurView.centerYAnchor
        }
        
        layout {
            $0.size == CGSize(width: buttonSize, height: buttonSize)
        }
    }
    
    @objc private func handleTap() {
        backNavigation?()
    }
}
