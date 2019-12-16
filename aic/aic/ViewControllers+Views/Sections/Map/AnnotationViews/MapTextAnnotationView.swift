/*
Abstract:
Custom annotation view for outside information, i.e. "Michigan Ave entrance", "Pritzer Garden", etc.
Shows a simple UILabel
*/

import MapKit

class MapTextAnnotationView: MapAnnotationView {
	var label: UILabel?

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		layer.zPosition = Common.Map.AnnotationZPosition.text.rawValue
		layer.drawsAsynchronously = true
		isEnabled = false
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setAnnotation(forMapTextAnnotation annotation: MapTextAnnotation) {
		// Reset Label
		if self.label != nil {
			self.label!.removeFromSuperview()
		}

		self.label = UILabel()
		let label = self.label!

		// Determine the font based on the type of text annotation
		var font: UIFont! = nil

		switch annotation.type {
		case .Space:
			font = .aicMapSpacesFont

		case .Landmark:
			font = .aicMapTextFont

		case .Garden:
			font = .aicMapTextFont

		case .Gallery:
			font = .aicMapTextFont
		}

		self.annotation = annotation

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 0
		paragraphStyle.maximumLineHeight = 18

		let attrString = NSMutableAttributedString(string: annotation.labelText)
		let range = NSRange(location: 0, length: attrString.length)
		attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
		attrString.addAttribute(.font, value: font, range: range)

		label.textColor = .white
		label.attributedText = attrString
		label.numberOfLines = 0
		label.textAlignment = NSTextAlignment.center
		label.sizeToFit()

		addSubview(label)

		label.frame.origin = CGPoint(x: -label.bounds.width/2, y: -label.bounds.height/2)
		//self.frame.size = label.frame.size
	}
}
