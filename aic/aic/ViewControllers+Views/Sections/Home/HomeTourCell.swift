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
	
	@IBOutlet var tourImage: AICImageView!
	@IBOutlet var tourTitle: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	var tourModel: AICTourModel? {
		didSet {
			guard let tourModel = self.tourModel else {
				return
			}
			
			// set up UI
			self.tourImage.loadImageAsynchronously(fromUrl: tourModel.imageUrl, withCropRect: nil)
			self.tourTitle.text = tourModel.title
		}
	}
}
