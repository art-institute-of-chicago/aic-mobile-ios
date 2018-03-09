/*
 Abstract:
 Custom annotation views for location (used by Whats On most likely)
 */

import UIKit
import MapKit

class MapLocationAnnotationView : MapAnnotationView {
    class var reuseIdentifier:String {
        return "mapLocation"
    }
    
    private let pinImageView = UIImageView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        guard let locationAnnotation = annotation as? MapLocationAnnotation else {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
            return
        }
        
        super.init(annotation:locationAnnotation, reuseIdentifier:reuseIdentifier)
        
        layer.zPosition = Common.Map.AnnotationZPosition.objectsSelected.rawValue
        layer.drawsAsynchronously = true
        isEnabled = false
		
//        pinImageView.image = #imageLiteral(resourceName: "mapPin")
        pinImageView.sizeToFit()
        
        // Offset to bottom
        centerOffset = CGPoint(x: 0, y: -pinImageView.frame.size.height / 2);
        self.bounds = pinImageView.bounds
        
        // Add Subviews
        addSubview(pinImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
