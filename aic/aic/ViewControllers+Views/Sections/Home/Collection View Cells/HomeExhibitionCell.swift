//
//  HomeExhibitionCell.swift
//  
//
//  Created by Filippo Vanucci on 11/28/17.
//

import UIKit

/// HomeExhibitionCell
///
/// UICollectionViewCell for list of Exhibitions featured in Homepage
class HomeExhibitionCell : UICollectionViewCell {
	static let reuseIdentifier = "homeExhibitionCell"
	
	@IBOutlet var exhibitionImageView: AICImageView!
	@IBOutlet var exhibitionTitleLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.exhibitionImageView.contentMode = .scaleAspectFill
		self.exhibitionImageView.clipsToBounds = true
	}
	
	var exhibitionModel: AICTourModel? {
		didSet {
			guard let exhibitionModel = self.exhibitionModel else {
				return
			}
			
			// set up UI
			self.exhibitionImageView.loadImageAsynchronously(fromUrl: exhibitionModel.imageUrl, withCropRect: nil)
			self.exhibitionTitleLabel.text = exhibitionModel.title
		}
	}
}

