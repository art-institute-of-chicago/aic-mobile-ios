//
//  MapExhibitionAnnotation.swift
//  aic
//
//  Created by Filippo Vanucci on 2/22/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import MapKit

class MapExhibitionAnnotation: MapAnnotation {
	var floor: Int
	var clLocation: CLLocation
	var imageUrl: URL?
	var exhibitionModel: AICExhibitionModel

	init(exhibition: AICExhibitionModel) {
		self.floor = exhibition.location!.floor
		self.clLocation = CLLocation(latitude: exhibition.location!.coordinate.latitude, longitude: exhibition.location!.coordinate.longitude)
		self.exhibitionModel = exhibition
		super.init(coordinate: exhibition.location!.coordinate)
	}
}
