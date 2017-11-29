//
//  HomeTourCell.swift
//  aic
//
//  Created by Filippo Vanucci on 11/21/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// HomeTourCell
///
/// UICollectionViewCell for list of Tours featured in Homepage
class HomeTourCell : UICollectionViewCell {
	static let reuseIdentifier = "homeTourCell"
	
	@IBOutlet var tourImageView: AICImageView!
	@IBOutlet var tourTitleLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.tourImageView.contentMode = .scaleAspectFill
		self.tourImageView.clipsToBounds = true
	}
	
	var tourModel: AICTourModel? {
		didSet {
			guard let tourModel = self.tourModel else {
				return
			}
			
			// set up UI
			self.tourImageView.loadImageAsynchronously(fromUrl: tourModel.imageUrl, withCropRect: nil)
			self.tourTitleLabel.text = tourModel.title
		}
	}
}
