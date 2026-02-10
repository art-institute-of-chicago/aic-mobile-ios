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
    let audioButton: AICButton = AICButton(withSize: AICButton.Size.dynamic)

	private let frameSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: Common.Layout.cardMinimizedContentHeight - Common.Layout.miniAudioPlayerHeight)

	init() {
		super.init(frame: CGRect(origin: CGPoint.zero, size: frameSize))

		audioButton.setColorMode(colorMode: AICButton.blueMode)
		audioButton.setIconImage(image: #imageLiteral(resourceName: "buttonPlayIcon"))
		audioButton.setTitle("tour_play_tour_introduction_action".localized(using: "Base"), for: .normal)
        audioButton.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 10)

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
		audioButton.setTitle("tour_play_tour_introduction_action".localized(using: "Base"), for: .normal)
	}
}
