import UIKit

enum CardState {
    case peek
    case half
    case full
    
    var height: CGFloat {
        switch self {
        case .peek: return GlobalConstants.screenH * 0.5
        case .half: return GlobalConstants.screenH * 0.5
        case .full: return GlobalConstants.screenH * 0.8
        }
    }
    
    var bottomOffset: CGFloat {
        switch self {
        case .peek:
            return self.height - 60
        case .half, .full:
            return -12
        }
    }
}

final class ModalCard: UIView {
    private var currentState: CardState = .peek
    private var initialCenter: CGPoint = .zero
    private var originalHeight: CGFloat = 0
    
    private var mainHeightConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue.withAlphaComponent(0.2)
        view.layer.cornerRadius = 40
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])
                
        // Content view constraints
        mainHeightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        mainHeightConstraint?.isActive = true
        heightConstraint?.isActive = true
        bottomConstraint?.isActive = true
        
        let text = UILabel()
        let textAS = NSAttributedString(
            string: "Drag me up and down!",
            attributes: [
                NSAttributedString.Key.kern: -0.8,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                NSAttributedString.Key.foregroundColor: UIColor.blue.withAlphaComponent(0.2)
            ]
        )
        text.attributedText = textAS
        text.then {
            addSubview($0)
        }.layout {
            $0.centerX == contentView.centerXAnchor
            $0.centerY == contentView.centerYAnchor
        }
    }
    
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        contentView.addGestureRecognizer(panGesture)
    }
    
    func updateLayout(for state: CardState, animated: Bool = true) {
        let newHeight = state.height
        
        let animations = {
            self.mainHeightConstraint?.constant = newHeight
            self.heightConstraint?.constant = newHeight
            
            switch state {
            case .peek:
                self.bottomConstraint?.constant = newHeight - 60
            case .half, .full:
                self.bottomConstraint?.constant = -12
            }
            
            self.superview?.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0.2,
                           options: [.curveEaseInOut, .allowUserInteraction],
                           animations: animations)
        } else {
            animations()
        }
        
        currentState = state
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        let dragAmount = translation.y
        let dragVelocity = velocity.y
        let dragPercentage = abs(dragAmount) / 400
        
        switch gesture.state {
        case .began:
            initialCenter = contentView.center
            originalHeight = contentView.bounds.height
            
        case .changed:
            switch currentState {
            case .peek:
                if dragAmount < 0 {
                    let currentOffset: CGFloat = CardState.peek.bottomOffset
                    let targetOffset: CGFloat = CardState.half.bottomOffset
                    let offsetDifference = targetOffset - currentOffset
                    let newOffset = currentOffset + (offsetDifference * dragPercentage)
                    
                    bottomConstraint?.constant = newOffset
                    
                    // If we've gone past the half state height, start transitioning the view height
                    if newOffset <= CardState.half.bottomOffset {
                        let excessDrag = abs(newOffset - CardState.half.bottomOffset)
                        let heightDifference = CardState.full.height - CardState.half.height
                        let heightDragPercentage = excessDrag / 400
                        
                        let newHeight = CardState.half.height + (heightDifference * heightDragPercentage)
                        heightConstraint?.constant = newHeight
                        mainHeightConstraint?.constant = newHeight
                        bottomConstraint?.constant = CardState.half.bottomOffset
                    }
                } else {
                    
                }
                
            case .half:
                // Dragging up to full
                if dragAmount < 0 {
                    let halfHeight = CardState.half.height
                    let fullHeight = CardState.full.height
                    let heightDifference = fullHeight - halfHeight
                    
                    let newHeight = halfHeight + (heightDifference * dragPercentage)
                    
                    if newHeight > CardState.full.height {
                        // Apply rubber banding when exceeding full height
                        let excess = newHeight - CardState.full.height
                        let dampedExcess = excess * 0.2
                        let dampedHeight = CardState.full.height + dampedExcess
                        
                        heightConstraint?.constant = dampedHeight
                        mainHeightConstraint?.constant = dampedHeight
                    } else {
                        heightConstraint?.constant = newHeight
                        mainHeightConstraint?.constant = newHeight
                    }
                    
                    bottomConstraint?.constant = CardState.half.bottomOffset
                    
                // Dragging down to peek
                } else {
                    let currentOffset: CGFloat = CardState.half.bottomOffset
                    let targetOffset: CGFloat = CardState.peek.bottomOffset
                    let offsetDifference = targetOffset - currentOffset
                    let newBottomOffset = currentOffset + (offsetDifference * dragPercentage)

                    bottomConstraint?.constant = newBottomOffset
                }
                
            case .full:
                if dragAmount < 0 {
                    let fullHeight = CardState.full.height
                    let screenHeight = GlobalConstants.screenH
                    let heightDifference = screenHeight - fullHeight
                    
                    let newHeight = fullHeight + (heightDifference * dragPercentage)
                    
                    let excess = newHeight - CardState.full.height
                    let dampedExcess = excess * 0.2
                    let dampedHeight = CardState.full.height + dampedExcess
                    
                    heightConstraint?.constant = dampedHeight
                    mainHeightConstraint?.constant = dampedHeight
                } else {
                    let fullHeight = CardState.full.height
                    let halfHeight = CardState.half.height
                    let heightDifference = halfHeight - fullHeight
                    
                    let newHeight = fullHeight + (heightDifference * dragPercentage)
                    
                    if newHeight < CardState.half.height {
                        let excess = newHeight - CardState.half.height
                        let dampedExcess = excess * 0.2
                        let dampedHeight = CardState.half.height + dampedExcess
                        
                        heightConstraint?.constant = dampedHeight
                        mainHeightConstraint?.constant = dampedHeight
                        
                        let newDragAmount = max(0, translation.y - CardState.half.height + 12)
                        let newDragPercentage = abs(newDragAmount) / 400
                        
                        let currentOffset: CGFloat = CardState.half.bottomOffset
                        let targetOffset: CGFloat = CardState.peek.bottomOffset
                        let offsetDifference = targetOffset - currentOffset
                        let newBottomOffset = currentOffset + (offsetDifference * newDragPercentage)

                        bottomConstraint?.constant = newBottomOffset
                    } else {
                        heightConstraint?.constant = newHeight
                        mainHeightConstraint?.constant = newHeight
                    }
                }
            }
            
        case .ended:
            switch currentState {
            case .peek:
                if dragAmount < -CardState.half.height {
                    updateLayout(for: .full)
                } else if dragVelocity < -500 || dragAmount < -50 {
                    updateLayout(for: .half)
                } else {
                    updateLayout(for: .peek)
                }
                
            case .half:
                if dragVelocity > 500 || dragAmount > 50 {
                    updateLayout(for: .peek)
                } else if dragVelocity < -500 || dragAmount < -50 {
                    updateLayout(for: .full)
                } else {
                    updateLayout(for: .half)
                }
                
            case .full:
                if dragAmount > CardState.half.height {
                    updateLayout(for: .peek)
                } else if dragVelocity > 500 || dragAmount > 50 {
                    updateLayout(for: .half)
                } else {
                    updateLayout(for: .full)
                }
            }
            
        default:
            break
        }
    }
}
