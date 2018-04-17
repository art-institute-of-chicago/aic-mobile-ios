//
//  MemberLoginView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/13/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MemberLoginView : UIView {
	let memberIDTitleLabel: UILabel = UILabel()
	let memberIDTextField: UITextField = UITextField()
	let memberZipCodeTitleLabel: UILabel = UILabel()
	let memberZipCodeTextField: UITextField = UITextField()
	let loginButton: AICButton = AICButton(isSmall: false)
	
	init() {
		super.init(frame: CGRect.zero)
		
		self.backgroundColor = .clear
		
		memberIDTitleLabel.text = "Member ID"
		memberIDTitleLabel.font = .aicTitleFont
		memberIDTitleLabel.textColor = .black
		memberIDTitleLabel.numberOfLines = 1
		memberIDTitleLabel.textAlignment = .left
		
		memberIDTextField.placeholder = "Enter your Member ID..."
		memberIDTextField.backgroundColor = .aicMemberCardLoginFieldColor
		memberIDTextField.textColor = .black
		memberIDTextField.font = .aicMemberCardLoginFieldFont
		memberIDTextField.leftViewMode = .always
		memberIDTextField.leftView = UIView(frame: CGRect(x: 0, y:0, width: 10, height: 40))
		memberIDTextField.keyboardType = .numberPad
		
		memberZipCodeTitleLabel.text = "Zip Code"
		memberZipCodeTitleLabel.font = .aicTitleFont
		memberZipCodeTitleLabel.textColor = .black
		memberZipCodeTitleLabel.numberOfLines = 1
		memberZipCodeTitleLabel.textAlignment = .left
		
		memberZipCodeTextField.placeholder = "Enter your home zip code..."
		memberZipCodeTextField.backgroundColor = .aicMemberCardLoginFieldColor
		memberZipCodeTextField.textColor = .black
		memberZipCodeTextField.font = .aicMemberCardLoginFieldFont
		memberZipCodeTextField.leftViewMode = .always
		memberZipCodeTextField.leftView = UIView(frame: CGRect(x: 0, y:0, width: 10, height: 40))
		memberZipCodeTextField.keyboardType = .numbersAndPunctuation
		
		loginButton.setColorMode(colorMode: AICButton.orangeMode)
		loginButton.setTitle("Sign In", for: .normal)
		
		// Add subviews
		self.addSubview(memberIDTitleLabel)
		self.addSubview(memberIDTextField)
		self.addSubview(memberZipCodeTitleLabel)
		self.addSubview(memberZipCodeTextField)
		self.addSubview(loginButton)
		
		createConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createConstraints() {
		memberIDTitleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: 23)
		memberIDTitleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 23)
		memberIDTitleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -23)
		
		memberIDTextField.autoPinEdge(.top, to: .bottom, of: memberIDTitleLabel, withOffset: 23)
		memberIDTextField.autoPinEdge(.leading, to: .leading, of: self, withOffset: 22)
		memberIDTextField.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -23)
		memberIDTextField.autoSetDimension(.height, toSize: 40)
		
		memberZipCodeTitleLabel.autoPinEdge(.top, to: .bottom, of: memberIDTextField, withOffset: 28)
		memberZipCodeTitleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 23)
		memberZipCodeTitleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -23)
		
		memberZipCodeTextField.autoPinEdge(.top, to: .bottom, of: memberZipCodeTitleLabel, withOffset: 23)
		memberZipCodeTextField.autoPinEdge(.leading, to: .leading, of: self, withOffset: 22)
		memberZipCodeTextField.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -23)
		memberZipCodeTextField.autoSetDimension(.height, toSize: 40)
		
		loginButton.autoPinEdge(.top, to: .bottom, of: memberZipCodeTextField, withOffset: 50)
		loginButton.autoAlignAxis(.vertical, toSameAxisOf: self)
	}
}
