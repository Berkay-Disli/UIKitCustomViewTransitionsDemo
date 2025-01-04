import UIKit

final class PathClockTooltip: UIView {
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.cgColor
        ]
        layer.locations = [0.0, 1.0]
        return layer
    }()
    
    private lazy var pathTooltipLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    
    private lazy var clockContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var clockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Clock")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.opacity = 0.5
        return imageView
    }()
    
    private lazy var hourHand: UIView = {
        let view = UIView()
        view.backgroundColor = .pathRed
        return view
    }()
    
    private lazy var minuteHand: UIView = {
        let view = UIView()
        view.backgroundColor = .pathRed
        return view
    }()
    
    private lazy var clockCenterDetail: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.pathRed.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 3
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        layer.insertSublayer(gradientLayer, at: 0)
        layer.mask = pathTooltipLayer
        
        addSubview(timeLabel)
        addSubview(clockContainerView)
        clockContainerView.addSubview(clockImageView)
        clockContainerView.addSubview(hourHand)
        clockContainerView.addSubview(minuteHand)
        clockContainerView.addSubview(clockCenterDetail)
        
        clockContainerView.translatesAutoresizingMaskIntoConstraints = false
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        clockCenterDetail.translatesAutoresizingMaskIntoConstraints = false
        hourHand.translatesAutoresizingMaskIntoConstraints = false
        minuteHand.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            clockContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            clockContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            clockContainerView.widthAnchor.constraint(equalTo: heightAnchor, constant: -10),
            clockContainerView.heightAnchor.constraint(equalTo: heightAnchor, constant: -10),
            
            clockImageView.centerXAnchor.constraint(equalTo: clockContainerView.centerXAnchor),
            clockImageView.centerYAnchor.constraint(equalTo: clockContainerView.centerYAnchor),
            clockImageView.widthAnchor.constraint(equalTo: clockContainerView.widthAnchor),
            clockImageView.heightAnchor.constraint(equalTo: clockContainerView.heightAnchor),
            
            clockCenterDetail.centerXAnchor.constraint(equalTo: clockContainerView.centerXAnchor),
            clockCenterDetail.centerYAnchor.constraint(equalTo: clockContainerView.centerYAnchor),
            clockCenterDetail.widthAnchor.constraint(equalToConstant: 6),
            clockCenterDetail.heightAnchor.constraint(equalToConstant: 6),
            
            hourHand.centerXAnchor.constraint(equalTo: clockImageView.centerXAnchor),
            hourHand.centerYAnchor.constraint(equalTo: clockImageView.centerYAnchor),
            hourHand.widthAnchor.constraint(equalToConstant: 3),
            hourHand.heightAnchor.constraint(equalTo: clockImageView.heightAnchor, multiplier: 0.3),
            
            minuteHand.centerXAnchor.constraint(equalTo: clockImageView.centerXAnchor),
            minuteHand.centerYAnchor.constraint(equalTo: clockImageView.centerYAnchor),
            minuteHand.widthAnchor.constraint(equalToConstant: 3),
            minuteHand.heightAnchor.constraint(equalTo: clockImageView.heightAnchor, multiplier: 0.4),
            
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: clockContainerView.trailingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
        
        setupClockHands()
    }
    
    private func setupClockHands() {
        hourHand.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        minuteHand.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        hourHand.layer.cornerRadius = 1.5
        minuteHand.layer.cornerRadius = 1.5
        
        updateClockHands(Date())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateTooltipPath()
        clockContainerView.layer.cornerRadius = clockContainerView.bounds.height / 2
        gradientLayer.frame = bounds
        
        if let currentTime = (timeLabel.text?.components(separatedBy: "\n").first).flatMap({ timeString in
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.date(from: timeString)
        }) {
            updateClockHands(currentTime)
        }
    }
    
    private func updateTooltipPath() {
        let path = UIBezierPath()
        let radius = bounds.height / 2
        let caratWidth: CGFloat = 12
        
        path.move(to: CGPoint(x: radius, y: 0)) // Begin with top left point
        path.addLine(to: CGPoint(x: bounds.width - caratWidth, y: 0)) // Draw top edge
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2)) // Draw carat...
        path.addLine(to: CGPoint(x: bounds.width - caratWidth, y: bounds.height)) // Complete carat...
        path.addLine(to: CGPoint(x: radius, y: bounds.height)) // Draw bottom edge
        path.addArc(withCenter: CGPoint(x: radius, y: bounds.height / 2),
                    radius: radius,
                    startAngle: .pi / 2,
                    endAngle: -.pi / 2,
                    clockwise: true) // Draw arc for clock to rest in
        path.close()
        
        pathTooltipLayer.path = path.cgPath
    }
    
    private func updateClockHands(_ date: Date) {
        let calendar = Calendar.current
        let hour = CGFloat(calendar.component(.hour, from: date) % 12)
        let minute = CGFloat(calendar.component(.minute, from: date))
        
        let hourAngle = ((hour + minute / 60) / 12) * 2 * .pi
        let minuteAngle = (minute / 60) * 2 * .pi
        
        hourHand.transform = CGAffineTransform(rotationAngle: hourAngle)
        minuteHand.transform = CGAffineTransform(rotationAngle: minuteAngle)
    }
    
    func updateTime(date: Date, text: String) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 2,
                       initialSpringVelocity: 0.2,
                       options: [.beginFromCurrentState])
        {
            self.timeLabel.text = text
            self.updateClockHands(date)
            self.layoutIfNeeded()
        }
    }
}
