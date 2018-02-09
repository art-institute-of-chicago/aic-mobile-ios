//
//  TourStopViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/5/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class TourStopViewController : UIViewController {
	let imageView: UIImageView = UIImageView()
	let titleLabel: UILabel = UILabel()
	let locationLabel: UILabel = UILabel()
	let audioButton: UIButton = UIButton()
	
	var stopIndex: Int = 0
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: Common.Layout.cardMinimizedContentHeight - 30 - Common.Layout.miniAudioPlayerHeight)
		
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
		self.view.addSubview(imageView)
		self.view.addSubview(titleLabel)
		self.view.addSubview(locationLabel)
		self.view.addSubview(audioButton)
		
		createViewConstraints()
	}
	
	func createViewConstraints() {
		imageView.autoPinEdge(.top, to: .top, of: self.view, withOffset: 56)
		imageView.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 16)
		imageView.autoSetDimension(.width, toSize: 72)
		imageView.autoSetDimension(.height, toSize: 45)
		
		titleLabel.autoPinEdge(.top, to: .top, of: imageView)
		titleLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .leading, of: audioButton, withOffset: -16)
		//titleLabel.autoSetDimension(.height, toSize: 50, relation: .lessThanOrEqual)
		
		locationLabel.autoPinEdge(.top, to: .bottom, of: titleLabel)
		locationLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 16)
		locationLabel.autoPinEdge(.trailing, to: .leading, of: audioButton, withOffset: -16)
		
		audioButton.autoPinEdge(.top, to: .top, of: self.view, withOffset: 56)
		audioButton.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: UIScreen.main.bounds.width - audioButton.image(for: .normal)!.size.width - 16)
	}
}
