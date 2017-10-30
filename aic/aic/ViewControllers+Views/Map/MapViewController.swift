/*
 Abstract:
 Main ViewController for MapView. Controls map display, overlays,
 annotations and floor selection. Also the entry point for CoreLocation
*/

import UIKit
import MapKit

protocol MapViewControllerDelegate : class {
    func mapViewControllerObjectPlayRequested(_ object:AICObjectModel)
    func mapViewControllerDidSelectTourStop(_ stopObject:AICObjectModel)
}

class MapViewController: UIViewController {
    
    enum Mode {
        case disabled
        case allInformation
        case newsLocation
        case tour
    }
    
    var mode:Mode = .disabled {
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
    var color:UIColor = UIColor.aicToursColor() {
        didSet {
            updateColors()
        }
    }
    
    let model = AICMapModel()
    
    // Layout

    // Map View
    let mapView:MapView
    let mapViewBackgroundOverlay = HideBackgroundOverlay.hideBackgroundOverlay()
    
    var tourMapState:MapState? = nil
    var allInformationMapState:MapState? = nil

    // Floor Selector
    let floorSelectorVC = MapFloorSelectorViewController()
    let floorSelectorMargin = CGPoint(x: 20, y: 40)
    
    fileprivate(set) var previousFloor:Int = Common.Map.startFloor
    fileprivate(set) var currentFloor:Int = Common.Map.startFloor
    
    var locationDisabledMessage:MessageSmallView? = nil
    var locationOffsiteMessage:MessageSmallView? = nil
    
    var isSwitchingModes = false
    
    init() {
        self.mapView = MapView(frame: CGRect.zero)
        super.init(nibName: nil, bundle: nil)
        
        // Update teh annotation views every frame
        //let displayLink = CADisplayLink(target: self, selector: #selector(MapViewController.setAnnotationViewPropertiesForCurrentMapAltitude))
        //displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        // Load in floorplans + annoations from app data
        // (app data should be loaded if this function is firing)
        model.loadData()
        
        // Add Subviews
        view.addSubview(mapView)
        view.addSubview(floorSelectorVC.view)
        
        // Set the overlay for the background
        mapView.add(mapViewBackgroundOverlay, level: .aboveRoads)
        
        mapView.camera.heading = mapView.defaultHeading
        mapView.camera.altitude = Common.Map.ZoomLevelAltitude.zoomedOut.rawValue
        mapView.camera.centerCoordinate = model.floors.first!.overlay.coordinate
        
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
        updateMapForModeChange(andStorePreviousMode: .disabled)
        setCurrentFloor(forFloorNum: Common.Map.startFloor)
        
        
        Timer.scheduledTimer(timeInterval: 1.0/20.0,
                                               target: self,
                                               selector: #selector(MapViewController.updateMapWithTimer),
                                               userInfo: nil,
                                               repeats: true)
    }
    
    //Set the color of the background overlay
    func updateColors() {
        // Set the background color
        if let renderer = mapView.renderer(for: mapViewBackgroundOverlay) as? MKPolygonRenderer {
            renderer.fillColor = self.color
        }
    }
    
    // MARK: Mode Functions
    
    // Show all the objects, landmarks and amenities on the map
    // Used when viewing the map by itself in the map (nearby) section
    func showAllInformation() {
        // Switch modes
        mode = .allInformation
        
        if let mapState = allInformationMapState {
            restoreMapState(toState: mapState)
        } else {
            mapView.showFullMap(useDefaultHeading: true)
        }
    }
    
    // Hide floor selector remove all annotations and randomly rotate
    func showDisabled() {
        mode = .disabled
        mapView.setRandomZoomAndHeading(forCenterCoordinate: model.floors[0].overlay.coordinate)
    }
    
    // Show a news item (location) on the map
    // Shows only that item and hides all other floor level info
    func showNews(forNewsItem item:AICNewsItemModel) {
        mode = .newsLocation
        
        // Add location annotation the floor model
        let floor = model.floors[item.location.floor]
        let locationAnnotation = MapLocationAnnotation(coordinate: item.location.coordinate, thumbUrl: item.thumbnailUrl)
        
        floor.locationAnnotations = [locationAnnotation]
        setCurrentFloor(forFloorNum: floor.floorNumber, andResetMap: false)
        
        mapView.addAnnotation(locationAnnotation)
        
        // Zoom in on the item
        mapView.zoomIn(onCenterCoordinate: item.location.coordinate);
    }
    
    // Shows all the objects on a tour, with active/inactive
    // states depending on which floor is selected.
    func showTour(forTour tourModel:AICTourModel, andRestoreState:Bool = false) {
        mode = .tour
        
        // Find the stops for this floor and set them on the model
        var startFloor:Int = 1
        var annotations:[MKAnnotation] = []
        for floor in model.floors {
            let floorStops = tourModel.stops.filter({ $0.object.location.floor == floor.floorNumber })
            if floorStops.count > 0 {
                startFloor = floor.floorNumber
            }
            // Set their objects as active on the map floor
            floor.setTourStopAnnotations(forTourStopModels: floorStops);
            annotations.append(contentsOf: floor.tourStopAnnotations as [MKAnnotation])
        }
        
        setCurrentFloor(forFloorNum: startFloor, andResetMap: false)
        mapView.showAnnotations(annotations, animated: false)
        
        if andRestoreState && tourMapState != nil {
            restoreMapState(toState: tourMapState!)
        } else {
            showTourOverview(forTourModel: tourModel)
        }
        
        
    }
    
    private func updateMapForModeChange(andStorePreviousMode previousMode:Mode) {
        // Save our state
        saveMapState(forMode: previousMode);
        
        // Clear the active annotations from the previous mode
        clearActiveAnnotations()
        
        // Set the new state
        mapView.departmentHud.hide()
        mapView.removeAnnotations(mapView.annotations)
        
        // Show/Hide floor selectore
        let disabled = (mode == .disabled)
        floorSelectorVC.view.isHidden = disabled
        mapView.showsUserLocation = !disabled
        
        isSwitchingModes = true
        
    }
    
    // Go through each floor and clear out it's location + tour objects
    private func clearActiveAnnotations() {
        for floor in model.floors {
            floor.clearActiveAnnotations()
        }
    }
    
    // Take a snapshot for restoring map state when returning to mode
    private func saveMapState(forMode mode:Mode) {
        let selectedAnnotation = mapView.selectedAnnotations.first
        if selectedAnnotation != nil {
            mapView.deselectAnnotation(selectedAnnotation, animated: false)
        }
        
        switch mode {
        case .tour:
            tourMapState = MapState(camera:mapView.camera.copy() as! MKMapCamera, floor: currentFloor, selectedAnnotation: selectedAnnotation)
            
        case .allInformation:
            allInformationMapState = MapState(camera:mapView.camera.copy() as! MKMapCamera, floor: currentFloor, selectedAnnotation: selectedAnnotation)
            print("Save altitude: \(allInformationMapState!.camera.altitude)")
        default:
            return
        }
    }
    
    private func restoreMapState(toState state:MapState) {
        mapView.camera = state.camera
        
        setCurrentFloor(forFloorNum: state.floor)
        
        if let annotation = state.selectedAnnotation {
            mapView.selectAnnotation(annotation, animated: false)
        }
    }
    
    // MARK: Tour Mode functions
    // Functions for manipulating the map while in .Tour mode
    // Show all annotations for the tour in view
    func showTourOverview(forTourModel tourModel:AICTourModel) {
        // Deselect all annotations
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
        
        // Turn off user heading since we want to jump to a specific place
        floorSelectorVC.disableUserHeading()
        
        // Zoom in on the tour's stops
        mapView.showAnnotations(model.floors[currentFloor].tourStopAnnotations, animated: false)
        
        // Show all annotations messes with the pitch + heading,
        // so reset our pitch + heading to preferred defaults
        mapView.camera.heading = mapView.defaultHeading
        mapView.camera.pitch = mapView.defaultPitch
    }
    
    // Highlights a specific tour object
    // Highlights item, switches to it's floor
    // and centers the map around it
    func highlightTourStop(forTour tour:AICTourModel, atStopIndex stopIndex:Int) {
        let stop = tour.stops[stopIndex]
        
        // Select the annotation
        for floor in model.floors {
            for annotation in floor.tourStopAnnotations {
                if annotation.object.nid == stop.object.nid {
                    // Go to that floor
                    setCurrentFloor(forFloorNum: stop.object.location.floor, andResetMap: false)
                    
                    // Select the annotation (which eventually updates it's view)
                    mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
        
        // Turn off user heading since we want to jump to a specific place
        floorSelectorVC.disableUserHeading()
        
        // Zoom in on the item
        mapView.zoomIn(onCenterCoordinate: stop.object.location.coordinate);
    }
    
    // MARK: Viewable Area
    // Sets the viewable area of our map and repositions the floor selector
    func setViewableArea(frame:CGRect) {
        // Set the layout margins to center map in visible area
        let mapInsets = UIEdgeInsetsMake(abs(frame.minY - mapView.frame.minY),
                                         0,
                                         abs(frame.maxY - mapView.frame.maxY),
                                         self.view.frame.width - floorSelectorVC.view.frame.origin.x
        )
        
        mapView.layoutMargins = mapInsets
        
        // Update the floor selector with new position
        let frame = UIEdgeInsetsInsetRect(mapView.frame, mapView.layoutMargins)
        
        let floorSelectorX = UIScreen.main.bounds.width - floorSelectorVC.view.frame.size.width - floorSelectorMargin.x
        var floorSelectorY = frame.origin.y + frame.height - floorSelectorVC.view.frame.height - floorSelectorMargin.y
        
        // Try to bottom align, if that pushes it out of the viewable area, push it down below area
        if floorSelectorY < 0 {
            floorSelectorY = frame.origin.y + 5
        }
        
        floorSelectorVC.view.frame.origin = CGPoint(x: floorSelectorX, y: floorSelectorY)
        mapView.departmentHud.frame.origin = frame.origin
        
        mapView.calculateStartingHeight()
    }
    
    // MARK: Change floor
    
    // Show the current floor's overlay, and change the views
    fileprivate func setCurrentFloor(forFloorNum floorNum:Int, andResetMap:Bool = false) {
        previousFloor = currentFloor
        currentFloor = floorNum
        
        floorSelectorVC.setSelectedFloor(forFloorNum: currentFloor)
        
        // Set the overlay
        mapView.floorplanOverlay = model.floors[floorNum].overlay
        
        // Add annotations
        if mode == .allInformation {
            updateAllInformationAnnotations(isSwitchingFloors: true)
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
        case .disabled:
            mapView.removeAnnotations(mapView.annotations)
            break
            
        case .allInformation:
            updateAllInformationAnnotations(isSwitchingFloors: forceUpdate)
            updateAllInformationAnnotationViews()
            break
            
        case .tour:
            updateTourAnnotationViews()
            break
            
        case .newsLocation:
            updateNewsLocationAnnotationViews()
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
            if mapView.currentZoomLevel == .zoomedDetail && mapView.previousZoomLevel == .zoomedMax ||
                mapView.currentZoomLevel == .zoomedMax && mapView.previousZoomLevel == .zoomedDetail {
                return
            }
        }
        
        if floorSwitch {
            mapView.removeAnnotations(mapView.annotations)
        } else {
            var annotationFilter:[MKAnnotation] = []
            annotationFilter.append(contentsOf: model.lionAnnotations as [MKAnnotation])
            annotationFilter.append(contentsOf: mapView.selectedAnnotations)
            annotationFilter.append(mapView.userLocation)
            
            let allAnnotations = mapView.getAnnotations(filteredBy: annotationFilter);
        
            mapView.removeAnnotationsWithAnimation(annotations: allAnnotations)
        }
        
        // Lions always present
        mapView.addAnnotations(model.lionAnnotations)
        
        // Set the annotations for this zoom level
        switch mapView.currentZoomLevel {
        case .zoomedOut:
            mapView.departmentHud.hide()
            mapView.addAnnotations(model.landmarkAnnotations)
            break
            
        case .zoomedIn:
            mapView.departmentHud.hide()
            mapView.addAnnotations(model.floors[currentFloor].amenityAnnotations)
            mapView.addAnnotations(model.floors[currentFloor].departmentAnnotations)
            break
            
        case .zoomedDetail, .zoomedMax:
            mapView.departmentHud.show()
            mapView.addAnnotations(model.floors[currentFloor].galleryAnnotations)
            mapView.addAnnotations(model.floors[currentFloor].objectAnnotations)
            
            break
        }
    }

    // Highlight object annotations that are in a visible range as the user pans around
    private func updateAllInformationAnnotationViews() {
        if mapView.currentZoomLevel == .zoomedDetail || mapView.currentZoomLevel == .zoomedMax {
            // Update Objects
            //let annotationsInRect = mapView.annotationsInMapRect(mapView.visibleMapRect)
            let centerCoord = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            
            for annotation in model.floors[currentFloor].objectAnnotations {
                //if let annotation = annotation as? MKAnnotation {
                    if let view = mapView.view(for: annotation) as? MapObjectAnnotationView {
                        let distance = centerCoord.distance(from: annotation.location)
                        if distance < 10 {
                            if view.isSelected == false {
                                view.mode = .maximized
                            }
                                
                        } else {
                            view.mode = .minimized
                        }
                    }
                //}
            }
            
            // Set the department in the HUD
            var closestDepartmentDistance = Double.greatestFiniteMagnitude
            var closestDepartment:MapDepartmentAnnotation? = nil
            
            let mapCenterPoint = MKMapPointForCoordinate(mapView.centerCoordinate)
            
            for annotation in model.floors[currentFloor].departmentAnnotations {
                let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                let distance = MKMetersBetweenMapPoints(mapCenterPoint, annotationPoint)
                
                if distance < closestDepartmentDistance {
                    closestDepartmentDistance = distance
                    closestDepartment = annotation
                }
            }
            
            if let department = closestDepartment {
                mapView.departmentHud.setDepartment(department.title!)
            }
        }
    }

    private func updateTourAnnotationViews() {
        for floor in model.floors {
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

    private func updateNewsLocationAnnotationViews() {
        for floor in model.floors {
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
            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: imageAnnotation.imageName) else {
                let view = MKAnnotationView(annotation: imageAnnotation, reuseIdentifier: imageAnnotation.imageName)
                view.image = UIImage(named:imageAnnotation.imageName)
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
            view.color = self.color
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
            if currentFloor != annotation.object.location.floor {
                setCurrentFloor(forFloorNum: annotation.object.location.floor, andResetMap: false)
            }
            
            mapView.setCenter(annotation.coordinate, animated: true)
            
            if mode == .tour {
                delegate?.mapViewControllerDidSelectTourStop(annotation.object)
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
    
}

// MARK: Floor Selector Delegate Methods
extension MapViewController : MapFloorSelectorViewControllerDelegate {
    func floorSelectorDidSelectFloor(_ floor: Int) {
        setCurrentFloor(forFloorNum: floor)
    }
    
    func floorSelectorLocationButtonTapped() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            // Show message to enable location
            locationDisabledMessage = MessageSmallView(model: Common.Messages.locationDisabled)
            locationDisabledMessage!.delegate = self
            
            self.view.window?.addSubview(locationDisabledMessage!)
        }
            
        else if floorSelectorVC.locationMode == .Offsite {
            // Show offsite message
            locationOffsiteMessage = MessageSmallView(model: Common.Messages.locationOffsite)
            locationOffsiteMessage?.delegate = self
            self.view.window?.addSubview(locationOffsiteMessage!)
        }
        
        else {
            // Toggle heading
            if floorSelectorVC.userHeadingIsEnabled() {
                floorSelectorVC.disableUserHeading()
            }
            else {
                floorSelectorVC.enableUserHeading()
                
                // Log Analytics
                AICAnalytics.sendMapDidEnableHeadingEvent()
            }
        }
    }
}

// MARK: Enable location services message delegate
extension MapViewController : MessageViewDelegate {
    func messageViewActionSelected(_ messageView: UIView) {
        // Remove the message
        messageView.removeFromSuperview()
        
        if messageView == locationDisabledMessage {
            // Go to settings
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings)
            }
        }
        
        locationDisabledMessage = nil
        locationOffsiteMessage = nil
    }
    
    func messageViewCancelSelected(_ messageView: UIView) {
        messageView.removeFromSuperview()
    }
}

// MARK: Object Annotation View Delegate Methods
extension MapViewController : MapObjectAnnotationViewDelegate {
    func mapObjectAnnotationViewPlayPressed(_ object: MapObjectAnnotationView) {
        if let annotation = object.annotation as? MapObjectAnnotation {
            delegate?.mapViewControllerObjectPlayRequested(annotation.object)
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
    }
    
    @objc func mapViewWasPanned(_ gesture:UIPanGestureRecognizer) {
        floorSelectorVC.disableUserHeading()
        mapView.keepMapInView()
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
            
            var userFloorNumber:Int? = nil
            
            // Update our floor if it is found
            if Common.Testing.useTestFloorLocation {
                userFloorNumber = Common.Testing.testFloorNumber
            } else {
                if let floor = location.floor {
                    userFloorNumber = floor.level
                }
            }
            
            if let userFloor = userFloorNumber {
                floorSelectorVC.setUserLocation(forFloorNum: userFloor)
                
                if currentFloor == userFloor {
                    mapView.tintColor = UIColor.white
                } else {
                    mapView.tintColor = UIColor.aicGrayColor()
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
