/*
 Abstract:
 Custom annotations for outside information, i.e. "Michigan Ave entrance", "Pritzer Garden", etc.
*/

import MapKit

class MapTextAnnotation: MapAnnotation {
    enum AnnotationType : String {
        case Landmark = "Landmark"
		case Garden = "Garden"
        case Space = "Space"
        case Gallery = "Gallery"
    }
    
    let type:AnnotationType
	
    var labelText: String
    
    convenience init(coordinateAsCGPoint: CGPoint, text: String, type: AnnotationType) {
        let mkCoord = Common.Map.coordinateConverter.MKMapPointFromPDFPoint(coordinateAsCGPoint).coordinate
        
        self.init(coordinate: mkCoord, text: text, type:type)
    }
    
    init(coordinate: CLLocationCoordinate2D, text: String, type: AnnotationType) {
        self.labelText = text
        self.type = type
		super.init(coordinate: coordinate)
    }
}

