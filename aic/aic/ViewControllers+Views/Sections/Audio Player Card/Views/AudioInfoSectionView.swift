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

class AudioInfoSectionView: UIView {
	let topDividerLine: UIView = UIView()
	let titleLabel: UILabel = UILabel()
	let tapArea: UIView = UIView()
	let bodyTextView: LinkedTextView = LinkedTextView()
	let collapseExpandButton: UIButton = UIButton()

	weak var delegate: AudioInfoSectionViewDelegate?

	let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()

	private let collapsedHeight: CGFloat = 64
	private let collapseAnimationDuration = 0.5

	var infoSectionHeight: NSLayoutConstraint?

	init() {
		super.init(frame: CGRect.zero)

		self.translatesAutoresizingMaskIntoConstraints = false
		self.clipsToBounds = true

		tapArea.backgroundColor = .clear

		topDividerLine.backgroundColor = .aicDividerLineDarkColor

		titleLabel.numberOfLines = 1
		titleLabel.textColor = .white
		titleLabel.font = .aicAudioInfoSectionTitleFont

		collapseExpandButton.setImage(#imageLiteral(resourceName: "collapseExpand"), for: .normal)
		collapseExpandButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		collapseExpandButton.addTarget(self, action: #selector(collapseButtonPressed(button:)), for: .touchUpInside)
		collapseExpandButton.isEnabled = false
		collapseExpandButton.isHidden = true
		collapseExpandButton.isSelected = false

		bodyTextView.setDefaultsForAICAttributedTextView()

		// tap to expand/collapse
		tapGesture.isEnabled = false
		tapGesture.addTarget(self, action: #selector(handleTapGesture(recognizer:)))
		tapArea.addGestureRecognizer(tapGesture)

		// Add Subviews
		addSubview(tapArea)
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

		// Accessibility
		self.accessibilityElementsHidden = true
	}

	func show(collapseEnabled: Bool) {
		isHidden = false
		tapGesture.isEnabled = collapseEnabled
		collapseExpandButton.isEnabled = collapseEnabled
		collapseExpandButton.isHidden = !collapseEnabled
		collapseExpandButton.isSelected = false
		collapseExpandButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
		if collapseEnabled == true {
			infoSectionHeight?.constant = collapsedHeight
			bodyTextView.alpha = 0
		} else {
			infoSectionHeight?.constant = bodyTextView.frame.origin.y + bodyTextView.frame.height + 32
			bodyTextView.alpha = 1
		}
		self.setNeedsLayout()
		self.layoutIfNeeded()

		// Accessibility
		self.accessibilityElementsHidden = false
		if collapseEnabled {
			self.accessibilityElements = [
				tapArea
			]

			tapArea.isAccessibilityElement = true
			tapArea.accessibilityLabel = titleLabel.text!
			tapArea.accessibilityValue = "Expand"
			tapArea.accessibilityTraits = .button
		} else {
			self.accessibilityElements = [
				titleLabel,
				bodyTextView
			]
		}
	}

	func set(relatedTours tours: [AICTourModel]) {
		let toursAttributedString: NSMutableAttributedString = NSMutableAttributedString()

		var linksCount: Int = 0
		for tour in tours {
			var linkText = tour.title
			if tour.nid != tours.last?.nid {
				linkText += "\n"
			}

			if let urlString = Common.DeepLinks.getURL(forTour: tour) {
				if let url = URL(string: urlString) {
					let linkAttrString = NSMutableAttributedString(string: linkText)

					let range = NSRange(location: 0, length: linkAttrString.string.count)
					linkAttrString.addAttributes([.link: url], range: range)

					toursAttributedString.append(linkAttrString)
					linksCount += 1
				}
			}
		}

		// Add spacing between tours
		let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
		paragraphStyle.paragraphSpacing = 14.0
		let range = NSRange(location: 0, length: toursAttributedString.length)
		toursAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)

		if linksCount > 0 {
			titleLabel.text = "Related Tours".localized(using: "AudioPlayer")

			bodyTextView.attributedText = toursAttributedString
			bodyTextView.linkTextAttributes = [.foregroundColor: UIColor.aicHomeLightColor]
			bodyTextView.font = .aicTitleFont

			infoSectionHeight?.constant = bodyTextView.frame.origin.y + bodyTextView.frame.height + 40
			self.setNeedsLayout()
			self.layoutIfNeeded()
		} else {
			hide()
		}
	}

	// MARK: Constraints

	func createConstraints() {
		tapArea.autoPinEdge(.top, to: .top, of: self)
		tapArea.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		tapArea.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		tapArea.autoSetDimension(.height, toSize: collapsedHeight)

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
				self.collapseExpandButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
				self.infoSectionHeight?.constant = self.collapsedHeight
				self.delegate?.audioInfoSectionDidUpdateHeight(audioInfoSectionView: self)
			})

			// Accessibility
			tapArea.accessibilityValue = "Expand"
			self.accessibilityElements = [
				tapArea
			]
		} else {
			UIView.animate(withDuration: collapseAnimationDuration, animations: {
				self.bodyTextView.alpha = 1
				self.collapseExpandButton.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi * 2.0))
				self.infoSectionHeight?.constant = self.bodyTextView.frame.origin.y + self.bodyTextView.frame.height + 32
				self.delegate?.audioInfoSectionDidUpdateHeight(audioInfoSectionView: self)
			})

			// Accessibility
			tapArea.accessibilityValue = "Collapse"
			self.accessibilityElements = [
				tapArea,
				bodyTextView
			]
			bodyTextView.becomeFirstResponder()
		}

		button.isSelected = !button.isSelected
	}

	@objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
		self.collapseButtonPressed(button: collapseExpandButton)
	}
}
