//
//  HomeEventCell.swift
//  aic
//
//  Created by Filippo Vanucci on 11/28/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// HomeEventCell
///
/// UICollectionViewCell for list of Events featured in Homepage
class HomeEventCell : UICollectionViewCell {
	static let reuseIdentifier = "homeEventCell"
	
	@IBOutlet var eventImageView: AICImageView!
	@IBOutlet var eventTitleLabel: UILabel!
	@IBOutlet var shortDescriptionTextView: UITextView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.eventImageView.contentMode = .scaleAspectFill
		self.eventImageView.clipsToBounds = true
		self.eventTitleLabel.textColor = .aicDarkGrayColor
		self.shortDescriptionTextView.textColor = .aicDarkGrayColor
	}
	
	var eventModel: AICTourModel? {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}
			
			// set up UI
			self.eventImageView.loadImageAsynchronously(fromUrl: eventModel.imageUrl, withCropRect: nil)
			self.eventTitleLabel.text = eventModel.title
			self.shortDescriptionTextView.text = eventModel.shortDescription
		}
	}
}
