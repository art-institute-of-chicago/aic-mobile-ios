//
//  ContentCardNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 1/15/18.
//  Copyright © 2018 Art Institute of Chicago. All rights reserved.
//

import UIKit

class ContentCardNavigationController: CardNavigationController {
	var tableVC: UITableViewController

	init(tableVC: UITableViewController) {
		self.tableVC = tableVC
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Add main VC as subview to rootVC
		tableVC.willMove(toParent: rootVC)
		rootVC.view.addSubview(tableVC.view)
		tableVC.didMove(toParent: rootVC)

		createViewConstraints()

		// Accessibility
		downArrowButton.accessibilityLabel = "Close Card"
		self.accessibilityElements = [
			downArrowButton,
			tableVC.tableView
			]
			.compactMap { $0 }
	}

	func createViewConstraints() {
		tableVC.view.autoPinEdge(.top, to: .top, of: rootVC.view, withOffset: contentTopMargin)
		tableVC.view.autoPinEdge(.leading, to: .leading, of: rootVC.view)
		tableVC.view.autoPinEdge(.trailing, to: .trailing, of: rootVC.view)
		tableVC.view.autoSetDimension(.height, toSize: Common.Layout.cardContentHeight - contentTopMargin)
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
