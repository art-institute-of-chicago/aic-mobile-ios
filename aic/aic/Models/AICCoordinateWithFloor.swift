/*
Abstract:
Combined struct of CLLocationCoordinate2D + a floor number
*/
import CoreLocation

struct CoordinateWithFloor {
	let coordinate: CLLocationCoordinate2D
	let floor: Int
}
