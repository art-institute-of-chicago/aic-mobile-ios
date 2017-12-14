//
//  SeeAllTourCell.swift
//  aic
//
//  Created by Filippo Vanucci on 11/30/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// SeeAllTourCell
///
/// UICollectionViewCell for list of all Tours
class SeeAllTourCell : UICollectionViewCell {
	static let reuseIdentifier = "seeAllTourCell"
	
	@IBOutlet var tourImageView: AICImageView!
	@IBOutlet var tourTitleLabel: UILabel!
	@IBOutlet var dividerLine: UIView!
	@IBOutlet var shortDescriptionTextView: UITextView!
	@IBOutlet var stopsNumberLabel: UILabel!
	@IBOutlet var durationLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		tourImageView.contentMode = .scaleAspectFill
		tourImageView.clipsToBounds = true
		tourTitleLabel.textColor = .aicDarkGrayColor
		tourTitleLabel.numberOfLines = 2
		tourTitleLabel.lineBreakMode = .byTruncatingTail
		dividerLine.backgroundColor = .aicDividerLineColor
		shortDescriptionTextView.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textContainerInset.left = -4
		shortDescriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
		stopsNumberLabel.textColor = .aicMediumGrayColor
		durationLabel.textColor = .aicMediumGrayColor
	}
	
	var tourModel: AICTourModel? = nil {
		didSet {
			guard let tourModel = self.tourModel else {
				return
			}
			
			// set up UI
			tourImageView.loadImageAsynchronously(fromUrl: tourModel.imageUrl, withCropRect: nil)
			tourTitleLabel.text = tourModel.title.stringByDecodingHTMLEntities
			shortDescriptionTextView.text = tourModel.shortDescription.stringByDecodingHTMLEntities
			stopsNumberLabel.text = "\(tourModel.stops.count) Stops"
			
			if (tourModel.durationInMinutes ?? "").isEmpty {
				durationLabel.isHidden = true
			}
			else if let duration: String = tourModel.durationInMinutes {
				durationLabel.text = "\(duration)min"
			}
		}
	}
}
