//
//  InfoBuyTicketsView.swift
//  aic
//
//  Created by Christopher Luu on 12/16/19.
//  Copyright © 2019 Art Institute of Chicago. All rights reserved.
//

import UIKit

class InfoBuyTicketsView: BaseView {
	let purchasePromptLabel = UILabel()
	let buyButton = AICButton(isSmall: false)
	let bottomDividerLine = UIView()

	private let purchasePromptLabelMarginTop: CGFloat = 15
	private let buyButtonMarginTop: CGFloat = 20
	private let buyButtonMarginBottom: CGFloat = 20

	init() {
		super.init(frame: CGRect.zero)

		purchasePromptLabel.numberOfLines = 0
		purchasePromptLabel.text = "Purchase Tickets Prompt".localized(using: "Info")
		purchasePromptLabel.font = .aicPageTextFont
		purchasePromptLabel.textColor = .aicDarkGrayColor
		purchasePromptLabel.textAlignment = .center

		buyButton.setColorMode(colorMode: AICButton.orangeMode)
		buyButton.setTitle("Buy Tickets Button".localized(using: "Info"), for: .normal)

		bottomDividerLine.backgroundColor = .aicDividerLineColor

		// Add Subviews
		addSubview(purchasePromptLabel)
		addSubview(buyButton)
		addSubview(bottomDividerLine)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func updateConstraints() {
		if didSetupConstraints == false {
			purchasePromptLabel.autoPinEdge(.top, to: .top, of: self, withOffset: purchasePromptLabelMarginTop)
			purchasePromptLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
			purchasePromptLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)

			buyButton.autoAlignAxis(.vertical, toSameAxisOf: self)
			buyButton.autoPinEdge(.top, to: .bottom, of: purchasePromptLabel, withOffset: buyButtonMarginTop)

			bottomDividerLine.autoPinEdge(.top, to: .bottom, of: buyButton, withOffset: buyButtonMarginBottom)
			bottomDividerLine.autoSetDimension(.height, toSize: 1)
			bottomDividerLine.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
			bottomDividerLine.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)

			self.autoPinEdge(.bottom, to: .bottom, of: bottomDividerLine)

			didSetupConstraints = true
		}

		super.updateConstraints()
	}
}
