//
//  HomeCollectionTitleView.swift
//  aic
//
//  Created by Filippo Vanucci on 11/29/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class HomeCollectionTitleView : UIView {
	let titleLabel: UILabel = UILabel()
	let seeAllButton: UIButton = UIButton()
	
	init(title: String) {
		super.init(frame: CGRect.zero)
		
		titleLabel.text = title
		titleLabel.font = .aicHomeCollectionTitleFont
		titleLabel.textColor = .aicDarkGrayColor
		
		seeAllButton.semanticContentAttribute = .forceRightToLeft
		seeAllButton.titleLabel?.font = .aicHomeSeeAllFont
		seeAllButton.setTitle("See all", for: .normal)
		seeAllButton.setTitleColor(.aicHomeLinkColor, for: .normal)
		seeAllButton.setImage(#imageLiteral(resourceName: "homeSeeAllArrow").colorized(.aicHomeLinkColor), for: .normal)
		
		addSubview(titleLabel)
		addSubview(seeAllButton)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateConstraints() {
		titleLabel.autoPinEdge(.top, to: .top, of: self, withOffset: 17)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		
		seeAllButton.autoAlignAxis(toSuperviewMarginAxis: .horizontal)
		seeAllButton.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -8)
		
		super.updateConstraints()
	}
}
