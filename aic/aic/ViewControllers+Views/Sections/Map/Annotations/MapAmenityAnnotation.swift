/*
Abstract:
Custom annotations for amenities, i.e. Bathrooms, Tickets, etc.
*/

import MapKit

enum MapAmenityAnnotationType: String {
	case AudioGuide = "Audio Guide"
	case Checkroom = "Check Room"
	case Dining = "Dining"
	case Escalator = "Escalator"
	case Elevator = "Elevator"
	case FamilyRestroom = "Family Restroom"
	case Giftshop = "Gift Shop"
	case Information = "Information"
	case MembersLounge = "Members Lounge"
	case MensRoom   = "Men's Room"
	case Tickets = "Tickets"
	case WheelchairRamp = "Wheelchair Ramp"
	case WomensRoom = "Women's Room"
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
