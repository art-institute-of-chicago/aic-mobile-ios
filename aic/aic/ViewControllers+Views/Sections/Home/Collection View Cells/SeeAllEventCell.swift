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
//	@IBOutlet var tourTitleLabel: UILabel!
//	@IBOutlet var dividerLine: UIView!
//	@IBOutlet var shortDescriptionTextView: UITextView!
//	@IBOutlet var stopsNumberLabel: UILabel!
//	@IBOutlet var durationLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
//		tourTitleLabel.textColor = .aicDarkGrayColor
//	//		tourTitleLabel.lineBreakMode = .byWordWrapping
//	//		tourTitleLabel.numberOfLines = 0
//		dividerLine.backgroundColor = .aicDividerLineColor
//		shortDescriptionTextView.textColor = .aicDarkGrayColor
//		shortDescriptionTextView.textContainerInset.left = -4
//		stopsNumberLabel.textColor = .aicMediumGrayColor
//		durationLabel.textColor = .aicMediumGrayColor
	}
	
	var eventModel: AICEventModel? = nil {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}
			
			// set up UI
			eventImageView.loadImageAsynchronously(fromUrl: eventModel.imageUrl, withCropRect: nil)
//			tourTitleLabel.text = tourModel.title.stringByDecodingHTMLEntities
//			shortDescriptionTextView.text = tourModel.shortDescription.stringByDecodingHTMLEntities
//			stopsNumberLabel.text = "\(tourModel.stops.count) Stops"
//
//			if (tourModel.durationInMinutes ?? "").isEmpty {
//				durationLabel.isHidden = true
//			}
//			else if let duration: String = tourModel.durationInMinutes {
//				durationLabel.text = "\(duration)min"
//			}
		}
	}
}
