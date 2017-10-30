/*
 Abstract:
 Shared text field with custom insets for entering member card info
 */

import UIKit

class InfoSectionTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 10)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 10)
    }
}
