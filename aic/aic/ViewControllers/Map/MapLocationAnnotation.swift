/*
 Abstract:
 Custom annotation for Locations (i.e. the location of a news item/gallery/etc.)
 */

import UIKit
import MapKit

class MapLocationAnnotation : NSObject, MKAnnotation {
    // MARK: Properties
    var coordinate: CLLocationCoordinate2D
    var thumbUrl: URL
    
    // MARK: Initialization
    init(coordinate: CLLocationCoordinate2D, thumbUrl:URL) {
        self.coordinate = coordinate
        self.thumbUrl = thumbUrl
    }
}
