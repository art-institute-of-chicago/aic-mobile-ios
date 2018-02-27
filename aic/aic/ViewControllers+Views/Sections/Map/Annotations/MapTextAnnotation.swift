/*
 Abstract:
 Custom annotations for outside information, i.e. "Michigan Ave entrance", "Pritzer Garden", etc.
*/

import MapKit

class MapTextAnnotation: NSObject, MKAnnotation {
    enum AnnotationType : String {
        case Landmark = "Landmark"
		case Garden = "Garden"
        case Space = "Space"
        case Gallery = "Gallery"
    }
    
    let type:AnnotationType
    
    var coordinate: CLLocationCoordinate2D
    var labelText: String
    
    convenience init(coordinateAsCGPoint:CGPoint, text:String, type:AnnotationType) {
        let mkCoord = MKCoordinateForMapPoint(Common.Map.coordinateConverter.MKMapPointFromPDFPoint(coordinateAsCGPoint))
        
        self.init(coordinate: mkCoord, text: text, type:type)
    }
    
    init(coordinate: CLLocationCoordinate2D, text:String, type:AnnotationType) {
        self.coordinate = coordinate
        self.labelText = text
        self.type = type
    }
}

