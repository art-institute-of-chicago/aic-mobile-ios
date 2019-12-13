/*
 Abstract:
 The main audio player that appears in the full-screen
 object view
*/

import UIKit

class AudioPlayerView: BaseView {
	let titleLabel: UILabel = UILabel()
	let timeRemainingLabel: UILabel = UILabel()
	let playPauseButton: UIButton = UIButton()
    let slider: AudioPlayerSlider = AudioPlayerSlider()
	let audioPlayerMinHeight: CGFloat = 120

    init() {
        super.init(frame: CGRect.zero)

		self.backgroundColor = .aicAudioPlayerBackgroundColor
		self.clipsToBounds = true

        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .aicTitleFont

        timeRemainingLabel.numberOfLines = 1
        timeRemainingLabel.textColor = .aicCardDarkTextColor
        timeRemainingLabel.textAlignment = .center
        timeRemainingLabel.font = .aicAudioPlayerTimeRemainingFont
        timeRemainingLabel.text = " "

		playPauseButton.setImage(#imageLiteral(resourceName: "audioPlayBig"), for: .normal)
		playPauseButton.setImage(#imageLiteral(resourceName: "audioPauseBig"), for: .selected)
		playPauseButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        // Add Subviews
		self.addSubview(titleLabel)
		self.addSubview(timeRemainingLabel)
        self.addSubview(playPauseButton)
        self.addSubview(slider)

		createConstraints()

		// Accessibility
		playPauseButton.accessibilityLabel = "Play Pause Audio Track"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset() {
        playPauseButton.isSelected = true
        timeRemainingLabel.text = "0:00/0:00"
        slider.value = 0.0
    }

    func showLoadingMessage(message: String) {
		titleLabel.text = message
        timeRemainingLabel.isHidden = true
        playPauseButton.isHidden = true
		slider.isHidden = true
    }

    func showTrackTitle(title: String) {
		titleLabel.text = title
        timeRemainingLabel.isHidden = false
		playPauseButton.isHidden = false
		slider.isHidden = false
    }

    func resetProgress() {
        slider.value = 0.0
    }

	func updateProgress(progress: Double, duration: Double, setSliderValue: Bool=true) {
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

	func createConstraints() {
		titleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: 16)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)

		timeRemainingLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 8)
		timeRemainingLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		timeRemainingLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)

		slider.autoPinEdge(.top, to: .bottom, of: timeRemainingLabel, withOffset: 8)
		slider.autoPinEdge(.leading, to: .trailing, of: playPauseButton, withOffset: 8)
		slider.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)

		playPauseButton.autoSetDimension(.width, toSize: 40.0)
		playPauseButton.autoSetDimension(.height, toSize: 40.0)
		playPauseButton.autoPinEdge(.leading, to: .leading, of: self, withOffset: 8)
		playPauseButton.autoAlignAxis(.horizontal, toSameAxisOf: slider)

		self.autoSetDimension(.width, toSize: UIScreen.main.bounds.width)
		self.autoPinEdge(.bottom, to: .bottom, of: slider, withOffset: 12)
    }
}
