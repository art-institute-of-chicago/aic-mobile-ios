/*
 Abstract:
 An annotation that is represented only by an imageName
 currently used by the Lions
 */

import MapKit
import Kingfisher

class MapImageAnnotation: MapAnnotation {
	var identifier: String
	
	var image: UIImage? = nil
    
    init(coordinate: CLLocationCoordinate2D, imageUrl: URL) {
		self.identifier = imageUrl.absoluteString
		self.image = nil
		super.init(coordinate: coordinate)
		
		ImageDownloader.default.downloadImage(with: imageUrl, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, error, url, data) in
			if image != nil {
				self.image = image!
			}
		}
    }
	
	init(coordinate: CLLocationCoordinate2D, image: UIImage, identifier: String) {
		self.identifier = identifier
		self.image = image
		super.init(coordinate: coordinate)
	}
    
}

