//
//  TooltipArrowView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/26/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class TooltipArrowView : UIView {
	let backgroundView: UIView = UIView()
	let textLabel: UILabel = UILabel()
	let arrowView: UIView = UIView()
	var arrowPosition: CGPoint
	
	init(tooltip: AICTooltipModel) {
		arrowPosition = tooltip.arrowPosition
		super.init(frame: UIScreen.main.bounds)
		
//		self.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
		self.backgroundColor = UIColor(white: 51.0 / 255.0, alpha: 0.25)
		
		backgroundView.backgroundColor = .aicTooltipBackgroundColor
		
		textLabel.text = tooltip.text
		textLabel.font = .aicTooltipTextFont
		textLabel.textColor = .white
		textLabel.textAlignment = .right
		textLabel.numberOfLines = 1
		
		let arrowPath = UIBezierPath()
		arrowPath.move(to: CGPoint(x: 0, y: 0))
		arrowPath.addLine(to: CGPoint(x: 6.0, y: 5.0))
		arrowPath.addLine(to: CGPoint(x: 0, y: 10.0))
		arrowPath.close()
		
		let arrowLayer = CAShapeLayer()
		arrowLayer.path = arrowPath.cgPath
		arrowLayer.fillColor = UIColor.aicTooltipBackgroundColor.cgColor
		
		arrowView.layer.addSublayer(arrowLayer)
		
		// Add Subviews
		self.addSubview(backgroundView)
		backgroundView.addSubview(arrowView)
		backgroundView.addSubview(textLabel)
		
		createConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createConstraints() {
		textLabel.autoPinEdge(.top, to: .top, of: self, withOffset: arrowPosition.y - 7.0)
		textLabel.autoPinEdge(.trailing, to: .leading, of: self, withOffset: arrowPosition.x - 24.0)
		
		backgroundView.autoPinEdge(.top, to: .top, of: textLabel, withOffset: -5)
		backgroundView.autoPinEdge(.leading, to: .leading, of: textLabel, withOffset: -10)
		backgroundView.autoPinEdge(.trailing, to: .trailing, of: textLabel, withOffset: 10)
		backgroundView.autoPinEdge(.bottom, to: .bottom, of: textLabel, withOffset: 5)
		
		arrowView.autoSetDimensions(to: CGSize(width: 6.0, height: 10.0))
		arrowView.autoPinEdge(.leading, to: .trailing, of: backgroundView)
		arrowView.autoPinEdge(.top, to: .top, of: backgroundView, withOffset: 10.0)
	}
}
