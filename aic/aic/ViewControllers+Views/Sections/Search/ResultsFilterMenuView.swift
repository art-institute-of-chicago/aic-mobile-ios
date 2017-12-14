//
//  ResultsFilterMenuView.swift
//  aic
//
//  Created by Filippo Vanucci on 12/13/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import Foundation

protocol FilterMenuDelegate: class {
	func filterMenuSelected(filter: Common.Search.Filter)
}

/// ResultsFilterMenuView
///
/// View for TableView section title in the results page with buttons to filter by content category (Suggested, Artworks, Tours, Exhibitions)
/// Example: 'On the map' section
class ResultsFilterMenuView : UITableViewHeaderFooterView {
	static let reuseIdentifier = "resultsFilterMenuView"
	
	weak var delegate: FilterMenuDelegate? = nil
	
	private let suggestedButton: UIButton = UIButton()
	private let artworksButton: UIButton = UIButton()
	private let toursButton: UIButton = UIButton()
	private let exhibitionsButton: UIButton = UIButton()
	
	static let cellHeight: CGFloat = 55
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		self.contentView.backgroundColor = .aicDarkGrayColor
		
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
		
		self.contentView.addSubview(suggestedButton)
		self.contentView.addSubview(artworksButton)
		self.contentView.addSubview(toursButton)
		self.contentView.addSubview(exhibitionsButton)
		
		createConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func createConstraints() {
		suggestedButton.autoPinEdge(.top, to: .top, of: self, withOffset: 0)
		suggestedButton.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		suggestedButton.autoSetDimension(.height, toSize: 40)
		suggestedButton.autoPinEdge(.trailing, to: .leading, of: artworksButton, withOffset: -22)
		
		artworksButton.autoPinEdge(.top, to: .top, of: self, withOffset: 0)
		artworksButton.autoSetDimension(.height, toSize: 40)
		artworksButton.autoPinEdge(.trailing, to: .leading, of: toursButton, withOffset: -22)
		
		toursButton.autoPinEdge(.top, to: .top, of: self, withOffset: 0)
		toursButton.autoSetDimension(.height, toSize: 40)
		toursButton.autoPinEdge(.trailing, to: .leading, of: exhibitionsButton, withOffset: -22)
		
		exhibitionsButton.autoPinEdge(.top, to: .top, of: self, withOffset: 0)
		exhibitionsButton.autoSetDimension(.height, toSize: 40)
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
		}
		else if button == artworksButton {
			setSelected(filter: .artworks)
			self.delegate?.filterMenuSelected(filter: .artworks)
		}
		else if button == toursButton {
			setSelected(filter: .tours)
			self.delegate?.filterMenuSelected(filter: .tours)
		}
		else if button == exhibitionsButton {
			setSelected(filter: .exhibitions)
			self.delegate?.filterMenuSelected(filter: .exhibitions)
		}
	}
}
