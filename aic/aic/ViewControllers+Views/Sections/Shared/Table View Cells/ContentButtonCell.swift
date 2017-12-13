//
//  ContentButtonCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// ContentButtonCell
///
/// UITableViewCell for list of Tour Stops or content results in Search
class ContentButtonCell : UITableViewCell {
	static let reuseIdentifier = "contentButtonCell"
	
	@IBOutlet var itemImageView: AICImageView!
	@IBOutlet var itemTitleLabel: UILabel!
	@IBOutlet var itemSubtitleLabel: UILabel!
	@IBOutlet var dividerLineTop: UIView!
	@IBOutlet var dividerLineBottom: UIView!
	
	var contentLoaded: Bool = false
	
	static let cellHeight: CGFloat = 72.0
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		itemImageView.contentMode = .scaleAspectFill
		itemImageView.clipsToBounds = true
		itemTitleLabel.textColor = .white
		itemSubtitleLabel.textColor = .aicCardDarkTextColor
		dividerLineTop.backgroundColor = .aicDividerLineDarkColor
		dividerLineBottom.backgroundColor = .aicDividerLineDarkColor
	}
	
	func setContent(imageUrl: URL, title: String, subtitle: String) {
		// TODO: cache and don't load unless necessary
//		if contentLoaded == true {
//			return
//		}
		
		itemImageView.loadImageAsynchronously(fromUrl: imageUrl, withCropRect: nil)
		itemTitleLabel.text = title
		itemSubtitleLabel.text = subtitle
		
		contentLoaded = true
	}
}

