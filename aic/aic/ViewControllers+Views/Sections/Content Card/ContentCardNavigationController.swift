//
//  ContentCardNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/15/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class ContentCardNavigationController : CardNavigationController {
	let tableVC: UITableViewController
	
	var tableViewHeightConstraint: NSLayoutConstraint? = nil
	
	let searchContentTopMargin: CGFloat = 30
	
	// Tour Card
	init(tour: AICTourModel) {
		tableVC = TourTableViewController(tour: tour)
		super.init()
	}
	
	// Exhibition Card
	init(exhibition: AICExhibitionModel) {
		tableVC = ExhibitionTableViewController(exhibition: exhibition)
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add subviews
		tableVC.willMove(toParentViewController: self)
		self.view.addSubview(tableVC.view)
		tableVC.didMove(toParentViewController: self)
		
		createViewConstraints()
	}
	
	func createViewConstraints() {
		tableVC.view.autoPinEdge(.top, to: .top, of: self.view, withOffset: searchContentTopMargin)
		tableVC.view.autoPinEdge(.leading, to: .leading, of: self.view)
		tableVC.view.autoPinEdge(.trailing, to: .trailing, of: self.view)
		tableViewHeightConstraint = tableVC.view.autoSetDimension(.height, toSize: Common.Layout.cardContentHeight - searchContentTopMargin)
	}
	
	override func cardWillShowFullscreen() {
	}
	
	override func cardDidShowFullscreen() {
	}
	
	override func cardDidHide() {
		self.cardDelegate?.cardDidHide(cardVC: self)
	}
}
