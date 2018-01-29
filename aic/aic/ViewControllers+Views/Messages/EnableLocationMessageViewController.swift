//
//  EnableLocationMessageViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/26/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class EnableLocationMessageViewController : MessageViewController {
	let confirmButton: AICTransparentButton = AICTransparentButton(color: .aicMapColor, isSmall: true)
//	let cancelButton: AICTransparentButton = AICTransparentButton(color: .aicMapColor, isSmall: true)
	
	override func viewDidLoad() {
		confirmButton.setTitle("Ok", for: .normal)
		confirmButton.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
		
		buttonsView.addSubview(confirmButton)
		
		super.viewDidLoad()
	}
	
	override func createViewConstraints() {
		super.createViewConstraints()
		
		confirmButton.autoPinEdge(.top, to: .top, of: buttonsView)
		confirmButton.autoAlignAxis(.vertical, toSameAxisOf: buttonsView)
	}
	
	@objc override func updateLanguage() {
		titleLabel.text = "Location Settings Title".localized(using: "LocationSettings")
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 6
		let textAttrString = NSMutableAttributedString(string: "Location Settings Text".localized(using: "LocationSettings"))
		textAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, textAttrString.length))
		
		subtitleLabel.attributedText = textAttrString
		subtitleLabel.font = .aicLanguageSelectionTextFont
		subtitleLabel.numberOfLines = 0
		subtitleLabel.textColor = .white
		subtitleLabel.textAlignment = .center
	}
	
	@objc func buttonPressed(button: UIButton) {
		if button == confirmButton {
			self.delegate?.messageViewActionSelected(messageVC: self)
		}
	}
}
