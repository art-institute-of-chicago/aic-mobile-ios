/*
 Abstract:
 AIC colors extending UIColor
*/

import UIKit

#if os(OSX)
    
    import Cocoa
    public  typealias PXColor = NSColor
    
#else
    
    import UIKit
    public  typealias PXColor = UIColor
    
#endif

extension UIColor {
	static let aicHomeColor: UIColor =  UIColor(red: 0.0 / 255.0, green: 128.0 / 255.0, blue: 133.0 / 255.0, alpha: 1.0)
	
	static let aicAudioGuideColor: UIColor = UIColor(red: 109.0 / 255.0, green: 40.0 / 255.0, blue: 97.0 / 255.0, alpha: 1.0)

	static let aicMapColor: UIColor = UIColor(red: 6.0 / 255.0, green: 50.0 / 255.0, blue: 88.0 / 255.0, alpha: 1.0)
	
	static let aicInfoColor: UIColor = UIColor(red: 206.0 / 255.0, green: 107.0 / 255.0, blue: 39.0 / 255.0, alpha: 1.0)
	
	static let aicHomeLightColor: UIColor =  UIColor(red: 55.0 / 255.0, green: 162.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
	
	static let aicMapLightColor: UIColor = UIColor(red: 57.0 / 255.0, green: 101.0 / 255.0, blue: 139.0 / 255.0, alpha: 1.0)
	
	static let aicButtonBlueColor: UIColor =  UIColor(red: 6.0 / 255.0, green: 50.0 / 255.0, blue: 88.0 / 255.0, alpha: 1.0)
	
	static let aicButtonBlueDarkColor: UIColor =  UIColor(red: 6.0 / 255.0, green: 50.0 / 255.0, blue: 88.0 / 255.0, alpha: 0.5)
	
	static let aicButtonGreenBlueColor: UIColor =  UIColor(red: 55.0 / 255.0, green: 162.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
	
	static let aicButtonGreenBlueDarkColor: UIColor =  UIColor(red: 55.0 / 255.0, green: 162.0 / 255.0, blue: 165.0 / 255.0, alpha: 0.5)
	
	static let aicButtonOrangeColor: UIColor = UIColor(red: 206.0 / 255.0, green: 107.0 / 255.0, blue: 39.0 / 255.0, alpha: 1.0)
	
	static let aicButtonOrangeDarkColor: UIColor = UIColor(red: 206.0 / 255.0, green: 107.0 / 255.0, blue: 39.0 / 255.0, alpha: 0.5)

	static let aicButtonsColor: UIColor = UIColor(red: 236.0 / 255.0, green: 101.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
	
	static let aicFloorTextColor: UIColor = UIColor(red: 26.0 / 255.0, green: 69.0 / 255.0, blue: 110.0 / 255.0, alpha: 1.0)
	
	static let aicFloorColor: UIColor = UIColor(white: 1.0, alpha: 1.0)
	
	static let aicFloorUnselectedColor: UIColor = UIColor(white: 1.0, alpha: 0.7)

	static let aicBluedotColor: UIColor = UIColor(red: 6.0 / 255.0, green: 50.0 / 255.0, blue: 88.0 / 255.0, alpha: 1.0)
	
	static let aicBluedotUnselectedColor: UIColor = UIColor(red: 6.0 / 255.0, green: 50.0 / 255.0, blue: 88.0 / 255.0, alpha: 0.5)

	static let aicGrayColor: UIColor = UIColor(white: 216.0 / 255.0, alpha: 1.0)
	
	static let aicLightGrayColor: UIColor = UIColor(white: 241.0 / 255.0, alpha: 1.0)
	
	static let aicMediumGrayColor: UIColor = UIColor(white: 161.0 / 255.0, alpha: 1.0)
	
	static let aicDarkGrayColor: UIColor = UIColor(white: 51.0 / 255.0, alpha: 1.0)

	static let aicTabbarColor: UIColor = UIColor(white: 26.0 / 255.0, alpha: 1.0)

	static let aicInactiveiconsColor: UIColor = UIColor(white: 110.0 / 255.0, alpha: 1.0)

	static let aicAudiobarColor: UIColor = UIColor(white: 34.0 / 255.0, alpha: 0.9)
    
	static let aicNearbyColor: UIColor = UIColor(red: 25.0 / 255.0, green: 67.0 / 255.0, blue: 119.0 / 255.0, alpha: 1.0)
    
	static let aicDarkBlueColor: UIColor = UIColor(red: 9.0 / 255.0, green: 44.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
	
	static let aicDividerLineColor: UIColor = UIColor(white: 216.0 / 255.0, alpha: 1.0)
	
	static let aicDividerLineDarkColor: UIColor = UIColor(white: 64.0 / 255.0, alpha: 1.0)
	
	static let aicDividerLineTransparentColor: UIColor = UIColor(white: 1.0, alpha: 0.5)
	
	static let aicIntroTextBackgroundColor: UIColor = UIColor(red: 199.0 / 255.0, green: 226.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0)
	
	static let aicHomeMemberPromptLinkColor: UIColor = UIColor(red: 48.0 / 255.0, green: 113.0 / 255.0, blue: 119.0 / 255.0, alpha: 1.0)
	
	static let aicHomeLinkColor: UIColor = UIColor(red: 55.0 / 255.0, green: 162.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
	
	static let aicCardDarkTextColor: UIColor = UIColor(white: 161.0 / 255.0, alpha: 1.0)
	
	static let aicCardDarkLinkColor: UIColor = UIColor(red: 48.0 / 255.0, green: 162.0 / 255.0, blue: 166.0 / 255.0, alpha: 1.0)
    
    static let aicAudioPlayerBackgroundColor: UIColor = UIColor(white: 25.0 / 255.0, alpha: 1.0)
	
	static let aicMapCardBackgroundColor: UIColor = UIColor(red: 119.0 / 255.0, green: 137.0 / 255.0, blue: 167.0 / 255.0, alpha: 1.0)
	
	static let aicMemberCardLoginFieldColor: UIColor = UIColor(white: 240.0 / 255.0, alpha: 1.0)
	
	static let aicMemberCardRedColor: UIColor = UIColor(red: 145.0 / 255.0, green: 7.0 / 255.0, blue: 45.0 / 255.0, alpha: 1.0)
	
	static let aicTooltipBackgroundColor: UIColor = UIColor(red: 94.0 / 255.0, green: 115.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0)
	
    func lighter(_ amount : CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(1 + amount)
    }
    
    func darker(_ amount : CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(1 - amount)
    }
    
    fileprivate func hueColorWithBrightnessAmount(_ amount: CGFloat) -> PXColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0
        
        #if os(iOS)
            
            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return PXColor( hue: hue,
                                saturation: saturation,
                                brightness: brightness * amount,
                                alpha: alpha )
            } else {
                return self
            }
            
        #else
            
            getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            return PXColor( hue: hue,
                            saturation: saturation,
                            brightness: brightness * amount,
                            alpha: alpha )
            
        #endif
        
    }
}
