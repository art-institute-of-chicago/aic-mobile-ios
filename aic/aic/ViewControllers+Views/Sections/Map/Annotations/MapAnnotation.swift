//
//  MapAnnotation.swift
//  aic
//
//  Created by Filippo Vanucci on 3/2/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import MapKit

class MapAnnotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	
	init(coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
		super.init()
	}
}
