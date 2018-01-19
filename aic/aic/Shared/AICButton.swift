/*
 Abstract:
 Shared button class for UIButtons in app with the same style
*/

import UIKit

class AICButton: UIButton {
    private let insets = UIEdgeInsetsMake(10, 10, 10, 10)
	private let mediumSize: CGSize = CGSize(width: 190, height: 50)
	private let smallSize: CGSize = CGSize(width: 140, height: 50)
	private let borderWidth: CGFloat = 2.0
	var buttonColor: UIColor = .aicHomeColor
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = .white
            } else {
                backgroundColor = buttonColor
            }
        }
    }

	init(color: UIColor, isSmall: Bool) {
		super.init(frame:CGRect.zero)
		
		setButtonColor(color: color)
		
		let frameSize = isSmall ? smallSize : mediumSize
		self.autoSetDimensions(to: CGSize(width: frameSize.width - (borderWidth), height: frameSize.height - (borderWidth)))
    }
    
    required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		buttonColor = .aicHomeColor
    }
	
	func setButtonColor(color: UIColor) {
		buttonColor = color
		backgroundColor = buttonColor
		setBackgroundImage(nil, for: .normal)
		setBackgroundImage(nil, for: .highlighted)
		setTitleColor(.white, for: .normal)
		setTitleColor(buttonColor, for: .highlighted)
		titleLabel!.font = .aicButtonFont
		layer.borderWidth = borderWidth
		layer.borderColor = buttonColor.cgColor
		adjustsImageWhenHighlighted = false
	}
	
	override func awakeFromNib() {
		setButtonColor(color: buttonColor)
	}
}
