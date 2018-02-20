//
//  ContentButtonCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Kingfisher

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
	@IBOutlet weak var audioIcon: UIImageView!
	
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
		audioIcon.isHidden = true
	}
	
	func setContent(imageUrl: URL?, title: String, subtitle: String, showAudioIcon: Bool = false) {
		// TODO: cache and don't load unless necessary
//		if contentLoaded == true {
//			return
//		}
		
		// Load image only if URL is not nil
		if let url = imageUrl {
			itemImageView.kf.setImage(with: url)
		}
		// Otherwise show placeholder image
		else {
			itemImageView.image = #imageLiteral(resourceName: "artworkPlaceholder")
		}
		
		itemTitleLabel.text = title
		itemSubtitleLabel.text = subtitle
		
		audioIcon.isHidden = !showAudioIcon
		
		contentLoaded = true
	}
}

