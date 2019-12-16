/*
Abstract:
A representation of a department in the museum
*/
import MapKit
import Kingfisher

class MapDepartmentAnnotation: MapAnnotation {
	var title: String?
	var image: UIImage?

	init(coordinate: CLLocationCoordinate2D, title: String, imageUrl: URL) {
		self.title = title
		self.image = nil
		super.init(coordinate: coordinate)

		ImageDownloader.default.downloadImage(with: imageUrl, options: nil, progressBlock: nil) { (result) in
			if let result = try? result.get() {
				self.image = result.image
			}
		}
	}
}
