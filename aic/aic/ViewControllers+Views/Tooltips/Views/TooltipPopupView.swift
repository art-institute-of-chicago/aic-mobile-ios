//
//  TooltipPopupView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/26/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class TooltipPopupView : UIView {
	private let backgroundView: UIView = UIView()
	private let titleLabel: UILabel = UILabel()
	private let dividerLine: UIView = UIView()
	private let imageView: UIImageView = UIImageView()
	private let textLabel: UILabel = UILabel()
	private let dismissLabel: UILabel = UILabel()
	
	init(tooltip: AICTooltipModel) {
		super.init(frame: UIScreen.main.bounds)
		
		self.backgroundColor = UIColor(white: 51.0 / 255.0, alpha: 0.45)
		
		backgroundView.backgroundColor = .aicTooltipBackgroundColor
		
		titleLabel.text = tooltip.title.localized(using: "Tooltips")
		titleLabel.font = .aicTooltipTitleFont
		titleLabel.textColor = .white
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0
		
		dividerLine.backgroundColor = .white
		
		imageView.backgroundColor = .clear
		imageView.contentMode = .scaleAspectFit
		if let image = tooltip.image {
			imageView.image = image
		}
		
		textLabel.text = tooltip.text.localized(using: "Tooltips")
		textLabel.font = .aicTooltipTextFont
		textLabel.textColor = .white
		textLabel.textAlignment = .center
		textLabel.numberOfLines = 0
		
		dismissLabel.text = "Dismiss".localized(using: "Tooltips").uppercased()
		dismissLabel.font = .aicTooltipDismissFont
		dismissLabel.textColor = .white
		dismissLabel.textAlignment = .right
		dismissLabel.numberOfLines = 1
		
		// Add Subviews
		self.addSubview(backgroundView)
		backgroundView.addSubview(titleLabel)
		backgroundView.addSubview(dividerLine)
		backgroundView.addSubview(imageView)
		backgroundView.addSubview(textLabel)
		backgroundView.addSubview(dismissLabel)
		
		createConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createConstraints() {
		backgroundView.autoSetDimension(.width, toSize: UIScreen.main.bounds.width - 48.0)
		backgroundView.autoPinEdge(.top, to: .top, of: self, withOffset: 100 + Common.Layout.safeAreaTopMargin)
		backgroundView.autoAlignAxis(.vertical, toSameAxisOf: self)
		
		titleLabel.autoPinEdge(.top, to: .top, of: backgroundView, withOffset: 16)
		titleLabel.autoPinEdge(.leading, to: .leading, of: backgroundView, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: backgroundView, withOffset: -16)
		
		dividerLine.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16)
		dividerLine.autoPinEdge(.leading, to: .leading, of: backgroundView, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: backgroundView, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
		
		imageView.autoPinEdge(.top, to: .bottom, of: dividerLine, withOffset: 8)
		imageView.autoAlignAxis(.vertical, toSameAxisOf: backgroundView)
		imageView.autoSetDimensions(to: CGSize(width: 48, height: 48))
		
		textLabel.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 24)
		textLabel.autoPinEdge(.leading, to: .leading, of: backgroundView, withOffset: 16)
		textLabel.autoPinEdge(.trailing, to: .trailing, of: backgroundView, withOffset: -16)
		
		dismissLabel.autoPinEdge(.top, to: .bottom, of: textLabel, withOffset: 20)
		dismissLabel.autoPinEdge(.leading, to: .leading, of: backgroundView, withOffset: 16)
		dismissLabel.autoPinEdge(.trailing, to: .trailing, of: backgroundView, withOffset: -16)
		dismissLabel.autoPinEdge(.bottom, to: .bottom, of: backgroundView, withOffset: -16)
	}
}
