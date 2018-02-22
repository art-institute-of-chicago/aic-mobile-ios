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
	var nid: Int?	// nid from CMS used to match with Tour Stop
	var coordinate: CLLocationCoordinate2D
	var floor: Int
	var clLocation: CLLocation
	var title: String?
	var thumbnailUrl: URL
	
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
