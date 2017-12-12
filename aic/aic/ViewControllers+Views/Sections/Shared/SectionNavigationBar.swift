//
//  SectionNavigationBar.swift
//  aic
//
//  Created by Filippo Vanucci on 11/16/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SectionNavigationBar : UIView {
	let backdropImage:UIImageView = UIImageView()
	let backButton: UIButton = UIButton()
	let searchButton: UIButton = UIButton()
	let iconImage:UIImageView = UIImageView()
	let titleLabel:UILabel = UILabel()
	let descriptionLabel:UILabel = UILabel()
	
	private let margins = UIEdgeInsetsMake(40, 30, 30, 30)
	
	private let backButtonBottomMargin: CGFloat = 1
	private let backButtonLeftMargin: CGFloat = 3
	private let backButtonContentInsets: UIEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
	private let iconBottomMargin: CGFloat = 10
	private let titleHeight: CGFloat = 40
	private var titleTopMargin: CGFloat = 95
	private var titleBottomMargin: CGFloat = 5
	private var titleMinimumScale: CGFloat = 0.7
	private let descriptionTopMargin: CGFloat = 65
	
	internal let titleString:String
	
	init(section: AICSectionModel) {
		
		self.titleString = section.title
		
		super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Common.Layout.navigationBarHeight))
		
		self.clipsToBounds = true
		self.backgroundColor = section.color
		
		if let _ = section.background {
			self.backdropImage.image = section.background
		}
		
		backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
		backButton.contentEdgeInsets = backButtonContentInsets
		setBackButtonHidden(true)
		
		searchButton.setImage(#imageLiteral(resourceName: "iconSearch"), for: .normal)
		searchButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
		
		iconImage.image = section.icon
		
		let preferredLabelWidth = UIScreen.main.bounds.width - margins.right - margins.left
		
		titleLabel.numberOfLines = 0
		if section.nid == Section.home.rawValue {
			titleLabel.font = .aicSectionBigTitleFont
			titleBottomMargin = -1
		}
		else {
			titleLabel.font = .aicSectionTitleFont
		}
		titleLabel.textColor = .white
		titleLabel.textAlignment = NSTextAlignment.center
		titleLabel.text = section.title
		titleLabel.preferredMaxLayoutWidth = preferredLabelWidth
		
		if section.nid == Section.home.rawValue {
			titleTopMargin = 176
			titleMinimumScale = 0.5
		}
		
		if section.nid != Section.home.rawValue {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 6
			let descriptonAttrString = NSMutableAttributedString(string: section.description)
			descriptonAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, descriptonAttrString.length))
			
			descriptionLabel.numberOfLines = 2
			descriptionLabel.font = .aicSectionDescriptionFont
			descriptionLabel.textColor = .white
			descriptionLabel.attributedText = descriptonAttrString
			descriptionLabel.textAlignment = NSTextAlignment.center
			descriptionLabel.preferredMaxLayoutWidth = preferredLabelWidth
			descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		}
		
		// Add Subviews
		addSubview(backdropImage)
		addSubview(iconImage)
		addSubview(titleLabel)
		if section.nid != Section.home.rawValue {
			addSubview(descriptionLabel)
		}
		addSubview(backButton)
		addSubview(searchButton)
		
		self.updateConstraints()
		self.layoutIfNeeded()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func collapse() {
		UIView.animate(withDuration: 0.5) {
			self.frame.size.height = Common.Layout.navigationBarMinimizedHeight
			self.backdropImage.alpha = 0.0
			self.iconImage.alpha = 0.0
			self.descriptionLabel.alpha = 0.0
			self.titleLabel.transform = CGAffineTransform(scaleX: CGFloat(self.titleMinimumScale), y: CGFloat(self.titleMinimumScale))
			self.layoutIfNeeded()
		}
	}
	
	func setBackButtonHidden(_ hidden: Bool) {
		backButton.isHidden = hidden
		backButton.isEnabled = !hidden
	}
	
	func updateHeight(contentOffset: CGPoint) {
		var frameHeight = Common.Layout.navigationBarVerticalOffset + (contentOffset.y * -1.0)
		frameHeight = clamp(val: frameHeight, minVal: Common.Layout.navigationBarMinimizedHeight, maxVal: 99999.0)
		var alphaVal = CGFloat(map(val: Double(frameHeight), oldRange1: Double(Common.Layout.navigationBarMinimizedHeight + 50), oldRange2: Double(Common.Layout.navigationBarHeight), newRange1: 0.0, newRange2: 1.0))
		alphaVal = clamp(val: alphaVal, minVal: 0.0, maxVal: 1.0)
		var titleScale = CGFloat(map(val: Double(frameHeight), oldRange1: Double(Common.Layout.navigationBarMinimizedHeight), oldRange2: Double(Common.Layout.navigationBarHeight), newRange1: Double(titleMinimumScale), newRange2: 1.0))
		titleScale = clamp(val: titleScale, minVal: titleMinimumScale, maxVal: 1.0)
		
		self.frame.size.height = frameHeight
		self.backdropImage.alpha = alphaVal
		self.iconImage.alpha = alphaVal
		self.descriptionLabel.alpha = alphaVal
		self.titleLabel.transform = CGAffineTransform(scaleX: titleScale, y: titleScale)
	}
	
	override func updateConstraints() {
		backButton.autoPinEdge(.bottom, to: .top, of: self, withOffset: Common.Layout.navigationBarMinimizedHeight - backButtonBottomMargin)
		backButton.autoPinEdge(.leading, to: .leading, of: self, withOffset: backButtonLeftMargin)
		
		searchButton.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -6)
		searchButton.autoPinEdge(.bottom, to: .top, of: self, withOffset: Common.Layout.navigationBarMinimizedHeight - 3)
		
		if let _ = self.backdropImage.image {
			backdropImage.autoPinEdge(.top, to: .top, of: self)
			backdropImage.autoPinEdge(.leading, to: .leading, of: self)
			backdropImage.autoPinEdge(.trailing, to: .trailing, of: self)
			backdropImage.autoMatch(.height, to: .width, of: backdropImage, withMultiplier: backdropImage.image!.size.height / backdropImage.image!.size.width)
		}
		
		iconImage.autoAlignAxis(.vertical, toSameAxisOf: self)
		iconImage.autoPinEdge(.bottom, to: .top, of: titleLabel, withOffset: -iconBottomMargin)
		iconImage.autoSetDimension(.width, toSize: iconImage.image!.size.width)
		iconImage.autoSetDimension(.height, toSize: iconImage.image!.size.height)
		
		NSLayoutConstraint.autoSetPriority(.defaultLow) {
			titleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: titleTopMargin)
		}
		titleLabel.autoPinEdge(.leading, to: .leading, of: self)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self)
		NSLayoutConstraint.autoSetPriority(.defaultHigh) {
			titleLabel.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -titleBottomMargin, relation: .lessThanOrEqual)
		}
		
		if descriptionLabel.superview != nil {
			descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
			descriptionLabel.autoSetDimensions(to: CGSize(width: 300.0, height: 60.0))
			descriptionLabel.autoAlignAxis(.vertical, toSameAxisOf: self)
		}
		
		super.updateConstraints()
	}
}

extension SectionNavigationBar : SectionViewControllerScrollDelegate {
	func sectionViewControllerDidScroll(scrollView: UIScrollView) {
		updateHeight(contentOffset: scrollView.contentOffset)
	}
	
	func sectionViewControllerWillAppearWithScrollView(scrollView: UIScrollView) {
		UIView.animate(withDuration: 0.5) {
			self.updateHeight(contentOffset: scrollView.contentOffset)
			self.layoutIfNeeded()
		}
	}
}
