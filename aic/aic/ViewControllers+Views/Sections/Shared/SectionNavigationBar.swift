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
	let iconImage:UIImageView = UIImageView()
	let titleLabel:UILabel = UILabel()
	let descriptionLabel:UILabel = UILabel()
	
	private let margins = UIEdgeInsetsMake(40, 30, 30, 30)
	
	private let backButtonBottomMargin: CGFloat = 1
	private let backButtonLeftMargin: CGFloat = 3
	private let backButtonContentInsets: UIEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
	private let iconTopMargin: CGFloat = 40
	private let titleHeight: CGFloat = 40
	private let titleTopMargin: CGFloat = 95
	private let titleBottomMargin: CGFloat = 5
	private let titleMinimumScale: CGFloat = 0.7
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
		
		iconImage.image = section.icon
		
		let preferredLabelWidth = UIScreen.main.bounds.width - margins.right - margins.left
		
		titleLabel.numberOfLines = 0
		titleLabel.font = .aicHeaderFont
		titleLabel.textColor = .white
		titleLabel.textAlignment = NSTextAlignment.center
		titleLabel.text = section.title
		titleLabel.preferredMaxLayoutWidth = preferredLabelWidth
		
		descriptionLabel.numberOfLines = 0
		descriptionLabel.font = .aicSystemTextFont
		descriptionLabel.textColor = .white
		descriptionLabel.textAlignment = NSTextAlignment.center
		descriptionLabel.text = section.description
		descriptionLabel.preferredMaxLayoutWidth = preferredLabelWidth
		descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		
		// Add Subviews
		addSubview(backdropImage)
		addSubview(iconImage)
		addSubview(titleLabel)
		addSubview(descriptionLabel)
		addSubview(backButton)
		
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
		var alphaVal = CGFloat(map(val: Double(frameHeight), oldRange1: Double(Common.Layout.navigationBarMinimizedHeight), oldRange2: Double(Common.Layout.navigationBarHeight), newRange1: 0.0, newRange2: 1.0))
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
		
		if let _ = self.backdropImage.image {
			backdropImage.autoPinEdge(.top, to: .top, of: self)
			backdropImage.autoPinEdge(.leading, to: .leading, of: self)
			backdropImage.autoPinEdge(.trailing, to: .trailing, of: self)
			backdropImage.autoMatch(.height, to: .width, of: backdropImage, withMultiplier: backdropImage.image!.size.height / backdropImage.image!.size.width)
		}
		
		iconImage.autoAlignAxis(.vertical, toSameAxisOf: self)
		iconImage.autoPinEdge(.top, to: .top, of: self, withOffset: iconTopMargin)
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
