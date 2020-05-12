//
//  LanguageSettingsViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class LanguageViewController: UIViewController {
	private let scrollView = UIScrollView()
	private let pageView = InfoPageView()
	private let languageStackView = UIStackView()
	private let languageButtons: [AICButton] = {
		Common.Language.allCases.map { (_) in
			AICButton(isSmall: false)
		}
	}()

	init() {
		super.init(nibName: nil, bundle: nil)

		self.navigationItem.title = "info_language_settings_action:Info"
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

		languageStackView.axis = .vertical
		languageStackView.spacing = 16.0
		languageStackView.alignment = .center

		zip(languageButtons, Common.Language.allCases).forEach { (button, language) in
			switch language {
			case .english:
				button.setTitle("English", for: .normal)
			case .spanish:
				button.setTitle("Español", for: .normal)
			case .chinese:
				button.setTitle("中文", for: .normal)
			case .korean:
				button.setTitle("한국어", for: .normal)
			case .french:
				button.setTitle("Française", for: .normal)
			}

			button.setColorMode(colorMode: AICButton.whiteOrangeMode)
			button.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
			languageStackView.addArrangedSubview(button)
		}

		// Add subviews
		view.addSubview(scrollView)
		scrollView.addSubview(pageView)
		scrollView.addSubview(languageStackView)

		let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(recognizer:)))
		swipeRightGesture.direction = .right
		view.addGestureRecognizer(swipeRightGesture)

		createViewConstraints()

		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		updateLanguage()

		// Log analytics
		AICAnalytics.trackScreenView("Language Settings", screenClass: "LanguageViewController")
	}

	func createViewConstraints() {
		scrollView.autoPinEdgesToSuperviewEdges()

		pageView.autoPinEdge(.top, to: .top, of: scrollView)
		pageView.autoPinEdge(.leading, to: .leading, of: scrollView)
		pageView.autoPinEdge(.trailing, to: .trailing, of: scrollView)
		pageView.autoMatch(.width, to: .width, of: scrollView)

		languageStackView.autoPinEdge(.top, to: .bottom, of: pageView)
		languageStackView.autoAlignAxis(.vertical, toSameAxisOf: scrollView)
		languageStackView.autoPinEdge(.bottom, to: .bottom, of: scrollView, withOffset: -30)
	}

	@objc func updateLanguage() {
		pageView.titleLabel.text = "language_settings_header".localized(using: "LocalizationUI")
		pageView.textView.text = "language_settings_body".localized(using: "LocalizationUI")

		zip(languageButtons, Common.Language.allCases).forEach { (button, language) in
			if Localize.currentLanguage() == language.rawValue {
				button.setColorMode(colorMode: AICButton.orangeMode)
			} else {
				button.setColorMode(colorMode: AICButton.whiteOrangeMode)
			}
		}
	}

	@objc func languageButtonPressed(button: UIButton) {
		zip(languageButtons, Common.Language.allCases).forEach { (languageButton, language) in
			guard languageButton == button else { return }
			Localize.setCurrentLanguage(language.rawValue)
		}

		// Log analytics
		AICAnalytics.updateLanguageSelection(language: Common.currentLanguage)
	}
}

extension LanguageViewController: UIGestureRecognizerDelegate {
	@objc private func swipeRight(recognizer: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
}
