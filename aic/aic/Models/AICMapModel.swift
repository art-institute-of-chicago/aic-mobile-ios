/*
 Abstract:
 Model for map, containing all annotations + overlays
 Parses these from SVG File
 */

import Foundation
import CoreGraphics
import MapKit

struct AICMapModel {
	// Background
	let backgroundOverlay: FloorplanOverlay
	
    // Global Annotations
    private (set) var imageAnnotations: [MapImageAnnotation] = []
    private (set) var landmarkAnnotations: [MapTextAnnotation] = []
    private (set) var gardenAnnotations: [MapTextAnnotation] = []
    
    // Floors
    let floors: [AICMapFloorModel]
}
