//
//  ResultsSuggestedSectionTitleCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// View for TableView section title in the results page
/// Example: 'On the map' section
class ResultsSectionTitleView : UIView {
	
	let titleLabel: UILabel = UILabel()

	init(title: String) {
		super.init(frame: CGRect.zero)
		
		self.backgroundColor = .aicDarkGrayColor

		titleLabel.text = title
		titleLabel.font = .aicSearchResultsSectionTitleFont
		titleLabel.textColor = .aicCardDarkTextColor
		titleLabel.numberOfLines = 0
		
		addSubview(titleLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateConstraints() {
		titleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: 5)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		titleLabel.autoPinEdge(.bottom, to: .bottom, of: self, withOffset: -10, relation: .greaterThanOrEqual)
		
		super.updateConstraints()
	}
}
