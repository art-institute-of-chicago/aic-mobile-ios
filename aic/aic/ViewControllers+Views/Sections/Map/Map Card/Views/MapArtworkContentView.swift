//
//  MapArtworkContentView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/18/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MapArtworkContentView : UIView {
	private let imageView: UIImageView = UIImageView()
	private let titleLabel: UILabel = UILabel()
	private let locationLabel: UILabel = UILabel()
	let audioButton: UIButton = UIButton()
	
	private let frameSize: CGSize = CGSize(width: UIScreen.main.bounds.height, height: Common.Layout.cardMinimizedContentHeight - 30 - Common.Layout.miniAudioPlayerHeight)
	
	init(artwork: AICObjectModel) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		setup()
		
		titleLabel.text = artwork.title
		imageView.kf.setImage(with: artwork.imageUrl)
		locationLabel.text = artwork.gallery.title //Common.Map.stringForFloorNumber[artwork.location.floor]
	}
	
	init(searchedArtwork: AICSearchedArtworkModel) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		setup()
		
		if let object = searchedArtwork.audioObject {
			titleLabel.text = object.title
			imageView.kf.setImage(with: object.imageUrl)
			locationLabel.text = Common.Map.stringForFloorNumber[object.location.floor]
		}
		else {
			titleLabel.text = searchedArtwork.title
			imageView.kf.setImage(with: searchedArtwork.imageUrl)
			locationLabel.text = searchedArtwork.gallery.title // Common.Map.stringForFloorNumber[searchedArtwork.location.floor]
			audioButton.isHidden = true
			audioButton.isEnabled = false
		}
	}
	
	init(tourStop: AICTourStopModel, language: Common.Language) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		setup()
		
		var audio = tourStop.audio
		audio.language = language
		
		titleLabel.text = audio.trackTitle
		imageView.kf.setImage(with: tourStop.object.imageUrl)
		locationLabel.text = tourStop.object.gallery.title //Common.Map.stringForFloorNumber[tourStop.object.location.floor]
	}
	
	private func setup() {
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.backgroundColor = .aicLightGrayColor
		imageView.kf.indicatorType = .activity
		
		titleLabel.numberOfLines = 1
		titleLabel.lineBreakMode = .byTruncatingTail
		titleLabel.textAlignment = .left
		titleLabel.font = .aicMapCardBoldTextFont
		titleLabel.textColor = .white
		
		locationLabel.numberOfLines = 1
		locationLabel.lineBreakMode = .byTruncatingTail
		locationLabel.textAlignment = .left
		locationLabel.font = .aicMapCardTextFont
		locationLabel.textColor = .white
		
		audioButton.setImage(#imageLiteral(resourceName: "mapTourStopAudioButton"), for: .normal)
		
		// Add subviews
		self.addSubview(imageView)
		self.addSubview(titleLabel)
		self.addSubview(locationLabel)
		self.addSubview(audioButton)
		
		createViewConstraints()
	}
	
	private func createViewConstraints() {
		imageView.autoPinEdge(.top, to: .top, of: self, withOffset: 56)
		imageView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		imageView.autoSetDimension(.width, toSize: 72)
		imageView.autoSetDimension(.height, toSize: 45)
		
		titleLabel.autoPinEdge(.top, to: .top, of: imageView)
		titleLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .leading, of: audioButton, withOffset: -16)
		
		locationLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
		locationLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 16)
		locationLabel.autoPinEdge(.trailing, to: .leading, of: audioButton, withOffset: -16)
		
		audioButton.autoPinEdge(.top, to: .top, of: self, withOffset: 56)
		audioButton.autoPinEdge(.leading, to: .leading, of: self, withOffset: UIScreen.main.bounds.width - audioButton.image(for: .normal)!.size.width - 16)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
