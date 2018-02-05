//
//  AudioPlayerContentSection.swift
//  aic
//
//  Created by Filippo Vanucci on 2/4/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol AudioInfoSectionViewDelegate: class {
	func audioInfoSectionDidUpdateHeight(audioInfoSectionView: AudioInfoSectionView)
}

class AudioInfoSectionView : UIView {
	let topDividerLine: UIView = UIView()
	let titleLabel: UILabel = UILabel()
	let bodyTextView: LinkedTextView = LinkedTextView()
	let collapseExpandButton: UIButton = UIButton()
	
	weak var delegate: AudioInfoSectionViewDelegate? = nil
	
	private let collapsedHeight: CGFloat = 64
	private let collapseAnimationDuration = 0.5
	
	var infoSectionHeight: NSLayoutConstraint? = nil
	
	init() {
		super.init(frame:CGRect.zero)
		
		self.translatesAutoresizingMaskIntoConstraints = false
		self.clipsToBounds = true
		
		topDividerLine.backgroundColor = .aicDividerLineDarkColor
		
		titleLabel.numberOfLines = 1
		titleLabel.textColor = .white
		titleLabel.font = .aicAudioInfoSectionTitleFont
		
		collapseExpandButton.setImage(#imageLiteral(resourceName: "audioInfoExpand"), for: .normal)
		collapseExpandButton.setImage(#imageLiteral(resourceName: "audioInfoCollapse"), for: .selected)
		collapseExpandButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		collapseExpandButton.addTarget(self, action: #selector(collapseButtonPressed(button:)), for: .touchUpInside)
		collapseExpandButton.isEnabled = false
		collapseExpandButton.isHidden = true
		
		bodyTextView.textColor = .white
		bodyTextView.font = .aicCardDescriptionFont
		bodyTextView.setDefaultsForAICAttributedTextView()
		
		// Add Subviews
		addSubview(topDividerLine)
		addSubview(titleLabel)
		addSubview(collapseExpandButton)
		addSubview(bodyTextView)
		
		createConstraints()
		
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Actions
	
	func hide() {
		isHidden = true
		infoSectionHeight?.constant = 0
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
	
	func show(collapseEnabled: Bool) {
		isHidden = false
		if collapseEnabled == true {
			infoSectionHeight?.constant = collapsedHeight
			collapseExpandButton.isEnabled = true
			collapseExpandButton.isHidden = false
			bodyTextView.alpha = 0
		}
		else {
			infoSectionHeight?.constant = bodyTextView.frame.origin.y + bodyTextView.frame.height + 32
			collapseExpandButton.isEnabled = false
			collapseExpandButton.isHidden = true
			bodyTextView.alpha = 1
		}
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
	
	func set(relatedTours tours:[AICTourModel]) {
		let links:NSMutableAttributedString = NSMutableAttributedString()
		
		for tour in tours {
			var linkText = tour.title
			if tour.nid != tours.last?.nid {
				linkText += "\n"
			}
			
			let url = Common.DeepLinks.getURL(forTour: tour)
			let linkAttrString = NSMutableAttributedString(string: linkText)
			
			let range = NSMakeRange(0, linkAttrString.string.count)
			linkAttrString.addAttributes([NSAttributedStringKey.link : url], range: range)
			
			links.append(linkAttrString)
		}
		
		bodyTextView.attributedText = links
		bodyTextView.font = .aicCardDescriptionFont
	}
	
	// MARK: Constraints
	
	func createConstraints() {
		topDividerLine.autoPinEdge(.top, to: .top, of: self)
		topDividerLine.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		topDividerLine.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		topDividerLine.autoSetDimension(.height, toSize: 1)
		
		titleLabel.autoPinEdge(.top, to: .bottom, of: topDividerLine, withOffset: 16)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		
		collapseExpandButton.autoSetDimension(.width, toSize: 40.0)
		collapseExpandButton.autoSetDimension(.height, toSize: 40.0)
		collapseExpandButton.autoPinEdge(.top, to: .bottom, of: topDividerLine, withOffset: 8)
		collapseExpandButton.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -8)
		
		bodyTextView.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16)
		bodyTextView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		bodyTextView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		
		NSLayoutConstraint.autoSetPriority(.defaultHigh) {
			infoSectionHeight = self.autoSetDimension(.height, toSize: bodyTextView.frame.origin.y + bodyTextView.frame.height + 40)
		}
	}
	
	// MARK: Collapse Button
	
	@objc internal func collapseButtonPressed(button: UIButton) {
		if button.isSelected {
			UIView.animate(withDuration: collapseAnimationDuration, animations: {
				self.bodyTextView.alpha = 0
				self.infoSectionHeight?.constant = self.collapsedHeight
				self.delegate?.audioInfoSectionDidUpdateHeight(audioInfoSectionView: self)
			})
		} else {
			UIView.animate(withDuration: collapseAnimationDuration, animations: {
				self.bodyTextView.alpha = 1
				self.infoSectionHeight?.constant = self.bodyTextView.frame.origin.y + self.bodyTextView.frame.height + 32
				self.delegate?.audioInfoSectionDidUpdateHeight(audioInfoSectionView: self)
			})
		}
		
		button.isSelected = !button.isSelected
	}
}
