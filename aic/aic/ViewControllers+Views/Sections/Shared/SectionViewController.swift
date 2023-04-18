/*
Abstract:
Base view controller for all Section Views (NumberPad, What's On, Tours, Nearby and Info)
*/

import UIKit

protocol SectionViewControllerScrollDelegate: AnyObject {
	func sectionViewControllerWillAppearWithScrollView(scrollView: UIScrollView)
	func sectionViewControllerDidScroll(scrollView: UIScrollView)
}

class SectionViewController: UIViewController {
	var color: UIColor
	let sectionModel: AICSectionModel
	weak var scrollDelegate: SectionViewControllerScrollDelegate?

	init(section: AICSectionModel) {
		self.sectionModel = section
		self.color = section.color
		super.init(nibName: nil, bundle: nil)

		// Set the navigation item content
		self.navigationItem.title = sectionModel.title
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	func reset() {
		// Override this to reset view when going back
	}
}
