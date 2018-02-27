//
//  EventContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 1/25/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

protocol EventContentCellDelegate : class {
	func eventBuyTicketsButtonPressed(url: URL)
}

class EventContentCell : UITableViewCell {
	static let reuseIdentifier = "eventContentCell"
	
	@IBOutlet var eventImageView: AICImageView!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet weak var buyTicketsButton: AICButton!
	@IBOutlet weak var transparentOverlayView: UIView!
	@IBOutlet var monthDayLabel: UILabel!
	@IBOutlet var hoursMinutesLabel: UILabel!
	
	@IBOutlet weak var descriptionToImageVerticalSpacing: NSLayoutConstraint!
	let descriptionVerticalSpacingMin: CGFloat = 32
	
	weak var delegate: EventContentCellDelegate? = nil
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
		transparentOverlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
	}
	
	var eventModel: AICEventModel? = nil {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}
			
			eventImageView.kf.setImage(with: eventModel.imageUrl)
			
			let descriptionText = eventModel.longDescription.replacingOccurrences(of: "<br />", with: "\n")
			descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: descriptionText.stringByDecodingHTMLEntities, font: .aicCardDescriptionFont, lineHeight: 22)
			descriptionLabel.textColor = .white
			monthDayLabel.text = Common.Info.monthDayString(date: eventModel.startDate)
			hoursMinutesLabel.text = Common.Info.hoursMinutesString(date: eventModel.startDate)
			
			if eventModel.eventUrl == nil {
				buyTicketsButton.isEnabled = false
				buyTicketsButton.isHidden = true
				descriptionToImageVerticalSpacing.constant = descriptionVerticalSpacingMin
			}
			else {
				buyTicketsButton.setTitle(eventModel.buttonText, for: .normal)
				buyTicketsButton.addTarget(self, action: #selector(buyTicketsButtonPressed(button:)), for: .touchUpInside)
			}
			
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}
	}
	
	@objc func buyTicketsButtonPressed(button: UIButton) {
		self.delegate?.eventBuyTicketsButtonPressed(url: eventModel!.eventUrl!)
	}
}
