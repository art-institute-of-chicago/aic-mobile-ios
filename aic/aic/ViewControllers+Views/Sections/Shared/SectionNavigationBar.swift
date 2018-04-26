//
//  SectionNavigationBar.swift
//  aic
//
//  Created by Filippo Vanucci on 11/16/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SectionNavigationBar : UIView {
	let headerView: UIView = UIView()
	let headerAnimatedColorView: UIView = UIView()
	let backdropImageView:UIImageView = UIImageView()
	let backButton: UIButton = UIButton()
	let iconImageView:UIImageView = UIImageView()
	let titleLabel:UILabel = UILabel()
	let descriptionLabel:UILabel = UILabel()
	let searchButton: UIButton = UIButton()
	
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
	private let searchButtonBackgroundAlpha: CGFloat = 0.4
	
	internal let titleString:String
	
	private var isAnimating: Bool = false
	
	enum State {
		case open
		case collapsed
		case hidden
	}
	var currentState: State = .open
	
	init(section: AICSectionModel) {
		titleString = section.title
		super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Common.Layout.navigationBarMinimizedHeight))
		
		self.backgroundColor = .clear
		
		headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Common.Layout.navigationBarHeight)
		headerView.clipsToBounds = true
		headerView.backgroundColor = section.color
		
		headerAnimatedColorView.alpha = 0.0
		headerAnimatedColorView.backgroundColor = .aicMemberCardRedColor
		
		if let _ = section.background {
			self.backdropImageView.image = section.background
		}
		
		backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
		backButton.contentEdgeInsets = backButtonContentInsets
		setBackButtonHidden(true)
		
		iconImageView.image = section.icon
		
		enableParallaxEffect()
		
		titleLabel.numberOfLines = 1
		if section.nid == Section.home.rawValue {
			titleLabel.font = .aicHomeSectionTitleFont
			titleBottomMargin = -1
		}
		else {
			titleLabel.font = .aicSectionTitleFont
		}
		titleLabel.textColor = .white
		titleLabel.textAlignment = NSTextAlignment.center
		titleLabel.lineBreakMode = .byClipping
		titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.minimumScaleFactor = 0.2
		titleLabel.text = section.title
		
		if section.nid == Section.home.rawValue {
			titleTopMargin = 176
			titleMinimumScale = 0.5
		}
		
		if section.nid != Section.home.rawValue {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 6
			let descriptonAttrString = NSMutableAttributedString(string:"")
			descriptonAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, descriptonAttrString.length))
			
			descriptionLabel.numberOfLines = 2
			descriptionLabel.font = .aicSectionDescriptionFont
			descriptionLabel.textColor = .white
			descriptionLabel.attributedText = descriptonAttrString
			descriptionLabel.textAlignment = NSTextAlignment.center
			descriptionLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - margins.right - margins.left
			descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		}
		
		searchButton.setImage(#imageLiteral(resourceName: "iconSearch"), for: .normal)
		searchButton.contentEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6)
		searchButton.backgroundColor = UIColor(white: 0.0, alpha: searchButtonBackgroundAlpha)
		searchButton.layer.cornerRadius = 18
		
		// Add Subviews
		headerView.addSubview(headerAnimatedColorView)
		headerView.addSubview(backdropImageView)
		headerView.addSubview(iconImageView)
		headerView.addSubview(titleLabel)
		if section.nid != Section.home.rawValue {
			headerView.addSubview(descriptionLabel)
		}
		headerView.addSubview(backButton)
		addSubview(headerView)
		addSubview(searchButton)
		
		createConstraints()
		layoutIfNeeded()
		
		// Accessibility
		searchButton.accessibilityLabel = "Search"
		self.accessibilityElements = [
			titleLabel,
			descriptionLabel,
			searchButton
		]
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func collapse() {
		currentState = .collapsed
		self.layer.removeAllAnimations()
		UIView.animate(withDuration: 0.5) {
			self.headerView.frame.size.height = Common.Layout.navigationBarMinimizedHeight
			self.backdropImageView.alpha = 0.0
			self.iconImageView.alpha = 0.0
			self.descriptionLabel.alpha = 0.0
			self.searchButton.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
			self.titleLabel.transform = CGAffineTransform(scaleX: CGFloat(self.titleMinimumScale), y: CGFloat(self.titleMinimumScale))
			self.layoutIfNeeded()
		}
	}
	
	func hide() {
		currentState = .hidden
		self.layer.removeAllAnimations()
		UIView.animate(withDuration: 0.5) {
			self.headerView.frame.size.height = 0
			self.backdropImageView.alpha = 0.0
			self.iconImageView.alpha = 0.0
			self.descriptionLabel.alpha = 0.0
			self.searchButton.backgroundColor = UIColor(white: 0.0, alpha: self.searchButtonBackgroundAlpha)
			self.titleLabel.transform = CGAffineTransform(scaleX: CGFloat(self.titleMinimumScale), y: CGFloat(self.titleMinimumScale))
			self.layoutIfNeeded()
		}
	}
	
	func setBackButtonHidden(_ hidden: Bool) {
		backButton.isHidden = hidden
		backButton.isEnabled = !hidden
		
		// Accessibility
		if hidden {
			self.accessibilityElements = [
				titleLabel,
				descriptionLabel,
				searchButton
			]
		}
		else {
			self.accessibilityElements = [
				backButton,
				titleLabel,
				descriptionLabel,
				searchButton
			]
		}
	}
	
	func updateHeight(contentOffset: CGPoint) {
		var frameHeight = Common.Layout.navigationBarHeight + (contentOffset.y * -1.0)
		frameHeight = clamp(val: frameHeight, minVal: Common.Layout.navigationBarMinimizedHeight, maxVal: 99999.0)
		var alphaVal = CGFloat(map(val: Double(frameHeight), oldRange1: Double(Common.Layout.navigationBarMinimizedHeight + 50), oldRange2: Double(Common.Layout.navigationBarHeight), newRange1: 0.0, newRange2: 1.0))
		alphaVal = clamp(val: alphaVal, minVal: 0.0, maxVal: 1.0)
		var titleScale = CGFloat(map(val: Double(frameHeight), oldRange1: Double(Common.Layout.navigationBarMinimizedHeight), oldRange2: Double(Common.Layout.navigationBarHeight), newRange1: Double(titleMinimumScale), newRange2: 1.0))
		titleScale = clamp(val: titleScale, minVal: titleMinimumScale, maxVal: 1.0)
		
		self.headerView.frame.size.height = frameHeight
		self.backdropImageView.alpha = alphaVal
		self.iconImageView.alpha = alphaVal
		self.descriptionLabel.alpha = alphaVal
		self.searchButton.backgroundColor = UIColor(white: 0.0, alpha: searchButtonBackgroundAlpha * alphaVal)
		self.titleLabel.transform = CGAffineTransform(scaleX: titleScale, y: titleScale)
		
		if frameHeight == Common.Layout.navigationBarMinimizedHeight {
			currentState = .collapsed
		}
		else if frameHeight > Common.Layout.navigationBarMinimizedHeight {
			currentState = .open
		}
		self.layoutIfNeeded()
	}
	
	func createConstraints() {
		headerAnimatedColorView.autoPinEdgesToSuperviewEdges()
		
		backButton.autoPinEdge(.bottom, to: .top, of: headerView, withOffset: Common.Layout.navigationBarMinimizedHeight - backButtonBottomMargin)
		backButton.autoPinEdge(.leading, to: .leading, of: headerView, withOffset: backButtonLeftMargin)
		
		if let _ = self.backdropImageView.image {
			backdropImageView.autoPinEdge(.top, to: .top, of: headerView)
			backdropImageView.autoPinEdge(.leading, to: .leading, of: headerView)
			backdropImageView.autoPinEdge(.trailing, to: .trailing, of: headerView)
			backdropImageView.autoMatch(.height, to: .width, of: backdropImageView, withMultiplier: backdropImageView.image!.size.height / backdropImageView.image!.size.width)
		}
		
		iconImageView.autoAlignAxis(.vertical, toSameAxisOf: headerView)
		iconImageView.autoPinEdge(.bottom, to: .top, of: titleLabel, withOffset: -iconBottomMargin)
		iconImageView.autoSetDimension(.width, toSize: iconImageView.image!.size.width)
		iconImageView.autoSetDimension(.height, toSize: iconImageView.image!.size.height)
		
		NSLayoutConstraint.autoSetPriority(.defaultLow) {
			titleLabel.autoPinEdge(.top, to: .top, of: headerView, withOffset: titleTopMargin)
		}
		titleLabel.autoPinEdge(.leading, to: .leading, of: headerView, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: headerView, withOffset: -16)
		NSLayoutConstraint.autoSetPriority(.defaultHigh) {
			titleLabel.autoPinEdge(.bottom, to: .bottom, of: headerView, withOffset: -titleBottomMargin, relation: .lessThanOrEqual)
		}
		
		if descriptionLabel.superview != nil {
			descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
			descriptionLabel.autoSetDimensions(to: CGSize(width: 300.0, height: 60.0))
			descriptionLabel.autoAlignAxis(.vertical, toSameAxisOf: headerView)
		}
		
		searchButton.autoSetDimensions(to: CGSize(width: 36, height: 36))
		searchButton.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -11)
		searchButton.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -5)
	}
	
	func disableParallaxEffect() {
		backdropImageView.motionEffects.removeAll()
	}
	
	func enableParallaxEffect() {
		addParallexEffect(toView: backdropImageView, left: 0, right: 0, top: -30, bottom: 30)
	}
	
	func startColorAnimation() {
		isAnimating = true
		headerAnimatedColorView.alpha = 0.0
		
		UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn], animations: {
			self.headerAnimatedColorView.alpha = 1.0
		}) { (completedHalf) in
			UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn], animations: {
				self.headerAnimatedColorView.alpha = 0.0
			}) { (completed) in
				if completed && self.isAnimating {
					self.startColorAnimation()
				}
			}
		}
	}
	
	func stopColorAnimation() {
		isAnimating = false
		UIView.animate(withDuration: 0.1) {
			self.headerAnimatedColorView.alpha = 0.0
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
		}
	}
}
