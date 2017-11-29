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
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.eventImageView.contentMode = .scaleAspectFill
		self.eventImageView.clipsToBounds = true
	}
	
	var eventModel: AICTourModel? {
		didSet {
			guard let eventModel = self.eventModel else {
				return
			}
			
			// set up UI
			self.eventImageView.loadImageAsynchronously(fromUrl: eventModel.imageUrl, withCropRect: nil)
			self.eventTitleLabel.text = eventModel.title
		}
	}
}
