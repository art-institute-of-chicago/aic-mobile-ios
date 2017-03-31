/*
 Abstract:
 Information view, contains things like Title, Year, etc.
*/


import UIKit

class ObjectInfoView: ObjectContentSectionView {
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(info:String) {
        let attrString = getAttributedString(forHTMLText: info, font: UIFont.aicTextFont()!)
        bodyTextView.attributedText = attrString
    }
}
