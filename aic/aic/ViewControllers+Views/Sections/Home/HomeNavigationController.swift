//
//  HomeSectionNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol HomeNavigationControllerDelegate : class {
	func showMemberCard()
	func showTourCard(tour: AICTourModel)
	func showExhibitionCard(exhibition: AICExhibitionModel)
	func showEventCard(event: AICEventModel)
}

class HomeNavigationController : SectionNavigationController {
	let homeVC: HomeViewController
	
	weak var sectionDelegate: HomeNavigationControllerDelegate? = nil
	
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
	func homeDidSelectAccessMemberCard() {
		self.sectionDelegate?.showMemberCard()
	}
	
	func homeDidSelectSeeAllTours() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)
		
		var content: SeeAllViewController.ContentType = .tours
		if AppDataManager.sharedInstance.shouldUseCategoriesForTours() {
			content = .toursByCategory
		}
		
		let seeAllVC = SeeAllViewController(contentType: content)
		seeAllVC.delegate = self
		self.pushViewController(seeAllVC, animated: true)
	}
	
	func homeDidSelectSeeAllExhibitions() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)
		
		let seeAllVC = SeeAllViewController(contentType: .exhibitions)
		seeAllVC.delegate = self
		self.pushViewController(seeAllVC, animated: true)
	}
	
	func homeDidSelectSeeAllEvents() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)
		
		let seeAllVC = SeeAllViewController(contentType: .events)
		seeAllVC.delegate = self
		self.pushViewController(seeAllVC, animated: true)
	}
	
	func homeDidSelectTour(tour: AICTourModel) {
		self.sectionDelegate?.showTourCard(tour: tour)
	}
	
	func homeDidSelectExhibition(exhibition: AICExhibitionModel) {
		self.sectionDelegate?.showExhibitionCard(exhibition: exhibition)
	}
	
	func homeDidSelectEvent(event: AICEventModel) {
		self.sectionDelegate?.showEventCard(event: event)
	}
}

extension HomeNavigationController : SeeAllViewControllerDelegate {
	func seeAllDidSelectTour(tour: AICTourModel) {
		self.sectionDelegate?.showTourCard(tour: tour)
	}
	
	func seeAllDidSelectExhibition(exhibition: AICExhibitionModel) {
		self.sectionDelegate?.showExhibitionCard(exhibition: exhibition)
	}
	
	func seeAllDidSelectEvent(event: AICEventModel) {
		self.sectionDelegate?.showEventCard(event: event)
	}
}
