//
//  SeeAllEventCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// SeeAllEventCell
///
/// UICollectionViewCell for list of all Events
class SeeAllEventCell : UICollectionViewCell {
	static let reuseIdentifier = "seeAllEventCell"
	
	@IBOutlet var eventImageView: AICImageView!
	@IBOutlet var eventTitleLabel: UILabel!
	@IBOutlet var dividerLine: UIView!
	@IBOutlet var shortDescriptionTextView: UITextView!
	@IBOutlet var monthDayLabel: UILabel!
	@IBOutlet var hoursMinutesLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
		eventTitleLabel.textColor = .aicDarkGrayColor
		eventTitleLabel.numberOfLines = 2
		eventTitleLabel.lineBreakMode = .byTruncatingTail
		dividerLine.backgroundColor = .aicDividerLineColor
		shortDescriptionTextView.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textContainerInset.left = -4
		monthDayLabel.textColor = .aicMediumGrayColor
		hoursMinutesLabel.textColor = .aicMediumGrayColor
	}
	
	var eventModel: AICEventModel? = nil {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}
			
			// set up UI
			eventImageView.loadImageAsynchronously(fromUrl: eventModel.imageUrl, withCropRect: nil)
			eventTitleLabel.text = eventModel.title.stringByDecodingHTMLEntities
			shortDescriptionTextView.text = eventModel.shortDescription.stringByDecodingHTMLEntities
			monthDayLabel.text = Common.Info.monthDayString(date: eventModel.startDate)
			hoursMinutesLabel.text = Common.Info.hoursMinutesString(date: eventModel.startDate)
		}
	}
}
