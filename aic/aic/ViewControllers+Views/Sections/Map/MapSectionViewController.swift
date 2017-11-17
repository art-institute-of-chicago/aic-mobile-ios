//
//  MapSectionViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/13/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import CoreLocation

class MapSectionViewController : UIViewController {
	let mapVC = MapViewController()
	let locationManager: CLLocationManager = CLLocationManager()
	fileprivate var enableLocationMessageView:UIView? = nil
	
	init() {
		super.init(nibName: "", bundle: nil)
		self.view = UIView(frame: UIScreen.main.bounds)
		
		let section: AICSectionModel = Common.Sections[Section.map]!
		self.tabBarItem = UITabBarItem(title: section.tabBarTitle, image: section.tabBarIcon, tag: section.nid)
		
		self.locationManager.delegate = self.mapVC
		//self.mapVC.delegate = self
		self.mapVC.showAllInformation()
		
		self.mapVC.willMove(toParentViewController: self)
		self.view.addSubview(mapVC.view)
		self.mapVC.didMove(toParentViewController: self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		startLocationManager()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.mapVC.setViewableArea(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - Common.Layout.tabBarHeightWithMiniAudioPlayerHeight))
	}
	
	fileprivate func startLocationManager() {
		//See if we need to prompt first
		let defaults = UserDefaults.standard
		let showEnableLocationMessageValue = defaults.bool(forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
		
		// If we do show it
		if showEnableLocationMessageValue {
			showEnableLocationMessage()
		} else {  // Otherwise try to start the location manager
			// Init location manager
			locationManager.requestWhenInUseAuthorization()
			locationManager.startUpdatingLocation()
			locationManager.startUpdatingHeading()
		}
	}
	
	fileprivate func showEnableLocationMessage() {
		let enableLocationView = MessageLargeView(model: Common.Messages.enableLocation)
		enableLocationView.delegate = self
		
		self.enableLocationMessageView = enableLocationView
		view.addSubview(enableLocationView)
	}
	
	fileprivate func hideEnableLocationMessage() {
		if let enableLocationMessageView = self.enableLocationMessageView {
			// Update user defaults
			let defaults = UserDefaults.standard
			defaults.set(false, forKey: Common.UserDefaults.showEnableLocationUserDefaultsKey)
			defaults.synchronize()
			
			enableLocationMessageView.removeFromSuperview()
			self.enableLocationMessageView = nil
		}
	}
}

// MARK: Message Delegate Methods
extension MapSectionViewController : MessageViewDelegate {
	func messageViewActionSelected(_ messageView: UIView) {
		if messageView == enableLocationMessageView {
			hideEnableLocationMessage()
			startLocationManager()
		}
	}
	
	func messageViewCancelSelected(_ messageView: UIView) {
		if messageView == enableLocationMessageView {
			hideEnableLocationMessage()
		}
	}
}

// MARK: Map Delegate Methods
extension MapViewController : MapViewControllerDelegate {
	func mapViewControllerObjectPlayRequested(_ object: AICObjectModel) {
		//showMapObject(forObjectModel: object)
	}
	
	func mapViewControllerDidSelectTourStop(_ stopObject: AICObjectModel) {
		//showTourStop(forStopObjectModel: stopObject)
	}
}
