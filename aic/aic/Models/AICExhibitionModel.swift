/*
 Abstract:
 Defines a data structure for AIC Exhibition Model
*/

import CoreLocation

struct AICExhibitionModel {
    let title:String
    let shortDescription:String
    let longDescription:String
    let imageUrl:URL
    let imageCropRect: CGRect?
	
	let startDate: Date
	let endDate: Date
    
    let revealTitle: String = "Show On Map"
    
    let thumbnailUrl:URL
    
    let location:CoordinateWithFloor
    
    let bannerString: String?
}
