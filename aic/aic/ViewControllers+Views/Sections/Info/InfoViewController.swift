//
//  InfoViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/17/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol InfoViewControllerDelegate: class {
	func accessMemberCardButtonPressed()
	func museumInfoButtonPressed()
	func languageButtonPressed()
	func locationButtonPressed()
}

class InfoViewController: SectionViewController {
	let scrollView = UIScrollView()
	let whiteBackgroundView = UIView()
	let buyTicketsView = InfoBuyTicketsView()
	let becomeMemberView = InfoBecomeMemberView()
	let museumInfoButton = InfoButton()
	let languageButton = InfoButton()
	let locationButton = InfoButton()
	let footerView = InfoFooterView()

	let footerTopMargin: CGFloat = 15.0

	weak var delegate: InfoViewControllerDelegate?

	override init(section: AICSectionModel) {
		super.init(section: section)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		automaticallyAdjustsScrollViewInsets = false

		if #available(iOS 11.0, *) {
			scrollView.contentInsetAdjustmentBehavior = .never
		}

		scrollView.backgroundColor = .aicInfoColor
		scrollView.showsVerticalScrollIndicator = false
		scrollView.delegate = self

		whiteBackgroundView.backgroundColor = .white

		buyTicketsView.buyButton.addTarget(self, action: #selector(buyTicketsBuyButtonPressed(button:)), for: .touchUpInside)
		becomeMemberView.accessButton.addTarget(self, action: #selector(accessMemberCardButtonPressed(button:)), for: .touchUpInside)

		museumInfoButton.setTitle("Museum Information", for: .normal)
		museumInfoButton.addTarget(self, action: #selector(infoButtonPressed(button:)), for: .touchUpInside)

		languageButton.setTitle("Language Settings", for: .normal)
		languageButton.addTarget(self, action: #selector(infoButtonPressed(button:)), for: .touchUpInside)

		locationButton.setTitle("Location Settings", for: .normal)
		locationButton.addTarget(self, action: #selector(infoButtonPressed(button:)), for: .touchUpInside)

		self.view.addSubview(scrollView)
		scrollView.addSubview(whiteBackgroundView)
		scrollView.addSubview(buyTicketsView)
		scrollView.addSubview(becomeMemberView)
		scrollView.addSubview(museumInfoButton)
		scrollView.addSubview(languageButton)
		scrollView.addSubview(locationButton)
		scrollView.addSubview(footerView)

		createViewConstraints()

		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.view.layoutIfNeeded()
		self.scrollView.contentSize.width = self.view.frame.width
		self.scrollView.contentSize.height = footerView.frame.origin.y + footerView.frame.height

		updateLanguage()

		// Log analytics
		AICAnalytics.trackScreenView("Information", screenClass: "InfoViewController")
	}

	func createViewConstraints() {
		scrollView.autoPinEdge(.top, to: .top, of: self.view)
		scrollView.autoPinEdge(.leading, to: .leading, of: self.view)
		scrollView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		scrollView.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: -Common.Layout.tabBarHeight)

		buyTicketsView.autoPinEdge(.top, to: .top, of: scrollView, withOffset: Common.Layout.navigationBarHeight)
		buyTicketsView.autoPinEdge(.leading, to: .leading, of: self.view)
		buyTicketsView.autoPinEdge(.trailing, to: .trailing, of: self.view)

		becomeMemberView.autoPinEdge(.top, to: .bottom, of: buyTicketsView)
		becomeMemberView.autoPinEdge(.leading, to: .leading, of: self.view)
		becomeMemberView.autoPinEdge(.trailing, to: .trailing, of: self.view)

		museumInfoButton.autoPinEdge(.top, to: .bottom, of: becomeMemberView)
		museumInfoButton.autoPinEdge(.leading, to: .leading, of: self.view)
		museumInfoButton.autoPinEdge(.trailing, to: .trailing, of: self.view)

		languageButton.autoPinEdge(.top, to: .bottom, of: museumInfoButton)
		languageButton.autoPinEdge(.leading, to: .leading, of: self.view)
		languageButton.autoPinEdge(.trailing, to: .trailing, of: self.view)

		locationButton.autoPinEdge(.top, to: .bottom, of: languageButton)
		locationButton.autoPinEdge(.leading, to: .leading, of: self.view)
		locationButton.autoPinEdge(.trailing, to: .trailing, of: self.view)

		footerView.autoPinEdge(.top, to: .bottom, of: locationButton, withOffset: footerTopMargin)
		footerView.autoPinEdge(.leading, to: .leading, of: self.view)
		footerView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		footerView.autoSetDimension(.height, toSize: 250)

		whiteBackgroundView.autoPinEdge(.top, to: .top, of: self.view)
		whiteBackgroundView.autoPinEdge(.leading, to: .leading, of: self.view)
		whiteBackgroundView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		whiteBackgroundView.autoPinEdge(.bottom, to: .top, of: footerView)
	}

	@objc func updateLanguage() {
		becomeMemberView.titleLabel.text = "Member Title".localized(using: "Info")
		becomeMemberView.joinPromptLabel.text = "Member Join Prompt".localized(using: "Info")
		becomeMemberView.joinTextView.text = "Member Join Text".localized(using: "Info")
		becomeMemberView.accessPromptLabel.text = "Member Access Prompt".localized(using: "Info")
		becomeMemberView.accessButton.setTitle("Member Access Button".localized(using: "Info"), for: .normal)

		museumInfoButton.setTitle("Museum Information".localized(using: "Sections"), for: .normal)

		languageButton.setTitle("Language Settings".localized(using: "Sections"), for: .normal)

		locationButton.setTitle("Location Settings".localized(using: "Sections"), for: .normal)

		let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
		let version = nsObject as! String
		footerView.potionCreditsTextView.text = "Version".localized(using: "Info") + " \(version) " + "Designed by".localized(using: "Info") + " Potion"
	}

	@objc func infoButtonPressed(button: UIButton) {
		if button == museumInfoButton {
			self.delegate?.museumInfoButtonPressed()
		} else if button == languageButton {
			self.delegate?.languageButtonPressed()
		} else if button == locationButton {
			self.delegate?.locationButtonPressed()
		}
	}

	@objc func buyTicketsBuyButtonPressed(button: UIButton) {
		if let url = URL(string: AppDataManager.sharedInstance.app.dataSettings[.ticketsUrl]!) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}

	@objc func accessMemberCardButtonPressed(button: UIButton) {
		self.delegate?.accessMemberCardButtonPressed()
	}
}

extension InfoViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.scrollDelegate?.sectionViewControllerDidScroll(scrollView: scrollView)
	}
}
