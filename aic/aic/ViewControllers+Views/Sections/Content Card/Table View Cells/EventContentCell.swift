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
    @IBOutlet weak var buttonCaptionTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var transparentOverlayView: UIView!
	@IBOutlet var monthDayLabel: UILabel!
	@IBOutlet var hoursMinutesLabel: UILabel!
	@IBOutlet weak var locationAndDateLabel: UILabelPadding!

	let descriptionVerticalSpacingMin: CGFloat = 32

	override func awakeFromNib() {
		super.awakeFromNib()

		selectionStyle = .none

		self.backgroundColor = .aicDarkGrayColor

		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
		buyTicketsButton.titleLabel?.font = .aicButtonFont
		buyTicketsButton.setIconImage(image: #imageLiteral(resourceName: "buttonTicketIcon"))
        buttonCaptionTextView.setDefaultsForAICAttributedTextView()
        monthDayLabel.font = .aicInfoOverlayFont
		hoursMinutesLabel.font = .aicInfoOverlayFont
		transparentOverlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
		descriptionTextView.setDefaultsForAICAttributedTextView()
		descriptionTextView.linkTextAttributes = [.foregroundColor: UIColor.white, .underlineStyle: NSUnderlineStyle.single.rawValue]
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
				.compactMap { $0 }

			eventImageView.kf.setImage(with: eventModel.imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (result) in
				if let result = try? result.get() {
					self.eventImageView.image = AppDataManager.sharedInstance.getCroppedImageForEvent(image: result.image, viewSize: self.eventImageView.frame.size)
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
			locationAndDateLabel.attributedText = attributedStringWithLineHeight(text: locationAndDateString, font: .aicTextItalicFont, lineHeight: 22)

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
				.replacingOccurrences(of: "</p>", with: "</p>\n\n")
				.replacingOccurrences(of: "<li>", with: "\n<li>•\t")

			let descriptionAttributedString = eventDescription
				.style(tags: emStyle, iStyle, strongStyle, bStyle)
				.styleAll(allStyle)
				.attributedString

			descriptionTextView.attributedText = descriptionAttributedString
			descriptionTextView.textColor = .white

            // Register/Purchase display logic
            let validDate = eventModel.onSaleDate == nil || (eventModel.onSaleDate ?? .distantPast < .now && eventModel.offSaleDate ?? .distantFuture > .now)
            if eventModel.isTicketed && eventModel.isSalesButtonHidden == false && validDate {
                // Show the button
                if let buyTicketsButton = buyTicketsButton {
                    buyTicketsButton.setTitle(eventModel.buttonText, for: .normal)
                    accessibilityItems.append(buyTicketsButton)
                }
            } else {
                // Hide the button
                buyTicketsButton.isEnabled = false
                buyTicketsButton.isHidden = true
            }
            
            // Register caption logic
            if let caption = eventModel.buttonCaption, caption.isEmpty == false {
                let captionAttr = caption.style(tags: emStyle, iStyle, strongStyle, bStyle).styleAll(allStyle).attributedString
                buttonCaptionTextView.attributedText = captionAttr
                buttonCaptionTextView.isHidden = false
                buttonCaptionTextView.textColor = .white
                buttonCaptionTextView.textAlignment = .center
            } else {
                buttonCaptionTextView.isHidden = true
            }

			self.setNeedsLayout()
			self.layoutIfNeeded()

			// Accessibility
			accessibilityItems.append(
				contentsOf: [
					descriptionTextView,
					locationAndDateLabel
					]
					.compactMap { $0 }
			)
			self.accessibilityElements = accessibilityItems
		}
	}
}
