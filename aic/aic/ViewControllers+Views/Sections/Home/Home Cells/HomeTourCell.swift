//
//  HomeTourCell.swift
//  aic
//
//  Created by Filippo Vanucci on 11/21/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

/// HomeTourCell
///
/// UICollectionViewCell for list of Tours featured in Homepage
class HomeTourCell : UICollectionViewCell {
	static let reuseIdentifier = "homeTourCell"
	
	@IBOutlet var tourImageView: AICImageView!
	@IBOutlet var tourTitleLabel: UILabel!
	@IBOutlet var shortDescriptionTextView: UITextView!
	@IBOutlet var transparentOverlayView: UIView!
	@IBOutlet var stopsNumberLabel: UILabel!
	@IBOutlet var clockImageView: UIImageView!
	@IBOutlet var durationLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		tourImageView.contentMode = .scaleAspectFill
		tourImageView.clipsToBounds = true
		stopsNumberLabel.font = .aicInfoOverlayFont
		durationLabel.font = .aicInfoOverlayFont
		tourTitleLabel.textColor = .aicDarkGrayColor
		tourTitleLabel.numberOfLines = 0
		tourTitleLabel.lineBreakMode = .byTruncatingTail
		shortDescriptionTextView.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textContainerInset.left = -4
		shortDescriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
		transparentOverlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
	}
	
	var tourModel: AICTourModel? = nil {
		didSet {
			guard let tourModel = self.tourModel else {
				return
			}
			
			if let _ = tourModel.translations[Common.currentLanguage] {
				self.tourModel!.language = Common.currentLanguage
			}
			
			// set up UI
			tourImageView.kf.setImage(with: tourModel.imageUrl)
			tourTitleLabel.text = self.tourModel!.title
			shortDescriptionTextView.text = self.tourModel!.shortDescription
			stopsNumberLabel.text = "\(self.tourModel!.stops.count) " + "Stops".localized(using: "Home")
			if (tourModel.durationInMinutes ?? "").isEmpty {
				clockImageView.isHidden = true
				durationLabel.isHidden = true
			}
			else if let duration: String = self.tourModel!.durationInMinutes {
				durationLabel.text = "\(duration)"
			}
		}
	}
}
