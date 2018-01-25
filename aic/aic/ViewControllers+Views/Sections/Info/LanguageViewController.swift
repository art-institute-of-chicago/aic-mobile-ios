//
//  LanguageSettingsViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class LanguageViewController : UIViewController {
	let pageView: InfoPageView = InfoPageView(title: "Language Settings Title".localized(using: "LanguageSettings"), text: "Language Settings Text".localized(using: "LanguageSettings"))
	let englishButton: AICButton = AICButton(color: .aicInfoColor, isSmall: false)
	let spanishButton: AICButton = AICButton(color: .aicInfoColor, isSmall: false)
	let chineseButton: AICButton = AICButton(color: .aicInfoColor, isSmall: false)
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		self.navigationItem.title = "Language Settings"
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
		
		englishButton.setTitle("English", for: .normal)
		englishButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		spanishButton.setTitle("Español", for: .normal)
		spanishButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		chineseButton.setTitle("中文", for: .normal)
		chineseButton.addTarget(self, action: #selector(languageButtonPressed(button:)), for: .touchUpInside)
		
		// Add subviews
		self.view.addSubview(pageView)
		self.view.addSubview(englishButton)
		self.view.addSubview(spanishButton)
		self.view.addSubview(chineseButton)
		
		let swipeRightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(recognizer:)))
		swipeRightGesture.direction = .right
		self.view.addGestureRecognizer(swipeRightGesture)
		
		createViewConstraints()
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLanguage()
	}
	
	func createViewConstraints() {
		pageView.autoPinEdge(.top, to: .top, of: self.view)
		pageView.autoPinEdge(.leading, to: .leading, of: self.view)
		pageView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		
		englishButton.autoPinEdge(.top, to: .bottom, of: pageView)
		englishButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		spanishButton.autoPinEdge(.top, to: .bottom, of: englishButton, withOffset: 16)
		spanishButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		
		chineseButton.autoPinEdge(.top, to: .bottom, of: spanishButton, withOffset: 16)
		chineseButton.autoAlignAxis(.vertical, toSameAxisOf: self.view)
	}
	
	@objc func languageButtonPressed(button: UIButton) {
		if button == englishButton {
			Localize.setCurrentLanguage(Common.Language.english.rawValue)
		}
		else if button == spanishButton {
			Localize.setCurrentLanguage(Common.Language.spanish.rawValue)
		}
		else if button == chineseButton {
			Localize.setCurrentLanguage(Common.Language.chinese.rawValue)
		}
	}
	
	@objc func updateLanguage() {
		pageView.titleLabel.text = "Language Settings Title".localized(using: "LanguageSettings")
		pageView.textView.text = "Language Settings Text".localized(using: "LanguageSettings")
		
		englishButton.isHighlighted = Localize.currentLanguage() != Common.Language.english.rawValue
		spanishButton.isHighlighted = Localize.currentLanguage() != Common.Language.spanish.rawValue
		chineseButton.isHighlighted = Localize.currentLanguage() != Common.Language.chinese.rawValue
	}
}

extension LanguageViewController : UIGestureRecognizerDelegate {
	@objc private func swipeRight(recognizer: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
}
