//
//  HomeContentTitleView.swift
//  aic
//
//  Created by Filippo Vanucci on 11/29/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class HomeContentTitleView : UIView {
	let contentTitleLabel: UILabel = UILabel()
	let seeAllButton: UIButton = UIButton()
	
	init(title: String) {
		super.init(frame: CGRect.zero)
		
		self.backgroundColor = .white
		
		contentTitleLabel.text = title
		contentTitleLabel.font = .aicContentTitleFont
		contentTitleLabel.textColor = .aicDarkGrayColor
		
		seeAllButton.semanticContentAttribute = .forceRightToLeft
		seeAllButton.titleLabel?.font = .aicHomeSeeAllFont
		seeAllButton.setTitle("See all", for: .normal)
		seeAllButton.setTitleColor(.aicHomeLinkColor, for: .normal)
		seeAllButton.setImage(#imageLiteral(resourceName: "homeSeeAllArrow").colorized(.aicHomeLinkColor), for: .normal)
		
		self.addSubview(contentTitleLabel)
		self.addSubview(seeAllButton)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateConstraints() {
		contentTitleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: 17)
		contentTitleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		
		seeAllButton.autoAlignAxis(toSuperviewMarginAxis: .horizontal)
		seeAllButton.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -8)
		
		super.updateConstraints()
	}
}
