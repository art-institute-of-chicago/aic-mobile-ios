//
//  LanguageSelectorButton.swift
//  aic
//
//  Created by Filippo Vanucci on 2/8/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// LanguageSelectorButton
///
/// Used in LanguageSelectorView.
/// Only the current language button is set to selected.
/// All buttons can get highlighted.
class LanguageSelectorButton: UIButton {
	static let buttonSize: CGSize = CGSize(width: 94, height: 24)

	var language: Common.Language = .english {
		didSet {
			if language == .english {
				setTitle("localization_english".localized(using: "Localization"), for: .normal)
			} else if language == .spanish {
				setTitle("localization_spanish".localized(using: "Localization"), for: .normal)
			} else if language == .chinese {
				setTitle("localization_chinese".localized(using: "Localization"), for: .normal)
			}
		}
	}

	private var hasArrow: Bool

	init(withArrow: Bool) {
		hasArrow = withArrow
		super.init(frame: CGRect(origin: CGPoint.zero, size: LanguageSelectorButton.buttonSize))

		if hasArrow {
			isSelected = true
		}

		self.layer.cornerRadius = LanguageSelectorButton.buttonSize.height * 0.5

		self.semanticContentAttribute = .forceRightToLeft
		self.titleLabel?.font = .aicHomeSeeAllFont

		if hasArrow == true {
			self.setImage(#imageLiteral(resourceName: "languageSelectorExpand"), for: .normal)
			// margin between text and icon, it might change with different button labels
			self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
			self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
		}

		let normalColor: UIColor = hasArrow ? .white : .black
		self.setTitleColor(normalColor, for: .normal)
		self.setTitleColor(.white, for: .selected)
		self.setTitleColor(.white, for: .highlighted)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var isSelected: Bool {
		didSet {
			if isSelected {
				self.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
			} else {
				self.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
			}
		}
	}

	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				if isSelected {
					self.backgroundColor = .black
				} else {
					self.backgroundColor = .aicHomeColor
				}
			} else {
				if hasArrow {
					self.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
				} else {
					self.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
				}
			}
		}
	}
}
