/*
 Abstract:
 Defines a data structure for AIC Exhibition Model
*/

import CoreLocation

struct AICExhibitionModel {
    let title: String
    let shortDescription: String
    let imageUrl: URL?
	
	let startDate: Date
	let endDate: Date
    
	let location: CoordinateWithFloor? // TODO: temporarily making this optional
}
