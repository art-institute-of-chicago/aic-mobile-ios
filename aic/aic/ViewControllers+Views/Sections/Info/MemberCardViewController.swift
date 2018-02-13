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
		
		let dismissKeyboardTapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		self.view.addGestureRecognizer(dismissKeyboardTapGesture)
		
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
		
		loadMemberFromUserDefaults()
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
	
	// MARK: Language
	
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
	
	// MARK: Load Member
	
	private func loadMemberFromUserDefaults() {
		if let memberInfo = memberDataManager.getSavedMember() {
			loadMember(memberId: memberInfo.memberID, zipCode: memberInfo.memberZip)
		} else {
			showLogin()
		}
	}
	
	private func loadMember(memberId: String, zipCode: String) {
		memberDataManager.validateMember(memberID: memberId, zipCode: zipCode)
		showLoading()
	}
	
	// MARK: Buttons
	
	@objc private func loginButtonPressed(button: UIButton) {
		hideKeyboard()
		
		let memberId = loginView.memberIDTextField.text!
		let zipCode = loginView.memberZipCodeTextField.text!
		
		loadMember(memberId: memberId, zipCode: zipCode)
	}
	
	@objc private func changeInfoButtonPressed(button: UIButton) {
		if let memberInfo = memberDataManager.getSavedMember() {
			loginView.memberIDTextField.text = memberInfo.memberID
			loginView.memberZipCodeTextField.text = memberInfo.memberZip
		}
		showLogin()
	}
	
	@objc private func switchCardholderButtonPressed(button: UIButton) {
		if let memberCard = memberDataManager.currentMemberCard {
			memberDataManager.currentMemberNameIndex = memberDataManager.currentMemberNameIndex < memberCard.memberNames.count - 1 ? memberDataManager.currentMemberNameIndex + 1 : 0
			cardView.memberNameLabel.text = memberCard.memberNames[memberDataManager.currentMemberNameIndex]
			
			memberDataManager.saveCurrentMember()
		}
	}
	
	// MARK: Dismiss Keyboard
	
	@objc private func hideKeyboard() {
		self.view.endEditing(true)
	}
}

// MARK: MemberDataManagerDelegate

extension MemberCardViewController : MemberDataManagerDelegate {
	func memberCardDidLoadForMember(memberCard: AICMemberCardModel) {
		cardView.setContent(memberCard: memberCard, memberNameIndex: memberDataManager.currentMemberNameIndex)
		showCard()
	}
	
	func memberCardDataLoadingFailed() {
		let alert = UIAlertController(title: Common.Info.alertMessageParseError, message: "", preferredStyle: UIAlertControllerStyle.alert)
		let action = UIAlertAction(title: Common.Info.alertMessageCancelButtonTitle, style: UIAlertActionStyle.default, handler: { (action) in
			self.loadMemberFromUserDefaults()
		})
		
		alert.addAction(action)
		present(alert, animated:true)
	}
	
	func memberCardDataLoadingFailedWithError(error: String) {
		let alert = UIAlertController(title: Common.Info.alertMessageNotFound, message: error, preferredStyle: UIAlertControllerStyle.alert)
		let action = UIAlertAction(title: Common.Info.alertMessageCancelButtonTitle, style: UIAlertActionStyle.default, handler: { (action) in
			self.loadMemberFromUserDefaults()
		})
		
		alert.addAction(action)
		present(alert, animated:true)
	}
}
