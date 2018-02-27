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
	@IBOutlet weak var transparentOverlayView: UIView!
	@IBOutlet weak var stopsNumberLabel: UILabel!
	@IBOutlet var clockImageView: UIImageView!
	@IBOutlet var durationLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		tourImageView.contentMode = .scaleAspectFill
		tourImageView.clipsToBounds = true
		transparentOverlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
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
			stopsNumberLabel.text = "\(tourModel.stops.count) " + "Stops"
			if (tourModel.durationInMinutes ?? "").isEmpty {
				clockImageView.isHidden = true
				durationLabel.isHidden = true
			}
			else if let duration: String = self.tourModel!.durationInMinutes {
				durationLabel.text = "\(duration)"
			}
		}
	}
}
