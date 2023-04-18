//
//  ResultsFilterMenuView.swift
//  aic
//
//  Created by Filippo Vanucci on 12/13/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol FilterMenuDelegate: AnyObject {
	func filterMenuSelected(filter: Common.Search.Filter)
}

/// ResultsFilterMenuView
///
/// View for filter buttons by content category (Suggested, Artworks, Tours, Exhibitions)
class ResultsFilterMenuView: UIView {
	private let scrollView: UIScrollView = UIScrollView()
	let suggestedButton: UIButton = UIButton()
	let artworksButton: UIButton = UIButton()
	let toursButton: UIButton = UIButton()
	let exhibitionsButton: UIButton = UIButton()

	static let menuHeight: CGFloat = 45

	weak var delegate: FilterMenuDelegate?

	init() {
		super.init(frame: CGRect.zero)

		self.backgroundColor = .aicDarkGrayColor

		scrollView.backgroundColor = .clear
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

		suggestedButton.setTitle("Suggested", for: .normal)
		suggestedButton.titleLabel?.font = .aicSearchResultsFilterFont
		suggestedButton.setTitleColor(.aicCardDarkTextColor, for: .normal)
		suggestedButton.setTitleColor(.white, for: .selected)
		suggestedButton.backgroundColor = .clear

		artworksButton.setTitle("Artworks", for: .normal)
		artworksButton.titleLabel?.font = .aicSearchResultsFilterFont
		artworksButton.setTitleColor(.aicCardDarkTextColor, for: .normal)
		artworksButton.setTitleColor(.white, for: .selected)
		artworksButton.backgroundColor = .clear

		toursButton.setTitle("Tours", for: .normal)
		toursButton.titleLabel?.font = .aicSearchResultsFilterFont
		toursButton.setTitleColor(.aicCardDarkTextColor, for: .normal)
		toursButton.setTitleColor(.white, for: .selected)
		toursButton.backgroundColor = .clear

		exhibitionsButton.setTitle("Exhibitions", for: .normal)
		exhibitionsButton.titleLabel?.font = .aicSearchResultsFilterFont
		exhibitionsButton.setTitleColor(.aicCardDarkTextColor, for: .normal)
		exhibitionsButton.setTitleColor(.white, for: .selected)
		exhibitionsButton.backgroundColor = .clear

		suggestedButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
		artworksButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
		toursButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
		exhibitionsButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)

		self.addSubview(scrollView)
		scrollView.addSubview(suggestedButton)
		scrollView.addSubview(artworksButton)
		scrollView.addSubview(toursButton)
		scrollView.addSubview(exhibitionsButton)

		createConstraints()

		self.layoutIfNeeded()
		scrollView.contentSize.width = exhibitionsButton.frame.origin.x + exhibitionsButton.frame.width
		scrollView.contentSize.height = self.frame.height

		// Accessibility
		suggestedButton.accessibilityLabel = "Filter results by"
		suggestedButton.accessibilityValue = "Suggested"
		artworksButton.accessibilityLabel = "Filter results by"
		artworksButton.accessibilityValue = "Artworks"
		toursButton.accessibilityLabel = "Filter results by"
		toursButton.accessibilityValue = "Tours"
		exhibitionsButton.accessibilityLabel = "Filter results by"
		exhibitionsButton.accessibilityValue = "Exhibitions"
		self.accessibilityElements = [
			suggestedButton,
			artworksButton,
			toursButton,
			exhibitionsButton
		]
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func createConstraints() {
		scrollView.autoPinEdgesToSuperviewEdges()

		suggestedButton.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 0)
		suggestedButton.autoPinEdge(.leading, to: .leading, of: scrollView)
		suggestedButton.autoSetDimension(.height, toSize: 40)
		suggestedButton.autoPinEdge(.trailing, to: .leading, of: artworksButton, withOffset: -22)

		artworksButton.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 0)
		artworksButton.autoSetDimension(.height, toSize: 40)
		artworksButton.autoPinEdge(.trailing, to: .leading, of: toursButton, withOffset: -22)

		toursButton.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 0)
		toursButton.autoSetDimension(.height, toSize: 40)
		toursButton.autoPinEdge(.trailing, to: .leading, of: exhibitionsButton, withOffset: -22)

		exhibitionsButton.autoPinEdge(.top, to: .top, of: scrollView, withOffset: 0)
		exhibitionsButton.autoSetDimension(.height, toSize: 40)
	}

	override func updateConstraints() {
		super.updateConstraints()

		scrollView.contentSize.width = exhibitionsButton.frame.origin.x + exhibitionsButton.frame.width
		scrollView.contentSize.height = self.frame.height
	}

	func setSelected(filter: Common.Search.Filter) {
		suggestedButton.isSelected = filter == .suggested
		artworksButton.isSelected = filter == .artworks
		toursButton.isSelected = filter == .tours
		exhibitionsButton.isSelected = filter == .exhibitions
	}

	@objc func buttonPressed(button: UIButton) {
		if button == suggestedButton {
			setSelected(filter: .suggested)
			self.delegate?.filterMenuSelected(filter: .suggested)
		} else if button == artworksButton {
			setSelected(filter: .artworks)
			self.delegate?.filterMenuSelected(filter: .artworks)
		} else if button == toursButton {
			setSelected(filter: .tours)
			self.delegate?.filterMenuSelected(filter: .tours)
		} else if button == exhibitionsButton {
			setSelected(filter: .exhibitions)
			self.delegate?.filterMenuSelected(filter: .exhibitions)
		}
	}
}
