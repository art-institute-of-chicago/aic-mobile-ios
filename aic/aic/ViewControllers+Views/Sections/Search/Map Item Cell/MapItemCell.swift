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
	
	@IBOutlet var iconImageView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
}
