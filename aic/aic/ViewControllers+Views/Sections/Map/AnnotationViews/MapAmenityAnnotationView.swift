/*
 Abstract:
 Custom annotation view for amenities, i.e. Bathrooms, Tickets, etc.
 Shows an appropriate icon, which is included in xcassets
*/

import MapKit

class MapAmenityAnnotationView: MapAnnotationView {
    
    var baseImage:UIImage? = nil
    
    var color:UIColor = .white {
        didSet {
            if oldValue != color {
                setImageColorized()
            }
        }
    }
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, color:UIColor) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        layer.zPosition = Common.Map.AnnotationZPosition.amenities.rawValue
        isEnabled = false

        self.layer.drawsAsynchronously = true
        
        // Load in the base image (white image we colorize based on section)
        if let amenityAnnotation = annotation as? MapAmenityAnnotation {
            baseImage = (UIImage(named: String(describing: amenityAnnotation.type))?.withRenderingMode(.alwaysTemplate))!
        }
        
        // Init image with colorized version
        self.color = color
        setImageColorized()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set image as colorized version
    private func setImageColorized() {
        image = baseImage!.colorized(color)
    }

}
