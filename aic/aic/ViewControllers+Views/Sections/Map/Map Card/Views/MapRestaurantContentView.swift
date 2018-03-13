//
//  MapRestaurantContentView.swift
//  aic
//
//  Created by Filippo Vanucci on 3/1/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MapRestaurantContentView : UIView {
	private let imageView: UIImageView = UIImageView()
	private let titleLabel: UILabel = UILabel()
	private let descriptionLabel: UILabel = UILabel()
	let audioButton: UIButton = UIButton()
	
	private let frameSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedContentHeight - 30 - Common.Layout.miniAudioPlayerHeight)
	
	init(restaurant: AICRestaurantModel) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		
		imageView.kf.setImage(with: restaurant.imageUrl)
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.backgroundColor = .aicLightGrayColor
		imageView.kf.indicatorType = .activity
		
		titleLabel.text = restaurant.title
		titleLabel.numberOfLines = 1
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.textAlignment = .left
		titleLabel.font = .aicContentTitleFont
		titleLabel.textColor = .white
		
		descriptionLabel.text = restaurant.description
		descriptionLabel.numberOfLines = 1
		descriptionLabel.lineBreakMode = .byWordWrapping
		descriptionLabel.textAlignment = .left
		descriptionLabel.font = .aicMapCardTextFont
		descriptionLabel.textColor = .white
		
		// Add subviews
		self.addSubview(imageView)
		self.addSubview(titleLabel)
		self.addSubview(descriptionLabel)
		
		createViewConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createViewConstraints() {
		imageView.autoPinEdge(.top, to: .top, of: self, withOffset: 56)
		imageView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		imageView.autoSetDimension(.width, toSize: 72)
		imageView.autoSetDimension(.height, toSize: 45)
		
		titleLabel.autoPinEdge(.top, to: .top, of: imageView)
		titleLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		
		descriptionLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
		descriptionLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 16)
		descriptionLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
	}
}
