/*
Abstract:
Main ViewController for MapView. Controls map display, overlays,
annotations and floor selection. Also the entry point for CoreLocation
*/

import UIKit
import MapKit
import Localize_Swift

protocol MapViewControllerDelegate: AnyObject {
	func mapWasPressed()
	func mapDidPressArtworkPlayButton(artwork: AICObjectModel)
	func mapDidSelectTourStop(stopId: Int)
	func mapDidSelectRestaurant(restaurant: AICRestaurantModel)
}

final class MapViewController: UIViewController {
  weak var delegate: MapViewControllerDelegate?

	private(set) var displayPointOfInterest: MapPointOfInterestType = .allInformation {
		didSet {
			updateMapForModeChange()
		}
	}

	private let mapModel = AppDataManager.sharedInstance.app.map

	// Map View
    private let mapView = MapView(frame: UIScreen.main.bounds)
    private let mapViewHideBackgroundOverlay = HideBackgroundOverlay.hideBackgroundOverlay()
    private var zoomLimitValue = Common.Map.ZoomLevelAltitude.zoomLimit.rawValue

    // Floor Selector
    private let floorSelectorMargin = CGPoint(x: 20, y: 20)
    private var floorSelectorViewController = MapFloorSelectorViewController()

	private(set) var previousFloor = Common.Map.startFloor
	private(set) var currentFloor = Common.Map.startFloor
	private(set) var currentUserFloor: Int?
	private(set) var previousUserFloor: Int?

	init() {
		super.init(nibName: nil, bundle: nil)
        setupNavigationItemTitle()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logAnalytics()
    }

	// MARK: Mode Functions

	private func updateMapForModeChange() {
		if displayPointOfInterest == .giftshop || displayPointOfInterest == .restrooms || displayPointOfInterest == .memberLounge {
			zoomLimitValue = Common.Map.ZoomLevelAltitude.zoomFarLimit.rawValue
		} else {
			zoomLimitValue = Common.Map.ZoomLevelAltitude.zoomLimit.rawValue
		}

		// Deselect all annotations
		deselectAllAnnotations()

		// Clear the active annotations from the previous mode
		clearActiveAnnotations()

		// Set the new state
		mapView.removeAnnotations(mapView.annotations)

		updateAnnotations()
	}

	// Go through each floor and clear out it's location + tour objects
	private func clearActiveAnnotations() {
		for floor in mapModel.floors {
			floor.clearActiveAnnotations()
		}
	}

	// MARK: Show Annotations

	// Show all the objects, landmarks and amenities on the map
	// Used when viewing the map by itself in the map (nearby) section
	func showAllInformation() {
		// Switch modes
		displayPointOfInterest = .allInformation

		if mapView.camera.centerCoordinateDistance > Common.Map.ZoomLevelAltitude.zoomDefault.rawValue {
			mapView.showFullMap(useDefaultHeading: true)
		}
			// Zooming in a bit to avoid the situation where you are in between artworks level and department level
		else if mapView.camera.centerCoordinateDistance < Common.Map.ZoomLevelAltitude.zoomDetail.rawValue+15.0 &&
			mapView.camera.centerCoordinateDistance > Common.Map.ZoomLevelAltitude.zoomDetail.rawValue-15.0 {
			mapView.zoomIn(onCenterCoordinate: mapView.camera.centerCoordinate,
                     centerCoordinateDistance: Common.Map.ZoomLevelAltitude.zoomDetail.rawValue - 10.0,
                     withAnimation: true,
                     heading: mapView.camera.heading,
                     pitch: mapView.perspectivePitch)
		}
	}

	func showArtwork(artwork: AICObjectModel) {
		displayPointOfInterest = .artwork

		// Add location annotation the floor model
		let floor = mapModel.floors[artwork.location.floor]
		var artworkAnnotation: MapObjectAnnotation?
		for objectAnnotation in floor.objectAnnotations {
			if objectAnnotation.nid == artwork.nid {
				artworkAnnotation = objectAnnotation
				artworkAnnotation!.tourStopOrder = 0
			}
		}

		if artworkAnnotation != nil {
			setCurrentFloor(forFloorNum: floor.floorNumber, andResetMap: false)

			mapView.addAnnotation(artworkAnnotation!)

			// Zoom in on the item
			mapView.zoomIn(onCenterCoordinate: artwork.location.coordinate)
		}
	}

	func showSearchedArtwork(searchedArtwork: AICSearchedArtworkModel) {
		displayPointOfInterest = .searchedArtwork

		// Add location annotation the floor model
		let floor = mapModel.floors[searchedArtwork.location.floor]
		var artworkAnnotation: MapObjectAnnotation?

		if let object = searchedArtwork.audioObject {
			for objectAnnotation in floor.objectAnnotations {
				if objectAnnotation.nid == object.nid {
					artworkAnnotation = objectAnnotation
					artworkAnnotation!.tourStopOrder = 0
				}
			}
		} else {
			artworkAnnotation = MapObjectAnnotation(searchedArtwork: searchedArtwork)
		}

		setCurrentFloor(forFloorNum: floor.floorNumber, andResetMap: false)

		mapView.addAnnotation(artworkAnnotation!)

		// Zoom in on the item
		mapView.zoomIn(onCenterCoordinate: searchedArtwork.location.coordinate)
	}

	func showExhibition(exhibition: AICExhibitionModel) {
		displayPointOfInterest = .exhibition

		// Add location annotation the floor model
		let floor = mapModel.floors[exhibition.location!.floor]
		let exhibitionAnnotation = MapExhibitionAnnotation(exhibition: exhibition)

		setCurrentFloor(forFloorNum: floor.floorNumber, andResetMap: false)

		mapView.addAnnotation(exhibitionAnnotation)

		// Zoom in on the item
		mapView.zoomIn(onCenterCoordinate: exhibition.location!.coordinate)

		// Select the annotation (which eventually updates it's view)
		mapView.selectAnnotation(exhibitionAnnotation, animated: true)
	}

	func showDining() {
		displayPointOfInterest = .dining

		updateDiningAnnotations()

		floorSelectorViewController.disableUserHeading()

		mapView.addAnnotations(mapModel.floors[currentFloor].diningAnnotations)

		// Zoom in on the first restaurant
		if AppDataManager.sharedInstance.app.restaurants.count > 0 {
			let firstRestaurant = AppDataManager.sharedInstance.app.restaurants.first!

			let startFloor: Int = firstRestaurant.location.floor
			setCurrentFloor(forFloorNum: startFloor, andResetMap: false)

			highlightRestaurant(identifier: firstRestaurant.nid, location: firstRestaurant.location)
		}
	}

	func showMemberLounge() {
		displayPointOfInterest = .memberLounge

		// if no member lounges are on the current floor, find a floor with member lounge
		if mapModel.floors[currentFloor].memberLoungeAnnotations.count == 0 {
			for index in 0...mapModel.floors.count-1 {
				// start from floor 1
				let floorNumber = (index + 1) < mapModel.floors.count ? (index + 1) : 0
				if mapModel.floors[floorNumber].memberLoungeAnnotations.count > 0 {
					setCurrentFloor(forFloorNum: floorNumber)
					break
				}
			}
		}

		updateMemberLoungeAnnotations()

		showAnnotationsGroup(annotations: mapModel.floors[currentFloor].memberLoungeAnnotations as [MKAnnotation])
	}

	func showGiftShop() {
		displayPointOfInterest = .giftshop

		// if no giftshops are on the current floor, find a floor with giftshops
		if mapModel.floors[currentFloor].giftShopAnnotations.count == 0 {
			for index in 0...mapModel.floors.count-1 {
				// start from floor 1
				let floorNumber = (index + 1) < mapModel.floors.count ? (index + 1) : 0
				if mapModel.floors[floorNumber].giftShopAnnotations.count > 0 {
					setCurrentFloor(forFloorNum: floorNumber)
					break
				}
			}
		}

		updateGiftShopAnnotations()

		showAnnotationsGroup(annotations: mapModel.floors[currentFloor].giftShopAnnotations as [MKAnnotation])
	}

	func showRestrooms() {
		displayPointOfInterest = .restrooms

		updateRestroomAnnotations()

		showAnnotationsGroup(annotations: mapModel.floors[currentFloor].restroomAnnotations as [MKAnnotation])
	}

	func showAnnotationsGroup(annotations: [MKAnnotation]) {
		floorSelectorViewController.disableUserHeading()

		// Zoom in on the gift shop annotations
		setViewableArea(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedPositionY)))
		mapView.showAnnotations(annotations, animated: false)

		// Show all annotations messes with the pitch + heading,
		// so reset our pitch + heading to preferred defaults
		mapView.camera.heading = mapView.defaultHeading
		mapView.camera.pitch = mapView.perspectivePitch
		if mapView.camera.centerCoordinateDistance <= Common.Map.ZoomLevelAltitude.zoomDetail.rawValue {
			mapView.camera.centerCoordinateDistance = Common.Map.ZoomLevelAltitude.zoomMedium.rawValue
		} else if mapView.camera.centerCoordinateDistance > zoomLimitValue {
			mapView.camera.centerCoordinateDistance = zoomLimitValue
		}
		mapView.camera.heading = mapView.defaultHeading
	}

	// Shows all the objects on a tour, with active/inactive
	// states depending on which floor is selected.
	func showTour(forTour tourModel: AICTourModel) {
		displayPointOfInterest = .tour

		// Find the stops for this floor and set them on the model
		var objectAnnotations: [MapObjectAnnotation] = []
		// add overview
		let tourOverviewStop = MapObjectAnnotation(tour: tourModel)
		tourOverviewStop.tourStopOrder = 0
		// add objects to each floor
		for floor in mapModel.floors {
			let floorStops = tourModel.stops.filter({ $0.object.location.floor == floor.floorNumber })

			if tourModel.location.floor == floor.floorNumber {
				floor.tourStopAnnotations.append(tourOverviewStop)
			}

			// Set their objects as active on the map floor
			floor.setTourStopAnnotations(forTourStopModels: floorStops)
			objectAnnotations.append(contentsOf: floor.tourStopAnnotations)
		}

		// order annotations and assign tour stop numbers
		// based on total number of stops, instead of number coming from CMS (some stops might be missing)
		objectAnnotations.sort { (A, B) -> Bool in
			return A.tourStopOrder < B.tourStopOrder
		}
		var number: Int = 0
		for annotation in objectAnnotations {
			annotation.tourStopOrder = number
			number += 1
		}

		// Set Floor
		setCurrentFloor(forFloorNum: tourModel.location.floor, andResetMap: false)

		// Add annotations
		var annotations: [MKAnnotation] = []
		annotations.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotations.append(contentsOf: mapModel.floors[currentFloor].galleryAnnotations as [MKAnnotation])
		annotations.append(contentsOf: objectAnnotations as [MKAnnotation])
		annotations.append(mapView.userLocation)

		let allAnnotations = mapView.getAnnotations(filteredBy: annotations)
		mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)

		mapView.addAnnotations(annotations)
	}

	// MARK: Highlight Annotations

	// Highlights a specific tour object
	// Highlights item, switches to it's floor
	// and centers the map around it
	func highlightTourStop(identifier: Int, location: CoordinateWithFloor) {
		// Select the annotation
		for floor in mapModel.floors {
			for annotation in floor.tourStopAnnotations {
				if annotation.nid == identifier {
					if let view = mapView.view(for: annotation) as? MapObjectAnnotationView {
						view.alpha = 1.0
					}

					// Turn off user heading since we want to jump to a specific place
					floorSelectorViewController.disableUserHeading()

					// Go to that floor
					if location.floor != currentFloor {
						setCurrentFloor(forFloorNum: location.floor, andResetMap: false)
					}

					// Zoom in on the item
                    mapView.zoomIn(onCenterCoordinate: location.coordinate,
                                   centerCoordinateDistance: Common.Map.ZoomLevelAltitude.zoomDetail.rawValue,
                                   withAnimation: true,
                                   heading: mapView.camera.heading,
                                   pitch: mapView.perspectivePitch)

					// Select the annotation (which eventually updates it's view)
					mapView.selectAnnotation(annotation, animated: false)
				}
			}
		}
	}

	func highlightRestaurant(identifier: Int, location: CoordinateWithFloor) {
		// Select the annotation
		for floor in mapModel.floors {
			for annotation in floor.diningAnnotations {
				if annotation.nid == identifier {
					// Turn off user heading since we want to jump to a specific place
					floorSelectorViewController.disableUserHeading()

					// Go to that floor
					if location.floor != currentFloor {
						setCurrentFloor(forFloorNum: location.floor, andResetMap: false)
					}

					// Zoom in on the item
					mapView.zoomIn(onCenterCoordinate: location.coordinate,
                         centerCoordinateDistance: Common.Map.ZoomLevelAltitude.zoomMedium.rawValue - 50,
                         withAnimation: true,
                         heading: mapView.camera.heading,
                         pitch: mapView.perspectivePitch)

					// Select the annotation (which eventually updates it's view)
					mapView.selectAnnotation(annotation, animated: true)
				}
			}
		}
	}

	func highlightArtwork(identifier: Int, location: CoordinateWithFloor) {
		// Select the annotation
		for annotation in mapView.annotations {
			if let artworkAnnotation = annotation as? MapObjectAnnotation {
				if artworkAnnotation.nid == identifier {
					// Turn off user heading since we want to jump to a specific place
					floorSelectorViewController.disableUserHeading()

					// Go to that floor
					setCurrentFloor(forFloorNum: location.floor, andResetMap: false)

					// Zoom in on the item
					mapView.zoomIn(onCenterCoordinate: location.coordinate,
                         centerCoordinateDistance: Common.Map.ZoomLevelAltitude.zoomDefault.rawValue,
                         withAnimation: true,
                         heading: mapView.camera.heading,
                         pitch: mapView.perspectivePitch)

					// Select the annotation (which eventually updates it's view)
					mapView.selectAnnotation(annotation, animated: true)
				}
			}
		}
	}

	// MARK: Viewable Area
	// Sets the viewable area of our map and repositions the floor selector
	func setViewableArea(frame: CGRect) {
		// Set the layout margins to center map in visible area
		let mapInsets = UIEdgeInsets(
			top: abs(frame.minY - mapView.frame.minY),
			left: 0,
			bottom: abs(frame.maxY - mapView.frame.maxY),
            right: 0
		)

		mapView.layoutMargins = mapInsets

		// Update the floor selector with new position
		let mapFrame = mapView.frame.inset(by: mapInsets)

		let floorSelectorX = UIScreen.main.bounds.width - floorSelectorViewController.view.frame.size.width - floorSelectorMargin.x
		var floorSelectorY = mapFrame.origin.y + mapFrame.height - floorSelectorViewController.view.frame.height - floorSelectorMargin.y
		let maxFloorSelectorY = UIScreen.main.bounds.height - Common.Layout.tabBarHeight - Common.Layout.miniAudioPlayerHeight - floorSelectorViewController.view.frame.height - floorSelectorMargin.y
		floorSelectorY = min(floorSelectorY, maxFloorSelectorY)

		floorSelectorViewController.view.frame.origin = CGPoint(x: floorSelectorX, y: floorSelectorY)
		mapView.calculateStartingHeight()
	}

	// MARK: Change floor

	// Show the current floor's overlay, and change the views
	func setCurrentFloor(forFloorNum floorNum: Int, andResetMap: Bool = false) {
		previousFloor = currentFloor
		currentFloor = floorNum

		floorSelectorViewController.setSelectedFloor(forFloorNum: currentFloor)

		// Set the overlay
		mapView.floorplanOverlay = mapModel.floors[floorNum].overlay

		// Add annotations
		switch displayPointOfInterest {
		case .allInformation:
			updateAllInformationAnnotations()
			break
		case .artwork, .searchedArtwork:
			break
		case .exhibition:
			break
		case .dining:
			break
		case .memberLounge:
			updateMemberLoungeAnnotations()
			break
		case .giftshop:
			updateGiftShopAnnotations()
			break
		case .restrooms:
			showRestrooms()
			break
		case .tour:
			updateTourAnnotations()
			break
		}

		// Snap back to full view
		if andResetMap {
			deselectAllAnnotations()
			mapView.showFullMap()
		}
	}

	// MARK: Annotations
	// Clears out all of the locations + tour objects
	// currently set for floors

	@objc func updateMapWithTimer() {
		updateAnnotations()
	}

	func updateAnnotations() {
		mapView.calculateCurrentAltitudeAndZoomLevel()

		switch displayPointOfInterest {
		case .allInformation:
			updateAllInformationAnnotations()
			updateAllInformationAnnotationViews()
			updateUserLocationAnnotationView()

		case .tour:
			updateTourAnnotations()
			updateTourAnnotationViews()
			updateUserLocationAnnotationView()

		case .artwork, .searchedArtwork:
			updateArtworkAnnotationView()
			updateUserLocationAnnotationView()

		case .exhibition:
			updateExhibitionAnnotationView()
			updateUserLocationAnnotationView()

		case .dining:
			updateDiningAnnotationViews()
			updateUserLocationAnnotationView()

		case .memberLounge:
			updateMemberLoungeAnnotations()
			updateUserLocationAnnotationView()

		case .giftshop:
			updateGiftShopAnnotations()
			updateUserLocationAnnotationView()

		case .restrooms:
			updateRestroomAnnotations()
			updateUserLocationAnnotationView()
		}
	}

	func updateAllInformationAnnotations() {
		var annotations: [MKAnnotation] = []

		// Set the annotations for a zoom level
		switch mapView.currentZoomLevel {
		case .zoomLimit, .zoomFarLimit:
			annotations.append(contentsOf: mapModel.landmarkAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.gardenAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].amenityAnnotations as [MKAnnotation])
			//			annotations.append(contentsOf: mapModel.floors[currentFloor].farObjectAnnotations as [MKAnnotation])
			break

		case .zoomDefault:
			annotations.append(contentsOf: mapModel.gardenAnnotations as [MKAnnotation])
			//			annotations.append(contentsOf: mapModel.floors[currentFloor].spaceAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].amenityAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].departmentAnnotations as [MKAnnotation])
			//			annotations.append(contentsOf: mapModel.floors[currentFloor].farObjectAnnotations as [MKAnnotation])
			break

		case .zoomMedium:
			annotations.append(contentsOf: mapModel.gardenAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].spaceAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].amenityAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].departmentAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].objectAnnotations as [MKAnnotation])
			//			annotations.append(contentsOf: mapModel.floors[currentFloor].farObjectAnnotations as [MKAnnotation])
			break

		case .zoomDetail, .zoomMax:
			annotations.append(contentsOf: mapModel.floors[currentFloor].spaceAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].amenityAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].galleryAnnotations as [MKAnnotation])
			annotations.append(contentsOf: mapModel.floors[currentFloor].objectAnnotations as [MKAnnotation])
			break
		}
		annotations.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotations.append(mapView.userLocation)

		let allAnnotations = mapView.getAnnotations(filteredBy: annotations)
		mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)
		mapView.addAnnotations(annotations)
	}

	// Highlight object annotations that are in a visible range as the user pans around
	private func updateAllInformationAnnotationViews() {
		if mapView.currentZoomLevel == .zoomMax || mapView.currentZoomLevel == .zoomDetail {
			// Update Objects
			let centerCoord = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)

			for annotation in mapModel.floors[currentFloor].objectAnnotations {
				if let view = mapView.view(for: annotation) as? MapObjectAnnotationView {
					let distance = centerCoord.distance(from: annotation.clLocation)
					if distance < 15 {
						if view.isSelected == false {
							view.setMode(mode: .imageInfo)
						}
					} else {
						view.setMode(mode: .dot)
					}
				}
			}
		} else if mapView.currentZoomLevel == .zoomMedium || mapView.currentZoomLevel == .zoomDefault || mapView.currentZoomLevel == .zoomLimit {
			for annotation in mapModel.floors[currentFloor].farObjectAnnotations {
				if let view = mapView.view(for: annotation) as? MapObjectAnnotationView {
					view.setMode(mode: .smallImageInfo)
				}
			}
		}
	}

	private func updateTourAnnotations() {
		var annotations: [MKAnnotation] = []
		annotations.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		if mapView.currentAltitude <= Common.Map.ZoomLevelAltitude.zoomDetail.rawValue + 50.0 {
			annotations.append(contentsOf: mapModel.floors[currentFloor].galleryAnnotations as [MKAnnotation])
		}
		for floor in mapModel.floors {
			annotations.append(contentsOf: floor.tourStopAnnotations as [MKAnnotation])
		}
		annotations.append(mapView.userLocation)

		let allAnnotations = mapView.getAnnotations(filteredBy: annotations)
		mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)

		mapView.addAnnotations(annotations)
	}

	private func updateTourAnnotationViews() {
		for floor in mapModel.floors {
			for annotation in floor.tourStopAnnotations {
				if let view = mapView.view(for: annotation) as? MapObjectAnnotationView {
					if annotation.floor == currentFloor {
						view.alpha = 1.0
					} else {
						view.alpha = 0.5
					}
				}
			}
		}
	}

	private func updateArtworkAnnotationView() {
		for annotation in mapView.annotations {
			if let objectAnnotation = annotation as? MapObjectAnnotation {
				if let view = mapView.view(for: objectAnnotation) as? MapObjectAnnotationView {
					view.setMode(mode: .image)
					view.setSelected(true, animated: true)
					if objectAnnotation.floor == currentFloor {
						view.alpha = 1.0
					} else {
						view.alpha = 0.5
					}
				}
			}
		}
	}

	private func updateExhibitionAnnotationView() {
		for annotation in mapView.annotations {
			if let exhibitionAnnotation = annotation as? MapExhibitionAnnotation {
				if let view = mapView.view(for: annotation) as? MapExhibitionAnnotationView {
					if exhibitionAnnotation.floor == currentFloor {
						view.alpha = 1.0
					} else {
						view.alpha = 0.5
					}
				}
			}
		}
	}

	private func updateDiningAnnotations() {
		var annotations: [MKAnnotation] = []
		annotations.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotations.append(contentsOf: mapModel.diningAnnotations as [MKAnnotation])
		annotations.append(mapView.userLocation)

		let allAnnotations = mapView.getAnnotations(filteredBy: annotations)
		mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)

		mapView.addAnnotations(annotations)
	}

	private func updateDiningAnnotationViews() {
		for floor in mapModel.floors {
			for annotation in floor.diningAnnotations {
				if let view = mapView.view(for: annotation) as? MapAmenityAnnotationView {
					if floor.floorNumber == currentFloor {
						view.alpha = 1.0
					} else {
						view.alpha = 0.5
					}
				}
			}
		}
	}

	private func updateMemberLoungeAnnotations() {
		var annotations: [MKAnnotation] = []
		annotations.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotations.append(contentsOf: mapModel.floors[currentFloor].memberLoungeAnnotations as [MKAnnotation])
		annotations.append(mapView.userLocation)

		let allAnnotations = mapView.getAnnotations(filteredBy: annotations)
		mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)

		mapView.addAnnotations(annotations)
	}

	private func updateGiftShopAnnotations() {
		var annotations: [MKAnnotation] = []
		annotations.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotations.append(contentsOf: mapModel.floors[currentFloor].giftShopAnnotations as [MKAnnotation])
		annotations.append(mapView.userLocation)

		let allAnnotations = mapView.getAnnotations(filteredBy: annotations)
		mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)

		mapView.addAnnotations(annotations)
	}

	private func updateUserLocationAnnotationView() {
		if let locationView = mapView.view(for: mapView.userLocation) {
			if currentUserFloor == currentFloor {
				locationView.alpha = 1.0
			} else {
				locationView.alpha = 0.5
			}
		}
	}

	private func updateRestroomAnnotations() {
		var annotations: [MKAnnotation] = []
		annotations.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotations.append(contentsOf: mapModel.floors[currentFloor].restroomAnnotations as [MKAnnotation])
		annotations.append(mapView.userLocation)

		let allAnnotations = mapView.getAnnotations(filteredBy: annotations)
		mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)

		mapView.addAnnotations(annotations)
	}

	// Deselect any open annotations
	private func deselectAllAnnotations() {
		for annotation in mapView.annotations {
			mapView.deselectAnnotation(annotation, animated: false)
		}
	}
}

// MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
	/**
	This renders the map with a background overlay
	and the overlay for the current floorplan
	*/
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		// Floorplan Overlay
		if overlay.isKind(of: FloorplanOverlay.self) {
			let renderer: FloorplanOverlayRenderer = FloorplanOverlayRenderer(overlay: overlay as MKOverlay)
			return renderer
		}

		// Hide Background Overlay
		if overlay.isKind(of: HideBackgroundOverlay.self) == true {
			let renderer = MKPolygonRenderer(overlay: overlay as MKOverlay)

			// No border
			renderer.lineWidth = 0.0
			renderer.strokeColor = UIColor.white.withAlphaComponent(0.0)
			renderer.fillColor = .aicMapColor
			return renderer
		}

		NSException(name: NSExceptionName(rawValue: "InvalidMKOverlay"),
                reason: "Did you add an overlay but forget to provide a matching renderer here? The class was type \(type(of: overlay))",
                userInfo: ["wasClass": type(of: overlay)]).raise()
		return MKOverlayRenderer()
	}

	/**
	This function sets the view when an annotation is added to the map.
	It tries to re-use existing views where available
	*/
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Department Annotations
        if let departmentAnnotation = annotation as? MapDepartmentAnnotation {
            guard let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: MapDepartmentAnnotationView.reuseIdentifier
            ) as? MapDepartmentAnnotationView else {
                let view = MapDepartmentAnnotationView(
                    annotation: departmentAnnotation,
                    reuseIdentifier: MapDepartmentAnnotationView.reuseIdentifier
                )
                return view
            }

            view.setAnnotation(forDepartmentAnnotation: departmentAnnotation)
            return view
        }

        // Image Annotations
        if let imageAnnotation = annotation as? MapImageAnnotation {
            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: imageAnnotation.identifier) else {
                let view = MKAnnotationView(
                    annotation: imageAnnotation,
                    reuseIdentifier: imageAnnotation.identifier
                )
                view.image = imageAnnotation.image
                return view
            }

            return view
        }

        // Amenity annotation
        if let amenityAnnotation = annotation as? MapAmenityAnnotation {
            guard let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: amenityAnnotation.type.rawValue
            ) as? MapAmenityAnnotationView else {
                let view = MapAmenityAnnotationView(
                    annotation: amenityAnnotation,
                    reuseIdentifier: amenityAnnotation.type.rawValue
                )
                return view
            }

            view.annotation = amenityAnnotation
            return view
        }

        // Text annotations
        if let textAnnotation = annotation as? MapTextAnnotation {
            var view: MapTextAnnotationView? = mapView.dequeueReusableAnnotationView(
                withIdentifier: textAnnotation.type.rawValue
            ) as? MapTextAnnotationView
            if view == nil {
                view = MapTextAnnotationView(
                    annotation: textAnnotation,
                    reuseIdentifier: textAnnotation.type.rawValue
                )
            }

            // Update the view
            view?.setAnnotation(forMapTextAnnotation: textAnnotation)
            return view
        }

        // Object annotations
        if let objectAnnotation = annotation as? MapObjectAnnotation {
            // TODO: Commenting this out as a temporary fix to bug where some tour stops disappear at times
            //            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: MapObjectAnnotationView.reuseIdentifier) as? MapObjectAnnotationView {
            //                view.delegate = self
            //                view.setAnnotation(forObjectAnnotation: objectAnnotation)
            //                return view
            //            }

            let view = MapObjectAnnotationView(
                annotation: objectAnnotation,
                reuseIdentifier: MapObjectAnnotationView.reuseIdentifier
            )
            if displayPointOfInterest == .tour {
                view.setMode(mode: .image, inTour: true)
                view.setTourStopNumber(number: objectAnnotation.tourStopOrder)
            }
            view.delegate = self
            return view
        }

        // Exhibition annotations
        if let exhibitionAnnotation = annotation as? MapExhibitionAnnotation {
            guard let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: MapExhibitionAnnotationView.reuseIdentifier
            ) as? MapExhibitionAnnotationView else {
                let view = MapExhibitionAnnotationView(
                    annotation: exhibitionAnnotation,
                    reuseIdentifier: MapExhibitionAnnotationView.reuseIdentifier
                )
                view.exhibitionModel = exhibitionAnnotation.exhibitionModel
                return view
            }
            view.exhibitionModel = exhibitionAnnotation.exhibitionModel
            return view
        }

        // Location (News Item) annotations
        if let locationAnnotation = annotation as? MapLocationAnnotation {
            guard let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: MapLocationAnnotationView.reuseIdentifier
            ) as? MapLocationAnnotationView else {
                let view = MapLocationAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: MapLocationAnnotationView.reuseIdentifier
                )
                return view
            }

            view.annotation = locationAnnotation
            return view
        }

        return nil
    }

	/**
	Annotation selected, set it's mode to .Selected
	*/
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let view = view as? MapObjectAnnotationView {
			// Switch to the floor for this object
			let annotation = view.annotation as! MapObjectAnnotation

			// Switch floors
			if currentFloor != annotation.floor {
				setCurrentFloor(forFloorNum: annotation.floor, andResetMap: false)
			}

            mapView.setCenter(annotation.coordinate, animated: true)

			if displayPointOfInterest == .tour {
				if let stopId = annotation.nid {
					delegate?.mapDidSelectTourStop(stopId: stopId)
				}
			}

		} else if let view = view as? MapDepartmentAnnotationView {
			mapView.deselectAnnotation(view.annotation, animated: false)
			self.mapView.zoomIn(onCenterCoordinate: view.annotation!.coordinate,
                                centerCoordinateDistance: Common.Map.ZoomLevelAltitude.zoomDetail.rawValue-10.0,
                                heading: self.mapView.camera.heading)

		} else if let view = view as? MapAmenityAnnotationView {
			// Restaurants
			let annotation = view.annotation as! MapAmenityAnnotation

			// Switch to the floor for this restaurant
			if annotation.type == .Dining {

				// Switch floors
				if currentFloor != annotation.floor {
					setCurrentFloor(forFloorNum: annotation.floor, andResetMap: false)
				}

				mapView.setCenter(annotation.coordinate, animated: true)

				if displayPointOfInterest == .dining {
					if let restaurantId = annotation.nid {
						if let restaurant = AppDataManager.sharedInstance.getRestaurant(forID: restaurantId) {
							delegate?.mapDidSelectRestaurant(restaurant: restaurant)
						}
					}
				}
			}
		}
	}

    /**
     When the map region changes update view properties
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.mapView.calculateCurrentAltitudeAndZoomLevel()

        // Keep map in view
        if !floorSelectorViewController.userHeadingIsEnabled() {
            self.mapView.keepMapInView(zoomLimit: zoomLimitValue)
        }
    }

    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
    }

    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    }

}

// MARK: Floor Selector Delegate Methods
extension MapViewController: MapFloorSelectorViewControllerDelegate {
	func floorSelectorDidSelectFloor(_ floor: Int) {
		setCurrentFloor(forFloorNum: floor)
	}

	func floorSelectorLocationButtonTapped() {
    let locationManager = CLLocationManager()
		if locationManager.authorizationStatus == .denied {
			// Show message to enable location
			//            locationDisabledMessage = MessageSmallView(model: Common.Messages.locationDisabled)
			//            locationDisabledMessage!.delegate = self
			//            self.view.window?.addSubview(locationDisabledMessage!)
		} else if floorSelectorViewController.locationMode == .offsite {
			// Show offsite message
			//            locationOffsiteMessage = MessageSmallView(model: Common.Messages.locationOffsite)
			//            locationOffsiteMessage?.delegate = self
			//            self.view.window?.addSubview(locationOffsiteMessage!)
		} else {
			// Toggle heading
			if floorSelectorViewController.userHeadingIsEnabled() {
				floorSelectorViewController.disableUserHeading()
			} else {
				floorSelectorViewController.enableUserHeading()

				// Log Analytics
				AICAnalytics.sendLocationEnableHeadingEvent()
			}
		}
	}
}

// MARK: - MapObjectAnnotationViewDelegate
extension MapViewController: MapObjectAnnotationViewDelegate {

  func mapObjectAnnotationViewDidPressPlay(_ annotationView: MapObjectAnnotationView) {
    guard let annotation = annotationView.annotation as? MapObjectAnnotation,
          let objectId = annotation.nid,
          let object = AppDataManager.sharedInstance.getObject(forID: objectId) else { return }

    delegate?.mapDidPressArtworkPlayButton(artwork: object)
  }

}

// MARK: - UIGestureRecognizerDelegate
extension MapViewController: UIGestureRecognizerDelegate {
	// Make sure our pinch gesture works with the map's built in zooming
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		true
	}

	@objc func mapViewWasPinched(_ gesture: UIPinchGestureRecognizer) {
		floorSelectorViewController.disableUserHeading()
		self.delegate?.mapWasPressed()
	}

	@objc func mapViewWasPanned(_ gesture: UIPanGestureRecognizer) {
		floorSelectorViewController.disableUserHeading()
		self.delegate?.mapWasPressed()
	}
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else {
			debugPrint("No usable location found")
			return
		}

		// Determine if user is near the museum
		let museumCenterCoordinate = CLLocation(latitude: mapView.floorplanOverlay!.coordinate.latitude, longitude: mapView.floorplanOverlay!.coordinate.longitude)
		let distanceFromCenterOfMuseum = location.distance(from: museumCenterCoordinate)

		if distanceFromCenterOfMuseum < Common.Location.minDistanceFromMuseumForLocation {
			if floorSelectorViewController.userHeadingIsEnabled() {
				mapView.zoomIn(onCenterCoordinate: location.coordinate,
                               centerCoordinateDistance: mapView.camera.centerCoordinateDistance)
			}

			// Update our floor if it is found
			if Common.Testing.useTestFloorLocation {
				currentUserFloor = Common.Testing.testFloorNumber
			} else {
				if let floor = location.floor {
					// Automatically show the floor the user walks into, if in tour mode or exploring all information
					if floor.level != previousUserFloor {
						if displayPointOfInterest == .tour || displayPointOfInterest == .allInformation {
							setCurrentFloor(forFloorNum: floor.level)
						}
					}
					previousUserFloor = currentUserFloor
					currentUserFloor = floor.level
				}
			}

			if let userFloor = currentUserFloor {
				floorSelectorViewController.setUserLocation(forFloorNum: userFloor)

				if currentFloor == userFloor {
					mapView.tintColor = .white
				} else {
					mapView.tintColor = .aicGrayColor
				}
			}

			if !floorSelectorViewController.userLocationIsEnabled() {
				floorSelectorViewController.locationMode = .enabled
			}

			// Log analytics
			// Log onsite location state, only if it hasn't been logged already or if the user moved location out/in the museum
			if Common.Location.hasLoggedOnsite == false || Common.Location.previousOnSiteState == false {
				AICAnalytics.sendLocationDetectedEvent(location: AICAnalytics.LocationState.OnSite)
				Common.Location.hasLoggedOnsite = true
				Common.Location.previousOnSiteState = true
			}

			// Update analytics User Properties
			AICAnalytics.updateUserLocationProperty(isOnSite: true)

		} else {
			floorSelectorViewController.locationMode = .offsite

			// Log analytics
			// Log onsite location state, only if it hasn't been logged already or if the user moved location out/in the museum
			if Common.Location.hasLoggedOnsite == false || Common.Location.previousOnSiteState == true {
				AICAnalytics.sendLocationDetectedEvent(location: AICAnalytics.LocationState.OffSite)
				Common.Location.hasLoggedOnsite = true
				Common.Location.previousOnSiteState = false
			}

			// Update analytics User Properties
			AICAnalytics.updateUserLocationProperty(isOnSite: false)
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		if floorSelectorViewController.userHeadingIsEnabled() {
			// A negative heading value represents an error
			if newHeading.trueHeading >= 0 {
				// Linear interpolation for smoothing
				// from http://stackoverflow.com/questions/2708476/rotation-interpolation
				var start = mapView.camera.heading
				var end = newHeading.trueHeading

				let difference = fabs(end-start)

				if difference > 180 {
					if end > start {
						start += 360
					} else {
						end += 360
					}
				}

				let newHeading = start + ((end-start) * 0.5)

				if newHeading >= 0 && newHeading <= 360 {
					mapView.camera.heading = newHeading
				} else {
					mapView.camera.heading = newHeading.truncatingRemainder(dividingBy: 360)
				}
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.denied {
			floorSelectorViewController.locationMode = .disabled
		}

		// Analytics
		// If location status changes to enabled, log location onsite
		if status != Common.Location.previousAuthorizationStatus {
			if status == .authorizedAlways || status == .authorizedWhenInUse {
				Common.Location.hasLoggedOnsite = false // next time you get the location update, track the onsite or offsite event
			} else if status == .denied {
				AICAnalytics.sendLocationDetectedEvent(location: AICAnalytics.LocationState.Disabled)
				Common.Location.hasLoggedOnsite = true
			}

			Common.Location.previousAuthorizationStatus = status
		}
	}
}

// MARK: - Map floor selector accessors
extension MapViewController {

    func floorSelectorOrientationButtonPosition() -> CGPoint {
        floorSelectorViewController.getOrientationButtonPosition()
    }

    func floorSelectorFloorButtonPosition(at floor: Int) -> CGPoint {
        floorSelectorViewController.getFloorButtonPosition(floorNumber: floor)
    }

}

// MARK: - Private - Setups
private extension MapViewController {

    func addMapGesturesForContinuousUpdates() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(MapViewController.mapViewWasPinched(_:)))
        pinchGesture.delegate = self

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(MapViewController.mapViewWasPanned(_:)))
        panGesture.delegate = self

        mapView.addGestureRecognizer(pinchGesture)
        mapView.addGestureRecognizer(panGesture)
    }

}

// MARK: - Private - Setups
private extension MapViewController {

    func setup() {
        setupSubviews()
        setupDelegates()
        setMapBackgroundOverlay()
        setMapCamerainItialStateforFirstAnimation()
        updateMapForModeChange()
        setupDefaultFloorSelection()
        setupMapUpdateTimer()
        addMapGesturesForContinuousUpdates()
    }

    func setupSubviews() {
        view.addSubview(mapView)
        view.addSubview(floorSelectorViewController.view)
    }

    func setupDelegates() {
        mapView.delegate = self
        floorSelectorViewController.delegate = self
    }

    func setupDefaultFloorSelection() {
        setCurrentFloor(forFloorNum: Common.Map.startFloor)
    }

    func setupMapUpdateTimer() {
        Timer.scheduledTimer(timeInterval: 1.0/20.0,
                             target: self,
                             selector: #selector(MapViewController.updateMapWithTimer),
                             userInfo: nil,
                             repeats: true)
    }

    func setMapBackgroundOverlay() {
        mapView.addOverlay(mapViewHideBackgroundOverlay, level: .aboveRoads)
    }

    /// Set Camera initial state for first animation when you open the map
    func setMapCamerainItialStateforFirstAnimation() {
        mapView.camera.heading = 0
        mapView.camera.centerCoordinateDistance = Common.Map.ZoomLevelAltitude.zoomLimit.rawValue
        mapView.camera.centerCoordinate = mapModel.floors.first!.overlay.coordinate
        mapView.camera.pitch = mapView.perspectivePitch
    }

    func setupNavigationItemTitle() {
        navigationItem.title = Common.Sections[.map]?.title
    }

    func logAnalytics() {
        AICAnalytics.trackScreenView("Map", screenClass: "MapViewController")
    }

}
