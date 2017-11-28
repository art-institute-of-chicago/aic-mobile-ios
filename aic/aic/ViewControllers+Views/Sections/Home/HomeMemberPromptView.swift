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
	
	let topMargin: CGFloat = 32.0
	let accessMemberCardTopMargin: CGFloat = 15.0
	let bottomMargin: CGFloat = 32.0
	
	init() {
		super.init(frame:CGRect.zero)
		
		backgroundColor = .aicHomeMemberPromptBackgroundColor
		
		promptTextView.setDefaultsForAICAttributedTextView()
		promptTextView.text = "The Museum is a dynamic place. Let’s Explore!\nIf you’re a member, sign-in for enhanced access."
		promptTextView.font = .aicTextFont
		promptTextView.textColor = .aicDarkGrayColor
		promptTextView.textAlignment = .center
		
		let accessMemberCardAttrText = NSMutableAttributedString(string: "Access your member card.")
		let accessMemberCardURL = URL(string: Common.Info.becomeMemberJoinURL)!
		accessMemberCardAttrText.addAttributes([NSAttributedStringKey.link : accessMemberCardURL], range: NSMakeRange(0, accessMemberCardAttrText.string.count))
		
		accessMemberCardTextView.setDefaultsForAICAttributedTextView()
		accessMemberCardTextView.attributedText = accessMemberCardAttrText
		accessMemberCardTextView.linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.aicMapColor]
		accessMemberCardTextView.textAlignment = NSTextAlignment.center
		accessMemberCardTextView.font = .aicTextFont
		
		self.addSubview(promptTextView)
		self.addSubview(accessMemberCardTextView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateConstraints() {
		if didSetupConstraints == false {
			promptTextView.autoPinEdge(.top, to: .top, of: self, withOffset: topMargin)
			promptTextView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16.0)
			promptTextView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16.0)
			
			accessMemberCardTextView.autoPinEdge(.top, to: .bottom, of: promptTextView, withOffset: accessMemberCardTopMargin)
			accessMemberCardTextView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16.0)
			accessMemberCardTextView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16.0)
			
			self.autoPinEdge(.bottom, to: .bottom, of: accessMemberCardTextView, withOffset: bottomMargin)
			
			didSetupConstraints = true
		}
		
		super.updateConstraints()
	}
}

