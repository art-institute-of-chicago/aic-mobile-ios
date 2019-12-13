//
//  ArtworkContentCell.swift
//  aic
//
//  Created by Filippo Vanucci on 1/17/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class ArtworkContentCell: UITableViewCell {
	static let reuseIdentifier = "artworkContentCell"

	@IBOutlet var artworkImageView: AICImageView!
	@IBOutlet var showOnMapButton: AICButton!
	@IBOutlet weak var playAudioButton: AICButton!
	@IBOutlet weak var artistDisplayLabel: UILabelPadding!
	@IBOutlet weak var descriptionLabel: UILabel!

	@IBOutlet var artworkImageHeight: NSLayoutConstraint!
	@IBOutlet weak var showOnMapButtonHorizontalOffset: NSLayoutConstraint!

	override func awakeFromNib() {
		super.awakeFromNib()

		selectionStyle = .none

		self.backgroundColor = .aicDarkGrayColor

		artworkImageView.backgroundColor = .clear
		artworkImageView.contentMode = .scaleAspectFit
		artworkImageView.clipsToBounds = true
		showOnMapButton.setIconImage(image: #imageLiteral(resourceName: "buttonMapIcon"))
		playAudioButton.setIconImage(image: #imageLiteral(resourceName: "buttonPlayIcon"))
		showOnMapButton.titleLabel?.font = .aicButtonFont
		playAudioButton.titleLabel?.font = .aicButtonFont
		artistDisplayLabel.font = .aicTextFont
		descriptionLabel.font = .aicTextFont
	}

	var artworkModel: AICSearchedArtworkModel? = nil {
		didSet {
			guard let artworkModel = self.artworkModel else {
				return
			}

			var accessibilityItems: [Any] = [
				showOnMapButton
			]

			// Image
			artworkImageView.kf.indicatorType = .activity
			artworkImageView.kf.setImage(with: artworkModel.imageUrl, placeholder: nil, options: nil, progressBlock: nil) { _, _, _, _ in
				// calculate image dimension to adjust height of imageview
//				if let _ = image {
//					let imageAspectRatio = image!.size.width / image!.size.height
//					let viewAspectRatio = self.artworkImageView.frame.width / self.artworkImageHeight.constant
//
//					if imageAspectRatio > viewAspectRatio {
//						UIView.animate(withDuration: 0.3, animations: {
//							self.artworkImageHeight.constant =  self.artworkImageView.frame.width * (image!.size.height / image!.size.width)
//							self.setNeedsLayout()
//							self.layoutIfNeeded()
//							self.layoutSubviews()
//						})
//					}
//				}
			}

			artistDisplayLabel.attributedText = getAttributedStringWithLineHeight(text: artworkModel.artistDisplay, font: .aicTextFont, lineHeight: 22)
			artistDisplayLabel.textColor = .white
			artistDisplayLabel.font = .aicTextFont

			descriptionLabel.text = ""
			descriptionLabel.font = .aicTextFont

			if let _ = artworkModel.audioObject {
				accessibilityItems.append(playAudioButton)
			} else {
				playAudioButton.isHidden = true
				playAudioButton.isEnabled = false
				showOnMapButtonHorizontalOffset.constant = 0
				self.setNeedsLayout()
				self.layoutIfNeeded()
			}

			// Accessibility
			accessibilityItems.append(artistDisplayLabel)
			accessibilityItems.append(descriptionLabel)
			self.accessibilityElements = accessibilityItems
		}
	}
}
