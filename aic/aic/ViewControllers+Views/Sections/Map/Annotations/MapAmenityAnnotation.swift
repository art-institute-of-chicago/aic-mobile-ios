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

class MapAmenityAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var type: MapAmenityAnnotationType
    
    init(coordinate: CLLocationCoordinate2D, type:MapAmenityAnnotationType) {
        self.coordinate = coordinate
        self.type = type
    }
}
