//
//  AICTransparentButton.swift
//  aic
//
//  Created by Filippo Vanucci on 1/19/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class AICTransparentButton : AICButton {
	
	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				backgroundColor = .clear
				layer.borderColor = UIColor.white.cgColor
			} else {
				backgroundColor = buttonColor
				layer.borderColor = buttonColor.cgColor
			}
		}
	}
	
	override func setButtonColor(color: UIColor) {
		super.setButtonColor(color: color)
		setTitleColor(.white, for: .highlighted)
	}
}
