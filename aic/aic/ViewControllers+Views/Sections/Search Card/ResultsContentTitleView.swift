//
//  ResultsContentTitleView.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class ResultsContentTitleView : UITableViewHeaderFooterView {
	static let reuseIdentifier: String = "resultsContentTitleView"
	
	let contentTitleLabel: UILabel = UILabel()
	let seeAllButton: UIButton = UIButton()
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		self.contentView.backgroundColor = .aicDarkGrayColor
		
		contentTitleLabel.font = .aicHomeCollectionTitleFont
		contentTitleLabel.textColor = .white
		
		seeAllButton.semanticContentAttribute = .forceRightToLeft
		seeAllButton.titleLabel?.font = .aicHomeSeeAllFont
		seeAllButton.setTitle("See all", for: .normal)
		seeAllButton.setTitleColor(.aicCardDarkTextColor, for: .normal)
		seeAllButton.setImage(#imageLiteral(resourceName: "homeSeeAllArrow").colorized(.aicCardDarkTextColor), for: .normal)
		
		self.contentView.addSubview(contentTitleLabel)
		self.contentView.addSubview(seeAllButton)
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

