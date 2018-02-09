/*
 Abstract:
 Defines a data structure for AIC Exhibition Model
*/

import CoreLocation

struct AICExhibitionModel {
	let id: Int
    let title: String
    let shortDescription: String
    var imageUrl: URL?
	
	let startDate: Date
	let endDate: Date
	
	let webUrl: URL?
    
	let location: CoordinateWithFloor? // TODO: temporarily making this optional
}
