//
//  MapItemCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/11/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// MapItemCell
///
/// MapItemCell for list of Map icons in Search
class MapItemCell : UICollectionViewCell {
	static let reuseIdentifier = "mapItemCell"
	
	@IBOutlet var iconImageView: AICImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.backgroundColor = .aicDarkGrayColor
		
		self.contentView.backgroundColor = .aicDarkGrayColor
		
		iconImageView.backgroundColor = .clear
		iconImageView.contentMode = .scaleAspectFill
		iconImageView.clipsToBounds = true
		iconImageView.layer.cornerRadius = 24
		iconImageView.layer.borderColor = UIColor.white.cgColor
		iconImageView.layer.borderWidth = 1
	}
	
	func setItemIcon(image: UIImage) {
		iconImageView.image = image
	}
}
