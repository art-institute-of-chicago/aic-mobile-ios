//
//  TourStopsNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 2/5/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class TourStopsNavigationController: CardNavigationController {
	private var tourModel: AICTourModel? = nil
	
	private let titleLabel: UILabel = UILabel()
	private let dividerLine: UIView = UIView()
	let tourStopPageVC: TourStopPageViewController = TourStopPageViewController()
	
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
		titleLabel.text = "The Essentials Tour"
		
		dividerLine.backgroundColor = .white
		
		// Add main VC as subview to rootVC
		tourStopPageVC.willMove(toParentViewController: rootVC)
		rootVC.view.addSubview(tourStopPageVC.view)
		tourStopPageVC.didMove(toParentViewController: rootVC)
		
		// Add subviews
		self.view.addSubview(titleLabel)
		self.view.addSubview(dividerLine)
		
		createViewConstraints()
	}
	
	private func createViewConstraints() {
		tourStopPageVC.view.autoPinEdge(.top, to: .top, of: rootVC.view, withOffset: contentTopMargin)
		tourStopPageVC.view.autoPinEdge(.leading, to: .leading, of: rootVC.view)
		tourStopPageVC.view.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
		tourStopPageVC.view.autoSetDimension(.height, toSize: Common.Layout.cardMinimizedContentHeight - contentTopMargin - Common.Layout.miniAudioPlayerHeight)
		
		titleLabel.autoPinEdge(.top, to: .top, of: self.view, withOffset: contentTopMargin + 5)
		titleLabel.autoPinEdge(.leading, to: .leading, of: self.view,  withOffset: 16)
		titleLabel.autoPinEdge(.trailing, to: .trailing, of: self.view,  withOffset: -16)
		
		dividerLine.autoPinEdge(.top, to: .top, of: self.view, withOffset: 70)
		dividerLine.autoPinEdge(.leading, to: .leading, of: self.view,  withOffset: 16)
		dividerLine.autoPinEdge(.trailing, to: .trailing, of: self.view,  withOffset: -16)
		dividerLine.autoSetDimension(.height, toSize: 1)
	}
	
	// MARK: Content
	
	func setTourContent(tour: AICTourModel, language: Common.Language) {
		tourModel = tour
		tourModel!.language = language
		titleLabel.text = tourModel!.title
		tourStopPageVC.setTour(tour: tourModel!)
		
		// in case the tour card is open, to tell the map to animate the floor selector
		self.cardDelegate?.cardDidUpdatePosition?(cardVC: self, position: self.view.frame.origin)
	}
	
	func setCurrentStop(stopIndex: Int?) {
		if let index = stopIndex {
			// Stop
			tourStopPageVC.setCurrentPage(pageIndex: index + 1)
		}
		else {
			// Overview
			tourStopPageVC.setCurrentPage(pageIndex: 0)
		}
	}
}
