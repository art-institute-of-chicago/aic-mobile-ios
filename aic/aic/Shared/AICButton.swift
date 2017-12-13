/*
 Abstract:
 Shared button class for UIButtons in app with the same style
*/

import UIKit

class AICButton: UIButton {
    let insets = UIEdgeInsetsMake(10, 10, 10, 10)
	let buttonColor: UIColor
	let mediumSize: CGSize = CGSize(width: 190, height: 50)
	let smallSize: CGSize = CGSize(width: 140, height: 50)
	let borderWidth: CGFloat = 2.0
    
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
		buttonColor = color
		super.init(frame:CGRect.zero)
		
        backgroundColor = buttonColor
        setTitleColor(.white, for: .normal)
		setTitleColor(.aicInfoColor, for: .highlighted)
        titleLabel!.font = .aicButtonFont
		layer.borderWidth = borderWidth
		layer.borderColor = buttonColor.cgColor
		
		let frameSize = isSmall ? smallSize : mediumSize
		self.autoSetDimensions(to: CGSize(width: frameSize.width - (borderWidth), height: frameSize.height - (borderWidth)))
    }
    
    required init?(coder aDecoder: NSCoder) {
		buttonColor = .aicHomeColor
		super.init(coder: aDecoder)
		
		backgroundColor = buttonColor
		setTitleColor(.white, for: .normal)
		setTitleColor(.aicInfoColor, for: .highlighted)
		titleLabel!.font = .aicButtonFont
		layer.borderWidth = borderWidth
		layer.borderColor = buttonColor.cgColor
    }
}
