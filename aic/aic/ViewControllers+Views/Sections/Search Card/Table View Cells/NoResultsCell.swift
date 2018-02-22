//
//  NoResultsCell.swift
//  aic
//
//  Created by Filippo Vanucci on 2/21/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Kingfisher

/// NoResultsCell
///
/// UITableViewCell for list of Tour Stops or content results in Search
class NoResultsCell : UITableViewCell {
	static let reuseIdentifier = "noResultsCell"
	
	@IBOutlet weak var noResultsLabel: UILabel!
	
	var contentLoaded: Bool = false
	
	static let cellHeight: CGFloat = 90.0
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		noResultsLabel.numberOfLines = 0
		noResultsLabel.lineBreakMode = .byWordWrapping
		noResultsLabel.textColor = .aicCardDarkTextColor
	}
}
