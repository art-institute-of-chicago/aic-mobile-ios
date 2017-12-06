//
//  HomeTourCell.swift
//  aic
//
//  Created by Filippo Vanucci on 11/21/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// HomeTourCell
///
/// UICollectionViewCell for list of Tours featured in Homepage
class HomeTourCell : UICollectionViewCell {
	static let reuseIdentifier = "homeTourCell"
	
	@IBOutlet var tourImageView: AICImageView!
	@IBOutlet var tourTitleLabel: UILabel!
	@IBOutlet var shortDescriptionTextView: UITextView!
	@IBOutlet var stopsNumberLabel: UILabel!
	@IBOutlet var clockImageView: UIImageView!
	@IBOutlet var durationLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		tourImageView.contentMode = .scaleAspectFill
		tourImageView.clipsToBounds = true
		tourTitleLabel.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textContainerInset.left = -4
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
				clockImageView.isHidden = true
				durationLabel.isHidden = true
			}
			else if let duration: String = tourModel.durationInMinutes {
				durationLabel.text = "\(duration)min"
			}
		}
	}
}
