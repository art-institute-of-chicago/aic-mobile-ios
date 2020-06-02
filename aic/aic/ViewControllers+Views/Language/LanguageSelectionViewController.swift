//
//  LanguageSelectionViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/19/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol LanguageSelectionViewControllerDelegate: class {
	func languageSelected(language: Common.Language)
}

class LanguageSelectionViewController: UIViewController {

	private let blurBGView: UIView = getBlurEffectView(frame: UIScreen.main.bounds)

	private let scrollView = UIScrollView()
	private let titleLabel = UILabel()
	private let dividerLine = UIView()
	private let subtitleLabel = UILabel()
	private let languageStackView = UIStackView()
	private let languageButtons: [AICButton] = {
		Common.Language.allCases.map { (_) in
			AICButton(isSmall: true)
		}
	}()

	let fadeInOutAnimationDuration = 0.4
	let contentViewFadeInOutAnimationDuration = 0.4

	var selectedLanguage: Common.Language = .english

	weak var delegate: LanguageSelectionViewControllerDelegate?

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .clear

		scrollView.backgroundColor = .clear

		titleLabel.font = .aicPageTitleFont
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .white
		titleLabel.textAlignment = .center

		dividerLine.backgroundColor = .aicDividerLineTransparentColor

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

			button.setColorMode(colorMode: AICButton.transparentMode)
			button.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
			languageStackView.addArrangedSubview(button)
		}

		// Add subviews
		view.addSubview(blurBGView)
		view.addSubview(scrollView)
		scrollView.addSubview(titleLabel)
		scrollView.addSubview(dividerLine)
		scrollView.addSubview(subtitleLabel)
		scrollView.addSubview(languageStackView)

		createViewConstraints()
	}

	func createViewConstraints() {
		scrollView.autoPinEdgesToSuperviewEdges()

		titleLabel.autoAlignAxis(.vertical, toSameAxisOf: scrollView)
		titleLabel.autoPinEdge(.leading, to: .leading, of: scrollView, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: scrollView, withOffset: -16)
		titleLabel.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 90 + Common.Layout.safeAreaTopMargin)

		dividerLine.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 30)
		dividerLine.autoPinEdge(.leading, to: .leading, of: scrollView, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: scrollView, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)

		subtitleLabel.autoPinEdge(.top, to: .bottom, of: dividerLine, withOffset: 30)
		subtitleLabel.autoPinEdge(.leading, to: .leading, of: scrollView, withOffset: 40)
		subtitleLabel.autoPinEdge(.trailing, to: .trailing, of: scrollView, withOffset: -40)
		subtitleLabel.autoAlignAxis(.vertical, toSameAxisOf: scrollView)

		languageStackView.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: 64)
		languageStackView.autoAlignAxis(.vertical, toSameAxisOf: scrollView)
		languageStackView.autoPinEdge(.bottom, to: .bottom, of: scrollView, withOffset: -64)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Device language
		if let deviceLanguage = NSLocale.preferredLanguages.first {
			zip(languageButtons, Common.Language.allCases).forEach { (button, language) in
				guard deviceLanguage.hasPrefix(language.prefix) else { return }

				Localize.setCurrentLanguage(language.rawValue)
				button.setColorMode(colorMode: AICButton.greenBlueMode)
			}
		}

		updateLanguage()

		// Fade in
		view.alpha = 0.0
		scrollView.alpha = 0.0
		UIView.animate(withDuration: fadeInOutAnimationDuration, animations: {
			self.view.alpha = 1.0
		}) { (completed) in
			if completed == true {
				UIView.animate(withDuration: self.contentViewFadeInOutAnimationDuration, animations: {
					self.scrollView.alpha = 1.0
				})
			}
		}
	}

	func updateLanguage() {
		titleLabel.text = "language_settings_header".localized(using: "LocalizationUI")

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 6
		let textAttrString = NSMutableAttributedString(string: "language_settings_body".localized(using: "LocalizationUI"))
		textAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: textAttrString.length))

		subtitleLabel.attributedText = textAttrString
		subtitleLabel.font = .aicPageTextFont
		subtitleLabel.numberOfLines = 0
		subtitleLabel.textColor = .white
		subtitleLabel.textAlignment = .center
	}

	@objc func languageButtonPressed(button: UIButton) {
		zip(languageButtons, Common.Language.allCases).forEach { (languageButton, language) in
			languageButton.isEnabled = false

			// If this is the pressed button
			if button == languageButton {
				languageButton.setColorMode(colorMode: AICButton.greenBlueMode)
				Localize.setCurrentLanguage(language.rawValue)
				selectedLanguage = language
			} else {
				languageButton.setColorMode(colorMode: AICButton.transparentMode)
			}
		}

		updateLanguage()

		self.perform(#selector(hideLanguageSelection), with: nil, afterDelay: 1.0)

		// Log analytics
		AICAnalytics.sendLanguageFirstSelectionEvent(language: selectedLanguage)
	}

	@objc func hideLanguageSelection() {
		//staticBlurImageView.removeFromSuperview()
		UIView.animate(withDuration: contentViewFadeInOutAnimationDuration, animations: {
			self.scrollView.alpha = 0.0
		}) { (firstCompleted) in
			if firstCompleted == true {
				UIView.animate(withDuration: self.fadeInOutAnimationDuration, animations: {
					self.view.alpha = 0.0
				}) { (secondCompleted) in
					if secondCompleted == true {
						self.delegate?.languageSelected(language: self.selectedLanguage)
					}
				}
			}
		}
	}
}
