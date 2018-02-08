//
//  ExhibitionContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 1/17/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Kingfisher

class ExhibitionContentCell : UITableViewCell {
	static let reuseIdentifier = "exhibitionContentCell"
	
	@IBOutlet var exhibitionImageView: AICImageView!
	@IBOutlet var showOnMapButton: UIButton!
	@IBOutlet var buyTicketsButton: UIButton!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var throughDateLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		exhibitionImageView.contentMode = .scaleAspectFill
		exhibitionImageView.clipsToBounds = true
	}
	
	var exhibitionModel: AICExhibitionModel? = nil {
		didSet {
			guard let exhibitionModel = self.exhibitionModel else {
				return
			}
			
			exhibitionImageView.kf.setImage(with: exhibitionModel.imageUrl)
			descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: exhibitionModel.shortDescription.stringByDecodingHTMLEntities, font: .aicCardDescriptionFont, lineHeight: 22)
			descriptionLabel.textColor = .white
			throughDateLabel.text = Common.Info.throughDateString(endDate: exhibitionModel.endDate)
		}
	}
}
