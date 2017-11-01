/*
 Abstract:
 Main ViewController for MapView. Controls map display, overlays,
 annotations and floor selection. Also the entry point for CoreLocation
*/

import UIKit
import MapKit

class _MapViewController : UIViewController {
    enum Mode {
        case Disabled
        case AllInformation
        case NewsLocation
        case Tour
    }
    
    var mode:Mode = .AllInformation {
        didSet {
            //setAnnotationsForCurrentMode()
        }
    }
    
    let locationManager: CLLocationManager = CLLocationManager()
    let mapView:MapView = MapView()
    
    let floorDisplay = UILabel()
    var floorUpdateCount = 0
    
    // Ladnmark Annotations
    var landmarkAnnotations:[MapTextAnnotation] = []
    
    // Object annotations
    var objectAnnotations:[MapObjectAnnotation] = []

    // Floorplans for each floor
    var floors:[MapFloor] = []
    let snapToFloorplan = true
    
    // Floor Selector
    let floorSelectorMargin = CGPointMake(20, 40)
    let floorSelector = MapFloorSelectorViewController(totalFloors: Common.Map.totalFloors)
    
    var visibleMapRegionDelegate:VisibleMapRegionDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = CGRectMake(0,0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        
        // Init location manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Parse SVG File for amenities + landmarks
        let svgUrl =  NSBundle.mainBundle().URLForResource(Common.Map.amenityLandmarkSVGFileName, withExtension: "svg", subdirectory:Common.Map.mapsDirectory)
        let svgParser = MapSVGParser(svgFile: svgUrl!, totalFloors: Common.Map.totalFloors)
        
        // Create landmark annotations
        for landmark in svgParser.landmarks {
            let coord = MKCoordinateForMapPoint(Common.Map.coordinateConverter.MKMapPointFromPDFPoint(landmark.positionInSVG))
            landmarkAnnotations.append(MapTextAnnotation(coordinate:coord, svgLabelText: landmark.text))
        }
        
        // Create Floors
        for i in 0..<Common.Map.totalFloors {
            // Create annotations for the amenities
            var amenityAnnotations:[MapAmenityAnnotation] = []
            for amenity in svgParser.floors[i].amenities {
                let coord = MKCoordinateForMapPoint(Common.Map.coordinateConverter.MKMapPointFromPDFPoint(amenity.positionInSVG))
                amenityAnnotations.append(MapAmenityAnnotation(coordinate: coord, type: amenity.type))
            }
            
            // Create annotations for departments
            var departmentAnnotations:[MapTextAnnotation] = []
            for department in svgParser.floors[i].departments {
                let coord = MKCoordinateForMapPoint(Common.Map.coordinateConverter.MKMapPointFromPDFPoint(department.positionInSVG))
                departmentAnnotations.append(MapTextAnnotation(coordinate:coord, svgLabelText: department.text))
            }
            
            // Create annotations for spaces
            var spaceAnnotations:[MapTextAnnotation] = []
            for space in svgParser.floors[i].spaces {
                let coord = MKCoordinateForMapPoint(Common.Map.coordinateConverter.MKMapPointFromPDFPoint(space.positionInSVG))
                spaceAnnotations.append(MapTextAnnotation(coordinate:coord, svgLabelText: space.text))
            }
            
            // Create annotations for objects
            var objectAnnotations:[MapObjectAnnotation] = []
            for object in AppDataManager.sharedInstance.getObjectsForFloor(i) {
                objectAnnotations.append(MapObjectAnnotation(object: object))
            }
            
            // Load Overlay from PDF
            let pdfUrl = NSBundle.mainBundle().URLForResource(Common.Map.floorplanFileNamePrefix + String(i), withExtension: "pdf", subdirectory:Common.Map.mapsDirectory)!
            let overlay = FloorplanOverlay(floorplanUrl: pdfUrl, withPDFBox: CGPDFBox.TrimBox, andAnchors: Common.Map.anchorPair, forFloorLevel: i)
            
            // Create floor
            let floor = MapFloor(floorNumber: i,
                                 overlay: overlay,
                                 objects:objectAnnotations,
                                 amenities: amenityAnnotations,
                                 departments: departmentAnnotations,
                                 spaces: spaceAnnotations
            )
            
            floors.append(floor)
        }
        
        // Configure Floor Selector
        floorSelector.view.frame.origin = CGPointMake(UIScreen.mainScreen().bounds.width - floorSelector.view.frame.size.width - floorSelectorMargin.x,
                                                      floorSelectorMargin.y)
        
        // Set Delegates
        locationManager.delegate = self
        floorSelector.delegate = self
        mapView.delegate = self
        
        // Create delegate for Map Snapping
        visibleMapRegionDelegate = VisibleMapRegionDelegate(floorplanBounds: floors[0].overlay.boundingMapRectIncludingRotations,
                                                            boundingPDFBox: floors[0].overlay.floorplanPDFBox,
                                                            floorplanCenter: floors[0].overlay.coordinate,
                                                            floorplanUprightMKMapCameraHeading: floors[0].overlay.getFloorplanUprightMKMapCameraHeading()
        )
        
        // Start with the map in frame
        visibleMapRegionDelegate.mapView(mapView, regionDidChangeAnimated:false)
        
        // Show the first floor
        floorSelector.setSelectedFloor(floors[0].floorNumber)
        
        // Add our views
        self.view.addSubview(mapView)
        self.view.addSubview(floorSelector.view)
        floorSelector.view.frame.origin.y = 450
        
//        floorDisplay.text = "TEST"
//        floorDisplay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.25)
//        floorDisplay.textColor = UIColor.whiteColor()
//        floorDisplay.textAlignment = NSTextAlignment.Center
//        floorDisplay.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height/2, UIScreen.mainScreen().bounds.width, 50);
//        self.view.addSubview(floorDisplay)
        
        //setAnnotationsForCurrentMode()
        
        // Add pinch gesture to map
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(MapViewController.mapViewWasPinched(_:)))
        pinchGesture.delegate = self
        mapView.addGestureRecognizer(pinchGesture)
    }
    
    
    // MARK: Public Functions
    
    // Show all the objects, landmarks and amenities on the map
    func showAllInformation() {
        // Set objects for floors
        for floor in floors {
            
        }
    }
    
    // Show a news item (location) on the map
    // Hide everything else
    func showNewsItem(item:AICNewsItemModel) {
        mapView.removeAnnotations(mapView.annotations)
        
        for floor in floors {
            floor.clearActiveAnnotations()
            if floor.floorNumber == item.location.floor {
                let locationAnnotation = MapLocationAnnotation(coordinate: item.location.coordinate, thumbUrl: item.thumbnailUrl)
                floor.locationAnnotations.append(locationAnnotation)
            }
        }
        
        mode = .NewsLocation
        mapView.zoomInOnCoordinate(item.location.coordinate)
        floorSelector.setSelectedFloor(item.location.floor)
    }
    
    // Show all the objects on a tour
    func showTour(tourModel:AICTourModel) {
        for floor in floors {
            floor.clearActiveAnnotations()
            
            // Find the stops for this floor
            let floorStops = tourModel.stops.filter({ $0.object.location.floor == floor.floorNumber })
            
            // Set their objects as active on the map floor
            for stop in floorStops {
                floor.setActiveObjectAnnotation(stop.object)
            }
        }
        
        mode = .Tour
    }
    
    // Show an individual object on a tour
    func showAllStopsOnTour(tourModel:AICTourModel) {
        for floor in floors {
            for annotation in floor.objectAnnotations {
                if let view = mapView.viewForAnnotation(annotation) as? MapObjectAnnotationView {
                    view.hidden = false
                    view.mode = .Minimized
                }
            }
        }
        
        deselectAllAnnotations()
        
        // Fit all annotations in view
        var minLat = 360.0
        var maxLat = -360.0
        var minLong = 360.0
        var maxLong = -360.0
        for stop in tourModel.stops {
            minLat = min(minLat, Double(stop.object.location.coordinate.latitude))
            maxLat = max(maxLat, Double(stop.object.location.coordinate.latitude))
            
            minLong = min(minLong, Double(stop.object.location.coordinate.longitude))
            maxLong = max(maxLong, Double(stop.object.location.coordinate.longitude))
        }
        
        
        let latitude = CLLocationDegrees((maxLat + minLat)/2)
        let longitude = CLLocationDegrees((maxLong + minLong)/2)
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.showFullMap(coord)
    }
    
    // Show an individual tour stop
    func highlightTourStop(stop:AICObjectModel) {
        floorSelector.setSelectedFloor(stop.location.floor)
        deselectAllAnnotations()
        
        for floor in floors {
            for annotation in floor.objectAnnotations {
                if let view = mapView.viewForAnnotation(annotation) as? MapObjectAnnotationView {
                    if annotation.object.nid == stop.nid {
                        view.hidden = false
                        view.mode = .Maximized
                    } else {
                        view.hidden = true
                    }
                }
            }
        }
        
        mapView.zoomInOnCoordinate(stop.location.coordinate)
    }
    
    // Resize the map to the size currently viewable
    func setViewableArea(frame:CGRect) {
        mapView.frame = frame
        floorSelector.view.frame.origin.y = frame.origin.y + frame.height - floorSelector.view.frame.height - floorSelectorMargin.y
    }
    
    // MARK: Private Funcs
    
    // When switching modes we remove all annotations
    // and then add the appropriate annotations for that mode
    private func addAnnotationsForCurrentMode() {
        // Clear all annotations from map
        mapView.removeAnnotations(mapView.annotations)
        
        if mode != .Disabled {
            // Add landmark + gallery information
            mapView.addAnnotations(landmarkAnnotations)
        
            setInformationAnnotationsForCurrentFloor()
        }
    }
    
    // Add the info annotations (amenities, departments and spaces) for the currently selected floor
    private func setInformationAnnotationsForCurrentFloor() {
        // Clear out all floor related annotations
        for floor in floors {
            // Remove amenities, places + departments for previous floor
            mapView.removeAnnotations(floor.amenityAnnotations)
            mapView.removeAnnotations(floor.departmentAnnotations)
            mapView.removeAnnotations(floor.spaceAnnotations)
        }
        
        // Add floor related annotations for current floor
        mapView.addAnnotations(floors[floorSelector.currentFloor].amenityAnnotations)
        mapView.addAnnotations(floors[floorSelector.currentFloor].departmentAnnotations)
        mapView.addAnnotations(floors[floorSelector.currentFloor].spaceAnnotations)
    }
    
    private func setTourItemsForFloor(floorNum:Int) {
        for floor in floors {
            for annotation in floor.objectAnnotations {
                if let view = mapView.viewForAnnotation(annotation) {
                    view.alpha = (floor.floorNumber == floorNum) ? 1.0 : 0.5
                    
                    if let view = view as? MapBaseAnnotationView {
                        view.mode = .Minimized
                    }
                }
            }
        }
    }
    
    private func deselectAllAnnotations() {
        for annotation in mapView.annotations {
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}

// MARK: Gesture Recognizers
extension _MapViewController : UIGestureRecognizerDelegate {
    // Make sure our pinch gesture works with the map's built in zooming
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func mapViewWasPinched(gesture:UIPinchGestureRecognizer) {
        print(mapView.region.span.latitudeDelta)
        
        for landmarkAnnotation in landmarkAnnotations {
            if let view = mapView.viewForAnnotation(landmarkAnnotation) as? MapTextAnnotationView {
                if mapView.region.span.latitudeDelta > 0.005 {
                    view.alpha = 0.1
                } else {
                    view.alpha = 1.0
                }
            }
        }
    }
}

// MARK: - Map View delegate
extension _MapViewController: MKMapViewDelegate {
    // Return Correct MapView Renderer
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay.isKindOfClass(FloorplanOverlay)) {
            let renderer: FloorplanOverlayRenderer = FloorplanOverlayRenderer(overlay: overlay as MKOverlay)
            return renderer
        }
        
        if (overlay.isKindOfClass(HideBackgroundOverlay) == true) {
            let renderer = MKPolygonRenderer(overlay: overlay as MKOverlay)
            
            /*
            HideBackgroundOverlay covers the entire world, so this means all
            of MapKit's tiles will be replaced with a solid white background
            */
            renderer.fillColor = UIColor.aicMapColor()
            //renderer.alpha = 0.25
            
            // No border.
            renderer.lineWidth = 0.0
            renderer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
            
            return renderer
        }
        
        NSException(name:"InvalidMKOverlay", reason:"Did you add an overlay but forget to provide a matching renderer here? The class was type \(overlay.dynamicType)", userInfo:["wasClass": overlay.dynamicType]).raise()
        return MKOverlayRenderer()
    }
    
    /**
     Check for when the MKMapView is zoomed or scrolled in case we need to
     bounce back to the floorplan. If, instead, you're using e.g.
     MKUserTrackingModeFollow then you'll want to disable
     snapMapViewToFloorplan since it will conflict with the user-follow
     scroll/zoom.
     */
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //visibleMapRegionDelegate.mapView(mapView, regionDidChangeAnimated:false)
    }
    
    /**
     This function sets the view when an annotation is added to the map.
     Used to set repeated views (i.e. amenities), and custom views
    */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MapAmenityAnnotation {
            let annotation = annotation as! MapAmenityAnnotation
            var amenityView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotation.type.rawValue)
            if amenityView == nil {
                amenityView = MapAmenityAnnotationView(annotation:annotation, reuseIdentifier: annotation.type.rawValue)
            } else {
                amenityView!.annotation = annotation
                
            }
            
            return amenityView
        }
        
        else if annotation is MapTextAnnotation {
            let annotation = annotation as! MapTextAnnotation
            var landmarkView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotation.labelText)
            if landmarkView == nil {
                landmarkView = MapTextAnnotationView(annotation: annotation, reuseIdentifier: annotation.labelText)
            } else {
                landmarkView!.annotation = annotation
            }
            
            return landmarkView
        }
        
        else if annotation is MapObjectAnnotation {
            let annotation = annotation as! MapObjectAnnotation
            var objectView = mapView.dequeueReusableAnnotationViewWithIdentifier(MapObjectAnnotationView.reuseIdentifier)
            if objectView == nil {
                objectView = MapObjectAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.object.nid))
            } else {
                objectView!.annotation = annotation
            }
            
            return objectView
        }
        
        else if annotation is MapLocationAnnotation {
            let locationView = MapLocationAnnotationView(annotation: annotation, reuseIdentifier: "")
            return locationView
        }
        
        // Leaving in for testing, there should be no point annotations in app
        else if annotation is MKPointAnnotation {
            return MKPinAnnotationView()
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if mode == .Tour {
            self.setTourItemsForFloor(self.floorSelector.currentFloor)
        }
        
        else if mode == .NewsLocation {
            for view in views {
                if let view = view as? MapLocationAnnotationView {
                    view.mode = .Maximized
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let view = view as? MapObjectAnnotationView {
            let annotation = view.annotation as! MapObjectAnnotation
            floorSelector.setSelectedFloor(annotation.object.location.floor)
            view.mode = .Maximized
        }
    }
    
    /**
    Handle presses on Map Object Item Callouts
    */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view is MapObjectAnnotationView {
            let annotation = view.annotation as! MapObjectAnnotation
            
            let wrappedAICObjectModel = Wrapper(theValue: annotation.object)
            NSNotificationCenter.defaultCenter().postNotificationName(Common.Notifications.shouldShowObjectViewNotification, object: nil, userInfo:["object":wrappedAICObjectModel])
        }
    }
}

// MARK: - MapFloorSelectorViewControllerDelegate
extension _MapViewController : MapFloorSelectorViewControllerDelegate {
    /**
     When the floor changes, clear out the current overlay
     and add the appropriate one for that floor
    */
    func didChangeFloors(newFloor: Int, previousFloor: Int) {
        if mode == .AllInformation {
            //showAmenitiesForFloor(newFloor, previousFloor: previousFloor)
        }
        
        else if mode == .Tour {
            setTourItemsForFloor(newFloor)
        }
        
        mapView.removeOverlay(floors[previousFloor].overlay)
        mapView.addOverlay(floors[newFloor].overlay)
    }
}

// MARK: - CLLocationManagerDelegate
extension _MapViewController : CLLocationManagerDelegate {
    // TODO: Control User Location changes
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
//        let floor = location.floor != nil ? locations[0].floor! : "Floor not found"
//        floorDisplay.text = "Floor Update \(floorUpdateCount): \(floor)"
//        floorDisplay.backgroundColor = UIColor.whiteColor()
//        UIView.animateWithDuration(1.0) {
//            self.floorDisplay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.25)
//        }
//        //print("Current floor:\(location.floor)")
//        floorUpdateCount = floorUpdateCount + 1
        
        
    }
    
    // TODO: Figure out treatment here, i.e. if they don't authorize tell them how to change in settings
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            print("Authorized!")
        }
    }
}