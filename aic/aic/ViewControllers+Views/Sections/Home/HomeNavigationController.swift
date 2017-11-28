//
//  HomeSectionNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/8/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class HomeNavigationController : SectionNavigationController {
	let homeVC: HomeViewController
	
	override init(section: AICSectionModel) {
		homeVC = HomeViewController(section: section)
		
		super.init(section: section)
		
		self.delegate = self
		
		homeVC.delegate = self
		homeVC.scrollDelegate = sectionNavigationBar
		
		self.pushViewController(homeVC, animated: false)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
}

extension HomeNavigationController : UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		
	}
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		
	}
}

extension HomeNavigationController : HomeViewControllerDelegate {
	func buttonPressed() {
		self.sectionNavigationBar.collapse()
		let vc = UIViewController()
		vc.view = UIView(frame: UIScreen.main.bounds)
		vc.view.backgroundColor = .purple
		self.pushViewController(vc, animated: true)
	}
}

