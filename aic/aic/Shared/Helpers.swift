/*
 Abstract:
 Helper functions
*/

import Foundation
import UIKit

/**
 Math
*/
func clamp(val: Double, minVal: Double, maxVal: Double) -> Double {
    return max(min(maxVal, val), minVal)
}

func clamp(val: CGFloat, minVal: CGFloat, maxVal: CGFloat) -> CGFloat {
    return CGFloat(clamp(val: Double(val), minVal: Double(minVal), maxVal: Double(maxVal)))
}

func map(val: Double, oldRange1: Double, oldRange2: Double, newRange1:Double, newRange2:Double) -> Double {
    let pct = (val-oldRange1) / (oldRange2-oldRange1)
    return newRange1 + (newRange2 - newRange1) * pct
}

func CGPointDistance(p1:CGPoint, p2:CGPoint) -> CGFloat {
    let xDist = (p2.x - p1.x);
    let yDist = (p2.y - p1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

func convertToHoursMinutesSeconds(seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

/**
 Wrapper template for passing structs as NSObjects so they can work with dictionaries
 */
class Wrapper<T> {
    let wrappedValue: T
    init(theValue: T) {
        wrappedValue = theValue
    }
}

/**
 Convenience method to measure text without having to create a UILabel
*/
func getOffsetRect(forText text:String, forFont font:UIFont) -> CGRect {
    let textString = text as NSString
    let textAttributes = [NSFontAttributeName: font]
    
    return textString.boundingRect(with: CGSize(width: 2000, height: 2000), options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
}

/**
 Render HTML text, very slow :/
*/
func getAttributedString(forHTMLText text:String, font:UIFont) -> NSAttributedString {
    // Convert line breaks to HTML breaks
    var textWithHTMLReturns = text.replacingOccurrences(of: "\r\n", with: "<br />")
    textWithHTMLReturns = textWithHTMLReturns.replacingOccurrences(of: "\r", with: "<br />")
    
    // Create HTML text
    let htmlText = NSString(format:"<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize)\">%@</span>" as NSString, textWithHTMLReturns) as String
    
    // Create an HTML Attributed string
    guard let data = htmlText.data(using: .utf8) else {
        return NSAttributedString()
    }
    
    let attrStr = try! NSAttributedString(
        data: data,
        options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue],
        documentAttributes: nil)
    
    return attrStr
}


// Create an attributed string with line-height set
func getAttributedStringWithLineHeight(text:String, font:UIFont, lineHeight:CGFloat) -> NSAttributedString {
    let baselineOffset = lineHeight - UIFont.aicTitleFont()!.pointSize
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 0.0
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.maximumLineHeight = lineHeight
    
    let attrString = NSMutableAttributedString(string: text)
    let range = NSMakeRange(0, attrString.length)
    attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: range)
    attrString.addAttribute(NSBaselineOffsetAttributeName, value:baselineOffset, range: range)
    attrString.addAttribute(NSFontAttributeName, value:font, range: range)
    
    return attrString
}

/**
 View with a blur effect, should be uniform in app
*/
func getBlurEffectView(frame:CGRect) -> UIVisualEffectView {
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = frame
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
    
    return blurEffectView
}

// Great function to get the splash screen dynamically based on device size
// from http://stackoverflow.com/a/29792747
func splashImage(forOrientation orientation: UIInterfaceOrientation, screenSize: CGSize) -> String? {
    var viewSize        = screenSize
    var viewOrientation = "Portrait"
    
    if UIInterfaceOrientationIsLandscape(orientation) {
        viewSize        = CGSize(width: screenSize.height, height: screenSize.width)
        viewOrientation = "Landscape"
    }
    
    if let imagesDict = Bundle.main.infoDictionary {
        if let imagesArray = imagesDict["UILaunchImages"] as? [[String: String]] {
            for dict in imagesArray {
                if let sizeString = dict["UILaunchImageSize"], let imageOrientation = dict["UILaunchImageOrientation"] {
                    let imageSize = CGSizeFromString(sizeString)
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
