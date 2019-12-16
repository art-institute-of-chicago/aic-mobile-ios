//
//  SeeAllTourCell.swift
//  aic
//
//  Created by Filippo Vanucci on 11/30/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

/// SeeAllTourCell
///
/// UICollectionViewCell for list of all Tours
class SeeAllTourCell: UICollectionViewCell {
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
		stopsNumberLabel.font = .aicSeeAllInfoFont
		stopsNumberLabel.textColor = .aicMediumGrayColor
		durationLabel.font = .aicSeeAllInfoFont
		durationLabel.textColor = .aicMediumGrayColor
		tourTitleLabel.font = .aicSeeAllTitleFont
		tourTitleLabel.textColor = .aicDarkGrayColor
		tourTitleLabel.numberOfLines = 2
		tourTitleLabel.lineBreakMode = .byTruncatingTail
		dividerLine.backgroundColor = .aicDividerLineColor
		shortDescriptionTextView.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textContainerInset.left = -4
		shortDescriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
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
			shortDescriptionTextView.attributedText = getAttributedStringWithLineHeight(text: self.tourModel!.shortDescription, font: .aicTextFont, lineHeight: 20)
			stopsNumberLabel.text = "\(tourModel.stops.count) " + "Stops".localized(using: "Home")

			if (self.tourModel!.durationInMinutes ?? "").isEmpty {
				durationLabel.isHidden = true
			} else if let duration: String = self.tourModel!.durationInMinutes {
				durationLabel.text = "\(duration)"
			}

			// Accessibility
			self.isAccessibilityElement = true
			self.accessibilityLabel = "Tour"
			var accessValue = tourTitleLabel.text!
			accessValue += ", "
			accessValue += stopsNumberLabel.text!
			if durationLabel.text != nil { accessValue += ", " + durationLabel.text! }
			accessValue += ", "
			accessValue += shortDescriptionTextView.text!
			self.accessibilityValue = accessValue
			self.accessibilityTraits = .button
		}
	}
}
