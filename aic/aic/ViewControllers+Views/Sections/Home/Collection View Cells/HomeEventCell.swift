//
//  HomeEventCell.swift
//  aic
//
//  Created by Filippo Vanucci on 11/28/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// HomeEventCell
///
/// UICollectionViewCell for list of Events featured in Homepage
class HomeEventCell : UICollectionViewCell {
	static let reuseIdentifier = "homeEventCell"
	
	@IBOutlet var eventImageView: AICImageView!
	@IBOutlet var eventTitleLabel: UILabel!
	@IBOutlet var shortDescriptionTextView: UITextView!
	@IBOutlet var transparentOverlayView: UIView!
	@IBOutlet var monthDayLabel: UILabel!
	@IBOutlet var hoursMinutesLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
		eventTitleLabel.textColor = .aicDarkGrayColor
		eventTitleLabel.numberOfLines = 0
		eventTitleLabel.lineBreakMode = .byTruncatingTail
		shortDescriptionTextView.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textContainerInset.left = -4
		shortDescriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
		transparentOverlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
	}
	
	var eventModel: AICEventModel? {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}
			
			// set up UI
			eventImageView.kf.setImage(with: eventModel.imageUrl)
//			eventImageView.loadImageAsynchronously(fromUrl: eventModel.imageUrl, withCropRect: nil)
			eventTitleLabel.text = eventModel.title.stringByDecodingHTMLEntities
			shortDescriptionTextView.text = eventModel.shortDescription.stringByDecodingHTMLEntities
			monthDayLabel.text = Common.Info.monthDayString(date: eventModel.startDate)
			hoursMinutesLabel.text = Common.Info.hoursMinutesString(date: eventModel.startDate)
		}
	}
}
