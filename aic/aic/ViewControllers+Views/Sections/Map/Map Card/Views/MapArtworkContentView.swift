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
	
	init(artwork: AICObjectModel) {
		super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: Common.Layout.cardMinimizedContentHeight - 30 - Common.Layout.miniAudioPlayerHeight))
		setup(artwork: artwork)
	}
	
	init (searchedArtwork: AICSearchedArtworkModel) {
		super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: Common.Layout.cardMinimizedContentHeight - 30 - Common.Layout.miniAudioPlayerHeight))
		
		if let object = searchedArtwork.audioObject {
			setup(artwork: object)
		}
		else {
			setup(searchedArtwork: searchedArtwork)
		}
	}
	
	private func setup(artwork: AICObjectModel) {
		setup()
		titleLabel.text = artwork.title
		imageView.kf.setImage(with: artwork.imageUrl)
		locationLabel.text = Common.Map.stringForFloorNumber[artwork.location.floor]
	}
	
	private func setup(searchedArtwork: AICSearchedArtworkModel) {
		setup()
		titleLabel.text = searchedArtwork.title
		imageView.kf.setImage(with: searchedArtwork.imageUrl)
		locationLabel.text = Common.Map.stringForFloorNumber[searchedArtwork.location.floor]
		audioButton.isHidden = true
		audioButton.isEnabled = false
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
