/*
 Abstract:
 This is a custom implementation of MKMapView that includes some basic setup
 and implements a function to get the zoom level
 
 Map Altitude continuous value code reinterpreted from:
 http://yuluer.com/page/bjfhcdhh-how-to-show-map-scale-during-zoom-of-mkmapview-like-apples-maps-app.shtml
*/

import MapKit

class MapView: MKMapView {
    enum ZoomDirection {
        case `in`
        case out
        case none
    }
    
    var floorplanOverlay: FloorplanOverlay? = nil {
        didSet {
            if let previousOverlay = oldValue {
                remove(previousOverlay)
            }
            
            if floorplanOverlay != nil {
                add(floorplanOverlay!)
            }
        }
    }
    
    // Used to calculate the map's altitude at any point
    // for fading annotations in out during pinching
    private var startingHeight:Double = 0.0
    
    // Rotate the map so that the Michigan Ave entrance faces south
    let defaultHeading = 90.0
	let defaultZoom = 400.0
    let defaultPitch:CGFloat = 0.0
    
    private (set) var previousAltitude:Double = 0.0
    private (set) var currentAltitude:Double = 0.0
    
    private (set) var previousZoomLevel:Common.Map.ZoomLevelAltitude = .zoomLimit
    private (set) var currentZoomLevel:Common.Map.ZoomLevelAltitude = .zoomLimit
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        mapType = .standard
        userTrackingMode = .none
        
        isScrollEnabled = true
        isZoomEnabled = true
        isPitchEnabled = true
        
        if #available(iOS 9.0, *) {
            showsCompass = false
            showsScale = false
            showsTraffic = false
        }
        
        if #available(iOS 11.0, *) {
            mapType = .mutedStandard
        }
        
        showsBuildings = false
        showsPointsOfInterest = false
        showsUserLocation = true
        
        tintColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateStartingHeight()
    }
    
    func getAnnotations(filteredBy annotationsToFilterOut:[MKAnnotation]) -> [MKAnnotation] {
        return annotations.filter({
            let thisAnnotation = $0
            return annotationsToFilterOut.index(where: {$0 === thisAnnotation}) == nil
        })
    }
    
    // Fade out annotations before removing them
    func removeAnnotationsWithAnimation(annotations: [MKAnnotation]) {
        for annotation in annotations {
            if let view = view(for: annotation) {
                UIView.animate(withDuration: 0.25, animations: {
                    view.alpha = 0.0
                    }, completion: {(value:Bool) in
                        self.removeAnnotation(annotation)
                })
            } else {
                removeAnnotation(annotation)
            }
        }
    }
    
//    func setRandomZoomAndHeading(forCenterCoordinate centerCoordinate:CLLocationCoordinate2D, duration:Double=0.5) {
//        let ran = Double(arc4random())/Double(UINT32_MAX)
//        let randomHeading = map(val: ran, oldRange1: 0.0, oldRange2: 1.0, newRange1: -45.0, newRange2: 45.0)
//        
//        let randomAltitude = map(val: Double(arc4random())/Double(UINT32_MAX),
//                                  oldRange1: 0,
//                                  oldRange2: 1,
//                                  newRange1: Common.Map.ZoomLevelAltitude.zoomedIn.rawValue + 1.0,
//                                  newRange2: Common.Map.ZoomLevelAltitude.zoomedOut.rawValue/2.0
//        )
//        
//        zoomIn(onCenterCoordinate: centerCoordinate, altitude: randomAltitude, heading: randomHeading)
//    }

    func zoomIn(onCenterCoordinate centerCoordinate:CLLocationCoordinate2D) {
        zoomIn(onCenterCoordinate: centerCoordinate, altitude: Common.Map.ZoomLevelAltitude.zoomDefault.rawValue, heading: camera.heading)
    }
    
    func showFullMap(useDefaultHeading: Bool = false, animated: Bool = true) {
        if let overlay = floorplanOverlay {
            let heading = useDefaultHeading ? defaultHeading : camera.heading
			var centerPoint = overlay.coordinate
			
			let buildingRect = overlay.boundingMapRect
			let userMapPoint = MKMapPointForCoordinate(userLocation.coordinate)
			let distanceFromBuildingCenter = MKMetersBetweenMapPoints(userMapPoint, buildingRect.getCenter())
			if  distanceFromBuildingCenter < Common.Location.minDistanceFromMuseumForLocation {
				centerPoint = userLocation.coordinate
			}
			
			zoomIn(onCenterCoordinate: centerPoint, altitude: camera.altitude, withAnimation: animated, heading: heading)
			
        }
    }
    
    func keepMapInView() {
        // Check altitude
        if camera.altitude > Common.Map.ZoomLevelAltitude.zoomLimit.rawValue {
			if let overlay = floorplanOverlay {
				let heading = defaultHeading// camera.heading
				zoomIn(onCenterCoordinate: overlay.coordinate, altitude: Common.Map.ZoomLevelAltitude.zoomDefault.rawValue, withAnimation: true, heading: heading)
			}
        } else {
            // Make sure our floorplan is on-screen
            if let floorplanOverlay = floorplanOverlay {
                let buildingRect = floorplanOverlay.boundingMapRect
                let cameraCenter = MKMapPointForCoordinate(camera.centerCoordinate)
                let distanceFromBuildingCenter = MKMetersBetweenMapPoints(cameraCenter, buildingRect.getCenter())
                
                if  distanceFromBuildingCenter > Common.Location.minDistanceFromMuseumForLocation {
                    zoomIn(onCenterCoordinate: floorplanOverlay.coordinate, altitude: camera.altitude, heading: nil, pitch: camera.pitch)
                }
            }
        }
    }
	
	func adjustPicthForZoomLevel() {
		if self.currentZoomLevel != self.previousZoomLevel && camera.pitch != 60.0 {
			var pitch: CGFloat = 0.0
//			var altitude: Double = camera.altitude
			if self.camera.altitude <= Common.Map.ZoomLevelAltitude.zoomDefault.rawValue {
				pitch = 60.0
//				if altitude > Common.Map.ZoomLevelAltitude.zoomMedium.rawValue - 50 &&
//					altitude < Common.Map.ZoomLevelAltitude.zoomMedium.rawValue {
//					altitude = altitude - 80.0
//				}
			}
			zoomIn(onCenterCoordinate: camera.centerCoordinate, altitude: camera.altitude, withAnimation: true, heading: camera.heading, pitch: pitch)
		}
	}
    
    func zoomIn(onCenterCoordinate centerCoordinate: CLLocationCoordinate2D, altitude: Double, withAnimation animated: Bool = true, heading: Double? = nil, pitch: CGFloat? = nil) {
		//let newCamera = MKMapCamera(lookingAtCenterCoordinate: centerCoordinate, fromEyeCoordinate: centerCoordinate, eyeAltitude: altitude)
        let newCamera = camera.copy() as! MKMapCamera
        newCamera.centerCoordinate = centerCoordinate
        newCamera.altitude = altitude
        
        if let _ = heading {
            newCamera.heading = heading!
        }
        
        if let _ = pitch {
            newCamera.pitch = pitch!
        } else {
            newCamera.pitch = defaultPitch
        }
        
        setCamera(newCamera, animated: animated)
    }
    
    // Find the altitude based on our start value and the current map visible to bounds ratio
    func calculateStartingHeight() {
        // Set the starting height for checking altitude while zooming
        let currentZoomScale = Double(bounds.size.width) / visibleMapRect.size.width
        let factor = 1.0 / currentZoomScale
        
        startingHeight = camera.altitude/factor;
    }
    
    func calculateCurrentAltitude() {
        // Altitude
        previousAltitude = currentAltitude
		
		// TODO: I do not understand this, investigate
        let zoomScale = Double(bounds.size.width) / visibleMapRect.size.width
        currentAltitude = startingHeight * (1 / zoomScale)
        
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
    }
}
