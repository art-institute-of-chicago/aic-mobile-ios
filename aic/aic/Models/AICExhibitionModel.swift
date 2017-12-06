/*
 Abstract:
 Defines a data structure for AIC Exhibition Model
*/

import CoreLocation

struct AICExhibitionModel {
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
