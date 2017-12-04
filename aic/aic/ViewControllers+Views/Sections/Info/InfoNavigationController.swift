//
//  InfoNavigationController.swift
//  aic
//
//  Created by Filippo Vanucci on 11/17/17.
//  Copyright © 2017 Art Institute of Chicago. All rights reserved.
//

import UIKit

class InfoNavigationController : SectionNavigationController {
	let infoVC: InfoViewController
	
	override init(section: AICSectionModel) {
		infoVC = InfoViewController(section: section)
		
		super.init(section: section)
		
		self.delegate = self
		
		infoVC.delegate = self
		
		self.pushViewController(infoVC, animated: false)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
}

extension InfoNavigationController : UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		
	}
	
	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		// set SectionNavigationBar as scrollDelegateon homeVC only after it appears for the first time
		if viewController == infoVC && infoVC.scrollDelegate == nil {
			infoVC.scrollDelegate = sectionNavigationBar
		}
	}
}

extension InfoNavigationController : InfoViewControllerDelegate {
	func museumInfoButtonPressed() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)
		let vc = UIViewController()
		vc.view = UIView(frame: UIScreen.main.bounds)
		vc.view.backgroundColor = .white
		vc.navigationItem.title = "Museum Information"
		
		let label = UILabel(frame: vc.view.bounds)
		label.text = "Museum Information"
		label.textAlignment = .center
		label.font = .aicTitleFont
		vc.view.addSubview(label)
		self.pushViewController(vc, animated: true)
	}
	
	func languageButtonPressed() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)
		let vc = UIViewController()
		vc.view = UIView(frame: UIScreen.main.bounds)
		vc.view.backgroundColor = .white
		vc.navigationItem.title = "Language"
		
		let label = UILabel(frame: vc.view.bounds)
		label.text = "Language"
		label.textAlignment = .center
		label.font = .aicTitleFont
		vc.view.addSubview(label)
		self.pushViewController(vc, animated: true)
	}
	
	func locationButtonPressed() {
		self.sectionNavigationBar.collapse()
		self.sectionNavigationBar.setBackButtonHidden(false)
		let vc = UIViewController()
		vc.view = UIView(frame: UIScreen.main.bounds)
		vc.view.backgroundColor = .white
		vc.navigationItem.title = "Location Settings"
		
		let label = UILabel(frame: vc.view.bounds)
		label.text = "Location"
		label.textAlignment = .center
		label.font = .aicTitleFont
		vc.view.addSubview(label)
		self.pushViewController(vc, animated: true)
	}
}
