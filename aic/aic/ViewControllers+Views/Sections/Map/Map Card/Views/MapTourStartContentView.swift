//
//  MapTourStartContentView.swift
//  aic
//
//  Created by Filippo Vanucci on 3/6/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MapTourStartContentView : UIView {
	let audioButton: AICButton = AICButton(isSmall: true)
	
	private let frameSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedContentHeight - 30 - Common.Layout.miniAudioPlayerHeight)
	
	init() {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		
		audioButton.setColorMode(colorMode: AICButton.blueMode)
		audioButton.setTitle("Play Audio", for: .normal)
		
		self.addSubview(audioButton)
		
		createViewConstraints()
	}
	
	private func createViewConstraints() {
		audioButton.autoPinEdge(.top, to: .top, of: self, withOffset: 56)
		audioButton.autoAlignAxis(.vertical, toSameAxisOf: self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
