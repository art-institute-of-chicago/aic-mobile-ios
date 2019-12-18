//
//  MuseumInfoViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift
import CoreLocation

class MuseumInfoViewController: UIViewController {
	let pageView: InfoPageView = InfoPageView()

	init() {
		super.init(nibName: nil, bundle: nil)

		self.navigationItem.title = "Museum Information"
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .white

		pageView.textView.delegate = self
		pageView.textView.dataDetectorTypes = [.address, .phoneNumber]

		self.view.addSubview(pageView)

		let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(recognizer:)))
		swipeRightGesture.direction = .right
		self.view.addGestureRecognizer(swipeRightGesture)

		createViewConstraints()

		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		updateLanguage()

		// Log analytics
		AICAnalytics.trackScreenView("Museum Information", screenClass: "MuseumInfoViewController")
	}

	func createViewConstraints() {
		pageView.autoPinEdge(.top, to: .top, of: self.view)
		pageView.autoPinEdge(.leading, to: .leading, of: self.view)
		pageView.autoPinEdge(.trailing, to: .trailing, of: self.view)
	}

	@objc func updateLanguage() {
		pageView.titleLabel.text = "Museum Information".localized(using: "Sections")

		var text: String = AppDataManager.sharedInstance.app.generalInfo.museumHours
		text += "\n\n" + Common.Info.museumInformationAddress
		text += "\n\n" + Common.Info.museumInformationPhoneNumber
		pageView.textView.text = text
	}
}

extension MuseumInfoViewController: UIGestureRecognizerDelegate {
	@objc private func swipeRight(recognizer: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
}

extension MuseumInfoViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if URL.absoluteString.range(of: "tel:") != nil {
			// Log analytics
			AICAnalytics.sendMiscLinkTappedEvent(link: AICAnalytics.MiscLink.InfoPhone)

			return true
		} else {
			// Log analytics
			AICAnalytics.sendMiscLinkTappedEvent(link: AICAnalytics.MiscLink.InfoAddress)

			openMuseumAddressURL()
		}
		return false
	}

	private func openMuseumAddressURL() {
		// TODO: put this URL in Common
		UIApplication.shared.open(URL(string: "http://maps.apple.com/?q=The%20Art%20Institute%20of%20Chicago")!, options: [:], completionHandler: nil)
	}
}
