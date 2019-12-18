//
//  AudioPlayerSlider.swift
//  aic
//
//  Created by Filippo Vanucci on 2/4/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class AudioPlayerSlider: UISlider {
	init() {
		super.init(frame: CGRect.zero)

		self.setThumbImage(#imageLiteral(resourceName: "audioSliderThumbImage"), for: .normal)
		self.tintColor = .aicHomeColor
		self.isUserInteractionEnabled = true
		self.isContinuous = true
		self.minimumValue = 0
		self.maximumValue = 1
		self.value = 0
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// Custom thumbImage size based on the "thumbImage" asset (32x32)
	override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
		let x = CGFloat(map(val: Double(value), oldRange1: 0.0, oldRange2: 1.0, newRange1: -8.0, newRange2: Double(bounds.width - 24)))
		let y = bounds.height * 0.5 - 16
		return CGRect(x: x, y: y, width: 32, height: 32)
	}
}
