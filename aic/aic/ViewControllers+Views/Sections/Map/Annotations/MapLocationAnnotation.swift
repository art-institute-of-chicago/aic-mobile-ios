/*
Abstract:
Custom annotation for Locations (i.e. the location of a news item/gallery/etc.)
*/

import UIKit
import MapKit

class MapLocationAnnotation: NSObject, MKAnnotation {
	// MARK: Properties
	var coordinate: CLLocationCoordinate2D

	// MARK: Initialization
	init(coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
	}
}
