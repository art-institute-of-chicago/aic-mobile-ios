//
//  SectionNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/15/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class SectionNavigationController: UINavigationController {
	let color: UIColor
	let sectionModel: AICSectionModel

	let sectionNavigationBar: SectionNavigationBar

	init(section: AICSectionModel) {
		self.sectionModel = section
		self.color = section.color
		self.sectionNavigationBar = SectionNavigationBar(section: section)
		super.init(nibName: nil, bundle: nil)

		// Set the tab bar item content
		self.tabBarItem = UITabBarItem(title: sectionModel.tabBarTitle, image: sectionModel.tabBarIcon, tag: sectionModel.nid)

		// Hide title and inset (center) images if not showing titles
		if Common.Layout.showTabBarTitles == false {
			self.tabBarItem.title = ""
			self.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
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

		// Accessibility
		sectionNavigationBar.titleLabel.becomeFirstResponder()
		UIAccessibility.post(notification: .screenChanged, argument: sectionNavigationBar)
	}

	override func popToRootViewController(animated: Bool) -> [UIViewController]? {
		let vcs = super.popToRootViewController(animated: animated)

		sectionNavigationBar.setBackButtonHidden(true)
		updateLanguage()

		return vcs
	}

	override func popViewController(animated: Bool) -> UIViewController? {
		let vc: UIViewController? = super.popViewController(animated: animated)

		let isRootVC: Bool = self.viewControllers.count <= 1
		let backButtonHidden = isRootVC
		sectionNavigationBar.setBackButtonHidden(backButtonHidden)
		updateLanguage()

		return vc
	}

	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)

		let isRootVC: Bool = self.viewControllers.count <= 1
		let backButtonHidden = isRootVC
		sectionNavigationBar.setBackButtonHidden(backButtonHidden)

		updateLanguage()
	}

	@objc func updateLanguage() {
		let isRootVC: Bool = self.viewControllers.count <= 1
		var titleText = self.topViewController?.navigationItem.title?.localized(using: "Sections")
		var subtitleText = ""

		// Set text from CMS for rootViewControllers of audio, map and info sections
		if isRootVC {
			if sectionModel.nid == Section.home.rawValue {
				if let firstName = UserDefaults.standard.object(forKey: Common.UserDefaults.memberFirstNameUserDefaultsKey) as? String {
					titleText = "Welcome".localized(using: "Sections") + ", " + firstName
				}
			} else {
				let generalInfo = AppDataManager.sharedInstance.app.generalInfo
				if sectionModel.nid == Section.audioGuide.rawValue {
					titleText = generalInfo.audioTitle
					subtitleText = generalInfo.audioSubtitle
				} else if sectionModel.nid == Section.map.rawValue {
					titleText = generalInfo.mapTitle
					subtitleText = generalInfo.mapSubtitle
				} else if sectionModel.nid == Section.info.rawValue {
					titleText = generalInfo.infoTitle
					subtitleText = generalInfo.infoSubtitle
				}
			}
		}

		sectionNavigationBar.titleLabel.text = titleText
		sectionNavigationBar.descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: subtitleText, font: .aicSectionDescriptionFont, lineHeight: 22)
		sectionNavigationBar.descriptionLabel.textAlignment = NSTextAlignment.center

	}

	@objc private func backButtonPressed(button: UIButton) {
		_ = self.popToRootViewController(animated: true)
	}
}
