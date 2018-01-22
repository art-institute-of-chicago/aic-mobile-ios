//
//  SectionNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/15/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class SectionNavigationController : UINavigationController {
	let color: UIColor
	let sectionModel: AICSectionModel
	
	let sectionNavigationBar: SectionNavigationBar
	
	init(section:AICSectionModel) {
		self.sectionModel = section
		self.color = section.color
		self.sectionNavigationBar = SectionNavigationBar(section: section)
		super.init(nibName: nil, bundle: nil)
		
		// Set the tab bar item content
		self.tabBarItem = UITabBarItem(title: sectionModel.tabBarTitle, image: sectionModel.tabBarIcon, tag: sectionModel.nid)
		
		// Hide title and inset (center) images if not showing titles
		if Common.Layout.showTabBarTitles == false {
			self.tabBarItem.title = ""
			self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
		}
		
		// Set the navigation item content
		self.navigationItem.title = sectionModel.title
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add Section Navigation Bar and add Back Button target
		self.sectionNavigationBar.backButton.addTarget(self, action: #selector(backButtonPressed(button:)), for: .touchUpInside)
		self.view.addSubview(sectionNavigationBar)
		
		// Subscribe to tab bar height changes
		//NotificationCenter.default.addObserver(self, selector: #selector(SectionViewController.tabBarHeightDidChange), name: NSNotification.Name(rawValue: Common.Notifications.tabBarHeightDidChangeNotification), object: nil)
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Hide Navigation Bar
		self.navigationBar.isTranslucent = false
		self.setNavigationBarHidden(true, animated: false)
		
		updateLanguage()
	}
	
	override func popViewController(animated: Bool) -> UIViewController? {
		let vc: UIViewController? = super.popViewController(animated: animated)
		updateLanguage()
		return vc
	}
	
	
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)
		updateLanguage()
	}
	
	@objc func updateLanguage() {
		let backButtonHidden = self.viewControllers.count <= 1
		sectionNavigationBar.setBackButtonHidden(backButtonHidden)
		sectionNavigationBar.titleLabel.text = self.topViewController?.navigationItem.title?.localized(using: "Sections")
		sectionNavigationBar.descriptionLabel.text = sectionModel.description.localized(using: "Sections")
	}
	
	@objc private func backButtonPressed(button: UIButton) {
		self.popViewController(animated: true)
	}
}


