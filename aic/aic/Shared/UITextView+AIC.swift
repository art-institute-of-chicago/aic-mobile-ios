/*
 Abstract:
 Convenience methods added to UITextView
 to set it up for attributed text
 */

import UIKit

extension UITextView {
    
    func setDefaultsForAICAttributedTextView() {
        linkTextAttributes = [NSForegroundColorAttributeName : UIColor.aicButtonsColor()]
        backgroundColor = UIColor.clear
        isScrollEnabled = false
        isEditable = false
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
