/*
 Abstract:
 Defines a data structure for AIC Exhibition Model
*/

import CoreLocation

class AICExhibitionModel : NSObject {
	let id: Int
	
    let title: String
    let shortDescription: String
    var imageUrl: URL?
	
	let startDate: Date
	let endDate: Date
    
	let location: CoordinateWithFloor? // TODO: making this optional, it's not always available in the data
	
	init(id: Int, title: String, shortDescription: String, imageUrl: URL?, startDate: Date, endDate: Date, location: CoordinateWithFloor?) {
		self.id = id
		self.title = title
		self.shortDescription = shortDescription
		self.imageUrl = imageUrl
		self.startDate = startDate
		self.endDate = endDate
		self.location = location
		super.init()
	}
}

class AICExhibitionInCMS : NSObject {
	let id: Int
	let imageUrl: URL?
	let sort: Int
	
	init(id: Int, imageUrl: URL?, sort: Int) {
		self.id = id
		self.imageUrl = imageUrl
		self.sort = sort
	}
}
