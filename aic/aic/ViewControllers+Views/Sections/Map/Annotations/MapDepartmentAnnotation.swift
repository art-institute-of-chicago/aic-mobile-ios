/*
 Abstract:
 A representation of a department in the museum
 */
import MapKit
import Kingfisher

class MapDepartmentAnnotation: MapAnnotation {
    var title: String?
    var image: UIImage? = nil
    
    init(coordinate: CLLocationCoordinate2D, title: String, imageUrl: URL) {
        self.title = title
        self.image = nil
		super.init(coordinate: coordinate)
		
		ImageDownloader.default.downloadImage(with: imageUrl, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, error, url, data) in
			if image != nil {
				self.image = image!
			}
		}
    }
}
