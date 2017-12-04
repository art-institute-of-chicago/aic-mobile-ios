//
//  InfoButton.swift
//  aic
//
//  Created by Filippo Vanucci on 11/21/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit
import PureLayout

class InfoButton : UIButton {
	let dividerLine: UIView = UIView()
	
	init() {
		super.init(frame:CGRect.zero)
		
		setTitleColor(.aicDarkGrayColor, for: .normal)
		setTitleColor(.aicInfoColor, for: .highlighted)
		titleLabel!.font = .aicTitleFont
		titleLabel!.textAlignment = .left
		contentHorizontalAlignment = .left
		contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		
		dividerLine.backgroundColor = .aicDividerLineColor
		self.addSubview(dividerLine)
		
		autoSetDimensions(to: CGSize(width: UIScreen.main.bounds.width, height: 80))
		
		dividerLine.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1.0)
		dividerLine.autoPinEdge(.top, to: .bottom, of: self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
