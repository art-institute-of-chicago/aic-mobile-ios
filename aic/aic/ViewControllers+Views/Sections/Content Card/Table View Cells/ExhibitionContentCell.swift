//
//  ExhibitionContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 1/17/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Kingfisher
import Atributika

class ExhibitionContentCell: UITableViewCell {
	static let reuseIdentifier = "exhibitionContentCell"

	@IBOutlet var exhibitionImageView: AICImageView!
	@IBOutlet var showOnMapButton: AICButton!
	@IBOutlet var buyTicketsButton: AICButton!
	@IBOutlet var descriptionLabel: UILabelPadding!
	@IBOutlet var throughDateLabel: UILabel!

	@IBOutlet weak var showOnMapButtonHorizontalOffset: NSLayoutConstraint!
	@IBOutlet weak var buyTicketsButtonHorizontalOffset: NSLayoutConstraint!
	@IBOutlet weak var descriptionToImageVerticalSpacing: NSLayoutConstraint!
	let descriptionVerticalSpacingMin: CGFloat = 32

	override func awakeFromNib() {
		super.awakeFromNib()

		selectionStyle = .none

		self.backgroundColor = .aicDarkGrayColor

		exhibitionImageView.contentMode = .scaleAspectFill
		exhibitionImageView.clipsToBounds = true
		showOnMapButton.setIconImage(image: #imageLiteral(resourceName: "buttonMapIcon"))
		buyTicketsButton.setIconImage(image: #imageLiteral(resourceName: "buttonTicketIcon"))
		showOnMapButton.titleLabel?.font = .aicButtonFont
		buyTicketsButton.titleLabel?.font = .aicButtonFont
		descriptionLabel.font = .aicTextFont
		throughDateLabel.font = .aicTextItalicFont
	}

	var exhibitionModel: AICExhibitionModel? = nil {
		didSet {
			guard let exhibitionModel = self.exhibitionModel else {
				return
			}

			var accessibilityItems: [Any] = []

			// TODO: temporary fix for missing image
			exhibitionImageView.kf.indicatorType = .activity
			if let _ = exhibitionModel.imageUrl {
				exhibitionImageView.kf.setImage(with: exhibitionModel.imageUrl)
			} else {
				let imageUrl = URL(string: "https://aic-mobile-tours.artic.edu/sites/default/files/object-images/AIC_ImagePlaceholder_25.png")!
				exhibitionImageView.kf.setImage(with: imageUrl)
			}

			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 0.0
			paragraphStyle.minimumLineHeight = 22
			paragraphStyle.maximumLineHeight = 22

			let emStyle = Style("em").font(.aicTextItalicFont)
			let iStyle = Style("i").font(.aicTextItalicFont)
			let strongStyle = Style("strong").font(.aicTextBoldFont)
			let bStyle = Style("b").font(.aicTextBoldFont)
			let allStyle = Style.font(.aicTextFont).baselineOffset(22.0 - Float(UIFont.aicTitleFont.pointSize)).paragraphStyle(paragraphStyle)

			let exhibitionDescription = exhibitionModel.shortDescription
				.replacingOccurrences(of: "</p>", with: "</p>\n")
				.replacingOccurrences(of: "<li>", with: "<li>•\t")

			let eventDescriptionAttributedString = exhibitionDescription
				.style(tags: emStyle, iStyle, strongStyle, bStyle)
				.styleAll(allStyle)
				.attributedString

			descriptionLabel.attributedText =  eventDescriptionAttributedString
			descriptionLabel.textColor = .white
			throughDateLabel.text = Common.Info.throughDateString(endDate: exhibitionModel.endDate)

			if exhibitionModel.location == nil {
				showOnMapButton.isHidden = true
				showOnMapButton.isEnabled = false
				buyTicketsButtonHorizontalOffset.constant = 0
			} else if let showOnMapButton = showOnMapButton {
				accessibilityItems.append(showOnMapButton)
			}

			self.setNeedsLayout()
			self.layoutIfNeeded()

			// Accessibility
			accessibilityItems
				.append(
					contentsOf: [
						buyTicketsButton,
						descriptionLabel,
						throughDateLabel
						]
						.compactMap { $0 }
			)
			self.accessibilityElements = accessibilityItems
		}
	}
}
