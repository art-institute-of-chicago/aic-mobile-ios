//
//  SeeAllIntroView.swift
//  aic
//
//  Created by Filippo Vanucci on 3/21/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class SeeAllIntroView: UICollectionReusableView {
	static let reuseIdentifier: String = "seeAllIntroView"

	let textLabel: UILabel = UILabel()

	static let topMargin: CGFloat = 32.0
	static let bottomMargin: CGFloat = 32.0

	static func sizeForText(text: String) -> CGSize {
		let textSize: CGSize = (text as NSString).boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 32, height: 0), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.aicPageTextFont], context: nil).size
		return CGSize(width: UIScreen.main.bounds.width - 32, height: textSize.height + SeeAllIntroView.topMargin + SeeAllIntroView.bottomMargin)
	}

	override init(frame: CGRect) {
		super.init(frame: CGRect.zero)

		backgroundColor = .aicIntroTextBackgroundColor

		textLabel.font = .aicPageTextFont
		textLabel.textColor = .aicDarkGrayColor
		textLabel.textAlignment = .center
		textLabel.numberOfLines = 0
		textLabel.lineBreakMode = .byWordWrapping

		// Add subviews
		self.addSubview(textLabel)

		createConstraints()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func createConstraints() {
		textLabel.autoPinEdge(.top, to: .top, of: self, withOffset: SeeAllIntroView.topMargin)
		textLabel.autoPinEdge(.leading, to: .leading, of: self, withOffset: 16.0)
		textLabel.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16.0)
	}

	func setText(text: String) {
		textLabel.text = text

		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
}
