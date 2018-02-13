//
//  MemberCardViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/12/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class MemberCardViewController : UIViewController {
	let loginView: MemberLoginView = MemberLoginView()
	let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
	let cardView: MemberCardView = MemberCardView()
	
	let memberDataManager: MemberDataManager = MemberDataManager()
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		self.navigationItem.title = "Member Card"
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		memberDataManager.delegate = self
		
		self.view.backgroundColor = .white
		
		loadingIndicatorView.isHidden = true
		loadingIndicatorView.activityIndicatorViewStyle = .whiteLarge
		loadingIndicatorView.color = .darkGray
		
		loginView.loginButton.addTarget(self, action: #selector(loginButtonPressed(button:)), for: .touchUpInside)
		cardView.changeInfoButton.addTarget(self, action: #selector(changeInfoButtonPressed(button:)), for: .touchUpInside)
		cardView.switchCardholderButton.addTarget(self, action: #selector(switchCardholderButtonPressed(button:)), for: .touchUpInside)
		
		// Add subviews
		self.view.addSubview(loginView)
		self.view.addSubview(loadingIndicatorView)
		self.view.addSubview(cardView)
		
		createViewConstraints()
		
		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		updateLanguage()
		
		showLogin()
	}
	
	private func createViewConstraints() {
		loginView.autoPinEdge(.top, to: .top, of: self.view, withOffset: Common.Layout.navigationBarMinimizedVerticalOffset)
		loginView.autoPinEdge(.leading, to: .leading, of: self.view)
		loginView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		loginView.autoPinEdge(.bottom, to: .bottom, of: self.view)
		
		loadingIndicatorView.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		loadingIndicatorView.autoAlignAxis(.horizontal, toSameAxisOf: self.view)
		
		cardView.autoPinEdge(.top, to: .top, of: self.view, withOffset: Common.Layout.navigationBarMinimizedVerticalOffset)
		cardView.autoPinEdge(.leading, to: .leading, of: self.view)
		cardView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		cardView.autoPinEdge(.bottom, to: .bottom, of: self.view)
	}
	
	@objc private func updateLanguage() {
		
	}
	
	// MARK: Show Views
	
	private func showLogin() {
		loginView.isHidden = false
		loadingIndicatorView.isHidden = true
		loadingIndicatorView.stopAnimating()
		cardView.isHidden = true
	}
	
	private func showLoading() {
		loginView.isHidden = true
		loadingIndicatorView.isHidden = false
		loadingIndicatorView.startAnimating()
		cardView.isHidden = true
	}
	
	private func showCard() {
		loginView.isHidden = true
		loadingIndicatorView.isHidden = true
		loadingIndicatorView.stopAnimating()
		cardView.isHidden = false
	}
	
	private func loadMemberFromUserDefaults() {
		
	}
	
	// Buttons
	
	@objc private func loginButtonPressed(button: UIButton) {
		let memberId = loginView.memberIDTextField.text!
		let zipCode = loginView.memberZipCodeTextField.text!
		
		memberDataManager.validateMember(memberID: memberId, zipCode: zipCode)
		showLoading()
	}
	
	@objc private func changeInfoButtonPressed(button: UIButton) {
		showLogin()
	}
	
	@objc private func switchCardholderButtonPressed(button: UIButton) {
		if let memberCard = memberDataManager.currentMemberCard {
			memberDataManager.currentMemberNameIndex = memberDataManager.currentMemberNameIndex < memberCard.memberNames.count - 1 ? memberDataManager.currentMemberNameIndex + 1 : 0
			cardView.memberNameLabel.text = memberCard.memberNames[memberDataManager.currentMemberNameIndex]
			
			memberDataManager.saveCurrentMember()
		}
	}
}

// MARK: MemberDataManagerDelegate

extension MemberCardViewController : MemberDataManagerDelegate {
	func memberCardDidLoadForMember(memberCard: AICMemberCardModel) {
		cardView.setContent(memberCard: memberCard, memberNameIndex: 0)
		showCard()
	}
	
	func memberCardDataLoadingFailed() {
		let alert = UIAlertController(title: Common.Info.alertMessageParseError, message: "", preferredStyle: UIAlertControllerStyle.alert)
		let action = UIAlertAction(title: Common.Info.alertMessageCancelButtonTitle, style: UIAlertActionStyle.default, handler: { (action) in
			self.showLogin()
			self.loadMemberFromUserDefaults()
		})
		
		alert.addAction(action)
		present(alert, animated:true)
	}
}
