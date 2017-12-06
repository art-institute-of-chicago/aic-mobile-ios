/*
 Abstract:
 UICollectionView of buttons for the audio guide
*/

import UIKit

class AudioGuideCollectionViewCell: UICollectionViewCell {
    let button = UIButton()
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = frame.width/2.0
        
        button.alpha = 0.5
        
        button.frame.size = frame.size
        button.setTitleColor(.white, for: UIControlState())
        button.titleLabel?.font = .aicNumberPadFont
        
        setButtonNormalState()
        
        button.addTarget(self, action: #selector(AudioGuideCollectionViewCell.wasPressed(_:)), for: UIControlEvents.touchDown)
        button.addTarget(self, action: #selector(AudioGuideCollectionViewCell.wasReleased(_:)), for: UIControlEvents.touchUpInside)
        button.addTarget(self, action: #selector(AudioGuideCollectionViewCell.wasReleased(_:)), for: UIControlEvents.touchUpOutside)
        button.addTarget(self, action: #selector(AudioGuideCollectionViewCell.wasReleased(_:)), for: UIControlEvents.touchCancel)
        
        addSubview(button)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideBorder() {
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 0
    }
    
    private func setButtonNormalState() {
        if let _ = button.currentImage {
            button.alpha = 0.5
        } else {
            button.backgroundColor = .clear
        }
    }
    
    private func setButtonPressedState() {
        if let _ = button.currentImage {
            button.alpha = 1.0
        } else {
            button.backgroundColor = .white
        }
    }
    
    @objc internal func wasPressed(_ button:UIButton) {
        setButtonPressedState()
    }

    @objc internal func wasReleased(_ button:UIButton) {
        setButtonNormalState()
    }
}
