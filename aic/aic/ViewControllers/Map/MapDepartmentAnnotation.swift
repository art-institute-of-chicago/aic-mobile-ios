/*
 Abstract:
 A representation of a department in the museum
 */
import MapKit

class MapDepartmentAnnotation: NSObject, MKAnnotation {
    var coordinate:CLLocationCoordinate2D
    var title: String?
    var imageName: String
    
    init(coordinate: CLLocationCoordinate2D, title: String, imageName: String) {
        self.coordinate = coordinate
        self.title = title
        self.imageName = imageName
    }
}
