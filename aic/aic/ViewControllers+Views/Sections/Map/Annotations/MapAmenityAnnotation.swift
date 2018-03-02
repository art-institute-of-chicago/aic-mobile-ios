/*
 Abstract:
 Custom annotations for amenities, i.e. Bathrooms, Tickets, etc.
*/

import MapKit

enum MapAmenityAnnotationType : String {
    case Checkroom = "Check Room"
    case Dining = "Dining"
    case Escalator = "Escalator"
    case Elevator = "Elevator"
    case WomensRoom = "Women's Room"
    case MensRoom   = "Men's Room"
    case WheelchairRamp = "Wheelchair Ramp"
    case FamilyRestroom = "Family Restroom"
    case Information = "Information"
    case Tickets = "Tickets"
    case Giftshop = "Gift Shop"
    case AudioGuide = "Audio Guide"
}

class MapAmenityAnnotation: MapAnnotation {
	var nid: Int?
	var floor: Int
    var type: MapAmenityAnnotationType
    
	init(nid: Int, coordinate: CLLocationCoordinate2D, floor: Int, type: MapAmenityAnnotationType) {
		self.nid = nid
		self.floor = floor
        self.type = type
		super.init(coordinate: coordinate)
    }
}
