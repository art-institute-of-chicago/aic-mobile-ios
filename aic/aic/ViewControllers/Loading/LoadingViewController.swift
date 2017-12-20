/*
 Abstract:
 Plays intro video and shows loading view
 */

import UIKit
import AVFoundation

protocol LoadingViewControllerDelegate: class {
    func loadingViewControllerDidFinishPlayingIntroVideo()
}

class LoadingViewController: UIViewController {
    weak var delegate:LoadingViewControllerDelegate? = nil
    
    var loadingView:LoadingView!
    var avPlayer : AVPlayer!
    
    var pctComplete:Float = 0.0
    
    override func loadView() {
        loadingView = LoadingView()
        view = loadingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Video Player
        // Load the URL
        let loadingVideoURL = Bundle.main.url(forResource: "loadingVideo", withExtension: "mp4", subdirectory:"Assets/video")
        
        // Create player item with the video, add callback for finished
        let playerItem = AVPlayerItem(url: loadingVideoURL!)
        NotificationCenter.default.addObserver(self, selector: #selector(LoadingViewController.videoFinishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer)
    
        // Create the player
        avPlayer = AVPlayer(playerItem: playerItem)
    
        // No Looping
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func playIntroVideo() {
        // Hide the progress bar
        loadingView.progressView.isHidden = true
        
        // Cover up the splash image
        let layer = AVPlayerLayer(player: avPlayer)
        layer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
		if UIDevice().type == .iPhoneX {
			let videoToScreenRatio = self.view.frame.size.height / 667.0
			let videoSize = CGSize(width: self.view.frame.size.width * videoToScreenRatio, height: self.view.frame.size.height * videoToScreenRatio)
			let videoOrigin = CGPoint(x: (videoSize.width - self.view.frame.size.width) * -0.5, y: (videoSize.height - self.view.frame.size.height) * -0.5)
			layer.frame = CGRect(x: videoOrigin.x, y: videoOrigin.y, width: videoSize.width, height: videoSize.height)
		}
        self.view.layer.insertSublayer(layer, above: self.view.layer.sublayers![0])
        
        // Play the video
        if let player = self.avPlayer {
            player.play()
        }
    }
    
    func updateProgress(forPercentComplete pct:Float) {
        pctComplete = pct
        loadingView.setProgressBarPct(pctComplete)
    }
    
    internal func videoFinishedPlaying() {
        delegate?.loadingViewControllerDidFinishPlayingIntroVideo()
    }
}
