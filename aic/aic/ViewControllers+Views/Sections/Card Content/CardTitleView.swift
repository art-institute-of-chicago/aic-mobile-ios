//
//  CardTitleView.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class CardTitleView : UITableViewHeaderFooterView {
	static let reuseIdentifier: String = "cardTitleView"
	
	let titleLabel: UILabel = UILabel()
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: CardTitleView.reuseIdentifier)
		
		self.contentView.backgroundColor = .aicDarkGrayColor
		
		titleLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
		titleLabel.textColor = .white
		titleLabel.textAlignment = .center
		titleLabel.font = .aicCardTitleFont
		
		self.addSubview(titleLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
