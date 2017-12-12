//
//  SuggestedSearchCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// Cell of ResultsTableViewController to show suggested search text
/// Example: 'On the map' section
class SuggestedSearchCell : UITableViewCell {
	static let reuseIdentifier = "suggestedSearchCell"
	
	static let cellHeight: CGFloat = 40.0
	
	@IBOutlet var suggestedSearchLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		layoutMargins = UIEdgeInsets.zero
		
		self.backgroundColor = .aicDarkGrayColor
		
		suggestedSearchLabel.textColor = .white
	}
	
	var suggestedText: String = "" {
		didSet {
			suggestedSearchLabel.text = suggestedText
		}
	}
}
