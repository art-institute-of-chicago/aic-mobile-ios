/*
 Abstract:
 View Controller for a miniature/barebones audio player
 that lives at the bottom of the screen when an object is selected
 but minimized.
*/

import UIKit
import SnapKit

class MiniAudioPlayerView : BaseView {
    fileprivate let margins = UIEdgeInsetsMake(0, 10, 0, 10)
    
    fileprivate let progressBarHeight = 1
    fileprivate var progressBarWidthConstraint:Constraint? = nil
    
    fileprivate let playPauseButtonScale:Float = 1.25
    
    // Views
    let insetView = UIView()
    
    let playPauseActivityHolderView = UIView()
    let playPauseButton = PlayPauseButton()
    let activityIndicator = UIActivityIndicatorView()
    let titleLabel:UILabel = UILabel()
    let fullscreenButton:UIButton = UIButton()
    
    let progressBar = UIView()
    
    init() {
        super.init(frame:CGRect.zero)
        
        self.backgroundColor = UIColor.aicAudiobarColor()
        
        // Configure
        playPauseButton.tintColor = UIColor.white
        playPauseButton.setScale(playPauseButtonScale)
        
        titleLabel.numberOfLines = 1
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.aicSystemTextFont()
        
        fullscreenButton.backgroundColor = UIColor.clear
        let expandImage = UIImage(named: "expand")
        fullscreenButton.setImage(expandImage!, for: UIControlState())
        fullscreenButton.frame = CGRect(x: 0,y: 0, width: expandImage!.size.width, height: expandImage!.size.height)
        
        progressBar.backgroundColor = UIColor.aicMapColor()
        
        // Add Subviews
        playPauseActivityHolderView.addSubview(playPauseButton)
        playPauseActivityHolderView.addSubview(activityIndicator)
        
        insetView.addSubview(playPauseActivityHolderView)
        insetView.addSubview(titleLabel)
        insetView.addSubview(fullscreenButton)
        
        addSubview(insetView)
        addSubview(progressBar)
        
        //updateProgress(5, duration: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        playPauseButton.mode = PlayPauseButton.Mode.paused
    }
    
    func showMessage(_ message:String) {
        playPauseButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        titleLabel.text = message
    }
    
    func showProgressAndControls(_ title:String) {
        playPauseButton.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        titleLabel.text = title
    }
    
    func setProgressBarColor(_ color:UIColor) {
        progressBar.backgroundColor = color
    }
    
    // MARK: Progress Bar
    func resetProgress() {
        setProgressBarWidth(0.0)
    }
    
    func updateProgress(_ progress:Double, duration:Double) {
        let pct = progress/duration
        setProgressBarWidth(Float(pct))
    }
    
    func setProgressBarWidth(_ pct:Float) {
        if let constraint = progressBarWidthConstraint {
            constraint.deactivate()
        }
        
        progressBar.snp.makeConstraints { (make) in
            progressBarWidthConstraint = make.width.equalTo(progressBar.superview!).multipliedBy(pct).priority(Common.Layout.Priority.high.rawValue).constraint
        }
    }
    
    // MARK: Constraints
    override func updateConstraints() {
        if !didSetupConstraints {
            insetView.snp.makeConstraints { (make) -> Void in
                make.edges.equalTo(insetView.superview!).inset(margins).priority(Common.Layout.Priority.high.rawValue)
            }
            
            playPauseActivityHolderView.snp.makeConstraints { (make) -> Void in
                make.size.equalTo(playPauseButton.frame.size)
                make.left.equalTo(playPauseActivityHolderView.superview!)
                make.centerY.equalTo(playPauseActivityHolderView.superview!)
            }
            
            playPauseButton.snp.makeConstraints({ (make) in
                make.size.equalTo(playPauseButton.frame.size)
                make.centerY.equalTo(playPauseButton.superview!)
            })
            
            activityIndicator.snp.makeConstraints({ (make) in
                //make.center.equalTo(activityIndicator.superview!)
                make.size.equalTo(playPauseButton.frame.size)
                make.centerY.equalTo(playPauseButton.superview!)
            })
            
            titleLabel.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(playPauseActivityHolderView.snp.right)
                make.right.equalTo(fullscreenButton.snp.left)
                make.centerY.equalTo(titleLabel.superview!)
                
                titleLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: UILayoutConstraintAxis.horizontal)
            }
            
            fullscreenButton.snp.makeConstraints { (make) -> Void in
                make.size.equalTo(fullscreenButton.frame.size)
                make.right.equalTo(fullscreenButton.superview!)
                make.centerY.equalTo(fullscreenButton.superview!)
            }
            
            progressBar.snp.makeConstraints({ (make) in
                make.height.equalTo(progressBarHeight)
                make.left.equalTo(progressBar.superview!).priority(Common.Layout.Priority.low.rawValue)
                make.bottom.equalTo(progressBar.superview!)
                progressBarWidthConstraint = make.width.equalTo(0).constraint
            })
            
            didSetupConstraints = true
        }

        super.updateConstraints()
    }
}
