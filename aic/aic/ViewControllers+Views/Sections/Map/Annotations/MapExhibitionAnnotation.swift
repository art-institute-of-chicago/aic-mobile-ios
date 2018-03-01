//
//  MapExhibitionAnnotation.swift
//  aic
//
//  Created by Filippo Vanucci on 2/22/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import MapKit

class MapExhibitionAnnotation : NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var floor: Int
	var clLocation: CLLocation
	var imageUrl: URL?
	var exhibitionModel: AICExhibitionModel
	
	init(exhibition: AICExhibitionModel) {
		self.coordinate = exhibition.location!.coordinate
		self.floor = exhibition.location!.floor
		self.clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		self.exhibitionModel = exhibition
	}
}
