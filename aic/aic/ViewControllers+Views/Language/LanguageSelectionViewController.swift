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
	
	let titleLabel = UILabel()
	let dividerLine = UIView()
	let subtitleLabel = UILabel()
	let englishButton: AICTransparentButton = AICTransparentButton(color: .aicHomeColor, isSmall: true)
	let spanishButton: AICTransparentButton = AICTransparentButton(color: .aicHomeColor, isSmall: true)
	let chineseButton: AICTransparentButton = AICTransparentButton(color: .aicHomeColor, isSmall: true)
	
	let fadeInAnimationDuration = 0.25
	
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
		
//		titleLabel.attributedText = getAttributedStringWithLineHeight(text: "Please Choose Your Preferred Language", font: .aicLanguageSelectionTitleFont, lineHeight: 32)
		titleLabel.text = "Language Selection Title".localized(using: "LanguageSelection")
		titleLabel.font = .aicLanguageSelectionTitleFont
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .white
		titleLabel.textAlignment = .center
		
		dividerLine.backgroundColor = .aicDividerLineTransparentColor
		
		englishButton.setTitle("English", for: .normal)
		englishButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		spanishButton.setTitle("Español", for: .normal)
		spanishButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		chineseButton.setTitle("中文", for: .normal)
		chineseButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		// Add subviews
		self.view.addSubview(blurBGView)
		self.view.addSubview(titleLabel)
		self.view.addSubview(dividerLine)
		self.view.addSubview(subtitleLabel)
		self.view.addSubview(englishButton)
		self.view.addSubview(spanishButton)
		self.view.addSubview(chineseButton)
		
		createViewConstraints()
	}
	
	func createViewConstraints() {
		titleLabel.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
		titleLabel.autoPinEdge(.top, to: .top, of: self.view, withOffset: 90 + Common.Layout.safeAreaTopMargin)
		
		dividerLine.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 30)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
		
		subtitleLabel.autoPinEdge(.top, to: .bottom, of: dividerLine, withOffset: 30)
		subtitleLabel.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 40)
		subtitleLabel.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -40)
		subtitleLabel.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		englishButton.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: 64)
		englishButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		spanishButton.autoPinEdge(.top, to: .bottom, of: englishButton, withOffset: 16)
		spanishButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		chineseButton.autoPinEdge(.top, to: .bottom, of: spanishButton, withOffset: 16)
		chineseButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Device language
		let deviceLanguage = NSLocale.preferredLanguages.first!
		if deviceLanguage.hasPrefix("es") {
			Localize.setCurrentLanguage(Common.Language.spanish.rawValue)
			englishButton.isHighlighted = true
			chineseButton.isHighlighted = true
		}
		else if deviceLanguage.hasPrefix("zh") {
			Localize.setCurrentLanguage(Common.Language.chinese.rawValue)
			englishButton.isHighlighted = true
			spanishButton.isHighlighted = true
		}
		else {
			Localize.setCurrentLanguage(Common.Language.english.rawValue)
			spanishButton.isHighlighted = true
			chineseButton.isHighlighted = true
		}
		
		updateLanguage()
		
		// Fade in
		view.alpha = 0.0
		UIView.animate(withDuration: fadeInAnimationDuration, animations: {
			self.view.alpha = 1.0
		})
	}
	
	func updateLanguage() {
		titleLabel.text = "Language Selection Title".localized(using: "LanguageSelection")
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 6
		let textAttrString = NSMutableAttributedString(string: "Language Selection Text".localized(using: "LanguageSelection"))
		textAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, textAttrString.length))
		
		subtitleLabel.attributedText = textAttrString
		subtitleLabel.font = .aicLanguageSelectionTextFont
		subtitleLabel.numberOfLines = 0
		subtitleLabel.textColor = .white
		subtitleLabel.textAlignment = .center
	}
	
	@objc func languageButtonPressed(button: UIButton) {
		englishButton.isHighlighted = button != englishButton
		spanishButton.isHighlighted = button != spanishButton
		chineseButton.isHighlighted = button != chineseButton
		
		if button == englishButton {
			Localize.setCurrentLanguage(Common.Language.english.rawValue)
			self.delegate?.languageSelected(language: .english)
		}
		else if button == spanishButton {
			Localize.setCurrentLanguage(Common.Language.spanish.rawValue)
			self.delegate?.languageSelected(language: .spanish)
		}
		else if button == chineseButton {
			Localize.setCurrentLanguage(Common.Language.chinese.rawValue)
			self.delegate?.languageSelected(language: .chinese)
		}
	}
}
