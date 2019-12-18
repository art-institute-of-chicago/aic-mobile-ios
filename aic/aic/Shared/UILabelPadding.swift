//
//  UILabelPadding.swift
//  aic
//
//  Created by Tina Shah on 7/20/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class UILabelPadding: UILabel {
	// Adding formatting to Artist info
	var topInset: CGFloat = 5.0
	var bottomInset: CGFloat = 0
	var leftInset: CGFloat = 0
	var rightInset: CGFloat = 0

	override func drawText(in rect: CGRect) {
		let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
		super.drawText(in: rect.inset(by: insets))
	}

	override var intrinsicContentSize: CGSize {
		let size = super.intrinsicContentSize
		return CGSize(width: size.width + leftInset + rightInset,
					  height: size.height + topInset + bottomInset)
	}
}
