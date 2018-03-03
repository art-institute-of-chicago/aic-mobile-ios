/*
 Abstract:
 Custom annotation for Objects (Artworks)
*/

import UIKit
import MapKit

class MapObjectAnnotation : MapAnnotation {
	var nid: Int?	// nid from CMS used to match with Tour Stop
	var floor: Int
    var clLocation: CLLocation
    var title: String?
	var thumbnailUrl: URL
	var thumbnailCropRect: CGRect?
	var tourStopIndex: Int = 0
	
	// Objects with audio
    init(object: AICObjectModel) {
		self.nid = object.nid
		self.floor = object.location.floor
        self.clLocation = CLLocation(latitude: object.location.coordinate.latitude, longitude: object.location.coordinate.longitude)
        self.title = object.title
		self.thumbnailUrl = object.thumbnailUrl
		super.init(coordinate: object.location.coordinate)
    }
	
	// Artworks from search
	init(searchedArtwork: AICSearchedArtworkModel) {
		if let object = searchedArtwork.audioObject {
			self.nid = object.nid
		}
		else {
			self.nid = searchedArtwork.artworkId
		}
		self.floor = searchedArtwork.location.floor
		self.clLocation = CLLocation(latitude: searchedArtwork.location.coordinate.latitude, longitude: searchedArtwork.location.coordinate.longitude)
		self.title = searchedArtwork.title
		self.thumbnailUrl = searchedArtwork.thumbnailUrl
		super.init(coordinate: searchedArtwork.location.coordinate)
	}
	
	// Tour Overview Stop
	init(tour: AICTourModel) {
		self.nid = tour.nid
		self.floor = tour.location.floor
		self.clLocation = CLLocation(latitude: tour.location.coordinate.latitude, longitude: tour.location.coordinate.longitude)
		self.title = tour.title
		self.thumbnailUrl = tour.imageUrl
		super.init(coordinate: tour.location.coordinate)
	}
}
