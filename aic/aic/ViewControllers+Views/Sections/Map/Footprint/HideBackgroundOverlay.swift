/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This class provides an MKOverlay that can be used to hide MapKit's
underlaying map tiles.
*/

import Foundation
import MapKit

/**
This class provides an MKOverlay that can be used to hide MapKit's
underlaying map tiles.
*/
class HideBackgroundOverlay: MKPolygon {

	/// - returns: a HideBackgroundOverlay object that covers the world.
	class func hideBackgroundOverlay() -> HideBackgroundOverlay {
		var corners =  [MKMapPoint(x: MKMapRect.world.maxX, y: MKMapRect.world.maxY),
						MKMapPoint(x: MKMapRect.world.minX, y: MKMapRect.world.maxY),
						MKMapPoint(x: MKMapRect.world.minX, y: MKMapRect.world.minY),
						MKMapPoint(x: MKMapRect.world.maxX, y: MKMapRect.world.minY)]

		return HideBackgroundOverlay(points: &corners, count: corners.count)
	}

	/**
	- returns: true to tell MapKit to hide its underlying map tiles, as long
	as this overlay is visible (which, as you can see above, is
	everywhere in the world), effectively hiding all map tiles and
	replacing them with a solid colored MKPolygon.
	*/
	override func canReplaceMapContent() -> Bool {
		return true
	}

}
