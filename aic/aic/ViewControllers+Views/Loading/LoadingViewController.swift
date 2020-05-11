/*
Abstract:
Plays intro video and shows loading view
*/

import UIKit
import AVFoundation

protocol LoadingViewControllerDelegate: class {
	func loadingDidFinishPlayingIntroVideoA()
	func loadingDidFinish()
}

class LoadingViewController: UIViewController {
	weak var delegate: LoadingViewControllerDelegate?

	let loadingImage = UIImageView()
	let progressBackgroundView = UIView()
	let progressHighlightView = UIView()
	let progressView = UIView()
	let welcomeLabel = UILabel()

	let videoView: UIView = UIView()
	var avPlayer: AVQueuePlayer!

	let playerItemFull: AVPlayerItem
	let playerItemA: AVPlayerItem
	let playerItemB: AVPlayerItem

	var layerFrame: CGRect = UIScreen.main.bounds

	let progressMarginTop = UIScreen.main.bounds.height * CGFloat(0.42)
	let progressSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(0.45), height: 1)
	let buildingToVideoTopMargin: CGFloat = 368.0

	var progressHighlightWidth: NSLayoutConstraint?

	var pctComplete: Float = 0.0

	let showFullVideo: Bool

	init(showFullVideo: Bool) {
		self.showFullVideo = showFullVideo

		// Load Video URL
		var resolutionString = ""
		if UIDevice().userInterfaceIdiom == .phone {
			let height: Int = Int(UIScreen.main.nativeBounds.height)
			switch height {
			case 1136:
				resolutionString = String(height)
			case 1334:
				resolutionString = String(height)
			case 2208:
				resolutionString = String(height)
			case 2436, 1624: // 1624 is the height for XR, and this video is only video that will work for XR
				resolutionString = "2436"
			default:
				resolutionString = "1334"
			}
		}

		let videoFilename = "RegularSplash_AIC_" + resolutionString

		let loadingVideoURL_Full = Bundle.main.url(forResource: videoFilename, withExtension: "mp4", subdirectory: "/video")
		let loadingVideoURL_A = Bundle.main.url(forResource: videoFilename + "_1", withExtension: "mp4", subdirectory: "/video")
		let loadingVideoURL_B = Bundle.main.url(forResource: videoFilename + "_2", withExtension: "mp4", subdirectory: "/video")

		// Create player item with the video, add callback for finished
		playerItemFull = AVPlayerItem(url: loadingVideoURL_Full!)
		playerItemA = AVPlayerItem(url: loadingVideoURL_A!)
		playerItemB = AVPlayerItem(url: loadingVideoURL_B!)

		// Remove video files that we don't need for this device resolution
		let videoFolder = Bundle.main.bundleURL.appendingPathComponent("video")
		var isDirectory: ObjCBool = true
		if FileManager.default.fileExists(atPath: videoFolder.path, isDirectory: &isDirectory) {
			do {
				let items = try FileManager.default.contentsOfDirectory(atPath: videoFolder.path)
				for item in items {
					if item.range(of: videoFilename) == nil {
						try FileManager.default.removeItem(atPath: videoFolder.appendingPathComponent(item).path)
					}
				}
			} catch {
			}
		}

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
		if showFullVideo {
			avPlayer = AVQueuePlayer(items: [playerItemFull])
		} else {
			avPlayer = AVQueuePlayer(items: [playerItemA, playerItemB])
		}

		// No Looping
		avPlayer.actionAtItemEnd = .none

		// Progress Bar
		//progressHighlightView.layer.cornerRadius = progressSize.height
		progressBackgroundView.backgroundColor = .lightGray
		progressHighlightView.backgroundColor = .white
		progressView.isHidden = true

		// Welcome Label
		welcomeLabel.font = .aicLoadingWelcomeFont
		welcomeLabel.text = "welcome_title".localized(using: "Base")
		welcomeLabel.numberOfLines = 1
		welcomeLabel.textColor = .white
		welcomeLabel.textAlignment = .center
		welcomeLabel.isHidden = true

		// Setup Video Layer
		// Cover up the splash image
		let layer = AVPlayerLayer(player: avPlayer)
		layer.frame = layerFrame
		videoView.layer.addSublayer(layer)

		// Add Subviews
		progressView.addSubview(progressBackgroundView)
		progressView.addSubview(progressHighlightView)
		loadingImage.addSubview(progressView)
		loadingImage.addSubview(welcomeLabel)
		self.view.addSubview(videoView)
		self.view.addSubview(loadingImage)

		createViewConstraints()
	}

	func createViewConstraints() {
		loadingImage.autoPinEdgesToSuperviewEdges()

		progressView.autoPinEdge(.top, to: .top, of: loadingImage, withOffset: self.view.bounds.height * 0.5 - 60)
		progressView.autoAlignAxis(.vertical, toSameAxisOf: loadingImage)
		progressView.autoSetDimensions(to: progressSize)

		progressBackgroundView.autoPinEdge(.top, to: .top, of: progressView)
		progressBackgroundView.autoPinEdge(.leading, to: .leading, of: progressView)
		progressBackgroundView.autoSetDimensions(to: progressSize)

		progressHighlightView.autoPinEdge(.top, to: .top, of: progressView)
		progressHighlightView.autoPinEdge(.leading, to: .leading, of: progressView)
		progressHighlightWidth = progressHighlightView.autoSetDimension(.width, toSize: 0)
		progressHighlightView.autoSetDimension(.height, toSize: progressSize.height)

		welcomeLabel.autoPinEdge(.bottom, to: .top, of: progressView, withOffset: -5)
		welcomeLabel.autoPinEdge(.leading, to: .leading, of: loadingImage)
		welcomeLabel.autoPinEdge(.trailing, to: .trailing, of: loadingImage)
	}

	func showProgressBar() {
		progressView.isHidden = false
		welcomeLabel.isHidden = false
		welcomeLabel.alpha = 0.0
		UIView.animate(withDuration: 0.3, animations: {
			self.welcomeLabel.alpha = 1.0
		})
	}

	func updateProgress(forPercentComplete pct: Float) {
		pctComplete = pct

		progressHighlightWidth?.constant = (progressSize.width * CGFloat(pct))

		self.view.layoutIfNeeded()
	}

	func playIntroVideo() {
		if loadingImage.superview != nil {
			UIView.animate(withDuration: 0.3, animations: {
				self.loadingImage.alpha = 0.0
			}) { (completed) in
				if completed == true {
					self.loadingImage.removeFromSuperview()
				}
			}
		}

		avPlayer.play()
	}

	@objc func loadIntroVideoB() {
		avPlayer.advanceToNextItem()
		avPlayer.pause()
	}

	@objc func videoFinishedPlaying() {
		if avPlayer.currentItem == playerItemA {
			delegate?.loadingDidFinishPlayingIntroVideoA()
		} else {
			self.delegate?.loadingDidFinish()
		}
	}
}
