/*
 Abstract:
 Custom annotation view for amenities, i.e. Bathrooms, Tickets, etc.
 Shows an appropriate icon, which is included in xcassets
*/

import MapKit

class MapAmenityAnnotationView: MapAnnotationView {
    
    var baseImage:UIImage? = nil
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, color:UIColor) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        layer.zPosition = Common.Map.AnnotationZPosition.amenities.rawValue
        isEnabled = false

        self.layer.drawsAsynchronously = true
        
        // Load in the base image (white image we colorize based on section)
        if let amenityAnnotation = annotation as? MapAmenityAnnotation {
			if amenityAnnotation.type == .FamilyRestroom ||
				amenityAnnotation.type == .WomensRoom ||
				amenityAnnotation.type == .MensRoom {
				image = #imageLiteral(resourceName: "restroom")
			}
			else if amenityAnnotation.type == .Information {
				image = #imageLiteral(resourceName: "information")
			}
			else if amenityAnnotation.type == .Dining {
				image = #imageLiteral(resourceName: "restaurant")
			}
			else if amenityAnnotation.type == .Giftshop {
				image = #imageLiteral(resourceName: "giftshop")
			}
			else {
            	image = (UIImage(named: String(describing: amenityAnnotation.type))?.withRenderingMode(.alwaysTemplate))!
			}
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
