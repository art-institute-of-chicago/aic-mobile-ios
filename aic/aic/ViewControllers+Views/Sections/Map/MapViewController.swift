/*
 Abstract:
 Main ViewController for MapView. Controls map display, overlays,
 annotations and floor selection. Also the entry point for CoreLocation
*/

import UIKit
import MapKit
import Localize_Swift

protocol MapViewControllerDelegate : class {
	func mapWasPressed()
    func mapDidPressArtworkPlayButton(artwork: AICObjectModel)
    func mapDidSelectTourStop(artwork: AICObjectModel)
}

class MapViewController: UIViewController {
    
    enum Mode {
        case allInformation
		case artwork
		case restrooms
		case giftshop
        case location
        case tour
    }
    
    var mode: Mode = .allInformation {
        didSet {
            updateMapForModeChange(andStorePreviousMode: oldValue)
        }
    }
    
    enum AnnotationLevel {
        case building
        case department
        case object
    }
    
    weak var delegate:MapViewControllerDelegate?
    
    // Map + Text Colors
    var color: UIColor = .aicHomeColor {
        didSet {
            updateColors()
        }
    }
    
    let mapModel = AppDataManager.sharedInstance.app.map
    
    // Layout

    // Map View
    let mapView:MapView
    let mapViewHideBackgroundOverlay = HideBackgroundOverlay.hideBackgroundOverlay()

    // Floor Selector
    let floorSelectorVC = MapFloorSelectorViewController()
    let floorSelectorMargin = CGPoint(x: 20, y: 40)
    
    fileprivate (set) var previousFloor: Int = Common.Map.startFloor
    fileprivate (set) var currentFloor: Int = Common.Map.startFloor
	fileprivate (set) var currentUserFloor: Int? = nil
	
	// TODO: move these to SectionsViewController
    var locationDisabledMessage: UIView? = nil
    var locationOffsiteMessage: UIView? = nil
    
    var isSwitchingModes = false
    
    init() {
        self.mapView = MapView(frame: UIScreen.main.bounds)
        super.init(nibName: nil, bundle: nil)
		
		// Navigation Item
		self.navigationItem.title = Common.Sections[.map]!.title
		
        // Update teh annotation views every frame
        //let displayLink = CADisplayLink(target: self, selector: #selector(MapViewController.setAnnotationViewPropertiesForCurrentMapAltitude))
        //displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
		// Add Subviews
        view.addSubview(mapView)
        view.addSubview(floorSelectorVC.view)
        
        // Set the overlay for the background
        mapView.add(mapViewHideBackgroundOverlay, level: .aboveRoads)
		mapView.add(mapModel.backgroundOverlay)
        
        mapView.camera.heading = mapView.defaultHeading
        mapView.camera.altitude = Common.Map.ZoomLevelAltitude.zoomedOut.rawValue
        mapView.camera.centerCoordinate = mapModel.floors.first!.overlay.coordinate
        
        // Set Delegates
        mapView.delegate = self
        floorSelectorVC.delegate = self
        
        // Add Gestures to map for continuous updates
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(MapViewController.mapViewWasPinched(_:)))
        pinchGesture.delegate = self
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(MapViewController.mapViewWasPanned(_:)))
        panGesture.delegate = self
        
        mapView.addGestureRecognizer(pinchGesture)
        mapView.addGestureRecognizer(panGesture)
        
        // Init map
        updateMapForModeChange(andStorePreviousMode: .allInformation)
        setCurrentFloor(forFloorNum: Common.Map.startFloor)
        
        
        Timer.scheduledTimer(timeInterval: 1.0/20.0,
                                               target: self,
                                               selector: #selector(MapViewController.updateMapWithTimer),
                                               userInfo: nil,
                                               repeats: true)
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLanguage()
	}
	
	@objc func updateLanguage() {
		
	}
    
    // Set the color of the background overlay
    func updateColors() {
        // Set the background color
        if let renderer = mapView.renderer(for: mapViewHideBackgroundOverlay) as? MKPolygonRenderer {
            renderer.fillColor = self.color
        }
    }
    
    // MARK: Mode Functions
    
    // Show all the objects, landmarks and amenities on the map
    // Used when viewing the map by itself in the map (nearby) section
    func showAllInformation() {
        // Switch modes
        mode = .allInformation
        
		mapView.showFullMap(useDefaultHeading: true)
    }
    
    // Show a news item (location) on the map
    // Shows only that item and hides all other floor level info
    func showNews(forNewsItem item:AICExhibitionModel) {
        mode = .location
        
        // Add location annotation the floor model
        let floor = mapModel.floors[item.location!.floor]
        let locationAnnotation = MapLocationAnnotation(coordinate: item.location!.coordinate)
        
        floor.locationAnnotations = [locationAnnotation]
        setCurrentFloor(forFloorNum: floor.floorNumber, andResetMap: false)
        
        mapView.addAnnotation(locationAnnotation)
        
        // Zoom in on the item
        mapView.zoomIn(onCenterCoordinate: item.location!.coordinate);
    }
	
	func showArtwork(artwork: AICSearchedArtworkModel) {
		mode = .artwork
		
		// Add location annotation the floor model
		let floor = mapModel.floors[artwork.location.floor]
		let artworkAnnotation = MapObjectAnnotation(searchedArtwork: artwork)
		
		setCurrentFloor(forFloorNum: floor.floorNumber, andResetMap: false)
		
		mapView.addAnnotation(artworkAnnotation)
		
		// Zoom in on the item
		mapView.zoomIn(onCenterCoordinate: artwork.location.coordinate)
		
		// Select the annotation (which eventually updates it's view)
		mapView.selectAnnotation(artworkAnnotation, animated: true)
	}
	
	func showRestrooms() {
		mode = .restrooms
		
		updateRestroomAnnotations()
		
		floorSelectorVC.disableUserHeading()
		
		let currentPitch = mapView.camera.pitch
		
		// Zoom in on the gift shop annotations
		mapView.showAnnotations(mapModel.floors[currentFloor].restroomAnnotations, animated: false)
		
		// Show all annotations messes with the pitch + heading,
		// so reset our pitch + heading to preferred defaults
		mapView.camera.heading = mapView.defaultHeading
		mapView.camera.pitch = currentPitch
	}
	
	func showGiftShop() {
		mode = .giftshop
		
		updateGiftShopAnnotations()
		
		floorSelectorVC.disableUserHeading()
		
		let currentPitch = mapView.camera.pitch
		
		// Zoom in on the gift shop annotations
		mapView.showAnnotations(mapModel.floors[currentFloor].giftShopAnnotations, animated: false)
		
		// Show all annotations messes with the pitch + heading,
		// so reset our pitch + heading to preferred defaults
		mapView.camera.heading = mapView.defaultHeading
		mapView.camera.pitch = currentPitch
	}
	
    // Shows all the objects on a tour, with active/inactive
    // states depending on which floor is selected.
    func showTour(forTour tourModel: AICTourModel) {
        mode = .tour
        
        // Find the stops for this floor and set them on the model
        var annotations: [MKAnnotation] = []
        for floor in mapModel.floors {
            let floorStops = tourModel.stops.filter({ $0.object.location.floor == floor.floorNumber })

            // Set their objects as active on the map floor
            floor.setTourStopAnnotations(forTourStopModels: floorStops)
            annotations.append(contentsOf: floor.tourStopAnnotations as [MKAnnotation])
        }

		let startFloor: Int = tourModel.stops.first!.object.location.floor
        setCurrentFloor(forFloorNum: startFloor, andResetMap: false)

//        mapView.showAnnotations(annotations, animated: false)
//
//        showTourOverview()
		
		mapView.addAnnotations(annotations)
		
		highlightTourStop(tourStop: tourModel.stops.first!)
    }
    
    private func updateMapForModeChange(andStorePreviousMode previousMode:Mode) {
        // Save our state
		if let selectedAnnotation = mapView.selectedAnnotations.first {
			mapView.deselectAnnotation(selectedAnnotation, animated: false)
		}
        
        // Clear the active annotations from the previous mode
        clearActiveAnnotations()
        
        // Set the new state
        mapView.removeAnnotations(mapView.annotations)
        
        isSwitchingModes = true
    }
    
    // Go through each floor and clear out it's location + tour objects
    private func clearActiveAnnotations() {
        for floor in mapModel.floors {
            floor.clearActiveAnnotations()
        }
    }
    
    // MARK: Tour Mode functions
    // Functions for manipulating the map while in .Tour mode
    // Show all annotations for the tour in view
    func showTourOverview() {
        // Deselect all annotations
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
        
        // Turn off user heading since we want to jump to a specific place
        floorSelectorVC.disableUserHeading()
        
        // Zoom in on the tour's stops
        mapView.showAnnotations(mapModel.floors[currentFloor].tourStopAnnotations, animated: false)
        
        // Show all annotations messes with the pitch + heading,
        // so reset our pitch + heading to preferred defaults
        mapView.camera.heading = mapView.defaultHeading
        mapView.camera.pitch = mapView.defaultPitch
    }
    
    // Highlights a specific tour object
    // Highlights item, switches to it's floor
    // and centers the map around it
    func highlightTourStop(tourStop: AICTourStopModel) {
        // Select the annotation
        for floor in mapModel.floors {
            for annotation in floor.tourStopAnnotations {
                if annotation.nid == tourStop.object.nid {
					// Turn off user heading since we want to jump to a specific place
					floorSelectorVC.disableUserHeading()
					
                    // Go to that floor
                    setCurrentFloor(forFloorNum: tourStop.object.location.floor, andResetMap: false)
					
					// Zoom in on the item
//					mapView.zoomIn(onCenterCoordinate: tourStop.object.location.coordinate)
//					mapView.zoomIn(onCenterCoordinate: tourStop.object.location.coordinate, altitude: Common.Map.ZoomLevelAltitude.zoomedDetail.rawValue)
					mapView.zoomIn(onCenterCoordinate: tourStop.object.location.coordinate, altitude: Common.Map.ZoomLevelAltitude.zoomedDetail.rawValue, withAnimation: true, heading: mapView.camera.heading, pitch: 60.0)
                    
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
		let mapInsets = UIEdgeInsetsMake(abs(frame.minY - mapView.frame.minY),
										 0,
										 abs(frame.maxY - mapView.frame.maxY),
										 self.view.frame.width - floorSelectorVC.view.frame.origin.x
		)
		
		mapView.layoutMargins = mapInsets
		
		// Update the floor selector with new position
		let mapFrame = UIEdgeInsetsInsetRect(mapView.frame, mapInsets)
		
		let floorSelectorX = UIScreen.main.bounds.width - floorSelectorVC.view.frame.size.width - floorSelectorMargin.x
		var floorSelectorY = mapFrame.origin.y + mapFrame.height - floorSelectorVC.view.frame.height - floorSelectorMargin.y
		
		// Try to bottom align, if that pushes it out of the viewable area, push it down below area
		if floorSelectorY < 0 {
			floorSelectorY = mapFrame.origin.y + 5
		}
		
		floorSelectorVC.view.frame.origin = CGPoint(x: floorSelectorX, y: floorSelectorY)
		
		mapView.calculateStartingHeight()
    }
    
    // MARK: Change floor
    
    // Show the current floor's overlay, and change the views
    fileprivate func setCurrentFloor(forFloorNum floorNum:Int, andResetMap:Bool = false) {
        previousFloor = currentFloor
        currentFloor = floorNum
        
        floorSelectorVC.setSelectedFloor(forFloorNum: currentFloor)
        
        // Set the overlay
        mapView.floorplanOverlay = mapModel.floors[floorNum].overlay
        
        // Add annotations
        if mode == .allInformation {
            updateAllInformationAnnotations(isSwitchingFloors: true)
        }
		else if mode == .restrooms {
			updateRestroomAnnotations()
		}
		else if mode == .giftshop {
			updateGiftShopAnnotations()
		}
        
        // Snap back to full view
        if andResetMap == true {
            deselectAllAnnotations()
            mapView.showFullMap()
        }
    }
    
    
    
    
    // MARK: Annotations
    // Clears out all of the locations + tour objects
    // currently set for floors
    
    @objc internal func updateMapWithTimer() {
        updateAnnotations()
    }
    
    internal func updateAnnotations(andForceUpdate forceUpdate:Bool = false) {
        if isSwitchingModes {
            return
        }

        mapView.calculateCurrentAltitude()
        
        switch mode {
        case .allInformation:
            updateAllInformationAnnotations(isSwitchingFloors: forceUpdate)
            updateAllInformationAnnotationViews()
			updateUserLocationAnnotationView()
            break
			
        case .tour:
            updateTourAnnotationViews()
			updateUserLocationAnnotationView()
            break
			
		case .artwork:
			updateArtworkAnnotationView()
			updateUserLocationAnnotationView()
			break
			
		case .restrooms:
			updateRestroomAnnotations()
			updateRestroomAnnotationViews()
			updateUserLocationAnnotationView()
			break
			
		case .giftshop:
			updateGiftShopAnnotations()
			updateGiftShopAnnotationViews()
			updateUserLocationAnnotationView()
			break
			
        case .location:
            updateNewsLocationAnnotationViews()
			updateUserLocationAnnotationView()
            break
        }
    }
    
    internal func updateAllInformationAnnotations(isSwitchingFloors floorSwitch:Bool=false) {
        if floorSwitch == false {
            // If we haven't changed zoom levels nothing to do
            if mapView.currentZoomLevel == mapView.previousZoomLevel {
                return
            }
            
            // If we are going between Detail and Max Zoom, stay the same
            if (mapView.currentZoomLevel == .zoomedDetail && mapView.previousZoomLevel == .zoomedMax) ||
                (mapView.currentZoomLevel == .zoomedMax && mapView.previousZoomLevel == .zoomedDetail) {
                return
            }
        }
        
        if floorSwitch {
            mapView.removeAnnotations(mapView.annotations)
        } else {
            var annotationFilter:[MKAnnotation] = []
            annotationFilter.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
            annotationFilter.append(contentsOf: mapView.selectedAnnotations)
            annotationFilter.append(mapView.userLocation)
            
            let allAnnotations = mapView.getAnnotations(filteredBy: annotationFilter)
        
            mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)
        }
        
        // Lions always present
        mapView.addAnnotations(mapModel.imageAnnotations)
        
        // Set the annotations for this zoom level
        switch mapView.currentZoomLevel {
        case .zoomedOut:
            mapView.addAnnotations(mapModel.landmarkAnnotations)
            break
            
        case .zoomedIn:
            mapView.addAnnotations(mapModel.floors[currentFloor].amenityAnnotations)
            mapView.addAnnotations(mapModel.floors[currentFloor].departmentAnnotations)
            break
            
        case .zoomedDetail, .zoomedMax:
            mapView.addAnnotations(mapModel.floors[currentFloor].galleryAnnotations)
            mapView.addAnnotations(mapModel.floors[currentFloor].objectAnnotations)
            
            break
        }
    }

    // Highlight object annotations that are in a visible range as the user pans around
    private func updateAllInformationAnnotationViews() {
        if mapView.currentZoomLevel == .zoomedDetail || mapView.currentZoomLevel == .zoomedMax {
            // Update Objects
            //let annotationsInRect = mapView.annotationsInMapRect(mapView.visibleMapRect)
            let centerCoord = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            
            for annotation in mapModel.floors[currentFloor].objectAnnotations {
//                if let annotation = annotation as? MKAnnotation {
                    if let view = mapView.view(for: annotation) as? MapObjectAnnotationView {
						let distance = centerCoord.distance(from: annotation.clLocation)
                        if distance < 10 {
                            if view.isSelected == false {
                                view.mode = .maximized
                            }
                                
                        } else {
                            view.mode = .minimized
                        }
                    }
//                }
            }
        }
    }

    private func updateTourAnnotationViews() {
        for floor in mapModel.floors {
            for annotation in floor.tourStopAnnotations {
                if let view = mapView.view(for: annotation) as? MapObjectAnnotationView {
                    if floor.floorNumber == currentFloor {
                        view.mode = .maximized
                        view.alpha = 1.0
                    }
                    else {
                        view.mode = .maximized
                        view.alpha = 0.5
                    }
                }
            }
        }
    }
	
	private func updateArtworkAnnotationView() {
		for floor in mapModel.floors {
			for annotation in floor.objectAnnotations {
				if let view = mapView.view(for: annotation) as? MapObjectAnnotationView {
					if floor.floorNumber == currentFloor {
						view.alpha = 1.0
					} else {
						view.alpha = 0.5
					}
				}
			}
		}
	}
	
	private func updateRestroomAnnotations() {
		let floor = mapModel.floors[currentFloor]
		
		var annotationFilter:[MKAnnotation] = []
		annotationFilter.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotationFilter.append(contentsOf: floor.restroomAnnotations as [MKAnnotation])
		annotationFilter.append(mapView.userLocation)
		let allAnnotations = mapView.getAnnotations(filteredBy: annotationFilter)
		
		mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)
		
		var annotations: [MKAnnotation] = []
		annotations.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotations.append(contentsOf: floor.restroomAnnotations as [MKAnnotation])
		annotations.append(mapView.userLocation)
		
		mapView.addAnnotations(annotations)
	}
	
	private func updateRestroomAnnotationViews() {
		for floor in mapModel.floors {
			for annotation in floor.restroomAnnotations {
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
	
	private func updateGiftShopAnnotations() {
		let floor = mapModel.floors[currentFloor]
		
		var annotationFilter:[MKAnnotation] = []
		annotationFilter.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotationFilter.append(contentsOf: floor.giftShopAnnotations as [MKAnnotation])
		annotationFilter.append(mapView.userLocation)
		let allAnnotations = mapView.getAnnotations(filteredBy: annotationFilter)
		
		mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)
		
		var annotations: [MKAnnotation] = []
		annotations.append(contentsOf: mapModel.imageAnnotations as [MKAnnotation])
		annotations.append(contentsOf: floor.giftShopAnnotations as [MKAnnotation])
		annotations.append(mapView.userLocation)
		
		mapView.addAnnotations(annotations)
	}
	
	private func updateGiftShopAnnotationViews() {
		for floor in mapModel.floors {
			for annotation in floor.giftShopAnnotations {
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

    private func updateNewsLocationAnnotationViews() {
        for floor in mapModel.floors {
            for annotation in floor.locationAnnotations {
                if let view = mapView.view(for: annotation) as? MapLocationAnnotationView {
                    if floor.floorNumber == currentFloor {
                        view.alpha = 1.0
                    } else {
                        view.alpha = 0.5
                    }
                }
            }
        }
    }
	
	private func updateUserLocationAnnotationView() {
		if let locationView = mapView.view(for: mapView.userLocation) {
			if currentUserFloor == currentFloor {
				locationView.alpha = 1.0
			}
			else {
				locationView.alpha = 0.5
			}
		}
	}
    
    // Deselect any open annotations
    private func deselectAllAnnotations() {
        for annotation in mapView.annotations {
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}

// MARK: Map View Delegate Methods
extension MapViewController : MKMapViewDelegate {
    /**
     This renders the map with a background overlay
     and the overlay for the current floorplan
    */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Floorplan Overlay
        if (overlay.isKind(of: FloorplanOverlay.self)) {
            let renderer: FloorplanOverlayRenderer = FloorplanOverlayRenderer(overlay: overlay as MKOverlay)
            return renderer
        }
        
        // Hide Background Overlay
        if (overlay.isKind(of: HideBackgroundOverlay.self) == true) {
            let renderer = MKPolygonRenderer(overlay: overlay as MKOverlay)
            
            renderer.fillColor = self.color
            
            // No border
            renderer.lineWidth = 0.0
            renderer.strokeColor = UIColor.white.withAlphaComponent(0.0)
            
            return renderer
        }
        
        NSException(name:NSExceptionName(rawValue: "InvalidMKOverlay"), reason:"Did you add an overlay but forget to provide a matching renderer here? The class was type \(type(of: overlay))", userInfo:["wasClass": type(of: overlay)]).raise()
        return MKOverlayRenderer()
    }
    
    /**
     This function sets the view when an annotation is added to the map.
     It tries to re-use existing views where available
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Department Annotations
        if let departmentAnnotation = annotation as? MapDepartmentAnnotation {
            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: MapDepartmentAnnotationView.reuseIdentifier) as? MapDepartmentAnnotationView else {
                let view = MapDepartmentAnnotationView(annotation:departmentAnnotation, reuseIdentifier: MapDepartmentAnnotationView.reuseIdentifier)
                return view
            }
            
            view.setAnnotation(forDepartmentAnnotation: departmentAnnotation);
            return view
        }
        
        // Image Annotations
        if let imageAnnotation = annotation as? MapImageAnnotation {
            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: imageAnnotation.identifier) else {
                let view = MKAnnotationView(annotation: imageAnnotation, reuseIdentifier: imageAnnotation.identifier)
                view.image = imageAnnotation.image
                return view
            }
            
            return view
            
        }
        
        // Amenity annotation
        if let amenityAnnotation = annotation as? MapAmenityAnnotation {
            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: amenityAnnotation.type.rawValue) as? MapAmenityAnnotationView else {
                let view = MapAmenityAnnotationView(annotation: amenityAnnotation, reuseIdentifier: amenityAnnotation.type.rawValue, color:self.color)
                return view
            }
            
            view.annotation = amenityAnnotation
            return view
        }
        
        // Text annotations
        if let textAnnotation = annotation as? MapTextAnnotation {
            
            var view:MapTextAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: textAnnotation.type.rawValue) as? MapTextAnnotationView
            if view == nil {
                view = MapTextAnnotationView(annotation: textAnnotation, reuseIdentifier: textAnnotation.type.rawValue)
            }
            
            // Update the view
            view.setAnnotation(forMapTextAnnotation: textAnnotation);
            view.setTextColor(self.color)
            
            return view
        }
        
        // Object annotations
        if let objectAnnotation = annotation as? MapObjectAnnotation {
            //let objectIdentifier = String(objectAnnotation.object.nid)
            let objectIdentifier = String(MapObjectAnnotationView.reuseIdentifier)
            
            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: objectIdentifier) as? MapObjectAnnotationView else {
                let view = MapObjectAnnotationView(annotation: objectAnnotation, reuseIdentifier: objectIdentifier)
                view.delegate = self
                return view
            }

            view.setAnnotation(forObjectAnnotation: objectAnnotation);
            return view
        }
        
        // Location (News Item) annotations
        if let locationAnnotation = annotation as? MapLocationAnnotation {
            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: MapLocationAnnotationView.reuseIdentifier) as? MapLocationAnnotationView else {
                let view = MapLocationAnnotationView(annotation: annotation, reuseIdentifier: MapLocationAnnotationView.reuseIdentifier)
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
            
            if mode == .tour {
				if let objectId = annotation.nid {
					if let object = AppDataManager.sharedInstance.getObject(forID: objectId) {
						delegate?.mapDidSelectTourStop(artwork: object)
					}
				}
            }
        }
        
        else if let view = view as? MapDepartmentAnnotationView {
            mapView.deselectAnnotation(view.annotation, animated: false)
            self.mapView.zoomIn(onCenterCoordinate: view.annotation!.coordinate);
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if mode == .allInformation && view.isKind(of: MapObjectAnnotationView.self) {
            if self.mapView.currentZoomLevel != .zoomedMax && self.mapView.currentZoomLevel != .zoomedDetail {
                self.mapView.removeAnnotationsWithAnimation(annotations: [view.annotation!])
            }
        }
    }
    
    /**
     When the map region changes update view properties
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.mapView.calculateStartingHeight()
        
        // Store the location mode
        if !floorSelectorVC.userHeadingIsEnabled() {
           self.mapView.keepMapInView()
        }
        
        if isSwitchingModes {
            isSwitchingModes = false
            updateAnnotations(andForceUpdate: true) // Force annotation update
        }
    }
	
	func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
		
	}
}

// MARK: Floor Selector Delegate Methods
extension MapViewController : MapFloorSelectorViewControllerDelegate {
    func floorSelectorDidSelectFloor(_ floor: Int) {
        setCurrentFloor(forFloorNum: floor)
    }
    
    func floorSelectorLocationButtonTapped() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            // Show message to enable location
//            locationDisabledMessage = MessageSmallView(model: Common.Messages.locationDisabled)
//            locationDisabledMessage!.delegate = self
//
//            self.view.window?.addSubview(locationDisabledMessage!)
        }
        else if floorSelectorVC.locationMode == .Offsite {
            // Show offsite message
//            locationOffsiteMessage = MessageSmallView(model: Common.Messages.locationOffsite)
//            locationOffsiteMessage?.delegate = self
//            self.view.window?.addSubview(locationOffsiteMessage!)
        }
        else {
            // Toggle heading
            if floorSelectorVC.userHeadingIsEnabled() {
                floorSelectorVC.disableUserHeading()
            }
            else {
                floorSelectorVC.enableUserHeading()
                
                // Log Analytics
//                AICAnalytics.sendMapDidEnableHeadingEvent()
            }
        }
    }
}

// MARK: Enable location services message delegate
extension MapViewController : MessageViewControllerDelegate {
    func messageViewActionSelected(messageVC: MessageViewController) {
        // Remove the message
        messageVC.dismiss(animated: true, completion: nil)
        
        if messageVC.view == locationDisabledMessage {
            // Go to settings
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        
        locationDisabledMessage = nil
        locationOffsiteMessage = nil
    }
    
    func messageViewCancelSelected(messageVC: MessageViewController) {
        messageVC.dismiss(animated: true, completion: nil)
    }
}

// MARK: Object Annotation View Delegate Methods
extension MapViewController : MapObjectAnnotationViewDelegate {
    func mapObjectAnnotationViewPlayPressed(_ annotationView: MapObjectAnnotationView) {
        if let annotation = annotationView.annotation as? MapObjectAnnotation {
			if let objectId = annotation.nid {
				if let object = AppDataManager.sharedInstance.getObject(forID: objectId) {
					delegate?.mapDidPressArtworkPlayButton(artwork: object)
				}
			}
        }
    }
}

// MARK: Gesture recognizer delegate
extension MapViewController : UIGestureRecognizerDelegate {
    // Make sure our pinch gesture works with the map's built in zooming
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func mapViewWasPinched(_ gesture:UIPinchGestureRecognizer) {
        floorSelectorVC.disableUserHeading()
		self.delegate?.mapWasPressed()
    }
    
    @objc func mapViewWasPanned(_ gesture:UIPanGestureRecognizer) {
        floorSelectorVC.disableUserHeading()
        mapView.keepMapInView()
		self.delegate?.mapWasPressed()
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("No useable location found")
            return
        }
        
        // Determine if user is near the museum
        let museumCenterCoordinate = CLLocation(latitude: mapView.floorplanOverlay!.coordinate.latitude, longitude: mapView.floorplanOverlay!.coordinate.longitude)
        let distanceFromCenterOfMuseum = location.distance(from: museumCenterCoordinate)
        
        if distanceFromCenterOfMuseum < Common.Location.minDistanceFromMuseumForLocation {
            if floorSelectorVC.userHeadingIsEnabled() {
                mapView.zoomIn(onCenterCoordinate: location.coordinate, altitude: mapView.camera.altitude)
            }
            
            // Update our floor if it is found
            if Common.Testing.useTestFloorLocation {
                currentUserFloor = Common.Testing.testFloorNumber
            } else {
                if let floor = location.floor {
                    currentUserFloor = floor.level
                }
            }
            
            if let userFloor = currentUserFloor {
                floorSelectorVC.setUserLocation(forFloorNum: userFloor)
                
                if currentFloor == userFloor {
                    mapView.tintColor = .white
                } else {
                    mapView.tintColor = .aicGrayColor
                }
            }
            
            if !floorSelectorVC.userLocationIsEnabled() {
                floorSelectorVC.locationMode = .Enabled
                
                // Log analytics
                AICAnalytics.sendMapUserOnSiteEvent()
            }
        } else {
            floorSelectorVC.locationMode = .Offsite
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if floorSelectorVC.userHeadingIsEnabled() {
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
                    }
                    else {
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
            floorSelectorVC.locationMode = .Disabled
        }
    }
}
