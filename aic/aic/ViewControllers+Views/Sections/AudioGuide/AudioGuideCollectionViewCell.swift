/*
Abstract:
UICollectionView of buttons for the audio guide
*/

import UIKit

class AudioGuideCollectionViewCell: UICollectionViewCell {
	let button = UIButton()

	override init(frame: CGRect) {
		super.init(frame: frame)

		button.layer.borderColor = UIColor(white: 1, alpha: 0.5).cgColor
		button.layer.borderWidth = 2
		button.layer.cornerRadius = frame.width/2.0

		button.alpha = 1.0

		button.frame.size = frame.size
		button.setTitleColor(.white, for: [])
		button.titleLabel?.font = .aicNumberPadFont

		setButtonNormalState()

		button.addTarget(self, action: #selector(AudioGuideCollectionViewCell.wasPressed(_:)), for: .touchDown)
		button.addTarget(self, action: #selector(AudioGuideCollectionViewCell.wasReleased(_:)), for: .touchUpInside)
		button.addTarget(self, action: #selector(AudioGuideCollectionViewCell.wasReleased(_:)), for: .touchUpOutside)
		button.addTarget(self, action: #selector(AudioGuideCollectionViewCell.wasReleased(_:)), for: .touchCancel)

		addSubview(button)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func reset() {
		button.layer.borderColor = UIColor(white: 1, alpha: 0.5).cgColor
		button.layer.borderWidth = 2
		button.layer.cornerRadius = frame.width/2.0
		button.setImage(nil, for: .normal)
		button.setImage(nil, for: .highlighted)
		button.setTitle(nil, for: .normal)
		button.accessibilityLabel = nil
	}

	func hideBorder() {
		button.layer.borderColor = UIColor.clear.cgColor
		button.layer.borderWidth = 0
		button.layer.cornerRadius = 0
	}

	private func setButtonNormalState() {
		if button.currentImage == nil {
			button.backgroundColor = .clear
		}
	}

	private func setButtonPressedState() {
		if button.currentImage == nil {
			button.backgroundColor = UIColor(white: 1, alpha: 0.36)
		}
	}

	@objc func wasPressed(_ button: UIButton) {
		setButtonPressedState()
	}

	@objc func wasReleased(_ button: UIButton) {
		setButtonNormalState()
	}
}
