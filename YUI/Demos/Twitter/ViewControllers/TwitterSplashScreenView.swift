// Adapted from https://iosdevtips.co/post/88481653818/twitter-ios-app-bird-zoom-animation

import UIKit

final class TwitterSplashScreenView: UIViewController, ViewControllerIdentifiable {
    var stringIdentifier: String = "TwitterSplashScreenView"
    var nameIdentifier: String = "Twitter Splash Screen"
    
    private lazy var twitterScreenContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var twitterScreen: UIImageView = {
        guard let image = UIImage(named: "TwitterScreen") else { return UIImageView() }
        let imageView = UIImageView(image: image)
        imageView.alpha = 0
        return imageView
    }()
    
    private lazy var twitterLogoMaskView: UIImageView = {
        guard let image = UIImage(named: "TwitterLogo") else { return UIImageView() }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        // Reset everything to initial state
        twitterLogoMaskView.transform = .identity
        twitterScreen.alpha = 0
        twitterLogoMaskView.frame = CGRect(x: 0, y: 0, width: 72.88, height: 60)
        twitterLogoMaskView.center = view.center
        twitterScreenContainerView.mask = twitterLogoMaskView
        
        // Start animation after reset
        DispatchQueue.main.async { [weak self] in
            self?.startAnimation()
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .twitterBlue
        
        twitterScreenContainerView.then {
            view.addSubview($0)
        }.layout {
            $0.trailing == view.trailingAnchor
            $0.leading == view.leadingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
        }
        
        twitterScreen.do {
            twitterScreenContainerView.addSubview($0)
            twitterScreenContainerView.fillWith($0)
        }
        
        // Mask Twitter screen with the Twitter logo
        twitterLogoMaskView.do {
            $0.frame = CGRect(x: 0, y: 0, width: 72.88, height: 60)
            $0.center = view.center
            twitterScreenContainerView.mask = $0
        }
    }
    
    private func startAnimation() {
        twitterLogoMaskView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            // Shrink Twitter logo slightly
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) {
                self.twitterLogoMaskView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.twitterScreenContainerView.transform = CGAffineTransform(scaleX: 1.16, y: 1.16)
            } completion: { _ in
                // Animate opacity of Twitter screen
                UIView.animate(withDuration: 0.4,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0.6,
                               options: .curveEaseInOut)
                {
                    self.twitterScreen.alpha = 1
                }
                
                // Expand Twitter logo to reveal app contents
                UIView.animate(withDuration: 0.8,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0.6,
                               options: .curveEaseInOut)
                {
                    self.twitterScreenContainerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.twitterLogoMaskView.transform = CGAffineTransform(scaleX: 60.0, y: 60.0)
                } completion: { _ in
                    self.twitterScreenContainerView.mask = nil
                    self.twitterLogoMaskView.removeFromSuperview()
                }
            }
        }
    }
    
    private func setupBackButton() {
        let backButton = BackButton(blurStyle: .systemUltraThinMaterialDark)
        backButton.backNavigation = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        backButton.then {
            view.addSubview($0)
        }.layout {
            $0.leading == view.leadingAnchor + 20
            $0.bottom == view.safeAreaLayoutGuide.bottomAnchor - 20
        }
    }
}

extension TwitterSplashScreenView: FBPaperTransitioning {
    var sharedView: UIView? {
        return UIView()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
