/*
 Abstract:
 Custom annotation for Objects (Artworks)
*/

import UIKit
import MapKit

class MapObjectAnnotation : NSObject, MKAnnotation {
	var nid: Int?	// nid from CMS used to match with Tour Stop
    var coordinate: CLLocationCoordinate2D
	var floor: Int
    var clLocation: CLLocation
    var title: String?
    var subtitle: String?
	var thumbnailUrl: URL
	var thumbnailCropRect: CGRect?
	
	// Objects with audio
    init(object:AICObjectModel) {
		self.nid = object.nid
        self.coordinate = object.location.coordinate
		self.floor = object.location.floor
        self.clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.title = object.title
		self.thumbnailUrl = object.thumbnailUrl
    }
	
	// Artworks from search
	init(searchedArtwork:AICSearchedArtworkModel) {
		if let object = searchedArtwork.audioObject {
			self.nid = object.nid
		}
		self.coordinate = searchedArtwork.location.coordinate
		self.floor = searchedArtwork.location.floor
		self.clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		self.title = searchedArtwork.title
		self.thumbnailUrl = searchedArtwork.thumbnailUrl
	}
}
