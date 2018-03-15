//
//  SeeAllExhibitionCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// SeeAllExhibitionCell
///
/// UICollectionViewCell for list of all Exhibitions

class SeeAllExhibitionCell : UICollectionViewCell {
	static let reuseIdentifier = "seeAllExhibitionCell"
	
	@IBOutlet var exhibitionImageView: AICImageView!
	@IBOutlet var exhibitionTitleLabel: UILabel!
	@IBOutlet var throughDateLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		exhibitionImageView.contentMode = .scaleAspectFill
		exhibitionImageView.clipsToBounds = true
		exhibitionTitleLabel.textColor = .aicDarkGrayColor
		exhibitionTitleLabel.numberOfLines = 0
		exhibitionTitleLabel.lineBreakMode = .byWordWrapping
		throughDateLabel.textColor = .aicDarkGrayColor
		throughDateLabel.numberOfLines = 1
	}
	
	var exhibitionModel: AICExhibitionModel? = nil {
		didSet {
			guard let exhibitionModel = self.exhibitionModel else {
				return
			}
			
			// set up UI
			exhibitionImageView.kf.setImage(with: exhibitionModel.imageUrl)
			exhibitionTitleLabel.text = exhibitionModel.title
			throughDateLabel.text = Common.Info.throughDateString(endDate: exhibitionModel.endDate)
		}
	}
}
