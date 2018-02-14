//
//  HomeMemberCardView.swift
//  aic
//
//  Created by Filippo Vanucci on 11/21/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import PureLayout

class HomeMemberPromptView: BaseView {
	let promptTextView: UITextView = UITextView()
	let accessMemberCardTextView: LinkedTextView = LinkedTextView()
	let accessMemberCardButton: UIButton = UIButton()
	
	let topMargin: CGFloat = 32.0
	let accessMemberCardTopMargin: CGFloat = 18.0
	let bottomMargin: CGFloat = 32.0
	
	init() {
		super.init(frame:CGRect.zero)
		
		backgroundColor = .aicHomeMemberPromptBackgroundColor
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 6
		let promptTextAttrString = NSMutableAttributedString(string: "The Museum is a dynamic place. Let’s Explore!\nIf you’re a member, sign-in for enhanced access.")
		promptTextAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, promptTextAttrString.length))
		
		promptTextView.setDefaultsForAICAttributedTextView()
		promptTextView.attributedText = promptTextAttrString
		promptTextView.font = .aicTextFont
		promptTextView.textColor = .aicDarkGrayColor
		promptTextView.textAlignment = .center
		
		accessMemberCardButton.backgroundColor = .clear
		accessMemberCardButton.setTitle("Access your member card.".localized(using: "Home"), for: .normal)
		accessMemberCardButton.titleLabel!.font = .aicTextFont
		accessMemberCardButton.setTitleColor(.aicHomeMemberPromptLinkColor, for: .normal)
		
		// Add subviews
		self.addSubview(promptTextView)
		self.addSubview(accessMemberCardButton)
		
		createConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createConstraints() {
		if didSetupConstraints == false {
			promptTextView.autoPinEdge(.top, to: .top, of: self, withOffset: topMargin)
			promptTextView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16.0)
			promptTextView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16.0)
			
			accessMemberCardButton.autoPinEdge(.top, to: .bottom, of: promptTextView, withOffset: accessMemberCardTopMargin)
			accessMemberCardButton.autoAlignAxis(.vertical, toSameAxisOf: self)
			
			self.autoPinEdge(.bottom, to: .bottom, of: accessMemberCardButton, withOffset: bottomMargin)
			
			didSetupConstraints = true
		}
		
		super.updateConstraints()
	}
}
