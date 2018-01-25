/*
 Abstract:
 Plays intro video and shows loading view
 */

import UIKit
import AVFoundation

protocol LoadingViewControllerDelegate: class {
    func loadingDidFinishPlayingIntroVideoA()
	func loadingDidFinishPlayingIntroVideoB()
	func loadingDidFinishBuildingAnimation()
}

class LoadingViewController: UIViewController {
    weak var delegate:LoadingViewControllerDelegate? = nil
	
	let loadingImage = UIImageView()
	let progressBackgroundView = UIView()
	let progressHighlightView = UIView()
	let progressView = UIView()
	let welcomeLabel = UILabel()
	let buildingImageView = UIImageView(image: Common.Sections[.home]!.background)
	
	let videoView: UIView = UIView()
	var avPlayer : AVQueuePlayer!
	
	let playerItemA: AVPlayerItem
	let playerItemB: AVPlayerItem
	
	var layerFrame: CGRect = UIScreen.main.bounds
	
	let progressMarginTop = UIScreen.main.bounds.height * CGFloat(0.42)
	let progressSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(0.45), height: 1)
	let buildingToVideoTopMargin: CGFloat = 368.0
	
	var progressHighlightWidth: NSLayoutConstraint? = nil
	var buildingImageTopMargin: NSLayoutConstraint? = nil
    
    var pctComplete:Float = 0.0
	
	init() {
		// Load Video URL
		let loadingVideoURL_A = Bundle.main.url(forResource: "RegularSplash_AIC_1", withExtension: "mp4", subdirectory:"/video")
		let loadingVideoURL_B = Bundle.main.url(forResource: "RegularSplash_AIC_2", withExtension: "mp4", subdirectory:"/video")
		
		// Create player item with the video, add callback for finished
		playerItemA = AVPlayerItem(url: loadingVideoURL_A!)
		playerItemB = AVPlayerItem(url: loadingVideoURL_B!)
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = .aicHomeColor
		
		// Splash Image
		if let image = splashImage(forOrientation: UIApplication.shared.statusBarOrientation, screenSize: UIScreen.main.bounds.size) {
			loadingImage.image = UIImage(named: image)
		}
		
		videoView.frame = UIScreen.main.bounds
		
		NotificationCenter.default.addObserver(self, selector: #selector(videoFinishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer)
		
        // Create the player
        avPlayer = AVQueuePlayer(items: [playerItemA, playerItemB])
		
        // No Looping
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
		
		// Progress Bar
		//progressHighlightView.layer.cornerRadius = progressSize.height
		progressBackgroundView.backgroundColor = .lightGray
		progressHighlightView.backgroundColor = .white
		progressView.isHidden = true
		
		// Welcome Label
		welcomeLabel.font = .aicLoadingWelcomeFont
		welcomeLabel.text = "Welcome".localized(using: "Sections")
		welcomeLabel.numberOfLines = 1
		welcomeLabel.textColor = .white
		welcomeLabel.textAlignment = .center
		welcomeLabel.isHidden = true
		
		// Building Image
		buildingImageView.isHidden = true
		
		// Setup Video Layer
		// Cover up the splash image
		let layer = AVPlayerLayer(player: avPlayer)
		// Fit video layer in screen frame
		let videoSize: CGSize = CGSize(width: 375.0, height: 812.0)
		let videoAspectRatio: CGFloat = videoSize.width / videoSize.height
		let screenAspectRatio: CGFloat = self.view.frame.width / self.view.frame.height
		if screenAspectRatio > videoAspectRatio {
			layerFrame.size.width = self.view.frame.width
			layerFrame.size.height = ceil(self.view.frame.width * (videoSize.height / videoSize.width))
			layerFrame.origin = CGPoint(x: 0, y: (self.view.frame.height - layerFrame.size.height) * 0.5)
		}
		layer.frame = layerFrame
		videoView.layer.addSublayer(layer)
		
		// Add Subviews
		progressView.addSubview(progressBackgroundView)
		progressView.addSubview(progressHighlightView)
		self.view.addSubview(loadingImage)
		self.view.addSubview(videoView)
		self.view.addSubview(progressView)
		self.view.addSubview(welcomeLabel)
		self.view.addSubview(buildingImageView)
		
		createViewConstraints()
    }
	
	func createViewConstraints() {
		loadingImage.autoPinEdgesToSuperviewEdges()
		
		progressView.autoPinEdge(.top, to: .top, of: self.view, withOffset: self.view.bounds.height * 0.5 + 35)
		progressView.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		progressView.autoSetDimensions(to: progressSize)
		
		progressBackgroundView.autoPinEdge(.top, to: .top, of: progressView)
		progressBackgroundView.autoPinEdge(.leading, to: .leading, of: progressView)
		progressBackgroundView.autoSetDimensions(to: progressSize)
		
		progressHighlightView.autoPinEdge(.top, to: .top, of: progressView)
		progressHighlightView.autoPinEdge(.leading, to: .leading, of: progressView)
		progressHighlightWidth = progressHighlightView.autoSetDimension(.width, toSize: 0)
		progressHighlightView.autoSetDimension(.height, toSize: progressSize.height)
		
		welcomeLabel.autoPinEdge(.bottom, to: .top, of: progressView, withOffset: -5)
		welcomeLabel.autoPinEdge(.leading, to: .leading, of: self.view)
		welcomeLabel.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		let buildingTopMarginInitialValue: CGFloat = 368.0 * (layerFrame.height / 812.0) + layerFrame.origin.y
		
		buildingImageTopMargin = buildingImageView.autoPinEdge(.top, to: .top, of: self.view, withOffset: buildingTopMarginInitialValue)
		buildingImageView.autoPinEdge(.leading, to: .leading, of: self.view)
		buildingImageView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		buildingImageView.autoMatch(.height, to: .width, of: buildingImageView, withMultiplier: buildingImageView.image!.size.height / buildingImageView.image!.size.width)
	}
    
    func playIntroVideoA() {
		avPlayer.play()
    }
	
	func showProgressBar() {
		progressView.isHidden = false
		welcomeLabel.isHidden = false
		welcomeLabel.alpha = 0.0
		UIView.animate(withDuration: 0.3, animations: {
			self.welcomeLabel.alpha = 1.0
		})
	}
	
	func hideProgressBar() {
		progressView.isHidden = true
		welcomeLabel.isHidden = true
	}
	
	func loadIntroVideoB() {
		//avPlayer.pause()
		avPlayer.advanceToNextItem()
		avPlayer.pause()
	}
	
	func playIntroVideoB() {
		avPlayer.play()
	}
    
    func updateProgress(forPercentComplete pct:Float) {
		pctComplete = pct
		
		progressHighlightWidth?.constant = (progressSize.width * CGFloat(pct))
		
		self.view.layoutIfNeeded()
    }
    
    @objc func videoFinishedPlaying() {
		if avPlayer.currentItem == playerItemA {
			loadingImage.removeFromSuperview()
			delegate?.loadingDidFinishPlayingIntroVideoA()
		}
		else {
			delegate?.loadingDidFinishPlayingIntroVideoB()
			self.perform(#selector(animateOut))
		}
    }
	
	@objc func animateOut() {
		buildingImageView.isHidden = false
		buildingImageView.alpha = 0.0
		
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
			self.videoView.alpha = 0.0
			self.buildingImageView.alpha = 1.0
		}, completion: { (completed1) in
			UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseIn, animations: {
				self.buildingImageTopMargin!.constant = 0.0
				self.view.layoutIfNeeded()
			}, completion: { (completed2) in
				self.delegate?.loadingDidFinishBuildingAnimation()
			})
		})
	}
}
