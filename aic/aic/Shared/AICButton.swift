/*
 Abstract:
 Shared button class for UIButtons in app with the same style
*/

import UIKit

class AICButton: UIButton {
	// Set of colors for different elements of the button
	struct ColorSet {
		let borderColor: UIColor
		let backgroundColor: UIColor
		let textColor: UIColor
	}

	// Color sets for the button states (normal and highlighted)
	struct ButtonColorMode {
		let normal: ColorSet
		let highlighted: ColorSet
	}

	static let blueMode = ButtonColorMode(
		normal: ColorSet(borderColor: .aicButtonBlueColor, backgroundColor: .aicButtonBlueColor, textColor: .white),
		highlighted: ColorSet(borderColor: .aicButtonBlueColor, backgroundColor: .aicButtonBlueDarkColor, textColor: .white)
	)

	static let greenBlueMode = ButtonColorMode(
		normal: ColorSet(borderColor: .aicButtonGreenBlueColor, backgroundColor: .aicButtonGreenBlueColor, textColor: .white),
		highlighted: ColorSet(borderColor: .aicButtonGreenBlueColor, backgroundColor: .aicButtonGreenBlueDarkColor, textColor: .white)
	)

	static let whiteGreenBlueMode = ButtonColorMode(
		normal: ColorSet(borderColor: .aicButtonGreenBlueColor, backgroundColor: .white, textColor: .aicButtonGreenBlueColor),
		highlighted: ColorSet(borderColor: .aicButtonGreenBlueColor, backgroundColor: UIColor(white: 0.95, alpha: 1.0), textColor: .aicButtonGreenBlueColor)
	)

	static let orangeMode = ButtonColorMode(
		normal: ColorSet(borderColor: .aicButtonOrangeColor, backgroundColor: .aicButtonOrangeColor, textColor: .white),
		highlighted: ColorSet(borderColor: .aicButtonOrangeColor, backgroundColor: .aicButtonOrangeDarkColor, textColor: .white)
	)

	static let whiteOrangeMode = ButtonColorMode(
		normal: ColorSet(borderColor: .aicButtonOrangeColor, backgroundColor: .white, textColor: .aicButtonOrangeColor),
		highlighted: ColorSet(borderColor: .aicButtonOrangeColor, backgroundColor: UIColor(white: 0.95, alpha: 1.0), textColor: .aicButtonOrangeColor)
	)

	static let transparentMode = ButtonColorMode(
		normal: ColorSet(borderColor: .white, backgroundColor: UIColor(white: 1, alpha: 0), textColor: .white),
		highlighted: ColorSet(borderColor: .white, backgroundColor: UIColor(white: 216.0 / 255.0, alpha: 0.5), textColor: .white)
	)

    private let insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	private let mediumSize: CGSize = CGSize(width: 190, height: 50)
	private let smallSize: CGSize = CGSize(width: 140, height: 50)
	private let borderWidth: CGFloat = 2.0
	private var buttonColorMode: ButtonColorMode = AICButton.greenBlueMode

    override var isHighlighted: Bool {
        didSet {
			if isHighlighted {
				backgroundColor = buttonColorMode.highlighted.backgroundColor
				layer.borderColor = buttonColorMode.highlighted.borderColor.cgColor
			} else {
				backgroundColor = buttonColorMode.normal.backgroundColor
				layer.borderColor = buttonColorMode.normal.borderColor.cgColor
			}
        }
    }

	init(isSmall: Bool) {
		super.init(frame: CGRect.zero)

		let frameSize = isSmall ? smallSize : mediumSize
		self.autoSetDimensions(to: CGSize(width: frameSize.width - (borderWidth), height: frameSize.height - (borderWidth)))
		setup()
    }

    required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
    }

	override func awakeFromNib() {
		setup()
		setColorMode(colorMode: AICButton.greenBlueMode)
	}

	private func setup() {
		setBackgroundImage(nil, for: .normal)
		setBackgroundImage(nil, for: .highlighted)
		titleLabel!.font = .aicButtonFont
		layer.borderWidth = borderWidth
		adjustsImageWhenHighlighted = false
	}

	func setColorMode(colorMode: ButtonColorMode) {
		buttonColorMode = colorMode
		setTitleColor(buttonColorMode.normal.textColor, for: .normal)
		setTitleColor(buttonColorMode.highlighted.textColor, for: .highlighted)
		backgroundColor = buttonColorMode.normal.backgroundColor
		layer.borderColor = buttonColorMode.normal.borderColor.cgColor
	}

	func setIconImage(image: UIImage) {
		setImage(image, for: .normal)
		setImage(image, for: .highlighted)
		imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
	}
}
