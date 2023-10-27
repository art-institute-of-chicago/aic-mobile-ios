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
	@IBOutlet weak var galleryTitleLabel: UILabel!
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

			artworkImageView.kf.indicatorType = .activity
            artworkImageView.kf.setImage(with: artworkModel.imageUrl) { _ in }

            artistDisplayLabel.attributedText = attributedStringWithLineHeight(
                text: artworkModel.artistDisplay,
                font: .aicTextFont,
                lineHeight: 22
            )
			artistDisplayLabel.textColor = .white
			artistDisplayLabel.font = .aicTextFont

			galleryTitleLabel.text = artworkModel.gallery.title
			galleryTitleLabel.textColor = .white
			galleryTitleLabel.font = .aicTextItalicFont

			descriptionLabel.text = ""
			descriptionLabel.font = .aicTextFont

            var accessibilityItems: [Any] = [showOnMapButton].compactMap { $0 }

			if let _ = artworkModel.audioObject, let playAudioButton = playAudioButton {
				accessibilityItems.append(playAudioButton)
			} else {
				playAudioButton.isHidden = true
				playAudioButton.isEnabled = false
				showOnMapButtonHorizontalOffset.constant = 0
				self.setNeedsLayout()
				self.layoutIfNeeded()
			}

			// Accessibility
            let accessibilityContents = [
                artistDisplayLabel,
                galleryTitleLabel,
                descriptionLabel
            ].compactMap { $0 }
            
			accessibilityItems.append(contentsOf: accessibilityContents)
			self.accessibilityElements = accessibilityItems
		}
	}
}
