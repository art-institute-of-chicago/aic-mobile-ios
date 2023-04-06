/*
Abstract:
Controller for the map floor selector
*/

import UIKit

// MARK: Protocol
protocol MapFloorSelectorViewControllerDelegate: AnyObject {
	func floorSelectorDidSelectFloor(_ floor: Int)
	func floorSelectorLocationButtonTapped()
}

class MapFloorSelectorViewController: UIViewController {
	enum LocationMode: String {
		case disabled = "orientDisabled"
		case offsite = "orientOffsite"
		case enabled = "orientInactive"
		case enabledWithHeading = "orientActive"
	}

	weak var delegate: MapFloorSelectorViewControllerDelegate?
  private lazy var floorSelectorView: MapFloorSelectorView = {
    return MapFloorSelectorView(totalFloors: Common.Map.totalFloors)
  }()

	var locationMode: LocationMode = .disabled {
		didSet {
			updateLocationImageForCurrentMode()
		}
	}

	override func loadView() {
		self.view = floorSelectorView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Add Gestures
		for button in floorSelectorView.floorButtons {
			button.addTarget(self, action: #selector(floorButtonPressed(button:)), for: .touchUpInside)
		}

		floorSelectorView.locationButton.addTarget(self, action: #selector(locationButtonPressed(button:)), for: .touchUpInside)

		// Load the default location image
		updateLocationImageForCurrentMode()

		// Set the default floor
		setSelectedFloor(forFloorNum: Common.Map.startFloor)
	}

	// MARK: Floor selector buttons

	/// Set the selected floor and notify delegate
	func setSelectedFloor(forFloorNum floorNum: Int) {
		for floorButton in floorSelectorView.floorButtons {
			floorButton.isSelectedFloor = false
		}

		floorSelectorView.floorButtons[floorNum].isSelectedFloor = true
	}

	func getCurrentFloorNumber() -> Int {
		for index in 0..<floorSelectorView.floorButtons.count {
			if floorSelectorView.floorButtons[index].isSelectedFloor == true {
				return index
			}
		}

		return 1
	}

	/// get position of current floor for tooltips
	func getFloorButtonPosition(floorNumber: Int) -> CGPoint {
		let pointX = self.view.frame.origin.x

		let floorButton = floorSelectorView.floorButtons[floorNumber]
		let pointY: CGFloat = self.view.frame.origin.y + floorButton.frame.origin.y + CGFloat(MapFloorSelectorView.buttonSize * 0.5)

		return CGPoint(x: pointX, y: pointY)
	}

	/// get position of orientation button for tooltips
	func getOrientationButtonPosition() -> CGPoint {
		let pointX = self.view.frame.origin.x
		let pointY: CGFloat = self.view.frame.origin.y + floorSelectorView.locationButton.frame.origin.y + CGFloat(floorSelectorView.locationButton.frame.height * 0.5)

		return CGPoint(x: pointX, y: pointY)
	}

	// Display the floor the user is currently on
	func setUserLocation(forFloorNum floorNum: Int) {
		clearUserLocationFloors()
		floorSelectorView.floorButtons[floorNum].isUserLocationFloor = true
	}

	// Show all floors as default (not current floor)
	func clearUserLocationFloors() {
		for button in floorSelectorView.floorButtons {
			button.isUserLocationFloor = false
		}
	}

	// MARK: Location Button
	func userLocationIsEnabled() -> Bool {
		return (locationMode != .disabled && locationMode != .offsite)
	}

	func userHeadingIsEnabled() -> Bool {
		return locationMode == .enabledWithHeading
	}

	func disableUserHeading() {
		if locationMode == .enabledWithHeading {
			locationMode = .enabled
		}
	}

	func enableUserHeading() {
		locationMode = .enabledWithHeading
	}

	private func updateLocationImageForCurrentMode() {
		floorSelectorView.locationButton.setImage(UIImage(named: locationMode.rawValue), for: [])
	}
}

// MARK: Gesture Recognizers
extension MapFloorSelectorViewController {
	@objc func floorButtonPressed(button: UIButton) {
		delegate?.floorSelectorDidSelectFloor(button.tag)
	}

	@objc func locationButtonPressed(button: UIButton) {
		delegate?.floorSelectorLocationButtonTapped()
	}
}
