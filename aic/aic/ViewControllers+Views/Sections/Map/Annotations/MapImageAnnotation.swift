/*
 Abstract:
 An annotation that is represented only by an imageName
 currently used by the Lions
 */

import MapKit
import Kingfisher

class MapImageAnnotation: NSObject, MKAnnotation {
	var identifier: String
	
    var coordinate: CLLocationCoordinate2D
	var image: UIImage? = nil
    
    init(coordinate: CLLocationCoordinate2D, imageUrl: URL) {
        self.coordinate = coordinate
		self.identifier = imageUrl.absoluteString
		self.image = nil
		super.init()
		
		ImageDownloader.default.downloadImage(with: imageUrl, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, error, url, data) in
			if image != nil {
				self.image = image!
			}
		}
    }
    
}

