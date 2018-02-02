//
//  ContentCardNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/15/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class ContentCardNavigationController : CardNavigationController {
	var tableVC: UITableViewController
	
	var tableViewHeightConstraint: NSLayoutConstraint? = nil
	
	// Tour Card
	init(tour: AICTourModel) {
		tableVC = TourTableViewController(tour: tour)
		super.init(nibName: nil, bundle: nil)
	}
	
	// Exhibition Card
	init(exhibition: AICExhibitionModel) {
		tableVC = ExhibitionTableViewController(exhibition: exhibition)
		super.init(nibName: nil, bundle: nil)
	}
	
	// Event Card
	init(event: AICEventModel) {
		tableVC = EventTableViewController(event: event)
        super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        // Add main VC as subview to rootVC
        tableVC.willMove(toParentViewController: rootVC)
        rootVC.view.addSubview(tableVC.view)
        tableVC.didMove(toParentViewController: rootVC)
		
		createViewConstraints()
	}
	
	func createViewConstraints() {
        tableVC.view.autoPinEdge(.top, to: .top, of: rootVC.view, withOffset: contentTopMargin)
        tableVC.view.autoPinEdge(.leading, to: .leading, of: rootVC.view)
        tableVC.view.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
        tableViewHeightConstraint = tableVC.view.autoSetDimension(.height, toSize: Common.Layout.cardContentHeight - contentTopMargin)
	}
}

// Pan Gesture
extension ContentCardNavigationController {
    override internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == cardPanGesture {
            if tableVC.tableView.contentOffset.y <= 0 {
                return true
            }
        }
        return false
    }
}

