//
//  SearchContentViewController.swift
//  aic
//
//  Created by Filippo Vanucci on 12/12/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

/// View controller that holds a table view of the content to display in a Search Card.
/// Tour, Artwork, Exhibition.
class SearchContentViewController : UIViewController {
	let cardBackgroundView: UIView = UIView()
	let tableVC: UITableViewController
	
	var tableViewHeightConstraint: NSLayoutConstraint? = nil
	
	let cardBackgroundTopMargin: CGFloat = 10
	let searchContentTopMargin: CGFloat = 69
	
	init(tableVC: UITableViewController) {
		self.tableVC = tableVC
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		self.view.backgroundColor = .clear
		cardBackgroundView.backgroundColor = .aicDarkGrayColor
		
		// Add subviews
		self.view.addSubview(cardBackgroundView)
		
		tableVC.willMove(toParent: self)
		self.view.addSubview(tableVC.view)
		tableVC.didMove(toParent: self)
		
		createViewConstraints()
	}
	
	func createViewConstraints() {
		cardBackgroundView.autoPinEdge(.top, to: .top, of: self.view, withOffset: cardBackgroundTopMargin)
		cardBackgroundView.autoPinEdge(.leading, to: .leading, of: self.view)
		cardBackgroundView.autoPinEdge(.trailing, to: .trailing, of: self.view)
		cardBackgroundView.autoPinEdge(.bottom, to: .bottom, of: self.view)
		
		// TODO: make it take into account tabBarHeight as well, then fix it also in resultsVC
		tableVC.view.autoPinEdge(.top, to: .top, of: self.view, withOffset: searchContentTopMargin)
		tableVC.view.autoPinEdge(.leading, to: .leading, of: self.view)
		tableVC.view.autoPinEdge(.trailing, to: .trailing, of: self.view)
		tableViewHeightConstraint = tableVC.view.autoSetDimension(.height, toSize: Common.Layout.cardContentHeight - searchContentTopMargin)
	}
}
