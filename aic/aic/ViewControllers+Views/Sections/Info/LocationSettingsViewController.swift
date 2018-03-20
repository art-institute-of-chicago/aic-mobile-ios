//
//  LocationViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import CoreLocation
import Localize_Swift

class LocationSettingsViewController : UIViewController {
	let pageView: InfoPageView = InfoPageView()
	let locationButton: AICButton = AICButton(isSmall: false)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		self.navigationItem.title = "Location Settings"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .white
		
		locationButton.setColorMode(colorMode: AICButton.orangeMode)
		locationButton.setTitle("Location Settings".localized(using: "Sections"), for: .normal)
		locationButton.addTarget(self, action: #selector(locationButtonPressed(button:)), for: .touchUpInside)
		
		self.view.addSubview(pageView)
		self.view.addSubview(locationButton)
		
		// TODO: move this and InfoPageView into InfoPageViewController base class
		let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(recognizer:)))
		swipeRightGesture.direction = .right
		self.view.addGestureRecognizer(swipeRightGesture)
		
		createViewConstraints()
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
		
		// Coming back from Settings
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLanguage()
	}
	
	func createViewConstraints() {
		pageView.autoPinEdge(.top, to: .top, of: self.view)
		pageView.autoPinEdge(.leading, to: .leading, of: self.view)
		pageView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		locationButton.autoPinEdge(.top, to: .bottom, of: pageView)
		locationButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
	}
	
	@objc func updateLanguage() {
		pageView.titleLabel.text = "Location Settings Title".localized(using: "LocationSettings")
		pageView.textView.text = "Location Settings Text".localized(using: "LocationSettings")
		
		if CLLocationManager.locationServicesEnabled() {
			switch(CLLocationManager.authorizationStatus()) {
			case .restricted, .denied:
				locationButton.setTitle("Location Disabled".localized(using: "LocationSettings"), for: .normal)
			case .authorizedAlways, .authorizedWhenInUse:
				locationButton.setTitle("Location Enabled".localized(using: "LocationSettings"), for: .normal)
			case .notDetermined:
				Common.Map.locationManager.delegate = self
				locationButton.setTitle("Location Settings".localized(using: "Sections"), for: .normal)
			}
		}
		else {
			locationButton.setTitle("Location Disabled".localized(using: "LocationSettings"), for: .normal)
		}
	}
	
	@objc func locationButtonPressed(button: UIButton) {
		if CLLocationManager.authorizationStatus() == .notDetermined {
			Common.Map.locationManager.requestWhenInUseAuthorization()
			Common.Map.locationManager.startUpdatingLocation()
			Common.Map.locationManager.startUpdatingHeading()
		}
		else {
			UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
		}
	}
}

extension LocationSettingsViewController : CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		updateLanguage()
	}
}

extension LocationSettingsViewController : UIGestureRecognizerDelegate {
	@objc private func swipeRight(recognizer: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
}
