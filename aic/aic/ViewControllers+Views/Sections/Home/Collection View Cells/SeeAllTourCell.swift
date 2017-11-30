//
//  SeeAllTourCell.swift
//  aic
//
//  Created by Filippo Vanucci on 11/30/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// SeeAllTourCell
///
/// UICollectionViewCell for list of all Tours
class SeeAllTourCell : UICollectionViewCell {
	static let reuseIdentifier = "seeAllTourCell"
	
	@IBOutlet var tourImageView: AICImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		tourImageView.contentMode = .scaleAspectFill
		tourImageView.clipsToBounds = true
	}
	
	var tourModel: AICTourModel? = nil {
		didSet {
			guard let tourModel = self.tourModel else {
				return
			}
			
			// set up UI
			tourImageView.loadImageAsynchronously(fromUrl: tourModel.imageUrl, withCropRect: nil)
		}
	}
}
