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
	let accessMemberCardButton: UIButton = UIButton()
	
	let topMargin: CGFloat = 32.0
	let accessMemberCardTopMargin: CGFloat = 18.0
	let bottomMargin: CGFloat = 32.0
	
	init() {
		super.init(frame:CGRect.zero)
		
		backgroundColor = .aicHomeMemberPromptBackgroundColor
		
		promptTextView.setDefaultsForAICAttributedTextView()
		promptTextView.font = .aicTextFont
		promptTextView.textColor = .aicDarkGrayColor
		promptTextView.textAlignment = .center
		
		accessMemberCardButton.backgroundColor = .clear
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
