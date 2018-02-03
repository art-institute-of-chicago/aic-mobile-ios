/*
 Abstract:
 The main audio player that appears in the full-screen
 object view
*/

import UIKit
import SnapKit

class AudioPlayerView : BaseView {
    
    // MARK: Properties
    let height:CGFloat = 120
    let sidePadding:CGFloat = 30
    let labelTopPadding:CGFloat = 15
    
    let margins = UIEdgeInsetsMake(15, 30, 10, 30)
    
    let sliderHeight:CGFloat = 45.0
    
    // Subviews
    
    let insetView = UIView()
    
    let titleLabel = UILabel()
    let timeRemainingLabel = UILabel()
    
    let controlView = UIView()
    let playPauseButton = PlayPauseButton()
    let slider:UISlider = UISlider()
    
    init() {
        super.init(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: height))
        
        // Configure
        backgroundColor = .aicAudioPlayerBackgroundColor
        
        slider.isUserInteractionEnabled = true
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isContinuous = true
        slider.tintColor = .red
        slider.value = 0
        
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.aicTitleFont
        titleLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - (margins.left + margins.right)
        
        timeRemainingLabel.numberOfLines = 1
        timeRemainingLabel.textColor = .black
        timeRemainingLabel.textAlignment = NSTextAlignment.center
        timeRemainingLabel.font = .aicShortTextFont
        timeRemainingLabel.text = " "
        
        playPauseButton.tintColor = .black
        
        // Add Subviews
        controlView.addSubview(playPauseButton)
        controlView.addSubview(slider)
        
        insetView.addSubview(titleLabel)
        insetView.addSubview(timeRemainingLabel)
        insetView.addSubview(controlView)
        
        self.addSubview(insetView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        playPauseButton.mode = PlayPauseButton.Mode.paused
        timeRemainingLabel.text = "0:00/0:00"
        slider.value = 0.0
    }
    
    func showMessage(message:String) {
        timeRemainingLabel.isHidden = true
        controlView.isHidden = true
        titleLabel.text = message
    }
    
    func showProgressAndControls(withTitle title:String) {
        timeRemainingLabel.isHidden = false
        controlView.isHidden = false
        titleLabel.text = title
    }
    
    func resetProgress() {
        slider.value = 0.0
    }
    
    func updateProgress(progress:Double, duration:Double, setSliderValue:Bool=true) {
        if setSliderValue {
            let newValue = progress/duration
            if !newValue.isNaN {
                slider.value = Float(progress/duration)
            }
        }
        
        let progressHMS = convertToHoursMinutesSeconds(seconds: Int(progress))
        let durationHMS = convertToHoursMinutesSeconds(seconds: Int(duration))
        
        let timeFormat = "%i:%02i"
        let progressString = String(format: timeFormat, progressHMS.1, progressHMS.2)
        let durationString = String(format: timeFormat, durationHMS.1, durationHMS.2)
        
        timeRemainingLabel.text = "\(progressString)/\(durationString)"
    }
    
    override func updateConstraints() {
        insetView.snp.remakeConstraints { (make) in
            make.edges.equalTo(insetView.superview!).inset(margins)
            make.bottom.equalTo(controlView)
        }
        
        titleLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(insetView)
            make.left.right.equalTo(insetView)
            make.height.greaterThanOrEqualTo(1)
        }
        
        timeRemainingLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.right.equalTo(insetView)
            make.height.greaterThanOrEqualTo(25)
        }
        
        controlView.snp.remakeConstraints { (make) in
            make.top.equalTo(timeRemainingLabel.snp.bottom)
            make.left.right.equalTo(insetView)
            make.height.equalTo(playPauseButton.frame.height)
        }
        
        playPauseButton.snp.remakeConstraints { (make) in
            make.size.equalTo(playPauseButton.frame.size)
            make.centerY.equalTo(controlView)
            make.left.equalTo(controlView)
        }
        
        slider.snp.remakeConstraints({ (make) in
            make.left.equalTo(playPauseButton.snp.right).offset(10)
            make.right.equalTo(controlView.snp.right)
            make.centerY.equalTo(controlView)
            make.height.equalTo(sliderHeight)
        })
        
        super.updateConstraints()
    }
}
