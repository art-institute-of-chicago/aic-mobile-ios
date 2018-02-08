//
//  TourContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Kingfisher

class TourContentCell : UITableViewCell {
	static let reuseIdentifier = "tourContentCell"
	
	@IBOutlet var tourImageView: AICImageView!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var startTourButton: AICButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		tourImageView.contentMode = .scaleAspectFill
		tourImageView.clipsToBounds = true
	}
	
	var tourModel: AICTourModel? = nil {
		didSet {
			guard let tourModel = self.tourModel else {
				return
			}
			
			var tourTranslationModel = tourModel.translations[.english]!
			if let translation: AICTourTranslationModel = tourModel.translations[Common.currentLanguage] {
				tourTranslationModel = translation
			}
			
			tourImageView.kf.setImage(with: tourModel.imageUrl)
			descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: tourTranslationModel.longDescription.stringByDecodingHTMLEntities, font: .aicCardDescriptionFont, lineHeight: 22)
			descriptionLabel.textColor = .white
		}
	}
}
