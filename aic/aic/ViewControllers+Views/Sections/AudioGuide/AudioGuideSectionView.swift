/*
 Abstract:
 The main view for the audio guide
*/

import UIKit

class AudioGuideSectionView: SectionView {
    private let maxInputCharacters = 5

    // No top margin on iPhone 5, should define this width somewhere this is gross
    let numberPadTopMargin = UIScreen.main.bounds.width > 320 ? 30 : 0
    let numberPadView:UICollectionView
    
    private(set) var curInputValue = "";
    
    init(section:AICSectionModel, numberPadView:UICollectionView) {
        self.numberPadView = numberPadView
        
        super.init(section:section)
        
        titleView.backgroundColor = UIColor.clear
        backgroundColor = section.color.withAlphaComponent(0.8)
        
        // Add Subviews
        scrollViewContentView.insertSubview(numberPadView, belowSubview: titleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if(!didSetupConstraints) {
            scrollViewContentView.snp.makeConstraints({ (make) -> Void in
                make.bottom.equalTo(numberPadView)
            })
            
            didSetupConstraints = true
        }
        
        numberPadView.snp.remakeConstraints({ (make) -> Void in
            make.width.equalTo(numberPadView.frame.width)
            make.height.equalTo(numberPadView.frame.height)
            make.centerX.equalTo(numberPadView.superview!)
            make.top.greaterThanOrEqualTo(titleView.snp.bottom).offset(numberPadTopMargin).priority(Common.Layout.Priority.high.rawValue)
            //make.top.equalTo(scrollViewContentView).offset(titleView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize).height)
        })
        
        super.updateConstraints()
    }
    
    func addNumberPadInput(value:String) {
        if curInputValue.characters.count < maxInputCharacters {
            curInputValue.append(value)
        }
        
        setTitleForCurInputValue()
    }
    
    func removeLastNumberPadInput() {
        let curNumInputChars = curInputValue.characters.count
        if curNumInputChars > 0 {
            if curNumInputChars == 1 {
                curInputValue = ""
            } else {
                let index = curInputValue.characters.index(curInputValue.endIndex, offsetBy: -1)
                curInputValue = curInputValue.substring(to: index)
            }
        }
        
        setTitleForCurInputValue()
    }
    
    func clearInput() {
        curInputValue = ""
        setTitleForCurInputValue()
    }
    
    // Simple shake animation
    // from http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
    func shakeForIncorrect() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: titleView.titleLabel.center.x - 10, y: titleView.titleLabel.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: titleView.titleLabel.center.x + 10, y: titleView.titleLabel.center.y))
        titleView.titleLabel.layer.add(animation, forKey: "position")
    }
    
    private func setTitleForCurInputValue() {
        let curNumInputChars = curInputValue.characters.count
        
        if curNumInputChars == 0 {
            self.titleView.titleLabel.text = self.titleView.titleString
        } else {
            self.titleView.titleLabel.text = curInputValue
        }
    }
}
