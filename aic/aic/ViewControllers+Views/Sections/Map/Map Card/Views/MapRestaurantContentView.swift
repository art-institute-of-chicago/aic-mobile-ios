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
	private let dividerLine: UIView = UIView()
	private let descriptionLabel: UILabel = UILabel()
	let audioButton: UIButton = UIButton()
	
	private let frameSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedContentHeight - Common.Layout.miniAudioPlayerHeight)
	
	init(restaurant: AICRestaurantModel) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		
		imageView.kf.setImage(with: restaurant.imageUrl)
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.backgroundColor = .aicLightGrayColor
		imageView.kf.indicatorType = .activity
		
		titleLabel.text = restaurant.title
		titleLabel.numberOfLines = 1
		titleLabel.lineBreakMode = .byTruncatingTail
		titleLabel.textAlignment = .center
		titleLabel.font = .aicTitleFont
		titleLabel.textColor = .white
		
		dividerLine.backgroundColor = .white
		
		descriptionLabel.text = restaurant.description
		descriptionLabel.numberOfLines = 2
		descriptionLabel.lineBreakMode = .byWordWrapping
		descriptionLabel.textAlignment = .left
		descriptionLabel.font = .aicPageTextFont
		descriptionLabel.textColor = .white
		
		// Add subviews
		self.addSubview(titleLabel)
		self.addSubview(dividerLine)
		self.addSubview(imageView)
		self.addSubview(descriptionLabel)
		
		createViewConstraints()
		
		// Accessibility
		titleLabel.accessibilityLabel = "Restaurant"
		titleLabel.accessibilityValue = restaurant.title
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createViewConstraints() {
		titleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: 27)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self,  withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self,  withOffset: -16)
		
		dividerLine.autoPinEdge(.top, to: .top, of: self, withOffset: 70)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self,  withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self,  withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
		
		imageView.autoPinEdge(.top, to: .top, of: self, withOffset: 86)
		imageView.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		imageView.autoSetDimension(.width, toSize: 72)
		imageView.autoSetDimension(.height, toSize: 45)
		
		descriptionLabel.autoPinEdge(.top, to: .top, of: imageView)
		descriptionLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 16)
		descriptionLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
	}
}
