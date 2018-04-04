/*
 Abstract:
 View Controller for a miniature/barebones audio player
 that lives at the bottom of the screen when an object is selected
 but minimized.
*/

import UIKit

class MiniAudioPlayerView : UIView {
    let blurBGView: UIView = getBlurEffectView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Common.Layout.miniAudioPlayerHeight))
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let playPauseButton: UIButton = UIButton()
    let closeButton: UIButton = UIButton()
    let titleLabel: UILabel = UILabel()
    let progressBar: UIView = UIView()
    
	fileprivate let progressBarHeight: CGFloat = 1
    
    fileprivate var progressBarWidthConstraint: NSLayoutConstraint? = nil
    
    init() {
        super.init(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Common.Layout.miniAudioPlayerHeight))
        
        self.backgroundColor = .clear
        self.clipsToBounds = true
		
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.font = .aicMiniPlayerTrackTitleFont
        
        closeButton.backgroundColor = .clear
        closeButton.setImage(#imageLiteral(resourceName: "audioClose"), for: .normal)
		closeButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        playPauseButton.setImage(#imageLiteral(resourceName: "audioPlay"), for: .normal)
        playPauseButton.setImage(#imageLiteral(resourceName: "audioPause"), for: .selected)
		playPauseButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		
		// Add Subviews
		addSubview(blurBGView)
		addSubview(playPauseButton)
		addSubview(activityIndicator)
		addSubview(titleLabel)
		addSubview(closeButton)
		addSubview(progressBar)
		
		createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	// MARK: Constraints
	
	func createConstraints() {
		blurBGView.autoPinEdgesToSuperviewEdges()
		
		playPauseButton.autoPinEdge(.top, to: .top, of: self)
		playPauseButton.autoPinEdge(.leading, to: .leading, of: self, withOffset: 8)
		playPauseButton.autoSetDimension(.width, toSize: 40)
		playPauseButton.autoPinEdge(.bottom, to: .bottom, of: self)
		
		activityIndicator.autoPinEdge(.top, to: .top, of: playPauseButton)
		activityIndicator.autoPinEdge(.leading, to: .leading, of: playPauseButton)
		activityIndicator.autoPinEdge(.trailing, to: .trailing, of: playPauseButton)
		activityIndicator.autoPinEdge(.bottom, to: .bottom, of: playPauseButton)
		
		closeButton.autoPinEdge(.top, to: .top, of: self)
		closeButton.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -8)
		closeButton.autoSetDimension(.width, toSize: 40)
		closeButton.autoPinEdge(.bottom, to: .bottom, of: self)
		
		titleLabel.autoPinEdge(.leading, to: .trailing, of: playPauseButton)
		titleLabel.autoPinEdge(.trailing, to: .leading, of: closeButton)
		titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: self)
		
		progressBarWidthConstraint = progressBar.autoSetDimension(.width, toSize: 0)
		progressBar.autoSetDimension(.height, toSize: progressBarHeight)
		progressBar.autoPinEdge(.leading, to: .leading, of: self)
		progressBar.autoPinEdge(.bottom, to: .bottom, of: self)
	}
	
	// MARK: States
    
    func reset() {
        playPauseButton.isSelected = false
    }
    
    func showLoadingMessage(message: String) {
        playPauseButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        titleLabel.text = message
    }
    
    func showTrackTitle(title: String) {
        playPauseButton.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        titleLabel.text = title
    }
    
    // MARK: Progress Bar
	
	func setProgressBarColor(color: UIColor) {
		progressBar.backgroundColor = color
	}
	
    func resetProgress() {
        setProgressBarWidth(percentage: 0.0)
    }
    
    func updateProgress(progress: Double, duration: Double) {
        let pct = progress/duration
        setProgressBarWidth(percentage: CGFloat(pct))
    }
    
    private func setProgressBarWidth(percentage: CGFloat) {
        progressBarWidthConstraint?.constant = self.frame.width * percentage
    }
}
