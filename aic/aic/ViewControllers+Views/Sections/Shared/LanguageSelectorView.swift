//
//  LanguageSelectorView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/8/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol LanguageSelectorViewDelegate : class {
	func languageSelectorDidSelect(language: Common.Language)
}

class LanguageSelectorView : UIView {
	let languageAButton: LanguageSelectorButton = LanguageSelectorButton(withArrow: false)
	let languageBButton: LanguageSelectorButton = LanguageSelectorButton(withArrow: false)
	let selectedLanguageButton: LanguageSelectorButton = LanguageSelectorButton(withArrow: true)
	
	weak var delegate: LanguageSelectorViewDelegate? = nil
	
	static let buttonMargin: CGFloat = 13
	static let selectorSize: CGSize = CGSize(width: LanguageSelectorButton.buttonSize.width, height: LanguageSelectorButton.buttonSize.height * 3 + LanguageSelectorView.buttonMargin * 2)
	
	var languageAButtonTopMargin: NSLayoutConstraint? = nil
	var languageBButtonTopMargin: NSLayoutConstraint? = nil
	var selectedLanguageButtonTopMargin: NSLayoutConstraint? = nil
	
	enum State {
		case open
		case closed
	}
	var currentState: State = .closed
	
	var language: Common.Language = .english {
		didSet {
			// rearrange our array so the selected language is in the front
			// non-selected languages will appear always in the same order from the bottom: english, spanish, chinese
			availableLanguages.sort { (first, second) -> Bool in
				if first == language { return true }
				else if second == language { return false }
				else if first == .english { return true }
				else if second == .english { return false }
				else if first == .spanish { return true }
				else if second == .spanish { return false }
				else if first == .chinese { return true }
				else if second == .chinese { return false }
				return false
			}
			
			// reset button languages in order starting from the selected at the bottom
			for index in 0...availableLanguages.count-1 {
				if index == 0 { selectedLanguageButton.language = availableLanguages[index] }
				else if index == 1 { languageBButton.language = availableLanguages[index] }
				else if index == 2 { languageAButton.language = availableLanguages[index] }
			}
		}
	}
	
	private var availableLanguages: [Common.Language] = [.english, .spanish, .chinese]
	
	init() {
		super.init(frame: CGRect.zero)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	// Setup
	
	private func setup() {
		self.backgroundColor = .clear
		
		currentState = .closed
		languageAButton.alpha = 0
		languageBButton.alpha = 0
		
		languageAButton.isSelected = false
		languageBButton.isSelected = false
		selectedLanguageButton.isSelected = true
		
		languageAButton.isEnabled = false
		languageBButton.isEnabled = false
		selectedLanguageButton.isEnabled = true
		
		languageAButton.language = .chinese
		languageBButton.language = .spanish
		selectedLanguageButton.language = .english
		
		languageAButton.addTarget(self, action: #selector(languageOptionButtonPressed(button:)), for: .touchUpInside)
		languageBButton.addTarget(self, action: #selector(languageOptionButtonPressed(button:)), for: .touchUpInside)
		selectedLanguageButton.addTarget(self, action: #selector(selectedLanguageButtonPressed(button:)), for: .touchUpInside)
		
		// Add subviews
		self.addSubview(languageAButton)
		self.addSubview(languageBButton)
		self.addSubview(selectedLanguageButton)
		
		createConstraints()
		
		// Accessibility
		self.accessibilityElementsHidden = true
	}
	
	private func createConstraints() {
		languageAButtonTopMargin = languageAButton.autoPinEdge(.top, to: .top, of: self)
		languageAButton.autoPinEdge(.leading, to: .leading, of: self)
		languageAButton.autoSetDimensions(to: LanguageSelectorButton.buttonSize)
		
		languageBButtonTopMargin = languageBButton.autoPinEdge(.top, to: .top, of: self, withOffset: LanguageSelectorButton.buttonSize.height + LanguageSelectorView.buttonMargin)
		languageBButton.autoPinEdge(.leading, to: .leading, of: self)
		languageBButton.autoSetDimensions(to: LanguageSelectorButton.buttonSize)
		
		selectedLanguageButtonTopMargin = selectedLanguageButton.autoPinEdge(.top, to: .top, of: self, withOffset: (LanguageSelectorButton.buttonSize.height + LanguageSelectorView.buttonMargin) * 2)
		selectedLanguageButton.autoPinEdge(.leading, to: .leading, of: self)
		selectedLanguageButton.autoSetDimensions(to: LanguageSelectorButton.buttonSize)
		
		self.autoSetDimensions(to: LanguageSelectorView.selectorSize)
	}
	
	func setLanguages(languages: [Common.Language], defaultLanguage: Common.Language) {
		availableLanguages = languages
		language = defaultLanguage
	}
	
	// MARK : Open/Close
	
	func open() {
		currentState = .open
		languageAButton.isEnabled = availableLanguages.count > 2
		languageAButton.isHidden = !languageAButton.isEnabled
		languageBButton.isEnabled = true
		languageBButton.isHidden = false
		languageAButton.alpha = 0
		languageBButton.alpha = 0
		languageAButtonTopMargin!.constant = selectedLanguageButtonTopMargin!.constant
		languageBButtonTopMargin!.constant = selectedLanguageButtonTopMargin!.constant
		self.setNeedsLayout()
		self.layoutIfNeeded()
		
		UIView.animate(withDuration: 0.25) {
			self.languageAButton.alpha = 1
			self.languageBButton.alpha = 1
		}
		UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
			self.languageAButtonTopMargin!.constant = 0
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}, completion: nil)
		UIView.animate(withDuration: 0.25, delay: 0.05, options: .curveEaseOut, animations: {
			self.languageBButtonTopMargin!.constant = LanguageSelectorButton.buttonSize.height + LanguageSelectorView.buttonMargin
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}, completion: nil)
	}
	
	@objc func close() {
		currentState = .closed
		languageAButton.isEnabled = false
		languageBButton.isEnabled = false
		UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
			self.languageBButtonTopMargin!.constant = self.selectedLanguageButtonTopMargin!.constant
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}, completion: nil)
		UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
			self.languageAButtonTopMargin!.constant = self.selectedLanguageButtonTopMargin!.constant
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}, completion: nil)
		UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
			self.languageAButton.alpha = 0
			self.languageBButton.alpha = 0
		}, completion: nil)
	}
	
	// MARK : Button Events
	
	@objc func languageOptionButtonPressed(button: LanguageSelectorButton) {
		language = button.language
		self.delegate?.languageSelectorDidSelect(language: language)
		self.perform(#selector(close), with: nil, afterDelay: 0.2)
	}
	
	@objc func selectedLanguageButtonPressed(button: LanguageSelectorButton) {
		if currentState == .open {
			close()
		}
		else if currentState == .closed {
			open()
		}
	}
}
