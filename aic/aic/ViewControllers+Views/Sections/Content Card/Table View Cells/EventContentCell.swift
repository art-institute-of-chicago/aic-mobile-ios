//
//  EventContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 1/25/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class EventContentCell : UITableViewCell {
	static let reuseIdentifier = "eventContentCell"
	
	@IBOutlet var eventImageView: AICImageView!
	@IBOutlet var descriptionLabel: UILabel!
//	@IBOutlet var buyTicketsButton: AICButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
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
		}
	}
}
