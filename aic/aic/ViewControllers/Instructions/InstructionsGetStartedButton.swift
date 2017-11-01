/*
 Abstract:
 Custom button for instruction screen
 */

import UIKit

class InstructionsGetStartedButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = UIColor.white.withAlphaComponent(0.5)
            } else {
                backgroundColor = UIColor.clear
            }
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 325, height: 50))
        
        backgroundColor = UIColor.clear
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        
        titleLabel?.font = UIFont.aicTitleFont
        setTitle("Get Started", for: UIControlState())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
