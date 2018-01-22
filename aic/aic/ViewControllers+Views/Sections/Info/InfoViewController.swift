//
//  InfoViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/17/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

protocol InfoViewControllerDelegate : class {
	func museumInfoButtonPressed()
	func languageButtonPressed()
	func locationButtonPressed()
}

class InfoViewController : SectionViewController {
	let scrollView: UIScrollView = UIScrollView()
	let whiteBackgroundView: UIView = UIView()
	let becomeMemberView: InfoBecomeMemberView = InfoBecomeMemberView()
	let museumInfoButton: InfoButton = InfoButton()
	let languageButton: InfoButton = InfoButton()
	let locationButton: InfoButton = InfoButton()
	let footerView: InfoFooterView = InfoFooterView()
	
	let footerTopMargin: CGFloat = 15.0
	
	weak var delegate: InfoViewControllerDelegate? = nil
	
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
		
		scrollView.backgroundColor = .aicInfoColor
		scrollView.delegate = self
		
		whiteBackgroundView.backgroundColor = .white
		
		museumInfoButton.setTitle("Museum Information", for: .normal)
		museumInfoButton.addTarget(self, action: #selector(infoButtonPressed(button:)), for: .touchUpInside)
		
		languageButton.setTitle("Language Settings", for: .normal)
		languageButton.addTarget(self, action: #selector(infoButtonPressed(button:)), for: .touchUpInside)
		
		locationButton.setTitle("Location Settings", for: .normal)
		locationButton.addTarget(self, action: #selector(infoButtonPressed(button:)), for: .touchUpInside)
		
		self.view.addSubview(scrollView)
		scrollView.addSubview(whiteBackgroundView)
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
		
		self.scrollDelegate?.sectionViewControllerWillAppearWithScrollView(scrollView: self.scrollView)
		
		updateLanguage()
	}
	
	func createViewConstraints() {
		scrollView.autoPinEdge(.top, to: .top, of: self.view)
		scrollView.autoPinEdge(.leading, to: .leading, of: self.view)
		scrollView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		scrollView.autoPinEdge(.bottom, to: .bottom, of: self.view, withOffset: -Common.Layout.tabBarHeight)
		
		becomeMemberView.autoPinEdge(.top, to: .top, of: scrollView, withOffset: Common.Layout.navigationBarVerticalOffset)
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
	}
	
	@objc func infoButtonPressed(button: UIButton) {
		if button == museumInfoButton {
			self.delegate?.museumInfoButtonPressed()
		}
		else if button == languageButton {
			self.delegate?.languageButtonPressed()
		}
		else if button == locationButton {
			self.delegate?.locationButtonPressed()
		}
	}
}

extension InfoViewController : UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.scrollDelegate?.sectionViewControllerDidScroll(scrollView: scrollView)
	}
}

