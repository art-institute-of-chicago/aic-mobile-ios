/*
 Abstract:
 Plays intro video and shows loading view
 */

import UIKit
import AVFoundation

protocol LoadingViewControllerDelegate: class {
    func loadingDidFinishPlayingIntroVideoA()
	func loadingDidFinishPlayingIntroVideoB()
	func loadingDidFinishFadeOutAnimation()
}

class LoadingViewController: UIViewController {
    weak var delegate:LoadingViewControllerDelegate? = nil
	
	let loadingImage = UIImageView()
	let progressBackgroundView = UIView()
	let progressHighlightView = UIView()
	let progressView = UIView()
	
	let progressMarginTop = UIScreen.main.bounds.height * CGFloat(0.42)
	let progressSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(0.45), height: 1)
	
	var progressHighlightWidth: NSLayoutConstraint? = nil
	
	let videoView: UIView = UIView()
	var avPlayer : AVQueuePlayer!
	
	let playerItemA: AVPlayerItem
	let playerItemB: AVPlayerItem
    
    var pctComplete:Float = 0.0
	
	init() {
		// Load Video URL
		let loadingVideoAURL = Bundle.main.url(forResource: "RegularSplash_AIC_1", withExtension: "mp4", subdirectory:"/video")
		let loadingVideoBURL = Bundle.main.url(forResource: "RegularSplash_AIC_2", withExtension: "mp4", subdirectory:"/video")
		
		// Create player item with the video, add callback for finished
		playerItemA = AVPlayerItem(url: loadingVideoAURL!)
		playerItemB = AVPlayerItem(url: loadingVideoBURL!)
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
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
        avPlayer = AVQueuePlayer(items: [playerItemA, playerItemB]) //(playerItem: playerItemA)
		
        // No Looping
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
		
		progressView.isHidden = true
		//progressHighlightView.layer.cornerRadius = progressSize.height
		progressBackgroundView.backgroundColor = .lightGray
		progressHighlightView.backgroundColor = .white
		
		// Add Subviews
		progressView.addSubview(progressBackgroundView)
		progressView.addSubview(progressHighlightView)
		self.view.addSubview(videoView)
		self.view.addSubview(loadingImage)
		self.view.addSubview(progressView)
		
		createViewConstraints()
    }
	
	func createViewConstraints() {
		loadingImage.autoPinEdgesToSuperviewEdges()
		
		progressView.autoPinEdge(.top, to: .top, of: self.view, withOffset: self.view.bounds.height * 0.5)
		progressView.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		progressView.autoSetDimensions(to: progressSize)
		
		progressBackgroundView.autoPinEdge(.top, to: .top, of: progressView)
		progressBackgroundView.autoPinEdge(.leading, to: .leading, of: progressView)
		progressBackgroundView.autoSetDimensions(to: progressSize)
		
		progressHighlightView.autoPinEdge(.top, to: .top, of: progressView)
		progressHighlightView.autoPinEdge(.leading, to: .leading, of: progressView)
		progressHighlightWidth = progressHighlightView.autoSetDimension(.width, toSize: 0)
		progressHighlightView.autoSetDimension(.height, toSize: progressSize.height)
	}
    
    func playIntroVideoA() {
		loadingImage.removeFromSuperview()
		
		// Cover up the splash image
		let layer = AVPlayerLayer(player: avPlayer)
		layer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//		if UIDevice().type != .iPhoneX {
//			let videoToScreenRatio = self.view.frame.size.height / 812.0
//			let videoSize = CGSize(width: self.view.frame.size.width * videoToScreenRatio, height: self.view.frame.size.height * videoToScreenRatio)
//			let videoOrigin = CGPoint(x: (videoSize.width - self.view.frame.size.width) * -0.5, y: (videoSize.height - self.view.frame.size.height) * -0.5)
//			layer.frame = CGRect(x: videoOrigin.x, y: videoOrigin.y, width: videoSize.width, height: videoSize.height)
//		}
		videoView.layer.addSublayer(layer)
		
		// Play the video
		avPlayer.play()
    }
	
	func showProgressBar() {
		progressView.isHidden = false
	}
	
	func hideProgressBar() {
		progressView.isHidden = true
	}
	
	func playIntroVideoB() {
		avPlayer.advanceToNextItem()
		avPlayer.play()
	}
    
    func updateProgress(forPercentComplete pct:Float) {
		pctComplete = pct
		
		progressHighlightWidth?.constant = (progressSize.width * CGFloat(pct))
		
		self.view.layoutIfNeeded()
    }
    
    @objc internal func videoFinishedPlaying() {
		if avPlayer.currentItem == playerItemA {
			delegate?.loadingDidFinishPlayingIntroVideoA()
		}
		else {
			delegate?.loadingDidFinishPlayingIntroVideoB()
			UIView.animate(withDuration: 0.75, animations: {
				self.videoView.frame.origin.y = -(UIScreen.main.bounds.height * 0.5) + 100
				self.view.alpha = 0.0
			}, completion: { (completed) in
				self.delegate?.loadingDidFinishFadeOutAnimation()
			})
		}
    }
}
