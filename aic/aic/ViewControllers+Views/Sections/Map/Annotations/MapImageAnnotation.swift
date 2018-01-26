/*
 Abstract:
 An annotation that is represented only by an imageName
 currently used by the Lions
 */

import MapKit

class MapImageAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var imageName: String
    
    init(coordinate: CLLocationCoordinate2D, imageName: String) {
        self.coordinate = coordinate
        self.imageName = imageName
    }
    
}
