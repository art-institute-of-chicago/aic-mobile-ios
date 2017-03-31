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
    class func aicAudioGuideColor() -> UIColor {
        return UIColor(red: 50.0 / 255.0, green: 152.0 / 255.0, blue: 96.0 / 255.0, alpha: 1.0)
    }

    class func aicWhatsonColor() -> UIColor {
        return UIColor(red: 111.0 / 255.0, green: 102.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
    }

    class func aicToursColor() -> UIColor {
        return UIColor(red: 46.0 / 255.0, green: 160.0 / 255.0, blue: 162.0 / 255.0, alpha: 1.0)
    }

    class func aicInfoColor() -> UIColor {
        return UIColor(red: 176.0 / 255.0, green: 83.0 / 255.0, blue: 171.0 / 255.0, alpha: 1.0)
    }

    class func aicMapColor() -> UIColor {
        return UIColor(red: 51.0 / 255.0, green: 123.0 / 255.0, blue: 178.0 / 255.0, alpha: 1.0)
    }

    class func aicButtonsColor() -> UIColor {
        return UIColor(red: 236.0 / 255.0, green: 101.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
    }

    class func aicBluedotColor() -> UIColor {
        return UIColor(red: 0.0, green: 174.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
    }

    class func aicGrayColor() -> UIColor {
        return UIColor(white: 216.0 / 255.0, alpha: 1.0)
    }

    class func aicTabbarColor() -> UIColor {
        return UIColor(white: 26.0 / 255.0, alpha: 1.0)
    }

    class func aicInactiveiconsColor() -> UIColor {
        return UIColor(white: 110.0 / 255.0, alpha: 1.0)
    }

    class func aicAudiobarColor() -> UIColor {
        return UIColor(white: 34.0 / 255.0, alpha: 0.9)
    }
    
    class func aicNearbyColor() -> UIColor {
        return UIColor(red: 25.0 / 255.0, green: 67.0 / 255.0, blue: 119.0 / 255.0, alpha: 1.0)
    }
    
    class func aicDarkBlueColor() -> UIColor {
        return UIColor(red: 9.0 / 255.0, green: 44.0 / 255.0, blue: 87.0 / 255.0, alpha: 1.0)
    }
    
    class func aicLightGrayColor() -> UIColor {
        return UIColor(white: 241.0 / 255.0, alpha: 1.0)
    }
        
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
