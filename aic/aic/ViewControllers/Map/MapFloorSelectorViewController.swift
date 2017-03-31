/*
 Abstract:
 Controller for the map floor selector
 */

import UIKit

// MARK: Protocol
protocol MapFloorSelectorViewControllerDelegate: class {
    func floorSelectorDidSelectFloor(_ floor:Int)
    func floorSelectorLocationButtonTapped()
}

class MapFloorSelectorViewController: UIViewController {
    enum LocationMode : String {
        case Disabled = "orientDisabled"
        case Offsite = "orientOffsite"
        case Enabled = "orientInactive"
        case EnabledWithHeading = "orientActive"
    }
    
    weak var delegate:MapFloorSelectorViewControllerDelegate?
    
    private var floorSelectorView:MapFloorSelectorView! = nil
    
    var locationMode:LocationMode = .Disabled {
        didSet {
            updateLocationImageForCurrentMode()
        }
    }
    
    override func loadView() {
        floorSelectorView = MapFloorSelectorView(totalFloors: Common.Map.totalFloors)
        self.view = floorSelectorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add Gestures
        for button in floorSelectorView.floorButtons {
            let buttonTapGesture = UITapGestureRecognizer(target: self, action: #selector(MapFloorSelectorViewController.floorButtonWasTapped(_:)))
            button.addGestureRecognizer(buttonTapGesture)
        }
        
        let locationTapGesture = UITapGestureRecognizer(target: self, action: #selector(MapFloorSelectorViewController.locationButtonWasTapped))
        floorSelectorView.locationButton.addGestureRecognizer(locationTapGesture)
        
        // Load the default location image
        updateLocationImageForCurrentMode()
        
        // Set the default floor
        setSelectedFloor(forFloorNum: Common.Map.startFloor)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Floor selector buttons
    /**
     Set the selected floor and notify delegate
     */
    func setSelectedFloor(forFloorNum floorNum: Int) {
        for floorButton in floorSelectorView.floorButtons {
            floorButton.isSelectedFloor = false
        }
        
        floorSelectorView.floorButtons[floorNum].isSelectedFloor = true
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
        return (locationMode != .Disabled && locationMode != .Offsite)
    }
    
    func userHeadingIsEnabled() -> Bool {
        return locationMode == .EnabledWithHeading
    }
    
    func disableUserHeading() {
        if locationMode == .EnabledWithHeading {
            locationMode = .Enabled
        }
    }
    
    func enableUserHeading() {
        locationMode = .EnabledWithHeading
    }
    
    private func updateLocationImageForCurrentMode() {
        floorSelectorView.locationButton.setImage(UIImage(named:locationMode.rawValue), for: UIControlState())
    }
}

// MARK: Gesture Recognizers
extension MapFloorSelectorViewController {
    func floorButtonWasTapped(_ gesture:UITapGestureRecognizer) {
        if let button = gesture.view {
            delegate?.floorSelectorDidSelectFloor(button.tag)
        }
    }
    
    func locationButtonWasTapped() {
        delegate?.floorSelectorLocationButtonTapped()
    }
}
