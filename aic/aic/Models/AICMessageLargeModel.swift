/*
 Abstract:
 This class represents an overlay message, i.e. Location Services are off
 */

import UIKit

struct AICMessageLargeModel {
    let backgroundColor = UIColor.aicButtonsColor
    let iconImage:UIImage
    let title:String
    let message:String
    let actionButtonTitle:String
    let cancelButtonTitle:String?
}
