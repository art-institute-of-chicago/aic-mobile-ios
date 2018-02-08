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
	@IBOutlet weak var languageSelectorView: LanguageSelectorView!
	
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
			
			languageSelectorView.isHidden = true
			if tourModel.availableLanguages.count > 1 {
				languageSelectorView.isHidden = false
				languageSelectorView.setLanguages(languages: tourModel.availableLanguages, defaultLanguage: tourModel.language)
			}
			
			tourImageView.kf.setImage(with: tourModel.imageUrl)
			descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: tourModel.longDescription.stringByDecodingHTMLEntities, font: .aicCardDescriptionFont, lineHeight: 22)
			descriptionLabel.textColor = .white
		}
	}
}
