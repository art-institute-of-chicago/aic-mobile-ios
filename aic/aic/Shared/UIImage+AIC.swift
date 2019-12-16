/*
Abstract:
Adds functionality to UIImage for tinting
*/
import UIKit

extension UIImage {
	func colorized(_ color: UIColor) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		let context = UIGraphicsGetCurrentContext()
		context!.setBlendMode(.multiply)
		context!.translateBy(x: 0, y: self.size.height); context!.scaleBy(x: 1.0, y: -1.0)
		context!.draw(self.cgImage!, in: rect)
		context!.clip(to: rect, mask: self.cgImage!)
		context!.setFillColor(color.cgColor)
		context!.fill(rect)
		let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return colorizedImage!
	}
}
