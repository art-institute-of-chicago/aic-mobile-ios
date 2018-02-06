//
//  SectionNavigationBar.swift
//  aic
//
//  Created by Filippo Vanucci on 11/16/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SectionNavigationBar : UIView {
	let backdropImageView:UIImageView = UIImageView()
	let backButton: UIButton = UIButton()
	let iconImageView:UIImageView = UIImageView()
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
			self.backdropImageView.image = section.background
		}
		
		backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
		backButton.contentEdgeInsets = backButtonContentInsets
		setBackButtonHidden(true)
		
		iconImageView.image = section.icon
        
        addParallexEffect(toView: backdropImageView, left: 0, right: 0, top: -30, bottom: 30)
		
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
		
		if section.nid == Section.home.rawValue {
			titleTopMargin = 176
			titleMinimumScale = 0.5
		}
		
		if section.nid != Section.home.rawValue {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 6
			let descriptonAttrString = NSMutableAttributedString(string: section.description)
			descriptonAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, descriptonAttrString.length))
			
			let preferredLabelWidth = UIScreen.main.bounds.width - margins.right - margins.left
			
			descriptionLabel.numberOfLines = 2
			descriptionLabel.font = .aicSectionDescriptionFont
			descriptionLabel.textColor = .white
			descriptionLabel.attributedText = descriptonAttrString
			descriptionLabel.textAlignment = NSTextAlignment.center
			descriptionLabel.preferredMaxLayoutWidth = preferredLabelWidth
			descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		}
		
		// Add Subviews
		addSubview(backdropImageView)
		addSubview(iconImageView)
		addSubview(titleLabel)
		if section.nid != Section.home.rawValue {
			addSubview(descriptionLabel)
		}
		addSubview(backButton)
		
		createConstraints()
		layoutIfNeeded()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func collapse() {
		UIView.animate(withDuration: 0.5) {
			self.frame.size.height = Common.Layout.navigationBarMinimizedHeight
			self.backdropImageView.alpha = 0.0
			self.iconImageView.alpha = 0.0
			self.descriptionLabel.alpha = 0.0
			self.titleLabel.transform = CGAffineTransform(scaleX: CGFloat(self.titleMinimumScale), y: CGFloat(self.titleMinimumScale))
			self.layoutIfNeeded()
		}
	}
	
	func hide() {
		UIView.animate(withDuration: 0.5) {
			self.frame.size.height = 0
			self.backdropImageView.alpha = 0.0
			self.iconImageView.alpha = 0.0
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
		self.backdropImageView.alpha = alphaVal
		self.iconImageView.alpha = alphaVal
		self.descriptionLabel.alpha = alphaVal
		self.titleLabel.transform = CGAffineTransform(scaleX: titleScale, y: titleScale)
	}
	
	func createConstraints() {
		backButton.autoPinEdge(.bottom, to: .top, of: self, withOffset: Common.Layout.navigationBarMinimizedHeight - backButtonBottomMargin)
		backButton.autoPinEdge(.leading, to: .leading, of: self, withOffset: backButtonLeftMargin)
		
		if let _ = self.backdropImageView.image {
			backdropImageView.autoPinEdge(.top, to: .top, of: self)
			backdropImageView.autoPinEdge(.leading, to: .leading, of: self)
			backdropImageView.autoPinEdge(.trailing, to: .trailing, of: self)
			backdropImageView.autoMatch(.height, to: .width, of: backdropImageView, withMultiplier: backdropImageView.image!.size.height / backdropImageView.image!.size.width)
		}
		
		iconImageView.autoAlignAxis(.vertical, toSameAxisOf: self)
		iconImageView.autoPinEdge(.bottom, to: .top, of: titleLabel, withOffset: -iconBottomMargin)
		iconImageView.autoSetDimension(.width, toSize: iconImageView.image!.size.width)
		iconImageView.autoSetDimension(.height, toSize: iconImageView.image!.size.height)
		
		NSLayoutConstraint.autoSetPriority(.defaultLow) {
			titleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: titleTopMargin)
		}
		titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 0)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: 0)
		NSLayoutConstraint.autoSetPriority(.defaultHigh) {
			titleLabel.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -titleBottomMargin, relation: .lessThanOrEqual)
		}
		
		if descriptionLabel.superview != nil {
			descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
			descriptionLabel.autoSetDimensions(to: CGSize(width: 300.0, height: 60.0))
			descriptionLabel.autoAlignAxis(.vertical, toSameAxisOf: self)
		}
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
