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
	@IBOutlet weak var playAudioButton: AICButton!
	@IBOutlet weak var artistDisplayLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	
	@IBOutlet var artworkImageHeight: NSLayoutConstraint!
	@IBOutlet weak var showOnMapButtonHorizontalOffset: NSLayoutConstraint!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectionStyle = UITableViewCellSelectionStyle.none
		
		self.backgroundColor = .aicDarkGrayColor
		
		artworkImageView.backgroundColor = .clear
		artworkImageView.contentMode = .scaleAspectFit
		artworkImageView.clipsToBounds = true
	}
	
	var artworkModel: AICSearchedArtworkModel? = nil {
		didSet {
			guard let artworkModel = self.artworkModel else {
				return
			}
			
			// Image
			artworkImageView.kf.setImage(with: artworkModel.imageUrl, placeholder: nil, options: nil, progressBlock: nil) { image, error, cacheType, imageURL in
				// calculate image dimension to adjust height of imageview
//				if let _ = image {
//					let imageAspectRatio = image!.size.width / image!.size.height
//					let viewAspectRatio = self.artworkImageView.frame.width / self.artworkImageHeight.constant
//
//					if imageAspectRatio > viewAspectRatio {
//						self.artworkImageHeight.constant =  self.artworkImageView.frame.width * (image!.size.height / image!.size.width)
//						self.setNeedsLayout()
//						self.layoutIfNeeded()
//					}
//				}
			}
			
			artistDisplayLabel.attributedText = getAttributedStringWithLineHeight(text: artworkModel.artistDisplay.stringByDecodingHTMLEntities, font: .aicCardDescriptionFont, lineHeight: 22)
			artistDisplayLabel.textColor = .white
			
			descriptionLabel.text = ""
			
			guard let _ = artworkModel.audioObject else {
				playAudioButton.isHidden = true
				playAudioButton.isEnabled = false
				showOnMapButtonHorizontalOffset.constant = 0
				self.setNeedsLayout()
				self.layoutIfNeeded()
				return
			}
//			throughDateLabel.text = Common.Info.throughDateString(endDate: exhibitionModel.endDate)
		}
	}
}
