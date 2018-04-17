//
//  SeeAllHeaderView.swift
//  aic
//
//  Created by Filippo Vanucci on 12/16/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SeeAllHeaderView : UICollectionReusableView {
	static let reuseIdentifier: String = "seeAllHeaderView"
	
	let titleLabel: UILabel = UILabel()
	
	static let headerHeight: CGFloat = 65.0
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		titleLabel.font = .aicTitleFont
		titleLabel.textAlignment = .left
		titleLabel.textColor = .aicDarkGrayColor
		
		self.addSubview(titleLabel)
		
		createViewConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createViewConstraints() {
		titleLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
		titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: self)
		
		self.autoSetDimensions(to: CGSize(width: UIScreen.main.bounds.width, height: SeeAllHeaderView.headerHeight))
	}
}
