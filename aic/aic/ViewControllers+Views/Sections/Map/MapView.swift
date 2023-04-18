/*
Abstract:
This is a custom implementation of MKMapView that includes some basic setup
and implements a function to get the zoom level

Map Altitude continuous value code reinterpreted from:
https://stackoverflow.com/questions/19572377/how-to-show-map-scale-during-zoom-of-mkmapview-like-apples-maps-app?rq=1
*/

import MapKit

class MapView: MKMapView {
	var floorplanOverlay: FloorplanOverlay? = nil {
		didSet {
			if let previousOverlay = oldValue {
				removeOverlay(previousOverlay)
			}

			if floorplanOverlay != nil {
				addOverlay(floorplanOverlay!)
			}
		}
	}

	// Used to calculate the map's altitude at any point
	// for fading annotations in out during pinching
	private var startingHeight: Double = 0.0

	// Rotate the map so that the Michigan Ave entrance faces south
	let defaultHeading: CGFloat = 90.0
	let defaultZoom: CGFloat = 400.0
	let topDownPitch: CGFloat = 0.0
	let perspectivePitch: CGFloat = 60.0

	private (set) var previousAltitude: Double = 0.0
	private (set) var currentAltitude: Double = 0.0

	private(set) var previousZoomLevel: Common.Map.ZoomLevelAltitude = .zoomLimit
	private(set) var currentZoomLevel: Common.Map.ZoomLevelAltitude = .zoomLimit

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    setup()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		calculateStartingHeight()
	}

	func getAnnotations(filteredBy annotationsToFilterOut: [MKAnnotation]) -> [MKAnnotation] {
		return annotations.filter({
			let thisAnnotation = $0
			return annotationsToFilterOut.firstIndex(where: {$0 === thisAnnotation}) == nil
		})
	}

	// Fade out annotations before removing them
	func removeAnnotationsWithAnimation(annotations: [MKAnnotation]) {
		for annotation in annotations {
			if let view = view(for: annotation) {
				UIView.animate(withDuration: 0.25, animations: {
					view.alpha = 0.0
				}, completion: {(_: Bool) in
					self.removeAnnotation(annotation)
				})
			} else {
				removeAnnotation(annotation)
			}
		}
	}

	func showFullMap(useDefaultHeading: Bool = false,
                   centerCoordinateDistance: Double = Common.Map.ZoomLevelAltitude.zoomDefault.rawValue) {
		if let overlay = floorplanOverlay {
			let heading = useDefaultHeading ? defaultHeading : camera.heading

			let buildingRect = overlay.boundingMapRect
			let userMapPoint = MKMapPoint(userLocation.coordinate)
			var centerPoint = buildingRect.getCenter().coordinate // Common.Map.defaultLocation

			let distanceFromBuildingCenter = userMapPoint.distance(to: buildingRect.getCenter())
			if  distanceFromBuildingCenter < Common.Location.minDistanceFromMuseumForLocation {
				centerPoint = userLocation.coordinate
			}

			zoomIn(onCenterCoordinate: centerPoint,
             centerCoordinateDistance: centerCoordinateDistance,
             withAnimation: true,
             heading: heading)
      debugPrint("MapView.showFullMap lat: \(centerPoint.latitude) long: \(centerPoint.longitude)")
		}
	}

  func zoomIn(onCenterCoordinate centerCoordinate: CLLocationCoordinate2D) {
    zoomIn(onCenterCoordinate: centerCoordinate,
           centerCoordinateDistance: Common.Map.ZoomLevelAltitude.zoomDefault.rawValue,
           heading: camera.heading)
  }

	func zoomIn(onCenterCoordinate centerCoordinate: CLLocationCoordinate2D,
              centerCoordinateDistance: Double,
              withAnimation animated: Bool = true,
              heading: Double? = nil,
              pitch: CGFloat? = nil) {
		let newCamera = MKMapCamera()
		newCamera.centerCoordinate = centerCoordinate
		newCamera.centerCoordinateDistance = centerCoordinateDistance
    newCamera.heading = self.camera.heading
    newCamera.pitch = self.camera.pitch

		if let heading {
			newCamera.heading = heading
		}

		if let pitch {
			newCamera.pitch = pitch
		} else {
			newCamera.pitch = perspectivePitch
		}

		setCamera(newCamera, animated: animated)
    debugPrint("MapView.\(newCamera.debugDescription)")
	}

	func keepMapInView(zoomLimit: Double) {
		// Check altitude
		if currentAltitude > zoomLimit {
			showFullMap(centerCoordinateDistance: zoomLimit)
      debugPrint("MapView.keepMapInView zoomLimit: \(zoomLimit)")
		} else {
			// Make sure our floorplan is on-screen
			if let floorplanOverlay = floorplanOverlay {
				let buildingRect = floorplanOverlay.boundingMapRect
				let cameraCenter = MKMapPoint(camera.centerCoordinate)
				let distanceFromBuildingCenter = cameraCenter.distance(to: buildingRect.getCenter())

				if distanceFromBuildingCenter > Common.Location.minDistanceFromMuseumForLocation {
					zoomIn(onCenterCoordinate: floorplanOverlay.coordinate,
                 centerCoordinateDistance: camera.centerCoordinateDistance,
                 heading: nil,
                 pitch: camera.pitch)
				}
			}
		}
	}

	// Find the altitude based on our start value and the current map visible to bounds ratio
	func calculateStartingHeight() {
		// Set the starting height for checking altitude while zooming
		let currentZoomScale = Double(bounds.size.width) / visibleMapRect.size.width
		let factor = 1.0 / currentZoomScale

		startingHeight = camera.centerCoordinateDistance/factor
	}

	func calculateCurrentAltitudeAndZoomLevel() {
		// Altitude
		previousAltitude = currentAltitude
		currentAltitude = camera.centerCoordinateDistance

		// Zoom Level
		previousZoomLevel = currentZoomLevel
		if currentAltitude > Common.Map.ZoomLevelAltitude.zoomLimit.rawValue {
			currentZoomLevel = .zoomLimit
		} else {
			for zoomLevel in Common.Map.ZoomLevelAltitude.allValues {
				if currentAltitude <= zoomLevel.rawValue {
					currentZoomLevel = zoomLevel
				}
			}
		}

//    debugPrint("CAMERA ALTITUDE: \(camera.centerCoordinateDistance) currentAltitude: \(currentAltitude) previousAltitude: \(previousAltitude)")
	}
}

// MARK: - Private - Setups
private extension MapView {

  func setup() {
    mapType = .mutedStandard
    userTrackingMode = .none
    pointOfInterestFilter = .excludingAll

    isZoomEnabled = true
    isPitchEnabled = true
    showsCompass = false
    showsScale = false
    showsTraffic = false
    showsBuildings = false
    showsUserLocation = true
    tintColor = .white
  }

}
