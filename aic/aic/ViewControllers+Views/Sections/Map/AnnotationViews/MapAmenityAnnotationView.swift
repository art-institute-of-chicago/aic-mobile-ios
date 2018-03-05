/*
 Abstract:
 Custom annotation view for amenities, i.e. Bathrooms, Tickets, etc.
 Shows an appropriate icon, which is included in xcassets
*/

import MapKit

class MapAmenityAnnotationView: MapAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        layer.zPosition = Common.Map.AnnotationZPosition.amenities.rawValue
		isEnabled = false

        self.layer.drawsAsynchronously = true
        
        // Load in the base image (white image we colorize based on section)
        if let amenityAnnotation = annotation as? MapAmenityAnnotation {
			switch amenityAnnotation.type {
				case .Checkroom:
					image = #imageLiteral(resourceName: "Checkroom")
				case .Dining:
					image = #imageLiteral(resourceName: "Dining")
					isEnabled = true
				case .Escalator:
					image = #imageLiteral(resourceName: "Elevator")
				case .Elevator:
					image = #imageLiteral(resourceName: "Elevator")
				case .WomensRoom:
					image = #imageLiteral(resourceName: "WomensRoom")
				case .MensRoom:
					image = #imageLiteral(resourceName: "MensRoom")
				case .WheelchairRamp:
					image = #imageLiteral(resourceName: "WheelchairRamp")
				case .FamilyRestroom:
					image = #imageLiteral(resourceName: "FamilyRestroom")
				case .Information:
					image = #imageLiteral(resourceName: "Information")
				case .Tickets:
					image = #imageLiteral(resourceName: "Tickets")
				case .Giftshop:
					image = #imageLiteral(resourceName: "Giftshop")
				case .AudioGuide:
					image = #imageLiteral(resourceName: "AudioGuide")
			}
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		if self.isSelected != selected {
			self.isSelected = selected
			if selected == true {
				UIView.animate(withDuration: 0.25, animations: {
					self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
				})
			}
			else {
				UIView.animate(withDuration: 0.25, animations: {
					self.transform = CGAffineTransform(scaleX: 1, y: 1)
				})
			}
		}
	}
}
