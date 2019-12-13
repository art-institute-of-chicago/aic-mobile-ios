//
//  MapTourStartContentView.swift
//  aic
//
//  Created by Filippo Vanucci on 3/6/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit
import Localize_Swift

class MapTourStartContentView: UIView {
	let audioButton: AICButton = AICButton(isSmall: false)

	private let frameSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedContentHeight - Common.Layout.miniAudioPlayerHeight)

	init() {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))

		audioButton.setColorMode(colorMode: AICButton.blueMode)
		audioButton.setIconImage(image: #imageLiteral(resourceName: "buttonPlayIcon"))
		audioButton.setTitle("Play Tour Intro".localized(using: "ContentCard"), for: .normal)

		self.addSubview(audioButton)

		createViewConstraints()

		// Language
		NotificationCenter.default.addObserver(self, selector: #selector(updateLanguage), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
	}

	private func createViewConstraints() {
		audioButton.autoPinEdge(.top, to: .top, of: self, withOffset: 85)
		audioButton.autoAlignAxis(.vertical, toSameAxisOf: self)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc private func updateLanguage() {
		audioButton.setTitle("Play Tour Intro".localized(using: "ContentCard"), for: .normal)
	}
}
