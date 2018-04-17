//
//  MapRestroomContentView.swift
//  aic
//
//  Created by Filippo Vanucci on 2/18/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MapTextContentView : UIView {
	private let textLabel: UILabel = UILabel()
	
	private let frameSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedContentHeight - Common.Layout.miniAudioPlayerHeight)
	
	init(text: String) {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))
		
		textLabel.text = text
		textLabel.numberOfLines = 0
		textLabel.textAlignment = .center
		textLabel.font = .aicPageTextFont
		textLabel.textColor = .white
		
		self.addSubview(textLabel)
		
		createViewConstraints()
	}
	
	private func createViewConstraints() {
		textLabel.autoPinEdge(.top, to: .top, of: self, withOffset: 95)
		textLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		textLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setText(text: String) {
		textLabel.text = text
	}
}
