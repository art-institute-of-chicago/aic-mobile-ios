//
//  EventContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 1/25/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Atributika

class EventContentCell: UITableViewCell {
	static let reuseIdentifier = "eventContentCell"

	@IBOutlet var eventImageView: AICImageView!
	@IBOutlet weak var buyTicketsButton: AICButton!
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var transparentOverlayView: UIView!
	@IBOutlet var monthDayLabel: UILabel!
	@IBOutlet var hoursMinutesLabel: UILabel!
	@IBOutlet weak var locationAndDateLabel: UILabelPadding!

	@IBOutlet weak var descriptionToImageVerticalSpacing: NSLayoutConstraint!
	let descriptionVerticalSpacingMin: CGFloat = 32

	override func awakeFromNib() {
		super.awakeFromNib()

		selectionStyle = .none

		self.backgroundColor = .aicDarkGrayColor

		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
		buyTicketsButton.titleLabel?.font = .aicButtonFont
		buyTicketsButton.setIconImage(image: #imageLiteral(resourceName: "buttonTicketIcon"))
		monthDayLabel.font = .aicInfoOverlayFont
		hoursMinutesLabel.font = .aicInfoOverlayFont
		transparentOverlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
		descriptionTextView.setDefaultsForAICAttributedTextView()
		descriptionTextView.linkTextAttributes = [.foregroundColor: UIColor.white, .underlineStyle: NSUnderlineStyle.single]
		locationAndDateLabel.numberOfLines = 2
	}

	var eventModel: AICEventModel? = nil {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}

			var accessibilityItems: [Any] = [
				monthDayLabel,
				hoursMinutesLabel
			]

			eventImageView.kf.setImage(with: eventModel.imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (image, _, _, _) in
				if image != nil {
					self.eventImageView.image = AppDataManager.sharedInstance.getCroppedImageForEvent(image: image!, viewSize: self.eventImageView.frame.size)
				}
			}

			let monthDayString = Common.Info.monthDayString(date: eventModel.startDate)
			let hoursMinutesString = Common.Info.hoursMinutesString(date: eventModel.startDate)
			var locationAndDateString = monthDayString
			locationAndDateString += ", "
			locationAndDateString += hoursMinutesString
			locationAndDateString += "\n"
			locationAndDateString += eventModel.locationText

			monthDayLabel.text = monthDayString
			hoursMinutesLabel.text = hoursMinutesString
			descriptionTextView.textColor = .white
			locationAndDateLabel.attributedText = getAttributedStringWithLineHeight(text: locationAndDateString, font: .aicTextItalicFont, lineHeight: 22)

			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 0.0
			paragraphStyle.minimumLineHeight = 22
			paragraphStyle.maximumLineHeight = 22

			let emStyle = Style("em").font(.aicTextItalicFont)
			let iStyle = Style("i").font(.aicTextItalicFont)
			let strongStyle = Style("strong").font(.aicTextBoldFont)
			let bStyle = Style("b").font(.aicTextBoldFont)
			let allStyle = Style.font(.aicTextFont).baselineOffset(22.0 - Float(UIFont.aicTitleFont.pointSize)).paragraphStyle(paragraphStyle)

			let eventDescription = eventModel.longDescription
				.replacingOccurrences(of: "</p>", with: "</p>\n")
				.replacingOccurrences(of: "<li>", with: "\n<li>•\t")

			let descriptionAttributedString = eventDescription
				.style(tags: emStyle, iStyle, strongStyle, bStyle)
				.styleAll(allStyle)
				.attributedString

			descriptionTextView.attributedText = descriptionAttributedString
			descriptionTextView.textColor = .white

			if eventModel.eventUrl == nil {
				buyTicketsButton.isEnabled = false
				buyTicketsButton.isHidden = true
				descriptionToImageVerticalSpacing.constant = descriptionVerticalSpacingMin
			} else {
				buyTicketsButton.setTitle(eventModel.buttonText, for: .normal)

				accessibilityItems.append(buyTicketsButton)
			}

			self.setNeedsLayout()
			self.layoutIfNeeded()

			// Accessibility
			accessibilityItems.append(descriptionTextView)
			accessibilityItems.append(locationAndDateLabel)
			self.accessibilityElements = accessibilityItems
		}
	}
}
