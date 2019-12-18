//
//  MapArtworkContentView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/18/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MapArtworkContentView: UIView {
	private let imageView: UIImageView = UIImageView()
	private let titleLabel: UILabel = UILabel()
	private let locationLabel: UILabel = UILabel()
	let audioButton: UIButton = UIButton()
	let imageButton: UIButton = UIButton()

	private let frameSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedContentHeight - Common.Layout.miniAudioPlayerHeight)

	init(artwork: AICObjectModel) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		setup()

		titleLabel.text = artwork.title
		imageView.kf.indicatorType = .activity
		imageView.kf.setImage(with: artwork.thumbnailUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
			if let result = try? result.get() {
				if let cropRect = artwork.imageCropRect {
					self.imageView.image = AppDataManager.sharedInstance.getCroppedImage(image: result.image, viewSize: self.imageView.frame.size, cropRect: cropRect)
				}
			}
		})
		locationLabel.text = artwork.gallery.title

		setupAccessibility()
	}

	init(searchedArtwork: AICSearchedArtworkModel) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		setup()

		if let object = searchedArtwork.audioObject {
			titleLabel.text = object.title
			imageView.kf.indicatorType = .activity
			imageView.kf.setImage(with: object.thumbnailUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
				if let result = try? result.get(), let cropRect = object.imageCropRect {
					let imageCropped = AppDataManager.sharedInstance.getCroppedImage(image: result.image, viewSize: self.imageView.frame.size, cropRect: cropRect)

					self.imageView.image = imageCropped
				}
			})
			locationLabel.text = object.gallery.title
		} else {
			titleLabel.text = searchedArtwork.title
			imageView.kf.indicatorType = .activity
			imageView.kf.setImage(with: searchedArtwork.thumbnailUrl)

			locationLabel.text = searchedArtwork.gallery.title
			audioButton.isHidden = true
			audioButton.isEnabled = false
		}

		setupAccessibility()
	}

	init(tourStop: AICTourStopModel, stopNumber: Int, language: Common.Language) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		setup()

		titleLabel.text = "\(stopNumber).\t" + tourStop.object.title
		imageView.kf.indicatorType = .activity
		imageView.kf.setImage(with: tourStop.object.thumbnailUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
			if let result = try? result.get(), let cropRect = tourStop.object.imageCropRect {
				self.imageView.image = AppDataManager.sharedInstance.getCroppedImage(image: result.image, viewSize: self.imageView.frame.size, cropRect: cropRect)
			}
		})
		locationLabel.text = "\t" + tourStop.object.gallery.title

		setupAccessibility()
	}

	init(tour: AICTourModel, language: Common.Language) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		setup()

		titleLabel.text = tour.title
		imageView.kf.indicatorType = .activity
		imageView.kf.setImage(with: tour.imageUrl)
		locationLabel.text = tour.stops.first!.object.gallery.title

		setupAccessibility()
	}

	init(exhibition: AICExhibitionModel) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		setup()

		titleLabel.text = exhibition.title
		imageView.kf.indicatorType = .activity
		imageView.kf.setImage(with: exhibition.imageUrl)
		locationLabel.text = Common.Map.stringForFloorNumber[exhibition.location!.floor]
		audioButton.isHidden = true
		audioButton.isEnabled = false

		setupAccessibility()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setup() {
		imageView.frame.size = CGSize(width: 72, height: 45)
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.backgroundColor = .aicLightGrayColor
		imageView.kf.indicatorType = .activity

		titleLabel.numberOfLines = 1
		titleLabel.lineBreakMode = .byTruncatingTail
		titleLabel.textAlignment = .left
		titleLabel.font = .aicContentButtonTitleFont
		titleLabel.textColor = .white

		locationLabel.numberOfLines = 1
		locationLabel.lineBreakMode = .byTruncatingTail
		locationLabel.textAlignment = .left
		locationLabel.font = .aicPageTextFont
		locationLabel.textColor = .white

		audioButton.setImage(#imageLiteral(resourceName: "tourStopPlay"), for: .normal)
		audioButton.setImage(#imageLiteral(resourceName: "tourStopPause"), for: .selected)

		imageButton.setTitle("", for: .normal)
		imageButton.setImage(UIImage(), for: .normal)
		imageButton.backgroundColor = .clear

		// Add subviews
		self.addSubview(imageView)
		self.addSubview(imageButton)
		self.addSubview(titleLabel)
		self.addSubview(locationLabel)
		self.addSubview(audioButton)

		createViewConstraints()
	}

	// MARK: Accessibility

	private func setupAccessibility() {
		imageButton.isAccessibilityElement = false
		locationLabel.isAccessibilityElement = false
		titleLabel.accessibilityLabel = "Tour Stop"
		titleLabel.accessibilityValue = titleLabel.text! + ", " + locationLabel.text!
		audioButton.accessibilityLabel = "Play Audio Track"
	}

	private func createViewConstraints() {
		imageView.autoPinEdge(.top, to: .top, of: self, withOffset: 86)
		imageView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		imageView.autoSetDimensions(to: imageView.frame.size)

		imageButton.autoPinEdge(.top, to: .top, of: imageView)
		imageButton.autoPinEdge(.leading, to: .leading, of: imageView)
		imageButton.autoPinEdge(.trailing, to: .trailing, of: imageView)
		imageButton.autoPinEdge(.bottom, to: .bottom, of: imageView)

		titleLabel.autoPinEdge(.top, to: .top, of: imageView)
		titleLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .leading, of: audioButton, withOffset: -16)

		locationLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
		locationLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 16)
		locationLabel.autoPinEdge(.trailing, to: .leading, of: audioButton, withOffset: -16)

		audioButton.autoAlignAxis(.horizontal, toSameAxisOf: imageView)
		audioButton.autoPinEdge(.leading, to: .leading, of: self, withOffset: UIScreen.main.bounds.width - audioButton.image(for: .normal)!.size.width - 16)
	}
}
