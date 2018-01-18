//
//  ArtworkContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 1/17/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class ArtworkContentCell : UITableViewCell {
	static let reuseIdentifier = "artworkContentCell"
	
	@IBOutlet var artworkImageView: AICImageView!
	@IBOutlet var showOnMapButton: AICButton!
	
	@IBOutlet var artworkImageWidth: NSLayoutConstraint!
	@IBOutlet var artworkImageHeight: NSLayoutConstraint!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		artworkImageView.backgroundColor = .clear
		artworkImageView.contentMode = .scaleAspectFit
		artworkImageView.clipsToBounds = true
	}
	
	var objectModel: AICObjectModel? = nil {
		didSet {
			guard let objectModel = self.objectModel else {
				return
			}
			
			// Image
			artworkImageView.kf.setImage(with: objectModel.imageUrl, placeholder: nil, options: nil, progressBlock: nil) { image, error, cacheType, imageURL in
				// calculate image dimension to adjust height of imageview
				if let _ = image {
					let imageAspectRatio = image!.size.width / image!.size.height
					let viewAspectRatio = self.artworkImageWidth.constant / self.artworkImageHeight.constant
					
					if imageAspectRatio > viewAspectRatio {
						self.artworkImageHeight.constant =  self.artworkImageWidth.constant * (image!.size.height / image!.size.width)
						self.setNeedsLayout()
						self.layoutIfNeeded()
					}
				}
			}
			
			
			//setImage(with: objectModel.imageUrl,
			
//			descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: exhibitionModel.longDescription.stringByDecodingHTMLEntities, font: .aicCardDescriptionFont, lineHeight: 22)
//			descriptionLabel.textColor = .white
//			throughDateLabel.text = Common.Info.throughDateString(endDate: exhibitionModel.endDate)
		}
	}
}
