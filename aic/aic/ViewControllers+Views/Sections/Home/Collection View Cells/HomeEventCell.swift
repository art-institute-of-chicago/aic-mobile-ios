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
		
		eventImageView.contentMode = .scaleAspectFill
		eventImageView.clipsToBounds = true
		eventTitleLabel.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textColor = .aicDarkGrayColor
		shortDescriptionTextView.textContainerInset.left = -4
	}
	
	var eventModel: AICTourModel? {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}
			
			// set up UI
			eventImageView.loadImageAsynchronously(fromUrl: eventModel.imageUrl, withCropRect: nil)
			eventTitleLabel.text = eventModel.title
			shortDescriptionTextView.text = eventModel.shortDescription
		}
	}
}
