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
	
	let titleLabel: UILabel = UILabel()
	private let dividerLine: UIView = UIView()
	private let contentVC: UIViewController
	
	init(contentVC: UIViewController) {
		self.contentVC = contentVC
		super.init(nibName: nil, bundle: nil)
	}
	
	init(contentView: UIView) {
		self.contentVC = UIViewController()
		self.contentVC.view.addSubview(contentView)
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
		titleLabel.font = .aicMapCardTitleFont
		titleLabel.textColor = .white
		
		dividerLine.backgroundColor = .white
		
		// Add main VC as subview to rootVC
		contentVC.willMove(toParentViewController: rootVC)
		rootVC.view.addSubview(contentVC.view)
		contentVC.didMove(toParentViewController: rootVC)
		
		// Add subviews
		self.view.addSubview(titleLabel)
		self.view.addSubview(dividerLine)
		
		createViewConstraints()
	}
	
	private func createViewConstraints() {
		contentVC.view.autoPinEdge(.top, to: .top, of: rootVC.view, withOffset: contentTopMargin)
		contentVC.view.autoPinEdge(.leading, to: .leading, of: rootVC.view)
		contentVC.view.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
		contentVC.view.autoSetDimension(.height, toSize: Common.Layout.cardMinimizedContentHeight - contentTopMargin - Common.Layout.miniAudioPlayerHeight)
		
		titleLabel.autoPinEdge(.top, to: .top, of: self.view, withOffset: 27)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self.view,  withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self.view,  withOffset: -16)
		
		dividerLine.autoPinEdge(.top, to: .top, of: self.view, withOffset: 70)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self.view,  withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self.view,  withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
	}
}
