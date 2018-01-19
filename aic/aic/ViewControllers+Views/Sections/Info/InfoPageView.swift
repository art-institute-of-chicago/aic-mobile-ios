//
//  InfoPageView.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// InfoPageView
///
/// Info page Title and Text
class InfoPageView : UIView {
	let titleLabel: UILabel = UILabel()
	let dividerLine: UIView = UIView()
	let textView: UITextView = UITextView()
	
	let titleHeight: CGFloat = 109
	
	init(title: String, text: String) {
		super.init(frame: CGRect.zero)
		
		titleLabel.text = title
		titleLabel.textColor = .aicDarkGrayColor
		titleLabel.textAlignment = .center
		titleLabel.font = .aicInfoSectionTitleFont
		titleLabel.numberOfLines = 0
		
		dividerLine.backgroundColor = .aicDividerLineColor
		
		
		// TODO: change this to use getAttributedStringWithLineHeight
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 6
		let textAttrString = NSMutableAttributedString(string: text)
		textAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, textAttrString.length))
		
		textView.setDefaultsForAICAttributedTextView()
		textView.attributedText = textAttrString
		textView.textColor = .aicDarkGrayColor
		textView.font = .aicInfoSectionTextFont
		textView.textAlignment = .center
		
		self.addSubview(titleLabel)
		self.addSubview(dividerLine)
		self.addSubview(textView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateConstraints() {
		titleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: Common.Layout.navigationBarMinimizedHeight)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 30.0)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -30.0)
		titleLabel.autoSetDimension(.height, toSize: titleHeight)
		
		dividerLine.autoPinEdge(.top, to: .bottom, of: titleLabel)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16.0)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16.0)
		dividerLine.autoSetDimension(.height, toSize: 1.0)
		
		textView.autoPinEdge(.top, to: .top, of: dividerLine, withOffset: 24.0)
		textView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 60.0)
		textView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -60.0)
		
		autoPinEdge(.bottom, to: .bottom, of: textView, withOffset: 64.0)
		
		super.updateConstraints()
	}
}
