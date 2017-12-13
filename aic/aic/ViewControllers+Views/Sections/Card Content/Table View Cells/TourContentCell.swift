//
//  TourContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class TourContentCell : UITableViewCell {
	static let reuseIdentifier = "tourContentCell"
	
	@IBOutlet var tourImageView: AICImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		layoutMargins = UIEdgeInsets.zero
		clipsToBounds = false
		
		self.backgroundColor = .aicDarkGrayColor
		
		tourImageView.contentMode = .scaleAspectFill
		tourImageView.clipsToBounds = true
	}
	
	var tourModel: AICTourModel? = nil {
		didSet {
			guard let tourModel = self.tourModel else {
				return
			}
			
			tourImageView.loadImageAsynchronously(fromUrl: tourModel.imageUrl, withCropRect: nil)
			
		}
	}
}
