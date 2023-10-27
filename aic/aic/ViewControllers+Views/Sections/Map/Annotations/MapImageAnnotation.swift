/*
Abstract:
An annotation that is represented only by an imageName
currently used by the Lions
*/

import MapKit
import Kingfisher

class MapImageAnnotation: MapAnnotation {
	var identifier: String
	var image: UIImage?

	init(coordinate: CLLocationCoordinate2D, imageUrl: URL) {
		self.identifier = imageUrl.absoluteString
		self.image = nil
		super.init(coordinate: coordinate)

		ImageDownloader.default.downloadImage(with: imageUrl, options: nil, progressBlock: nil) { (result) in
			if let result = try? result.get() {
				self.image = result.image
			}
		}
	}

	init(coordinate: CLLocationCoordinate2D, image: UIImage, identifier: String) {
		self.identifier = identifier
		self.image = image
		super.init(coordinate: coordinate)
	}

}
