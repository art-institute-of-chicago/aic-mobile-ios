//
//  ResultsSuggestedSectionTitleCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// ResultsSectionTitleView
///
/// View for TableView section title in the results page
/// Example: 'On the map' section
class ResultsSectionTitleView : UITableViewHeaderFooterView {
	static let reuseIdentifier = "resultsSectionTitleView"
	
	let titleLabel: UILabel = UILabel()
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		self.contentView.backgroundColor = .aicDarkGrayColor
		
		titleLabel.font = .aicSearchResultsSectionTitleFont
		titleLabel.textColor = .aicCardDarkTextColor
		titleLabel.numberOfLines = 0
		
		self.contentView.addSubview(titleLabel)
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
