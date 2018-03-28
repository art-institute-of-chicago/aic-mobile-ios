//
//  LanguageSelectionViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/19/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol LanguageSelectionViewControllerDelegate : class {
	func languageSelected(language: Common.Language)
}

class LanguageSelectionViewController : UIViewController {
	
	let blurBGView:UIView = getBlurEffectView(frame: UIScreen.main.bounds)
	
	let contentView = UIView()
	let titleLabel = UILabel()
	let dividerLine = UIView()
	let subtitleLabel = UILabel()
	let englishButton: AICButton = AICButton(isSmall: true)
	let spanishButton: AICButton = AICButton(isSmall: true)
	let chineseButton: AICButton = AICButton(isSmall: true)
	
	let fadeInOutAnimationDuration = 0.4
	let contentViewFadeInOutAnimationDuration = 0.4
	
	var selectedLanguage: Common.Language = .english
	
	weak var delegate: LanguageSelectionViewControllerDelegate? = nil
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .clear
		
		contentView.backgroundColor = .clear
		
		titleLabel.font = .aicLanguageSelectionTitleFont
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .white
		titleLabel.textAlignment = .center
		
		dividerLine.backgroundColor = .aicDividerLineTransparentColor
		
		englishButton.setColorMode(colorMode: AICButton.transparentMode)
		englishButton.setTitle("English", for: .normal)
		englishButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		spanishButton.setColorMode(colorMode: AICButton.transparentMode)
		spanishButton.setTitle("Español", for: .normal)
		spanishButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		chineseButton.setColorMode(colorMode: AICButton.transparentMode)
		chineseButton.setTitle("中文", for: .normal)
		chineseButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		// Add subviews
		self.view.addSubview(blurBGView)
		self.view.addSubview(contentView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(dividerLine)
		contentView.addSubview(subtitleLabel)
		contentView.addSubview(englishButton)
		contentView.addSubview(spanishButton)
		contentView.addSubview(chineseButton)
		
		createViewConstraints()
	}
	
	func createViewConstraints() {
		contentView.autoPinEdgesToSuperviewEdges()
		
		titleLabel.autoAlignAxis(.vertical, toSameAxisOf: contentView)
		titleLabel.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
		titleLabel.autoPinEdge(.top, to: .top, of: contentView, withOffset: 90 + Common.Layout.safeAreaTopMargin)
		
		dividerLine.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 30)
		dividerLine.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
		
		subtitleLabel.autoPinEdge(.top, to: .bottom, of: dividerLine, withOffset: 30)
		subtitleLabel.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 40)
		subtitleLabel.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -40)
		subtitleLabel.autoAlignAxis(.vertical, toSameAxisOf: contentView)
		
		englishButton.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: 64)
		englishButton.autoAlignAxis(.vertical, toSameAxisOf: contentView)
		
		spanishButton.autoPinEdge(.top, to: .bottom, of: englishButton, withOffset: 16)
		spanishButton.autoAlignAxis(.vertical, toSameAxisOf: contentView)
		
		chineseButton.autoPinEdge(.top, to: .bottom, of: spanishButton, withOffset: 16)
		chineseButton.autoAlignAxis(.vertical, toSameAxisOf: contentView)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Device language
		let deviceLanguage = NSLocale.preferredLanguages.first!
		if deviceLanguage.hasPrefix("es") {
			Localize.setCurrentLanguage(Common.Language.spanish.rawValue)
			spanishButton.setColorMode(colorMode: AICButton.greenBlueMode)
		}
		else if deviceLanguage.hasPrefix("zh") {
			Localize.setCurrentLanguage(Common.Language.chinese.rawValue)
			chineseButton.setColorMode(colorMode: AICButton.greenBlueMode)
		}
		else {
			Localize.setCurrentLanguage(Common.Language.english.rawValue)
			englishButton.setColorMode(colorMode: AICButton.greenBlueMode)
		}
		
		updateLanguage()
		
		// Fade in
		view.alpha = 0.0
		contentView.alpha = 0.0
		UIView.animate(withDuration: fadeInOutAnimationDuration, animations: {
			self.view.alpha = 1.0
		}) { (completed) in
			if completed == true {
				UIView.animate(withDuration: self.contentViewFadeInOutAnimationDuration, animations: {
					self.contentView.alpha = 1.0
				})
			}
		}
	}
	
	func updateLanguage() {
		titleLabel.text = "Language Settings Title".localized(using: "LanguageSettings")
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 6
		let textAttrString = NSMutableAttributedString(string: "Language Settings Text".localized(using: "LanguageSettings"))
		textAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, textAttrString.length))
		
		subtitleLabel.attributedText = textAttrString
		subtitleLabel.font = .aicLanguageSelectionTextFont
		subtitleLabel.numberOfLines = 0
		subtitleLabel.textColor = .white
		subtitleLabel.textAlignment = .center
	}
	
	@objc func languageButtonPressed(button: UIButton) {
		englishButton.setColorMode(colorMode: AICButton.transparentMode)
		spanishButton.setColorMode(colorMode: AICButton.transparentMode)
		chineseButton.setColorMode(colorMode: AICButton.transparentMode)
		
		englishButton.isEnabled = false
		spanishButton.isEnabled = false
		chineseButton.isEnabled = false
		
		if button == englishButton {
			englishButton.setColorMode(colorMode: AICButton.greenBlueMode)
			Localize.setCurrentLanguage(Common.Language.english.rawValue)
			selectedLanguage = .english
		}
		else if button == spanishButton {
			spanishButton.setColorMode(colorMode: AICButton.greenBlueMode)
			Localize.setCurrentLanguage(Common.Language.spanish.rawValue)
			selectedLanguage = .spanish
		}
		else if button == chineseButton {
			chineseButton.setColorMode(colorMode: AICButton.greenBlueMode)
			Localize.setCurrentLanguage(Common.Language.chinese.rawValue)
			selectedLanguage = .chinese
		}
		
		updateLanguage()
		
		self.perform(#selector(hideLanguageSelection), with: nil, afterDelay: 1.0)
		
		// Log analytics
		AICAnalytics.sendLanguageSelectedEvent(language: selectedLanguage)
	}
	
	@objc func hideLanguageSelection() {
		//staticBlurImageView.removeFromSuperview()
		UIView.animate(withDuration: contentViewFadeInOutAnimationDuration, animations: {
			self.contentView.alpha = 0.0
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
