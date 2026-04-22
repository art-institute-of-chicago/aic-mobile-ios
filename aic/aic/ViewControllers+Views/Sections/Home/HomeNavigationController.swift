//
//  HomeSectionNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import Localize_Swift
import UIKit
import SwiftUI

protocol HomeNavigationControllerDelegate: AnyObject {
	func showMemberCard()
	func showTourCard(tour: AICTourModel)
	func showExhibitionCard(exhibition: AICExhibitionModel)
	func showEventCard(event: AICEventModel)
    func showSearch()
    func showExhibitionOnMap(exhibition: AICExhibitionModel)
}

class HomeNavigationController: SectionNavigationController {
	let homeVC: HomeViewController
    let coordinator = HomeNavigationCoordinator()

	weak var sectionDelegate: HomeNavigationControllerDelegate?

	override init(section: AICSectionModel) {
		homeVC = HomeViewController(section: section)
		super.init(section: section)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
        
        coordinator.showExhibitionOnMap = { [weak self] exhibition in
            self?.sectionDelegate?.showExhibitionOnMap(exhibition: exhibition)
        }


        let home = NavigationStack {
            HomeScreen(languageManager: LanguageManager.sharedInstance)
                .toolbar {
                    Button {
                        self.sectionDelegate?.showSearch()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .foregroundStyle(.white)
                }
                .environment(\.locale, LanguageManager.sharedInstance.currentLocale)
                .environmentObject(coordinator)
        }
        let rootVC = UIHostingController(rootView: home)
        
        addChild(rootVC)
        view.addSubview(rootVC.view)
        rootVC.view.autoPinEdgesToSuperviewEdges()
        rootVC.didMove(toParent: self)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Accessibility
		tabBarController!.tabBar.isAccessibilityElement = true
		sectionNavigationBar.titleLabel.becomeFirstResponder()
		self.perform(#selector(accessibilityReEnableTabBar), with: nil, afterDelay: 2.0)
	}

	@objc private func accessibilityReEnableTabBar() {
		tabBarController!.tabBar.isAccessibilityElement = false
	}

	func showHomeTooltip() {
		//See if we need to prompt first
		let defaults = UserDefaults.standard
		let showMapTooltipsMessageValue = defaults.bool(forKey: Common.UserDefaults.showTooltipsDefaultsKey)

		if showMapTooltipsMessageValue {
			homeVC.animateToursScrolling()
		}
	}

	func showSeeAllVC(contentType: SeeAllViewController.ContentType) {
		let seeAllVC = SeeAllViewController(contentType: contentType)
		seeAllVC.delegate = self
		self.pushViewController(seeAllVC, animated: true)
	}
}

extension HomeNavigationController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if viewController == homeVC {
			self.sectionNavigationBar.sectionViewControllerWillAppearWithScrollView(scrollView: homeVC.scrollView)
			self.sectionNavigationBar.setBackButtonHidden(true)
		} else {
			homeVC.scrollDelegate = nil
		}
	}

	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		// set SectionNavigationBar as scrollDelegateon homeVC only after it appears for the first time
		if viewController == homeVC && homeVC.scrollDelegate == nil {
			homeVC.scrollDelegate = sectionNavigationBar
		}

		// Accessibility
		self.accessibilityElements = [
			sectionNavigationBar,
			viewController.view,
			tabBarController?.tabBar
			]
			.compactMap { $0 }
		sectionNavigationBar.titleLabel.becomeFirstResponder()
	}
}

extension HomeNavigationController: HomeViewControllerDelegate {
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

		showSeeAllVC(contentType: content)
	}

	func homeDidSelectSeeAllExhibitions() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)

		showSeeAllVC(contentType: .exhibitions)
	}

	func homeDidSelectSeeAllEvents() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)

		showSeeAllVC(contentType: .events)
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

extension HomeNavigationController: SeeAllViewControllerDelegate {
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
