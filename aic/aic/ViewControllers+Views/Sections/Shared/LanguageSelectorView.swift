//
//  LanguageSelectorView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/8/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import Localize_Swift
import UIKit

protocol LanguageSelectorViewDelegate: class {
	func languageSelectorDidSelect(language: Common.Language)
}

class LanguageSelectorView: UIView {
	private let stackView = UIStackView()
	private let otherLanguageButtons: [LanguageSelectorButton] = {
		Common.Language.allCases.reversed().map {
			let button = LanguageSelectorButton(withArrow: false)
			button.language = $0
			return button
		}
	}()
	private let selectedLanguageButton: LanguageSelectorButton = LanguageSelectorButton(withArrow: true)

	weak var delegate: LanguageSelectorViewDelegate?

	private static let buttonMargin: CGFloat = 13
	private static let selectorSize = CGSize(width: LanguageSelectorButton.buttonSize.width, height: LanguageSelectorButton.buttonSize.height * 3 + LanguageSelectorView.buttonMargin * 2)

	private enum State {
		case open
		case closed
	}
	private var currentState: State = .closed

	private var language: Common.Language = .english {
		didSet {
			selectedLanguageButton.language = language
		}
	}

	private var availableLanguages = Common.Language.allCases

	// MARK: Initializers

	init() {
		super.init(frame: .zero)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// Setup

	private func setup() {
		self.backgroundColor = .clear

		currentState = .closed

		stackView.axis = .vertical
		stackView.spacing = LanguageSelectorView.buttonMargin
		addSubview(stackView)

		for button in otherLanguageButtons {
			button.isHidden = true
			button.isSelected = false
			button.addTarget(self, action: #selector(languageOptionButtonPressed(button:)), for: .touchUpInside)
			stackView.addArrangedSubview(button)
		}

		selectedLanguageButton.isSelected = true
		selectedLanguageButton.isEnabled = true
		selectedLanguageButton.addTarget(self, action: #selector(selectedLanguageButtonPressed(button:)), for: .touchUpInside)

		stackView.addArrangedSubview(selectedLanguageButton)

		createConstraints()

		// Accessibility
		accessibilityElementsHidden = true

		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}

	private func createConstraints() {
		stackView.autoPinEdgesToSuperviewEdges()

		for button in otherLanguageButtons {
			button.autoSetDimensions(to: LanguageSelectorButton.buttonSize)
		}
		selectedLanguageButton.autoSetDimensions(to: LanguageSelectorButton.buttonSize)
	}

	func setLanguages(languages: [Common.Language], defaultLanguage: Common.Language) {
		availableLanguages = languages
		language = defaultLanguage
	}

	// MARK: Open/Close

	func open() {
		currentState = .open

		for button in otherLanguageButtons {
			button.isHidden = (language == button.language) || !availableLanguages.contains(button.language)
		}

		let activeButtons = otherLanguageButtons.filter { !$0.isHidden }
		activeButtons.reversed().enumerated().forEach { (index, button) in
			button.alpha = 0.0
			button.transform = CGAffineTransform(
				translationX: 0,
				y: CGFloat(index + 1) * (LanguageSelectorButton.buttonSize.height + LanguageSelectorView.buttonMargin)
			)
		}

		let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
			activeButtons.forEach { (button) in
				button.alpha = 1.0
				button.transform = .identity
			}
		}
		animator.startAnimation()
	}

	@objc func close() {
		currentState = .closed

		let activeButtons = otherLanguageButtons.filter { !$0.isHidden }

		let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
			activeButtons.reversed().enumerated().forEach { (index, button) in
				button.alpha = 0.0
				button.transform = CGAffineTransform(
					translationX: 0,
					y: CGFloat(index + 1) * (LanguageSelectorButton.buttonSize.height + LanguageSelectorView.buttonMargin)
				)
			}
		}
		animator.startAnimation()
	}

	// MARK: Button Events

	@objc func languageOptionButtonPressed(button: LanguageSelectorButton) {
		language = button.language
		self.delegate?.languageSelectorDidSelect(language: language)
		self.perform(#selector(close), with: nil, afterDelay: 0.2)
	}

	@objc func selectedLanguageButtonPressed(button: LanguageSelectorButton) {
		if currentState == .open {
			close()
		} else if currentState == .closed {
			open()
		}
	}

	// MARK: Localization

	@objc private func updateLanguage() {
		for button in otherLanguageButtons {
			button.updateLanguage()
		}
		selectedLanguageButton.updateLanguage()
	}
}
