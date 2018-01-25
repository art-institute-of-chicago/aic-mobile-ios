//
//  LocationViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class LocationSettingsViewController : UIViewController {
	let pageView: InfoPageView = InfoPageView(title: Common.Info.locationTitle, text: Common.Info.locationText)
	let locationButton: AICButton = AICButton(color: .aicInfoColor, isSmall: false)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		self.navigationItem.title = "Location Settings"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .white
		
		locationButton.setTitle("Location Enabled", for: .normal)
		locationButton.addTarget(self, action: #selector(locationButtonPressed(button:)), for: .touchUpInside)
		
		self.view.addSubview(pageView)
		self.view.addSubview(locationButton)
		
		// TODO: move this and InfoPageView into InfoPageViewController base class
		let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(recognizer:)))
		swipeRightGesture.direction = .right
		self.view.addGestureRecognizer(swipeRightGesture)
		
		createViewConstraints()
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
	}
	
	func createViewConstraints() {
		pageView.autoPinEdge(.top, to: .top, of: self.view)
		pageView.autoPinEdge(.leading, to: .leading, of: self.view)
		pageView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		locationButton.autoPinEdge(.top, to: .bottom, of: pageView)
		locationButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLanguage()
	}
	
	@objc func updateLanguage() {
		pageView.titleLabel.text = "Location Settings Title".localized(using: "LocationSettings")
		pageView.textView.text = "Location Settings Text".localized(using: "LocationSettings")
		
		locationButton.setTitle("Location Enabled".localized(using: "LocationSettings"), for: .normal)
	}
	
	@objc func locationButtonPressed(button: UIButton) {
		// TODO: link to settings page to change location preferences
	}
}

extension LocationSettingsViewController : UIGestureRecognizerDelegate {
	@objc private func swipeRight(recognizer: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
}
