/*
 Abstract:
 Shared button for large views
 */

import UIKit

class MessageLargeButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = UIColor.white.withAlphaComponent(0.5)
            } else {
                backgroundColor = .clear
            }
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0,y: 0, width: 325, height: 50))
        layer.borderColor = UIColor.white.cgColor
        setTitleColor( .white, for: UIControlState())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
