/*
 Abstract:
 Custom annotation for Objects (Artworks)
*/

import UIKit
import MapKit

class MapObjectAnnotation : NSObject, MKAnnotation {
    
    // MARK: Properties
    var coordinate: CLLocationCoordinate2D
    var location: CLLocation
    var title: String?
    var subtitle: String?
    var object:AICObjectModel
    
    // MARK: Initialization
    init(object:AICObjectModel) {
        self.coordinate = object.location.coordinate
        self.location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.title = object.title
        self.object = object
    }
}