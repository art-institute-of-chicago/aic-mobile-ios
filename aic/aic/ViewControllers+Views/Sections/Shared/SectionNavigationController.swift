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
    removeNotificationsObserver()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
    setup()
	}

  override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
    hideNavigationBar()
		updateLanguage()

		// Accessibility
		sectionNavigationBar.titleLabel.becomeFirstResponder()
		UIAccessibility.post(notification: .screenChanged, argument: sectionNavigationBar)
	}

	override func popToRootViewController(animated: Bool) -> [UIViewController]? {
		let rootViewController = super.popToRootViewController(animated: animated)

		sectionNavigationBar.setBackButtonHidden(true)
		updateLanguage()
		return rootViewController
	}

	override func popViewController(animated: Bool) -> UIViewController? {
		let popViewController = super.popViewController(animated: animated)
		updateLanguage()
		return popViewController
	}

	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)
		updateLanguage()
	}

	@objc func updateLanguage() {
		let isRootVC = self.viewControllers.count <= 1

		var titleText = ""

		// In an effort to make minimal changes to the codebase when transitioning to the Twine-based string files
		// the view controller can convey its localization key and title by separating them with a colon
		// e.g. "welcome_title:Base"
		if let titleComponents = topViewController?.navigationItem.title?.components(separatedBy: ":"),
			let localizationKey = titleComponents.first,
			let localizationTable = titleComponents.last {
			titleText = localizationKey.localized(using: localizationTable)
		}
		var subtitleText = ""

		// Set text from CMS for rootViewControllers of audio, map and info sections
		if isRootVC {
			if sectionModel.nid == Section.home.rawValue {
				if let firstName = UserDefaults.standard.object(forKey: Common.UserDefaults.memberFirstNameUserDefaultsKey) as? String {
					titleText = "welcome_title_logged_in".localizedFormat(arguments: firstName, using: "Base")
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
    sectionNavigationBar.descriptionLabel.textAlignment = .center
		sectionNavigationBar.descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: subtitleText,
                                                                                             font: .aicSectionDescriptionFont,
                                                                                             lineHeight: 22)
	}

	@objc private func backButtonPressed(button: UIButton) {
		_ = self.popToRootViewController(animated: true)
	}
}

// MARK: - Private - Setup
private extension SectionNavigationController {

  func setup() {
    // Add Section Navigation Bar and add Back Button target
    self.sectionNavigationBar.backButton.addTarget(self, action: #selector(backButtonPressed(button:)), for: .touchUpInside)
    self.view.addSubview(sectionNavigationBar)

    addLanguageChangeNotification()
  }

  func addLanguageChangeNotification() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(updateLanguage),
                                           name: NSNotification.Name(LCLLanguageChangeNotification),
                                           object: nil)
  }

  func removeNotificationsObserver() {
    NotificationCenter.default.removeObserver(self)
  }

  func hideNavigationBar() {
    navigationBar.isTranslucent = false
    setNavigationBarHidden(true, animated: false)
  }
}
