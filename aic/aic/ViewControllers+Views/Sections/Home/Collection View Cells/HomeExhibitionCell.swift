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
	@IBOutlet var throughDateTextView: UITextView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		exhibitionImageView.contentMode = .scaleAspectFill
		exhibitionImageView.clipsToBounds = true
		exhibitionTitleLabel.textColor = .aicDarkGrayColor
		exhibitionTitleLabel.numberOfLines = 0
		exhibitionTitleLabel.lineBreakMode = .byTruncatingTail
		throughDateTextView.textColor = .aicDarkGrayColor
		throughDateTextView.textContainerInset.left = -4
	}
	
	var exhibitionModel: AICExhibitionModel? {
		didSet {
			guard let exhibitionModel = self.exhibitionModel else {
				return
			}
			
			// set up UI
			exhibitionImageView.loadImageAsynchronously(fromUrl: exhibitionModel.imageUrl, withCropRect: nil)
			exhibitionTitleLabel.text = exhibitionModel.title
			throughDateTextView.text = Common.Info.throughDateString(endDate: exhibitionModel.endDate)
		}
	}
}

