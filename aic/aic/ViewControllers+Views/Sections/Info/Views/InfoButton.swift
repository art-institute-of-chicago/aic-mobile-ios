//
//  InfoButton.swift
//  aic
//
//  Created by Filippo Vanucci on 11/21/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class InfoButton: UIButton {
	let dividerLine: UIView = UIView()
	let arrowIcon: UIImageView = UIImageView()

	init() {
		super.init(frame: CGRect.zero)

		setTitleColor(.aicDarkGrayColor, for: .normal)
		setTitleColor(.aicInfoColor, for: .highlighted)
		titleLabel?.font = .aicTitleFont
		titleLabel?.textAlignment = .left
		contentHorizontalAlignment = .left
		contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

		arrowIcon.image = #imageLiteral(resourceName: "rightArrow").colorized(.aicDarkGrayColor)
		dividerLine.backgroundColor = .aicDividerLineColor

		self.addSubview(dividerLine)
		self.addSubview(arrowIcon)

		autoSetDimensions(to: CGSize(width: UIScreen.main.bounds.width, height: 80))

    dividerLine.translatesAutoresizingMaskIntoConstraints = false
    arrowIcon.translatesAutoresizingMaskIntoConstraints = false

    dividerLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
    dividerLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    dividerLine.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    dividerLine.topAnchor.constraint(equalTo: bottomAnchor).isActive = true

    arrowIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    arrowIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    arrowIcon.heightAnchor.constraint(equalToConstant: arrowIcon.image!.size.height).isActive = true
    arrowIcon.widthAnchor.constraint(equalToConstant: arrowIcon.image!.size.width).isActive = true
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isHighlighted: Bool {
		willSet(newValue) {
			super.isHighlighted = newValue
			if newValue == true {
				arrowIcon.image = #imageLiteral(resourceName: "rightArrow").colorized(.aicInfoColor)
			} else {
				arrowIcon.image = #imageLiteral(resourceName: "rightArrow").colorized(.aicDarkGrayColor)
			}
		}
	}
}
