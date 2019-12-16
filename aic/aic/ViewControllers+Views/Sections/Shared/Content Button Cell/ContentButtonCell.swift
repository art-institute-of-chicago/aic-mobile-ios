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
class ContentButtonCell: UITableViewCell {
	static let reuseIdentifier = "contentButtonCell"

	@IBOutlet var itemImageView: AICImageView!
	@IBOutlet var itemTitleLabel: UILabel!
	@IBOutlet var itemSubtitleLabel: UILabel!
	@IBOutlet var dividerLineTop: UIView!
	@IBOutlet var dividerLineBottom: UIView!
	@IBOutlet weak var audioIcon: UIImageView!

	static let cellHeight: CGFloat = 72.0

	var imageUrl: URL?

	override func awakeFromNib() {
		super.awakeFromNib()

		selectionStyle = .none

		self.backgroundColor = .aicDarkGrayColor

		itemImageView.contentMode = .scaleAspectFill
		itemImageView.clipsToBounds = true
		itemTitleLabel.font = .aicContentButtonTitleFont
		itemTitleLabel.textColor = .white
		itemSubtitleLabel.font = .aicContentButtonSubtitleFont
		itemSubtitleLabel.textColor = .aicCardDarkTextColor
		dividerLineTop.backgroundColor = .aicDividerLineDarkColor
		dividerLineBottom.backgroundColor = .aicDividerLineDarkColor
		audioIcon.isHidden = true
	}

	func setContent(imageUrl: URL?, cropRect: CGRect?, title: String, subtitle: String, showAudioIcon: Bool = false) {
		if title == itemTitleLabel.text && subtitle == itemSubtitleLabel.text && self.imageUrl == imageUrl {
			return
		}

		// Load image only if URL is not nil
		self.imageUrl = imageUrl
		if let url = imageUrl {
			itemImageView.kf.indicatorType = .activity
			itemImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
				if image != nil {
					if cropRect != nil {
						self.itemImageView.image = AppDataManager.sharedInstance.getCroppedImage(image: image!, viewSize: self.itemImageView.frame.size, cropRect: cropRect!)
					}
				}
			})
		}
			// Otherwise show placeholder image
		else {
			itemImageView.image = #imageLiteral(resourceName: "artworkPlaceholder")
		}

		itemTitleLabel.text = title
		itemSubtitleLabel.text = subtitle

		audioIcon.isHidden = !showAudioIcon

		// Accessibility
		self.isAccessibilityElement = true
		self.accessibilityLabel = ""
		self.accessibilityValue = itemTitleLabel.text! + ", " + itemSubtitleLabel.text!
		self.accessibilityTraits = .button
	}
}
