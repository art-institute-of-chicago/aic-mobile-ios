//
//  TourStopsNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/5/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class MapContentCardNavigationController: CardNavigationController {
	private var tourModel: AICTourModel? = nil
	
	private let titleLabel: UILabel = UILabel()
	private let dividerLine: UIView = UIView()
	let contentVC: UIViewController
	
	init(contentVC: UIViewController) {
		self.contentVC = contentVC
		super.init(nibName: nil, bundle: nil)
	}
	
	init(contentView: UIView) {
		self.contentVC = UIViewController()
		self.contentVC.view = contentView
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set Open State as Minimized
		openState = .minimized
		
		self.view.backgroundColor = .aicMapCardBackgroundColor
		
		titleLabel.numberOfLines = 1
		titleLabel.lineBreakMode = .byTruncatingTail
		titleLabel.textAlignment = .center
		titleLabel.font = .aicTitleFont
		titleLabel.textColor = .white
		
		dividerLine.backgroundColor = .white
		
		// Add main VC as subview to rootVC
		contentVC.willMove(toParent: rootVC)
		rootVC.view.addSubview(contentVC.view)
		contentVC.didMove(toParent: rootVC)
		
		// Add subviews
		self.view.addSubview(titleLabel)
		self.view.addSubview(dividerLine)
		
		createViewConstraints()
		
		// Accessibility
		self.view.accessibilityElements = [
			titleLabel,
			closeButton,
			contentVC.view
		]
	}
	
	func setTitleText(text: String) {
		if text.isEmpty {
			titleLabel.isHidden = true
			dividerLine.isHidden = true
		}
		else {
			titleLabel.text = text
		}
	}
	
	private func createViewConstraints() {
		contentVC.view.autoPinEdge(.top, to: .top, of: rootVC.view)
		contentVC.view.autoPinEdge(.leading, to: .leading, of: rootVC.view)
		contentVC.view.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
		contentVC.view.autoSetDimension(.height, toSize: Common.Layout.cardMinimizedContentHeight - Common.Layout.miniAudioPlayerHeight)
		
		titleLabel.autoPinEdge(.top, to: .top, of: self.view, withOffset: 27)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self.view,  withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self.view,  withOffset: -16)
		
		dividerLine.autoPinEdge(.top, to: .top, of: self.view, withOffset: 70)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self.view,  withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self.view,  withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
	}
	
	override func cardDidShowMinimized() {
		// Accessibility
		self.titleLabel.becomeFirstResponder()
	}
}
