/*
Abstract:
Model for map, containing all annotations + overlays
Parses these from SVG File
*/

import Foundation
import CoreGraphics
import MapKit

struct AICMapModel {
	// Global Annotations
	private (set) var imageAnnotations: [MapImageAnnotation] = []
	private (set) var landmarkAnnotations: [MapTextAnnotation] = []
	private (set) var gardenAnnotations: [MapTextAnnotation] = []

	var diningAnnotations: [MapAmenityAnnotation] {
		var result = [MapAmenityAnnotation]()
		for floor in AppDataManager.sharedInstance.app.map.floors {
			result.append(contentsOf: floor.diningAnnotations)
		}
		return result
	}

	// Floors
	let floors: [AICMapFloorModel]
}
