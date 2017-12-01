//
//  SectionNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/15/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SectionNavigationController : UINavigationController {
	let color: UIColor
	let sectionModel: AICSectionModel
	
	let sectionNavigationBar: SectionNavigationBar
	
	init(section:AICSectionModel) {
		self.sectionModel = section
		self.color = section.color
		self.sectionNavigationBar = SectionNavigationBar(section: section)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Hide Navigation Bar
		self.navigationBar.isTranslucent = false
		self.setNavigationBarHidden(true, animated: false)
		
		// Add Section Navigation Bar and add Back Button target
		self.sectionNavigationBar.backButton.addTarget(self, action: #selector(backButtonPressed(button:)), for: .touchUpInside)
		self.view.addSubview(sectionNavigationBar)
		
		// Set the tab bar item content
		self.tabBarItem = UITabBarItem(title: sectionModel.tabBarTitle, image: sectionModel.tabBarIcon, tag: sectionModel.nid)
		
		// Set the navigation item content
		self.navigationItem.title = sectionModel.title
		
		// Hide title and inset (center) images if not showing titles
		if Common.Layout.showTabBarTitles == false {
			self.tabBarItem.title = ""
			self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
		}
		
		// Subscribe to tab bar height changes
		NotificationCenter.default.addObserver(self, selector: #selector(SectionViewController.tabBarHeightDidChange), name: NSNotification.Name(rawValue: Common.Notifications.tabBarHeightDidChangeNotification), object: nil)
	}
	
	override func popViewController(animated: Bool) -> UIViewController? {
		let vc: UIViewController? = super.popViewController(animated: animated)
		updateSectionNavigationBar()
		return vc
	}
	
	
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)
		updateSectionNavigationBar()
	}
	
	private func updateSectionNavigationBar() {
		let backButtonHidden = self.viewControllers.count <= 1
		sectionNavigationBar.setBackButtonHidden(backButtonHidden)
		sectionNavigationBar.titleLabel.text = self.topViewController?.navigationItem.title
	}
	
	@objc private func backButtonPressed(button: UIButton) {
		self.popViewController(animated: true)
	}
}


