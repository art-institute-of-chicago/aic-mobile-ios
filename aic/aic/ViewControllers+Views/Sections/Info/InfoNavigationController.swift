//
//  InfoNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/17/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import Localize_Swift
import SwiftUI
import UIKit

class InfoNavigationController: SectionNavigationController {
//	let infoVC: InfoViewController
	let memberCardVC: MemberCardViewController = MemberCardViewController()
	let museumInfoVC: MuseumInfoViewController = MuseumInfoViewController()
	let languageVC: LanguageViewController = LanguageViewController()
	let locationSettingsVC: LocationSettingsViewController = LocationSettingsViewController()

	var shouldShowMemberCard: Bool = false

	override init(section: AICSectionModel) {
//		infoVC = InfoViewController(section: section)
		super.init(section: section)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
//    }

	override func viewDidLoad() {
		super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
//        self.delegate = self
        
        Localize.setCurrentLanguage("en")
        
        let infoScreen = NavigationStack {
            InfoScreen()
                .toolbar {
                    Button {
//                        self.sectionDelegate?.showSearch()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .foregroundStyle(.white)
                }
                .environment(\.locale, Locale(identifier: Localize.currentLanguage()))
        }
        
        let rootVC = UIHostingController(rootView: infoScreen)
        addChild(rootVC)
        view.addSubview(rootVC.view)
        rootVC.view.autoPinEdgesToSuperviewEdges()
        rootVC.didMove(toParent: self)
    }

//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//
//		if shouldShowMemberCard {
//			shouldShowMemberCard = false
//
//			if self.viewControllers.count > 1 {
//				if self.viewControllers.last!.isKind(of: MemberCardViewController.self) == true {
//					self.sectionNavigationBar.setBackButtonHidden(false)
//					return
//				}
//			}
//
//			showMemberCard()
//		}
//
//		// Accessibility
//		tabBarController!.tabBar.isAccessibilityElement = true
//		sectionNavigationBar.titleLabel.becomeFirstResponder()
//		self.perform(#selector(accessibilityReEnableTabBar), with: nil, afterDelay: 2.0)
//	}
    
//    @objc private func appWillEnterForeground() {
//        if shouldShowMemberCard {
//            shouldShowMemberCard = false
//
//            if self.viewControllers.count > 1 {
//                if self.viewControllers.last!.isKind(of: MemberCardViewController.self) == true {
//                    self.sectionNavigationBar.setBackButtonHidden(false)
//                    return
//                }
//            }
//
//            showMemberCard()
//        }
//    }

//	@objc private func accessibilityReEnableTabBar() {
//		tabBarController!.tabBar.isAccessibilityElement = false
//	}

//	func showMemberCard() {
//		self.sectionNavigationBar.collapse()
//		self.sectionNavigationBar.setBackButtonHidden(false)
//		self.sectionNavigationBar.startColorAnimation()
//
//		self.pushViewController(memberCardVC, animated: true)
//	}
}

//extension InfoNavigationController: UINavigationControllerDelegate {
//	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//		if viewController == infoVC {
//			self.sectionNavigationBar.sectionViewControllerWillAppearWithScrollView(scrollView: infoVC.scrollView)
//			self.sectionNavigationBar.setBackButtonHidden(true)
//			self.sectionNavigationBar.stopColorAnimation()
//		} else {
//			infoVC.scrollDelegate = nil
//		}
//	}
//
//	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//		// set SectionNavigationBar as scrollDelegate on infoVC only after it appears for the first time
//		if viewController == infoVC && infoVC.scrollDelegate == nil {
//			infoVC.scrollDelegate = sectionNavigationBar
//		}
//
//		// Accessibility
//		self.accessibilityElements = [
//			sectionNavigationBar,
//			viewController.view,
//			tabBarController?.tabBar
//			]
//			.compactMap { $0 }
//		sectionNavigationBar.titleLabel.becomeFirstResponder()
//	}
//}

//extension InfoNavigationController: InfoViewControllerDelegate {
//	func accessMemberCardButtonPressed() {
//		showMemberCard()
//	}
//
//	func museumInfoButtonPressed() {
//		self.sectionNavigationBar.collapse()
//		self.sectionNavigationBar.setBackButtonHidden(false)
//
//		self.pushViewController(museumInfoVC, animated: true)
//	}
//
//	func languageButtonPressed() {
//		self.sectionNavigationBar.collapse()
//		self.sectionNavigationBar.setBackButtonHidden(false)
//
//		self.pushViewController(languageVC, animated: true)
//	}
//
//	func locationButtonPressed() {
//		self.sectionNavigationBar.collapse()
//		self.sectionNavigationBar.setBackButtonHidden(false)
//
//		self.pushViewController(locationSettingsVC, animated: true)
//	}
//}
