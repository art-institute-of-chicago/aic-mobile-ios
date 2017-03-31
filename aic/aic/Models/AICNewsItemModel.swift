/*
 Abstract:
 Defines a data structure for AIC News Items
*/

import CoreLocation

struct AICNewsItemModel : AICNewsTourItemProtocol {
    let type:NewsTourItemType = .news
    
    let title:String
    let shortDescription:String
    let longDescription:String
    let additionalInformation: String?
    let imageUrl:URL
    let imageCropRect: CGRect?
    
    let revealTitle: String = "Show On Map"
    
    let thumbnailUrl:URL
    
    let location:CoordinateWithFloor
    
    let bannerString: String?
}
