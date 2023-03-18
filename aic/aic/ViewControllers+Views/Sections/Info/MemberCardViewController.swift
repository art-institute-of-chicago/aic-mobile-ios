//
//  MemberCardViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/12/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class MemberCardViewController: UIViewController {
	let loginView: MemberLoginView = MemberLoginView()
	let loadingIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
	let cardView: MemberCardView = MemberCardView()

	init() {
		super.init(nibName: nil, bundle: nil)

		self.navigationItem.title = "member_card_title:AccessCard"
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		MemberDataManager.sharedInstance.delegate = self

		self.view.backgroundColor = .white

		loadingIndicatorView.isHidden = true
		loadingIndicatorView.style = .large
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

		// Log analytics
		AICAnalytics.trackScreenView("Member Card", screenClass: "MemberCardViewController")
	}

	private func createViewConstraints() {
		loginView.autoPinEdge(.top, to: .top, of: self.view, withOffset: Common.Layout.navigationBarMinimizedHeight)
		loginView.autoPinEdge(.leading, to: .leading, of: self.view)
		loginView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		loginView.autoPinEdge(.bottom, to: .bottom, of: self.view)

		loadingIndicatorView.autoAlignAxis(.vertical, toSameAxisOf: self.view)
		loadingIndicatorView.autoAlignAxis(.horizontal, toSameAxisOf: self.view)

		cardView.autoPinEdge(.top, to: .top, of: self.view, withOffset: Common.Layout.navigationBarMinimizedHeight)
		cardView.autoPinEdge(.leading, to: .leading, of: self.view)
		cardView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		cardView.autoPinEdge(.bottom, to: .bottom, of: self.view)
	}

	// MARK: Language

	@objc private func updateLanguage() {
		loginView.memberIDTitleLabel.text = "sign_in_member_id_header".localized(using: "AccessCard")
		loginView.memberIDTextField.attributedPlaceholder = NSAttributedString(
			string: "sign_in_member_id_placeholder".localized(using: "AccessCard"),
			attributes: [
				.font: loginView.memberIDTextField.font ?? .aicMemberCardLoginFieldFont,
				.foregroundColor: UIColor.gray
			]
		)
		loginView.memberZipCodeTitleLabel.text = "sign_in_zip_code_header".localized(using: "AccessCard")
		loginView.memberZipCodeTextField.attributedPlaceholder = NSAttributedString(
			string: "sign_in_zip_code_placeholder".localized(using: "AccessCard"),
			attributes: [
				.font: loginView.memberZipCodeTextField.font ?? .aicMemberCardLoginFieldFont,
				.foregroundColor: UIColor.gray
			]
		)
		loginView.loginButton.setTitle("sign_in_action".localized(using: "AccessCard"), for: .normal)
		cardView.changeInfoButton.setTitle("member_card_change_information_action".localized(using: "AccessCard"), for: .normal)
		cardView.switchCardholderButton.setTitle("member_card_switch_cardholder_action".localized(using: "AccessCard"), for: .normal)
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

		// Log analytics
		AICAnalytics.sendMemberCardShownEvent()
	}

	// MARK: Load Member

	private func loadMemberFromUserDefaults() {
		if let memberInfo = MemberDataManager.sharedInstance.getSavedMember() {
			loadMember(memberId: memberInfo.memberID, zipCode: memberInfo.memberZip)
		} else {
			showLogin()
		}
	}

	private func loadMember(memberId: String, zipCode: String) {
		MemberDataManager.sharedInstance.validateMember(memberID: memberId, zipCode: zipCode)
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
		if let memberInfo = MemberDataManager.sharedInstance.getSavedMember() {
			loginView.memberIDTextField.text = memberInfo.memberID
			loginView.memberZipCodeTextField.text = memberInfo.memberZip
		}
		showLogin()
	}

	@objc private func switchCardholderButtonPressed(button: UIButton) {
		if let memberCard = MemberDataManager.sharedInstance.currentMemberCard {
			MemberDataManager.sharedInstance.currentMemberNameIndex = MemberDataManager.sharedInstance.currentMemberNameIndex < memberCard.memberNames.count - 1 ? MemberDataManager.sharedInstance.currentMemberNameIndex + 1 : 0
			cardView.memberNameLabel.text = memberCard.memberNames[MemberDataManager.sharedInstance.currentMemberNameIndex]

			MemberDataManager.sharedInstance.saveCurrentMember()
		}
	}

	// MARK: Dismiss Keyboard

	@objc private func hideKeyboard() {
		self.view.endEditing(true)
	}
}

// MARK: MemberDataManagerDelegate

extension MemberCardViewController: MemberDataManagerDelegate {
	func memberCardDidLoadForMember(memberCard: AICMemberCardModel) {
		cardView.setContent(memberCard: memberCard, memberNameIndex: MemberDataManager.sharedInstance.currentMemberNameIndex)
		showCard()
	}

	func memberCardDataLoadingFailed() {
		let alert = UIAlertController(title: "sign_in_failure_title".localized(using: "AccessCard"), message: nil, preferredStyle: .alert)
		let action = UIAlertAction(title: "global_accept_action".localized(using: "Base"), style: .default, handler: { (_) in
			self.loadMemberFromUserDefaults()
		})

		alert.addAction(action)
		present(alert, animated: true)
	}
}
