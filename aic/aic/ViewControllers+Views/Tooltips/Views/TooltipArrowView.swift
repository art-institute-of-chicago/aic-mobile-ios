//
//  TooltipArrowView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/26/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class TooltipArrowView: UIView {
	let backgroundView: UIView = UIView()
	let textLabel: UILabel = UILabel()
	let arrowView: UIView = UIView()
	var arrowPosition: CGPoint

	let arrowSize = CGSize(width: 7.0, height: 10.0)
	let arrowRightMargin: CGFloat = 5.0

	init(tooltip: AICTooltipModel) {
		arrowPosition = tooltip.arrowPosition
		super.init(frame: UIScreen.main.bounds)

		self.backgroundColor = .clear

		backgroundView.backgroundColor = .aicTooltipBackgroundColor

		textLabel.text = tooltip.text
		textLabel.font = .aicPageTextFont
		textLabel.textColor = .white
		textLabel.textAlignment = .right
		textLabel.numberOfLines = 1

		if tooltip.text.range(of: "\n") != nil {
			textLabel.numberOfLines = 2
		}

		let arrowPath = UIBezierPath()
		arrowPath.move(to: CGPoint(x: 0, y: 0))
		arrowPath.addLine(to: CGPoint(x: arrowSize.width, y: arrowSize.height * 0.5))
		arrowPath.addLine(to: CGPoint(x: 0, y: arrowSize.height))
		arrowPath.close()

		let arrowLayer = CAShapeLayer()
		arrowLayer.path = arrowPath.cgPath
		arrowLayer.fillColor = UIColor.aicTooltipBackgroundColor.cgColor

		arrowView.layer.addSublayer(arrowLayer)

		// Add Subviews
		backgroundView.addSubview(arrowView)
		backgroundView.addSubview(textLabel)
		self.addSubview(backgroundView)

		createConstraints()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func createConstraints() {
		arrowView.autoSetDimensions(to: CGSize(width: arrowSize.width, height: arrowSize.height))
		arrowView.autoPinEdge(.top, to: .top, of: self, withOffset: arrowPosition.y - 5.0)
		arrowView.autoPinEdge(.leading, to: .leading, of: self, withOffset: arrowPosition.x - arrowSize.width - arrowRightMargin)

		textLabel.autoAlignAxis(.horizontal, toSameAxisOf: arrowView)
		textLabel.autoPinEdge(.trailing, to: .leading, of: arrowView, withOffset: -10.0)

		backgroundView.autoPinEdge(.top, to: .top, of: textLabel, withOffset: -5)
		backgroundView.autoPinEdge(.leading, to: .leading, of: textLabel, withOffset: -10)
		backgroundView.autoPinEdge(.trailing, to: .trailing, of: textLabel, withOffset: 10)
		backgroundView.autoPinEdge(.bottom, to: .bottom, of: textLabel, withOffset: 5)
	}
}
