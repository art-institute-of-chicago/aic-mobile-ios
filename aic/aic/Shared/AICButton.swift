/*
 Abstract:
 Shared button class for UIButtons in app with the same style
*/

import UIKit

class AICButton: UIButton {
    let insets = UIEdgeInsetsMake(10, 10, 10, 10)
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = UIColor.aicButtonsColor.darker()
            } else {
                backgroundColor = .aicButtonsColor
            }
        }
    }

    init() {
        super.init(frame:CGRect.zero)
        
        backgroundColor = .aicButtonsColor
        setTitleColor(UIColor.white, for: UIControlState())
        titleLabel!.font = .aicTitleFont
        contentEdgeInsets = insets
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
