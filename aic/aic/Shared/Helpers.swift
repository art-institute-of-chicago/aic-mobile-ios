/*
Abstract:
Helper functions
*/

import Foundation
import UIKit

// MARK: Math

func clamp(val: Double, minVal: Double, maxVal: Double) -> Double {
	return max(min(maxVal, val), minVal)
}

func clamp(val: CGFloat, minVal: CGFloat, maxVal: CGFloat) -> CGFloat {
	return CGFloat(clamp(val: Double(val), minVal: Double(minVal), maxVal: Double(maxVal)))
}

func map(val: Double, oldRange1: Double, oldRange2: Double, newRange1: Double, newRange2: Double) -> Double {
	let pct = (val-oldRange1) / (oldRange2-oldRange1)
	return newRange1 + (newRange2 - newRange1) * pct
}

func CGPointDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
	let xDist = (p2.x - p1.x)
	let yDist = (p2.y - p1.y)
	return sqrt((xDist * xDist) + (yDist * yDist))
}

func convertToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
	return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

extension BinaryInteger {
	var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
	var degreesToRadians: Self { return self * .pi / 180 }
	var radiansToDegrees: Self { return self * 180 / .pi }
}

// MARK: Data Structs
/**
Wrapper template for passing structs as NSObjects so they can work with dictionaries
*/
class Wrapper<T> {
	let wrappedValue: T
	init(theValue: T) {
		wrappedValue = theValue
	}
}

// MARK: Text

/**
Convenience method to measure text without having to create a UILabel
*/
func getOffsetRect(forText text: String, forFont font: UIFont) -> CGRect {
	let textString = text as NSString
	let textAttributes = [NSAttributedString.Key.font: font]

	return textString.boundingRect(with: CGSize(width: 2000, height: 2000), options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
}

/**
Render HTML text, very slow :/
*/
func getAttributedString(forHTMLText text: String, font: UIFont) -> NSAttributedString {
	// Convert line breaks to HTML breaks
	var textWithHTMLReturns = text.replacingOccurrences(of: "\r\n", with: "<br />")
	textWithHTMLReturns = textWithHTMLReturns.replacingOccurrences(of: "\r", with: "<br />")

	// Create HTML text
	let htmlText = NSString(format: "<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize)\">%@</span>" as NSString, textWithHTMLReturns) as String

	// Create an HTML Attributed string
	guard let data = htmlText.data(using: .utf8) else {
		return NSAttributedString()
	}

	let attrStr = try! NSAttributedString(
		data: data,
		options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
		documentAttributes: nil)

	return attrStr
}

// Create an attributed string with line-height set
func getAttributedStringWithLineHeight(text: String, font: UIFont, lineHeight: CGFloat) -> NSAttributedString {
	let attrString = NSMutableAttributedString(string: text)

	let paragraphStyle = NSMutableParagraphStyle()
	paragraphStyle.lineSpacing = 0.0
	paragraphStyle.minimumLineHeight = lineHeight
	paragraphStyle.maximumLineHeight = lineHeight

	let baselineOffset = lineHeight - UIFont.aicTitleFont.pointSize

	let range = NSRange(location: 0, length: attrString.length)
	attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
	attrString.addAttribute(.baselineOffset, value: baselineOffset, range: range)
	attrString.addAttribute(.font, value: font, range: range)

	return attrString
}

func getAttributedStringWithHTMLEnabled(text: String, font: UIFont, lineHeight: CGFloat) -> NSAttributedString {
	do {
		let data = text.data(using: .utf8, allowLossyConversion: true)!
		let attributedString = try NSMutableAttributedString(data: data,
															 options: [.documentType: NSAttributedString.DocumentType.html,
																	   .characterEncoding: String.Encoding.utf8.rawValue],
															 documentAttributes: nil
		)

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 0.0
		paragraphStyle.minimumLineHeight = lineHeight
		paragraphStyle.maximumLineHeight = lineHeight

		let baselineOffset = lineHeight - UIFont.aicTitleFont.pointSize

		let range = NSRange(location: 0, length: attributedString.length)
		attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
		attributedString.addAttribute(.baselineOffset, value: baselineOffset, range: range)
		attributedString.addAttribute(.font, value: font, range: range)

		return attributedString
	} catch {
		return getAttributedStringWithLineHeight(text: text, font: font, lineHeight: lineHeight)
	}
}

// MARK: Visual Effects

/// View with a blur effect, should be uniform in app
func getBlurEffectView(frame: CGRect) -> UIVisualEffectView {
	let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
	let blurEffectView = UIVisualEffectView(effect: blurEffect)
	blurEffectView.frame = frame
	blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation

	return blurEffectView
}

/// Great function to get the splash screen dynamically based on device size
// from http://stackoverflow.com/a/29792747
func splashImage(forOrientation orientation: UIInterfaceOrientation, screenSize: CGSize) -> String? {
	var viewSize        = screenSize
	var viewOrientation = "Portrait"

	if orientation.isLandscape {
		viewSize        = CGSize(width: screenSize.height, height: screenSize.width)
		viewOrientation = "Landscape"
	}

	if let imagesDict = Bundle.main.infoDictionary {
		if let imagesArray = imagesDict["UILaunchImages"] as? [[String: String]] {
			for dict in imagesArray {
				if let sizeString = dict["UILaunchImageSize"], let imageOrientation = dict["UILaunchImageOrientation"] {
					let imageSize = NSCoder.cgSize(for: sizeString)
					if imageSize.equalTo(viewSize) && viewOrientation == imageOrientation {
						if let imageName = dict["UILaunchImageName"] {
							return imageName
						}
					}
				}
			}
		}
	}

	return nil
}

/// Add Parallex effect to UIView
func addParallexEffect(toView view: UIView, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
	let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
	horizontal.minimumRelativeValue = left
	horizontal.maximumRelativeValue = right

	let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
	vertical.minimumRelativeValue = top
	vertical.maximumRelativeValue = bottom

	let group = UIMotionEffectGroup()
	group.motionEffects = [horizontal, vertical]
	view.addMotionEffect(group)
}
