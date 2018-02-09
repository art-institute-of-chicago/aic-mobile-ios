//
//  ExhibitionContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 1/17/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Kingfisher

protocol ExhibitionContentCellDelegate : class {
	func exhibitionBuyTicketsButtonPressed(url: URL)
}

class ExhibitionContentCell : UITableViewCell {
	static let reuseIdentifier = "exhibitionContentCell"
	
	@IBOutlet var exhibitionImageView: AICImageView!
	@IBOutlet var showOnMapButton: UIButton!
	@IBOutlet var buyTicketsButton: UIButton!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var throughDateLabel: UILabel!
	
	@IBOutlet weak var showOnMapButtonHorizontalOffset: NSLayoutConstraint!
	@IBOutlet weak var buyTicketsButtonHorizontalOffset: NSLayoutConstraint!
	@IBOutlet weak var descriptionToImageVerticalSpacing: NSLayoutConstraint!
	let descriptionVerticalSpacingMin: CGFloat = 32
	
	weak var delegate: ExhibitionContentCellDelegate? = nil
	
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
			
			// TODO: temporary fix for missing image
			if let _ = exhibitionModel.imageUrl {
				exhibitionImageView.kf.setImage(with: exhibitionModel.imageUrl)
			}
			else {
				let imageUrl = URL(string: "http://aic-mobile-tours.artic.edu/sites/default/files/object-images/AIC_ImagePlaceholder_25.png")!
				exhibitionImageView.kf.setImage(with: imageUrl)
			}
			
			descriptionLabel.attributedText = getAttributedStringWithLineHeight(text: exhibitionModel.shortDescription.stringByDecodingHTMLEntities, font: .aicCardDescriptionFont, lineHeight: 22)
			descriptionLabel.textColor = .white
			throughDateLabel.text = Common.Info.throughDateString(endDate: exhibitionModel.endDate)
			
			var hasLocation = exhibitionModel.location != nil
			var hasWebUrl =  exhibitionModel.webUrl != nil
			
			let now = Date()
			let isOnView = exhibitionModel.startDate < now && exhibitionModel.endDate > now
			if !isOnView {
				hasWebUrl = false
				hasLocation = false
			}
			
			if !hasLocation {
				showOnMapButton.isHidden = true
				showOnMapButton.isEnabled = false
				buyTicketsButtonHorizontalOffset.constant = 0
			}
			
			if !hasWebUrl {
				buyTicketsButton.isHidden = true
				buyTicketsButton.isEnabled = false
				showOnMapButtonHorizontalOffset.constant = 0
			}
			else {
				buyTicketsButton.addTarget(self, action: #selector(buyTicketsButtonPressed(button:)), for: .touchUpInside)
			}
			
			if !hasWebUrl && !hasLocation {
				descriptionToImageVerticalSpacing.constant = descriptionVerticalSpacingMin
			}
			
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}
	}
	
	@objc func buyTicketsButtonPressed(button: UIButton) {
		self.delegate?.exhibitionBuyTicketsButtonPressed(url: exhibitionModel!.webUrl!)
	}
}
