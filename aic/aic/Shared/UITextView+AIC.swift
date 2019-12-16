/*
Abstract:
Convenience methods added to UITextView
to set it up for attributed text
*/

import UIKit

extension UITextView {

	func setDefaultsForAICAttributedTextView() {
		backgroundColor = .clear
		isScrollEnabled = false
		isEditable = false
		textContainerInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
		textContainer.lineFragmentPadding = 0
	}
}
