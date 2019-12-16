/*
Abstract:
Extends UIView  + UIButton to allow copying
*/
import UIKit

// MARK: - UIView Extensions

extension UIView {
	func copyView() -> AnyObject {
		return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))! as AnyObject
	}
}

extension UIButton {
	func copyWithZone(_ zone: NSZone?) -> AnyObject {
		let archiveData = NSKeyedArchiver.archivedData(withRootObject: self)
		let buttonCopy = NSKeyedUnarchiver.unarchiveObject(with: archiveData)
		return buttonCopy! as AnyObject
	}
}
