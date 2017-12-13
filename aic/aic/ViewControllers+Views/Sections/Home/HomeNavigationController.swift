//
//  HomeSectionNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class HomeNavigationController : SectionNavigationController {
	let homeVC: HomeViewController
	
	override init(section: AICSectionModel) {
		homeVC = HomeViewController(section: section)
		super.init(section: section)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.delegate = self
		homeVC.delegate = self
		
		self.pushViewController(homeVC, animated: false)
	}
}

extension HomeNavigationController : UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if viewController == homeVC {
			self.sectionNavigationBar.titleLabel.text = homeVC.navigationItem.title
			self.sectionNavigationBar.setBackButtonHidden(true)
		}
	}
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		// set SectionNavigationBar as scrollDelegateon homeVC only after it appears for the first time
		if viewController == homeVC && homeVC.scrollDelegate == nil {
			homeVC.scrollDelegate = sectionNavigationBar
		}
	}
}

extension HomeNavigationController : HomeViewControllerDelegate {
	func showSeeAllTours() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)
		
		let seeAllVC = SeeAllViewController(contentType: .tours)
		seeAllVC.tourItems = AppDataManager.sharedInstance.app.tours
		self.pushViewController(seeAllVC, animated: true)
	}
	
	func showSeeAllExhibitions() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)
		
		let seeAllVC = SeeAllViewController(contentType: .exhibitions)
		seeAllVC.exhibitionItems = AppDataManager.sharedInstance.exhibitions
		self.pushViewController(seeAllVC, animated: true)
	}
	
	func showSeeAllEvents() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)
		
		let seeAllVC = SeeAllViewController(contentType: .events)
		seeAllVC.eventItems = AppDataManager.sharedInstance.events
		self.pushViewController(seeAllVC, animated: true)
	}
}

