/*
 Abstract:
 Custom annotations for amenities, i.e. Bathrooms, Tickets, etc.
*/

import MapKit

enum MapAmenityAnnotationType : String {
    case Checkroom = "Checkroom"
    case Dining = "Dining"
    case Escalator = "Escalator"
    case Elevator = "Elevator"
    case WomensRoom = "WomensRoom"
    case MensRoom   = "MensRoom"
    case WheelchairRamp = "WheelchairRamp"
    case FamilyRestroom = "FamilyRestroom"
    case Information = "Information"
    case Tickets = "Tickets"
    case Giftshop = "Giftshop"
    case AudioGuide = "AudioGuide"
}

class MapAmenityAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var type: MapAmenityAnnotationType
    
    init(coordinate: CLLocationCoordinate2D, type:MapAmenityAnnotationType) {
        self.coordinate = coordinate
        self.type = type
    }
}
