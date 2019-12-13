//
//  TooltipPopupView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/26/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class TooltipPopupPageView: UIView {
	private let titleLabel: UILabel = UILabel()
	private let dividerLine: UIView = UIView()
	private let imageView: UIImageView = UIImageView()
	private let textLabel: UILabel = UILabel()
	private let dismissLabel: UILabel = UILabel()

	init(frame: CGRect, tooltip: AICTooltipModel) {
		super.init(frame: frame)

		self.backgroundColor = .clear

		titleLabel.text = tooltip.title.localized(using: "Tooltips")
		titleLabel.font = .aicTitleFont
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
		textLabel.font = .aicPageTextFont
		textLabel.textColor = .white
		textLabel.textAlignment = .center
		textLabel.numberOfLines = 2

		dismissLabel.text = "Dismiss".localized(using: "Tooltips").uppercased()
		dismissLabel.font = .aicTooltipDismissFont
		dismissLabel.textColor = .white
		dismissLabel.textAlignment = .right
		dismissLabel.numberOfLines = 1

		// Add Subviews
		self.addSubview(titleLabel)
		self.addSubview(dividerLine)
		self.addSubview(imageView)
		self.addSubview(textLabel)
		self.addSubview(dismissLabel)

		createConstraints()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func createConstraints() {
		dividerLine.autoPinEdge(.top, to: .top, of: self, withOffset: 82)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)

		titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: dividerLine, withOffset: -41)

		imageView.autoPinEdge(.top, to: .bottom, of: dividerLine, withOffset: 18)
		imageView.autoAlignAxis(.vertical, toSameAxisOf: self)
		imageView.autoSetDimensions(to: CGSize(width: 48, height: 48))

		textLabel.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 16)
		textLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		textLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
	}
}
