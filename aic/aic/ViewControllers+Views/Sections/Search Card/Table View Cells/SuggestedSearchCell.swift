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
class SuggestedSearchCell: UITableViewCell {
	static let reuseIdentifier = "suggestedSearchCell"

	static let cellHeight: CGFloat = 40.0

	@IBOutlet var suggestedSearchLabel: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()

		selectionStyle = .none
		layoutMargins = UIEdgeInsets.zero

		self.backgroundColor = .aicDarkGrayColor

		suggestedSearchLabel.font = .aicPageTextFont
		suggestedSearchLabel.textColor = .white
	}

	func setSuggestedText(text: String, color: UIColor) {
		suggestedSearchLabel.text = text
		suggestedSearchLabel.textColor = color

		// Accessibility
		self.isAccessibilityElement = true
		self.accessibilityLabel = "Search for"
		self.accessibilityValue = text
		self.accessibilityTraits = .button
	}

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		if highlighted == true {
			self.alpha = 0.75
		} else {
			self.alpha = 1.0
		}
	}
}
