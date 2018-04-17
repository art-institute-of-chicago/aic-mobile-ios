/*
 Abstract:
 Defines a data structure for AIC Exhibition Model
*/

import CoreLocation

struct AICExhibitionModel {
	let id: Int
	
	let isFeatured: Bool
	
    let title: String
    let shortDescription: String
    var imageUrl: URL?
	
	let startDate: Date
	let endDate: Date
    
	let location: CoordinateWithFloor? // TODO: making this optional, it's not always available in the data
}
