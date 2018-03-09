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
    let topDownPitch:CGFloat = 0.0
	let perspectivePitch:CGFloat = 60.0
    
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
			var centerPoint = Common.Map.defaultLocation
			
			let buildingRect = overlay.boundingMapRect
			let userMapPoint = MKMapPointForCoordinate(userLocation.coordinate)
			let distanceFromBuildingCenter = MKMetersBetweenMapPoints(userMapPoint, buildingRect.getCenter())
			if  distanceFromBuildingCenter < Common.Location.minDistanceFromMuseumForLocation {
				centerPoint = userLocation.coordinate
			}
			
			zoomIn(onCenterCoordinate: centerPoint, altitude: defaultZoom, withAnimation: animated, heading: heading)
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
            newCamera.pitch = topDownPitch
        }
        
        setCamera(newCamera, animated: animated)
    }
	
	func keepMapInView() {
		// Check altitude
		if currentAltitude > Common.Map.ZoomLevelAltitude.zoomLimit.rawValue {
			showFullMap()
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
	
	/// Function to keep same altitude when switching the camera pitch from top-down to perspective
	/// https://stackoverflow.com/questions/6633850/calculate-new-coordinate-x-meters-and-y-degree-away-from-one-coordinate
	func adjustPicthForZoomLevel() {
		if self.currentZoomLevel != self.previousZoomLevel {
			var pitch: CGFloat = topDownPitch
			if currentAltitude < Common.Map.ZoomLevelAltitude.zoomMedium.rawValue {
				pitch = perspectivePitch
			}
			
			if abs(pitch - camera.pitch) > 10 {
				let angle = camera.heading.degreesToRadians
				var lookAtCoordinate = CLLocationCoordinate2D()
				var distanceCamera = currentAltitude
				if pitch == perspectivePitch {
//					lookAtCoordinate.latitude = centerCoordinate.latitude + (cos(angle) * 0.0001)
//					lookAtCoordinate.longitude = centerCoordinate.longitude + (sin(angle) * 0.0001)
//
//					let clCenter = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
//					let clLook = CLLocation(latitude: lookAtCoordinate.latitude, longitude: lookAtCoordinate.longitude)
//					let distanceMeters = clCenter.distance(from: clLook)
//					distanceCamera = sqrt(currentAltitude*currentAltitude + distanceMeters*distanceMeters)
					
					let distanceMeters = currentAltitude * Double(tan(pitch))
					distanceCamera = sqrt((currentAltitude * currentAltitude) + (distanceMeters * distanceMeters))
					let oneMeterRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, 1, 1)
					lookAtCoordinate.latitude = centerCoordinate.latitude + (cos(angle) * (oneMeterRegion.span.latitudeDelta * distanceMeters))
					lookAtCoordinate.longitude = centerCoordinate.longitude + (sin(angle) * (oneMeterRegion.span.longitudeDelta * distanceMeters))
				}
				else {
					lookAtCoordinate.latitude = centerCoordinate.latitude - (cos(angle) * 0.0006)
					lookAtCoordinate.longitude = centerCoordinate.longitude - (sin(angle) * 0.0006)
					distanceCamera = currentAltitude
				}
				let cam = MKMapCamera(lookingAtCenter: lookAtCoordinate, fromDistance: distanceCamera, pitch: pitch, heading: camera.heading)
				setCamera(cam, animated: true)
			}
		}
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
		currentAltitude = camera.altitude
		
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
		
		print("CAMERA ALTITUDE: \(camera.altitude) currentAltitude: \(currentAltitude) previousAltitude: \(previousAltitude)")

    }
}

